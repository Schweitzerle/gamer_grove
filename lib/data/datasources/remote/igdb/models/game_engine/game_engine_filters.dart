// lib/data/datasources/remote/igdb/models/game_engine/game_engine_filters.dart

import 'package:gamer_grove/data/datasources/remote/igdb/models/igdb_filters.dart';

/// Pre-configured filters for common game engine queries.
class GameEngineFilters {
  GameEngineFilters._();

  // ============================================================
  // COMPANY FILTERS
  // ============================================================

  /// Filter game engines by company
  static IgdbFilter byCompany(int companyId) =>
      ContainsFilter('companies', [companyId]);

  /// Filter game engines by multiple companies
  static IgdbFilter byCompanies(List<int> companyIds) =>
      ContainsFilter('companies', companyIds);

  // ============================================================
  // PLATFORM FILTERS
  // ============================================================

  /// Filter game engines by platform
  static IgdbFilter byPlatform(int platformId) =>
      ContainsFilter('platforms', [platformId]);

  /// Filter game engines by multiple platforms
  static IgdbFilter byPlatforms(List<int> platformIds) =>
      ContainsFilter('platforms', platformIds);

  // ============================================================
  // SEARCH & NAME FILTERS
  // ============================================================

  /// Search game engines by name
  static IgdbFilter searchByName(String query) =>
      FieldFilter('name', '~', query);

  // ============================================================
  // EXISTENCE FILTERS
  // ============================================================

  /// Filter game engines that have a logo
  static IgdbFilter hasLogo() => const NullFilter('logo', isNull: false);

  /// Filter game engines that have a description
  static IgdbFilter hasDescription() =>
      const NullFilter('description', isNull: false);

  /// Filter game engines that have a URL
  static IgdbFilter hasUrl() => const NullFilter('url', isNull: false);

  /// Filter game engines that support platforms
  static IgdbFilter hasPlatforms() => const NullFilter('platforms', isNull: false);

  /// Filter game engines that have associated companies
  static IgdbFilter hasCompanies() => const NullFilter('companies', isNull: false);
}

/// Builder for creating complex game engine filters.
class GameEngineFilterBuilder {

  GameEngineFilterBuilder();
  final List<IgdbFilter> _filters = [];

  // Company methods
  GameEngineFilterBuilder byCompany(int companyId) {
    _filters.add(GameEngineFilters.byCompany(companyId));
    return this;
  }

  GameEngineFilterBuilder byCompanies(List<int> companyIds) {
    _filters.add(GameEngineFilters.byCompanies(companyIds));
    return this;
  }

  // Platform methods
  GameEngineFilterBuilder supportsPlatform(int platformId) {
    _filters.add(GameEngineFilters.byPlatform(platformId));
    return this;
  }

  GameEngineFilterBuilder supportsPlatforms(List<int> platformIds) {
    _filters.add(GameEngineFilters.byPlatforms(platformIds));
    return this;
  }

  // Existence methods
  GameEngineFilterBuilder withLogo() {
    _filters.add(GameEngineFilters.hasLogo());
    return this;
  }

  GameEngineFilterBuilder withDescription() {
    _filters.add(GameEngineFilters.hasDescription());
    return this;
  }

  GameEngineFilterBuilder withUrl() {
    _filters.add(GameEngineFilters.hasUrl());
    return this;
  }

  GameEngineFilterBuilder withPlatforms() {
    _filters.add(GameEngineFilters.hasPlatforms());
    return this;
  }

  GameEngineFilterBuilder withCompanies() {
    _filters.add(GameEngineFilters.hasCompanies());
    return this;
  }

  // Search methods
  GameEngineFilterBuilder searchByName(String query) {
    _filters.add(GameEngineFilters.searchByName(query));
    return this;
  }

  // Custom filter
  GameEngineFilterBuilder addCustomFilter(IgdbFilter filter) {
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
