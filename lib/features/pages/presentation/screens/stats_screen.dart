import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:revida/config/theme/app_colors.dart';
import 'package:revida/features/pages/presentation/cubits/image_db_revida/image_db_revida_cubit.dart';
import 'package:revida/features/pages/presentation/screens/flow_chart.dart';
import 'package:go_router/go_router.dart';
import 'package:revida/features/pages/presentation/screens/calendar_view.dart';

class StatsScreen extends StatefulWidget {
  static String name = 'stats';
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();

  static BoxDecoration _cardDecoration(BuildContext context) {
    return BoxDecoration(
      color: AppColors.isDark(context)
          ? const Color(0xFF1B3A2A)
          : const Color.fromARGB(255, 203, 255, 207),
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withAlpha(30),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}

class _StatsScreenState extends State<StatsScreen> {
  Options _currentOption = Options.option1;

  List<bool> recicladoDias = List.generate(28, (index) => index % 3 == 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Estadísticas')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SingleChoice(
                onChanged: (value) {
                  setState(() {
                    _currentOption = value;
                  });
                },
              ),

              const SizedBox(height: 30),

              Container(
                height: 500,
                width: double.infinity,
                decoration: StatsScreen._cardDecoration(context),
                child: Center(
                  child: _currentOption == Options.option1
                      ? BarChartSample1()
                      : CalendarView(),
                ),
              ),

              const SizedBox(height: 20),

              _GeneralStats(),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 120,
                child: ElevatedButton.icon(
                  onPressed: () => context.push('/history'),
                  icon: const Icon(Icons.history, size: 32),
                  label: const Text(
                    "Ver historial",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    elevation: 6,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GeneralStats extends StatelessWidget {
  const _GeneralStats();

  @override
  Widget build(BuildContext context) {
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
          final total = reciclajes.length;

          final now = DateTime.now();
          final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
          final reciclajesSemana = reciclajes.where((r) {
            return r.date.isAfter(startOfWeek);
          }).length;

          final Map<String, int> conteo = {};

          for (final r in reciclajes) {
            final cat = r.categoria.toLowerCase();

            conteo[cat] = (conteo[cat] ?? 0) + 1;
          }

          String tipoMasReciclado = 'Sin datos';

          if (conteo.isNotEmpty) {
            tipoMasReciclado = conteo.entries
                .reduce((a, b) => a.value > b.value ? a : b)
                .key;
          }

          String capitalizar(String text) =>
              text[0].toUpperCase() + text.substring(1);

          double co2Total = 0;

          for (final r in reciclajes) {
            final cat = r.categoria.toLowerCase();

            if (cat.contains('plastico') || cat.contains('plástico')) {
              co2Total += 1.5;
            } else if (cat.contains('papel')) {
              co2Total += 1.0;
            } else if (cat.contains('carton') || cat.contains('cartón')) {
              co2Total += 0.8;
            } else if (cat.contains('metal')) {
              co2Total += 2.0;
            } else if (cat.contains('vidrio')) {
              co2Total += 0.5;
            }
          }

          return Container(
            height: 180,
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: StatsScreen._cardDecoration(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Estadísticas Generales",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                SizedBox(height: 10),
                Text("♻ Total de residuos reciclados: $total"),
                Text("🗓 Reciclajes esta semana: $reciclajesSemana "),
                Text("🏆 Tipo más reciclado: ${capitalizar(tipoMasReciclado)}"),
                Text("🌎 CO₂ evitado: $co2Total kg"),
              ],
            ),
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

enum Options { option1, option2 }

class SingleChoice extends StatefulWidget {
  final ValueChanged<Options> onChanged;

  const SingleChoice({super.key, required this.onChanged});

  @override
  State<SingleChoice> createState() => _SingleChoiceState();
}

class _SingleChoiceState extends State<SingleChoice> {
  Options? _selectedOption = Options.option1;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<Options>(
      style: SegmentedButton.styleFrom(
        backgroundColor: AppColors.card(context),
        selectedBackgroundColor: const Color(0xFF11C95A),
        selectedForegroundColor: Colors.white,
      ),
      segments: const <ButtonSegment<Options>>[
        ButtonSegment<Options>(
          value: Options.option1,
          label: Text('Gráfica de barras'),
        ),
        ButtonSegment<Options>(
          value: Options.option2,
          label: Text('Calendario'),
        ),
      ],
      selected: <Options>{_selectedOption!},
      onSelectionChanged: (Set<Options> newSelection) {
        setState(() {
          _selectedOption = newSelection.first;
        });
        widget.onChanged(_selectedOption!);
      },
    );
  }
}
