import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lights_out_website/blocs/circuit/circuit_state.dart';
import 'package:lights_out_website/blocs/race/race_state.dart';
import 'package:table_calendar/table_calendar.dart';
import '../blocs/race/race_bloc.dart';
import '../blocs/circuit/circuit_bloc.dart';
import '../models/circuit.dart';
import '../widgets/app_layout.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  final int _currentYear = DateTime.now().year;
  DateTime? _selectedDay;

  Circuit? _findCircuit(String circuitId, List<Circuit> circuits) {
    try {
      return circuits.firstWhere((circuit) => circuit.id.toString() == circuitId);
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      title: 'Race Calendar',
      currentRoute: '/calendar',
      child: Column(
        children: [
          Card(
            child: TableCalendar(
              firstDay: DateTime(_currentYear),
              lastDay: DateTime(_currentYear, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              eventLoader: (day) {
                final state = context.read<RaceBloc>().state;
                if (state is RaceLoaded) {
                  return state.races
                      .where((race) => isSameDay(race.date, day))
                      .toList();
                }
                return [];
              },
              calendarStyle: CalendarStyle(
                markerDecoration: BoxDecoration(
                  color: Colors.red[600],
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          if (_selectedDay != null)
            BlocBuilder<RaceBloc, RaceState>(
              builder: (context, raceState) {
                if (raceState is RaceLoaded) {
                  final races = raceState.races
                      .where((race) => isSameDay(race.date, _selectedDay!))
                      .toList();

                  return BlocBuilder<CircuitBloc, CircuitState>(
                    builder: (context, circuitState) {
                      if (circuitState is CircuitLoaded) {
                        return Column(
                          children: races.map((race) {
                            final circuit = _findCircuit(race.circuitId, circuitState.circuits);
                            if (circuit == null) return const SizedBox.shrink();

                            return Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        // Text(
                                        //   circuit.flagEmoji,
                                        //   style: const TextStyle(fontSize: 24),
                                        // ),
                                        // const SizedBox(width: 8),
                                        Text(
                                          race.name,
                                          style: Theme.of(context).textTheme.titleLarge,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      circuit.name,
                                      style: Theme.of(context).textTheme.titleMedium,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Country: ${circuit.country}',
                                      style: Theme.of(context).textTheme.bodyLarge,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
        ],
      ),
    );
  }
}