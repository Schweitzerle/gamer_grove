// lib/data/models/multiplayer_mode_model.dart
import 'package:gamer_grove/domain/entities/multiplayer_mode.dart';

class MultiplayerModeModel extends MultiplayerMode {
  const MultiplayerModeModel({
    required super.id,
    super.campaignCoop,
    super.dropin,
    super.lancoop,
    super.offlineCoop,
    super.offlineCoopMax,
    super.offlineMax,
    super.onlineCoop,
    super.onlineCoopMax,
    super.onlineMax,
    super.splitscreen,
    super.splitscreenOnline,
  });

  factory MultiplayerModeModel.fromJson(Map<String, dynamic> json) {
    try {
      return MultiplayerModeModel(
        id: _parseInt(json['id']) ?? 0,
        // Boolean fields - parse safely
        campaignCoop: _parseBool(json['campaigncoop']),
        dropin: _parseBool(json['dropin']),
        lancoop: _parseBool(json['lancoop']),
        offlineCoop: _parseBool(json['offlinecoop']),
        onlineCoop: _parseBool(json['onlinecoop']),
        splitscreen: _parseBool(json['splitscreen']),
        splitscreenOnline: _parseBool(json['splitscreenonline']),

        // FIX: Integer fields - parse as int, not bool
        offlineCoopMax: _parseInt(json['offlinecoopmax']) ?? 0,
        offlineMax: _parseInt(json['offlinemax']) ?? 0,
        onlineCoopMax: _parseInt(json['onlinecoopmax']) ?? 0,
        onlineMax: _parseInt(json['onlinemax']) ?? 0,
      );
    } catch (e) {
      rethrow;
    }
  }

  // === SAFE PARSING HELPERS ===
  static int? _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    if (value is bool) return value ? 1 : 0; // Handle bool -> int conversion
    return null;
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is int) return value != 0;
    if (value is String) return value.toLowerCase() == 'true' || value == '1';
    return false;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'campaigncoop': campaignCoop,
      'dropin': dropin,
      'lancoop': lancoop,
      'offlinecoop': offlineCoop,
      'offlinecoopmax': offlineCoopMax,
      'offlinemax': offlineMax,
      'onlinecoop': onlineCoop,
      'onlinecoopmax': onlineCoopMax,
      'onlinemax': onlineMax,
      'splitscreen': splitscreen,
      'splitscreenonline': splitscreenOnline,
    };
  }
}
