import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:path_provider/path_provider.dart';
import 'package:revida/features/pages/domain/datasources/revida_datasource.dart';
import 'package:revida/features/pages/infrastructure/datasources/revida_datasource_impl.dart';
import 'package:revida/features/pages/presentation/cubits/analisis/analisis_state.dart';

class AnalisisCubit extends Cubit<AnalisisState> {
  AnalisisCubit({RevidaDatasource? datasource})
    : _datasource = datasource ?? RevidaDatasourceImpl(),
      super(AnalisisInitial());

  final RevidaDatasource _datasource;

  Future<String> _copiarModelo() async {
    final byteData = await rootBundle.load('assets/image_model/model.tflite');
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/model.tflite');

    await file.writeAsBytes(byteData.buffer.asUint8List());
    return file.path;
  }

  Future<void> analizarResiduo(String rutaImagen) async {
    emit(AnalisisLoading());

    ImageLabeler? imageLabeler;
    try {
      final modelPath = await _copiarModelo();
      final options = LocalLabelerOptions(modelPath: modelPath);
      imageLabeler = ImageLabeler(options: options);

      final inputImage = InputImage.fromFilePath(rutaImagen);

      final List<ImageLabel> labels = await imageLabeler.processImage(
        inputImage,
      );

      if (labels.isEmpty) {
        emit(AnalisisError('No se pudo identificar ningún objeto claramente.'));
        return;
      }

      labels.sort((a, b) => b.confidence.compareTo(a.confidence));

      final mejorPrediccion = labels.first;
      final indice = mejorPrediccion.index;
      final confianza = mejorPrediccion.confidence;

      const listaEtiquetas = [
        'cardboard',
        'glass',
        'metal',
        'paper',
        'plastic',
      ];

      final objetoDetectado = (indice >= 0 && indice < listaEtiquetas.length)
          ? listaEtiquetas[indice]
          : 'desconocido';
      final clasificacion = _clasificar(objetoDetectado);

      final resultado = AnalisisSuccess(
        objetoDetectado: objetoDetectado,
        nombreObjeto: clasificacion.nombre,
        confianza: confianza,
        categoriaResiduo: clasificacion.categoria,
        tipoContenedor: clasificacion.tipo,
        buscandoContenedor: clasificacion.tipo.isNotEmpty,
      );
      emit(resultado);

      if (clasificacion.tipo.isEmpty) {
        emit(
          resultado.conAviso(
            buscandoContenedor: false,
            avisoContenedor:
                'No pude asociar este residuo a un tipo de contenedor. Revísalo antes de desecharlo.',
          ),
        );
        return;
      }

      await _buscarContenedorCercano(resultado);
    } catch (e, s) {
      print(s);
      emit(AnalisisError('Error al analizar la imagen: $e'));
    } finally {
      imageLabeler?.close();
    }
  }

  Future<void> _buscarContenedorCercano(AnalisisSuccess resultado) async {
    try {
      final posicion = await _ubicacionActual();
      if (posicion == null) {
        emit(
          resultado.conAviso(
            buscandoContenedor: false,
            avisoContenedor:
                'Activa la ubicación para indicarte el contenedor de ${resultado.nombreObjeto.toLowerCase()} más cercano.',
          ),
        );
        return;
      }

      final contenedor = await _datasource.contenedorMasCercano(
        tipo: resultado.tipoContenedor,
        latitud: posicion.latitude,
        longitud: posicion.longitude,
      );

      if (contenedor == null) {
        emit(
          resultado.conAviso(
            buscandoContenedor: false,
            avisoContenedor:
                'No hay contenedores de ${resultado.nombreObjeto.toLowerCase()} registrados cerca de ti.',
          ),
        );
        return;
      }

      emit(
        resultado.conAviso(
          buscandoContenedor: false,
          contenedorCercano: contenedor,
        ),
      );
    } catch (e) {
      emit(
        resultado.conAviso(
          buscandoContenedor: false,
          avisoContenedor:
              'No se pudo consultar la base de contenedores. Revisa la conexión con Firebase.',
        ),
      );
    }
  }

  Future<Position?> _ubicacionActual() async {
    final servicioActivo = await Geolocator.isLocationServiceEnabled();
    if (!servicioActivo) return null;

    var permiso = await Geolocator.checkPermission();
    if (permiso == LocationPermission.denied) {
      permiso = await Geolocator.requestPermission();
    }
    if (permiso == LocationPermission.denied ||
        permiso == LocationPermission.deniedForever) {
      return null;
    }

    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 12),
        ),
      );
    } on TimeoutException {
      return null;
    }
  }

  ({String nombre, String categoria, String tipo}) _clasificar(String etiqueta) {
    switch (etiqueta) {
      case 'cardboard':
        return (
          nombre: 'Cartón',
          categoria: 'Papel y Cartón 📦',
          tipo: 'papel',
        );
      case 'paper':
        return (
          nombre: 'Papel',
          categoria: 'Papel y Cartón 📦',
          tipo: 'papel',
        );
      case 'plastic':
        return (
          nombre: 'Plástico',
          categoria: 'Plástico Reciclable 🥤',
          tipo: 'plastico',
        );
      case 'glass':
        return (
          nombre: 'Vidrio',
          categoria: 'Vidrio 🍾',
          tipo: 'vidrio',
        );
      case 'metal':
        return (
          nombre: 'Metal',
          categoria: 'Metales / Latas 🥫',
          tipo: 'metal',
        );
      default:
        return (
          nombre: 'Desconocido',
          categoria: 'Desconocido - Verifica manualmente ⚠️',
          tipo: '',
        );
    }
  }
}
