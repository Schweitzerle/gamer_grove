// lib/data/models/game_engine_model.dart
import '../../../domain/entities/game/game_engine.dart';

class GameEngineModel extends GameEngine {
  const GameEngineModel({
    required super.id,
    required super.checksum,
    required super.name,
    super.description,
    super.logoId,
    super.slug,
    super.url,
    super.companyIds = const [],
    super.platformIds = const [],
    super.createdAt,
    super.updatedAt,
  });

  factory GameEngineModel.fromJson(Map<String, dynamic> json) {
    return GameEngineModel(
      id: json['id'] ?? 0,
      checksum: json['checksum'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      logoId: json['logo'],
      slug: json['slug'],
      url: json['url'],
      companyIds: _parseIdList(json['companies']),
      platformIds: _parseIdList(json['platforms']),
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
      'description': description,
      'logo': logoId,
      'slug': slug,
      'url': url,
      'companies': companyIds,
      'platforms': platformIds,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}