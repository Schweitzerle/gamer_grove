// ===========================================
// ERWEITERTE GAMEVIDEOMODEL MIT TOJSON
// ===========================================
// lib/data/models/game/game_video_model.dart
import '../../../domain/entities/game/game_video.dart';

class GameVideoModel extends GameVideo {
  const GameVideoModel({
    required super.id,
    required super.videoId,
    super.title,
  });

  factory GameVideoModel.fromJson(Map<String, dynamic> json) {
    return GameVideoModel(
      id: json['id'] ?? 0,
      videoId: json['video_id'] ?? '',
      title: json['name'] ?? json['title'], // Try both name and title fields
    );
  }

  // *** NEUE TOJSON METHODE ***
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'video_id': videoId,
      'name': title, // IGDB uses 'name' field for video titles
      'title': title, // Also include title for compatibility
    };
  }

  // Helper method to get YouTube URL
  String get youtubeUrl => 'https://www.youtube.com/watch?v=$videoId';

  // Helper method to get YouTube thumbnail URL
  String get thumbnailUrl => 'https://img.youtube.com/vi/$videoId/maxresdefault.jpg';

  // Helper method to get YouTube embed URL
  String get embedUrl => 'https://www.youtube.com/embed/$videoId';

  // Helper method to check if video ID is valid
  bool get isValidVideo => videoId.isNotEmpty && videoId.length >= 10;

  // Helper method to get display title
  String get displayTitle => title ?? 'Game Video';

  // Factory method to create from YouTube URL
  factory GameVideoModel.fromYouTubeUrl(String url, {String? title, int? id}) {
    final videoId = _extractVideoIdFromUrl(url);
    return GameVideoModel(
      id: id ?? 0,
      videoId: videoId,
      title: title,
    );
  }

  // Helper method to extract video ID from various YouTube URL formats
  static String _extractVideoIdFromUrl(String url) {
    // Handle different YouTube URL formats
    final patterns = [
      RegExp(r'youtube\.com/watch\?v=([a-zA-Z0-9_-]+)'),
      RegExp(r'youtube\.com/embed/([a-zA-Z0-9_-]+)'),
      RegExp(r'youtu\.be/([a-zA-Z0-9_-]+)'),
      RegExp(r'youtube\.com/v/([a-zA-Z0-9_-]+)'),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(url);
      if (match != null && match.groupCount > 0) {
        return match.group(1) ?? '';
      }
    }

    // If no pattern matches, assume the entire string is the video ID
    return url;
  }

  // Copy method for easy modification
  GameVideoModel copyWith({
    int? id,
    String? videoId,
    String? title,
  }) {
    return GameVideoModel(
      id: id ?? this.id,
      videoId: videoId ?? this.videoId,
      title: title ?? this.title,
    );
  }
}