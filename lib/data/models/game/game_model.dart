// lib/data/models/game_model.dart (VOLLSTÄNDIG ERWEITERT)
import '../../../core/utils/date_formatter.dart';
import '../../../domain/entities/game/game.dart';
import '../../../domain/entities/game/game_type.dart';
import '../../../domain/entities/genre.dart';
import '../../../domain/entities/platform/platform.dart';
import '../../../domain/entities/game/game_mode.dart';
import '../../../domain/entities/involved_company.dart';
import '../../../domain/entities/website/website.dart';
import '../../../domain/entities/game/game_video.dart';
import '../../../domain/entities/ageRating/age_rating.dart';
import '../../../domain/entities/game/game_engine.dart';
import '../../../domain/entities/keyword.dart';
import '../../../domain/entities/multiplayer_mode.dart';
import '../../../domain/entities/player_perspective.dart';
import '../../../domain/entities/franchise.dart';
import '../../../domain/entities/collection.dart';
import '../../../domain/entities/externalGame/external_game.dart';
import '../../../domain/entities/language_support.dart';
import '../../../domain/entities/releaseDate/release_date.dart';
import '../../../domain/entities/game/game_localization.dart';

// Imports für Models
import '../genre_model.dart';
import '../platform/platform_model.dart';
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
import '../collection_model.dart';
import '../externalGame/external_game_model.dart';
import '../language_support_model.dart';
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
    super.isWishlisted,
    super.isRecommended,
    super.userRating,
    super.isInTopThree,
    super.topThreePosition,
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
      playerPerspectives: _extractPlayerPerspectives(json['player_perspectives']),
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
      standaloneExpansions: _extractStandaloneExpansions(json['standalone_expansions']),
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

  static GameStatus _parseGameStatus(dynamic status) {
    if (status is Map && status['id'] is int) {
      // Wenn es ein Objekt mit ID ist
      return _mapGameStatusId(status['id']);
    } else if (status is int) {
      // Direkter Wert (deprecated)
      return _mapGameStatusId(status);
    }
    return GameStatus.unknown;
  }

  static GameStatus _mapGameStatusId(int id) {
    switch (id) {
      case 0: return GameStatus.released;
      case 2: return GameStatus.alpha;
      case 3: return GameStatus.beta;
      case 4: return GameStatus.earlyAccess;
      case 5: return GameStatus.offline;
      case 6: return GameStatus.cancelled;
      case 7: return GameStatus.rumored;
      case 8: return GameStatus.delisted;
      default: return GameStatus.unknown;
    }
  }

  static GameType _parseGameType(dynamic type) {
    if (type is Map && type['id'] is int) {
      // Wenn es ein Objekt mit ID ist
      return _mapGameTypeId(type['id']);
    } else if (type is int) {
      // Direkter Wert (deprecated category)
      return _mapGameTypeId(type);
    }
    return GameType.unknown;
  }

  static GameType _mapGameTypeId(int id) {
    switch (id) {
      case 0: return GameType.mainGame;
      case 1: return GameType.dlcAddon;
      case 2: return GameType.expansion;
      case 3: return GameType.bundle;
      case 4: return GameType.standaloneExpansion;
      case 5: return GameType.mod;
      case 6: return GameType.episode;
      case 7: return GameType.season;
      case 8: return GameType.remake;
      case 9: return GameType.remaster;
      case 10: return GameType.expandedGame;
      case 11: return GameType.port;
      case 12: return GameType.fork;
      case 13: return GameType.pack;
      case 14: return GameType.update;
      default: return GameType.unknown;
    }
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

  static List<String> _extractScreenshots(dynamic screenshots) {
    if (screenshots is List) {
      return screenshots
          .where((item) => item is Map && item['url'] is String)
          .map((item) {
        final url = item['url'] as String;
        return url.startsWith('//') ? 'https:$url' : url;
      })
          .toList();
    }
    return [];
  }

  static List<String> _extractArtworks(dynamic artworks) {
    if (artworks is List) {
      return artworks
          .where((item) => item is Map && item['url'] is String)
          .map((item) {
        final url = item['url'] as String;
        return url.startsWith('//') ? 'https:$url' : url;
      })
          .toList();
    }
    return [];
  }

  static List<GameVideo> _extractVideos(dynamic videos) {
    if (videos is List) {
      return videos
          .where((item) => item is Map)
          .map((item) => GameVideoModel.fromJson(item as Map<String, dynamic>))
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
          .where((item) => item is Map)
          .map((item) {
        try {
          return PlatformModel.fromJson(item as Map<String, dynamic>);
        } catch (e) {
          print('⚠️ GameModel: Failed to parse platform: $item - Error: $e');
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
          print('⚠️ GameModel: Failed to parse game mode: $item - Error: $e');
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
          .where((item) => item is Map)
          .map((item) => KeywordModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  static List<PlayerPerspective> _extractPlayerPerspectives(dynamic perspectives) {
    if (perspectives is List) {
      return perspectives
          .where((item) => item is Map)
          .map((item) => PlayerPerspectiveModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  static List<int> _extractTags(dynamic tags) {
    if (tags is List) {
      return tags
          .where((item) => item is int)
          .map((item) => item as int)
          .toList();
    }
    return [];
  }

  static List<InvolvedCompany> _extractInvolvedCompanies(dynamic companies) {
    if (companies is List) {
      return companies
          .where((item) => item is Map)
          .map((item) => InvolvedCompanyModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  static List<GameEngine> _extractGameEngines(dynamic engines) {
    if (engines is List) {
      return engines
          .where((item) => item is Map)
          .map((item) => GameEngineModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  static List<Website> _extractWebsites(dynamic websites) {
    if (websites is List) {
      return websites
          .where((item) => item is Map)
          .map((item) => WebsiteModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  static List<ExternalGame> _extractExternalGames(dynamic external) {
    if (external is List) {
      return external
          .where((item) => item is Map)
          .map((item) => ExternalGameModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  static List<AgeRating> _extractAgeRatings(dynamic ratings) {
    if (ratings is List) {
      return ratings
          .where((item) => item is Map)
          .map((item) => AgeRatingModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  static List<MultiplayerMode> _extractMultiplayerModes(dynamic modes) {
    if (modes is List) {
      return modes
          .where((item) => item is Map)
          .map((item) => MultiplayerModeModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  static List<LanguageSupport> _extractLanguageSupports(dynamic supports) {
    if (supports is List) {
      return supports
          .where((item) => item is Map)
          .map((item) => LanguageSupportModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  static List<GameLocalization> _extractGameLocalizations(dynamic localizations) {
    if (localizations is List) {
      return localizations
          .where((item) => item is Map)
          .map((item) => GameLocalizationModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  static List<ReleaseDate> _extractReleaseDates(dynamic dates) {
    if (dates is List) {
      return dates
          .where((item) => item is Map)
          .map((item) => ReleaseDateModel.fromJson(item as Map<String, dynamic>))
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
      return franchises
          .where((item) => item is Map)
          .map((item) => FranchiseModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  static List<Collection> _extractCollections(dynamic collections) {
    if (collections is List) {
      return collections
          .where((item) => item is Map)
          .map((item) => CollectionModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  // Verwandte Spiele Extraction Methods
  static List<Game> _extractSimilarGames(dynamic games) => _extractGameList(games);
  static List<Game> _extractDLCs(dynamic games) => _extractGameList(games);
  static List<Game> _extractExpansions(dynamic games) => _extractGameList(games);
  static List<Game> _extractStandaloneExpansions(dynamic games) => _extractGameList(games);
  static List<Game> _extractBundles(dynamic games) => _extractGameList(games);
  static List<Game> _extractExpandedGames(dynamic games) => _extractGameList(games);
  static List<Game> _extractForks(dynamic games) => _extractGameList(games);
  static List<Game> _extractPorts(dynamic games) => _extractGameList(games);
  static List<Game> _extractRemakes(dynamic games) => _extractGameList(games);
  static List<Game> _extractRemasters(dynamic games) => _extractGameList(games);

  static List<Game> _extractGameList(dynamic games) {
    if (games is List) {
      return games
          .where((item) => item is Map)
          .map((item) => GameModel.fromJson(item as Map<String, dynamic>))
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

  // ===== SERIALIZATION =====

  /// Konvertiert das GameModel zu JSON für Caching und API-Responses
  Map<String, dynamic> toJson() {
    return {
      // Grundlegende Daten
      'id': id,
      'name': name,
      'summary': summary,
      'storyline': storyline,
      'slug': slug,
      'url': url,
      'checksum': checksum,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),

      // Bewertungen
      'total_rating': totalRating,
      'total_rating_count': totalRatingCount,
      'rating': rating,
      'rating_count': ratingCount,
      'aggregated_rating': aggregatedRating,
      'aggregated_rating_count': aggregatedRatingCount,

      // Release & Status
      'first_release_date': firstReleaseDate != null
          ? firstReleaseDate!.millisecondsSinceEpoch ~/ 1000
          : null,
      'release_dates': releaseDates.map((rd) => {
        'id': rd.id,
        'date': rd.date != null ? rd.date!.millisecondsSinceEpoch ~/ 1000 : null,
        'platform': rd.platform != null ? {
          'id': rd.platform!.id,
          'name': rd.platform!.name,
          'abbreviation': rd.platform!.abbreviation,
        } : null,
        'region': rd.region.index,
        'human': rd.human,
      }).toList(),
      'game_status': gameStatus.index,
      'game_type': gameType.index,
      'version_title': versionTitle,
      'version_parent': versionParent != null ? {
        'id': versionParent!.id,
        'name': versionParent!.name,
        'cover': {'url': versionParent!.coverUrl},
      } : null,

      // Medien
      'cover': coverUrl != null ? {'url': coverUrl} : null,
      'screenshots': screenshots.map((url) => {'url': url}).toList(),
      'artworks': artworks.map((url) => {'url': url}).toList(),
      'videos': videos.map((video) => {
        'id': video.id,
        'video_id': video.videoId,
        'name': video.title,
      }).toList(),

      // Kategorisierung
      'genres': genres.map((genre) => {
        'id': genre.id,
        'name': genre.name,
        'slug': genre.slug,
      }).toList(),
      'platforms': platforms.map((platform) => {
        'id': platform.id,
        'name': platform.name,
        'abbreviation': platform.abbreviation,
        'logo': platform.logoUrl != null ? {'url': platform.logoUrl} : null,
      }).toList(),
      'game_modes': gameModes.map((mode) => {
        'id': mode.id,
        'name': mode.name,
        'slug': mode.slug,
      }).toList(),
      'themes': themes.map((theme) => {'name': theme}).toList(),
      'keywords': keywords.map((keyword) => {
        'id': keyword.id,
        'name': keyword.name,
        'slug': keyword.slug,
      }).toList(),
      'player_perspectives': playerPerspectives.map((pp) => {
        'id': pp.id,
        'name': pp.name,
        'slug': pp.slug,
      }).toList(),
      'tags': tags,

      // Unternehmen & Entwicklung
      'involved_companies': involvedCompanies.map((ic) => {
        'id': ic.id,
        'company': {
          'id': ic.company.id,
          'name': ic.company.name,
          'logo': ic.company.logoUrl != null ? {'url': ic.company.logoUrl} : null,
        },
        'developer': ic.isDeveloper,
        'publisher': ic.isPublisher,
        'porting': ic.isPorting,
        'supporting': ic.isSupporting,
      }).toList(),
      'game_engines': gameEngines.map((engine) => {
        'id': engine.id,
        'name': engine.name,
        'logo': engine.logoUrl != null ? {'url': engine.logoUrl} : null,
        'description': engine.description,
      }).toList(),

      // Externe Links & Stores
      'websites': websites.map((website) => {
        'id': website.id,
        'url': website.url,
        'category': website.category.index,
        'title': website.title,
      }).toList(),
      'external_games': externalGames.map((eg) => {
        'id': eg.id,
        'uid': eg.uid,
        'url': eg.url,
        'category': eg.category.index,
        'name': eg.name,
      }).toList(),

      // Bewertungen & Regulierung
      'age_ratings': ageRatings.map((rating) => {
        'id': rating.id,
        'organization': rating.organization.index,
        'rating_category': rating.ratingCategory.index,
        'synopsis': rating.synopsis,
        'rating_cover_url': rating.ratingCoverUrl,
        'content_descriptions': rating.contentDescriptions,
      }).toList(),

      // Features
      'multiplayer_modes': multiplayerModes.map((mm) => {
        'id': mm.id,
        'campaigncoop': mm.campaignCoop,
        'dropin': mm.dropin,
        'lancoop': mm.lancoop,
        'offlinecoop': mm.offlineCoop,
        'offlinecoopmax': mm.offlineCoopMax,
        'offlinemax': mm.offlineMax,
        'onlinecoop': mm.onlineCoop,
        'onlinecoopmax': mm.onlineCoopMax,
        'onlinemax': mm.onlineMax,
        'splitscreen': mm.splitscreen,
        'splitscreenonline': mm.splitscreenOnline,
      }).toList(),
      'language_supports': languageSupports.map((ls) => {
        'id': ls.id,
        'language': ls.languageName,
        'language_support_type': ls.supportType.index,
      }).toList(),
      'game_localizations': gameLocalizations.map((gl) => {
        'id': gl.id,
        'name': gl.name,
        'region': gl.region.index,
      }).toList(),

      // Serien & Sammlungen
      'franchise': mainFranchise != null ? {
        'id': mainFranchise!.id,
        'name': mainFranchise!.name,
        'slug': mainFranchise!.slug,
        'url': mainFranchise!.url,
      } : null,
      'franchises': franchises.map((franchise) => {
        'id': franchise.id,
        'name': franchise.name,
        'slug': franchise.slug,
        'url': franchise.url,
      }).toList(),
      'collections': collections.map((collection) => {
        'id': collection.id,
        'name': collection.name,
        'slug': collection.slug,
        'url': collection.url,
      }).toList(),

      // Verwandte Spiele (simplified für JSON)
      'similar_games': _serializeGameList(similarGames),
      'dlcs': _serializeGameList(dlcs),
      'expansions': _serializeGameList(expansions),
      'standalone_expansions': _serializeGameList(standaloneExpansions),
      'bundles': _serializeGameList(bundles),
      'expanded_games': _serializeGameList(expandedGames),
      'forks': _serializeGameList(forks),
      'ports': _serializeGameList(ports),
      'remakes': _serializeGameList(remakes),
      'remasters': _serializeGameList(remasters),
      'parent_game': parentGame != null ? {
        'id': parentGame!.id,
        'name': parentGame!.name,
        'cover': {'url': parentGame!.coverUrl},
      } : null,

      // Alternative Namen
      'alternative_names': alternativeNames.map((name) => {'name': name}).toList(),

      // Community & Hype
      'hypes': hypes,

      // User Daten (für Caching)
      'is_wishlisted': isWishlisted,
      'is_recommended': isRecommended,
      'user_rating': userRating,
      'is_in_top_three': isInTopThree,
      'top_three_position': topThreePosition,
    };
  }

  /// Vereinfachte Serialisierung für Game-Listen (vermeidet Zirkularität)
  static List<Map<String, dynamic>> _serializeGameList(List<Game> games) {
    return games.map((game) => {
      'id': game.id,
      'name': game.name,
      'cover': game.coverUrl != null ? {'url': game.coverUrl} : null,
      'total_rating': game.bestRating,
      'first_release_date': game.bestReleaseDate != null
          ? game.bestReleaseDate!.millisecondsSinceEpoch ~/ 1000
          : null,
    }).toList();
  }

  /// Erstellt ein vollständiges Mock-Game für Tests und Entwicklung
  factory GameModel.mock({
    int id = 1,
    String name = 'Mock Game',
    String? summary,
    double? totalRating,
    List<Genre>? genres,
    List<Platform>? platforms,
  }) {
    return GameModel(
      id: id,
      name: name,
      summary: summary ?? 'This is a mock game for testing and development purposes.',
      totalRating: totalRating ?? 85.5,
      totalRatingCount: 1500,
      coverUrl: 'https://via.placeholder.com/264x352.png?text=${Uri.encodeComponent(name)}',
      firstReleaseDate: DateTime.now().subtract(const Duration(days: 365)),
      gameStatus: GameStatus.released,
      gameType: GameType.mainGame,
      genres: genres ?? [
        const GenreModel(id: 1, name: 'Action', slug: 'action'),
        const GenreModel(id: 2, name: 'Adventure', slug: 'adventure'),
      ],
      platforms: platforms ?? [
        const PlatformModel(id: 6, name: 'PC (Microsoft Windows)', abbreviation: 'PC'),
        const PlatformModel(id: 167, name: 'PlayStation 5', abbreviation: 'PS5'),
      ],
      gameModes: const [
        GameModeModel(id: 1, name: 'Single player', slug: 'singleplayer'),
        GameModeModel(id: 2, name: 'Multiplayer', slug: 'multiplayer'),
      ],
      screenshots: [
        'https://via.placeholder.com/1920x1080.png?text=Screenshot+1',
        'https://via.placeholder.com/1920x1080.png?text=Screenshot+2',
      ],
      hypes: 150,
    );
  }
}