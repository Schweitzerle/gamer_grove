// lib/data/datasources/remote/igdb/models/game/game_query_presets.dart

import 'package:gamer_grove/data/datasources/remote/igdb/models/game/game_field_sets.dart';
import 'package:gamer_grove/data/datasources/remote/igdb/models/game/game_filters.dart';
import 'package:gamer_grove/data/datasources/remote/igdb/models/igdb_filters.dart' hide GameFilters;
import 'package:gamer_grove/data/datasources/remote/igdb/models/igdb_query.dart';

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
  ///
  /// Uses IGDB's native search functionality which is better than
  /// regex matching with 'where name ~'. The search operator finds
  /// games by name, alternative names, and other text fields.
  ///
  /// Based on original query:
  /// search "$query";
  static IgdbGameQuery search({
    required String searchTerm,
    int limit = 20,
    int offset = 0,
  }) {
    return IgdbGameQuery(
      search: searchTerm,
      fields: GameFieldSets.search,
      limit: limit,
      offset: offset,
    );
  }

  // ============================================================
  // POPULAR & TRENDING
  // ============================================================

  /// Popular games query
  ///
  /// Updated to use hypes (what people are talking about/expecting)
  /// Games with hype between 5-300, filtered to ±6 months from now
  /// to show currently trending games (not mega-hyped evergreen titles)
  static IgdbGameQuery popular({
    int limit = 20,
    int offset = 0,
    DateTime? releasedAfter,
  }) {
    final now = DateTime.now();
    final sixMonthsAgo = DateTime(now.year, now.month - 6, now.day);
    final sixMonthsFromNow = DateTime(now.year, now.month + 6, now.day);

    final filters = <IgdbFilter>[
      const FieldFilter('hypes', '>=', 5),
      FieldFilter('first_release_date', '>=',
          sixMonthsAgo.millisecondsSinceEpoch ~/ 1000,),
      FieldFilter('first_release_date', '<=',
          sixMonthsFromNow.millisecondsSinceEpoch ~/ 1000,),
    ];

    if (releasedAfter != null) {
      filters.add(GameFilters.releasedAfter(releasedAfter));
    }

    return IgdbGameQuery(
      where: CombinedFilter(filters),
      fields: GameFieldSets.standard,
      limit: limit,
      offset: offset,
      sort: 'hypes desc',
    );
  }

  /// Top rated games query
  ///
  /// Based on original query:
  /// where total_rating >= 70 & total_rating_count >= 100;
  ///
  /// Note: We only use total_rating_count filter because IGDB API
  /// has issues with total_rating comparisons. We rely on sorting
  /// to get the highest rated games.
  static IgdbGameQuery topRated({
    int limit = 20,
    int offset = 0,
    double minRating = 70.0, // Not used - IGDB API doesn't support it reliably
    int minRatingCount = 100,
  }) {
    final filter = GameFilters.minRatingCount(minRatingCount);

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
  ///
  /// Based on original query:
  /// where first_release_date < $now;
  static IgdbGameQuery recentReleases({
    int limit = 20,
    int offset = 0,
    int daysAgo = 30,
  }) {
    final now = DateTime.now();
    final filter = GameFilters.releasedBefore(now);

    return IgdbGameQuery(
      where: filter,
      fields: GameFieldSets.standard,
      limit: limit,
      offset: offset,
      sort: 'first_release_date desc',
    );
  }

  /// Upcoming releases query
  ///
  /// Based on original query:
  /// where first_release_date > $now;
  static IgdbGameQuery upcomingReleases({
    int limit = 20,
    int offset = 0,
  }) {
    final filter = GameFilters.releasedAfter(DateTime.now());

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
    String? sortBy,
    String? sortOrder,
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

    // Build sort string (default: total_rating_count desc)
    final sortString = sortBy != null && sortOrder != null
        ? '$sortBy $sortOrder'
        : 'total_rating_count desc';

    return IgdbGameQuery(
      where: filter,
      fields: GameFieldSets.platformGames,
      limit: limit,
      offset: offset,
      sort: sortString,
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
