import 'package:gamer_grove/model/igdb_models/game.dart';

import '../../repository/igdb/IGDBApiService.dart';
import '../firebase/firebaseUser.dart';
import '../firebase/gameModel.dart';

class GameVideo {
  int id;
  final String? checksum;
  final Game? game; // Referenz-ID für das Spiel
  final String? name;
  final String? videoId; // Externe ID des Videos (normalerweise YouTube)

  GameVideo({
    required this.id,
    this.checksum,
    this.game,
    this.name,
    this.videoId,
  });

  factory GameVideo.fromJson(Map<String, dynamic> json) {
    return GameVideo(
      checksum: json['checksum'],
      game: json['game'] != null
          ? (json['game'] is int
          ? Game(id: json['game'], gameModel: GameModel(id: '0', wishlist: false, recommended: false, rating: 0))
          : Game.fromJson(json['game'], IGDBApiService.getGameModel(json['game']['id'])))
          : null,
      name: json['name'],
      videoId: json['video_id'],
      id: json['id'],
    );
  }
}
