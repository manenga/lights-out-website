import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/circuit.dart';
import '../../services/supabase_service.dart';
import 'circuit_event.dart';
import 'circuit_state.dart';

class CircuitBloc extends Bloc<CircuitEvent, CircuitState> {
  final SupabaseService _service;

  CircuitBloc(this._service) : super(CircuitInitial()) {
    on<LoadCircuitsEvent>(_onLoadCircuits);
  }

  Future<void> _onLoadCircuits(LoadCircuitsEvent event, Emitter<CircuitState> emit) async {
    try {
      emit(CircuitLoading());
      final circuits = await _service.getCircuits();
      emit(CircuitLoaded(circuits));
    } catch (e) {
      emit(CircuitError(e.toString()));
    }
  }
} 