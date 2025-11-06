
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamer_grove/presentation/blocs/theme/theme_event.dart';
import 'package:gamer_grove/presentation/blocs/theme/theme_state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(ThemeState.initial()) {
    on<ThemeLoadStarted>((event, emit) async {
      final prefs = await SharedPreferences.getInstance();
      final themeModeIndex = prefs.getInt('themeMode') ?? ThemeMode.dark.index;
      final themeMode = ThemeMode.values[themeModeIndex];
      final flexSchemeIndex = prefs.getInt('flexScheme') ?? FlexScheme.material.index;
      final flexScheme = FlexScheme.values[flexSchemeIndex];
      emit(state.copyWith(themeMode: themeMode, flexScheme: flexScheme));
    });

    on<ThemeModeChanged>((event, emit) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('themeMode', event.themeMode.index);
      emit(state.copyWith(themeMode: event.themeMode));
    });

    on<ThemeSchemeChanged>((event, emit) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('flexScheme', event.flexScheme.index);
      emit(state.copyWith(flexScheme: event.flexScheme));
    });
  }
}
