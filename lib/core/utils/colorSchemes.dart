import 'dart:ui';

import 'package:flutter/material.dart';

class ColorScales {
  static Color getRankingColor(int index) {
    switch (index) {
      case 0: return Colors.amber; // Gold für Platz 1
      case 1: return Colors.grey[400]!; // Silber für Platz 2
      case 2: return Colors.brown[400]!; // Bronze für Platz 3
      default: return Colors.black;
    }
  }

  static Color getRatingColor(double rating) {
    if (rating >= 90.0) return const Color(0xFF5b041d); // Iridescent (orchid/lila)
    if (rating >= 80.0) return const Color(0xFFd98b0b); // Gold
    if (rating >= 60.0) return const Color(0xFF6a6f75); // Silver
    if (rating >= 40.0) return const Color(0xFF7c3614); // Bronze
    return const Color(0xFF51483a); // Ash (dunkelgrau)
  }
}