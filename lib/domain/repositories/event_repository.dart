// lib/domain/repositories/event_repository.dart
import 'package:dartz/dartz.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import 'package:gamer_grove/domain/entities/event/event.dart';
import 'package:gamer_grove/domain/entities/search/event_search_filters.dart';

abstract class EventRepository {
  // Current & Upcoming Events
  Future<Either<Failure, List<Event>>> getCurrentEvents({
    int limit = 10,
  });

  Future<Either<Failure, List<Event>>> getUpcomingEvents({
    int limit = 10,
  });

  // Event Search & Details
  Future<Either<Failure, List<Event>>> searchEvents(String query);

  Future<Either<Failure, Event>> getEventDetails(int eventId);

  // Advanced Event Search with Filters
  Future<Either<Failure, List<Event>>> advancedEventSearch({
    required EventSearchFilters filters,
    String? textQuery,
    int limit = 20,
    int offset = 0,
  });

  // Events by Criteria
  Future<Either<Failure, List<Event>>> getEventsByDateRange({
    DateTime? startDate,
    DateTime? endDate,
    int limit = 50,
  });

  Future<Either<Failure, List<Event>>> getEventsByGames(List<int> gameIds);
}
