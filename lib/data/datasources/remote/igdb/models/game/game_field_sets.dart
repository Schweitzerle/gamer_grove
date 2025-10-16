// lib/data/datasources/remote/igdb/models/game/game_field_sets.dart

/// Pre-defined field sets for game queries.
///
/// These field sets are optimized for different use cases to reduce
/// data transfer and improve performance.
class GameFieldSets {
  GameFieldSets._(); // Private constructor to prevent instantiation

  /// Minimal fields for autocomplete/dropdowns
  /// ~0.5KB per game
  static const List<String> minimal = [
    'id',
    'name',
    'slug',
  ];

  /// Basic fields for game lists
  /// ~2KB per game
  static const List<String> basic = [
    'id',
    'name',
    'slug',
    'first_release_date',
    'cover.url',
    'cover.image_id',
    'total_rating',
    'aggregated_rating',
  ];

  /// Standard fields for most views
  /// ~5KB per game
  static const List<String> standard = [
    'id',
    'name',
    'slug',
    'summary',
    'first_release_date',
    'category',
    'status',
    // Cover
    'cover.id',
    'cover.url',
    'cover.image_id',
    'cover.width',
    'cover.height',
    // Ratings
    'total_rating',
    'total_rating_count',
    'aggregated_rating',
    'aggregated_rating_count',
    // Popularity
    'follows',
    'hypes',
    // Metadata
    'genres.id',
    'genres.name',
    'genres.slug',
    'platforms.id',
    'platforms.name',
    'platforms.abbreviation',
    'platforms.platform_logo.url',
    'platforms.platform_logo.image_id',
    // Companies
    'involved_companies.company.id',
    'involved_companies.company.name',
    'involved_companies.company.logo.url',
    'involved_companies.developer',
    'involved_companies.publisher',
  ];

  /// Fields for game detail pages
  /// ~15KB per game
  static const List<String> complete = [
    '*',
    // Cover
    'cover.*',
    // Artworks
    'artworks.id',
    'artworks.url',
    'artworks.image_id',
    'artworks.width',
    'artworks.height',
    // Screenshots
    'screenshots.id',
    'screenshots.url',
    'screenshots.image_id',
    'screenshots.width',
    'screenshots.height',
    // Videos
    'videos.id',
    'videos.video_id',
    'videos.name',
    // Age Ratings
    'age_ratings.id',
    'age_ratings.category',
    'age_ratings.rating',
    'age_ratings.synopsis',
    // Metadata
    'genres.*',
    'themes.*',
    'game_modes.*',
    'player_perspectives.*',
    'keywords.*',
    // Platforms
    'platforms.id',
    'platforms.name',
    'platforms.abbreviation',
    'platforms.platform_logo.*',
    // Release Dates
    'release_dates.id',
    'release_dates.date',
    'release_dates.human',
    'release_dates.region',
    'release_dates.platform.id',
    'release_dates.platform.name',
    // Companies
    'involved_companies.company.id',
    'involved_companies.company.name',
    'involved_companies.company.logo.*',
    'involved_companies.developer',
    'involved_companies.publisher',
    'involved_companies.porting',
    'involved_companies.supporting',
    // Related Games
    'dlcs.id',
    'dlcs.name',
    'dlcs.cover.url',
    'expansions.id',
    'expansions.name',
    'expansions.cover.url',
    'similar_games.id',
    'similar_games.name',
    'similar_games.cover.url',
    'similar_games.total_rating',
    // Collections & Franchises
    'franchises.id',
    'franchises.name',
    'franchises.slug',
    'collection.id',
    'collection.name',
    'collection.slug',
    // Websites
    'websites.id',
    'websites.url',
    'websites.category',
  ];

  /// Fields optimized for search results
  /// ~3KB per game
  static const List<String> search = [
    'id',
    'name',
    'slug',
    'summary',
    'first_release_date',
    'cover.url',
    'cover.image_id',
    'total_rating',
    'total_rating_count',
    'genres.name',
    'platforms.abbreviation',
  ];

  /// Fields for platform-specific game lists
  /// ~4KB per game
  static const List<String> platformGames = [
    'id',
    'name',
    'slug',
    'summary',
    'first_release_date',
    'category',
    'cover.url',
    'cover.image_id',
    'total_rating',
    'aggregated_rating',
    'genres.id',
    'genres.name',
    'release_dates.date',
    'release_dates.region',
    'release_dates.platform.id',
  ];

  /// Fields for company-specific game lists
  /// ~4KB per game
  static const List<String> companyGames = [
    'id',
    'name',
    'slug',
    'summary',
    'first_release_date',
    'category',
    'cover.url',
    'cover.image_id',
    'total_rating',
    'genres.name',
    'involved_companies.developer',
    'involved_companies.publisher',
  ];

  /// Fields for character-specific game lists
  /// ~3KB per game
  static const List<String> characterGames = [
    'id',
    'name',
    'slug',
    'first_release_date',
    'cover.url',
    'cover.image_id',
    'total_rating',
    'genres.name',
  ];

  /// Fields for franchise/collection views
  /// ~4KB per game
  static const List<String> franchiseGames = [
    'id',
    'name',
    'slug',
    'summary',
    'first_release_date',
    'category',
    'cover.url',
    'cover.image_id',
    'total_rating',
    'genres.name',
    'platforms.abbreviation',
  ];
}
