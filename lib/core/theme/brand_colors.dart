import 'package:flutter/material.dart';

/// Canonical colours of third-party services.
///
/// These stay hardcoded on purpose. They are other companies' marks, not our
/// design tokens — routing them through the colour scheme would strip the one
/// thing that makes a Steam link recognisable as Steam.
///
/// They are not used raw as a foreground. Several are near-black (Apple, Epic,
/// Oculus) and disappear on our dark surface, so every foreground use goes
/// through `legibleOn`, which keeps the hue and lifts only the lightness. That
/// is why one table serves both themes.
///
/// This replaces three tables that had drifted apart: Steam was `#00adee` as an
/// icon and `#1B2838` as a label in the same card, and Apple was `#000000` in
/// one place and `#007AFF` in another.
abstract final class BrandColors {
  static const _byName = <String, Color>{
    'apple': Color(0xFF000000),
    'amazon': Color(0xFFFF9900),
    'android': Color(0xFF3DDC84),
    'bluesky': Color(0xFF0085FF),
    'discord': Color(0xFF5865F2),
    'epic': Color(0xFF313131),
    'facebook': Color(0xFF1877F2),
    'gamejolt': Color(0xFF2F7D32),
    'gog': Color(0xFF8A2BE2),
    'instagram': Color(0xFFC13584),
    'itch': Color(0xFFFA5C5C),
    'meta': Color(0xFF0668E1),
    'microsoft': Color(0xFF00BCF2),
    'nintendo': Color(0xFFE60012),
    'oculus': Color(0xFF1C1E20),
    'playstation': Color(0xFF0070D1),
    'reddit': Color(0xFFFF4500),
    'steam': Color(0xFF1B2838),
    'twitch': Color(0xFF9146FF),
    'twitter': Color(0xFF1DA1F2),
    'wikipedia': Color(0xFF636466),
    'xbox': Color(0xFF107C10),
    'youtube': Color(0xFFFF0000),
  };

  /// The mark colour for [name], or null when the service is unknown — callers
  /// then fall back to the app's own accent rather than inventing a colour.
  static Color? of(String? name) =>
      name == null ? null : _byName[name.toLowerCase()];

  @visibleForTesting
  static Iterable<String> get names => _byName.keys;
}
