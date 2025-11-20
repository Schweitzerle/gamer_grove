// lib/data/repositories/event_repository_impl.dart

/// Refactored Event Repository Implementation.
///
/// Uses [IgdbBaseRepository] for unified error handling and the new
/// IGDB query system for clean, maintainable code.
///
/// Key improvements:
/// - Extends IgdbBaseRepository for automatic error handling
/// - Uses EventQueryPresets for common queries
/// - Eliminates code duplication
/// - Better separation of concerns
/// - Production-ready error handling
library;

import 'package:dartz/dartz.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import 'package:gamer_grove/data/datasources/remote/igdb/igdb_datasource.dart';
import 'package:gamer_grove/data/datasources/remote/igdb/models/event/event_field_sets.dart';
import 'package:gamer_grove/data/datasources/remote/igdb/models/event/event_filters.dart';
import 'package:gamer_grove/data/datasources/remote/igdb/models/event/event_query_presets.dart';
import 'package:gamer_grove/data/datasources/remote/igdb/models/igdb_filters.dart';
import 'package:gamer_grove/data/datasources/remote/igdb/models/igdb_query.dart';
import 'package:gamer_grove/data/repositories/base/igdb_base_repository.dart';
import 'package:gamer_grove/domain/entities/event/event.dart';
import 'package:gamer_grove/domain/entities/search/event_search_filters.dart';
import 'package:gamer_grove/domain/repositories/event_repository.dart';

/// Concrete implementation of [EventRepository].
///
/// Handles all event-related operations using the IGDB API through
/// the unified query system.
///
/// Example usage:
/// ```dart
/// final eventRepo = EventRepositoryImpl(
///   igdbDataSource: igdbDataSource,
///   networkInfo: networkInfo,
/// );
///
/// // Get current events
/// final result = await eventRepo.getCurrentEvents(limit: 10);
/// result.fold(
/// );
/// ```
class EventRepositoryImpl extends IgdbBaseRepository
    implements EventRepository {

  EventRepositoryImpl({
    required this.igdbDataSource,
    required super.networkInfo,
  });
  final IgdbDataSource igdbDataSource;

  // ============================================================
  // CURRENT & UPCOMING EVENTS
  // ============================================================

  @override
  Future<Either<Failure, List<Event>>> getCurrentEvents({
    int limit = 10,
  }) {
    return executeIgdbOperation(
      operation: () async {
        final query = EventQueryPresets.ongoing(
          limit: limit,
        );
        return igdbDataSource.queryEvents(query);
      },
      errorMessage: 'Failed to fetch current events',
    );
  }

  @override
  Future<Either<Failure, List<Event>>> getUpcomingEvents({
    int limit = 10,
  }) {
    return executeIgdbOperation(
      operation: () async {
        final query = EventQueryPresets.upcoming(
          limit: limit,
          daysAhead: 30,
        );
        return igdbDataSource.queryEvents(query);
      },
      errorMessage: 'Failed to fetch upcoming events',
    );
  }

  // ============================================================
  // SEARCH & DETAILS
  // ============================================================

  @override
  Future<Either<Failure, List<Event>>> searchEvents(String query) {
    if (query.trim().isEmpty) {
      return Future.value(const Right([]));
    }

    return executeIgdbOperation(
      operation: () async {
        final searchQuery = EventQueryPresets.search(
          searchTerm: query.trim(),
          limit: 50,
        );
        return igdbDataSource.queryEvents(searchQuery);
      },
      errorMessage: 'Failed to search events',
    );
  }

  @override
  Future<Either<Failure, List<Event>>> advancedEventSearch({
    required EventSearchFilters filters,
    String? textQuery,
    int limit = 20,
    int offset = 0,
  }) {
    return executeIgdbOperation(
      operation: () async {
        // Build filters based on EventSearchFilters
        final filterList = <IgdbFilter>[];

        // Start time filters (we only filter by event start_time)
        if (filters.startTimeFrom != null) {
          filterList.add(EventFilters.startsAfter(filters.startTimeFrom!));
        }
        if (filters.startTimeTo != null) {
          filterList.add(EventFilters.startsBefore(filters.startTimeTo!));
        }

        // Event networks filter
        if (filters.eventNetworkIds.isNotEmpty) {
          filterList.add(
            AnyFilter('event_networks', filters.eventNetworkIds),
          );
        }

        // Text search filter
        if (textQuery != null && textQuery.trim().isNotEmpty) {
          filterList.add(FieldFilter('name', '~', textQuery.trim()));
        }

        // Combine all filters (or null if no filters)
        final combinedFilter = filterList.isEmpty
            ? null
            : (filterList.length == 1
                ? filterList.first
                : CombinedFilter(filterList));

        // Determine sort order
        final String sortField;
        switch (filters.sortBy) {
          case EventSortBy.startTime:
            sortField = 'start_time';
          case EventSortBy.endTime:
            sortField = 'end_time';
          case EventSortBy.name:
            sortField = 'name';
          case EventSortBy.relevance:
            sortField = 'start_time';
        }

        final sortOrder = filters.sortOrder == EventSortOrder.ascending
            ? 'asc'
            : 'desc';

        final query = IgdbEventQuery(
          where: combinedFilter,
          fields: EventFieldSets.cards,
          limit: limit,
          offset: offset,
          sort: '$sortField $sortOrder',
        );

        return igdbDataSource.queryEvents(query);
      },
      errorMessage: 'Failed to perform advanced event search',
    );
  }

  @override
  Future<Either<Failure, Event>> getEventDetails(int eventId) {
    if (eventId <= 0) {
      return Future.value(
        const Left(ValidationFailure(message: 'Invalid event ID')),
      );
    }

    return executeIgdbOperation(
      operation: () async {
        final query = EventQueryPresets.fullDetails(eventId: eventId);
        final events = await igdbDataSource.queryEvents(query);

        if (events.isEmpty) {
          throw const IgdbNotFoundException(
            message: 'Event not found',
          );
        }

        return events.first;
      },
      errorMessage: 'Failed to fetch event details',
    );
  }

  // ============================================================
  // FILTERED QUERIES
  // ============================================================

  @override
  Future<Either<Failure, List<Event>>> getEventsByDateRange({
    DateTime? startDate,
    DateTime? endDate,
    int limit = 50,
  }) {
    return executeIgdbOperation(
      operation: () async {
        // Build filter based on provided dates
        IgdbFilter? filter;

        if (startDate != null && endDate != null) {
          filter = EventFilters.between(startDate, endDate);
        } else if (startDate != null) {
          filter = EventFilters.startsAfter(startDate);
        } else if (endDate != null) {
          filter = EventFilters.startsBefore(endDate);
        }

        final query = IgdbEventQuery(
          where: filter,
          fields: EventFieldSets.cards,
          limit: limit,
          sort: 'start_time asc',
        );

        return igdbDataSource.queryEvents(query);
      },
      errorMessage: 'Failed to fetch events by date range',
    );
  }

  @override
  Future<Either<Failure, List<Event>>> getEventsByGames(
    List<int> gameIds,
  ) {
    if (gameIds.isEmpty) {
      return Future.value(const Right([]));
    }

    return executeIgdbOperation(
      operation: () async {
        final filter = EventFilters.byGames(gameIds);

        final query = IgdbEventQuery(
          where: filter,
          fields: EventFieldSets.standard,
          limit: 100,
          sort: 'start_time desc',
        );

        return igdbDataSource.queryEvents(query);
      },
      errorMessage: 'Failed to fetch events by games',
    );
  }
}
