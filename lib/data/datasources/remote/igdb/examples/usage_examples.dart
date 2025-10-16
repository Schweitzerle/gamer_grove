// lib/data/datasources/remote/igdb/examples/usage_examples.dart
//
// This file contains examples of how to use the new IGDB query system.
// These are meant to be adapted and used in your repository layer.

import 'package:gamer_grove/data/datasources/remote/igdb/models/game/game_field_sets.dart';
import 'package:gamer_grove/data/datasources/remote/igdb/models/game/game_query_presets.dart';
import 'package:gamer_grove/domain/entities/game/game.dart';

import '../igdb_datasource.dart';
import '../models/igdb_filters.dart';
import '../models/igdb_query.dart';

// ============================================================
// EXAMPLE 1: Basic Queries with Presets
// ============================================================

class BasicQueryExamples {
  final IgdbDataSource dataSource;

  BasicQueryExamples(this.dataSource);

  /// Get popular games
  Future<List<Game>> getPopularGames() async {
    final query = GameQueryPresets.popular(limit: 20);
    return await dataSource.queryGames(query);
  }

  /// Get top rated games
  Future<List<Game>> getTopRatedGames() async {
    final query = GameQueryPresets.topRated(
      minRating: 85.0,
      minRatingCount: 100,
    );
    return await dataSource.queryGames(query);
  }

  /// Get recent releases
  Future<List<Game>> getRecentReleases() async {
    final query = GameQueryPresets.recentReleases(daysAgo: 30);
    return await dataSource.queryGames(query);
  }

  /// Get upcoming releases
  Future<List<Game>> getUpcomingReleases() async {
    final query = GameQueryPresets.upcomingReleases(limit: 20);
    return await dataSource.queryGames(query);
  }
}

// ============================================================
// EXAMPLE 2: Platform-Specific Queries
// ============================================================

class PlatformQueryExamples {
  final IgdbDataSource dataSource;

  PlatformQueryExamples(this.dataSource);

  /// Get games for a single platform
  Future<List<Game>> getGamesByPlatform(int platformId) async {
    final query = GameQueryPresets.byPlatform(
      platformId: platformId,
      limit: 20,
      onlyMainGames: true,
    );
    return await dataSource.queryGames(query);
  }

  /// Get games for multiple platforms
  Future<List<Game>> getGamesForMultiplePlatforms(List<int> platformIds) async {
    final query = IgdbGameQuery(
      where: GameFilters.byPlatforms(platformIds),
      fields: GameFieldSets.standard,
      limit: 50,
      sort: 'total_rating desc',
    );
    return await dataSource.queryGames(query);
  }

  /// Get top rated PlayStation 5 games
  Future<List<Game>> getTopPS5Games() async {
    const ps5PlatformId = 167; // PS5 platform ID

    final filter = CombinedFilter([
      GameFilters.byPlatform(ps5PlatformId),
      GameFilters.ratingAbove(80.0),
      GameFilters.minRatingCount(50),
      GameFilters.mainGamesOnly(),
    ]);

    final query = IgdbGameQuery(
      where: filter,
      fields: GameFieldSets.standard,
      limit: 20,
      sort: 'total_rating desc',
    );

    return await dataSource.queryGames(query);
  }
}

// ============================================================
// EXAMPLE 3: Company-Specific Queries
// ============================================================

class CompanyQueryExamples {
  final IgdbDataSource dataSource;

  CompanyQueryExamples(this.dataSource);

  /// Get all games by a company
  Future<List<Game>> getGamesByCompany(int companyId) async {
    final query = GameQueryPresets.byCompany(
      companyId: companyId,
      limit: 50,
    );
    return await dataSource.queryGames(query);
  }

  /// Get only games developed by a company
  Future<List<Game>> getGamesDevelopedByCompany(int companyId) async {
    final query = GameQueryPresets.byCompany(
      companyId: companyId,
      onlyDeveloped: true,
      limit: 50,
    );
    return await dataSource.queryGames(query);
  }

  /// Get recent Nintendo games
  Future<List<Game>> getRecentNintendoGames() async {
    const nintendoCompanyId = 70; // Nintendo company ID

    final filter = CombinedFilter([
      GameFilters.byCompany(nintendoCompanyId),
      GameFilters.releasedAfter(DateTime(2020, 1, 1)),
      GameFilters.mainGamesOnly(),
    ]);

    final query = IgdbGameQuery(
      where: filter,
      fields: GameFieldSets.standard,
      limit: 30,
      sort: 'first_release_date desc',
    );

    return await dataSource.queryGames(query);
  }
}

// ============================================================
// EXAMPLE 4: Genre & Theme Queries
// ============================================================

class GenreQueryExamples {
  final IgdbDataSource dataSource;

  GenreQueryExamples(this.dataSource);

  /// Get games by genre
  Future<List<Game>> getGamesByGenre(int genreId) async {
    final query = GameQueryPresets.byGenre(
      genreId: genreId,
      limit: 30,
    );
    return await dataSource.queryGames(query);
  }

  /// Get RPG games with high ratings
  Future<List<Game>> getTopRPGGames() async {
    const rpgGenreId = 12; // RPG genre ID

    final filter = CombinedFilter([
      GameFilters.byGenre(rpgGenreId),
      GameFilters.ratingAbove(85.0),
      GameFilters.minRatingCount(100),
      GameFilters.mainGamesOnly(),
    ]);

    final query = IgdbGameQuery(
      where: filter,
      fields: GameFieldSets.standard,
      limit: 20,
      sort: 'total_rating desc',
    );

    return await dataSource.queryGames(query);
  }

  /// Get horror games released in the last 5 years
  Future<List<Game>> getRecentHorrorGames() async {
    const horrorThemeId = 19; // Horror theme ID

    final filter = CombinedFilter([
      GameFilters.byTheme(horrorThemeId),
      GameFilters.releasedAfter(
          DateTime.now().subtract(Duration(days: 365 * 5))),
      GameFilters.mainGamesOnly(),
      GameFilters.minRatingCount(10),
    ]);

    final query = IgdbGameQuery(
      where: filter,
      fields: GameFieldSets.standard,
      limit: 30,
      sort: 'total_rating desc',
    );

    return await dataSource.queryGames(query);
  }
}

// ============================================================
// EXAMPLE 5: Complex Filtered Queries Using Builder
// ============================================================

class ComplexQueryExamples {
  final IgdbDataSource dataSource;

  ComplexQueryExamples(this.dataSource);

  /// Get multiplayer Switch games released in 2023
  Future<List<Game>> getMultiplayerSwitchGames2023() async {
    const switchPlatformId = 130; // Nintendo Switch
    const multiplayerGameModeId = 2; // Multiplayer mode

    final filter = GameFilterBuilder()
        .withPlatform(switchPlatformId)
        .releasedInYear(2023)
        .addCustomFilter(GameFilters.byGameMode(multiplayerGameModeId))
        .withMinRating(70.0)
        .mainGamesOnly()
        .build();

    final query = IgdbGameQuery(
      where: filter,
      fields: GameFieldSets.standard,
      limit: 30,
      sort: 'total_rating desc',
    );

    return await dataSource.queryGames(query);
  }

  /// Get indie games with exceptional ratings
  Future<List<Game>> getTopIndieGames() async {
    const indieThemeId = 32; // Indie theme

    final filter = GameFilterBuilder()
        .addCustomFilter(GameFilters.byTheme(indieThemeId))
        .withMinRating(85.0)
        .withMinRatingCount(50)
        .mainGamesOnly()
        .build();

    final query = IgdbGameQuery(
      where: filter,
      fields: GameFieldSets.standard,
      limit: 20,
      sort: 'total_rating desc',
    );

    return await dataSource.queryGames(query);
  }

  /// Get open-world RPGs for current gen consoles
  Future<List<Game>> getOpenWorldRPGsCurrentGen() async {
    const rpgGenreId = 12;
    const openWorldThemeId = 38;
    const ps5 = 167;
    const xboxSeriesX = 169;

    final filter = CombinedFilter([
      GameFilters.byGenre(rpgGenreId),
      GameFilters.byTheme(openWorldThemeId),
      GameFilters.byPlatforms([ps5, xboxSeriesX]),
      GameFilters.ratingAbove(75.0),
      GameFilters.mainGamesOnly(),
    ]);

    final query = IgdbGameQuery(
      where: filter,
      fields: GameFieldSets.standard,
      limit: 20,
      sort: 'total_rating desc',
    );

    return await dataSource.queryGames(query);
  }
}

// ============================================================
// EXAMPLE 6: Advanced Pagination
// ============================================================

class PaginationExamples {
  final IgdbDataSource dataSource;

  PaginationExamples(this.dataSource);

  /// Load multiple pages of results
  Future<List<Game>> loadMultiplePages({
    required IgdbGameQuery initialQuery,
    required int pageCount,
  }) async {
    final allGames = <Game>[];
    var currentQuery = initialQuery;

    for (int i = 0; i < pageCount; i++) {
      final games = await dataSource.queryGames(currentQuery);
      allGames.addAll(games);

      // If we got fewer results than the limit, we've reached the end
      if (games.length < currentQuery.limit) break;

      // Move to next page
      currentQuery = currentQuery.nextPage();
    }

    return allGames;
  }

  /// Infinite scroll pattern
  Future<List<Game>> loadNextPage({
    required IgdbGameQuery currentQuery,
  }) async {
    final nextQuery = currentQuery.nextPage();
    return await dataSource.queryGames(nextQuery);
  }
}

// ============================================================
// EXAMPLE 7: Custom Field Selection for Performance
// ============================================================

class PerformanceOptimizedExamples {
  final IgdbDataSource dataSource;

  PerformanceOptimizedExamples(this.dataSource);

  /// Get minimal game info for autocomplete
  Future<List<Game>> getGamesForAutocomplete(String searchTerm) async {
    final query = IgdbGameQuery(
      where: GameFilters.searchByName(searchTerm),
      fields: GameFieldSets.minimal, // Only ID and name
      limit: 10,
      sort: 'total_rating_count desc',
    );

    return await dataSource.queryGames(query);
  }

  /// Get game list with only cover images (for grid view)
  Future<List<Game>> getGamesWithCoversOnly() async {
    final query = IgdbGameQuery(
      where: GameFilters.mainGamesOnly(),
      fields: [
        'id',
        'name',
        'slug',
        'cover.url',
        'cover.image_id',
      ],
      limit: 50,
      sort: 'total_rating_count desc',
    );

    return await dataSource.queryGames(query);
  }
}

// ============================================================
// EXAMPLE 8: Real Repository Integration
// ============================================================

/// Example of how to integrate this in your repository
class GameRepositoryExample {
  final IgdbDataSource igdbDataSource;

  GameRepositoryExample(this.igdbDataSource);

  /// Repository method using the new query system
  Future<List<Game>> getGamesByPlatformAndGenre({
    required int platformId,
    required int genreId,
    int limit = 20,
    int offset = 0,
  }) async {
    // Build filter
    final filter = CombinedFilter([
      GameFilters.byPlatform(platformId),
      GameFilters.byGenre(genreId),
      GameFilters.mainGamesOnly(),
      GameFilters.minRatingCount(5),
    ]);

    // Build query
    final query = IgdbGameQuery(
      where: filter,
      fields: GameFieldSets.standard,
      limit: limit,
      offset: offset,
      sort: 'total_rating desc',
    );

    // Execute query
    return await igdbDataSource.queryGames(query);
  }

  /// Another repository method
  Future<List<Game>> getGamesForHomeFeed() async {
    // Get popular recent games
    final query = GameQueryPresets.popular(
      limit: 20,
      releasedAfter: DateTime.now().subtract(Duration(days: 90)),
    );

    return await igdbDataSource.queryGames(query);
  }
}

// ============================================================
// MIGRATION GUIDE EXAMPLE
// ============================================================

/// Shows how to migrate from old code to new query system
class MigrationExample {
  final IgdbDataSource dataSource;

  MigrationExample(this.dataSource);

  // ❌ OLD WAY (before refactoring)
  /*
  Future<List<Game>> getGamesByPlatformOldWay(int platformId) async {
    // Had to call specific method
    return await dataSource.getGamesByPlatform(
      platformIds: [platformId],
      limit: 20,
      offset: 0,
    );
  }
  */

  // ✅ NEW WAY (after refactoring)
  Future<List<Game>> getGamesByPlatformNewWay(int platformId) async {
    // Use preset for common case
    final query = GameQueryPresets.byPlatform(
      platformId: platformId,
      limit: 20,
    );
    return await dataSource.queryGames(query);
  }

  // ❌ OLD WAY (what you probably had before - multiple methods)
  /*
  Future<List<Game>> getPS5RPGsOldWay() async {
    // Had to chain multiple specific methods or build complex logic
    final ps5Games = await dataSource.getGamesByPlatform(...);
    final rpgGames = await dataSource.getGamesByGenre(...);
    // Then manually filter the intersection... messy!
  }
  */

  // ✅ NEW WAY (clean, composable filters)
  Future<List<Game>> getPS5RPGsNewWay() async {
    const ps5 = 167;
    const rpgGenre = 12;

    final filter = CombinedFilter([
      GameFilters.byPlatform(ps5),
      GameFilters.byGenre(rpgGenre),
      GameFilters.mainGamesOnly(),
    ]);

    final query = IgdbGameQuery(
      where: filter,
      fields: GameFieldSets.standard,
      limit: 20,
      sort: 'total_rating desc',
    );

    return await dataSource.queryGames(query);
  }
}
