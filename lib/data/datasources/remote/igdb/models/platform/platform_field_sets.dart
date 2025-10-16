// lib/data/datasources/remote/igdb/models/platform/platform_field_sets.dart

/// Pre-defined field sets for platform queries.
class PlatformFieldSets {
  PlatformFieldSets._();

  /// Minimal fields for autocomplete/dropdowns
  static const List<String> minimal = [
    'id',
    'name',
    'abbreviation',
    'slug',
  ];

  /// Basic fields for platform lists
  static const List<String> basic = [
    'id',
    'name',
    'abbreviation',
    'slug',
    'category',
    'generation',
    'platform_logo.url',
    'platform_logo.image_id',
  ];

  /// Standard fields for most views
  static const List<String> standard = [
    'id',
    'name',
    'abbreviation',
    'slug',
    'summary',
    'category',
    'generation',
    // Logo
    'platform_logo.id',
    'platform_logo.url',
    'platform_logo.image_id',
    'platform_logo.width',
    'platform_logo.height',
    // Platform Family
    'platform_family.id',
    'platform_family.name',
    'platform_family.slug',
    // Metadata
    'created_at',
    'updated_at',
    'checksum',
  ];

  /// Complete fields for platform detail pages
  static const List<String> complete = [
    '*',
    // Full logo details
    'platform_logo.*',
    // Platform family
    'platform_family.*',
    // Versions
    'versions.id',
    'versions.name',
    'versions.summary',
    'versions.url',
    // Websites
    'websites.id',
    'websites.url',
    'websites.category',
  ];

  /// Fields for platform search results
  static const List<String> search = [
    'id',
    'name',
    'abbreviation',
    'slug',
    'summary',
    'category',
    'generation',
    'platform_logo.url',
    'platform_logo.image_id',
  ];

  /// Fields for game detail pages (showing platforms)
  static const List<String> gamePlatforms = [
    'id',
    'name',
    'abbreviation',
    'slug',
    'category',
    'platform_logo.url',
    'platform_logo.image_id',
  ];
}
