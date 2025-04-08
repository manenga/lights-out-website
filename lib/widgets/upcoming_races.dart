import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lights_out_website/blocs/circuit/circuit_state.dart';
import 'package:lights_out_website/blocs/race/race_state.dart';
import '../blocs/race/race_bloc.dart';
import '../blocs/circuit/circuit_bloc.dart';
import '../models/race.dart';
import '../models/circuit.dart';

class UpcomingRacesWidget extends StatelessWidget {
  const UpcomingRacesWidget({super.key});

  String _formatDate(DateTime date) {
    String daySuffix;
    if (date.day % 10 == 1 && date.day != 11) {
      daySuffix = 'st';
    } else if (date.day % 10 == 2 && date.day != 12) {
      daySuffix = 'nd';
    } else if (date.day % 10 == 3 && date.day != 13) {
      daySuffix = 'rd';
    } else {
      daySuffix = 'th';
    }
    
    return '${date.day}$daySuffix ${_getMonthName(date.month)} ${date.year}';
  }

  String _getMonthName(int month) {
    const monthNames = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return monthNames[month];
  }

  String _getCountdown(DateTime raceDate) {
    final now = DateTime.now();
    final difference = raceDate.difference(now);

    if (difference.isNegative) {
      return 'Race has already started';
    }

    final days = difference.inDays;
    final hours = difference.inHours % 24;
    final minutes = difference.inMinutes % 60;

    if (days > 0) {
      return '$days days to go!';
    } else if (hours > 0) {
      return '$hours hours $minutes minutes to go!';
    } else {
      return '$minutes minutes to go!';
    }
  }

  List<Race> _getUpcomingRaces(List<Race> races) {
    return races.where((race) => race.date.isAfter(DateTime.now())).toList();
  }

  Circuit? _findCircuit(String circuitId, List<Circuit> circuits) {
    try {
      return circuits.firstWhere((circuit) => circuit.id.toString() == circuitId);
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RaceBloc, RaceState>(
      builder: (context, raceState) {
        if (raceState is RaceLoading) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }

        if (raceState is RaceError) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Center(
                child: Text(
                  raceState.message,
                  style: TextStyle(color: Colors.red[700]),
                ),
              ),
            ),
          );
        }

        if (raceState is RaceLoaded) {
          final upcomingRaces = _getUpcomingRaces(raceState.races);
          
          if (upcomingRaces.isEmpty) {
            return const Card(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Center(
                  child: Text('No upcoming races'),
                ),
              ),
            );
          }

          return BlocBuilder<CircuitBloc, CircuitState>(
            builder: (context, circuitState) {
              if (circuitState is CircuitLoading) {
                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                );
              }

              if (circuitState is CircuitError) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Center(
                      child: Text(
                        circuitState.message,
                        style: TextStyle(color: Colors.red[700]),
                      ),
                    ),
                  ),
                );
              }

              if (circuitState is CircuitLoaded) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Upcoming Races',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 16),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: upcomingRaces.length,
                          itemBuilder: (context, index) {
                            final race = upcomingRaces[index];
                            final circuit = _findCircuit(race.circuitId, circuitState.circuits);
                            
                            if (circuit == null) {
                              return const SizedBox.shrink();
                            }

                            return Card(
                              child: ListTile(
                                leading: Text(
                                  circuit.flagEmoji,
                                  style: const TextStyle(fontSize: 32),
                                ),
                                title: Text(
                                  race.name, 
                                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Text(
                                      circuit.name,
                                    ),
                                    Text(
                                      _formatDate(race.date),
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                                trailing: Text(
                                  _getCountdown(race.date), 
                                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              }

              return const SizedBox.shrink();
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
