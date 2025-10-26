// ===== GAME TYPE MODEL =====
// File: lib/data/models/game/game_type_model.dart

import '../../../domain/entities/game/game_type.dart';

class GameTypeModel extends GameType {
  const GameTypeModel({
    required super.id,
    required super.checksum,
    required super.type,
    super.createdAt,
    super.updatedAt,
  });

  factory GameTypeModel.fromJson(Map<String, dynamic> json) {
    return GameTypeModel(
      id: json['id'] ?? 0,
      checksum: json['checksum'] ?? '',
      type: json['type'] ?? '',
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
        'type': type,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
      };
}
