// lib/data/datasources/remote/igdb/models/igdb_filters.dart

import 'package:equatable/equatable.dart';

/// Base class for all IGDB query filters.
///
/// Filters are used to construct WHERE clauses for IGDB API queries.
/// Each filter can be converted to an IGDB-compatible query string.
abstract class IgdbFilter extends Equatable {
  const IgdbFilter();

  /// Converts this filter to an IGDB query string
  String toQueryString();

  @override
  List<Object?> get props => [];
}

/// Filter for a single field comparison.
///
/// Supports operators: =, !=, >, <, >=, <=
///
/// Example:
/// ```dart
/// FieldFilter('total_rating', '>', 80)
/// // Output: "total_rating > 80"
/// ```
class FieldFilter extends IgdbFilter {

  const FieldFilter(this.field, this.operator, this.value);
  final String field;
  final String operator;
  final dynamic value;

  @override
  String toQueryString() {
    // Handle string values (need quotes)
    if (value is String) {
      // For the ~ operator (partial match), add wildcards around the search term
      if (operator == '~') {
        return '$field $operator *"$value"*';
      }
      return '$field $operator "$value"';
    }
    return '$field $operator $value';
  }

  @override
  List<Object?> get props => [field, operator, value];
}

/// Filter for checking if a field contains value(s) from a list.
///
/// Used for array fields in IGDB (platforms, genres, etc.)
///
/// Example:
/// ```dart
/// ContainsFilter('platforms', [6, 48, 49])
/// // Output: "platforms = (6,48,49)"
/// ```
class ContainsFilter extends IgdbFilter {

  const ContainsFilter(this.field, this.values);
  final String field;
  final List<dynamic> values;

  @override
  String toQueryString() {
    if (values.isEmpty) {
      throw ArgumentError('ContainsFilter values cannot be empty');
    }
    final valueStr = values.join(',');
    return '$field = ($valueStr)';
  }

  @override
  List<Object?> get props => [field, values];
}

/// Filter for checking if ANY value in a list matches.
///
/// Example:
/// ```dart
/// AnyFilter('platforms', [6, 48, 49])
/// // Output: "platforms = [6,48,49]"
/// ```
class AnyFilter extends IgdbFilter {

  const AnyFilter(this.field, this.values);
  final String field;
  final List<dynamic> values;

  @override
  String toQueryString() {
    if (values.isEmpty) {
      throw ArgumentError('AnyFilter values cannot be empty');
    }
    final valueStr = values.join(',');
    return '$field = [$valueStr]';
  }

  @override
  List<Object?> get props => [field, values];
}

/// Filter for checking if ALL values in a list match.
///
/// Example:
/// ```dart
/// AllFilter('genres', [12, 31])
/// // Output: "genres = {12,31}"
/// ```
class AllFilter extends IgdbFilter {

  const AllFilter(this.field, this.values);
  final String field;
  final List<dynamic> values;

  @override
  String toQueryString() {
    if (values.isEmpty) {
      throw ArgumentError('AllFilter values cannot be empty');
    }
    final valueStr = values.join(',');
    return '$field = {$valueStr}';
  }

  @override
  List<Object?> get props => [field, values];
}

/// Filter for NULL checks.
///
/// Example:
/// ```dart
/// NullFilter('parent_game', isNull: true)
/// // Output: "parent_game = null"
///
/// NullFilter('parent_game', isNull: false)
/// // Output: "parent_game != null"
/// ```
class NullFilter extends IgdbFilter {

  const NullFilter(this.field, {this.isNull = true});
  final String field;
  final bool isNull;

  @override
  String toQueryString() {
    return isNull ? '$field = null' : '$field != null';
  }

  @override
  List<Object?> get props => [field, isNull];
}

/// Combines multiple filters with AND or OR logic.
///
/// Example:
/// ```dart
/// CombinedFilter([
///   FieldFilter('total_rating', '>', 80),
///   ContainsFilter('platforms', [6]),
/// ], operator: '&')
/// // Output: "total_rating > 80 & platforms = (6)"
/// ```
class CombinedFilter extends IgdbFilter { // '&' for AND, '|' for OR

  const CombinedFilter(this.filters, {this.operator = '&'});
  final List<IgdbFilter> filters;
  final String operator;

  @override
  String toQueryString() {
    if (filters.isEmpty) {
      throw ArgumentError('CombinedFilter must have at least one filter');
    }
    if (filters.length == 1) {
      return filters.first.toQueryString();
    }
    return filters.map((f) => '(${f.toQueryString()})').join(' $operator ');
  }

  @override
  List<Object?> get props => [filters, operator];
}

/// Negates a filter (NOT logic).
///
/// Example:
/// ```dart
/// NotFilter(ContainsFilter('genres', [12]))
/// // Output: "!(genres = (12))"
/// ```
class NotFilter extends IgdbFilter {

  const NotFilter(this.filter);
  final IgdbFilter filter;

  @override
  String toQueryString() => '!(${filter.toQueryString()})';

  @override
  List<Object?> get props => [filter];
}

// ============================================================
// PRE-BUILT FILTER FACTORY FOR COMMON USE CASES
// ============================================================

/// Pre-configured filters for common game queries.
///
/// This class provides convenient factory methods for the most
/// common filtering scenarios when querying games from IGDB.
class GameFilters {
  // Platform Filters
  // ---------------

  /// Filter games by a single platform
  static IgdbFilter byPlatform(int platformId) =>
      ContainsFilter('platforms', [platformId]);

  /// Filter games by multiple platforms (games that have ANY of these platforms)
  static IgdbFilter byPlatforms(List<int> platformIds) =>
      ContainsFilter('platforms', platformIds);

  /// Filter games that have ALL specified platforms
  static IgdbFilter byAllPlatforms(List<int> platformIds) =>
      AllFilter('platforms', platformIds);

  // Company Filters
  // --------------

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

  // Character & Related Entities
  // ---------------------------

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

  // Genre & Theme Filters
  // --------------------

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

  // Rating Filters
  // -------------

  /// Filter games with rating above threshold
  static IgdbFilter ratingAbove(double rating) =>
      FieldFilter('total_rating', '>', rating);

  /// Filter games with rating below threshold
  static IgdbFilter ratingBelow(double rating) =>
      FieldFilter('total_rating', '<', rating);

  /// Filter games with rating between min and max
  static IgdbFilter ratingBetween(double min, double max) => CombinedFilter([
        FieldFilter('total_rating', '>=', min),
        FieldFilter('total_rating', '<=', max),
      ]);

  /// Filter games with at least X ratings
  static IgdbFilter minRatingCount(int count) =>
      FieldFilter('total_rating_count', '>=', count);

  // Release Date Filters
  // -------------------

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

  // Game Type & Status Filters
  // --------------------------

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

  // Parent/Child Relationship Filters
  // ---------------------------------

  /// Filter games that have no parent (standalone games)
  static IgdbFilter noParentGame() => const NullFilter('parent_game');

  /// Filter games that ARE DLCs/expansions of a specific game
  static IgdbFilter dlcsOf(int parentGameId) =>
      FieldFilter('parent_game', '=', parentGameId);

  // Search & Name Filters
  // --------------------

  /// Search games by name (partial match)
  /// Note: This is a simple contains check, IGDB has better search endpoints
  static IgdbFilter searchByName(String query) =>
      FieldFilter('name', '~', query);

  // Helper Methods
  // -------------

  /// Convert DateTime to Unix timestamp (seconds since epoch)
  static int _toUnixTimestamp(DateTime date) =>
      date.millisecondsSinceEpoch ~/ 1000;
}

// ============================================================
// FILTER BUILDERS FOR COMPLEX SCENARIOS
// ============================================================

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
  IgdbFilter? build({String operator = '&'}) {
    if (_filters.isEmpty) return null;
    if (_filters.length == 1) return _filters.first;
    return CombinedFilter(_filters, operator: operator);
  }
}
