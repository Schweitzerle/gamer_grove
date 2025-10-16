// lib/data/datasources/remote/igdb/models/game_engine/game_engine_field_sets.dart

/// Pre-defined field sets for game engine queries.
class GameEngineFieldSets {
  GameEngineFieldSets._();

  /// Minimal fields for autocomplete/dropdowns
  static const List<String> minimal = [
    'id',
    'name',
    'slug',
  ];

  /// Basic fields for game engine lists
  static const List<String> basic = [
    'id',
    'name',
    'slug',
    'url',
    'logo.url',
    'logo.image_id',
  ];

  /// Standard fields for most views
  static const List<String> standard = [
    'id',
    'name',
    'slug',
    'description',
    'url',
    // Logo
    'logo.id',
    'logo.url',
    'logo.image_id',
    'logo.width',
    'logo.height',
    // Companies
    'companies.id',
    'companies.name',
    'companies.slug',
    'companies.logo.url',
    // Platforms
    'platforms.id',
    'platforms.name',
    'platforms.abbreviation',
    // Metadata
    'created_at',
    'updated_at',
    'checksum',
  ];

  /// Complete fields for game engine detail pages
  static const List<String> complete = [
    '*',
    // Full logo details
    'logo.*',
    // Companies with logos
    'companies.id',
    'companies.name',
    'companies.slug',
    'companies.logo.*',
    'companies.country',
    // Platforms with details
    'platforms.id',
    'platforms.name',
    'platforms.abbreviation',
    'platforms.category',
    'platforms.platform_logo.*',
  ];

  /// Fields for search results
  static const List<String> search = [
    'id',
    'name',
    'slug',
    'description',
    'logo.url',
    'logo.image_id',
    'companies.name',
  ];

  /// Fields for game detail pages (showing game engines)
  static const List<String> gameEngines = [
    'id',
    'name',
    'slug',
    'logo.url',
    'logo.image_id',
    'url',
  ];
}
