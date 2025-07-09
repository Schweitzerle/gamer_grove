// ==================================================
// EVENT USE CASES
// ==================================================

// lib/domain/usecases/events/get_game_events.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/errors/failures.dart';
import '../../entities/event/event.dart';
import '../../repositories/game_repository.dart';
import '../base_usecase.dart';

class GetGameEvents extends UseCase<List<Event>, GetGameEventsParams> {
  final GameRepository repository;

  GetGameEvents(this.repository);

  @override
  Future<Either<Failure, List<Event>>> call(GetGameEventsParams params) async {
    if (params.gameId <= 0) {
      return const Left(ValidationFailure(message: 'Invalid game ID'));
    }

    return await repository.getGameEvents(params.gameId);
  }
}

class GetGameEventsParams extends Equatable {
  final int gameId;

  const GetGameEventsParams({required this.gameId});

  @override
  List<Object> get props => [gameId];
}

