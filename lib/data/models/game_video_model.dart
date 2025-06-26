// lib/data/models/game_video_model.dart
import '../../domain/entities/game_video.dart';

class GameVideoModel extends GameVideo {
  const GameVideoModel({
    required super.id,
    required super.videoId,
    super.title,
    super.description,
  });

  factory GameVideoModel.fromJson(Map<String, dynamic> json) {
    return GameVideoModel(
      id: json['id'] ?? 0,
      videoId: json['video_id'] ?? '',
      title: json['name'],
      description: json['description'],
    );
  }
}
