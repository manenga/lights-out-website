import 'package:flutter/material.dart';
import '../providers/race_provider.dart';

class UpcomingRacesWidget extends StatelessWidget {
  const UpcomingRacesWidget({
    super.key,
    required this.raceProvider,
  });

  final RaceProvider raceProvider;

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

  @override
  Widget build(BuildContext context) {
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
              itemCount: raceProvider.upcomingRaces.length,
              itemBuilder: (context, index) {
                final race = raceProvider.upcomingRaces[index];
                return Card(
                  child: ListTile(
                    leading: Text(
                      race.flagEmoji,
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
                          race.circuit,
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
}
