// ===== GAME VERSION FEATURE MODEL =====
// File: lib/data/models/game/game_version_feature_model.dart

import 'package:gamer_grove/domain/entities/game/game_version_feature.dart';

class GameVersionFeatureModel extends GameVersionFeature {
  const GameVersionFeatureModel({
    required super.id,
    required super.checksum,
    required super.title,
    super.description,
    super.category,
    super.position,
    super.valueIds,
  });

  factory GameVersionFeatureModel.fromJson(Map<String, dynamic> json) {
    return GameVersionFeatureModel(
      id: json['id'] ?? 0,
      checksum: json['checksum'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      category: json['category'],
      position: json['position'],
      valueIds: _parseIdList(json['values']),
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

  Map<String, dynamic> toJson() => {
    'id': id,
    'checksum': checksum,
    'title': title,
    'description': description,
    'category': category,
    'position': position,
    'values': valueIds,
  };
}

