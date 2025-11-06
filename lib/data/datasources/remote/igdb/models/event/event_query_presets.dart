// lib/data/datasources/remote/igdb/models/event/event_query_presets.dart

import '../igdb_query.dart';
import '../igdb_filters.dart';
import 'event_field_sets.dart';
import 'event_filters.dart';

/// Pre-configured query presets for common event queries.
class EventQueryPresets {
  EventQueryPresets._();

  // ============================================================
  // BASIC QUERIES
  // ============================================================

  /// Basic list query
  static IgdbEventQuery basicList({
    IgdbFilter? filter,
    int limit = 20,
    int offset = 0,
    String sort = 'start_time desc',
  }) {
    return IgdbEventQuery(
      where: filter,
      fields: EventFieldSets.standard,
      limit: limit,
      offset: offset,
      sort: sort,
    );
  }

  /// Minimal list for dropdowns
  static IgdbEventQuery minimalList({
    IgdbFilter? filter,
    int limit = 100,
    int offset = 0,
  }) {
    return IgdbEventQuery(
      where: filter,
      fields: EventFieldSets.minimal,
      limit: limit,
      offset: offset,
      sort: 'start_time desc',
    );
  }

  /// Full details
  static IgdbEventQuery fullDetails({
    required int eventId,
  }) {
    return IgdbEventQuery(
      where: FieldFilter('id', '=', eventId),
      fields: EventFieldSets.complete,
      limit: 1,
    );
  }

  /// Search query
  static IgdbEventQuery search({
    required String searchTerm,
    int limit = 20,
    int offset = 0,
  }) {
    return IgdbEventQuery(
      where: EventFilters.searchByName(searchTerm),
      fields: EventFieldSets.search,
      limit: limit,
      offset: offset,
      sort: 'start_time desc',
    );
  }

  // ============================================================
  // TIME-BASED QUERIES
  // ============================================================

  /// Upcoming events
  static IgdbEventQuery upcoming({
    int limit = 20,
    int offset = 0,
    int daysAhead = 60,
    int daysBack = 60,
  }) {
    final filter = CombinedFilter([
      EventFilters.between(
        DateTime.now().subtract(Duration(days: daysBack)),
        DateTime.now().add(Duration(days: daysAhead)),
      ),
    ]);

    return IgdbEventQuery(
      where: filter,
      fields: EventFieldSets.cards,
      limit: limit,
      offset: offset,
      sort: 'start_time asc',
    );
  }

  /// Currently ongoing events
  static IgdbEventQuery ongoing({
    int limit = 20,
    int offset = 0,
  }) {
    final filter = CombinedFilter([
      EventFilters.ongoing(),
      EventFilters.hasLogo(),
    ]);

    return IgdbEventQuery(
      where: filter,
      fields: EventFieldSets.cards,
      limit: limit,
      offset: offset,
      sort: 'start_time desc',
    );
  }

  /// Past events
  static IgdbEventQuery past({
    int limit = 20,
    int offset = 0,
    int daysBack = 90,
  }) {
    final startDate = DateTime.now().subtract(Duration(days: daysBack));

    final filter = CombinedFilter([
      EventFilters.past(),
      EventFilters.startsAfter(startDate),
      EventFilters.hasLogo(),
    ]);

    return IgdbEventQuery(
      where: filter,
      fields: EventFieldSets.cards,
      limit: limit,
      offset: offset,
      sort: 'start_time desc',
    );
  }

  /// Events this week
  static IgdbEventQuery thisWeek({
    int limit = 50,
    int offset = 0,
  }) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(Duration(days: 7));

    final filter = EventFilters.between(startOfWeek, endOfWeek);

    return IgdbEventQuery(
      where: filter,
      fields: EventFieldSets.cards,
      limit: limit,
      offset: offset,
      sort: 'start_time asc',
    );
  }

  /// Events this month
  static IgdbEventQuery thisMonth({
    int limit = 50,
    int offset = 0,
  }) {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    final filter = EventFilters.between(startOfMonth, endOfMonth);

    return IgdbEventQuery(
      where: filter,
      fields: EventFieldSets.cards,
      limit: limit,
      offset: offset,
      sort: 'start_time asc',
    );
  }

  // ============================================================
  // GAME-SPECIFIC QUERIES
  // ============================================================

  /// Events featuring a specific game
  static IgdbEventQuery byGame({
    required int gameId,
    int limit = 50,
    int offset = 0,
  }) {
    return IgdbEventQuery(
      where: EventFilters.byGame(gameId),
      fields: EventFieldSets.standard,
      limit: limit,
      offset: offset,
      sort: 'start_time desc',
    );
  }

  // ============================================================
  // SPECIAL QUERIES
  // ============================================================

  /// Events with live streams
  static IgdbEventQuery withLiveStreams({
    int limit = 20,
    int offset = 0,
  }) {
    final filter = CombinedFilter([
      EventFilters.hasLiveStream(),
      EventFilters.hasLogo(),
    ]);

    return IgdbEventQuery(
      where: filter,
      fields: EventFieldSets.standard,
      limit: limit,
      offset: offset,
      sort: 'start_time desc',
    );
  }
}
