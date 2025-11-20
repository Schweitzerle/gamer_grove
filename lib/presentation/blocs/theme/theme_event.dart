
import 'package:equatable/equatable.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';

abstract class ThemeEvent extends Equatable {
  const ThemeEvent();

  @override
  List<Object> get props => [];
}

class ThemeModeChanged extends ThemeEvent {

  const ThemeModeChanged(this.themeMode);
  final ThemeMode themeMode;

  @override
  List<Object> get props => [themeMode];
}

class ThemeSchemeChanged extends ThemeEvent {

  const ThemeSchemeChanged(this.flexScheme);
  final FlexScheme flexScheme;

  @override
  List<Object> get props => [flexScheme];
}

class ThemeLoadStarted extends ThemeEvent {
  const ThemeLoadStarted();
}
