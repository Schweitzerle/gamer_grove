// lib/data/datasources/remote/igdb/models/igdb_query.dart

import 'package:equatable/equatable.dart';
import 'igdb_filters.dart';

/// Represents a complete IGDB API query with all its components.
///
/// This class encapsulates all parts of an IGDB query:
/// - WHERE clause (filtering)
/// - FIELDS selection
/// - LIMIT and OFFSET (pagination)
/// - SORT ordering
/// - EXCLUDE clause
///
/// Example:
/// ```dart
/// final query = IgdbGameQuery(
///   where: GameFilters.byPlatform(6),
///   fields: ['name', 'cover.url', 'total_rating'],
///   limit: 20,
///   offset: 0,
///   sort: 'total_rating desc',
/// );
///
/// final queryString = query.buildQuery();
/// // Output: "fields name,cover.url,total_rating; where platforms = (6); limit 20; offset 0; sort total_rating desc;"
/// ```
class IgdbGameQuery extends Equatable {
  /// Filter condition for the WHERE clause
  final IgdbFilter? where;

  /// Fields to retrieve. Use '*' for all fields.
  /// For nested fields, use dot notation: 'cover.url'
  final List<String> fields;

  /// Maximum number of results to return
  final int limit;

  /// Number of results to skip (for pagination)
  final int offset;

  /// Sort order. Format: 'field_name asc/desc'
  /// Examples: 'name asc', 'total_rating desc'
  final String? sort;

  /// Fields to exclude from the response
  final List<String>? exclude;

  const IgdbGameQuery({
    this.where,
    this.fields = const ['*'],
    this.limit = 20,
    this.offset = 0,
    this.sort,
    this.exclude,
  });

  /// Builds the complete IGDB query string
  String buildQuery() {
    final parts = <String>[];

    // Fields clause (required)
    parts.add('fields ${fields.join(',')}; ');

    // Where clause (optional)
    if (where != null) {
      parts.add('where ${where!.toQueryString()}; ');
    }

    // Limit clause (required)
    parts.add('limit $limit; ');

    // Offset clause (required)
    parts.add('offset $offset; ');

    // Sort clause (optional)
    if (sort != null && sort!.isNotEmpty) {
      parts.add('sort $sort; ');
    }

    // Exclude clause (optional)
    if (exclude != null && exclude!.isNotEmpty) {
      parts.add('exclude ${exclude!.join(',')}; ');
    }

    return parts.join('');
  }

  /// Creates a copy of this query with modified parameters
  IgdbGameQuery copyWith({
    IgdbFilter? where,
    List<String>? fields,
    int? limit,
    int? offset,
    String? sort,
    List<String>? exclude,
  }) {
    return IgdbGameQuery(
      where: where ?? this.where,
      fields: fields ?? this.fields,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
      sort: sort ?? this.sort,
      exclude: exclude ?? this.exclude,
    );
  }

  /// Creates a query for the next page of results
  IgdbGameQuery nextPage() {
    return copyWith(offset: offset + limit);
  }

  /// Creates a query for the previous page of results
  IgdbGameQuery previousPage() {
    return copyWith(offset: (offset - limit).clamp(0, offset));
  }

  @override
  List<Object?> get props => [where, fields, limit, offset, sort, exclude];

  @override
  String toString() => buildQuery();
}

// ============================================================
// PREDEFINED FIELD SETS
// ============================================================

/// Predefined field configurations for common query scenarios.
///
/// These help maintain consistency and reduce code duplication
/// when selecting fields for different use cases.
class GameFieldSets {
  /// Minimal fields for list views (ID and name only)
  static const minimal = ['id', 'name'];

  /// Basic fields for game cards in lists
  static const basic = [
    'id',
    'name',
    'slug',
    'cover.url',
    'cover.image_id',
    'total_rating',
    'total_rating_count',
    'first_release_date',
  ];

  /// Standard fields for most list views
  static const standard = [
    'id',
    'name',
    'slug',
    'summary',
    'cover.url',
    'cover.image_id',
    'screenshots.url',
    'screenshots.image_id',
    'total_rating',
    'total_rating_count',
    'rating',
    'rating_count',
    'first_release_date',
    'genres.name',
    'platforms.name',
    'platforms.platform_logo.url',
    'involved_companies.company.name',
    'involved_companies.developer',
    'involved_companies.publisher',
  ];

  /// Extended fields with more details
  static const extended = [
    '*',
    'cover.*',
    'screenshots.*',
    'artworks.*',
    'videos.*',
    'genres.*',
    'platforms.*',
    'platforms.platform_logo.*',
    'game_modes.*',
    'player_perspectives.*',
    'themes.*',
    'involved_companies.*',
    'involved_companies.company.*',
    'age_ratings.*',
    'websites.*',
  ];

  /// Complete fields for detail pages (everything)
  static const complete = [
    '*',
    'cover.*',
    'screenshots.*',
    'artworks.*',
    'videos.*',
    'genres.*',
    'themes.*',
    'keywords.*',
    'platforms.*',
    'platforms.platform_logo.*',
    'platforms.platform_family.*',
    'game_modes.*',
    'player_perspectives.*',
    'involved_companies.*',
    'involved_companies.company.*',
    'involved_companies.company.logo.*',
    'age_ratings.*',
    'websites.*',
    'external_games.*',
    'similar_games.name',
    'similar_games.cover.url',
    'similar_games.total_rating',
    'dlcs.name',
    'dlcs.cover.url',
    'dlcs.first_release_date',
    'expansions.name',
    'expansions.cover.url',
    'expansions.first_release_date',
    'standalone_expansions.name',
    'standalone_expansions.cover.url',
    'remakes.name',
    'remakes.cover.url',
    'remasters.name',
    'remasters.cover.url',
    'parent_game.name',
    'parent_game.cover.url',
    'franchise.*',
    'franchises.*',
    'collection.*',
    'game_engines.*',
    'game_localizations.*',
    'language_supports.*',
    'language_supports.language.*',
    'multiplayer_modes.*',
    'release_dates.*',
    'release_dates.platform.*',
  ];

  /// Fields for search results (balanced between detail and performance)
  static const search = [
    'id',
    'name',
    'slug',
    'summary',
    'cover.url',
    'cover.image_id',
    'total_rating',
    'first_release_date',
    'genres.name',
    'platforms.name',
  ];

  /// Fields for character detail page
  static const characterGames = [
    'id',
    'name',
    'slug',
    'cover.url',
    'total_rating',
    'first_release_date',
    'genres.name',
  ];

  /// Fields for platform detail page
  static const platformGames = [
    'id',
    'name',
    'slug',
    'cover.url',
    'total_rating',
    'first_release_date',
    'release_dates.date',
    'release_dates.region',
  ];
}

// ============================================================
// QUERY PRESETS FOR COMMON USE CASES
// ============================================================

/// Pre-configured query templates for common scenarios.
///
/// These provide ready-to-use queries that follow best practices
/// and can be easily customized via copyWith().
class GameQueryPresets {
  /// Basic list query with standard fields and sorting
  static IgdbGameQuery basicList({
    IgdbFilter? filter,
    int limit = 20,
    int offset = 0,
    String sort = 'total_rating_count desc',
  }) {
    return IgdbGameQuery(
      where: filter,
      fields: GameFieldSets.standard,
      limit: limit,
      offset: offset,
      sort: sort,
    );
  }

  /// Minimal list query for dropdowns/autocomplete
  static IgdbGameQuery minimalList({
    IgdbFilter? filter,
    int limit = 50,
    int offset = 0,
  }) {
    return IgdbGameQuery(
      where: filter,
      fields: GameFieldSets.minimal,
      limit: limit,
      offset: offset,
      sort: 'name asc',
    );
  }

  /// Full details query for detail pages
  static IgdbGameQuery fullDetails({
    required int gameId,
  }) {
    return IgdbGameQuery(
      where: FieldFilter('id', '=', gameId),
      fields: GameFieldSets.complete,
      limit: 1,
    );
  }

  /// Search query optimized for text search
  static IgdbGameQuery search({
    required String searchTerm,
    int limit = 20,
    int offset = 0,
  }) {
    return IgdbGameQuery(
      where: GameFilters.searchByName(searchTerm),
      fields: GameFieldSets.search,
      limit: limit,
      offset: offset,
      sort: 'total_rating_count desc',
    );
  }

  /// Popular games query
  static IgdbGameQuery popular({
    int limit = 20,
    int offset = 0,
    DateTime? releasedAfter,
  }) {
    IgdbFilter? filter;
    if (releasedAfter != null) {
      filter = CombinedFilter([
        GameFilters.releasedAfter(releasedAfter),
        GameFilters.mainGamesOnly(),
        GameFilters.minRatingCount(10),
      ]);
    } else {
      filter = CombinedFilter([
        GameFilters.mainGamesOnly(),
        GameFilters.minRatingCount(10),
      ]);
    }

    return IgdbGameQuery(
      where: filter,
      fields: GameFieldSets.standard,
      limit: limit,
      offset: offset,
      sort: 'total_rating_count desc',
    );
  }

  /// Top rated games query
  static IgdbGameQuery topRated({
    int limit = 20,
    int offset = 0,
    double minRating = 80.0,
    int minRatingCount = 50,
  }) {
    final filter = CombinedFilter([
      GameFilters.mainGamesOnly(),
      GameFilters.ratingAbove(minRating),
      GameFilters.minRatingCount(minRatingCount),
    ]);

    return IgdbGameQuery(
      where: filter,
      fields: GameFieldSets.standard,
      limit: limit,
      offset: offset,
      sort: 'total_rating desc',
    );
  }

  /// Recent releases query
  static IgdbGameQuery recentReleases({
    int limit = 20,
    int offset = 0,
    int daysAgo = 30,
  }) {
    final date = DateTime.now().subtract(Duration(days: daysAgo));
    final filter = CombinedFilter([
      GameFilters.releasedAfter(date),
      GameFilters.mainGamesOnly(),
    ]);

    return IgdbGameQuery(
      where: filter,
      fields: GameFieldSets.standard,
      limit: limit,
      offset: offset,
      sort: 'first_release_date desc',
    );
  }

  /// Upcoming releases query
  static IgdbGameQuery upcomingReleases({
    int limit = 20,
    int offset = 0,
  }) {
    final filter = CombinedFilter([
      GameFilters.releasedAfter(DateTime.now()),
      GameFilters.mainGamesOnly(),
    ]);

    return IgdbGameQuery(
      where: filter,
      fields: GameFieldSets.standard,
      limit: limit,
      offset: offset,
      sort: 'first_release_date asc',
    );
  }

  /// Games by platform query
  static IgdbGameQuery byPlatform({
    required int platformId,
    int limit = 20,
    int offset = 0,
    bool onlyMainGames = true,
  }) {
    IgdbFilter filter;
    if (onlyMainGames) {
      filter = CombinedFilter([
        GameFilters.byPlatform(platformId),
        GameFilters.mainGamesOnly(),
      ]);
    } else {
      filter = GameFilters.byPlatform(platformId);
    }

    return IgdbGameQuery(
      where: filter,
      fields: GameFieldSets.platformGames,
      limit: limit,
      offset: offset,
      sort: 'total_rating_count desc',
    );
  }

  /// Games by company query
  static IgdbGameQuery byCompany({
    required int companyId,
    int limit = 20,
    int offset = 0,
    bool onlyDeveloped = false,
  }) {
    IgdbFilter filter;
    if (onlyDeveloped) {
      filter = GameFilters.byDeveloper(companyId);
    } else {
      filter = GameFilters.byCompany(companyId);
    }

    return IgdbGameQuery(
      where: filter,
      fields: GameFieldSets.standard,
      limit: limit,
      offset: offset,
      sort: 'first_release_date desc',
    );
  }

  /// Games by character query
  static IgdbGameQuery byCharacter({
    required int characterId,
    int limit = 20,
    int offset = 0,
  }) {
    return IgdbGameQuery(
      where: GameFilters.byCharacter(characterId),
      fields: GameFieldSets.characterGames,
      limit: limit,
      offset: offset,
      sort: 'first_release_date desc',
    );
  }

  /// Games by franchise query
  static IgdbGameQuery byFranchise({
    required int franchiseId,
    int limit = 20,
    int offset = 0,
  }) {
    return IgdbGameQuery(
      where: GameFilters.byFranchise(franchiseId),
      fields: GameFieldSets.standard,
      limit: limit,
      offset: offset,
      sort: 'first_release_date asc',
    );
  }

  /// Games by genre query
  static IgdbGameQuery byGenre({
    required int genreId,
    int limit = 20,
    int offset = 0,
  }) {
    final filter = CombinedFilter([
      GameFilters.byGenre(genreId),
      GameFilters.mainGamesOnly(),
      GameFilters.minRatingCount(5),
    ]);

    return IgdbGameQuery(
      where: filter,
      fields: GameFieldSets.standard,
      limit: limit,
      offset: offset,
      sort: 'total_rating desc',
    );
  }

  /// Similar games query (for a specific game's similar games)
  static IgdbGameQuery similarGames({
    required List<int> gameIds,
    int limit = 20,
  }) {
    return IgdbGameQuery(
      where: ContainsFilter('id', gameIds),
      fields: GameFieldSets.basic,
      limit: limit,
      sort: 'total_rating desc',
    );
  }
}

// ============================================================
// QUERY BUILDER FOR STEP-BY-STEP CONSTRUCTION
// ============================================================

/// Fluent builder for constructing IGDB queries step by step.
///
/// Example:
/// ```dart
/// final query = IgdbGameQueryBuilder()
///   .withFields(GameFieldSets.standard)
///   .withFilter(GameFilters.byPlatform(6))
///   .withLimit(20)
///   .sortBy('total_rating desc')
///   .build();
/// ```
class IgdbGameQueryBuilder {
  IgdbFilter? _where;
  List<String> _fields = const ['*'];
  int _limit = 20;
  int _offset = 0;
  String? _sort;
  List<String>? _exclude;

  IgdbGameQueryBuilder();

  /// Start from an existing query
  IgdbGameQueryBuilder.from(IgdbGameQuery query)
      : _where = query.where,
        _fields = query.fields,
        _limit = query.limit,
        _offset = query.offset,
        _sort = query.sort,
        _exclude = query.exclude;

  IgdbGameQueryBuilder withFilter(IgdbFilter? filter) {
    _where = filter;
    return this;
  }

  IgdbGameQueryBuilder withFields(List<String> fields) {
    _fields = fields;
    return this;
  }

  IgdbGameQueryBuilder withLimit(int limit) {
    _limit = limit;
    return this;
  }

  IgdbGameQueryBuilder withOffset(int offset) {
    _offset = offset;
    return this;
  }

  IgdbGameQueryBuilder sortBy(String sort) {
    _sort = sort;
    return this;
  }

  IgdbGameQueryBuilder exclude(List<String> fields) {
    _exclude = fields;
    return this;
  }

  /// Build the final query
  IgdbGameQuery build() {
    return IgdbGameQuery(
      where: _where,
      fields: _fields,
      limit: _limit,
      offset: _offset,
      sort: _sort,
      exclude: _exclude,
    );
  }
}
