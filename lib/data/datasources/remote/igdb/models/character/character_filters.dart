// lib/data/datasources/remote/igdb/models/character/character_filters.dart

import 'package:gamer_grove/domain/entities/character/character_gender.dart';
import 'package:gamer_grove/domain/entities/character/character_species.dart';

import '../igdb_filters.dart';

/// Pre-configured filters for common character queries.
///
/// This class provides convenient factory methods for the most
/// common filtering scenarios when querying characters from IGDB.
class CharacterFilters {
  CharacterFilters._(); // Private constructor to prevent instantiation

  // ============================================================
  // GAME FILTERS
  // ============================================================

  /// Filter characters that appear in a specific game
  static IgdbFilter byGame(int gameId) => ContainsFilter('games', [gameId]);

  /// Filter characters that appear in any of the specified games
  static IgdbFilter byGames(List<int> gameIds) =>
      ContainsFilter('games', gameIds);

  // ============================================================
  // GENDER FILTERS
  // ============================================================

  /// Filter characters by gender enum
  static IgdbFilter byGender(CharacterGenderEnum gender) =>
      FieldFilter('gender', '=', gender.value);

  /// Filter male characters
  static IgdbFilter maleOnly() => byGender(CharacterGenderEnum.male);

  /// Filter female characters
  static IgdbFilter femaleOnly() => byGender(CharacterGenderEnum.female);

  /// Filter non-binary characters
  static IgdbFilter nonBinaryOnly() => byGender(CharacterGenderEnum.other);

  // ============================================================
  // SPECIES FILTERS
  // ============================================================

  /// Filter characters by species enum
  static IgdbFilter bySpecies(CharacterSpeciesEnum species) =>
      FieldFilter('species', '=', species.value);

  /// Filter human characters
  static IgdbFilter humanOnly() => bySpecies(CharacterSpeciesEnum.human);

  /// Filter alien characters
  static IgdbFilter alienOnly() => bySpecies(CharacterSpeciesEnum.alien);

  /// Filter animal characters
  static IgdbFilter animalOnly() => bySpecies(CharacterSpeciesEnum.animal);

  /// Filter android characters
  static IgdbFilter androidOnly() => bySpecies(CharacterSpeciesEnum.android);

  /// Filter unknown characters
  static IgdbFilter unknownSpeciesOnly() =>
      bySpecies(CharacterSpeciesEnum.unknown);

  // ============================================================
  // SEARCH & NAME FILTERS
  // ============================================================

  /// Search characters by name (partial match)
  static IgdbFilter searchByName(String query) =>
      FieldFilter('name', '~', query);

  /// Filter characters from a specific country
  static IgdbFilter byCountry(String countryName) =>
      FieldFilter('country_name', '=', countryName);

  // ============================================================
  // EXISTENCE FILTERS
  // ============================================================

  /// Filter characters that have a mug shot image
  static IgdbFilter hasMugShot() => NullFilter('mug_shot', isNull: false);

  /// Filter characters that have a description
  static IgdbFilter hasDescription() =>
      NullFilter('description', isNull: false);

  /// Filter characters that appear in at least one game
  static IgdbFilter hasGames() => NullFilter('games', isNull: false);
}

/// Builder for creating complex character filters step by step.
///
/// Example:
/// ```dart
/// final filter = CharacterFilterBuilder()
///   .inGame(1942)
///   .withGender(CharacterGenderEnum.female)
///   .withMugShot()
///   .build();
/// ```
class CharacterFilterBuilder {
  final List<IgdbFilter> _filters = [];

  CharacterFilterBuilder();

  // Game methods
  CharacterFilterBuilder inGame(int gameId) {
    _filters.add(CharacterFilters.byGame(gameId));
    return this;
  }

  CharacterFilterBuilder inGames(List<int> gameIds) {
    _filters.add(CharacterFilters.byGames(gameIds));
    return this;
  }

  // Gender methods
  CharacterFilterBuilder withGender(CharacterGenderEnum gender) {
    _filters.add(CharacterFilters.byGender(gender));
    return this;
  }

  CharacterFilterBuilder maleOnly() {
    _filters.add(CharacterFilters.maleOnly());
    return this;
  }

  CharacterFilterBuilder femaleOnly() {
    _filters.add(CharacterFilters.femaleOnly());
    return this;
  }

  // Species methods
  CharacterFilterBuilder withSpecies(CharacterSpeciesEnum species) {
    _filters.add(CharacterFilters.bySpecies(species));
    return this;
  }

  CharacterFilterBuilder humanOnly() {
    _filters.add(CharacterFilters.humanOnly());
    return this;
  }

  // Existence methods
  CharacterFilterBuilder withMugShot() {
    _filters.add(CharacterFilters.hasMugShot());
    return this;
  }

  CharacterFilterBuilder withDescription() {
    _filters.add(CharacterFilters.hasDescription());
    return this;
  }

  CharacterFilterBuilder withGames() {
    _filters.add(CharacterFilters.hasGames());
    return this;
  }

  // Search methods
  CharacterFilterBuilder searchByName(String query) {
    _filters.add(CharacterFilters.searchByName(query));
    return this;
  }

  CharacterFilterBuilder fromCountry(String countryName) {
    _filters.add(CharacterFilters.byCountry(countryName));
    return this;
  }

  // Custom filter
  CharacterFilterBuilder addCustomFilter(IgdbFilter filter) {
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
