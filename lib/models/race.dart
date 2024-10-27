class Race {
  final String name;
  final String circuit;
  final DateTime date;
  final String country;
  final String flagEmoji;
  bool isFavorite;

  Race({
    required this.name,
    required this.circuit,
    required this.date,
    required this.country,
    required this.flagEmoji,
    this.isFavorite = false,
  });
}