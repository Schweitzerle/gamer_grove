// ==================================================
// ERWEITERTE UTILITY FUNCTIONS
// ==================================================

// lib/core/utils/game_utils.dart
import 'package:flutter/material.dart';

import '../../domain/entities/game.dart';

class GameUtils {
  static String getGameStatusDisplayName(String? status) {
    if (status == null) return 'Unknown';

    switch (status.toLowerCase()) {
      case 'released':
        return 'Released';
      case 'alpha':
        return 'Alpha';
      case 'beta':
        return 'Beta';
      case 'early_access':
        return 'Early Access';
      case 'offline':
        return 'Offline';
      case 'cancelled':
        return 'Cancelled';
      case 'rumoured':
        return 'Rumoured';
      case 'delisted':
        return 'Delisted';
      default:
        return 'Unknown';
    }
  }

  static Color getStatusColor(String? status) {
    if (status == null) return Colors.grey;

    switch (status.toLowerCase()) {
      case 'released':
        return Colors.green;
      case 'alpha':
        return Colors.orange;
      case 'beta':
        return Colors.blue;
      case 'early_access':
        return Colors.amber;
      case 'offline':
        return Colors.red;
      case 'cancelled':
        return Colors.red;
      case 'rumoured':
        return Colors.purple;
      case 'delisted':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  static String formatGameDuration(int? minutes) {
    if (minutes == null || minutes == 0) return 'Unknown';

    if (minutes < 60) {
      return '${minutes}m';
    } else if (minutes < 1440) { // Less than 24 hours
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      if (remainingMinutes == 0) {
        return '${hours}h';
      } else {
        return '${hours}h ${remainingMinutes}m';
      }
    } else {
      final days = minutes ~/ 1440;
      final remainingHours = (minutes % 1440) ~/ 60;
      if (remainingHours == 0) {
        return '${days}d';
      } else {
        return '${days}d ${remainingHours}h';
      }
    }
  }

  static String getMultiplayerModeDisplayName(String mode) {
    switch (mode.toLowerCase()) {
      case 'single_player':
        return 'Single Player';
      case 'multiplayer':
        return 'Multiplayer';
      case 'cooperative':
        return 'Cooperative';
      case 'split_screen':
        return 'Split Screen';
      case 'online':
        return 'Online';
      case 'local':
        return 'Local';
      default:
        return mode;
    }
  }

  static String getPlatformDisplayName(String platform) {
    switch (platform.toLowerCase()) {
      case 'pc':
      case 'win':
        return 'PC (Windows)';
      case 'mac':
        return 'macOS';
      case 'linux':
        return 'Linux';
      case 'ps5':
        return 'PlayStation 5';
      case 'ps4':
        return 'PlayStation 4';
      case 'xbox_series_x':
        return 'Xbox Series X/S';
      case 'xbox_one':
        return 'Xbox One';
      case 'nintendo_switch':
        return 'Nintendo Switch';
      case 'android':
        return 'Android';
      case 'ios':
        return 'iOS';
      default:
        return platform;
    }
  }

  static List<String> getGameHighlights(Game game) {
    final highlights = <String>[];

    // Add rating highlight
    if (game.rating != null && game.rating! >= 80) {
      highlights.add('Highly Rated (${game.rating!.toStringAsFixed(0)}/100)');
    }

    // Add popularity highlight
    if (game.follows != null && game.follows! > 10000) {
      highlights.add('Popular (${_formatNumber(game.follows!)} followers)');
    }

    // Add hype highlight
    if (game.hypes != null && game.hypes! > 100) {
      highlights.add('Hyped (${game.hypes} hype points)');
    }

    // Add multiplayer highlight
    if (game.hasMultiplayer) {
      if (game.hasOnlineMultiplayer && game.hasLocalMultiplayer) {
        highlights.add('Online & Local Multiplayer');
      } else if (game.hasOnlineMultiplayer) {
        highlights.add('Online Multiplayer');
      } else if (game.hasLocalMultiplayer) {
        highlights.add('Local Multiplayer');
      }
    }

    // Add platform highlights
    if (game.platforms.length >= 5) {
      highlights.add('Multi-Platform (${game.platforms.length} platforms)');
    }

    return highlights;
  }

  static String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}




