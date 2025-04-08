import 'package:equatable/equatable.dart';
import '../../models/circuit.dart';

abstract class CircuitState extends Equatable {
  const CircuitState();

  @override
  List<Object> get props => [];
}

class CircuitInitial extends CircuitState {}

class CircuitLoading extends CircuitState {}

class CircuitLoaded extends CircuitState {
  final List<Circuit> circuits;
  const CircuitLoaded(this.circuits);

  @override
  List<Object> get props => [circuits];
}

class CircuitError extends CircuitState {
  final String message;
  const CircuitError(this.message);

  @override
  List<Object> get props => [message];
} 