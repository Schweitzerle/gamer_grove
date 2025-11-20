// domain/usecases/game/get_popular_games.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import 'package:gamer_grove/domain/entities/game/game.dart';
import 'package:gamer_grove/domain/repositories/game_repository.dart';
import 'package:gamer_grove/domain/usecases/base_usecase.dart';

class GetPopularGames extends UseCase<List<Game>, GetPopularGamesParams> {

  GetPopularGames(this.repository);
  final GameRepository repository;

  @override
  Future<Either<Failure, List<Game>>> call(GetPopularGamesParams params) async {
    return repository.getPopularGames(
      params.limit,
      params.offset,
    );
  }
}

class GetPopularGamesParams extends Equatable {

  const GetPopularGamesParams({
    this.limit = 20,
    this.offset = 0,
  });
  final int limit;
  final int offset;

  @override
  List<Object> get props => [limit, offset];
}

