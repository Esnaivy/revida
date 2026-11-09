import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:revida/features/pages/domain/datasources/revida_datasource.dart';
import 'package:revida/features/pages/domain/entities/contenedor.dart';
import 'package:revida/features/pages/domain/entities/reciclaje.dart';

class RevidaDatasourceImpl extends RevidaDatasource {
  @override
  Future<void> procesarYGuardarDeteccion(
    String categoria,
    String imageUrl,
    double confianza,
  ) async {
    try {
      String? uid = FirebaseAuth.instance.currentUser?.uid;

      if (uid != null) {
        // 3. Guardar todo en Firestore (colección 'residuos')
        await FirebaseFirestore.instance.collection('residuos').add({
          'categoria': categoria,
          'confianza': confianza,
          'imageUrl': imageUrl,
          'userId': uid,
          'date': FieldValue.serverTimestamp(),
        });
        print("¡Éxito! Imagen y datos guardados.");
      } else {
        print("Error: No hay usuario autenticado.");
      }
    } catch (e) {
      print("Error en el proceso: $e");
    }
  }

  @override
  Future<List<Reciclaje>> loadReciclajes() async {
    try {
      // 1. Obtener el ID del usuario actual
      final String? uid = FirebaseAuth.instance.currentUser?.uid;

      if (uid == null) {
        print("Error: No hay usuario autenticado.");
        return [];
      }

      // 2. Consultar la colección filtrando por el userId

      final querySnapshot = await FirebaseFirestore.instance
          .collection('residuos')
          .where('userId', isEqualTo: uid)
          .orderBy('date', descending: true)
          .get();

      // 3. Mapear los documentos a tu entidad Reciclaje
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        print('Se mapeo correctamente');

        return Reciclaje(
          categoria: data['categoria'] ?? '',
          imageUrl: data['imageUrl'] ?? '',
          confianza: (data['confianza'] as num?)?.toDouble() ?? 0.0,
          date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
        );
      }).toList();
    } catch (e) {
      print("Error al cargar reciclajes: $e");
      return [];
    }
  }

  @override
  Future<List<Reciclaje>> borrarData() async {
    try {
      // Obtener UID del usuario actual
      final String? uid = FirebaseAuth.instance.currentUser?.uid;

      if (uid == null) {
        print("Error: No hay usuario autenticado.");
        return [];
      }

      // Buscar todos los documentos del usuario
      final querySnapshot = await FirebaseFirestore.instance
          .collection('residuos')
          .where('userId', isEqualTo: uid)
          .get();

      // Eliminar cada documento
      for (final doc in querySnapshot.docs) {
        await doc.reference.delete();
      }

      print("Todos los documentos del usuario fueron eliminados.");

      return [];
    } catch (e) {
      print("Error al borrar reciclajes: $e");
      return [];
    }
  }

  @override
  Future<ContenedorCercano?> contenedorMasCercano({
    required String tipo,
    required double latitud,
    required double longitud,
  }) async {
    final coleccion = FirebaseFirestore.instance.collection('contenedores');
    var snapshot = await coleccion.where('tipo', isEqualTo: tipo).get();

    if (snapshot.docs.isEmpty) {
      snapshot = await coleccion.get();
    }

    ContenedorCercano? masCercano;

    for (final doc in snapshot.docs) {
      final data = doc.data();
      if (_normalizarTipo(data['tipo']?.toString() ?? '') != tipo) continue;

      final lat = _comoDouble(data['latitud'] ?? data['lat'] ?? data['latitude']);
      final lng = _comoDouble(
        data['longitud'] ?? data['lng'] ?? data['lon'] ?? data['longitude'],
      );
      if (lat == null || lng == null) continue;

      final distancia = _distanciaMetros(latitud, longitud, lat, lng);
      final candidato = ContenedorCercano(
        id: doc.id,
        nombre: (data['nombre'] ?? data['name'] ?? 'Contenedor').toString(),
        tipo: tipo,
        latitud: lat,
        longitud: lng,
        referencia: (data['referencia'] ?? data['direccion'] ?? data['address'] ?? '')
            .toString(),
        distanciaMetros: distancia,
      );

      if (masCercano == null || distancia < masCercano.distanciaMetros) {
        masCercano = candidato;
      }
    }

    return masCercano;
  }

  double? _comoDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  String _normalizarTipo(String raw) {
    final tipo = raw.toLowerCase();
    if (tipo.contains('plast')) return 'plastico';
    if (tipo.contains('papel') ||
        tipo.contains('carton') ||
        tipo.contains('cartón') ||
        tipo.contains('cardboard')) {
      return 'papel';
    }
    if (tipo.contains('vidr') || tipo.contains('glass')) return 'vidrio';
    if (tipo.contains('metal') || tipo.contains('lata') || tipo.contains('alum')) {
      return 'metal';
    }
    return tipo.trim();
  }

  double _distanciaMetros(double lat1, double lon1, double lat2, double lon2) {
    const radioTierra = 6371000.0;
    final dLat = _gradosARadianes(lat2 - lat1);
    final dLon = _gradosARadianes(lon2 - lon1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_gradosARadianes(lat1)) *
            math.cos(_gradosARadianes(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    return radioTierra * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }

  double _gradosARadianes(double grados) => grados * math.pi / 180;
}
