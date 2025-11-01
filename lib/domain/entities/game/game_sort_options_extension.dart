// lib/domain/entities/game/game_sort_options_extension.dart
// ============================================================
// Extension for GameSortBy enum to provide IGDB field names
// ============================================================

import 'game_sort_options.dart';

/// Extension on GameSortBy to provide IGDB API field names
extension GameSortByExtension on GameSortBy {
  /// Returns the IGDB API field name for this sort option
  String get igdbField {
    switch (this) {
      case GameSortBy.popularity:
        return 'hypes';
      case GameSortBy.rating:
        return 'total_rating';
      case GameSortBy.releaseDate:
        return 'first_release_date';
      case GameSortBy.name:
        return 'name';
      case GameSortBy.ratingCount:
        return 'total_rating_count';
      case GameSortBy.relevance:
        return 'relevance';
      case GameSortBy.aggregatedRating:
        return 'aggregated_rating';
    }
  }

  /// Returns a human-readable description of this sort option
  String get displayName {
    switch (this) {
      case GameSortBy.popularity:
        return 'Most Popular';
      case GameSortBy.rating:
        return 'Highest Rated';
      case GameSortBy.releaseDate:
        return 'Release Date';
      case GameSortBy.name:
        return 'Name';
      case GameSortBy.ratingCount:
        return 'Most Rated';
      case GameSortBy.relevance:
        return 'Relevance';
      case GameSortBy.aggregatedRating:
        return 'Aggregated Rating';
    }
  }
}

/// Extension on SortOrder for convenience
extension SortOrderExtension on SortOrder {
  /// Returns 'asc' or 'desc' for IGDB API
  String get value {
    switch (this) {
      case SortOrder.ascending:
        return 'asc';
      case SortOrder.descending:
        return 'desc';
    }
  }

  /// Returns the opposite sort order
  SortOrder get opposite {
    switch (this) {
      case SortOrder.ascending:
        return SortOrder.descending;
      case SortOrder.descending:
        return SortOrder.ascending;
    }
  }

  /// Returns a human-readable name
  String get displayName {
    switch (this) {
      case SortOrder.ascending:
        return 'Ascending';
      case SortOrder.descending:
        return 'Descending';
    }
  }
}
