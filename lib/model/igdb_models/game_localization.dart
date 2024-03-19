import 'package:gamer_grove/model/igdb_models/region.dart';

import '../../repository/igdb/IGDBApiService.dart';
import '../firebase/firebaseUser.dart';
import '../firebase/gameModel.dart';
import 'cover.dart';
import 'game.dart';

class GameLocalization {
  int id;
  final String? checksum; // Fixed typo: "hecksum"
  final int? createdAt;
  final Cover? cover;
  final Game? game;
  final String? name;
  final Region? region;
  final int? updatedAt;

  GameLocalization({
    required this.id,
    this.checksum,
    this.createdAt,
    this.cover,
    this.game,
    this.name,
    this.region,
    this.updatedAt,
  });

  factory GameLocalization.fromJson(Map<String, dynamic> json) {
    return GameLocalization(
      checksum: json['checksum'],
      createdAt: json['created_at'],
      cover: json['cover'] != null
          ? (json['cover'] is int
          ? Cover(id: json['cover'])
          : Cover.fromJson(json['cover']))
          : null,

      game: json['game'] != null
          ? (json['game'] is int
          ? Game(id: json['game'], gameModel: GameModel(id: '0', wishlist: false, recommended: false, rating: 0))
          : Game.fromJson(json['game'], IGDBApiService.getGameModel(json['game']['id'])))
          : null,
      name: json['name'],
      region: json['region'] != null
          ? (json['region'] is int
          ? Region(id: json['region'])
          : Region.fromJson(json['region']))
          : null,
      updatedAt: json['updated_at'], id: json['id'],
    );
  }
}
