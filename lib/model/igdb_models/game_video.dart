import 'package:gamer_grove/model/igdb_models/game.dart';

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
          ? Game(id: json['game'])
          : Game.fromJson(json['game']))
          : null,
      name: json['name'],
      videoId: json['video_id'],
      id: json['id'],
    );
  }
}
