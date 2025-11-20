// lib/data/datasources/remote/igdb/models/platform/platform_filters.dart

import 'package:gamer_grove/data/datasources/remote/igdb/models/igdb_filters.dart';

/// Pre-configured filters for common platform queries.
class PlatformFilters {
  PlatformFilters._();

  // ============================================================
  // CATEGORY FILTERS
  // ============================================================

  /// Filter platforms by category
  ///
  /// Categories:
  /// - 1: Console
  /// - 2: Arcade
  /// - 3: Platform (generic)
  /// - 4: Operating System
  /// - 5: Portable Console
  /// - 6: Computer
  static IgdbFilter byCategory(int category) =>
      FieldFilter('category', '=', category);

  /// Filter only game consoles
  static IgdbFilter consolesOnly() => byCategory(1);

  /// Filter only arcade platforms
  static IgdbFilter arcadeOnly() => byCategory(2);

  /// Filter only operating systems
  static IgdbFilter operatingSystemsOnly() => byCategory(4);

  /// Filter only portable consoles
  static IgdbFilter portableConsolesOnly() => byCategory(5);

  /// Filter only computers
  static IgdbFilter computersOnly() => byCategory(6);

  // ============================================================
  // GENERATION FILTERS
  // ============================================================

  /// Filter platforms by generation
  static IgdbFilter byGeneration(int generation) =>
      FieldFilter('generation', '=', generation);

  /// Filter current generation platforms (9th gen)
  static IgdbFilter currentGen() => byGeneration(9);

  /// Filter last generation platforms (8th gen)
  static IgdbFilter lastGen() => byGeneration(8);

  // ============================================================
  // PLATFORM FAMILY FILTERS
  // ============================================================

  /// Filter platforms by platform family
  static IgdbFilter byPlatformFamily(int platformFamilyId) =>
      FieldFilter('platform_family', '=', platformFamilyId);

  /// Filter PlayStation family platforms
  static IgdbFilter playstationFamily() => byPlatformFamily(1);

  /// Filter Xbox family platforms
  static IgdbFilter xboxFamily() => byPlatformFamily(2);

  /// Filter Nintendo family platforms
  static IgdbFilter nintendoFamily() => byPlatformFamily(5);

  // ============================================================
  // SEARCH & NAME FILTERS
  // ============================================================

  /// Search platforms by name
  static IgdbFilter searchByName(String query) =>
      FieldFilter('name', '~', query);

  // ============================================================
  // EXISTENCE FILTERS
  // ============================================================

  /// Filter platforms that have a logo
  static IgdbFilter hasLogo() => const NullFilter('platform_logo', isNull: false);

  /// Filter platforms that have a summary
  static IgdbFilter hasSummary() => const NullFilter('summary', isNull: false);
}

/// Builder for creating complex platform filters.
class PlatformFilterBuilder {

  PlatformFilterBuilder();
  final List<IgdbFilter> _filters = [];

  // Category methods
  PlatformFilterBuilder withCategory(int category) {
    _filters.add(PlatformFilters.byCategory(category));
    return this;
  }

  PlatformFilterBuilder consolesOnly() {
    _filters.add(PlatformFilters.consolesOnly());
    return this;
  }

  PlatformFilterBuilder portableOnly() {
    _filters.add(PlatformFilters.portableConsolesOnly());
    return this;
  }

  // Generation methods
  PlatformFilterBuilder withGeneration(int generation) {
    _filters.add(PlatformFilters.byGeneration(generation));
    return this;
  }

  PlatformFilterBuilder currentGenOnly() {
    _filters.add(PlatformFilters.currentGen());
    return this;
  }

  // Platform family methods
  PlatformFilterBuilder withPlatformFamily(int familyId) {
    _filters.add(PlatformFilters.byPlatformFamily(familyId));
    return this;
  }

  PlatformFilterBuilder playstationOnly() {
    _filters.add(PlatformFilters.playstationFamily());
    return this;
  }

  PlatformFilterBuilder xboxOnly() {
    _filters.add(PlatformFilters.xboxFamily());
    return this;
  }

  PlatformFilterBuilder nintendoOnly() {
    _filters.add(PlatformFilters.nintendoFamily());
    return this;
  }

  // Existence methods
  PlatformFilterBuilder withLogo() {
    _filters.add(PlatformFilters.hasLogo());
    return this;
  }

  // Search methods
  PlatformFilterBuilder searchByName(String query) {
    _filters.add(PlatformFilters.searchByName(query));
    return this;
  }

  // Custom filter
  PlatformFilterBuilder addCustomFilter(IgdbFilter filter) {
    _filters.add(filter);
    return this;
  }

  // Build
  IgdbFilter? build() {
    if (_filters.isEmpty) return null;
    if (_filters.length == 1) return _filters.first;
    return CombinedFilter(_filters);
  }
}
