import 'package:flutter/material.dart';

/// Colours for everything painted **on top of cover artwork**.
///
/// These deliberately do not come from the colour scheme. The backdrop here is
/// the artwork, not an app surface, so a title has to be light on a dark scrim
/// in both themes — swapping in `onSurface` would put dark text on a dark cover
/// the moment the light theme is on.
abstract final class CardScrim {
  static const Color ink = Colors.black;
  static const Color paper = Colors.white;

  /// The drop shadow that keeps small type readable over a busy cover.
  static List<Shadow> get textShadow => [
        Shadow(
          offset: const Offset(0, 1),
          blurRadius: 2,
          color: ink.withValues(alpha: 0.7),
        ),
      ];
}
