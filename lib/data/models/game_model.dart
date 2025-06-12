// data/models/game_model.dart
import '../../domain/entities/game.dart';
import '../../domain/entities/genre.dart';
import '../../domain/entities/platform.dart';
import '../../domain/entities/game_mode.dart';

class GameModel extends Game {
  const GameModel({
    required super.id,
    required super.name,
    super.summary,
    super.storyline,
    super.rating,
    super.ratingCount,
    super.coverUrl,
    super.screenshots,
    super.artworks,
    super.releaseDate,
    super.genres,
    super.platforms,
    super.gameModes,
    super.themes,
    super.follows,
    super.hypes,
    super.isWishlisted,
    super.isRecommended,
    super.userRating,
  });

  factory GameModel.fromJson(Map<String, dynamic> json) {
    return GameModel(
      id: json['id'],
      name: json['name'],
      summary: json['summary'],
      storyline: json['storyline'],
      rating: json['total_rating']?.toDouble(),
      ratingCount: json['total_rating_count'],
      coverUrl: _extractCoverUrl(json['cover']),
      screenshots: _extractImageUrls(json['screenshots']),
      artworks: _extractImageUrls(json['artworks']),
      releaseDate: json['first_release_date'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['first_release_date'] * 1000)
          : null,
      genres: _extractGenres(json['genres']),
      platforms: _extractPlatforms(json['platforms']),
      gameModes: _extractGameModes(json['game_modes']),
      themes: _extractThemes(json['themes']),
      follows: json['follows'],
      hypes: json['hypes'],
    );
  }

  static String? _extractCoverUrl(dynamic cover) {
    if (cover == null) return null;
    if (cover is Map && cover['url'] != null) {
      return 'https:${cover['url']}'.replaceAll('t_thumb', 't_cover_big');
    }
    return null;
  }

  static List<String> _extractImageUrls(dynamic images) {
    if (images == null) return [];
    if (images is List) {
      return images
          .where((img) => img['url'] != null)
          .map<String>((img) => 'https:${img['url']}'.replaceAll('t_thumb', 't_1080p'))
          .toList();
    }
    return [];
  }

  static List<Genre> _extractGenres(dynamic genres) {
    if (genres == null) return [];
    if (genres is List) {
      return genres.map((g) => Genre(
        id: g['id'],
        name: g['name'] ?? '',
        slug: g['slug'] ?? '',
      )).toList();
    }
    return [];
  }

  static List<Platform> _extractPlatforms(dynamic platforms) {
    if (platforms == null) return [];
    if (platforms is List) {
      return platforms.map((p) => Platform(
        id: p['id'],
        name: p['name'] ?? '',
        abbreviation: p['abbreviation'] ?? '',
        logoUrl: p['platform_logo']?['url'] != null
            ? 'https:${p['platform_logo']['url']}'
            : null,
      )).toList();
    }
    return [];
  }

  static List<GameMode> _extractGameModes(dynamic gameModes) {
    if (gameModes == null) return [];
    if (gameModes is List) {
      return gameModes.map((gm) => GameMode(
        id: gm['id'],
        name: gm['name'] ?? '',
        slug: gm['slug'] ?? '',
      )).toList();
    }
    return [];
  }

  static List<String> _extractThemes(dynamic themes) {
    if (themes == null) return [];
    if (themes is List) {
      return themes
          .where((t) => t['name'] != null)
          .map<String>((t) => t['name'])
          .toList();
    }
    return [];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'summary': summary,
      'storyline': storyline,
      'total_rating': rating,
      'total_rating_count': ratingCount,
      'cover_url': coverUrl,
      'screenshots': screenshots,
      'artworks': artworks,
      'first_release_date': releaseDate?.millisecondsSinceEpoch,
      'genres': genres.map((g) => {'id': g.id, 'name': g.name}).toList(),
      'platforms': platforms.map((p) => {'id': p.id, 'name': p.name}).toList(),
      'follows': follows,
      'hypes': hypes,
    };
  }
}