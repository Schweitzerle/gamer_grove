import 'package:gamer_grove/model/igdb_models/game_version_feature.dart';

import 'game.dart';

class GameVersion {
  int id;
  String? checksum;
  int? createdAt;
  List<GameVersionFeature>? features;
  Game? game;
  List<Game>? games;
  int? updatedAt;
  String? url;

  GameVersion({
    required this.id,
    required this.checksum,
    this.createdAt,
    this.features,
    this.game,
    this.games,
    this.updatedAt,
    this.url,
  });

  factory GameVersion.fromJson(Map<String, dynamic> json) {
    return GameVersion(
      checksum: json['checksum'],
      createdAt: json['created_at'],
      features: json['features'] != null
          ? List<GameVersionFeature>.from(
        json['features'].map((feature) {
          if (feature is int) {
            return GameVersionFeature(id: feature);
          } else {
            return GameVersionFeature.fromJson(feature);
          }
        }),
      )
          : null,
      game: json['game'] != null
          ? (json['game'] is int
          ? Game(id: json['game'])
          : Game.fromJson(json['game']))
          : null,
      games: json['games'] != null
          ? List<Game>.from(
        json['games'].map((games) {
          if (games is int) {
            return Game(id: games);
          } else {
            return Game.fromJson(games);
          }
        }),
      )
          : null,
      updatedAt: json['updated_at'],
      url: json['url'], id: json['id'],
    );
  }
}
