// ==================================================

// lib/domain/usecases/events/get_events_by_games.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/errors/failures.dart';
import '../../entities/event/event.dart';
import '../../repositories/event_repository.dart';
import '../base_usecase.dart';

class GetEventsByGames extends UseCase<List<Event>, GetEventsByGamesParams> {
  final EventRepository repository;

  GetEventsByGames(this.repository);

  @override
  Future<Either<Failure, List<Event>>> call(GetEventsByGamesParams params) async {
    if (params.gameIds.isEmpty) {
      return const Left(ValidationFailure(message: 'At least one game ID is required'));
    }

    return await repository.getEventsByGames(params.gameIds);
  }
}

class GetEventsByGamesParams extends Equatable {
  final List<int> gameIds;

  const GetEventsByGamesParams({required this.gameIds});

  @override
  List<Object> get props => [gameIds];
}

