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
      return const Left(
          ServerFailure(message: 'Failed to load events by date range'));
    }
  }

  @override
  Future<Either<Failure, Event>> getEventDetails(int eventId) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      print('🎪 EventRepository: Getting event details for: $eventId');

      // Use enhanced method for complete event data
      final event = await igdbDataSource.getEventByIdWithCompleteData(eventId);

      if (event == null) {
        return const Left(ServerFailure(message: 'Event not found'));
      }

      print('✅ EventRepository: Event details loaded');
      print(
          '📊 EventRepository: Event "${event.name}" has ${event.games.length} games, ${event.eventNetworks.length} networks');

      return Right(event);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return const Left(ServerFailure(message: 'Failed to get event details'));
    }
  }

  @override
  Future<Either<Failure, List<Event>>> getCurrentEvents(
      {int limit = 10}) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      print('🎪 EventRepository: Getting current events (limit: $limit)');

      // Use enhanced method for complete event data
      final liveEvents =
          await igdbDataSource.getLiveEventsWithCompleteData(limit: limit);

      print(
          '✅ EventRepository: Found ${liveEvents.length} live events with complete data');

      return Right(liveEvents);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return const Left(ServerFailure(message: 'Failed to get current events'));
    }
  }

  @override
  Future<Either<Failure, List<Event>>> getUpcomingEvents(
      {int limit = 10}) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      print('🎪 EventRepository: Getting upcoming events (limit: $limit)');

      // Use enhanced method for complete event data
      final upcomingEvents =
          await igdbDataSource.getUpcomingEventsWithCompleteData(limit: limit);

      print(
          '✅ EventRepository: Found ${upcomingEvents.length} upcoming events with complete data');

      return Right(upcomingEvents);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return const Left(
          ServerFailure(message: 'Failed to get upcoming events'));
    }
  }

  @override
  Future<Either<Failure, List<Event>>> searchEvents(String query) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      print('🔍 EventRepository: Searching events for: "$query"');

      // Use enhanced method for complete event data
      final events = await igdbDataSource.searchEventsWithCompleteData(query);

      print(
          '✅ EventRepository: Found ${events.length} events with complete data');

      return Right(events);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return const Left(ServerFailure(message: 'Failed to search events'));
    }
  }

  @override
  Future<Either<Failure, List<Event>>> getEventsByGames(
      List<int> gameIds) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      if (gameIds.isEmpty) {
        return const Right([]);
      }

      print('🎪 EventRepository: Getting events for ${gameIds.length} games');

      // Use enhanced method for complete event data
      final events =
          await igdbDataSource.getEventsByGamesWithCompleteData(gameIds);

      print(
          '✅ EventRepository: Found ${events.length} events with complete data');

      return Right(events);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return const Left(
          ServerFailure(message: 'Failed to get events by games'));
    }
  }
}
