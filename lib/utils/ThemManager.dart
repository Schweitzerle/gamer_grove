import 'dart:async';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'FlexThemeX.dart';

class ThemeManager {
  final FlexScheme? scheme;
  final String _themeKey = 'selected_theme';

  ThemeManager({this.scheme});

  final _themeChangeController = StreamController<void>.broadcast();

  void setTheme(BuildContext context) {
    AdaptiveTheme.of(context).setTheme(
      light: FlexThemeData.light(
        scheme: scheme,
        surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
        subThemesData: const FlexSubThemesData(
          blendOnLevel: 10,
          blendOnColors: false,
          useTextTheme: true,
          useM2StyleDividerInM3: true,
          alignedDropdown: true,
          useInputDecoratorThemeInDialogs: true,
        ),
        visualDensity: FlexColorScheme.comfortablePlatformDensity,
        useMaterial3: true,
        swapLegacyOnMaterial3: true,
      ),
      dark: FlexThemeData.dark(
        scheme: scheme,
        surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
        subThemesData: const FlexSubThemesData(
          blendOnLevel: 20,
          useTextTheme: true,
          useM2StyleDividerInM3: true,
          alignedDropdown: true,
          useInputDecoratorThemeInDialogs: true,
        ),
        visualDensity: FlexColorScheme.comfortablePlatformDensity,
        useMaterial3: true,
        swapLegacyOnMaterial3: true,
        // To use the Playground font, add GoogleFonts package and uncomment
        // fontFamily: GoogleFonts.notoSans().fontFamily,
      ),
    );
    saveThemeToPrefs(scheme!);
  }

  void saveThemeToPrefs(FlexScheme scheme) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_themeKey, scheme.toString());
    notifyThemeChange();
  }

  Future<FlexScheme> loadThemeFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final savedScheme = prefs.getString(_themeKey);
    return savedScheme != null ? FlexSchemeX.schemeFromName(savedScheme) : FlexScheme.redWine;
  }

  void notifyThemeChange() {
    _themeChangeController.add(null);
    print('Theme changed');
  }

  Stream<void> get onThemeChanged => _themeChangeController.stream;
}
