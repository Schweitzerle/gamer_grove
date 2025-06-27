// lib/data/models/game_release_format_model.dart

import '../../../domain/entities/game/game_release_format.dart';

class GameReleaseFormatModel extends GameReleaseFormat {
  const GameReleaseFormatModel({
    required super.id,
    required super.checksum,
    required super.format,
    super.createdAt,
    super.updatedAt,
  });

  factory GameReleaseFormatModel.fromJson(Map<String, dynamic> json) {
    return GameReleaseFormatModel(
      id: json['id'] ?? 0,
      checksum: json['checksum'] ?? '',
      format: json['format'] ?? '',
      createdAt: _parseDateTime(json['created_at']),
      updatedAt: _parseDateTime(json['updated_at']),
    );
  }

  static DateTime? _parseDateTime(dynamic date) {
    if (date is String) {
      return DateTime.tryParse(date);
    } else if (date is int) {
      return DateTime.fromMillisecondsSinceEpoch(date * 1000);
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'checksum': checksum,
      'format': format,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}