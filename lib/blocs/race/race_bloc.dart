import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/race.dart';
import '../../services/supabase_service.dart';
import 'race_event.dart';
import 'race_state.dart';

class RaceBloc extends Bloc<RaceEvent, RaceState> {
  final SupabaseService _service;

  RaceBloc(this._service) : super(RaceInitial()) {
    on<LoadRacesEvent>(_onLoadRaces);
    on<ToggleFavoriteEvent>(_onToggleFavorite);
  }

  Future<void> _onLoadRaces(LoadRacesEvent event, Emitter<RaceState> emit) async {
    try {
      emit(RaceLoading());
      final races = await _service.getRaces();
      emit(RaceLoaded(races));
    } catch (e) {
      emit(RaceError(e.toString()));
    }
  }

  void _onToggleFavorite(ToggleFavoriteEvent event, Emitter<RaceState> emit) {
    if (state is RaceLoaded) {
      final currentState = state as RaceLoaded;
      final updatedRaces = List<Race>.from(currentState.races);
      updatedRaces[event.index].isFavorite = !updatedRaces[event.index].isFavorite;
      emit(RaceLoaded(updatedRaces));
    }
  }
} 