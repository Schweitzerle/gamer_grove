// domain/usecases/game/get_latest_games.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import 'package:gamer_grove/domain/entities/game/game.dart';
import 'package:gamer_grove/domain/repositories/game_repository.dart';
import 'package:gamer_grove/domain/usecases/base_usecase.dart';

class GetLatestGames extends UseCase<List<Game>, GetLatestGamesParams> {

  GetLatestGames(this.repository);
  final GameRepository repository;

  @override
  Future<Either<Failure, List<Game>>> call(GetLatestGamesParams params) async {
    return repository.getLatestGames(
      params.limit,
      params.offset,
    );
  }
}

class GetLatestGamesParams extends Equatable {

  const GetLatestGamesParams({
    this.limit = 20,
    this.offset = 0,
  });
  final int limit;
  final int offset;

  @override
  List<Object> get props => [limit, offset];
}

