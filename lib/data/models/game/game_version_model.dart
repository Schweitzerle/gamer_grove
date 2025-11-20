// ===== GAME VERSION MODEL =====
// File: lib/data/models/game/game_version_model.dart

import 'package:gamer_grove/domain/entities/game/game_version.dart';

class GameVersionModel extends GameVersion {
  const GameVersionModel({
    required super.id,
    required super.checksum,
    super.gameId,
    super.featureIds,
    super.gameIds,
    super.url,
    super.createdAt,
    super.updatedAt,
  });

  factory GameVersionModel.fromJson(Map<String, dynamic> json) {
    return GameVersionModel(
      id: json['id'] ?? 0,
      checksum: json['checksum'] ?? '',
      gameId: json['game'],
      featureIds: _parseIdList(json['features']),
      gameIds: _parseIdList(json['games']),
      url: json['url'],
      createdAt: _parseDateTime(json['created_at']),
      updatedAt: _parseDateTime(json['updated_at']),
    );
  }

  static List<int> _parseIdList(dynamic data) {
    if (data is List) {
      return data
          .where((item) => item is int || (item is Map && item['id'] is int))
          .map((item) => item is int ? item : item['id'] as int)
          .toList();
    }
    return [];
  }

  static DateTime? _parseDateTime(dynamic date) {
    if (date is String) return DateTime.tryParse(date);
    if (date is int) return DateTime.fromMillisecondsSinceEpoch(date * 1000);
    return null;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'checksum': checksum,
    'game': gameId,
    'features': featureIds,
    'games': gameIds,
    'url': url,
    'created_at': createdAt?.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
  };
}

