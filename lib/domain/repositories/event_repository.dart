// lib/domain/repositories/event_repository.dart
import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/event/event.dart';

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

  // Events by Criteria
  Future<Either<Failure, List<Event>>> getEventsByDateRange({
    DateTime? startDate,
    DateTime? endDate,
    int limit = 50,
  });

  Future<Either<Failure, List<Event>>> getEventsByGames(List<int> gameIds);
}