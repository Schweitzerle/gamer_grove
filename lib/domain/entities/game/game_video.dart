// lib/domain/entities/game_video.dart
import 'package:equatable/equatable.dart';

// lib/domain/entities/game_video.dart
class GameVideo extends Equatable {
  final int id;
  final String videoId;
  final String? title;
  // description removed, da nicht in IGDB API verfügbar

  const GameVideo({
    required this.id,
    required this.videoId,
    this.title,
  });

  String get youtubeUrl => 'https://www.youtube.com/watch?v=$videoId';
  String get thumbnailUrl => 'https://img.youtube.com/vi/$videoId/maxresdefault.jpg';

  @override
  List<Object?> get props => [id, videoId, title];
}