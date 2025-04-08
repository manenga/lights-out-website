class Race {
  final String name;
  final String circuitId;
  final DateTime date;
  bool isFavorite;
  
  Race({
    required this.name,
    required this.circuitId,
    required this.date,
    this.isFavorite = false,
  });

  factory Race.fromJson(Map<String, dynamic> json) {
    return Race(
      name: json['race_name'] as String,
      circuitId: json['circuit_id'] as String,
      date: DateTime.parse(json['race_date_time'] as String),
    );
  }
}