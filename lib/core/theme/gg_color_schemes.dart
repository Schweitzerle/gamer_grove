import 'package:flutter/material.dart';

/// GamerGrove's brand colour schemes, derived from the app icon.
///
/// The story sets the palette: the app is dark because the dark **is the room**
/// — the gamer's cave — and gold is the light you head towards. Cover art is
/// the loudest thing on any screen, so the interface keeps to one warm accent
/// and stays out of its way.
///
/// The light scheme is not an inversion. Brand gold `#F2A63C` scores 1.9:1 on a
/// light ground and fails WCAG outright, so daylight gets its own darker gold.
/// Contrast for every pairing the UI actually uses is asserted in
/// `test/unit/core/theme/gg_contrast_test.dart`.
abstract final class GGColorSchemes {
  static const dark = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFFF2A63C),
    onPrimary: Color(0xFF2A1A0A),
    primaryContainer: Color(0xFF4A3418),
    onPrimaryContainer: Color(0xFFFFD68F),
    secondary: Color(0xFF8FB3A6),
    onSecondary: Color(0xFF10241E),
    secondaryContainer: Color(0xFF24443C),
    onSecondaryContainer: Color(0xFFC7E3D8),
    tertiary: Color(0xFF9FB8C9),
    onTertiary: Color(0xFF0E212B),
    tertiaryContainer: Color(0xFF2C4552),
    onTertiaryContainer: Color(0xFFCFE3EE),
    error: Color(0xFFFF8A72),
    onError: Color(0xFF3A0F06),
    errorContainer: Color(0xFF6B2415),
    onErrorContainer: Color(0xFFFFD9CF),
    surface: Color(0xFF0B1614),
    onSurface: Color(0xFFE8E5DC),
    surfaceContainerLowest: Color(0xFF060F0D),
    surfaceContainerLow: Color(0xFF0E1A17),
    surfaceContainer: Color(0xFF12211D),
    surfaceContainerHigh: Color(0xFF182C26),
    surfaceContainerHighest: Color(0xFF1E352E),
    onSurfaceVariant: Color(0xFF9EACA6),
    // Two outline roles on purpose: `outline` bounds interactive components and
    // owes 3:1, `outlineVariant` is a decorative divider and is exempt. Using
    // one token for both is what put the first draft under the bar.
    outline: Color(0xFF7A8C86),
    outlineVariant: Color(0xFF334741),
    inverseSurface: Color(0xFFE8E5DC),
    onInverseSurface: Color(0xFF12211D),
    inversePrimary: Color(0xFF8A5410),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
  );

  static const light = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF8A5410),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFFFD68F),
    onPrimaryContainer: Color(0xFF3A2408),
    secondary: Color(0xFF3A5F54),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFC7E3D8),
    onSecondaryContainer: Color(0xFF12312A),
    tertiary: Color(0xFF3D5A6B),
    onTertiary: Color(0xFFFFFFFF),
    tertiaryContainer: Color(0xFFCFE3EE),
    onTertiaryContainer: Color(0xFF12303D),
    error: Color(0xFF9B2C1A),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFFD9CF),
    onErrorContainer: Color(0xFF3A0F06),
    surface: Color(0xFFFAF7F0),
    onSurface: Color(0xFF16211E),
    surfaceContainerLowest: Color(0xFFFFFFFF),
    surfaceContainerLow: Color(0xFFF6F1E7),
    surfaceContainer: Color(0xFFF0EADD),
    surfaceContainerHigh: Color(0xFFE7E0D0),
    surfaceContainerHighest: Color(0xFFDFD7C5),
    onSurfaceVariant: Color(0xFF4E5A55),
    outline: Color(0xFF7C766A),
    outlineVariant: Color(0xFFCFC7B7),
    inverseSurface: Color(0xFF16211E),
    onInverseSurface: Color(0xFFF0EADD),
    inversePrimary: Color(0xFFFFD68F),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
  );
}
