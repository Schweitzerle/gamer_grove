// lib/data/datasources/remote/igdb/models/company/company_query_presets.dart

import '../igdb_query.dart';
import '../igdb_filters.dart';
import 'company_field_sets.dart';
import 'company_filters.dart';

/// Pre-configured query presets for common company queries.
class CompanyQueryPresets {
  CompanyQueryPresets._();

  // ============================================================
  // BASIC QUERIES
  // ============================================================

  /// Basic list query
  static IgdbCompanyQuery basicList({
    IgdbFilter? filter,
    int limit = 20,
    int offset = 0,
    String sort = 'name asc',
  }) {
    return IgdbCompanyQuery(
      where: filter,
      fields: CompanyFieldSets.standard,
      limit: limit,
      offset: offset,
      sort: sort,
    );
  }

  /// Minimal list for dropdowns
  static IgdbCompanyQuery minimalList({
    IgdbFilter? filter,
    int limit = 100,
    int offset = 0,
  }) {
    return IgdbCompanyQuery(
      where: filter,
      fields: CompanyFieldSets.minimal,
      limit: limit,
      offset: offset,
      sort: 'name asc',
    );
  }

  /// Full details
  static IgdbCompanyQuery fullDetails({
    required int companyId,
  }) {
    return IgdbCompanyQuery(
      where: FieldFilter('id', '=', companyId),
      fields: CompanyFieldSets.complete,
      limit: 1,
    );
  }

  /// Search query
  static IgdbCompanyQuery search({
    required String searchTerm,
    int limit = 20,
    int offset = 0,
  }) {
    return IgdbCompanyQuery(
      where: CompanyFilters.searchByName(searchTerm),
      fields: CompanyFieldSets.search,
      limit: limit,
      offset: offset,
      sort: 'name asc',
    );
  }

  // ============================================================
  // TYPE-SPECIFIC QUERIES
  // ============================================================

  /// Game developers
  static IgdbCompanyQuery developers({
    int limit = 50,
    int offset = 0,
  }) {
    final filter = CombinedFilter([
      CompanyFilters.developersOnly(),
      CompanyFilters.hasLogo(),
    ]);

    return IgdbCompanyQuery(
      where: filter,
      fields: CompanyFieldSets.standard,
      limit: limit,
      offset: offset,
      sort: 'name asc',
    );
  }

  /// Game publishers
  static IgdbCompanyQuery publishers({
    int limit = 50,
    int offset = 0,
  }) {
    final filter = CombinedFilter([
      CompanyFilters.publishersOnly(),
      CompanyFilters.hasLogo(),
    ]);

    return IgdbCompanyQuery(
      where: filter,
      fields: CompanyFieldSets.standard,
      limit: limit,
      offset: offset,
      sort: 'name asc',
    );
  }

  /// Independent companies
  static IgdbCompanyQuery independent({
    int limit = 50,
    int offset = 0,
  }) {
    final filter = CombinedFilter([
      CompanyFilters.independentOnly(),
      CompanyFilters.hasLogo(),
    ]);

    return IgdbCompanyQuery(
      where: filter,
      fields: CompanyFieldSets.standard,
      limit: limit,
      offset: offset,
      sort: 'name asc',
    );
  }

  // ============================================================
  // LOCATION-BASED QUERIES
  // ============================================================

  /// Companies from specific country
  static IgdbCompanyQuery fromCountry({
    required int countryCode,
    int limit = 50,
    int offset = 0,
  }) {
    return IgdbCompanyQuery(
      where: CompanyFilters.byCountry(countryCode),
      fields: CompanyFieldSets.standard,
      limit: limit,
      offset: offset,
      sort: 'name asc',
    );
  }

  // ============================================================
  // HIERARCHY QUERIES
  // ============================================================

  /// Subsidiaries of a parent company
  static IgdbCompanyQuery subsidiariesOf({
    required int parentCompanyId,
    int limit = 50,
    int offset = 0,
  }) {
    return IgdbCompanyQuery(
      where: CompanyFilters.byParentCompany(parentCompanyId),
      fields: CompanyFieldSets.standard,
      limit: limit,
      offset: offset,
      sort: 'name asc',
    );
  }
}
