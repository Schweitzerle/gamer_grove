// lib/data/datasources/remote/igdb/models/character/character_field_sets.dart

/// Pre-defined field sets for character queries.
///
/// These field sets are optimized for different use cases to reduce
/// data transfer and improve performance.
class CharacterFieldSets {
  CharacterFieldSets._(); // Private constructor to prevent instantiation

  /// Minimal fields for autocomplete/dropdowns
  /// ~0.3KB per character
  static const List<String> minimal = [
    'id',
    'name',
    'slug',
  ];

  /// Basic fields for character lists
  /// ~1KB per character
  static const List<String> basic = [
    'id',
    'name',
    'slug',
    'mug_shot.url',
    'mug_shot.image_id',
    'games',
  ];

  /// Standard fields for most views
  /// ~3KB per character
  static const List<String> standard = [
    'id',
    'name',
    'slug',
    'description',
    'country_name',
    'character_gender',
    'character_species',
    'gender', // deprecated but kept for compatibility
    'species', // deprecated but kept for compatibility
    // Mug Shot
    'mug_shot.id',
    'mug_shot.url',
    'mug_shot.image_id',
    'mug_shot.width',
    'mug_shot.height',
    // Games
    'games.id',
    'games.name',
    'games.slug',
    'games.cover.url',
    'games.cover.image_id',
    // Metadata
    'created_at',
    'updated_at',
    'checksum',
  ];

  /// Complete fields for character detail pages
  /// ~5KB per character
  static const List<String> complete = [
    '*',
    // Full Mug Shot details
    'mug_shot.*',
    // Full game details with covers and ratings
    'games.id',
    'games.name',
    'games.slug',
    'games.summary',
    'games.first_release_date',
    'games.category',
    'games.cover.*',
    'games.total_rating',
    'games.aggregated_rating',
    'games.genres.id',
    'games.genres.name',
    'games.platforms.id',
    'games.platforms.name',
    'games.platforms.abbreviation',
  ];

  /// Fields for character search results
  /// ~2KB per character
  static const List<String> search = [
    'id',
    'name',
    'slug',
    'description',
    'mug_shot.url',
    'mug_shot.image_id',
    'character_gender',
    'character_species',
    'gender', // deprecated but kept for compatibility
    'species', // deprecated but kept for compatibility
    'games.id',
    'games.name',
  ];

  /// Fields for game detail pages (showing characters of a game)
  /// ~2KB per character
  static const List<String> gameCharacters = [
    'id',
    'name',
    'slug',
    'description',
    'mug_shot.url',
    'mug_shot.image_id',
    'character_gender',
    'character_species',
    'gender', // deprecated but kept for compatibility
    'species', // deprecated but kept for compatibility
    'country_name',
  ];
}
