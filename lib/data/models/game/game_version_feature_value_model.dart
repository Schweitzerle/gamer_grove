// ===== GAME VERSION FEATURE VALUE MODEL =====
// File: lib/data/models/game/game_version_feature_value_model.dart

import 'package:gamer_grove/domain/entities/game/game_version_feature_value.dart';

class GameVersionFeatureValueModel extends GameVersionFeatureValue {
  const GameVersionFeatureValueModel({
    required super.id,
    required super.checksum,
    super.gameId,
    super.gameFeatureId,
    super.includedFeature,
    super.note,
  });

  factory GameVersionFeatureValueModel.fromJson(Map<String, dynamic> json) {
    return GameVersionFeatureValueModel(
      id: json['id'] ?? 0,
      checksum: json['checksum'] ?? '',
      gameId: json['game'],
      gameFeatureId: json['game_feature'],
      includedFeature: json['included_feature'],
      note: json['note'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'checksum': checksum,
    'game': gameId,
    'game_feature': gameFeatureId,
    'included_feature': includedFeature,
    'note': note,
  };
}