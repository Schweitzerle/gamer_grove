// lib/data/datasources/remote/igdb/models/game_engine/game_engine_query_presets.dart

import 'package:gamer_grove/data/datasources/remote/igdb/models/game_engine/game_engine_field_sets.dart';
import 'package:gamer_grove/data/datasources/remote/igdb/models/game_engine/game_engine_filters.dart';
import 'package:gamer_grove/data/datasources/remote/igdb/models/igdb_filters.dart';
import 'package:gamer_grove/data/datasources/remote/igdb/models/igdb_query.dart';

/// Pre-configured query presets for common game engine queries.
class GameEngineQueryPresets {
  GameEngineQueryPresets._();

  // ============================================================
  // BASIC QUERIES
  // ============================================================

  /// Basic list query
  static IgdbGameEngineQuery basicList({
    IgdbFilter? filter,
    int limit = 20,
    int offset = 0,
    String sort = 'name asc',
  }) {
    return IgdbGameEngineQuery(
      where: filter,
      fields: GameEngineFieldSets.standard,
      limit: limit,
      offset: offset,
      sort: sort,
    );
  }

  /// Minimal list for dropdowns
  static IgdbGameEngineQuery minimalList({
    IgdbFilter? filter,
    int limit = 100,
    int offset = 0,
  }) {
    return IgdbGameEngineQuery(
      where: filter,
      fields: GameEngineFieldSets.minimal,
      limit: limit,
      offset: offset,
      sort: 'name asc',
    );
  }

  /// Full details
  static IgdbGameEngineQuery fullDetails({
    required int gameEngineId,
  }) {
    return IgdbGameEngineQuery(
      where: FieldFilter('id', '=', gameEngineId),
      fields: GameEngineFieldSets.complete,
      limit: 1,
    );
  }

  /// Search query
  static IgdbGameEngineQuery search({
    required String searchTerm,
    int limit = 20,
    int offset = 0,
  }) {
    return IgdbGameEngineQuery(
      where: GameEngineFilters.searchByName(searchTerm),
      fields: GameEngineFieldSets.search,
      limit: limit,
      offset: offset,
      sort: 'name asc',
    );
  }

  // ============================================================
  // POPULAR & FEATURED
  // ============================================================

  /// Popular game engines (with logos and descriptions)
  static IgdbGameEngineQuery popular({
    int limit = 20,
    int offset = 0,
  }) {
    final filter = CombinedFilter([
      GameEngineFilters.hasLogo(),
      GameEngineFilters.hasDescription(),
    ]);

    return IgdbGameEngineQuery(
      where: filter,
      fields: GameEngineFieldSets.standard,
      limit: limit,
      offset: offset,
      sort: 'name asc',
    );
  }

  // ============================================================
  // COMPANY-SPECIFIC QUERIES
  // ============================================================

  /// Game engines by company
  static IgdbGameEngineQuery byCompany({
    required int companyId,
    int limit = 50,
    int offset = 0,
  }) {
    return IgdbGameEngineQuery(
      where: GameEngineFilters.byCompany(companyId),
      fields: GameEngineFieldSets.standard,
      limit: limit,
      offset: offset,
      sort: 'name asc',
    );
  }

  // ============================================================
  // PLATFORM-SPECIFIC QUERIES
  // ============================================================

  /// Game engines supporting a specific platform
  static IgdbGameEngineQuery byPlatform({
    required int platformId,
    int limit = 50,
    int offset = 0,
  }) {
    return IgdbGameEngineQuery(
      where: GameEngineFilters.byPlatform(platformId),
      fields: GameEngineFieldSets.standard,
      limit: limit,
      offset: offset,
      sort: 'name asc',
    );
  }
}
