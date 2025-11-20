// lib/data/datasources/remote/igdb/models/game/game_filters.dart

import 'package:gamer_grove/data/datasources/remote/igdb/models/igdb_filters.dart';

/// Pre-configured filters for common game queries.
///
/// This class provides convenient factory methods for the most
/// common filtering scenarios when querying games from IGDB.
class GameFilters {
  GameFilters._(); // Private constructor to prevent instantiation

  // ============================================================
  // PLATFORM FILTERS
  // ============================================================

  /// Filter games by a single platform
  static IgdbFilter byPlatform(int platformId) =>
      ContainsFilter('platforms', [platformId]);

  /// Filter games by multiple platforms (games that have ANY of these platforms)
  static IgdbFilter byPlatforms(List<int> platformIds) =>
      ContainsFilter('platforms', platformIds);

  /// Filter games that have ALL specified platforms
  static IgdbFilter byAllPlatforms(List<int> platformIds) =>
      AllFilter('platforms', platformIds);

  // ============================================================
  // COMPANY FILTERS
  // ============================================================

  /// Filter games by involved company
  static IgdbFilter byCompany(int companyId) =>
      ContainsFilter('involved_companies.company', [companyId]);

  /// Filter games by developer company
  static IgdbFilter byDeveloper(int companyId) => CombinedFilter([
        ContainsFilter('involved_companies.company', [companyId]),
        const FieldFilter('involved_companies.developer', '=', true),
      ]);

  /// Filter games by publisher company
  static IgdbFilter byPublisher(int companyId) => CombinedFilter([
        ContainsFilter('involved_companies.company', [companyId]),
        const FieldFilter('involved_companies.publisher', '=', true),
      ]);

  // ============================================================
  // RELATED ENTITIES FILTERS
  // ============================================================

  /// Filter games by character
  static IgdbFilter byCharacter(int characterId) =>
      ContainsFilter('characters', [characterId]);

  /// Filter games by franchise
  static IgdbFilter byFranchise(int franchiseId) =>
      FieldFilter('franchise', '=', franchiseId);

  /// Filter games by franchises (any of these)
  static IgdbFilter byFranchises(List<int> franchiseIds) =>
      ContainsFilter('franchises', franchiseIds);

  /// Filter games by collection
  static IgdbFilter byCollection(int collectionId) =>
      FieldFilter('collection', '=', collectionId);

  // ============================================================
  // GENRE & THEME FILTERS
  // ============================================================

  /// Filter games by a single genre
  static IgdbFilter byGenre(int genreId) => ContainsFilter('genres', [genreId]);

  /// Filter games by multiple genres (any of these)
  static IgdbFilter byGenres(List<int> genreIds) =>
      ContainsFilter('genres', genreIds);

  /// Filter games by a single theme
  static IgdbFilter byTheme(int themeId) => ContainsFilter('themes', [themeId]);

  /// Filter games by multiple themes (any of these)
  static IgdbFilter byThemes(List<int> themeIds) =>
      ContainsFilter('themes', themeIds);

  /// Filter games by game mode
  static IgdbFilter byGameMode(int gameModeId) =>
      ContainsFilter('game_modes', [gameModeId]);

  // ============================================================
  // RATING FILTERS
  // ============================================================

  /// Filter games with rating above threshold
  /// Note: IGDB only supports >= operator for total_rating, not >
  static IgdbFilter ratingAbove(double rating) =>
      FieldFilter('total_rating', '>=', rating);

  /// Filter games with rating below threshold
  /// Note: IGDB only supports <= operator for total_rating, not <
  static IgdbFilter ratingBelow(double rating) =>
      FieldFilter('total_rating', '<=', rating);

  /// Filter games with rating between min and max
  static IgdbFilter ratingBetween(double min, double max) => CombinedFilter([
        FieldFilter('total_rating', '>=', min),
        FieldFilter('total_rating', '<=', max),
      ]);

  /// Filter games with at least X ratings
  static IgdbFilter minRatingCount(int count) =>
      FieldFilter('total_rating_count', '>=', count);

  // ============================================================
  // RELEASE DATE FILTERS
  // ============================================================

  /// Filter games released after a specific date
  static IgdbFilter releasedAfter(DateTime date) =>
      FieldFilter('first_release_date', '>', _toUnixTimestamp(date));

  /// Filter games released before a specific date
  static IgdbFilter releasedBefore(DateTime date) =>
      FieldFilter('first_release_date', '<', _toUnixTimestamp(date));

  /// Filter games released between two dates
  static IgdbFilter releasedBetween(DateTime start, DateTime end) =>
      CombinedFilter([
        FieldFilter('first_release_date', '>=', _toUnixTimestamp(start)),
        FieldFilter('first_release_date', '<=', _toUnixTimestamp(end)),
      ]);

  /// Filter games released in a specific year
  static IgdbFilter releasedInYear(int year) {
    final start = DateTime(year);
    final end = DateTime(year, 12, 31, 23, 59, 59);
    return releasedBetween(start, end);
  }

  // ============================================================
  // GAME TYPE & STATUS FILTERS
  // ============================================================

  /// Filter by game category/type
  ///
  /// Categories:
  /// - 0: Main game
  /// - 1: DLC/Addon
  /// - 2: Expansion
  /// - 3: Bundle
  /// - 4: Standalone expansion
  /// - 5: Mod
  /// - 6: Episode
  /// - 7: Season
  /// - 8: Remake
  /// - 9: Remaster
  /// - 10: Expanded game
  /// - 11: Port
  /// - 12: Fork
  /// - 13: Pack
  /// - 14: Update
  static IgdbFilter byCategory(int category) =>
      FieldFilter('category', '=', category);

  /// Filter only main games (no DLCs, expansions, etc.)
  static IgdbFilter mainGamesOnly() => byCategory(0);

  /// Filter only DLCs
  static IgdbFilter dlcsOnly() => byCategory(1);

  /// Filter only expansions
  static IgdbFilter expansionsOnly() => byCategory(2);

  /// Filter by game status
  ///
  /// Status:
  /// - 0: Released
  /// - 2: Alpha
  /// - 3: Beta
  /// - 4: Early access
  /// - 5: Offline
  /// - 6: Cancelled
  /// - 7: Rumored
  /// - 8: Delisted
  static IgdbFilter byStatus(int status) => FieldFilter('status', '=', status);

  /// Filter only released games
  static IgdbFilter releasedGamesOnly() => byStatus(0);

  // ============================================================
  // PARENT/CHILD RELATIONSHIP FILTERS
  // ============================================================

  /// Filter games that have no parent (standalone games)
  static IgdbFilter noParentGame() => const NullFilter('parent_game');

  /// Filter games that ARE DLCs/expansions of a specific game
  static IgdbFilter dlcsOf(int parentGameId) =>
      FieldFilter('parent_game', '=', parentGameId);

  // ============================================================
  // SEARCH & NAME FILTERS
  // ============================================================

  /// Search games by name (partial match)
  /// Note: This is a simple contains check, IGDB has better search endpoints
  static IgdbFilter searchByName(String query) =>
      FieldFilter('name', '~', query);

  // ============================================================
  // HELPER METHODS
  // ============================================================

  /// Convert DateTime to Unix timestamp (seconds since epoch)
  static int _toUnixTimestamp(DateTime date) =>
      date.millisecondsSinceEpoch ~/ 1000;
}

/// Builder for creating complex game filters step by step.
///
/// Example:
/// ```dart
/// final filter = GameFilterBuilder()
///   .withPlatforms([6, 48, 49])
///   .withGenres([12, 31])
///   .withMinRating(80.0)
///   .releasedAfter(DateTime(2020, 1, 1))
///   .mainGamesOnly()
///   .build();
/// ```
class GameFilterBuilder {

  GameFilterBuilder();
  final List<IgdbFilter> _filters = [];

  // Platform methods
  GameFilterBuilder withPlatform(int platformId) {
    _filters.add(GameFilters.byPlatform(platformId));
    return this;
  }

  GameFilterBuilder withPlatforms(List<int> platformIds) {
    _filters.add(GameFilters.byPlatforms(platformIds));
    return this;
  }

  // Genre methods
  GameFilterBuilder withGenre(int genreId) {
    _filters.add(GameFilters.byGenre(genreId));
    return this;
  }

  GameFilterBuilder withGenres(List<int> genreIds) {
    _filters.add(GameFilters.byGenres(genreIds));
    return this;
  }

  // Rating methods
  GameFilterBuilder withMinRating(double rating) {
    _filters.add(GameFilters.ratingAbove(rating));
    return this;
  }

  GameFilterBuilder withRatingBetween(double min, double max) {
    _filters.add(GameFilters.ratingBetween(min, max));
    return this;
  }

  GameFilterBuilder withMinRatingCount(int count) {
    _filters.add(GameFilters.minRatingCount(count));
    return this;
  }

  // Release date methods
  GameFilterBuilder releasedAfter(DateTime date) {
    _filters.add(GameFilters.releasedAfter(date));
    return this;
  }

  GameFilterBuilder releasedBefore(DateTime date) {
    _filters.add(GameFilters.releasedBefore(date));
    return this;
  }

  GameFilterBuilder releasedBetween(DateTime start, DateTime end) {
    _filters.add(GameFilters.releasedBetween(start, end));
    return this;
  }

  GameFilterBuilder releasedInYear(int year) {
    _filters.add(GameFilters.releasedInYear(year));
    return this;
  }

  // Category methods
  GameFilterBuilder mainGamesOnly() {
    _filters.add(GameFilters.mainGamesOnly());
    return this;
  }

  GameFilterBuilder dlcsOnly() {
    _filters.add(GameFilters.dlcsOnly());
    return this;
  }

  GameFilterBuilder expansionsOnly() {
    _filters.add(GameFilters.expansionsOnly());
    return this;
  }

  // Status methods
  GameFilterBuilder releasedGamesOnly() {
    _filters.add(GameFilters.releasedGamesOnly());
    return this;
  }

  // Company methods
  GameFilterBuilder byCompany(int companyId) {
    _filters.add(GameFilters.byCompany(companyId));
    return this;
  }

  GameFilterBuilder byDeveloper(int companyId) {
    _filters.add(GameFilters.byDeveloper(companyId));
    return this;
  }

  GameFilterBuilder byPublisher(int companyId) {
    _filters.add(GameFilters.byPublisher(companyId));
    return this;
  }

  // Custom filter
  GameFilterBuilder addCustomFilter(IgdbFilter filter) {
    _filters.add(filter);
    return this;
  }

  // Build final filter
  IgdbFilter? build() {
    if (_filters.isEmpty) return null;
    if (_filters.length == 1) return _filters.first;
    return CombinedFilter(_filters);
  }
}
