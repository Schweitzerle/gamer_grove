
import 'package:flutter/material.dart';
import 'package:gamer_grove/model/igdb_models/age_rating.dart';
import 'package:gamer_grove/model/igdb_models/alternative_name.dart';
import 'package:gamer_grove/model/igdb_models/artwork.dart';
import 'package:gamer_grove/model/igdb_models/collection.dart';
import 'package:gamer_grove/model/igdb_models/cover.dart';
import 'package:gamer_grove/model/igdb_models/external_game.dart';
import 'package:gamer_grove/model/igdb_models/franchise.dart';
import 'package:gamer_grove/model/igdb_models/game_engine.dart';
import 'package:gamer_grove/model/igdb_models/game_localization.dart';
import 'package:gamer_grove/model/igdb_models/game_mode.dart';
import 'package:gamer_grove/model/igdb_models/game_video.dart';
import 'package:gamer_grove/model/igdb_models/genre.dart';
import 'package:gamer_grove/model/igdb_models/involved_companies.dart';
import 'package:gamer_grove/model/igdb_models/keyword.dart';
import 'package:gamer_grove/model/igdb_models/language_support.dart';
import 'package:gamer_grove/model/igdb_models/multiplayer_mode.dart';
import 'package:gamer_grove/model/igdb_models/platform.dart';
import 'package:gamer_grove/model/igdb_models/player_perspectiverequest_path.dart';
import 'package:gamer_grove/model/igdb_models/release_date.dart';
import 'package:gamer_grove/model/igdb_models/screenshot.dart';
import 'package:gamer_grove/model/igdb_models/theme.dart';
import 'package:gamer_grove/model/igdb_models/website.dart';

class Game {
  int id;
  List<AgeRating>? ageRatings;
  double? aggregatedRating;
  int? aggregatedRatingCount;
  List<AlternativeName>? alternativeNames;
  List<Artwork>? artworks;
  List<Game>? bundles;
  String? category;
  Collection? collection;
  List<Collection>? collections;
  Cover? cover;
  List<Game>? dlcs;
  List<Game>? expandedGames;
  List<Game>? expansions;
  List<ExternalGame>? externalGames;
  int? firstReleaseDate;
  int? follows;
  List<Game>? forks;
  Franchise? franchise;
  List<Franchise>? franchises;
  List<GameEngine>? gameEngines;
  List<GameLocalization>? gameLocalizations;
  List<GameMode>? gameModes;
  List<Genre>? genres;
  int? hypes;
  List<InvolvedCompany>? involvedCompanies;
  List<Keyword>? keywords;
  List<LanguageSupport>? languageSupports;
  List<MultiplayerMode>? multiplayerModes;
  String? name;
  Game? parentGame;
  List<PlatformIGDB>? platforms;
  List<PlayerPerspective>? playerPerspectives;
  List<Game>? ports;
  double? rating;
  int? ratingCount;
  List<ReleaseDate>? releaseDates;
  List<Game>? remakes;
  List<Game>? remasters;
  List<Screenshot>? screenshots;
  List<Game>? similarGames;
  String? slug;
  List<Game>? standaloneExpansions;
  String? status;
  String? storyline;
  String? summary;
  List<String>? tags;
  List<ThemeIDGB>? themes;
  double? totalRating;
  int? totalRatingCount;
  int? updatedAt;
  String? url;
  Game? versionParent;
  String? versionTitle;
  List<GameVideo>? videos;
  List<Website>? websites;

  Game({
    required this.id,
    this.ageRatings,
    this.aggregatedRating,
    this.aggregatedRatingCount,
    this.alternativeNames,
    this.artworks,
    this.bundles,
    this.category,
    this.collection,
    this.collections,
    this.cover,
    this.dlcs,
    this.expandedGames,
    this.expansions,
    this.externalGames,
    this.firstReleaseDate,
    this.follows,
    this.forks,
    this.franchise,
    this.franchises,
    this.gameEngines,
    this.gameLocalizations,
    this.gameModes,
    this.genres,
    this.hypes,
    this.involvedCompanies,
    this.keywords,
    this.languageSupports,
    this.multiplayerModes,
    this.name,
    this.parentGame,
    this.platforms,
    this.playerPerspectives,
    this.ports,
    this.rating,
    this.ratingCount,
    this.releaseDates,
    this.remakes,
    this.remasters,
    this.screenshots,
    this.similarGames,
    this.slug,
    this.standaloneExpansions,
    this.status,
    this.storyline,
    this.summary,
    this.tags,
    this.themes,
    this.totalRating,
    this.totalRatingCount,
    this.updatedAt,
    this.url,
    this.versionParent,
    this.versionTitle,
    this.videos,
    this.websites,
  });

  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      id: json['id'],
      ageRatings: json['age_ratings'] != null
          ? List<AgeRating>.from(
        json['age_ratings'].map((ageRating) {
          if (ageRating is int) {
            return AgeRating(id: ageRating);
          } else {
            return AgeRating.fromJson(ageRating);
          }
        }),
      )
          : null,
      aggregatedRating: json['aggregated_rating']?.toDouble(),
      aggregatedRatingCount: json['aggregated_rating_count'],
      alternativeNames: json['alternative_names'] != null
          ? List<AlternativeName>.from(
        json['alternative_names'].map((alternativeName) {
          if (alternativeName is int) {
            return AlternativeName(id: alternativeName);
          } else {
            return AlternativeName.fromJson(alternativeName);
          }
        }),
      )
          : null,
      artworks: json['artworks'] != null
          ? List<Artwork>.from(
        json['artworks'].map((artwork) {
          if (artwork is int) {
            return Artwork(id: artwork);
          } else {
            return Artwork.fromJson(artwork);
          }
        }),
      )
          : null,
      bundles: json['bundles'] != null
          ? List<Game>.from(
        json['bundles'].map((dlc) {
          if (dlc is int) {
            return Game(id: dlc);
          } else {
            return Game.fromJson(dlc);
          }
        }),
      )
          : null,
      category: json['category'] != null
          ? CategoryEnumExtension.fromValue(json['category']).stringValue
          : null,
      collection: json['collection'] != null
          ? (json['collection'] is int
          ? Collection(id: json['collection'])
          : Collection.fromJson(json['collection']))
          : null,
      collections: json['collections'] != null
          ? List<Collection>.from(
        json['collections'].map((collection) {
          if (collection is int) {
            return Collection(id: collection);
          } else {
            return Collection.fromJson(collection);
          }
        }),
      )
          : null,
      cover: json['cover'] != null
          ? (json['cover'] is int
          ? Cover(id: json['cover'])
          : Cover.fromJson(json['cover']))
          : null,
      dlcs: json['dlcs'] != null
          ? List<Game>.from(
        json['dlcs'].map((collection) {
          if (collection is int) {
            return Game(id: collection);
          } else {
            return Game.fromJson(collection);
          }
        }),
      )
          : null,
      expandedGames: json['expanded_games'] != null
          ? List<Game>.from(
        json['expanded_games'].map((collection) {
          if (collection is int) {
            return Game(id: collection);
          } else {
            return Game.fromJson(collection);
          }
        }),
      )
          : null,
      expansions: json['expansions'] != null
          ? List<Game>.from(
        json['expansions'].map((collection) {
          if (collection is int) {
            return Game(id: collection);
          } else {
            return Game.fromJson(collection);
          }
        }),
      )
          : null,
      externalGames: json['external_games'] != null
          ? List<ExternalGame>.from(
        json['external_games'].map((collection) {
          if (collection is int) {
            return ExternalGame(id: collection);
          } else {
            return ExternalGame.fromJson(collection);
          }
        }),
      )
          : null,
      firstReleaseDate: json['first_release_date'],
      follows: json['follows'],
      forks: json['forks'] != null
          ? List<Game>.from(
        json['forks'].map((collection) {
          if (collection is int) {
            return Game(id: collection);
          } else {
            return Game.fromJson(collection);
          }
        }),
      )
          : null,
      franchise: json['franchise'] != null
          ? (json['franchise'] is int
          ? Franchise(id: json['franchise'])
          : Franchise.fromJson(json['franchise']))
          : null,
      franchises: json['franchises'] != null
          ? List<Franchise>.from(
        json['franchises'].map((collection) {
          if (collection is int) {
            return Franchise(id: collection);
          } else {
            return Franchise.fromJson(collection);
          }
        }),
      )
          : null,
      gameEngines: json['game_engines'] != null
          ? List<GameEngine>.from(
        json['game_engines'].map((collection) {
          if (collection is int) {
            return GameEngine(id: collection);
          } else {
            return GameEngine.fromJson(collection);
          }
        }),
      )
          : null,
      gameLocalizations: json['game_localizations'] != null
          ? List<GameLocalization>.from(
        json['game_localizations'].map((collection) {
          if (collection is int) {
            return GameLocalization(id: collection);
          } else {
            return GameLocalization.fromJson(collection);
          }
        }),
      )
          : null,
      gameModes: json['game_modes'] != null
          ? List<GameMode>.from(
        json['game_modes'].map((collection) {
          if (collection is int) {
            return GameMode(id: collection);
          } else {
            return GameMode.fromJson(collection);
          }
        }),
      )
          : null,

      genres: json['genres'] != null
          ? List<Genre>.from(
        json['genres'].map((collection) {
          if (collection is int) {
            return Genre(id: collection);
          } else {
            return Genre.fromJson(collection);
          }
        }),
      )
          : null,

      hypes: json['hypes'],
      involvedCompanies: json['involved_companies'] != null
          ? List<InvolvedCompany>.from(
        json['involved_companies'].map((collection) {
          if (collection is int) {
            return InvolvedCompany(id: collection);
          } else {
            return InvolvedCompany.fromJson(collection);
          }
        }),
      )
          : null,
      keywords: json['keywords'] != null
          ? List<Keyword>.from(
        json['keywords'].map((collection) {
          if (collection is int) {
            return Keyword(id: collection);
          } else {
            return Keyword.fromJson(collection);
          }
        }),
      )
          : null,
      languageSupports: json['language_supports'] != null
          ? List<LanguageSupport>.from(
        json['language_supports'].map((collection) {
          if (collection is int) {
            return LanguageSupport(id: collection);
          } else {
            return LanguageSupport.fromJson(collection);
          }
        }),
      )
          : null,
      multiplayerModes: json['multiplayer_modes'] != null
          ? List<MultiplayerMode>.from(
        json['multiplayer_modes'].map((collection) {
          if (collection is int) {
            return MultiplayerMode(id: collection);
          } else {
            return MultiplayerMode.fromJson(collection);
          }
        }),
      )
          : null,
      name: json['name'],
      parentGame: json['parent_game'] != null
          ? (json['parent_game'] is int
          ? Game(id: json['parent_game'])
          : Game.fromJson(json['parent_game']))
          : null,
      platforms: json['platforms'] != null
          ? List<PlatformIGDB>.from(
        json['platforms'].map((collection) {
          if (collection is int) {
            return PlatformIGDB(id: collection);
          } else {
            return PlatformIGDB.fromJson(collection);
          }
        }),
      )
          : null,
      playerPerspectives: json['player_perspectives'] != null
          ? List<PlayerPerspective>.from(
        json['player_perspectives'].map((collection) {
          if (collection is int) {
            return PlayerPerspective(id: collection);
          } else {
            return PlayerPerspective.fromJson(collection);
          }
        }),
      )
          : null,
      ports: json['ports'] != null
          ? List<Game>.from(
        json['ports'].map((collection) {
          if (collection is int) {
            return Game(id: collection);
          } else {
            return Game.fromJson(collection);
          }
        }),
      )
          : null,
      rating: json['rating']?.toDouble(),
      ratingCount: json['rating_count'],
      releaseDates: json['release_dates'] != null
          ? List<ReleaseDate>.from(
        json['release_dates'].map((collection) {
          if (collection is int) {
            return ReleaseDate(id: collection);
          } else {
            return ReleaseDate.fromJson(collection);
          }
        }),
      )
          : null,

      remakes: json['remakes'] != null
          ? List<Game>.from(
        json['remakes'].map((collection) {
          if (collection is int) {
            return Game(id: collection);
          } else {
            return Game.fromJson(collection);
          }
        }),
      )
          : null,
      remasters: json['remasters'] != null
          ? List<Game>.from(
        json['remasters'].map((collection) {
          if (collection is int) {
            return Game(id: collection);
          } else {
            return Game.fromJson(collection);
          }
        }),
      )
          : null,
      screenshots: json['screenshots'] != null
        ? List<Screenshot>.from(
      json['screenshots'].map((collection) {
        if (collection is int) {
          return Screenshot(id: collection);
        } else {
          return Screenshot.fromJson(collection);
        }
      }),
    )
        : null,
      similarGames: json['similar_games'] != null
          ? List<Game>.from(
        json['similar_games'].map((collection) {
          if (collection is int) {
            return Game(id: collection);
          } else {
            return Game.fromJson(collection);
          }
        }),
      )
          : null,
      slug: json['slug'],
      standaloneExpansions: json['standalone_expansions'] != null
          ? List<Game>.from(
        json['standalone_expansions'].map((collection) {
          if (collection is int) {
            return Game(id: collection);
          } else {
            return Game.fromJson(collection);
          }
        }),
      )
          : null,
      status: json['status'] != null
          ? StatusEnumExtension.fromValue(json['status']).stringValue
          : null,
      storyline: json['storyline'],
      summary: json['summary'],
      tags: json['tags'] != null
          ? List<String>.from(
        json['tags'].map((tag) => TagNumbersEnumExtension.fromValue(tag).stringValue),
      )
          : null,
      themes: json['themes'] != null
          ? List<ThemeIDGB>.from(
        json['themes'].map((collection) {
          if (collection is int) {
            return ThemeIDGB(id: collection);
          } else {
            return ThemeIDGB.fromJson(collection);
          }
        }),
      )
          : null,
      totalRating: json['total_rating']?.toDouble(),
      totalRatingCount: json['total_rating_count'],
      updatedAt: json['updated_at'],
      url: json['url'],
      versionParent: json['version_parent'] != null
          ? (json['version_parent'] is int
          ? Game(id: json['version_parent'])
          : Game.fromJson(json['version_parent']))
          : null,
      versionTitle: json['version_title'],
      videos: json['videos'] != null
          ? List<GameVideo>.from(
        json['videos'].map((collection) {
          if (collection is int) {
            return GameVideo(id: collection);
          } else {
            return GameVideo.fromJson(collection);
          }
        }),
      )
          : null,
      websites: json['websites'] != null
          ? List<Website>.from(
        json['websites'].map((collection) {
          if (collection is int) {
            return Website(id: collection);
          } else {
            return Website.fromJson(collection);
          }
        }),
      )
          : null,
    );
  }
}

enum TagNumbersEnum {
  Theme,
  Genre,
  Keyword,
  Game,
  PlayerPerspective,
}

extension TagNumbersEnumExtension on TagNumbersEnum {
  int get value {
    // Ensure that the index is within the valid range (0..31)
    if (this.index < 0 || this.index >= 32) {
      throw ArgumentError('Invalid index for TagNumbersEnum: ${this.index}');
    }
    // Bit-shifting the index by 28 bits
    return this.index << 28;
  }

  String get stringValue {
    return _formatEnumValue(this.toString());
  }

  static TagNumbersEnum fromValue(int value) {
    // Extract the index from the tag number
    int index = value >> 28;

    // Ensure that the extracted index is within the valid range (0..4)
    if (index < 0 || index >= TagNumbersEnum.values.length) {
      throw ArgumentError('Invalid value for TagNumbersEnum: $value');
    }

    return TagNumbersEnum.values[index];
  }
  static String _formatEnumValue(String value) {
    // Convert "mainGame" to "Main Game"
    String formattedValue = value.replaceAllMapped(RegExp(r'[A-Z]'), (match) {
      return ' ${match.group(0)}';
    }).trim();

    // Remove the enum type prefix
    return formattedValue.split('.').last.trim();
  }

}

enum CategoryEnum {
  MainGame,
  dlcAddon,
  expansion,
  bundle,
  standaloneExpansion,
  mod,
  episode,
  season,
  remake,
  remaster,
  expandedGame,
  port,
  fork,
  pack,
  update,
}

extension CategoryEnumExtension on CategoryEnum {
  int get value {
    return index;
  }

  String get stringValue {
    return _formatEnumValue(this.toString());
  }

  static CategoryEnum fromValue(int value) {
    return CategoryEnum.values[value];
  }

  static String _formatEnumValue(String value) {
    // Convert "mainGame" to "Main Game"
    String formattedValue = value.replaceAllMapped(RegExp(r'[A-Z]'), (match) {
      return ' ${match.group(0)}';
    }).trim();

    // Remove the enum type prefix
    return formattedValue.split('.').last.trim();
  }
}

enum StatusEnum {
  released,
  alpha,
  beta,
  earlyAccess,
  offline,
  cancelled,
  rumored,
  delisted,
}

extension StatusEnumExtension on StatusEnum {
  int get value {
    switch (this) {
      case StatusEnum.released:
        return 0;
      case StatusEnum.alpha:
        return 2;
      case StatusEnum.beta:
        return 3;
      case StatusEnum.earlyAccess:
        return 4;
      case StatusEnum.offline:
        return 5;
      case StatusEnum.cancelled:
        return 6;
      case StatusEnum.rumored:
        return 7;
      case StatusEnum.delisted:
        return 8;
    }
  }

  String get stringValue {
    return _formatEnumValue(this.toString());
  }

  static StatusEnum fromValue(int value) {
    switch (value) {
      case 0:
        return StatusEnum.released;
      case 2:
        return StatusEnum.alpha;
      case 3:
        return StatusEnum.beta;
      case 4:
        return StatusEnum.earlyAccess;
      case 5:
        return StatusEnum.offline;
      case 6:
        return StatusEnum.cancelled;
      case 7:
        return StatusEnum.rumored;
      case 8:
        return StatusEnum.delisted;
      default:
        throw ArgumentError('Unknown StatusEnum value: $value');
    }
  }

  static String _formatEnumValue(String value) {
    // Convert "mainGame" to "Main Game"
    String formattedValue = value.replaceAllMapped(RegExp(r'[A-Z]'), (match) {
      return ' ${match.group(0)}';
    }).trim();

    // Remove the enum type prefix
    return formattedValue.split('.').last.trim();
  }
}

