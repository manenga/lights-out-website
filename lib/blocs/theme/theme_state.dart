import 'package:equatable/equatable.dart';

abstract class ThemeState extends Equatable {
  final bool isDarkMode;
  const ThemeState({required this.isDarkMode});

  @override
  List<Object> get props => [isDarkMode];
}

class ThemeInitial extends ThemeState {
  const ThemeInitial({required super.isDarkMode});
}