import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import 'package:gamer_grove/domain/entities/game/game.dart';
import 'package:gamer_grove/domain/repositories/game_repository.dart';
import 'package:gamer_grove/domain/usecases/usecase.dart';

/// Resolves a list of game ids to full [Game] entities (order-preserving on the
/// caller side). Used by the custom-collection detail view.
class GetGamesByIdsUseCase implements UseCase<List<Game>, GetGamesByIdsParams> {
  GetGamesByIdsUseCase(this.repository);

  final GameRepository repository;

  @override
  Future<Either<Failure, List<Game>>> call(GetGamesByIdsParams params) {
    if (params.gameIds.isEmpty) {
      return Future.value(const Right(<Game>[]));
    }
    return repository.getGamesByIds(params.gameIds);
  }
}

class GetGamesByIdsParams extends Equatable {
  const GetGamesByIdsParams({required this.gameIds});

  final List<int> gameIds;

  @override
  List<Object?> get props => [gameIds];
}
