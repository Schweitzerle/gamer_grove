import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamer_grove/core/theme/gg_color_schemes.dart';

/// Contrast is a property of the palette, not of any one screen, so it is
/// checked here once rather than hoped for in every widget test.
///
/// WCAG 2.2 AA: 4.5:1 for body text, 3:1 for large text, non-text UI components
/// and meaningful graphics. Flutter's own `textContrastGuideline` only sees what
/// a given test renders; this covers every pairing the design actually uses,
/// including ones no test happens to show yet.
void main() {
  double relativeLuminance(Color c) {
    double channel(double v) =>
        v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4) as double;
    return 0.2126 * channel(c.r) +
        0.7152 * channel(c.g) +
        0.0722 * channel(c.b);
  }

  double ratio(Color a, Color b) {
    final la = relativeLuminance(a);
    final lb = relativeLuminance(b);
    final hi = math.max(la, lb);
    final lo = math.min(la, lb);
    return (hi + 0.05) / (lo + 0.05);
  }

  void expectContrast(
    String what,
    Color foreground,
    Color background,
    double minimum,
  ) {
    final actual = ratio(foreground, background);
    expect(
      actual,
      greaterThanOrEqualTo(minimum),
      reason: '$what: ${actual.toStringAsFixed(2)}:1, needs $minimum:1',
    );
  }

  void checkScheme(String name, ColorScheme s) {
    group(name, () {
      test('text on every surface it can land on', () {
        expectContrast('body on surface', s.onSurface, s.surface, 4.5);
        expectContrast(
          'body on container',
          s.onSurface,
          s.surfaceContainer,
          4.5,
        );
        expectContrast(
          'body on high container',
          s.onSurface,
          s.surfaceContainerHigh,
          4.5,
        );
        expectContrast(
          'secondary text on surface',
          s.onSurfaceVariant,
          s.surface,
          4.5,
        );
        expectContrast(
          'secondary text on container',
          s.onSurfaceVariant,
          s.surfaceContainer,
          4.5,
        );
      });

      test('accent colours as text and as fill', () {
        expectContrast('brand as text', s.primary, s.surface, 4.5);
        expectContrast('text on brand fill', s.onPrimary, s.primary, 4.5);
        expectContrast(
          'text on brand container',
          s.onPrimaryContainer,
          s.primaryContainer,
          4.5,
        );
        expectContrast('error as text', s.error, s.surface, 4.5);
        expectContrast('text on error fill', s.onError, s.error, 4.5);
        expectContrast(
          'text on error container',
          s.onErrorContainer,
          s.errorContainer,
          4.5,
        );
        expectContrast(
          'text on inverse',
          s.onInverseSurface,
          s.inverseSurface,
          4.5,
        );
      });

      test('non-text UI clears the 3:1 bar', () {
        // `outline` bounds interactive components and owes 3:1. `outlineVariant`
        // is a decorative divider and is deliberately exempt — collapsing the
        // two into one token is what put the first draft of this palette below
        // the bar.
        expectContrast('interactive outline', s.outline, s.surface, 3);
        expectContrast(
          'interactive outline on container',
          s.outline,
          s.surfaceContainer,
          3,
        );
        expectContrast('brand as fill', s.primary, s.surface, 3);
      });
    });
  }

  checkScheme('dark scheme', GGColorSchemes.dark);
  checkScheme('light scheme', GGColorSchemes.light);

  test('the two schemes are distinct, not one inverted', () {
    // Brand gold scores 1.9:1 on a light ground, so daylight needs its own
    // darker primary. If these ever match, someone inverted instead of
    // designing the second theme.
    expect(GGColorSchemes.light.primary, isNot(GGColorSchemes.dark.primary));
  });
}
