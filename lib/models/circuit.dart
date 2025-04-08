import 'package:lights_out_website/utils/country_utils.dart';

class Circuit {
  final int id;
  final String ref;
  final String name;
  final String location;
  final String country;

  Circuit({
    required this.id,
    required this.ref,
    required this.name,
    required this.location,
    required this.country,
  });

  String get flagEmoji {
    return CountryUtils.getFlagEmoji(country);
  }

  factory Circuit.fromJson(Map<String, dynamic> json) {
    return Circuit(
      id: json['circuitId'] as int,
      ref: json['circuitRef'] as String,
      name: json['name'] as String,
      location: json['location'] as String,
      country: json['country'] as String,
    );
  }
}