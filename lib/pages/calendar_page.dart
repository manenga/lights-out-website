import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/race_provider.dart';
import '../widgets/app_layout.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    final raceProvider = Provider.of<RaceProvider>(context);
    
    return AppLayout(
      title: 'Race Calendar',
      child: Column(
        children: [
          Card(
            child: TableCalendar(
              firstDay: DateTime(2024),
              lastDay: DateTime(2024, 12, 31),
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
                return raceProvider.races
                    .where((race) => isSameDay(race.date, day))
                    .toList();
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
            ...raceProvider.races
                .where((race) => isSameDay(race.date, _selectedDay!))
                .map((race) => Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  race.flagEmoji,
                                  style: const TextStyle(fontSize: 24),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  race.name,
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              race.circuit,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Country: ${race.country}',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                                IconButton(
                                  icon: Icon(
                                    race.isFavorite ? Icons.star : Icons.star_border,
                                    color: race.isFavorite ? Colors.amber : null,
                                  ),
                                  onPressed: () => raceProvider.toggleFavorite(
                                    raceProvider.races.indexOf(race),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ))
                .toList(),
        ],
      ),
    );
  }
}