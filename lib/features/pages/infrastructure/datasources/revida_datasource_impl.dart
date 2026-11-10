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
    final String? uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      throw Exception('No hay una sesión activa.');
    }

    await FirebaseFirestore.instance.collection('residuos').add({
      'categoria': categoria,
      'confianza': confianza,
      'imageUrl': imageUrl,
      'userId': uid,
      'date': FieldValue.serverTimestamp(),
    });
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

      final coleccion = FirebaseFirestore.instance.collection('residuos');
      QuerySnapshot<Map<String, dynamic>> querySnapshot;
      try {
        querySnapshot = await coleccion
            .where('userId', isEqualTo: uid)
            .orderBy('date', descending: true)
            .get();
      } catch (e) {
        // The composite index can still be building right after the first
        // saves. The equality query does not need it; sort on the device.
        print("Consulta ordenada no disponible, se ordena en el dispositivo: $e");
        querySnapshot = await coleccion.where('userId', isEqualTo: uid).get();
      }

      final reciclajes = querySnapshot.docs.map((doc) {
        final data = doc.data();

        return Reciclaje(
          categoria: data['categoria'] ?? '',
          imageUrl: data['imageUrl'] ?? '',
          confianza: (data['confianza'] as num?)?.toDouble() ?? 0.0,
          date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
        );
      }).toList();
      reciclajes.sort((a, b) => b.date.compareTo(a.date));
      return reciclajes;
    } catch (e) {
      print("Error al cargar reciclajes: $e");
      rethrow;
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
    // Read every container and match the type in the app. Documents in the
    // console often use "Papel", "plástico" or a GeoPoint instead of the
    // exact fields the first version expected.
    final snapshot = await coleccion.get();

    ContenedorCercano? masCercano;

    for (final doc in snapshot.docs) {
      final data = doc.data();
      if (_normalizarTipo(data['tipo']?.toString() ?? data['type']?.toString() ?? '') !=
          tipo) {
        continue;
      }

      final coords = _coordenadas(data);
      if (coords == null) continue;
      final lat = coords.$1;
      final lng = coords.$2;

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
    if (value is String) {
      return double.tryParse(value.trim().replaceAll(',', '.'));
    }
    return null;
  }

  (double, double)? _coordenadas(Map<String, dynamic> data) {
    final geo = data['ubicacion'] ?? data['location'] ?? data['geo'] ?? data['posicion'];
    if (geo is GeoPoint) return (geo.latitude, geo.longitude);
    if (geo is Map) {
      final lat = _comoDouble(geo['latitud'] ?? geo['lat'] ?? geo['latitude']);
      final lng = _comoDouble(
        geo['longitud'] ?? geo['lng'] ?? geo['lon'] ?? geo['longitude'],
      );
      if (lat != null && lng != null) return (lat, lng);
    }

    final lat = _comoDouble(data['latitud'] ?? data['lat'] ?? data['latitude']);
    final lng = _comoDouble(
      data['longitud'] ?? data['lng'] ?? data['lon'] ?? data['longitude'],
    );
    if (lat == null || lng == null) return null;
    return (lat, lng);
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
