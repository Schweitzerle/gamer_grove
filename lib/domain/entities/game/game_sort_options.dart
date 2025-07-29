// ==========================================
// SEARCH & FILTERING ENUMS FOR PHASE 2
// ==========================================

// lib/domain/entities/game/game_sort_options.dart
enum GameSortBy {
  relevance('relevance'),
  name('name'),
  rating('total_rating'),
  ratingCount('total_rating_count'),
  releaseDate('first_release_date'),
  popularity('hypes'),
  aggregatedRating('aggregated_rating'),
  userRating('rating'),
  addedDate('created_at'),
  lastPlayed('last_played'), // for user collections
  userRatingDate('user_rating_date'); // for user collections

  const GameSortBy(this.igdbField);
  final String igdbField;

  String get displayName {
    switch (this) {
      case relevance: return 'Relevance';
      case name: return 'Name';
      case rating: return 'Rating';
      case ratingCount: return 'Rating Count';
      case releaseDate: return 'Release Date';
      case popularity: return 'Popularity';
      case aggregatedRating: return 'Critic Rating';
      case userRating: return 'User Rating';
      case addedDate: return 'Date Added';
      case lastPlayed: return 'Last Played';
      case userRatingDate: return 'Date Rated';
    }
  }
}

enum SortOrder {
  ascending('asc'),
  descending('desc');

  const SortOrder(this.value);
  final String value;

  String get displayName {
    switch (this) {
      case ascending: return 'Ascending';
      case descending: return 'Descending';
    }
  }
}

