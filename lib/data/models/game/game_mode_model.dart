// lib/data/models/game_mode_model.dart
import '../../../domain/entities/game/game_mode.dart';

class GameModeModel extends GameMode {
  const GameModeModel({
    required super.id,
    required super.checksum,
    required super.name,
    super.slug,
    super.url,
    super.createdAt,
    super.updatedAt,
  });

  factory GameModeModel.fromJson(Map<String, dynamic> json) {
    return GameModeModel(
      id: json['id'] ?? 0,
      checksum: json['checksum'] ?? '',
      name: json['name'] ?? '',
      slug: json['slug'],
      url: json['url'],
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
      'name': name,
      'slug': slug,
      'url': url,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}