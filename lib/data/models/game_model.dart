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
    try {
      return GameModel(
        id: _parseId(json['id']),
        name: _parseString(json['name']) ?? 'Unknown Game',
        summary: _parseString(json['summary']),
        storyline: _parseString(json['storyline']),
        rating: _parseDouble(json['total_rating']),
        ratingCount: _parseInt(json['total_rating_count']),
        coverUrl: _extractCoverUrl(json['cover']),
        screenshots: _extractImageUrls(json['screenshots']),
        artworks: _extractImageUrls(json['artworks']),
        releaseDate: _parseReleaseDate(json['first_release_date']),
        genres: _extractGenres(json['genres']),
        platforms: _extractPlatforms(json['platforms']),
        gameModes: _extractGameModes(json['game_modes']),
        themes: _extractThemes(json['themes']),
        follows: _parseInt(json['follows']),
        hypes: _parseInt(json['hypes']),
      );
    } catch (e) {
      print('❌ GameModel: Error parsing JSON: $e');
      print('🔍 GameModel: Problematic JSON: $json');
      rethrow;
    }
  }

  // Safe parsing helpers
  static int _parseId(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static String? _parseString(dynamic value) {
    if (value is String && value.isNotEmpty) return value;
    return null;
  }

  static double? _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static int? _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static DateTime? _parseReleaseDate(dynamic value) {
    if (value == null) return null;

    try {
      if (value is int) {
        // IGDB returns Unix timestamp in SECONDS, not milliseconds
        // Convert to milliseconds for DateTime.fromMillisecondsSinceEpoch
        if (value > 0) {
          return DateTime.fromMillisecondsSinceEpoch(value * 1000);
        }
      }
      if (value is String) {
        return DateTime.parse(value);
      }
    } catch (e) {
      print('⚠️ GameModel: Failed to parse release date: $e for value: $value');
    }
    return null;
  }

  static String? _extractCoverUrl(dynamic cover) {
    if (cover == null) return null;

    try {
      String? url;
      if (cover is Map && cover['url'] != null) {
        url = cover['url'] as String;
      } else if (cover is String) {
        url = cover;
      }

      if (url != null) {
        // Ensure URL starts with https:
        if (url.startsWith('//')) {
          url = 'https:$url';
        }
        // Replace thumbnail with bigger image
        return url.replaceAll('t_thumb', 't_cover_big');
      }
    } catch (e) {
      print('⚠️ GameModel: Failed to extract cover URL: $e');
    }
    return null;
  }

  static List<String> _extractImageUrls(dynamic images) {
    if (images == null) return [];

    try {
      final List<String> urls = [];
      if (images is List) {
        for (final img in images) {
          String? url;
          if (img is Map && img['url'] != null) {
            url = img['url'] as String;
          } else if (img is String) {
            url = img;
          }

          if (url != null) {
            if (url.startsWith('//')) {
              url = 'https:$url';
            }
            // Use high resolution for screenshots
            url = url.replaceAll('t_thumb', 't_1080p');
            urls.add(url);
          }
        }
      }
      return urls;
    } catch (e) {
      print('⚠️ GameModel: Failed to extract image URLs: $e');
      return [];
    }
  }

  static List<Genre> _extractGenres(dynamic genres) {
    if (genres == null) return [];

    try {
      final List<Genre> genreList = [];
      if (genres is List) {
        for (final g in genres) {
          if (g is Map) {
            final id = _parseId(g['id']);
            final name = _parseString(g['name']);
            final slug = _parseString(g['slug']) ?? name?.toLowerCase().replaceAll(' ', '-') ?? 'unknown';

            if (id > 0 && name != null) {
              genreList.add(Genre(
                id: id,
                name: name,
                slug: slug,
              ));
            }
          }
        }
      }
      return genreList;
    } catch (e) {
      print('⚠️ GameModel: Failed to extract genres: $e');
      return [];
    }
  }

  static List<Platform> _extractPlatforms(dynamic platforms) {
    if (platforms == null) return [];

    try {
      final List<Platform> platformList = [];
      if (platforms is List) {
        for (final p in platforms) {
          if (p is Map) {
            final id = _parseId(p['id']);
            final name = _parseString(p['name']);
            final abbreviation = _parseString(p['abbreviation']) ?? name ?? 'Unknown';

            if (id > 0 && name != null) {
              platformList.add(Platform(
                id: id,
                name: name,
                abbreviation: abbreviation,
                logoUrl: _parseString(p['platform_logo']?['url']),
              ));
            }
          }
        }
      }
      return platformList;
    } catch (e) {
      print('⚠️ GameModel: Failed to extract platforms: $e');
      return [];
    }
  }

  static List<GameMode> _extractGameModes(dynamic gameModes) {
    if (gameModes == null) return [];

    try {
      final List<GameMode> gameModeList = [];
      if (gameModes is List) {
        for (final gm in gameModes) {
          if (gm is Map) {
            final id = _parseId(gm['id']);
            final name = _parseString(gm['name']);
            final slug = _parseString(gm['slug']) ?? name?.toLowerCase().replaceAll(' ', '-') ?? 'unknown';

            if (id > 0 && name != null) {
              gameModeList.add(GameMode(
                id: id,
                name: name,
                slug: slug,
              ));
            }
          }
        }
      }
      return gameModeList;
    } catch (e) {
      print('⚠️ GameModel: Failed to extract game modes: $e');
      return [];
    }
  }

  static List<String> _extractThemes(dynamic themes) {
    if (themes == null) return [];

    try {
      final List<String> themeList = [];
      if (themes is List) {
        for (final t in themes) {
          String? name;
          if (t is Map && t['name'] != null) {
            name = _parseString(t['name']);
          } else if (t is String) {
            name = t;
          }

          if (name != null && name.isNotEmpty) {
            themeList.add(name);
          }
        }
      }
      return themeList;
    } catch (e) {
      print('⚠️ GameModel: Failed to extract themes: $e');
      return [];
    }
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
      'genres': genres.map((g) => {
        'id': g.id,
        'name': g.name,
        'slug': g.slug
      }).toList(),
      'platforms': platforms.map((p) => {
        'id': p.id,
        'name': p.name,
        'abbreviation': p.abbreviation
      }).toList(),
      'game_modes': gameModes.map((gm) => {
        'id': gm.id,
        'name': gm.name,
        'slug': gm.slug
      }).toList(),
      'themes': themes,
      'follows': follows,
      'hypes': hypes,
      'is_wishlisted': isWishlisted,
      'is_recommended': isRecommended,
      'user_rating': userRating,
    };
  }

  // Helper method to create a test/mock game
  factory GameModel.mock({
    int id = 1,
    String name = 'Test Game',
  }) {
    return GameModel(
      id: id,
      name: name,
      summary: 'This is a test game for development purposes.',
      rating: 85.5,
      ratingCount: 1500,
      coverUrl: 'https://via.placeholder.com/264x352.png?text=$name',
      releaseDate: DateTime.now().subtract(const Duration(days: 365)),
      genres: const [
        Genre(id: 1, name: 'Action', slug: 'action'),
        Genre(id: 2, name: 'Adventure', slug: 'adventure'),
      ],
      platforms: const [
        Platform(id: 1, name: 'PC', abbreviation: 'PC'),
        Platform(id: 2, name: 'PlayStation 5', abbreviation: 'PS5'),
      ],
    );
  }
}