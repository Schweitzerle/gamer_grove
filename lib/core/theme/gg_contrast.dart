import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Contrast helpers for colours the app does not control.
///
/// Inside the brand theme every pairing is chosen by hand and asserted in
/// `test/unit/core/theme/gg_contrast_test.dart`. But the Pro theme picker
/// renders FlexColorScheme's palettes, and several of them pair an `onPrimary`
/// with their `primary` at barely 3:1 — readable enough for a large button
/// label, not for the tile captions here. Rather than trust the foreign scheme,
/// pick the foreground that actually reads.
extension GGContrastX on Color {
  /// Relative luminance per WCAG 2.x.
  double get relativeLuminance {
    double channel(double v) =>
        v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4) as double;
    return 0.2126 * channel(r) + 0.7152 * channel(g) + 0.0722 * channel(b);
  }

  /// Contrast ratio against [other], from 1 (identical) to 21 (black on white).
  double contrastAgainst(Color other) {
    final a = relativeLuminance;
    final b = other.relativeLuminance;
    return (math.max(a, b) + 0.05) / (math.min(a, b) + 0.05);
  }

  /// A foreground that clears [minimum] against this colour.
  ///
  /// Keeps [preferred] when it already passes, so a scheme's intended
  /// foreground survives wherever it is good enough, and only falls back to
  /// plain black or white when it is not.
  Color readableForeground(Color preferred, {double minimum = 4.5}) {
    if (contrastAgainst(preferred) >= minimum) return preferred;
    return contrastAgainst(Colors.white) >= contrastAgainst(Colors.black)
        ? Colors.white
        : Colors.black;
  }
}
