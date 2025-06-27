// data/models/game_model.dart
import 'package:gamer_grove/data/models/player_perspective_model.dart';

import '../../core/utils/date_formatter.dart';
import '../../domain/entities/age_rating.dart';
import '../../domain/entities/collection.dart';
import '../../domain/entities/external_game.dart';
import '../../domain/entities/franchise.dart';
import '../../domain/entities/game.dart';
import '../../domain/entities/game_engine.dart';
import '../../domain/entities/game_video.dart';
import '../../domain/entities/genre.dart';
import '../../domain/entities/involved_company.dart';
import '../../domain/entities/keyword.dart';
import '../../domain/entities/language_support.dart';
import '../../domain/entities/multiplayer_mode.dart';
import '../../domain/entities/platform.dart';
import '../../domain/entities/game_mode.dart';
import 'language_support_model.dart';
import '../../domain/entities/game.dart';
import '../../domain/entities/player_perspective.dart';
import '../../domain/entities/website.dart';
import '../datasources/remote/idgb_remote_datasource.dart';
import 'collection_model.dart';
import 'company_model.dart';
import 'external_game_model.dart';
import 'franchise_model.dart';
import 'game_engine_model.dart';
import 'involved_company_model.dart';
import 'keyword_model.dart';
import 'multiplayer_mode_model.dart';
import 'website_model.dart';
import 'game_video_model.dart';
import 'age_rating_model.dart';

class GameModel extends Game {
  const GameModel({
    required super.id,
    required super.name,
    super.summary,
    super.storyline,
    super.rating,
    super.ratingCount,
    super.coverUrl,
    super.releaseDate,
    super.screenshots,
    super.artworks,
    super.videos,
    super.genres,
    super.platforms,
    super.gameModes,
    super.themes,
    super.keywords,
    super.playerPerspectives,
    super.involvedCompanies,
    super.gameEngines,
    super.websites,
    super.externalGames,
    super.ageRatings,
    super.multiplayerModes,
    super.languageSupports,
    super.franchises,
    super.collections,
    super.similarGames,
    super.dlcs,
    super.expansions,
    super.alternativeNames,
    super.follows,
    super.hypes,
    super.isWishlisted,
    super.isRecommended,
    super.userRating,
    super.isInTopThree,
    super.topThreePosition,
    super.firstReleaseDate,
    super.status,
    super.releaseDates,
    super.versionTitle,
    super.isBundle,
    super.isExpansion,
    super.isStandalone,
    super.parentGame,
  });

  factory GameModel.fromJson(Map<String, dynamic> json) {
    return GameModel(
      id: _parseId(json['id']),
      name: _parseString(json['name']) ?? 'Unknown Game',
      summary: _parseString(json['summary']),
      storyline: _parseString(json['storyline']),
      rating: _parseDouble(json['total_rating']),
      ratingCount: _parseInt(json['total_rating_count']),
      coverUrl: _extractCoverUrl(json['cover']),
      releaseDate: _parseReleaseDate(json['first_release_date']),
      screenshots: _extractScreenshots(json['screenshots']),
      artworks: _extractArtworks(json['artworks']),
      videos: _extractVideos(json['videos']),
      genres: _extractGenres(json['genres']),
      platforms: _extractPlatforms(json['platforms']),
      gameModes: _extractGameModes(json['game_modes']),
      themes: _extractThemes(json['themes']),
      keywords: _extractKeywords(json['keywords']),
      playerPerspectives: _extractPlayerPerspectives(json['player_perspectives']),
      involvedCompanies: _extractInvolvedCompanies(json['involved_companies']),
      gameEngines: _extractGameEngines(json['game_engines']),
      websites: _extractWebsites(json['websites']),
      externalGames: _extractExternalGames(json['external_games']),
      ageRatings: _extractAgeRatings(json['age_ratings']),
      multiplayerModes: _extractMultiplayerModes(json['multiplayer_modes']),
      languageSupports: _extractLanguageSupports(json['language_supports']),
      franchises: _extractFranchises(json['franchises']),
      collections: _extractCollections(json['collections']),
      similarGames: _extractSimilarGames(json['similar_games']),
      dlcs: _extractDLCs(json['dlcs']),
      expansions: _extractExpansions(json['expansions']),
      alternativeNames: _extractAlternativeNames(json['alternative_names']),
      follows: _parseInt(json['follows']),
      hypes: _parseInt(json['hypes']),
      firstReleaseDate: _parseReleaseDate(json['first_release_date']),
      status: _parseGameStatus(json['status']),
      releaseDates: _extractReleaseDates(json['release_dates']),
      versionTitle: _parseString(json['version_title']),
      isBundle: _parseCategory(json['category']) == 4,
      isExpansion: _parseCategory(json['category']) == 2,
      isStandalone: _parseCategory(json['category']) == 0,
      parentGame: _parseParentGame(json['parent_game']),
    );
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

  static List<GameVideo> _extractVideos(dynamic videos) {
    if (videos == null) return [];
    try {
      final List<GameVideo> videoList = [];
      if (videos is List) {
        for (final v in videos) {
          if (v is Map) {
            final id = _parseId(v['id']);
            final videoId = _parseString(v['video_id']);
            if (id > 0 && videoId != null) {
              videoList.add(GameVideo(
                id: id,
                videoId: videoId,
                title: _parseString(v['name']),
              ));
            }
          }
        }
      }
      return videoList;
    } catch (e) {
      print('⚠️ GameModel: Failed to extract videos: $e');
      return [];
    }
  }

  static List<Website> _extractWebsites(dynamic websites) {
    if (websites == null) return [];
    try {
      final List<Website> websiteList = [];
      if (websites is List) {
        for (final w in websites) {
          if (w is Map) {
            final id = _parseId(w['id']);
            final url = _parseString(w['url']);
            if (id > 0 && url != null) {
              websiteList.add(WebsiteModel.fromJson(w as Map<String, dynamic>));
            }
          }
        }
      }
      return websiteList;
    } catch (e) {
      print('⚠️ GameModel: Failed to extract websites: $e');
      return [];
    }
  }

  static List<AgeRating> _extractAgeRatings(dynamic ageRatings) {
    if (ageRatings == null) return [];
    try {
      final List<AgeRating> ratingList = [];
      if (ageRatings is List) {
        for (final r in ageRatings) {
          if (r is Map) {
            final id = _parseId(r['id']);
            if (id > 0) {
              ratingList.add(AgeRatingModel.fromJson(r as Map<String, dynamic>));
            }
          }
        }
      }
      return ratingList;
    } catch (e) {
      print('⚠️ GameModel: Failed to extract age ratings: $e');
      return [];
    }
  }

  static List<String> _extractAlternativeNames(dynamic altNames) {
    if (altNames == null) return [];
    try {
      final List<String> nameList = [];
      if (altNames is List) {
        for (final name in altNames) {
          if (name is Map && name['name'] != null) {
            nameList.add(name['name'].toString());
          }
        }
      }
      return nameList;
    } catch (e) {
      print('⚠️ GameModel: Failed to extract alternative names: $e');
      return [];
    }
  }

  static String? _parseGameStatus(dynamic status) {
    if (status is int) {
      switch (status) {
        case 0: return 'released';
        case 2: return 'alpha';
        case 3: return 'beta';
        case 4: return 'early_access';
        case 5: return 'offline';
        case 6: return 'cancelled';
        case 7: return 'rumoured';
        case 8: return 'delisted';
        default: return 'unknown';
      }
    }
    return null;
  }

  static int _parseCategory(dynamic category) {
    if (category is int) return category;
    return 0; // Default to main game
  }

  static Game? _parseParentGame(dynamic parentGame) {
    if (parentGame is Map) {
      return GameModel.fromJson(parentGame as Map<String, dynamic>);
    }
    return null;
  }

  static List<Keyword> _extractKeywords(dynamic keywords) {
    if (keywords == null) return [];
    try {
      final List<Keyword> keywordList = [];
      if (keywords is List) {
        for (final k in keywords) {
          if (k is Map) {
            final id = _parseId(k['id']);
            final name = _parseString(k['name']);
            if (id > 0 && name != null) {
              keywordList.add(KeywordModel.fromJson(k as Map<String, dynamic>));
            }
          }
        }
      }
      return keywordList;
    } catch (e) {
      print('⚠️ GameModel: Failed to extract keywords: $e');
      return [];
    }
  }

  static List<PlayerPerspective> _extractPlayerPerspectives(dynamic perspectives) {
    if (perspectives == null) return [];
    try {
      final List<PlayerPerspective> perspectiveList = [];
      if (perspectives is List) {
        for (final p in perspectives) {
          if (p is Map) {
            final id = _parseId(p['id']);
            final name = _parseString(p['name']);
            if (id > 0 && name != null) {
              perspectiveList.add(PlayerPerspectiveModel.fromJson(p as Map<String, dynamic>));
            }
          }
        }
      }
      return perspectiveList;
    } catch (e) {
      print('⚠️ GameModel: Failed to extract player perspectives: $e');
      return [];
    }
  }

  static List<InvolvedCompany> _extractInvolvedCompanies(dynamic companies) {
    if (companies == null) return [];
    try {
      final List<InvolvedCompany> companyList = [];
      if (companies is List) {
        for (final c in companies) {
          if (c is Map) {
            final id = _parseId(c['id']);
            if (id > 0) {
              companyList.add(InvolvedCompanyModel.fromJson(c as Map<String, dynamic>));
            }
          }
        }
      }
      return companyList;
    } catch (e) {
      print('⚠️ GameModel: Failed to extract involved companies: $e');
      return [];
    }
  }

  static List<GameEngine> _extractGameEngines(dynamic engines) {
    if (engines == null) return [];
    try {
      final List<GameEngine> engineList = [];
      if (engines is List) {
        for (final e in engines) {
          if (e is Map) {
            final id = _parseId(e['id']);
            final name = _parseString(e['name']);
            if (id > 0 && name != null) {
              engineList.add(GameEngineModel.fromJson(e as Map<String, dynamic>));
            }
          }
        }
      }
      return engineList;
    } catch (e) {
      print('⚠️ GameModel: Failed to extract game engines: $e');
      return [];
    }
  }

  static List<ExternalGame> _extractExternalGames(dynamic external) {
    if (external == null) return [];
    try {
      final List<ExternalGame> externalList = [];
      if (external is List) {
        for (final e in external) {
          if (e is Map) {
            final id = _parseId(e['id']);
            final uid = _parseString(e['uid']);
            if (id > 0 && uid != null) {
              externalList.add(ExternalGameModel.fromJson(e as Map<String, dynamic>));
            }
          }
        }
      }
      return externalList;
    } catch (e) {
      print('⚠️ GameModel: Failed to extract external games: $e');
      return [];
    }
  }

  static List<MultiplayerMode> _extractMultiplayerModes(dynamic multiplayer) {
    if (multiplayer == null) return [];
    try {
      final List<MultiplayerMode> modeList = [];
      if (multiplayer is List) {
        for (final m in multiplayer) {
          if (m is Map) {
            final id = _parseId(m['id']);
            if (id > 0) {
              modeList.add(MultiplayerModeModel.fromJson(m as Map<String, dynamic>));
            }
          }
        }
      }
      return modeList;
    } catch (e) {
      print('⚠️ GameModel: Failed to extract multiplayer modes: $e');
      return [];
    }
  }

  static List<LanguageSupport> _extractLanguageSupports(dynamic languages) {
    if (languages == null) return [];
    try {
      final List<LanguageSupport> languageList = [];
      if (languages is List) {
        for (final l in languages) {
          if (l is Map) {
            final id = _parseId(l['id']);
            if (id > 0) {
              languageList.add(LanguageSupportModel.fromJson(l as Map<String, dynamic>));
            }
          }
        }
      }
      return languageList;
    } catch (e) {
      print('⚠️ GameModel: Failed to extract language supports: $e');
      return [];
    }
  }

  static List<Franchise> _extractFranchises(dynamic franchises) {
    if (franchises == null) return [];
    try {
      final List<Franchise> franchiseList = [];
      if (franchises is List) {
        for (final f in franchises) {
          if (f is Map) {
            final id = _parseId(f['id']);
            final name = _parseString(f['name']);
            if (id > 0 && name != null) {
              franchiseList.add(FranchiseModel.fromJson(f as Map<String, dynamic>));
            }
          }
        }
      }
      return franchiseList;
    } catch (e) {
      print('⚠️ GameModel: Failed to extract franchises: $e');
      return [];
    }
  }

  static List<Collection> _extractCollections(dynamic collections) {
    if (collections == null) return [];
    try {
      final List<Collection> collectionList = [];
      if (collections is List) {
        for (final c in collections) {
          if (c is Map) {
            final id = _parseId(c['id']);
            final name = _parseString(c['name']);
            if (id > 0 && name != null) {
              collectionList.add(CollectionModel.fromJson(c as Map<String, dynamic>));
            }
          }
        }
      }
      return collectionList;
    } catch (e) {
      print('⚠️ GameModel: Failed to extract collections: $e');
      return [];
    }
  }

  static List<Game> _extractSimilarGames(dynamic similar) {
    if (similar == null) return [];
    try {
      final List<Game> gameList = [];
      if (similar is List) {
        for (final s in similar) {
          if (s is Map) {
            final id = _parseId(s['id']);
            final name = _parseString(s['name']);
            if (id > 0 && name != null) {
              gameList.add(GameModel.fromJson(s as Map<String, dynamic>));
            }
          }
        }
      }
      return gameList;
    } catch (e) {
      print('⚠️ GameModel: Failed to extract similar games: $e');
      return [];
    }
  }

  static List<Game> _extractDLCs(dynamic dlcs) {
    if (dlcs == null) return [];
    try {
      final List<Game> dlcList = [];
      if (dlcs is List) {
        for (final d in dlcs) {
          if (d is Map) {
            final id = _parseId(d['id']);
            final name = _parseString(d['name']);
            if (id > 0 && name != null) {
              dlcList.add(GameModel.fromJson(d as Map<String, dynamic>));
            }
          }
        }
      }
      return dlcList;
    } catch (e) {
      print('⚠️ GameModel: Failed to extract DLCs: $e');
      return [];
    }
  }

  static List<Game> _extractExpansions(dynamic expansions) {
    if (expansions == null) return [];
    try {
      final List<Game> expansionList = [];
      if (expansions is List) {
        for (final e in expansions) {
          if (e is Map) {
            final id = _parseId(e['id']);
            final name = _parseString(e['name']);
            if (id > 0 && name != null) {
              expansionList.add(GameModel.fromJson(e as Map<String, dynamic>));
            }
          }
        }
      }
      return expansionList;
    } catch (e) {
      print('⚠️ GameModel: Failed to extract expansions: $e');
      return [];
    }
  }

  static List<String> _extractReleaseDates(dynamic dates) {
    if (dates == null) return [];
    try {
      final List<String> dateList = [];
      if (dates is List) {
        for (final d in dates) {
          if (d is Map && d['date'] != null) {
            final date = _parseReleaseDate(d['date']);
            final platform = d['platform']?['name'];
            if (date != null) {
              final formatted = platform != null
                  ? '${DateFormatter.formatShortDate(date)} ($platform)'
                  : DateFormatter.formatShortDate(date);
              dateList.add(formatted);
            }
          }
        }
      }
      return dateList;
    } catch (e) {
      print('⚠️ GameModel: Failed to extract release dates: $e');
      return [];
    }
  }

  static List<String> _extractScreenshots(dynamic screenshots) {
    return _extractImageUrls(screenshots);
  }

  static List<String> _extractArtworks(dynamic artworks) {
    return _extractImageUrls(artworks);
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