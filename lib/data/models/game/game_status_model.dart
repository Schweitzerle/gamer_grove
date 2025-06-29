// ===== GAME STATUS MODEL =====
// File: lib/data/models/game/game_status_model.dart

import '../../../domain/entities/game/game_status.dart';

class GameStatusModel extends GameStatus {
  const GameStatusModel({
    required super.id,
    required super.checksum,
    required super.name,
    super.description,
    super.createdAt,
    super.updatedAt,
  });

  factory GameStatusModel.fromJson(Map<String, dynamic> json) {
    return GameStatusModel(
      id: json['id'] ?? 0,
      checksum: json['checksum'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
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
    'name': name,
    'description': description,
    'created_at': createdAt?.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
  };

  factory GameStatusModel.fromEnum(GameStatusEnum statusEnum) {
    return GameStatusModel(
      id: statusEnum.value,
      checksum: '',
      name: statusEnum.name,
    );
  }
}




