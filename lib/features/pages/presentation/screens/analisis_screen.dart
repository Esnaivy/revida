import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:revida/features/pages/presentation/cubits/image_db_revida/image_db_revida_cubit.dart';
import 'package:revida/features/pages/domain/entities/contenedor.dart';
import 'package:revida/config/theme/app_colors.dart';
import 'package:revida/features/pages/presentation/cubits/analisis/analisis_cubit.dart';
import 'package:revida/features/pages/presentation/cubits/analisis/analisis_state.dart';

class AnalisisScreen extends StatelessWidget {
  static String name = 'analisis';
  final String imagePath;

  const AnalisisScreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AnalisisCubit(),
      child: _AnalisisBody(imagePath: imagePath),
    );
  }
}

class _AnalisisBody extends StatefulWidget {
  const _AnalisisBody({required this.imagePath});
  final String imagePath;

  @override
  State<_AnalisisBody> createState() => _AnalisisBodyState();
}

class _AnalisisBodyState extends State<_AnalisisBody> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnalisisCubit>().analizarResiduo(widget.imagePath);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Análisis IA',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<AnalisisCubit, AnalisisState>(
        builder: (context, state) {
          if (state is AnalisisLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFF10B981)),
                  SizedBox(height: 16),
                  Text(
                    'Analizando residuo...',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          if (state is AnalisisSuccess) {
            return _AnalisisSuccessBody(
              imagePath: widget.imagePath,
              state: state,
            );
          }

          if (state is AnalisisError) {
            return Center(
              child: Text(
                state.mensaje,
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _AnalisisSuccessBody extends StatefulWidget {
  const _AnalisisSuccessBody({required this.imagePath, required this.state});

  final String imagePath;
  final AnalisisSuccess state;

  @override
  State<_AnalisisSuccessBody> createState() => _AnalisisSuccessBodyState();
}

class _AnalisisSuccessBodyState extends State<_AnalisisSuccessBody> {
  bool _guardando = false;

  Color _getColorForCategory(String category) {
    final cat = category.toLowerCase();
    if (cat.contains('plástico') || cat.contains('plastico')) {
      return Colors.blue;
    }
    if (cat.contains('papel') ||
        cat.contains('cartón') ||
        cat.contains('carton')) {
      return const Color(0xFF8D6E63);
    }
    if (cat.contains('metal') || cat.contains('aluminio')) {
      return Colors.grey.shade600;
    }
    if (cat.contains('orgánico') || cat.contains('organico')) {
      return Colors.green;
    }
    return const Color(0xFF10B981);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final state = widget.state;
    final imagePath = widget.imagePath;
    final categoryColor = _getColorForCategory(state.categoriaResiduo);
    final String confianzaStr = (state.confianza * 100).toStringAsFixed(1);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Container(
              height: 280,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.file(File(imagePath), fit: BoxFit.fitHeight),
              ),
            ),

            const SizedBox(height: 24),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.card(context),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: categoryColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      state.nombreObjeto.toUpperCase(),
                      style: textTheme.headlineMedium!.copyWith(
                        color: categoryColor,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.categoriaResiduo,
                    style: textTheme.titleMedium!.copyWith(
                      color: AppColors.onSurface(context),
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Precisión del modelo: $confianzaStr%',
                    style: textTheme.bodyMedium!.copyWith(
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            _AvisoContenedor(state: state, color: categoryColor),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton.icon(
                onPressed: _guardando
                    ? null
                    : () async {
                  setState(() => _guardando = true);
                  final ok = await context
                      .read<ImageDbRevidaCubit>()
                      .registrarDeteccion(
                        pathImagen: imagePath,
                        categoria: state.categoriaResiduo,
                        confianza: state.confianza,
                      );

                  if (!context.mounted) return;

                  final resultado = context.read<ImageDbRevidaCubit>().state;
                  final mensaje = ok
                      ? 'Reciclaje registrado correctamente'
                      : resultado is ImageDbRevidaError
                      ? resultado.message
                      : 'No se pudo registrar el reciclaje';

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(mensaje)),
                  );

                  if (ok) {
                    context.go('/');
                    return;
                  }
                  if (mounted) setState(() => _guardando = false);
                },
                icon: const Icon(
                  Icons.check_circle_outline_rounded,
                  size: 28,
                  color: Colors.white,
                ),
                label: Text(
                  '¡Registrar Reciclaje!',
                  style: textTheme.titleLarge!.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 5,
                  shadowColor: const Color(0xFF10B981).withValues(alpha: 0.5),
                ),
              ),
            ),
            const SizedBox(height: 10),

            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Escanear de nuevo',
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AvisoContenedor extends StatelessWidget {
  const _AvisoContenedor({required this.state, required this.color});

  final AnalisisSuccess state;
  final Color color;

  String _texto(ContenedorCercano contenedor) {
    final distancia = contenedor.distanciaMetros < 1000
        ? '${contenedor.distanciaMetros.round()} m'
        : '${(contenedor.distanciaMetros / 1000).toStringAsFixed(1)} km';
    final lugar = contenedor.referencia.trim().isEmpty
        ? ''
        : ' Queda en ${contenedor.referencia.trim()}.';
    return 'El contenedor de ${_etiquetaTipo(state.tipoContenedor)} más cercano es "${contenedor.nombre}", a $distancia.$lugar Puedes desecharlo ahí.';
  }

  String _etiquetaTipo(String tipo) {
    switch (tipo) {
      case 'papel':
        return 'papel y cartón';
      case 'plastico':
        return 'plástico';
      case 'vidrio':
        return 'vidrio';
      case 'metal':
        return 'metal';
      default:
        return 'ese tipo';
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final buscando = state.buscandoContenedor;
    final contenedor = state.contenedorCercano;
    final mensaje = contenedor != null
        ? _texto(contenedor)
        : (state.avisoContenedor ?? 'Buscando un contenedor cerca de ti...');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (buscando)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.4, color: color),
              ),
            )
          else
            Icon(
              contenedor != null
                  ? Icons.location_on_rounded
                  : Icons.info_outline_rounded,
              color: color,
              size: 24,
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              mensaje,
              style: textTheme.bodyMedium!.copyWith(
                color: Colors.grey.shade800,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
