import 'package:equatable/equatable.dart';

abstract class RaceEvent extends Equatable {
  const RaceEvent();

  @override
  List<Object> get props => [];
}

class LoadRacesEvent extends RaceEvent {}

class ToggleFavoriteEvent extends RaceEvent {
  final int index;
  const ToggleFavoriteEvent(this.index);

  @override
  List<Object> get props => [index];
}
