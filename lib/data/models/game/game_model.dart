// lib/data/models/game_model.dart (VOLLSTÄNDIG ERWEITERT)
import '../../../domain/entities/artwork.dart';
import '../../../domain/entities/character/character.dart';
import '../../../domain/entities/event/event.dart';
import '../../../domain/entities/game/game.dart';
import '../../../domain/entities/game/game_status.dart';
import '../../../domain/entities/game/game_type.dart';
import '../../../domain/entities/genre.dart';
import '../../../domain/entities/language/language_support.dart';
import '../../../domain/entities/platform/platform.dart';
import '../../../domain/entities/game/game_mode.dart';
import '../../../domain/entities/involved_company.dart';
import '../../../domain/entities/screenshot.dart';
import '../../../domain/entities/website/website.dart';
import '../../../domain/entities/game/game_video.dart';
import '../../../domain/entities/ageRating/age_rating.dart';
import '../../../domain/entities/game/game_engine.dart';
import '../../../domain/entities/keyword.dart';
import '../../../domain/entities/multiplayer_mode.dart';
import '../../../domain/entities/player_perspective.dart';
import '../../../domain/entities/franchise.dart';

// FIX: Correct import path
import '../../../domain/entities/collection/collection.dart';
import '../../../domain/entities/externalGame/external_game.dart';
import '../../../domain/entities/releaseDate/release_date.dart';
import '../../../domain/entities/game/game_localization.dart';

// Imports für Models
import '../artwork_model.dart';
import '../character/character_model.dart';
import '../collection/collection_model.dart';
import '../event/event_model.dart';
import '../genre_model.dart';
import '../language/language_support_model.dart';
import '../platform/platform_model.dart';
import '../screenshot_model.dart';
import 'game_mode_model.dart';
import '../involved_company_model.dart';
import '../website/website_model.dart';
import 'game_video_model.dart';
import '../ageRating/age_rating_model.dart';
import 'game_engine_model.dart';
import '../keyword_model.dart';
import '../multiplayer_mode_model.dart';
import '../player_perspective_model.dart';
import '../franchise_model.dart';
import '../externalGame/external_game_model.dart';
import '../release_date/release_date_model.dart';
import 'game_localization_model.dart';

class GameModel extends Game {
  const GameModel({
    required super.id,
    required super.name,
    super.summary,
    super.storyline,
    super.slug,
    super.url,
    super.checksum,
    super.createdAt,
    super.updatedAt,
    super.totalRating,
    super.totalRatingCount,
    super.rating,
    super.ratingCount,
    super.aggregatedRating,
    super.aggregatedRatingCount,
    super.firstReleaseDate,
    super.releaseDates,
    super.gameStatus,
    super.gameType,
    super.versionTitle,
    super.versionParent,
    super.coverUrl,
    super.screenshots,
    super.artworks,
    super.videos,
    super.genres,
    super.platforms,
    super.gameModes,
    super.themes,
    super.keywords,
    super.playerPerspectives,
    super.tags,
    super.involvedCompanies,
    super.gameEngines,
    super.websites,
    super.externalGames,
    super.ageRatings,
    super.multiplayerModes,
    super.languageSupports,
    super.gameLocalizations,
    super.mainFranchise,
    super.franchises,
    super.collections,
    super.similarGames,
    super.dlcs,
    super.expansions,
    super.standaloneExpansions,
    super.bundles,
    super.expandedGames,
    super.forks,
    super.ports,
    super.remakes,
    super.remasters,
    super.parentGame,
    super.alternativeNames,
    super.hypes,
    super.characters,
    super.events,
    // FIX: Remove these parameters if they don't exist in Game entity
    // super.isWishlisted,
    // super.isRecommended,
    // super.userRating,
    // super.isInTopThree,
    // super.topThreePosition,
  });

  factory GameModel.fromJson(Map<String, dynamic> json) {
    return GameModel(
      id: _parseId(json['id']),
      name: _parseString(json['name']) ?? 'Unknown Game',
      summary: _parseString(json['summary']),
      storyline: _parseString(json['storyline']),
      slug: _parseString(json['slug']),
      url: _parseString(json['url']),
      checksum: _parseString(json['checksum']),
      createdAt: _parseDateTime(json['created_at']),
      updatedAt: _parseDateTime(json['updated_at']),

      // Bewertungen
      totalRating: _parseDouble(json['total_rating']),
      totalRatingCount: _parseInt(json['total_rating_count']),
      rating: _parseDouble(json['rating']),
      ratingCount: _parseInt(json['rating_count']),
      aggregatedRating: _parseDouble(json['aggregated_rating']),
      aggregatedRatingCount: _parseInt(json['aggregated_rating_count']),

      // Release & Status
      firstReleaseDate: _parseUnixTimestamp(json['first_release_date']),
      releaseDates: _extractReleaseDates(json['release_dates']),
      gameStatus: _parseGameStatus(json['game_status']),
      gameType: _parseGameType(json['game_type']),
      versionTitle: _parseString(json['version_title']),
      versionParent: _extractVersionParent(json['version_parent']),

      // Medien
      coverUrl: _extractCoverUrl(json['cover']),
      screenshots: _extractScreenshots(json['screenshots']),
      artworks: _extractArtworks(json['artworks']),
      videos: _extractVideos(json['videos']),

      // Kategorisierung
      genres: _extractGenres(json['genres']),
      platforms: _extractPlatforms(json['platforms']),
      gameModes: _extractGameModes(json['game_modes']),
      themes: _extractThemes(json['themes']),
      keywords: _extractKeywords(json['keywords']),
      playerPerspectives:
          _extractPlayerPerspectives(json['player_perspectives']),
      tags: _extractTags(json['tags']),

      // Unternehmen
      involvedCompanies: _extractInvolvedCompanies(json['involved_companies']),
      gameEngines: _extractGameEngines(json['game_engines']),

      // Externe Links
      websites: _extractWebsites(json['websites']),
      externalGames: _extractExternalGames(json['external_games']),

      // Bewertungen & Regulierung
      ageRatings: _extractAgeRatings(json['age_ratings']),

      // Features
      multiplayerModes: _extractMultiplayerModes(json['multiplayer_modes']),
      languageSupports: _extractLanguageSupports(json['language_supports']),
      gameLocalizations: _extractGameLocalizations(json['game_localizations']),

      // Serien & Sammlungen
      mainFranchise: _extractMainFranchise(json['franchise']),
      franchises: _extractFranchises(json['franchises']),
      collections: _extractCollections(json['collections']),

      // Verwandte Spiele
      similarGames: _extractSimilarGames(json['similar_games']),
      dlcs: _extractDLCs(json['dlcs']),
      expansions: _extractExpansions(json['expansions']),
      standaloneExpansions:
          _extractStandaloneExpansions(json['standalone_expansions']),
      bundles: _extractBundles(json['bundles']),
      expandedGames: _extractExpandedGames(json['expanded_games']),
      forks: _extractForks(json['forks']),
      ports: _extractPorts(json['ports']),
      remakes: _extractRemakes(json['remakes']),
      remasters: _extractRemasters(json['remasters']),
      parentGame: _extractParentGame(json['parent_game']),

      // Alternative Namen
      alternativeNames: _extractAlternativeNames(json['alternative_names']),

      // Community
      hypes: _parseInt(json['hypes']),

      characters: _extractCharacters(json['characters']),
      events: _extractEvents(json['events']),
    );
  }

  // ===== PARSING HELPER METHODS =====

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

  static DateTime? _parseDateTime(dynamic value) {
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  static DateTime? _parseUnixTimestamp(dynamic timestamp) {
    if (timestamp is int) {
      return DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    }
    return null;
  }

  // ===== ENUM PARSING =====

  // ===== FIXED ENUM PARSING IN GAMEMODEL =====
// Ersetze diese Methoden in deinem GameModel:

  // FIX: Parse GameStatus as Entity (not Enum)
  static GameStatus? _parseGameStatus(dynamic status) {
    // If it's already a GameStatus entity object
    if (status is Map && status['name'] is String) {
      return GameStatus(
        id: status['id'] ?? 0,
        checksum: status['checksum'] ?? '',
        status: status['status'] ?? 'Unknown',
        description: status['description'],
        createdAt: _parseDateTime(status['created_at']),
        updatedAt: _parseDateTime(status['updated_at']),
      );
    }
    return null; // Changed to nullable
  }

  static GameType? _parseGameType(dynamic type) {
    // If it's already a GameType entity object
    if (type is Map && type['name'] is String) {
      return GameType(
        id: type['id'] ?? 0,
        checksum: type['checksum'] ?? '',
        type: type['type'] ?? 'Unknown',
        createdAt: _parseDateTime(type['created_at']),
        updatedAt: _parseDateTime(type['updated_at']),
      );
    }
    return null; // Changed to nullable
  }

  // ===== EXTRACTION METHODS =====

  static String? _extractCoverUrl(dynamic cover) {
    if (cover is Map) {
      final url = cover['url'];
      if (url is String) {
        return url.startsWith('//') ? 'https:$url' : url;
      }
    }
    return null;
  }

  static List<Character> _extractCharacters(dynamic characters) {
    if (characters is List) {
      return characters
          .whereType<Map<String, dynamic>>()
          .map((item) => CharacterModel.fromJson(item))
          .toList();
    }
    return [];
  }

  static List<Event> _extractEvents(dynamic events) {
    if (events is List) {
      return events
          .whereType<Map<String, dynamic>>()
          .map((item) => EventModel.fromJson(item))
          .toList();
    }
    return [];
  }

// Korrigierte Screenshot Extraction:
  static List<Screenshot> _extractScreenshots(dynamic screenshots) {
    if (screenshots is List) {
      return screenshots
          .whereType<Map<String, dynamic>>()
          .map((item) => ScreenshotModel.fromJson(item))
          .toList();
    }
    return [];
  }

// Korrigierte Artwork Extraction:
  static List<Artwork> _extractArtworks(dynamic artworks) {
    if (artworks is List) {
      return artworks
          .whereType<Map<String, dynamic>>()
          .map((item) => ArtworkModel.fromJson(item))
          .toList();
    }
    return [];
  }

  static List<GameVideo> _extractVideos(dynamic videos) {
    if (videos is List) {
      return videos
          .whereType<Map<String, dynamic>>()
          .map((item) => GameVideoModel.fromJson(item))
          .toList();
    }
    return [];
  }

  static List<Genre> _extractGenres(dynamic genres) {
    if (genres is List) {
      return genres
          .where((item) => item is Map && item['name'] is String)
          .map((item) {
            try {
              return GenreModel.fromJson(item as Map<String, dynamic>);
            } catch (e) {
              print('⚠️ GameModel: Failed to parse genre: $item - Error: $e');
              return null;
            }
          })
          .where((genre) => genre != null)
          .cast<Genre>()
          .toList();
    }
    return [];
  }

  static List<Platform> _extractPlatforms(dynamic platforms) {
    if (platforms is List) {
      return platforms
          .whereType<Map<String, dynamic>>()
          .map((item) {
            try {
              return PlatformModel.fromJson(item);
            } catch (e) {
              print(
                  '⚠️ GameModel: Failed to parse platform: $item - Error: $e');
              return null;
            }
          })
          .where((platform) => platform != null)
          .cast<Platform>()
          .toList();
    }
    return [];
  }

  static List<GameMode> _extractGameModes(dynamic gameModes) {
    if (gameModes is List) {
      return gameModes
          .where((item) => item is Map && item['name'] is String)
          .map((item) {
            try {
              return GameModeModel.fromJson(item as Map<String, dynamic>);
            } catch (e) {
              print(
                  '⚠️ GameModel: Failed to parse game mode: $item - Error: $e');
              return null;
            }
          })
          .where((gameMode) => gameMode != null)
          .cast<GameMode>()
          .toList();
    }
    return [];
  }

  static List<String> _extractThemes(dynamic themes) {
    if (themes is List) {
      return themes
          .where((item) => item is Map && item['name'] is String)
          .map((item) => item['name'] as String)
          .toList();
    }
    return [];
  }

  static List<Keyword> _extractKeywords(dynamic keywords) {
    if (keywords is List) {
      return keywords
          .whereType<Map<String, dynamic>>()
          .map((item) => KeywordModel.fromJson(item))
          .toList();
    }
    return [];
  }

  static List<PlayerPerspective> _extractPlayerPerspectives(
      dynamic perspectives) {
    if (perspectives is List) {
      return perspectives
          .whereType<Map<String, dynamic>>()
          .map((item) => PlayerPerspectiveModel.fromJson(item))
          .toList();
    }
    return [];
  }

  static List<int> _extractTags(dynamic tags) {
    if (tags is List) {
      return tags.whereType<int>().map((item) => item).toList();
    }
    return [];
  }

  static List<InvolvedCompany> _extractInvolvedCompanies(dynamic companies) {
    if (companies is List) {
      return companies
          .whereType<Map<String, dynamic>>()
          .map((item) => InvolvedCompanyModel.fromJson(item))
          .toList();
    }
    return [];
  }

  static List<GameEngine> _extractGameEngines(dynamic engines) {
    if (engines is List) {
      return engines
          .whereType<Map<String, dynamic>>()
          .map((item) => GameEngineModel.fromJson(item))
          .toList();
    }
    return [];
  }

  static List<Website> _extractWebsites(dynamic websites) {
    if (websites is List) {
      return websites
          .whereType<Map<String, dynamic>>()
          .map((item) => WebsiteModel.fromJson(item))
          .toList();
    }
    return [];
  }

  static List<ExternalGame> _extractExternalGames(dynamic external) {
    if (external is List) {
      return external
          .whereType<Map<String, dynamic>>()
          .map((item) => ExternalGameModel.fromJson(item))
          .toList();
    }
    return [];
  }

  static List<AgeRating> _extractAgeRatings(dynamic ratings) {
    if (ratings is List) {
      return ratings
          .whereType<Map<String, dynamic>>()
          .map((item) => AgeRatingModel.fromJson(item))
          .toList();
    }
    return [];
  }

  static List<MultiplayerMode> _extractMultiplayerModes(dynamic modes) {
    if (modes is List) {
      return modes
          .whereType<Map<String, dynamic>>()
          .map((item) => MultiplayerModeModel.fromJson(item))
          .toList();
    }
    return [];
  }

  static List<LanguageSupport> _extractLanguageSupports(dynamic supports) {
    if (supports is List) {
      return supports
          .whereType<Map<String, dynamic>>()
          .map((item) => LanguageSupportModel.fromJson(item))
          .toList();
    }
    return [];
  }

  static List<GameLocalization> _extractGameLocalizations(
      dynamic localizations) {
    if (localizations is List) {
      return localizations
          .whereType<Map<String, dynamic>>()
          .map((item) => GameLocalizationModel.fromJson(item))
          .toList();
    }
    return [];
  }

  static List<ReleaseDate> _extractReleaseDates(dynamic dates) {
    if (dates is List) {
      return dates
          .whereType<Map<String, dynamic>>()
          .map((item) => ReleaseDateModel.fromJson(item))
          .toList();
    }
    return [];
  }

  static Franchise? _extractMainFranchise(dynamic franchise) {
    if (franchise is Map) {
      return FranchiseModel.fromJson(franchise as Map<String, dynamic>);
    }
    return null;
  }

  static List<Franchise> _extractFranchises(dynamic franchises) {
    if (franchises is List) {
      print(franchises.length);
      return franchises
          .whereType<Map<String, dynamic>>()
          .map((item) => FranchiseModel.fromJson(item))
          .toList();
    }
    return [];
  }

  static List<Collection> _extractCollections(dynamic collections) {
    if (collections is List) {
      print(collections.length);
      return collections
          .whereType<Map<String, dynamic>>()
          .map((item) => CollectionModel.fromJson(item))
          .toList();
    }
    return [];
  }

  // Verwandte Spiele Extraction Methods
  static List<Game> _extractSimilarGames(dynamic games) =>
      _extractGameList(games);

  static List<Game> _extractDLCs(dynamic games) => _extractGameList(games);

  static List<Game> _extractExpansions(dynamic games) =>
      _extractGameList(games);

  static List<Game> _extractStandaloneExpansions(dynamic games) =>
      _extractGameList(games);

  static List<Game> _extractBundles(dynamic games) => _extractGameList(games);

  static List<Game> _extractExpandedGames(dynamic games) =>
      _extractGameList(games);

  static List<Game> _extractForks(dynamic games) => _extractGameList(games);

  static List<Game> _extractPorts(dynamic games) => _extractGameList(games);

  static List<Game> _extractRemakes(dynamic games) => _extractGameList(games);

  static List<Game> _extractRemasters(dynamic games) => _extractGameList(games);

  static List<Game> _extractGameList(dynamic games) {
    if (games is List) {
      return games
          .whereType<Map<String, dynamic>>()
          .map((item) => GameModel.fromJson(item))
          .toList();
    }
    return [];
  }

  static Game? _extractParentGame(dynamic parent) {
    if (parent is Map) {
      return GameModel.fromJson(parent as Map<String, dynamic>);
    }
    return null;
  }

  static Game? _extractVersionParent(dynamic parent) {
    if (parent is Map) {
      return GameModel.fromJson(parent as Map<String, dynamic>);
    }
    return null;
  }

  static List<String> _extractAlternativeNames(dynamic names) {
    if (names is List) {
      return names
          .where((item) => item is Map && item['name'] is String)
          .map((item) => item['name'] as String)
          .toList();
    }
    return [];
  }

  // ===== SIMPLIFIED SERIALIZATION =====
  // FIX: Simplified toJson without problematic properties

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'summary': summary,
      'slug': slug,
      'url': url,
      'checksum': checksum,
      'total_rating': totalRating,
      'total_rating_count': totalRatingCount,
      'first_release_date': firstReleaseDate != null
          ? firstReleaseDate!.millisecondsSinceEpoch ~/ 1000
          : null,
      'cover': coverUrl != null ? {'url': coverUrl} : null,
      'screenshots': screenshots.map((url) => {'url': url}).toList(),
      'artworks': artworks.map((url) => {'url': url}).toList(),
      'genres': genres
          .map((genre) => {
                'id': genre.id,
                'name': genre.name,
                'slug': genre.slug,
              })
          .toList(),
      'platforms': platforms
          .map((platform) => {
                'id': platform.id,
                'name': platform.name,
                'abbreviation': platform.abbreviation,
              })
          .toList(),
      'themes': themes.map((theme) => {'name': theme}).toList(),
      'hypes': hypes,
    };
  }
}
