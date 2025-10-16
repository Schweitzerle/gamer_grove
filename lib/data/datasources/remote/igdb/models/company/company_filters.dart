// lib/data/datasources/remote/igdb/models/company/company_filters.dart

import '../igdb_filters.dart';

/// Pre-configured filters for common company queries.
class CompanyFilters {
  CompanyFilters._();

  // ============================================================
  // RELATIONSHIP FILTERS
  // ============================================================

  /// Filter companies that have developed games
  static IgdbFilter hasDevelopedGames() =>
      NullFilter('developed', isNull: false);

  /// Filter companies that have published games
  static IgdbFilter hasPublishedGames() =>
      NullFilter('published', isNull: false);

  /// Filter companies that are developers
  static IgdbFilter developersOnly() => hasDevelopedGames();

  /// Filter companies that are publishers
  static IgdbFilter publishersOnly() => hasPublishedGames();

  // ============================================================
  // PARENT COMPANY FILTERS
  // ============================================================

  /// Filter companies by parent company
  static IgdbFilter byParentCompany(int parentCompanyId) =>
      FieldFilter('parent', '=', parentCompanyId);

  /// Filter independent companies (no parent)
  static IgdbFilter independentOnly() => NullFilter('parent', isNull: true);

  /// Filter subsidiary companies (has parent)
  static IgdbFilter subsidiariesOnly() => NullFilter('parent', isNull: false);

  // ============================================================
  // LOCATION FILTERS
  // ============================================================

  /// Filter companies by country code
  static IgdbFilter byCountry(int countryCode) =>
      FieldFilter('country', '=', countryCode);

  // ============================================================
  // DATE FILTERS
  // ============================================================

  /// Filter companies founded after date
  static IgdbFilter foundedAfter(DateTime date) =>
      FieldFilter('start_date', '>', _toUnixTimestamp(date));

  /// Filter companies founded before date
  static IgdbFilter foundedBefore(DateTime date) =>
      FieldFilter('start_date', '<', _toUnixTimestamp(date));

  // ============================================================
  // SEARCH & NAME FILTERS
  // ============================================================

  /// Search companies by name
  static IgdbFilter searchByName(String query) =>
      FieldFilter('name', '~', query);

  // ============================================================
  // EXISTENCE FILTERS
  // ============================================================

  /// Filter companies that have a logo
  static IgdbFilter hasLogo() => NullFilter('logo', isNull: false);

  /// Filter companies that have a description
  static IgdbFilter hasDescription() =>
      NullFilter('description', isNull: false);

  // ============================================================
  // HELPER METHODS
  // ============================================================

  static int _toUnixTimestamp(DateTime date) =>
      date.millisecondsSinceEpoch ~/ 1000;
}

/// Builder for creating complex company filters.
class CompanyFilterBuilder {
  final List<IgdbFilter> _filters = [];

  CompanyFilterBuilder();

  // Type methods
  CompanyFilterBuilder developersOnly() {
    _filters.add(CompanyFilters.developersOnly());
    return this;
  }

  CompanyFilterBuilder publishersOnly() {
    _filters.add(CompanyFilters.publishersOnly());
    return this;
  }

  // Parent methods
  CompanyFilterBuilder withParent(int parentId) {
    _filters.add(CompanyFilters.byParentCompany(parentId));
    return this;
  }

  CompanyFilterBuilder independentOnly() {
    _filters.add(CompanyFilters.independentOnly());
    return this;
  }

  // Location methods
  CompanyFilterBuilder fromCountry(int countryCode) {
    _filters.add(CompanyFilters.byCountry(countryCode));
    return this;
  }

  // Date methods
  CompanyFilterBuilder foundedAfter(DateTime date) {
    _filters.add(CompanyFilters.foundedAfter(date));
    return this;
  }

  CompanyFilterBuilder foundedBefore(DateTime date) {
    _filters.add(CompanyFilters.foundedBefore(date));
    return this;
  }

  // Existence methods
  CompanyFilterBuilder withLogo() {
    _filters.add(CompanyFilters.hasLogo());
    return this;
  }

  CompanyFilterBuilder withDescription() {
    _filters.add(CompanyFilters.hasDescription());
    return this;
  }

  // Search methods
  CompanyFilterBuilder searchByName(String query) {
    _filters.add(CompanyFilters.searchByName(query));
    return this;
  }

  // Custom filter
  CompanyFilterBuilder addCustomFilter(IgdbFilter filter) {
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
