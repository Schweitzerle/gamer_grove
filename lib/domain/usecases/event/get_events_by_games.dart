// ==================================================

// lib/domain/usecases/events/get_events_by_games.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import 'package:gamer_grove/domain/entities/event/event.dart';
import 'package:gamer_grove/domain/repositories/event_repository.dart';
import 'package:gamer_grove/domain/usecases/base_usecase.dart';

class GetEventsByGames extends UseCase<List<Event>, GetEventsByGamesParams> {

  GetEventsByGames(this.repository);
  final EventRepository repository;

  @override
  Future<Either<Failure, List<Event>>> call(GetEventsByGamesParams params) async {
    if (params.gameIds.isEmpty) {
      return const Left(ValidationFailure(message: 'At least one game ID is required'));
    }

    return repository.getEventsByGames(params.gameIds);
  }
}

class GetEventsByGamesParams extends Equatable {

  const GetEventsByGamesParams({required this.gameIds});
  final List<int> gameIds;

  @override
  List<Object> get props => [gameIds];
}

