// lib/data/datasources/remote/igdb/models/event/event_filters.dart

import '../igdb_filters.dart';

/// Pre-configured filters for common event queries.
class EventFilters {
  EventFilters._();

  // ============================================================
  // TIME-BASED FILTERS
  // ============================================================

  /// Filter events starting after a specific date
  static IgdbFilter startsAfter(DateTime date) =>
      FieldFilter('start_time', '>', _toUnixTimestamp(date));

  /// Filter events starting before a specific date
  static IgdbFilter startsBefore(DateTime date) =>
      FieldFilter('start_time', '<', _toUnixTimestamp(date));

  /// Filter events ending after a specific date
  static IgdbFilter endsAfter(DateTime date) =>
      FieldFilter('end_time', '>', _toUnixTimestamp(date));

  /// Filter events ending before a specific date
  static IgdbFilter endsBefore(DateTime date) =>
      FieldFilter('end_time', '<', _toUnixTimestamp(date));

  /// Filter events happening between two dates
  static IgdbFilter between(DateTime start, DateTime end) => CombinedFilter([
        FieldFilter('start_time', '>=', _toUnixTimestamp(start)),
        FieldFilter('end_time', '<=', _toUnixTimestamp(end)),
      ]);

  /// Filter upcoming events (starting in the future)
  static IgdbFilter upcoming() => startsAfter(DateTime.now());

  /// Filter ongoing events (currently happening)
  static IgdbFilter ongoing() {
    final now = DateTime.now();
    return CombinedFilter([
      FieldFilter('start_time', '<=', _toUnixTimestamp(now)),
      FieldFilter('end_time', '>=', _toUnixTimestamp(now)),
    ]);
  }

  /// Filter past events (already ended)
  static IgdbFilter past() => endsBefore(DateTime.now());

  // ============================================================
  // GAME FILTERS
  // ============================================================

  /// Filter events featuring a specific game
  static IgdbFilter byGame(int gameId) => ContainsFilter('games', [gameId]);

  /// Filter events featuring any of the specified games
  static IgdbFilter byGames(List<int> gameIds) =>
      ContainsFilter('games', gameIds);

  // ============================================================
  // SEARCH & NAME FILTERS
  // ============================================================

  /// Search events by name
  static IgdbFilter searchByName(String query) =>
      FieldFilter('name', '~', query);

  // ============================================================
  // EXISTENCE FILTERS
  // ============================================================

  /// Filter events that have a logo
  static IgdbFilter hasLogo() => NullFilter('event_logo', isNull: false);

  /// Filter events that have a description
  static IgdbFilter hasDescription() =>
      NullFilter('description', isNull: false);

  /// Filter events that have a live stream URL
  static IgdbFilter hasLiveStream() =>
      NullFilter('live_stream_url', isNull: false);

  /// Filter events that have videos
  static IgdbFilter hasVideos() => NullFilter('videos', isNull: false);

  /// Filter events that feature games
  static IgdbFilter hasGames() => NullFilter('games', isNull: false);

  // ============================================================
  // HELPER METHODS
  // ============================================================

  static int _toUnixTimestamp(DateTime date) =>
      date.millisecondsSinceEpoch ~/ 1000;
}

/// Builder for creating complex event filters.
class EventFilterBuilder {
  final List<IgdbFilter> _filters = [];

  EventFilterBuilder();

  // Time methods
  EventFilterBuilder startsAfter(DateTime date) {
    _filters.add(EventFilters.startsAfter(date));
    return this;
  }

  EventFilterBuilder startsBefore(DateTime date) {
    _filters.add(EventFilters.startsBefore(date));
    return this;
  }

  EventFilterBuilder endsAfter(DateTime date) {
    _filters.add(EventFilters.endsAfter(date));
    return this;
  }

  EventFilterBuilder endsBefore(DateTime date) {
    _filters.add(EventFilters.endsBefore(date));
    return this;
  }

  EventFilterBuilder upcomingOnly() {
    _filters.add(EventFilters.upcoming());
    return this;
  }

  EventFilterBuilder ongoingOnly() {
    _filters.add(EventFilters.ongoing());
    return this;
  }

  EventFilterBuilder pastOnly() {
    _filters.add(EventFilters.past());
    return this;
  }

  // Game methods
  EventFilterBuilder featuringGame(int gameId) {
    _filters.add(EventFilters.byGame(gameId));
    return this;
  }

  EventFilterBuilder featuringGames(List<int> gameIds) {
    _filters.add(EventFilters.byGames(gameIds));
    return this;
  }

  // Existence methods
  EventFilterBuilder withLogo() {
    _filters.add(EventFilters.hasLogo());
    return this;
  }

  EventFilterBuilder withDescription() {
    _filters.add(EventFilters.hasDescription());
    return this;
  }

  EventFilterBuilder withLiveStream() {
    _filters.add(EventFilters.hasLiveStream());
    return this;
  }

  EventFilterBuilder withVideos() {
    _filters.add(EventFilters.hasVideos());
    return this;
  }

  EventFilterBuilder withGames() {
    _filters.add(EventFilters.hasGames());
    return this;
  }

  // Search methods
  EventFilterBuilder searchByName(String query) {
    _filters.add(EventFilters.searchByName(query));
    return this;
  }

  // Custom filter
  EventFilterBuilder addCustomFilter(IgdbFilter filter) {
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
