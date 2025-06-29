// ===== GAME TIME TO BEAT MODEL =====
// File: lib/data/models/game/game_time_to_beat_model.dart

import '../../../domain/entities/game/game_time_to_beat.dart';

class GameTimeToBeatModel extends GameTimeToBeat {
  const GameTimeToBeatModel({
    required super.id,
    required super.checksum,
    super.gameId,
    super.hastily,
    super.normally,
    super.completely,
    super.createdAt,
    super.updatedAt,
  });

  factory GameTimeToBeatModel.fromJson(Map<String, dynamic> json) {
    return GameTimeToBeatModel(
      id: json['id'] ?? 0,
      checksum: json['checksum'] ?? '',
      gameId: json['game'],
      hastily: json['hastily'],
      normally: json['normally'],
      completely: json['completely'],
      createdAt: _parseDateTime(json['created_at']),
      updatedAt: _parseDateTime(json['updated_at']),
    );
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
    'hastily': hastily,
    'normally': normally,
    'completely': completely,
    'created_at': createdAt?.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
  };
}
