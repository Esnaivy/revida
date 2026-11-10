import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:revida/config/theme/app_colors.dart';
import 'package:revida/features/pages/presentation/cubits/image_db_revida/image_db_revida_cubit.dart';

class HomeScreen extends StatelessWidget {
  static String name = 'home-screen';
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                onPressed: () => context.push('/profile'),
                icon: const Icon(Icons.person, color: Color(0xFF10B981)),
              ),
            ),
          ),
        ],
      ),
      body: const _HomeBody(),
    );
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Column(
          children: const [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _RachaWidget(),
                    SizedBox(height: 16),
                    _MisResiduosButton(),
                    SizedBox(height: 16),
                    _TotalRecicYUltRecicl(),
                  ],
                ),
              ),
            ),
            SizedBox(height: 12),
            _EscanearButton(),
          ],
        ),
      ),
    );
  }
}

class _TotalRecicYUltRecicl extends StatelessWidget {
  const _TotalRecicYUltRecicl();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final verdeOscuro = AppColors.isDark(context)
        ? const Color(0xFFB7F7C8)
        : const Color(0xFF1B5E20);

    return BlocBuilder<ImageDbRevidaCubit, ImageDbRevidaState>(
      builder: (context, state) {
        if (state is ImageDbRevidaInitial) {
          context.watch<ImageDbRevidaCubit>().loadReciclajes();
        }

        if (state is ImageDbRevidaLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ImageDbRevidaLoaded) {
          final reciclajes = state.reciclajes;
          print(reciclajes);
          final total = reciclajes.length;

          final ultimo = reciclajes.isNotEmpty ? reciclajes.last : null;

          return Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  height: 180,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    color: AppColors.tint(context),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Residuos\nReciclados',
                        textAlign: TextAlign.center,
                        style: textTheme.titleMedium!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: verdeOscuro,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: Container(
                          alignment: Alignment.center,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.card(context),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            total.toString(),
                            style: textTheme.headlineMedium!.copyWith(
                              fontWeight: FontWeight.bold,
                              color: verdeOscuro,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  height: 180,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    color: AppColors.tint(context),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Último\nReciclado',
                        textAlign: TextAlign.center,
                        style: textTheme.titleMedium!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: verdeOscuro,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: Container(
                          alignment: Alignment.center,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.card(context),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ultimo == null
                              ? Text('Sin datos', style: textTheme.bodyMedium)
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      ultimo.categoria,
                                      style: textTheme.titleLarge!.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: verdeOscuro,
                                      ),
                                    ),
                                    Text(
                                      ultimo.date.toString(),
                                      style: textTheme.bodySmall!.copyWith(
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }

        if (state is ImageDbRevidaError) {
          return Center(child: Text(state.message));
        }

        return const SizedBox();
      },
    );
  }
}

class _RachaWidget extends StatelessWidget {
  const _RachaWidget();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      width: double.infinity,
      height: 130,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Racha Reciclando',
            style: textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: AppColors.inset(context),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  BlocBuilder<ImageDbRevidaCubit, ImageDbRevidaState>(
                    builder: (context, state) {
                      int racha = 0;

                      if (state is ImageDbRevidaLoaded) {
                        racha = state.racha;
                      }

                      return Text(
                        '$racha días',
                        style: textTheme.headlineSmall!.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.local_fire_department_rounded,
                    size: 40,
                    color: Color(0xFFFF9800), // Naranja vibrante
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EscanearButton extends StatelessWidget {
  const _EscanearButton();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: () => context.push('/camara'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF10B981),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF10B981).withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Spacer(),
            Text(
              'Escanear',
              style: textTheme.headlineSmall!.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const Spacer(),
            const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 40),
          ],
        ),
      ),
    );
  }
}

class _MisResiduosButton extends StatelessWidget {
  const _MisResiduosButton();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return BlocBuilder<ImageDbRevidaCubit, ImageDbRevidaState>(
      builder: (context, state) {
        int plastico = 0;
        int papel = 0;
        int metal = 0;
        int vidrio = 0;

        if (state is ImageDbRevidaLoaded) {
          for (final r in state.reciclajes) {
            final cat = r.categoria.toLowerCase();

            if (cat.contains('plastico') || cat.contains('plástico')) {
              plastico++;
            } else if (cat.contains('papel') ||
                cat.contains('carton') ||
                cat.contains('cartón')) {
              papel++;
            } else if (cat.contains('metal')) {
              metal++;
            } else if (cat.contains('vidrio')) {
              vidrio++;
            }
          }
        }

        return GestureDetector(
          onTap: () => context.push('/stats'),
          child: Container(
            height: 280,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Mis Residuos',
                      style: textTheme.titleLarge!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 20,
                      color: Colors.grey,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _Residuo(
                        nomResiduo: 'Plástico',
                        numResiduo: plastico,
                        totalMeta: 100,
                        color: Colors.blue,
                      ),
                      _Residuo(
                        nomResiduo: 'Papel/Cartón',
                        numResiduo: papel,
                        totalMeta: 100,
                        color: const Color(0xFF8D6E63),
                      ),
                      _Residuo(
                        nomResiduo: 'Metal',
                        numResiduo: metal,
                        totalMeta: 100,
                        color: Colors.grey,
                      ),
                      _Residuo(
                        nomResiduo: 'Vidrio',
                        numResiduo: vidrio,
                        totalMeta: 100,
                        color: Colors.green,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Residuo extends StatelessWidget {
  const _Residuo({
    required this.nomResiduo,
    required this.numResiduo,
    required this.totalMeta,
    required this.color,
  });

  final String nomResiduo;
  final Color color;
  final int numResiduo;
  final int totalMeta;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    double progress = (totalMeta == 0) ? 0 : numResiduo / totalMeta;

    return Row(
      children: [
        Icon(Icons.recycling_rounded, color: color, size: 24),
        const SizedBox(width: 12),
        SizedBox(
          width: 100,
          child: Text(
            nomResiduo,
            style: textTheme.titleSmall!.copyWith(fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: color.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 30,
          child: Text(
            numResiduo.toString(),
            textAlign: TextAlign.right,
            style: textTheme.titleSmall!.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
