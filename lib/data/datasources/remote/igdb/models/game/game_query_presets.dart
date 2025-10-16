// lib/data/datasources/remote/igdb/models/game/game_query_presets.dart

import '../igdb_query.dart';
import '../igdb_filters.dart' hide GameFilters;
import 'game_field_sets.dart';
import 'game_filters.dart';

/// Pre-configured query presets for common game queries.
///
/// These presets provide convenient, optimized queries for common scenarios.
class GameQueryPresets {
  GameQueryPresets._(); // Private constructor to prevent instantiation

  // ============================================================
  // BASIC QUERIES
  // ============================================================

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

  // ============================================================
  // POPULAR & TRENDING
  // ============================================================

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

  // ============================================================
  // RELEASE-BASED QUERIES
  // ============================================================

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

  // ============================================================
  // ENTITY-SPECIFIC QUERIES
  // ============================================================

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
