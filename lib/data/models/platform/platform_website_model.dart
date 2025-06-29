// ===== UPDATED GAME ENTITY =====
// File: lib/domain/entities/game/game.dart
// Add these fields to existing Game entity:

import 'package:equatable/equatable.dart';
import 'game_status.dart';
import 'game_type.dart';
import 'game_time_to_beat.dart';

class Game extends Equatable {
  // ... existing fields ...

  // NEW FIELDS TO ADD:

  // Status and Type References
  final int? gameStatusId;
  final int? gameTypeId;
  final GameStatus? gameStatus;
  final GameType? gameType;

  // Time to Beat
  final GameTimeToBeat? timeToBeat;

  // Version Information (for DLCs, expansions, etc.)
  final String? versionTitle;
  final int? versionParentId;
  final Game? versionParent;

  // Popularity Metrics
  final int? hypes;
  final int? follows;

  // Tags (combination of all tag numbers)
  final List<int> tags;

  // Related Games Lists (these should already exist but ensure they're included)
  final List<Game> dlcs;
  final List<Game> expansions;
  final List<Game> standaloneExpansions;
  final List<Game> remakes;
  final List<Game> remasters;
  final List<Game> ports;
  final List<Game> bundles;
  final List<Game> similarGames;
  final List<Game> expandedGames;
  final List<Game> forks;

  // Game Localizations
  final List<GameLocalization> gameLocalizations;

  // Parent/Child Relationships
  final Game? parentGame;
  final List<Game> childGames; // All versions of this game

  const Game({
    // ... existing parameters ...

    // Add these parameters:
    this.gameStatusId,
    this.gameTypeId,
    this.gameStatus,
    this.gameType,
    this.timeToBeat,
    this.versionTitle,
    this.versionParentId,
    this.versionParent,
    this.hypes,
    this.follows,
    this.tags = const [],
    this.dlcs = const [],
    this.expansions = const [],
    this.standaloneExpansions = const [],
    this.remakes = const [],
    this.remasters = const [],
    this.ports = const [],
    this.bundles = const [],
    this.similarGames = const [],
    this.expandedGames = const [],
    this.forks = const [],
    this.gameLocalizations = const [],
    this.parentGame,
    this.childGames = const [],
  });

  // Helper getters
  bool get isMainGame => gameType?.id == 0 || gameTypeId == 0;
  bool get isDLC => gameType?.id == 1 || gameTypeId == 1;
  bool get isExpansion => gameType?.id == 2 || gameTypeId == 2;
  bool get isBundle => gameType?.id == 3 || gameTypeId == 3;
  bool get isStandaloneExpansion => gameType?.id == 4 || gameTypeId == 4;
  bool get isMod => gameType?.id == 5 || gameTypeId == 5;
  bool get isEpisode => gameType?.id == 6 || gameTypeId == 6;
  bool get isSeason => gameType?.id == 7 || gameTypeId == 7;
  bool get isRemake => gameType?.id == 8 || gameTypeId == 8;
  bool get isRemaster => gameType?.id == 9 || gameTypeId == 9;

  bool get isReleased => gameStatus?.id == 0 || gameStatusId == 0;
  bool get isAlpha => gameStatus?.id == 2 || gameStatusId == 2;
  bool get isBeta => gameStatus?.id == 3 || gameStatusId == 3;
  bool get isEarlyAccess => gameStatus?.id == 4 || gameStatusId == 4;
  bool get isCancelled => gameStatus?.id == 6 || gameStatusId == 6;
  bool get isRumored => gameStatus?.id == 7 || gameStatusId == 7;

  // Time to beat helpers
  String? get averageTimeToBeat => timeToBeat?.normallyFormatted;
  String? get quickestTimeToBeat => timeToBeat?.hastilyFormatted;
  String? get completionistTimeToBeat => timeToBeat?.completelyFormatted;

  @override
  List<Object?> get props => [
    // ... existing props ...
    gameStatusId,
    gameTypeId,
    gameStatus,
    gameType,
    timeToBeat,
    versionTitle,
    versionParentId,
    versionParent,
    hypes,
    follows,
    tags,
    dlcs,
    expansions,
    standaloneExpansions,
    remakes,
    remasters,
    ports,
    bundles,
    similarGames,
    expandedGames,
    forks,
    gameLocalizations,
    parentGame,
    childGames,
  ];
}

// ===== UPDATED GAME MODEL PARSING =====
// File: lib/data/models/game/game_model.dart
// Add these parsing methods to GameModel:

class GameModel extends Game {
  // ... existing code ...

  // Add to fromJson factory:
  factory GameModel.fromJson(Map<String, dynamic> json) {
    return GameModel(
      // ... existing parsing ...

      // Parse new fields:
      gameStatusId: json['game_status'] is int ? json['game_status'] : null,
      gameTypeId: json['game_type'] is int ? json['game_type'] : null,
      gameStatus: _parseGameStatus(json['game_status']),
      gameType: _parseGameType(json['game_type']),
      timeToBeat: _parseTimeToBeat(json['time_to_beat']),
      versionTitle: json['version_title'],
      versionParentId: json['version_parent'] is int ? json['version_parent'] : null,
      versionParent: _parseVersionParent(json['version_parent']),
      hypes: json['hypes'],
      follows: json['follows'],
      tags: _parseTags(json['tags']),
      dlcs: _parseRelatedGames(json['dlcs']),
      expansions: _parseRelatedGames(json['expansions']),
      standaloneExpansions: _parseRelatedGames(json['standalone_expansions']),
      remakes: _parseRelatedGames(json['remakes']),
      remasters: _parseRelatedGames(json['remasters']),
      ports: _parseRelatedGames(json['ports']),
      bundles: _parseRelatedGames(json['bundles']),
      similarGames: _parseRelatedGames(json['similar_games']),
      expandedGames: _parseRelatedGames(json['expanded_games']),
      forks: _parseRelatedGames(json['forks']),
      gameLocalizations: _parseGameLocalizations(json['game_localizations']),
      parentGame: _parseParentGame(json['parent_game']),
      childGames: _parseRelatedGames(json['child_games']),
    );
  }

  // New parsing methods:

  static GameStatus? _parseGameStatus(dynamic data) {
    if (data is Map<String, dynamic>) {
      return GameStatusModel.fromJson(data);
    } else if (data is int) {
      return GameStatusModel.fromEnum(GameStatusEnum.fromValue(data));
    }
    return null;
  }

  static GameType? _parseGameType(dynamic data) {
    if (data is Map<String, dynamic>) {
      return GameTypeModel.fromJson(data);
    } else if (data is int) {
      return GameTypeModel.fromCategory(GameCategoryEnum.fromValue(data));
    }
    return null;
  }

  static GameTimeToBeat? _parseTimeToBeat(dynamic data) {
    if (data is Map<String, dynamic>) {
      return GameTimeToBeatModel.fromJson(data);
    }
    return null;
  }

  static Game? _parseVersionParent(dynamic data) {
    if (data is Map<String, dynamic>) {
      return GameModel.fromJson(data);
    }
    return null;
  }

  static List<int> _parseTags(dynamic data) {
    if (data is List) {
      return data.where((tag) => tag is int).cast<int>().toList();
    }
    return [];
  }

  static List<Game> _parseRelatedGames(dynamic data) {
    if (data is List) {
      return data
          .where((item) => item is Map)
          .map((item) => GameModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  static List<GameLocalization> _parseGameLocalizations(dynamic data) {
    if (data is List) {
      return data
          .where((item) => item is Map)
          .map((item) => GameLocalizationModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  static Game? _parseParentGame(dynamic data) {
    if (data is Map<String, dynamic>) {
      return GameModel.fromJson(data);
    }
    return null;
  }
}