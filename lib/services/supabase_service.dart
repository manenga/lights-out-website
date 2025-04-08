import 'package:flutter/material.dart';
import 'package:lights_out_website/models/circuit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/race.dart';

class SupabaseService {
  final SupabaseClient _client;

  SupabaseService(this._client);

  Future<List<Race>> getRaces() async {
    debugPrint('Fetching races...');
    try {
      final response = await _client
          .schema('prod')
          .from('races')
          .select()
          .order('race_date_time', ascending: true);
          
      debugPrint('Returning ${response.length} races...');
      return response.map((race) => Race.fromJson(race)).toList();
    } catch (e) {
      debugPrint('Error fetching races: $e');
      return [];
    }
  }

  Future<List<Circuit>> getCircuits() async {
    debugPrint('Fetching circuits...');
    try {
      final response = await _client
          .from('Circuits')
          .select();
          
      debugPrint('Returning ${response.length} circuits...');
      return response.map((circuit) => Circuit.fromJson(circuit)).toList();
    } catch (e) {
      debugPrint('Error fetching circuits: $e');
      return [];
    }
  }
} 