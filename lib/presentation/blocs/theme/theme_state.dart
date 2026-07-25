import 'package:equatable/equatable.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';

class ThemeState extends Equatable {
  const ThemeState({
    required this.themeMode,
    required this.flexScheme,
  });

  /// Dark by default, and on the brand theme rather than a FlexColorScheme.
  /// The default used to be `FlexScheme.material`, so every screen inherited
  /// Material's stock purple instead of GamerGrove's own colour.
  factory ThemeState.initial() => const ThemeState(
        themeMode: ThemeMode.dark,
        flexScheme: null,
      );

  final ThemeMode themeMode;

  /// `null` means the GamerGrove brand theme. A value means the user picked one
  /// of FlexColorScheme's schemes in the Pro theme picker.
  final FlexScheme? flexScheme;

  bool get usesBrandTheme => flexScheme == null;

  ThemeState copyWith({
    ThemeMode? themeMode,
    FlexScheme? flexScheme,
    bool resetToBrandTheme = false,
  }) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      flexScheme: resetToBrandTheme ? null : (flexScheme ?? this.flexScheme),
    );
  }

  @override
  List<Object?> get props => [themeMode, flexScheme];
}
