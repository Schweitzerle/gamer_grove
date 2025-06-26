// lib/domain/entities/game_video.dart
import 'package:equatable/equatable.dart';

class GameVideo extends Equatable {
  final int id;
  final String videoId; // YouTube ID
  final String? title;
  final String? description;

  const GameVideo({
    required this.id,
    required this.videoId,
    this.title,
    this.description,
  });

  String get youtubeUrl => 'https://www.youtube.com/watch?v=$videoId';
  String get thumbnailUrl => 'https://img.youtube.com/vi/$videoId/maxresdefault.jpg';

  @override
  List<Object?> get props => [id, videoId, title, description];
}