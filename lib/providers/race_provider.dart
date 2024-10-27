import 'package:flutter/material.dart';
import '../models/race.dart';

class RaceProvider with ChangeNotifier {
  final List<Race> _races = [
    Race(
      name: 'Mexico City Grand Prix',
      circuit: 'Autodromo Hermanos Rodriguez',
      date: DateTime(2024, 10, 27),
      country: 'Mexico',
      flagEmoji: '🇲🇽',
    ),
    Race(
      name: 'Sao Paulo Grand Prix',
      circuit: 'Autodromo Jose Carlos Pace',
      date: DateTime(2024, 11, 3),
      country: 'Brazil',
      flagEmoji: '🇧🇷',
    ),
    Race(
      name: 'Las Vegas Grand Prix',
      circuit: 'Las Vegas Strip Street Circuit',
      date: DateTime(2024, 11, 23),
      country: 'USA',
      flagEmoji: '🇺🇸',
    ),
    Race(
      name: 'Abu Dhabi Grand Prix',
      circuit: 'Yas Marina Circuit',
      date: DateTime(2024, 12, 1),
      country: 'UAE',
      flagEmoji: '🇦🇪',
    ),
  ];

  List<Race> get races => _races;

  void toggleFavorite(int index) {
    _races[index].isFavorite = !_races[index].isFavorite;
    notifyListeners();
  }
}