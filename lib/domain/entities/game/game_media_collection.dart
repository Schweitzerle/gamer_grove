// ==========================================

// lib/domain/entities/game/game_media_collection.dart
import 'package:equatable/equatable.dart';
import 'package:gamer_grove/domain/entities/artwork.dart';
import 'package:gamer_grove/domain/entities/game/game_video.dart';
import 'package:gamer_grove/domain/entities/screenshot.dart';

class GameMediaCollection extends Equatable {

  const GameMediaCollection({
    required this.gameId,
    required this.videos,
    required this.screenshots,
    required this.artworks,
  });
  final int gameId;
  final List<GameVideo> videos;
  final List<Screenshot> screenshots;
  final List<Artwork> artworks;

  // Helper getters
  bool get hasVideos => videos.isNotEmpty;
  bool get hasScreenshots => screenshots.isNotEmpty;
  bool get hasArtwork => artworks.isNotEmpty;
  bool get hasAnyMedia => hasVideos || hasScreenshots || hasArtwork;

  int get totalMediaCount => videos.length + screenshots.length + artworks.length;


  @override
  List<Object> get props => [gameId, videos, screenshots, artworks];
}