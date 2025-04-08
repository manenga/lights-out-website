import 'package:equatable/equatable.dart';

abstract class CircuitEvent extends Equatable {
  const CircuitEvent();

  @override
  List<Object> get props => [];
}

class LoadCircuitsEvent extends CircuitEvent {} 