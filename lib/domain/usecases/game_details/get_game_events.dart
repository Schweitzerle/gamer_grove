// ==========================================

// lib/domain/usecases/game_details/get_game_events.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import 'package:gamer_grove/domain/entities/event/event.dart';
import 'package:gamer_grove/domain/repositories/game_repository.dart';
import 'package:gamer_grove/domain/usecases/base_usecase.dart';

class GetGameEvents extends UseCase<List<Event>, GetGameEventsParams> {

  GetGameEvents(this.repository);
  final GameRepository repository;

  @override
  Future<Either<Failure, List<Event>>> call(GetGameEventsParams params) async {
    if (params.gameId <= 0) {
      return const Left(ValidationFailure(message: 'Invalid game ID'));
    }

    return repository.getGameEvents(params.gameId);
  }
}

class GetGameEventsParams extends Equatable {

  const GetGameEventsParams({required this.gameId});
  final int gameId;

  @override
  List<Object> get props => [gameId];
}

