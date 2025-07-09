// ==========================================
// EVENT REPOSITORY FOR PHASE 1
// ==========================================

// lib/domain/repositories/event_repository.dart
import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/event/event.dart';

abstract class EventRepository {
  // ==========================================
  // PHASE 1 - HOME SCREEN EVENT METHODS
  // ==========================================

  /// Get current events (happening now or very recently started)
  Future<Either<Failure, List<Event>>> getCurrentEvents({
    int limit = 10,
  });

  /// Get upcoming events (starting in the near future)
  Future<Either<Failure, List<Event>>> getUpcomingEvents({
    int limit = 10,
  });

  /// Get events in a specific date range
  Future<Either<Failure, List<Event>>> getEventsByDateRange({
    DateTime? startDate,
    DateTime? endDate,
    int limit = 50,
  });

  /// Get events for specific games
  Future<Either<Failure, List<Event>>> getEventsByGames(List<int> gameIds);

  /// Get event details by ID
  Future<Either<Failure, Event>> getEventDetails(int eventId);

  /// Search events by query
  Future<Either<Failure, List<Event>>> searchEvents(String query);

}




