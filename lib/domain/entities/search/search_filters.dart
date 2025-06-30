// lib/domain/entities/search/search_filters.dart
import 'package:equatable/equatable.dart';
import '../game/game_sort_options.dart';

class SearchFilters extends Equatable {
  final List<int> genreIds;
  final List<int> platformIds;
  final List<int> gameTypeIds; // Main game, DLC, Expansion, etc.
  final double? minRating;
  final double? maxRating;
  final DateTime? releaseDateFrom;
  final DateTime? releaseDateTo;
  final List<int> themesIds;
  final List<int> gameModesIds;
  final List<int> playerPerspectiveIds;
  final bool? hasMultiplayer;
  final bool? hasSinglePlayer;
  final GameSortBy sortBy;
  final SortOrder sortOrder;

  const SearchFilters({
    this.genreIds = const [],
    this.platformIds = const [],
    this.gameTypeIds = const [],
    this.minRating,
    this.maxRating,
    this.releaseDateFrom,
    this.releaseDateTo,
    this.themesIds = const [],
    this.gameModesIds = const [],
    this.playerPerspectiveIds = const [],
    this.hasMultiplayer,
    this.hasSinglePlayer,
    this.sortBy = GameSortBy.relevance,
    this.sortOrder = SortOrder.descending,
  });

  // Helper methods
  bool get hasFilters =>
      genreIds.isNotEmpty ||
          platformIds.isNotEmpty ||
          gameTypeIds.isNotEmpty ||
          minRating != null ||
          maxRating != null ||
          releaseDateFrom != null ||
          releaseDateTo != null ||
          themesIds.isNotEmpty ||
          gameModesIds.isNotEmpty ||
          playerPerspectiveIds.isNotEmpty ||
          hasMultiplayer != null ||
          hasSinglePlayer != null;

  bool get hasGenreFilter => genreIds.isNotEmpty;
  bool get hasPlatformFilter => platformIds.isNotEmpty;
  bool get hasRatingFilter => minRating != null || maxRating != null;
  bool get hasDateFilter => releaseDateFrom != null || releaseDateTo != null;

  SearchFilters copyWith({
    List<int>? genreIds,
    List<int>? platformIds,
    List<int>? gameTypeIds,
    double? minRating,
    double? maxRating,
    DateTime? releaseDateFrom,
    DateTime? releaseDateTo,
    List<int>? themesIds,
    List<int>? gameModesIds,
    List<int>? playerPerspectiveIds,
    bool? hasMultiplayer,
    bool? hasSinglePlayer,
    GameSortBy? sortBy,
    SortOrder? sortOrder,
  }) {
    return SearchFilters(
      genreIds: genreIds ?? this.genreIds,
      platformIds: platformIds ?? this.platformIds,
      gameTypeIds: gameTypeIds ?? this.gameTypeIds,
      minRating: minRating ?? this.minRating,
      maxRating: maxRating ?? this.maxRating,
      releaseDateFrom: releaseDateFrom ?? this.releaseDateFrom,
      releaseDateTo: releaseDateTo ?? this.releaseDateTo,
      themesIds: themesIds ?? this.themesIds,
      gameModesIds: gameModesIds ?? this.gameModesIds,
      playerPerspectiveIds: playerPerspectiveIds ?? this.playerPerspectiveIds,
      hasMultiplayer: hasMultiplayer ?? this.hasMultiplayer,
      hasSinglePlayer: hasSinglePlayer ?? this.hasSinglePlayer,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  SearchFilters clearFilters() {
    return const SearchFilters(
      sortBy: GameSortBy.relevance,
      sortOrder: SortOrder.descending,
    );
  }

  @override
  List<Object?> get props => [
    genreIds,
    platformIds,
    gameTypeIds,
    minRating,
    maxRating,
    releaseDateFrom,
    releaseDateTo,
    themesIds,
    gameModesIds,
    playerPerspectiveIds,
    hasMultiplayer,
    hasSinglePlayer,
    sortBy,
    sortOrder,
  ];
}