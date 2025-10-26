// lib/domain/entities/search/search_filters.dart
import 'package:equatable/equatable.dart';
import '../game/game_sort_options.dart';

class SearchFilters extends Equatable {
  // ============================================================
  // BASIC FILTERS
  // ============================================================
  final List<int> genreIds;
  final List<int> platformIds;
  final DateTime? releaseDateFrom;
  final DateTime? releaseDateTo;

  // ============================================================
  // RATING FILTERS
  // ============================================================
  // Total Rating (combined user + critic)
  final double? minTotalRating;
  final double? maxTotalRating;
  final int? minTotalRatingCount;

  // IGDB User Rating
  final double? minUserRating;
  final double? maxUserRating;
  final int? minUserRatingCount;

  // Aggregated Critic Rating
  final double? minAggregatedRating;
  final double? maxAggregatedRating;
  final int? minAggregatedRatingCount;

  // ============================================================
  // GAME TYPE & STATUS FILTERS
  // ============================================================
  final List<int> gameTypeIds; // Main game, DLC, Expansion, etc.
  final List<int> gameStatusIds; // Released, Alpha, Beta, etc.

  // ============================================================
  // MULTIPLAYER & MODES FILTERS
  // ============================================================
  final List<int> themesIds;
  final List<int> gameModesIds;
  final List<int> playerPerspectiveIds;
  final List<int> multiplayerModeIds; // Online, Splitscreen, Co-op, etc.
  final bool? hasMultiplayer;
  final bool? hasSinglePlayer;

  // ============================================================
  // POPULARITY & HYPE FILTERS
  // ============================================================
  final int? minFollows; // User follows count
  final int? minHypes; // For unreleased games

  // ============================================================
  // AGE RATING & LOCALIZATION FILTERS
  // ============================================================
  final List<int> ageRatingIds; // PEGI, ESRB ratings
  final List<int> languageSupportIds; // Supported languages

  // ============================================================
  // DYNAMIC SEARCH FILTERS
  // ============================================================
  final List<int> companyIds; // Developer/Publisher
  final List<int> gameEngineIds;
  final List<int> franchiseIds;
  final List<int> collectionIds;
  final List<int> keywordIds; // Keywords

  // ============================================================
  // SORTING
  // ============================================================
  final GameSortBy sortBy;
  final SortOrder sortOrder;

  const SearchFilters({
    // Basic
    this.genreIds = const [],
    this.platformIds = const [],
    this.releaseDateFrom,
    this.releaseDateTo,

    // Ratings
    this.minTotalRating,
    this.maxTotalRating,
    this.minTotalRatingCount,
    this.minUserRating,
    this.maxUserRating,
    this.minUserRatingCount,
    this.minAggregatedRating,
    this.maxAggregatedRating,
    this.minAggregatedRatingCount,

    // Game Type & Status
    this.gameTypeIds = const [],
    this.gameStatusIds = const [],

    // Multiplayer & Modes
    this.themesIds = const [],
    this.gameModesIds = const [],
    this.playerPerspectiveIds = const [],
    this.multiplayerModeIds = const [],
    this.hasMultiplayer,
    this.hasSinglePlayer,

    // Popularity
    this.minFollows,
    this.minHypes,

    // Age Rating & Localization
    this.ageRatingIds = const [],
    this.languageSupportIds = const [],

    // Dynamic Search
    this.companyIds = const [],
    this.gameEngineIds = const [],
    this.franchiseIds = const [],
    this.collectionIds = const [],
    this.keywordIds = const [],

    // Sorting
    this.sortBy = GameSortBy.relevance,
    this.sortOrder = SortOrder.descending,
  });

  bool get hasFilters =>
      genreIds.isNotEmpty ||
      platformIds.isNotEmpty ||
      gameTypeIds.isNotEmpty ||
      gameStatusIds.isNotEmpty ||
      minTotalRating != null ||
      maxTotalRating != null ||
      minTotalRatingCount != null ||
      minUserRating != null ||
      maxUserRating != null ||
      minUserRatingCount != null ||
      minAggregatedRating != null ||
      maxAggregatedRating != null ||
      minAggregatedRatingCount != null ||
      releaseDateFrom != null ||
      releaseDateTo != null ||
      themesIds.isNotEmpty ||
      gameModesIds.isNotEmpty ||
      playerPerspectiveIds.isNotEmpty ||
      multiplayerModeIds.isNotEmpty ||
      hasMultiplayer != null ||
      hasSinglePlayer != null ||
      minFollows != null ||
      minHypes != null ||
      ageRatingIds.isNotEmpty ||
      languageSupportIds.isNotEmpty ||
      companyIds.isNotEmpty ||
      gameEngineIds.isNotEmpty ||
      franchiseIds.isNotEmpty ||
      collectionIds.isNotEmpty ||
      keywordIds.isNotEmpty;

  bool get hasGenreFilter => genreIds.isNotEmpty;
  bool get hasPlatformFilter => platformIds.isNotEmpty;
  bool get hasRatingFilter =>
      minTotalRating != null ||
      maxTotalRating != null ||
      minUserRating != null ||
      maxUserRating != null ||
      minAggregatedRating != null ||
      maxAggregatedRating != null;
  bool get hasDateFilter => releaseDateFrom != null || releaseDateTo != null;

  SearchFilters copyWith({
    List<int>? genreIds,
    List<int>? platformIds,
    List<int>? gameTypeIds,
    List<int>? gameStatusIds,
    double? minTotalRating,
    double? maxTotalRating,
    int? minTotalRatingCount,
    double? minUserRating,
    double? maxUserRating,
    int? minUserRatingCount,
    double? minAggregatedRating,
    double? maxAggregatedRating,
    int? minAggregatedRatingCount,
    DateTime? releaseDateFrom,
    DateTime? releaseDateTo,
    List<int>? themesIds,
    List<int>? gameModesIds,
    List<int>? playerPerspectiveIds,
    List<int>? multiplayerModeIds,
    bool? hasMultiplayer,
    bool? hasSinglePlayer,
    int? minFollows,
    int? minHypes,
    List<int>? ageRatingIds,
    List<int>? languageIds,
    List<int>? companyIds,
    List<int>? gameEngineIds,
    List<int>? franchiseIds,
    List<int>? collectionIds,
    List<int>? keywordIds,
    GameSortBy? sortBy,
    SortOrder? sortOrder,
  }) {
    return SearchFilters(
      genreIds: genreIds ?? this.genreIds,
      platformIds: platformIds ?? this.platformIds,
      gameTypeIds: gameTypeIds ?? this.gameTypeIds,
      gameStatusIds: gameStatusIds ?? this.gameStatusIds,
      minTotalRating: minTotalRating ?? this.minTotalRating,
      maxTotalRating: maxTotalRating ?? this.maxTotalRating,
      minTotalRatingCount: minTotalRatingCount ?? this.minTotalRatingCount,
      minUserRating: minUserRating ?? this.minUserRating,
      maxUserRating: maxUserRating ?? this.maxUserRating,
      minUserRatingCount: minUserRatingCount ?? this.minUserRatingCount,
      minAggregatedRating: minAggregatedRating ?? this.minAggregatedRating,
      maxAggregatedRating: maxAggregatedRating ?? this.maxAggregatedRating,
      minAggregatedRatingCount:
          minAggregatedRatingCount ?? this.minAggregatedRatingCount,
      releaseDateFrom: releaseDateFrom ?? this.releaseDateFrom,
      releaseDateTo: releaseDateTo ?? this.releaseDateTo,
      themesIds: themesIds ?? this.themesIds,
      gameModesIds: gameModesIds ?? this.gameModesIds,
      playerPerspectiveIds: playerPerspectiveIds ?? this.playerPerspectiveIds,
      multiplayerModeIds: multiplayerModeIds ?? this.multiplayerModeIds,
      hasMultiplayer: hasMultiplayer ?? this.hasMultiplayer,
      hasSinglePlayer: hasSinglePlayer ?? this.hasSinglePlayer,
      minFollows: minFollows ?? this.minFollows,
      minHypes: minHypes ?? this.minHypes,
      ageRatingIds: ageRatingIds ?? this.ageRatingIds,
      languageSupportIds: languageIds ?? this.languageSupportIds,
      companyIds: companyIds ?? this.companyIds,
      gameEngineIds: gameEngineIds ?? this.gameEngineIds,
      franchiseIds: franchiseIds ?? this.franchiseIds,
      collectionIds: collectionIds ?? this.collectionIds,
      keywordIds: keywordIds ?? this.keywordIds,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  SearchFilters clearFilters() {
    return const SearchFilters();
  }

  @override
  List<Object?> get props => [
        genreIds,
        platformIds,
        gameTypeIds,
        gameStatusIds,
        minTotalRating,
        maxTotalRating,
        minTotalRatingCount,
        minUserRating,
        maxUserRating,
        minUserRatingCount,
        minAggregatedRating,
        maxAggregatedRating,
        minAggregatedRatingCount,
        releaseDateFrom,
        releaseDateTo,
        themesIds,
        gameModesIds,
        playerPerspectiveIds,
        multiplayerModeIds,
        hasMultiplayer,
        hasSinglePlayer,
        minFollows,
        minHypes,
        ageRatingIds,
        languageSupportIds,
        companyIds,
        gameEngineIds,
        franchiseIds,
        collectionIds,
        keywordIds,
        sortBy,
        sortOrder,
      ];
}
