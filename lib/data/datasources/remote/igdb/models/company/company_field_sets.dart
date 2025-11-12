// lib/data/datasources/remote/igdb/models/company/company_field_sets.dart

/// Pre-defined field sets for company queries.
class CompanyFieldSets {
  CompanyFieldSets._();

  /// Minimal fields for autocomplete/dropdowns
  static const List<String> minimal = [
    'id',
    'name',
    'slug',
  ];

  /// Basic fields for company lists
  static const List<String> basic = [
    'id',
    'name',
    'slug',
    'country',
    'logo.url',
    'logo.image_id',
    'developed',
    'published',
  ];

  /// Standard fields for most views
  static const List<String> standard = [
    'id',
    'name',
    'slug',
    'description',
    'country',
    'start_date',
    // Logo
    'logo.id',
    'logo.url',
    'logo.image_id',
    'logo.width',
    'logo.height',
    // Relationships
    'parent',
    'developed',
    'published',
    // Metadata
    'created_at',
    'updated_at',
    'checksum',
  ];

  /// Complete fields for company detail pages
  static const List<String> complete = [
    '*',
    // Full logo details
    'logo.*',
    // Parent company
    'parent.id',
    'parent.name',
    'parent.slug',
    'parent.description',
    'parent.logo.*',
    // Websites
    'websites.id',
    'websites.url',
    'websites.category',
    'websites.type.*',
    // Games developed
    'developed.id',
    'developed.name',
    'developed.slug',
    'developed.cover.url',
    // Games published
    'published.id',
    'published.name',
    'published.slug',
    'published.cover.url',
  ];

  /// Fields for company search results
  static const List<String> search = [
    'id',
    'name',
    'slug',
    'description',
    'country',
    'logo.url',
    'logo.image_id',
    'developed',
    'published',
  ];

  /// Fields for game detail pages (showing companies)
  static const List<String> gameCompanies = [
    'id',
    'name',
    'slug',
    'country',
    'logo.url',
    'logo.image_id',
  ];
}
