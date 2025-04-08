import 'package:flutter_bloc/flutter_bloc.dart';
import 'theme_event.dart';
import 'theme_state.dart';

class ToggleThemeEvent extends ThemeEvent {}

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(const ThemeInitial(isDarkMode: true)) {
    on<ToggleThemeEvent>((event, emit) {
      emit(ThemeInitial(isDarkMode: !state.isDarkMode));
    });
  }
} 