import 'package:gamer_grove/model/igdb_models/game_version_feature.dart';

import '../../repository/igdb/IGDBApiService.dart';
import '../firebase/firebaseUser.dart';
import '../firebase/gameModel.dart';
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
          ? Game(id: json['game'], gameModel: GameModel(id: '0', wishlist: false, recommended: false, rating: 0))
          : Game.fromJson(json['game'], IGDBApiService.getGameModel(json['game']['id'])))
          : null,
      games: json['games'] != null
          ? List<Game>.from(
        json['games'].map((dlc) {
          if (dlc is int) {
            return Game(id: dlc, gameModel: GameModel(id: '0', wishlist: false, recommended: false, rating: 0));
          } else {
            return Game.fromJson(dlc, IGDBApiService.getGameModel(dlc['id']));
          }
        }),
      )
          : null,
      updatedAt: json['updated_at'],
      url: json['url'], id: json['id'],
    );
  }
}
