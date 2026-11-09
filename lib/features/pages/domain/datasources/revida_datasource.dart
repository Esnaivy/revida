import 'package:revida/features/pages/domain/entities/contenedor.dart';
import 'package:revida/features/pages/domain/entities/reciclaje.dart';

abstract class RevidaDatasource {
  Future<void> procesarYGuardarDeteccion(String categoria, String imageUrl, double confianza);
  Future<List<Reciclaje>> loadReciclajes();
  Future<List<Reciclaje>> borrarData();

  /// Contenedor del [tipo] (`papel`, `plastico`, `vidrio`, `metal`) más
  /// cercano a la ubicación actual. Los documentos viven en `contenedores`
  /// con `nombre`, `tipo`, `latitud`, `longitud` y `referencia`.
  Future<ContenedorCercano?> contenedorMasCercano({
    required String tipo,
    required double latitud,
    required double longitud,
  });
}