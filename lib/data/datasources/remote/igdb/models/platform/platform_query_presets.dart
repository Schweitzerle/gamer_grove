// lib/data/datasources/remote/igdb/models/platform/platform_query_presets.dart

import 'package:gamer_grove/data/datasources/remote/igdb/models/igdb_filters.dart';
import 'package:gamer_grove/data/datasources/remote/igdb/models/igdb_query.dart';
import 'package:gamer_grove/data/datasources/remote/igdb/models/platform/platform_field_sets.dart';
import 'package:gamer_grove/data/datasources/remote/igdb/models/platform/platform_filters.dart';

/// Pre-configured query presets for common platform queries.
class PlatformQueryPresets {
  PlatformQueryPresets._();

  // ============================================================
  // BASIC QUERIES
  // ============================================================

  /// Basic list query
  static IgdbPlatformQuery basicList({
    IgdbFilter? filter,
    int limit = 20,
    int offset = 0,
    String sort = 'name asc',
  }) {
    return IgdbPlatformQuery(
      where: filter,
      fields: PlatformFieldSets.standard,
      limit: limit,
      offset: offset,
      sort: sort,
    );
  }

  /// Minimal list for dropdowns
  static IgdbPlatformQuery minimalList({
    IgdbFilter? filter,
    int limit = 100,
    int offset = 0,
  }) {
    return IgdbPlatformQuery(
      where: filter,
      fields: PlatformFieldSets.minimal,
      limit: limit,
      offset: offset,
      sort: 'name asc',
    );
  }

  /// Full details
  static IgdbPlatformQuery fullDetails({
    required int platformId,
  }) {
    return IgdbPlatformQuery(
      where: FieldFilter('id', '=', platformId),
      fields: PlatformFieldSets.complete,
      limit: 1,
    );
  }

  /// Search query
  static IgdbPlatformQuery search({
    required String searchTerm,
    int limit = 20,
    int offset = 0,
  }) {
    return IgdbPlatformQuery(
      where: PlatformFilters.searchByName(searchTerm),
      fields: PlatformFieldSets.search,
      limit: limit,
      offset: offset,
      sort: 'name asc',
    );
  }

  // ============================================================
  // CATEGORY-SPECIFIC QUERIES
  // ============================================================

  /// All game consoles
  static IgdbPlatformQuery consoles({
    int limit = 50,
    int offset = 0,
  }) {
    return IgdbPlatformQuery(
      where: PlatformFilters.consolesOnly(),
      fields: PlatformFieldSets.standard,
      limit: limit,
      offset: offset,
      sort: 'generation desc, name asc',
    );
  }

  /// Portable consoles
  static IgdbPlatformQuery portableConsoles({
    int limit = 50,
    int offset = 0,
  }) {
    return IgdbPlatformQuery(
      where: PlatformFilters.portableConsolesOnly(),
      fields: PlatformFieldSets.standard,
      limit: limit,
      offset: offset,
      sort: 'generation desc, name asc',
    );
  }

  /// Current generation platforms
  static IgdbPlatformQuery currentGeneration({
    int limit = 20,
    int offset = 0,
  }) {
    final filter = CombinedFilter([
      PlatformFilters.currentGen(),
      PlatformFilters.hasLogo(),
    ]);

    return IgdbPlatformQuery(
      where: filter,
      fields: PlatformFieldSets.standard,
      limit: limit,
      offset: offset,
      sort: 'name asc',
    );
  }

  // ============================================================
  // PLATFORM FAMILY QUERIES
  // ============================================================

  /// PlayStation platforms
  static IgdbPlatformQuery playstationPlatforms({
    int limit = 20,
    int offset = 0,
  }) {
    return IgdbPlatformQuery(
      where: PlatformFilters.playstationFamily(),
      fields: PlatformFieldSets.standard,
      limit: limit,
      offset: offset,
      sort: 'generation desc',
    );
  }

  /// Xbox platforms
  static IgdbPlatformQuery xboxPlatforms({
    int limit = 20,
    int offset = 0,
  }) {
    return IgdbPlatformQuery(
      where: PlatformFilters.xboxFamily(),
      fields: PlatformFieldSets.standard,
      limit: limit,
      offset: offset,
      sort: 'generation desc',
    );
  }

  /// Nintendo platforms
  static IgdbPlatformQuery nintendoPlatforms({
    int limit = 20,
    int offset = 0,
  }) {
    return IgdbPlatformQuery(
      where: PlatformFilters.nintendoFamily(),
      fields: PlatformFieldSets.standard,
      limit: limit,
      offset: offset,
      sort: 'generation desc',
    );
  }
}
