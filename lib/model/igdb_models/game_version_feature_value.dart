import 'package:gamer_grove/model/igdb_models/game.dart';
import 'package:gamer_grove/model/igdb_models/game_version_feature.dart';

class GameVersionFeatureValue {
  int id;
  final String? checksum;
  final Game? game;
  final GameVersionFeature? gameFeature;
  final IncludedFeatureEnum? includedFeature;
  final String? note;

  GameVersionFeatureValue({
    required this.id,
    this.checksum,
    this.game,
    this.gameFeature,
    this.includedFeature,
    this.note,
  });

  factory GameVersionFeatureValue.fromJson(Map<String, dynamic> json) {
    return GameVersionFeatureValue(
      checksum: json['checksum'],
      game: json['game'] != null
          ? (json['game'] is int
          ? Game(id: json['game'])
          : Game.fromJson(json['game']))
          : null,
      gameFeature: json['game_feature'] != null
          ? (json['game_feature'] is int
          ? GameVersionFeature(id: json['game_feature'])
          : GameVersionFeature.fromJson(json['game_feature']))
          : null,
      includedFeature: json['included_feature'] != null
          ? IncludedFeatureEnumExtension.fromValue(json['included_feature'])
          : null,
      note: json['note'], id: json['id'],
    );
  }
}

enum IncludedFeatureEnum {
  NotIncluded,
  Included,
  PreOrderOnly,
}

extension IncludedFeatureEnumExtension on IncludedFeatureEnum {
  int get value {
    return this.index;
  }

  static IncludedFeatureEnum fromValue(int value) {
    return IncludedFeatureEnum.values[value];
  }
}
