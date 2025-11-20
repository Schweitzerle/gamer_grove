// lib/data/datasources/remote/igdb/models/character/character_query_presets.dart

import 'package:gamer_grove/data/datasources/remote/igdb/models/character/character_field_sets.dart';
import 'package:gamer_grove/data/datasources/remote/igdb/models/character/character_filters.dart';
import 'package:gamer_grove/data/datasources/remote/igdb/models/igdb_filters.dart';
import 'package:gamer_grove/data/datasources/remote/igdb/models/igdb_query.dart';
import 'package:gamer_grove/domain/entities/character/character_gender.dart';
import 'package:gamer_grove/domain/entities/character/character_species.dart';

/// Pre-configured query presets for common character queries.
///
/// These presets provide convenient, optimized queries for common scenarios.
class CharacterQueryPresets {
  CharacterQueryPresets._(); // Private constructor to prevent instantiation

  // ============================================================
  // BASIC QUERIES
  // ============================================================

  /// Basic list query with standard fields
  static IgdbCharacterQuery basicList({
    IgdbFilter? filter,
    int limit = 20,
    int offset = 0,
    String sort = 'name asc',
  }) {
    return IgdbCharacterQuery(
      where: filter,
      fields: CharacterFieldSets.standard,
      limit: limit,
      offset: offset,
      sort: sort,
    );
  }

  /// Minimal list query for dropdowns/autocomplete
  static IgdbCharacterQuery minimalList({
    IgdbFilter? filter,
    int limit = 50,
    int offset = 0,
  }) {
    return IgdbCharacterQuery(
      where: filter,
      fields: CharacterFieldSets.minimal,
      limit: limit,
      offset: offset,
      sort: 'name asc',
    );
  }

  /// Full details query for detail pages
  static IgdbCharacterQuery fullDetails({
    required int characterId,
  }) {
    return IgdbCharacterQuery(
      where: FieldFilter('id', '=', characterId),
      fields: CharacterFieldSets.complete,
      limit: 1,
    );
  }

  /// Search query optimized for text search
  static IgdbCharacterQuery search({
    required String searchTerm,
    int limit = 20,
    int offset = 0,
  }) {
    return IgdbCharacterQuery(
      where: CharacterFilters.searchByName(searchTerm),
      fields: CharacterFieldSets.search,
      limit: limit,
      offset: offset,
      sort: 'name asc',
    );
  }

  // ============================================================
  // POPULAR & FEATURED
  // ============================================================

  /// Popular characters (sorted by name since IGDB doesn't have popularity for characters)
  static IgdbCharacterQuery popular({
    int limit = 20,
    int offset = 0,
  }) {
    final filter = CombinedFilter([
      CharacterFilters.hasMugShot(),
      CharacterFilters.hasGames(),
    ]);

    return IgdbCharacterQuery(
      where: filter,
      fields: CharacterFieldSets.standard,
      limit: limit,
      offset: offset,
    );
  }

  /// Characters with descriptions (more complete profiles)
  static IgdbCharacterQuery withDescriptions({
    int limit = 20,
    int offset = 0,
  }) {
    final filter = CombinedFilter([
      CharacterFilters.hasDescription(),
      CharacterFilters.hasMugShot(),
    ]);

    return IgdbCharacterQuery(
      where: filter,
      fields: CharacterFieldSets.standard,
      limit: limit,
      offset: offset,
      sort: 'name asc',
    );
  }

  // ============================================================
  // GAME-SPECIFIC QUERIES
  // ============================================================

  /// Characters from a specific game
  static IgdbCharacterQuery fromGame({
    required int gameId,
    int limit = 50,
    int offset = 0,
  }) {
    return IgdbCharacterQuery(
      where: CharacterFilters.byGame(gameId),
      fields: CharacterFieldSets.gameCharacters,
      limit: limit,
      offset: offset,
      sort: 'name asc',
    );
  }

  /// Characters that appear in multiple games (franchise characters)
  static IgdbCharacterQuery fromGames({
    required List<int> gameIds,
    int limit = 50,
    int offset = 0,
  }) {
    return IgdbCharacterQuery(
      where: CharacterFilters.byGames(gameIds),
      fields: CharacterFieldSets.standard,
      limit: limit,
      offset: offset,
      sort: 'name asc',
    );
  }

  // ============================================================
  // GENDER-SPECIFIC QUERIES
  // ============================================================

  /// Female characters only
  static IgdbCharacterQuery femaleCharacters({
    int limit = 20,
    int offset = 0,
  }) {
    final filter = CombinedFilter([
      CharacterFilters.femaleOnly(),
      CharacterFilters.hasMugShot(),
    ]);

    return IgdbCharacterQuery(
      where: filter,
      fields: CharacterFieldSets.standard,
      limit: limit,
      offset: offset,
      sort: 'name asc',
    );
  }

  /// Male characters only
  static IgdbCharacterQuery maleCharacters({
    int limit = 20,
    int offset = 0,
  }) {
    final filter = CombinedFilter([
      CharacterFilters.maleOnly(),
      CharacterFilters.hasMugShot(),
    ]);

    return IgdbCharacterQuery(
      where: filter,
      fields: CharacterFieldSets.standard,
      limit: limit,
      offset: offset,
      sort: 'name asc',
    );
  }

  /// Characters by gender
  static IgdbCharacterQuery byGender({
    required CharacterGenderEnum gender,
    int limit = 20,
    int offset = 0,
  }) {
    final filter = CombinedFilter([
      CharacterFilters.byGender(gender),
      CharacterFilters.hasMugShot(),
    ]);

    return IgdbCharacterQuery(
      where: filter,
      fields: CharacterFieldSets.standard,
      limit: limit,
      offset: offset,
      sort: 'name asc',
    );
  }

  // ============================================================
  // SPECIES-SPECIFIC QUERIES
  // ============================================================

  /// Human characters only
  static IgdbCharacterQuery humanCharacters({
    int limit = 20,
    int offset = 0,
  }) {
    final filter = CombinedFilter([
      CharacterFilters.humanOnly(),
      CharacterFilters.hasMugShot(),
    ]);

    return IgdbCharacterQuery(
      where: filter,
      fields: CharacterFieldSets.standard,
      limit: limit,
      offset: offset,
      sort: 'name asc',
    );
  }

  /// Alien characters only
  static IgdbCharacterQuery alienCharacters({
    int limit = 20,
    int offset = 0,
  }) {
    final filter = CombinedFilter([
      CharacterFilters.alienOnly(),
      CharacterFilters.hasMugShot(),
    ]);

    return IgdbCharacterQuery(
      where: filter,
      fields: CharacterFieldSets.standard,
      limit: limit,
      offset: offset,
      sort: 'name asc',
    );
  }

  /// Android characters only
  static IgdbCharacterQuery androidCharacters({
    int limit = 20,
    int offset = 0,
  }) {
    final filter = CombinedFilter([
      CharacterFilters.androidOnly(),
      CharacterFilters.hasMugShot(),
    ]);

    return IgdbCharacterQuery(
      where: filter,
      fields: CharacterFieldSets.standard,
      limit: limit,
      offset: offset,
      sort: 'name asc',
    );
  }

  /// Characters by species
  static IgdbCharacterQuery bySpecies({
    required CharacterSpeciesEnum species,
    int limit = 20,
    int offset = 0,
  }) {
    final filter = CombinedFilter([
      CharacterFilters.bySpecies(species),
      CharacterFilters.hasMugShot(),
    ]);

    return IgdbCharacterQuery(
      where: filter,
      fields: CharacterFieldSets.standard,
      limit: limit,
      offset: offset,
      sort: 'name asc',
    );
  }

  // ============================================================
  // COUNTRY-SPECIFIC QUERIES
  // ============================================================

  /// Characters from a specific country
  static IgdbCharacterQuery fromCountry({
    required String countryName,
    int limit = 20,
    int offset = 0,
  }) {
    return IgdbCharacterQuery(
      where: CharacterFilters.byCountry(countryName),
      fields: CharacterFieldSets.standard,
      limit: limit,
      offset: offset,
      sort: 'name asc',
    );
  }
}
