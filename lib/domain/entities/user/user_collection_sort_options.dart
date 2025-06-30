// ==========================================
// USER COLLECTION ENUMS & TYPES FOR PHASE 3
// ==========================================

// lib/domain/entities/user/user_collection_sort_options.dart
enum UserCollectionSortBy {
  name('name'),
  rating('user_rating'),
  releaseDate('first_release_date'),
  dateAdded('date_added'),
  lastPlayed('last_played'),
  gameRating('total_rating'), // Game's overall rating, not user rating
  dateRated('date_rated'),
  alphabetical('name'),
  popularity('hypes'),
  recentlyAdded('created_at');

  const UserCollectionSortBy(this.field);
  final String field;

  String get displayName {
    switch (this) {
      case name: return 'Name';
      case rating: return 'My Rating';
      case releaseDate: return 'Release Date';
      case dateAdded: return 'Date Added';
      case lastPlayed: return 'Last Played';
      case gameRating: return 'Game Rating';
      case dateRated: return 'Date Rated';
      case alphabetical: return 'Alphabetical';
      case popularity: return 'Popularity';
      case recentlyAdded: return 'Recently Added';
    }
  }

  // Different sort options available for different collection types
  static List<UserCollectionSortBy> get wishlistSortOptions => [
    name,
    dateAdded,
    releaseDate,
    gameRating,
    popularity,
  ];

  static List<UserCollectionSortBy> get ratedSortOptions => [
    name,
    rating,
    dateRated,
    releaseDate,
    gameRating,
  ];

  static List<UserCollectionSortBy> get recommendedSortOptions => [
    name,
    dateAdded,
    releaseDate,
    gameRating,
    popularity,
  ];
}

// lib/domain/entities/user/user_collection_type.dart
enum UserCollectionType {
  wishlist('wishlist'),
  rated('rated'),
  recommended('recommended'),
  topThree('top_three');

  const UserCollectionType(this.value);
  final String value;

  String get displayName {
    switch (this) {
      case wishlist: return 'Wishlist';
      case rated: return 'Rated Games';
      case recommended: return 'Recommended';
      case topThree: return 'Top Three';
    }
  }

  String get icon {
    switch (this) {
      case wishlist: return '❤️';
      case rated: return '⭐';
      case recommended: return '👍';
      case topThree: return '🏆';
    }
  }
}

