import 'package:equatable/equatable.dart';
import '../../models/race.dart';

abstract class RaceState extends Equatable {
  const RaceState();

  @override
  List<Object> get props => [];
}

class RaceInitial extends RaceState {}

class RaceLoading extends RaceState {}

class RaceLoaded extends RaceState {
  final List<Race> races;
  const RaceLoaded(this.races);

  @override
  List<Object> get props => [races];
}

class RaceError extends RaceState {
  final String message;
  const RaceError(this.message);

  @override
  List<Object> get props => [message];
}