// ==========================================

// lib/data/repositories/event_repository_impl.dart
import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/event/event.dart';
import '../../domain/repositories/event_repository.dart';
import '../datasources/local/cache_datasource.dart';
import '../datasources/remote/igdb/idgb_remote_datasource.dart';

class EventRepositoryImpl implements EventRepository {
  final IGDBRemoteDataSource igdbDataSource;
  final LocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  EventRepositoryImpl({
    required this.igdbDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Event>>> getCurrentEvents({int limit = 10}) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      print('🎪 EventRepository: Getting current events (limit: $limit)');

      // Get events that are currently happening or started recently
      final now = DateTime.now();
      final oneWeekAgo = now.subtract(const Duration(days: 7));
      final oneDayFromNow = now.add(const Duration(days: 1));

      final events = await igdbDataSource.getEventsByDateRange(
        startDate: oneWeekAgo,
        endDate: oneDayFromNow,
        limit: limit,
      );

      // Filter events that are currently "live" or very recent
      final currentEvents = events.where((event) {
        final startTime = event.startTime;
        final endTime = event.endTime;

        if (startTime == null) return false;

        // Event is current if:
        // 1. It has started but not ended yet, OR
        // 2. It started within the last week and no end time specified
        final hasStarted = startTime.isBefore(now);
        final hasEnded = endTime != null ? endTime.isBefore(now) : false;

        return hasStarted && !hasEnded;
      }).toList();

      print('✅ EventRepository: Found ${currentEvents.length} current events');
      return Right(currentEvents);

    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to load current events'));
    }
  }

  @override
  Future<Either<Failure, List<Event>>> getUpcomingEvents({int limit = 10}) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      print('📅 EventRepository: Getting upcoming events (limit: $limit)');

      // Get events starting from now to 2 weeks in the future
      final now = DateTime.now();
      final twoWeeksFromNow = now.add(const Duration(days: 14));

      final events = await igdbDataSource.getEventsByDateRange(
        startDate: now,
        endDate: twoWeeksFromNow,
        limit: limit,
      );

      // Filter only truly upcoming events (start time is in the future)
      final upcomingEvents = events.where((event) {
        final startTime = event.startTime;
        return startTime != null && startTime.isAfter(now);
      }).toList();

      print('✅ EventRepository: Found ${upcomingEvents.length} upcoming events');
      return Right(upcomingEvents);

    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to load upcoming events'));
    }
  }

  @override
  Future<Either<Failure, List<Event>>> getEventsByDateRange({
    DateTime? startDate,
    DateTime? endDate,
    int limit = 50,
  }) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      print('📅 EventRepository: Getting events by date range (limit: $limit)');

      final events = await igdbDataSource.getEventsByDateRange(
        startDate: startDate,
        endDate: endDate,
        limit: limit,
      );

      print('✅ EventRepository: Found ${events.length} events in date range');
      return Right(events);

    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to load events by date range'));
    }
  }

  @override
  Future<Either<Failure, List<Event>>> getEventsByGames(List<int> gameIds) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      if (gameIds.isEmpty) {
        return const Right([]);
      }

      print('🎮 EventRepository: Getting events for ${gameIds.length} games');

      final events = await igdbDataSource.getEventsByGames(gameIds);

      print('✅ EventRepository: Found ${events.length} events for games');
      return Right(events);

    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to load events by games'));
    }
  }

  @override
  Future<Either<Failure, Event>> getEventDetails(int eventId) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      print('🎪 EventRepository: Getting event details for ID: $eventId');

      final event = await igdbDataSource.getEventById(eventId);

      if (event == null) {
        return Left(NotFoundFailure(message: 'Event not found'));
      }

      print('✅ EventRepository: Event details loaded successfully');
      return Right(event);

    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to load event details'));
    }
  }
}
