
import 'package:equatable/equatable.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';

abstract class ThemeEvent extends Equatable {
  const ThemeEvent();

  @override
  List<Object> get props => [];
}

class ThemeModeChanged extends ThemeEvent {
  final ThemeMode themeMode;

  const ThemeModeChanged(this.themeMode);

  @override
  List<Object> get props => [themeMode];
}

class ThemeSchemeChanged extends ThemeEvent {
  final FlexScheme flexScheme;

  const ThemeSchemeChanged(this.flexScheme);

  @override
  List<Object> get props => [flexScheme];
}

class ThemeLoadStarted extends ThemeEvent {
  const ThemeLoadStarted();
}
