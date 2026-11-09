import 'package:revida/features/pages/domain/entities/contenedor.dart';

abstract class AnalisisState {}

class AnalisisInitial extends AnalisisState {}

class AnalisisLoading extends AnalisisState {}

class AnalisisSuccess extends AnalisisState {
  final String objetoDetectado;
  final String nombreObjeto;
  final double confianza;
  final String categoriaResiduo;
  final String tipoContenedor;
  final bool buscandoContenedor;
  final ContenedorCercano? contenedorCercano;
  final String? avisoContenedor;

  AnalisisSuccess({
    required this.objetoDetectado,
    required this.nombreObjeto,
    required this.confianza,
    required this.categoriaResiduo,
    required this.tipoContenedor,
    this.buscandoContenedor = false,
    this.contenedorCercano,
    this.avisoContenedor,
  });

  AnalisisSuccess conAviso({
    required bool buscandoContenedor,
    ContenedorCercano? contenedorCercano,
    String? avisoContenedor,
  }) {
    return AnalisisSuccess(
      objetoDetectado: objetoDetectado,
      nombreObjeto: nombreObjeto,
      confianza: confianza,
      categoriaResiduo: categoriaResiduo,
      tipoContenedor: tipoContenedor,
      buscandoContenedor: buscandoContenedor,
      contenedorCercano: contenedorCercano,
      avisoContenedor: avisoContenedor,
    );
  }
}

class AnalisisError extends AnalisisState {
  final String mensaje;
  
  AnalisisError(this.mensaje);
}