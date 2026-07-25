import 'package:flutter/material.dart';

/// GamerGrove's type system: two families, a fixed scale, no ad-hoc sizes.
///
/// Bricolage Grotesque carries the headings — a grotesque with deliberately
/// uneven strokes, so it reads as *made* rather than smoothed out, which is the
/// same claim the pixel icon makes. IBM Plex Sans does the reading, and brings
/// real tabular figures, which is what keeps ratings and counters from
/// jittering between rows.
///
/// Both are bundled with the app rather than fetched at runtime. That is partly
/// speed, but mostly law: pulling fonts from a CDN would add a recipient to the
/// privacy policy.
abstract final class GGTypography {
  static const display = 'BricolageGrotesque';
  static const text = 'IBMPlexSans';

  /// Numbers that sit in columns — ratings, counts, stats — need fixed-width
  /// digits, or every row shifts as the values change.
  static const tabularFigures = <FontFeature>[FontFeature.tabularFigures()];

  static TextTheme textTheme(Color onSurface, Color onSurfaceVariant) {
    TextStyle heading(double size, double height, double tracking) => TextStyle(
          fontFamily: display,
          fontSize: size,
          height: height,
          letterSpacing: tracking,
          fontWeight: FontWeight.w700,
          color: onSurface,
        );

    TextStyle body(
      double size,
      double height,
      FontWeight weight, {
      double tracking = 0,
      Color? color,
    }) =>
        TextStyle(
          fontFamily: text,
          fontSize: size,
          height: height,
          letterSpacing: tracking,
          fontWeight: weight,
          color: color ?? onSurface,
        );

    return TextTheme(
      // Display and headline are the brand's voice: tight, large, negative
      // tracking so the size contrast against body text is unmistakable.
      displayLarge: heading(44, 1.05, -1),
      displayMedium: heading(36, 1.08, -0.8),
      displaySmall: heading(30, 1.1, -0.6),
      headlineLarge: heading(26, 1.15, -0.4),
      headlineMedium: heading(22, 1.2, -0.3),
      headlineSmall: heading(20, 1.2, -0.2),
      titleLarge: body(18, 1.3, FontWeight.w600),
      titleMedium: body(16, 1.4, FontWeight.w600, tracking: 0.1),
      titleSmall: body(14, 1.4, FontWeight.w600, tracking: 0.1),
      // 16 is the floor for anything the user actually reads.
      bodyLarge: body(16, 1.5, FontWeight.w400),
      bodyMedium: body(14, 1.5, FontWeight.w400),
      bodySmall: body(12, 1.45, FontWeight.w400, color: onSurfaceVariant),
      labelLarge: body(14, 1.3, FontWeight.w600, tracking: 0.3),
      labelMedium: body(12, 1.3, FontWeight.w600, tracking: 0.4),
      labelSmall: body(11, 1.3, FontWeight.w600, tracking: 0.5),
    );
  }
}

extension GGTextStyleX on TextStyle {
  /// Fixed-width digits, for values that line up across rows.
  TextStyle get tabular => copyWith(fontFeatures: GGTypography.tabularFigures);
}
