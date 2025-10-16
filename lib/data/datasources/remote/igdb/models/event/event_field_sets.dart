// lib/data/datasources/remote/igdb/models/event/event_field_sets.dart

/// Pre-defined field sets for event queries.
class EventFieldSets {
  EventFieldSets._();

  /// Minimal fields for autocomplete/dropdowns
  static const List<String> minimal = [
    'id',
    'name',
    'slug',
  ];

  /// Basic fields for event lists
  static const List<String> basic = [
    'id',
    'name',
    'slug',
    'start_time',
    'end_time',
    'event_logo.url',
    'event_logo.image_id',
    'live_stream_url',
  ];

  /// Standard fields for most views
  static const List<String> standard = [
    'id',
    'name',
    'slug',
    'description',
    'start_time',
    'end_time',
    'time_zone',
    'live_stream_url',
    // Logo
    'event_logo.id',
    'event_logo.url',
    'event_logo.image_id',
    'event_logo.width',
    'event_logo.height',
    // Networks
    'event_networks.id',
    'event_networks.url',
    'event_networks.network_type',
    // Videos
    'videos.id',
    'videos.video_id',
    'videos.name',
    // Games
    'games.id',
    'games.name',
    'games.slug',
    'games.cover.url',
    // Metadata
    'created_at',
    'updated_at',
    'checksum',
  ];

  /// Complete fields for event detail pages
  static const List<String> complete = [
    '*',
    // Full logo details
    'event_logo.*',
    // Networks with full details
    'event_networks.id',
    'event_networks.url',
    'event_networks.network_type',
    'event_networks.event',
    // Videos with details
    'videos.id',
    'videos.video_id',
    'videos.name',
    'videos.checksum',
    // Games with covers and details
    'games.id',
    'games.name',
    'games.slug',
    'games.summary',
    'games.cover.*',
    'games.first_release_date',
    'games.total_rating',
  ];

  /// Fields for search results
  static const List<String> search = [
    'id',
    'name',
    'slug',
    'description',
    'start_time',
    'end_time',
    'event_logo.url',
    'event_logo.image_id',
    'live_stream_url',
  ];

  /// Fields for event cards/lists
  static const List<String> cards = [
    'id',
    'name',
    'slug',
    'description',
    'start_time',
    'end_time',
    'event_logo.url',
    'event_logo.image_id',
    'games.id',
    'games.name',
    'games.cover.url',
  ];
}
