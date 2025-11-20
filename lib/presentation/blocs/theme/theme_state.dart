
import 'package:equatable/equatable.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';

class ThemeState extends Equatable {

  const ThemeState({
    required this.themeMode,
    required this.flexScheme,
  });

  factory ThemeState.initial() => const ThemeState(
        themeMode: ThemeMode.dark,
        flexScheme: FlexScheme.material,
      );
  final ThemeMode themeMode;
  final FlexScheme flexScheme;

  ThemeState copyWith({
    ThemeMode? themeMode,
    FlexScheme? flexScheme,
  }) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      flexScheme: flexScheme ?? this.flexScheme,
    );
  }

  @override
  List<Object?> get props => [themeMode, flexScheme];
}
