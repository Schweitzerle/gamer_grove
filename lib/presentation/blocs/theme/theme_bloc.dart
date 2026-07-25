import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamer_grove/presentation/blocs/theme/theme_event.dart';
import 'package:gamer_grove/presentation/blocs/theme/theme_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(ThemeState.initial()) {
    on<ThemeLoadStarted>((event, emit) async {
      final prefs = await SharedPreferences.getInstance();
      final themeModeIndex = prefs.getInt('themeMode') ?? ThemeMode.dark.index;
      final themeMode = ThemeMode.values[themeModeIndex];

      emit(
        ThemeState(
          themeMode: themeMode,
          flexScheme: _decodeScheme(prefs.getInt(_schemeKey)),
        ),
      );
    });

    on<ThemeModeChanged>((event, emit) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('themeMode', event.themeMode.index);
      emit(state.copyWith(themeMode: event.themeMode));
    });

    on<ThemeSchemeChanged>((event, emit) async {
      final prefs = await SharedPreferences.getInstance();
      final scheme = event.flexScheme;
      await prefs.setInt(_schemeKey, scheme?.index ?? _brandThemeMarker);
      emit(
        state.copyWith(
          flexScheme: scheme,
          resetToBrandTheme: scheme == null,
        ),
      );
    });
  }

  static const _schemeKey = 'flexScheme';

  /// The brand theme is not a `FlexScheme`, so it needs a stored value of its
  /// own. Users who deliberately picked a scheme keep it; everyone else — no
  /// stored value, or a value this build no longer knows — lands on the brand
  /// theme rather than on Material's stock purple.
  static const _brandThemeMarker = -1;

  static FlexScheme? _decodeScheme(int? stored) {
    if (stored == null || stored < 0 || stored >= FlexScheme.values.length) {
      return null;
    }
    return FlexScheme.values[stored];
  }
}
