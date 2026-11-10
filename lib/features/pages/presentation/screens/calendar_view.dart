import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:revida/config/theme/app_colors.dart';
import 'package:revida/features/pages/presentation/cubits/image_db_revida/image_db_revida_cubit.dart';

class CalendarView extends StatefulWidget {
  const CalendarView({super.key});

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  final CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          BlocBuilder<ImageDbRevidaCubit, ImageDbRevidaState>(
            builder: (context, state) {
              List<DateTime> diasConReciclaje = [];

              if (state is ImageDbRevidaInitial) {
                context.read<ImageDbRevidaCubit>().loadReciclajes();
              }

              if (state is ImageDbRevidaLoaded) {
                final reciclajes = state.reciclajes;

                diasConReciclaje = reciclajes.map((r) {
                  final d = r.date; 
                  return DateTime(d.year, d.month, d.day);
                }).toSet().toList();
              }

              return TableCalendar(
                firstDay: DateTime.utc(2024, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                startingDayOfWeek: StartingDayOfWeek.monday,

                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },

                eventLoader: (day) {
                  if (diasConReciclaje.any((d) => isSameDay(d, day))) {
                    return ['Reciclaje'];
                  }
                  return [];
                },

                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: TextStyle(
                    color: AppColors.isDark(context)
                        ? const Color(0xFFB7F7C8)
                        : const Color(0xFF2E7D32),
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                  leftChevronIcon: Icon(
                    Icons.chevron_left,
                    color: AppColors.onSurface(context),
                  ),
                  rightChevronIcon: Icon(
                    Icons.chevron_right,
                    color: AppColors.onSurface(context),
                  ),
                ),

                daysOfWeekStyle: DaysOfWeekStyle(
                  weekdayStyle: TextStyle(color: AppColors.onSurface(context)),
                  weekendStyle: const TextStyle(color: Colors.redAccent),
                ),
                calendarStyle: CalendarStyle(
                  selectedDecoration: const BoxDecoration(
                    color: Color(0xFF10B981),
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: const Color(0xFF5DB075).withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  markerDecoration: const BoxDecoration(
                    color: Color(0xFF2E7D32),
                    shape: BoxShape.circle,
                  ),
                  defaultTextStyle: TextStyle(
                    color: AppColors.isDark(context)
                        ? const Color(0xFFB7F7C8)
                        : const Color(0xFF2E7D32),
                    fontWeight: FontWeight.bold,
                  ),
                  outsideTextStyle: TextStyle(
                    color: AppColors.onSurface(context).withValues(alpha: 0.4),
                  ),
                  weekendTextStyle: const TextStyle(color: Colors.redAccent),
                ),
              );
            },
          ),

          const SizedBox(height: 15),

          if (_selectedDay != null)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.card(context).withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                (context.read<ImageDbRevidaCubit>().state is ImageDbRevidaLoaded &&
                        (context.read<ImageDbRevidaCubit>().state as ImageDbRevidaLoaded)
                            .reciclajes
                            .any((r) {
                          final d = r.date;
                          return isSameDay(DateTime(d.year, d.month, d.day), _selectedDay);
                        }))
                    ? "♻️ Registraste material este día!!"
                    : "😢 No hay registros este día",
                style: TextStyle(
                  color: AppColors.isDark(context)
                      ? const Color(0xFFB7F7C8)
                      : const Color(0xFF2E7D32),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}