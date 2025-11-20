// lib/domain/usecases/game/get_newest_games.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import 'package:gamer_grove/domain/entities/game/game.dart';
import 'package:gamer_grove/domain/repositories/game_repository.dart';
import 'package:gamer_grove/domain/usecases/base_usecase.dart';

class GetNewestGames extends UseCase<List<Game>, GetNewestGamesParams> {

  GetNewestGames(this.repository);
  final GameRepository repository;

  @override
  Future<Either<Failure, List<Game>>> call(GetNewestGamesParams params) async {
    return repository.getNewestGames(
      params.limit,
      params.offset,
    );
  }
}

class GetNewestGamesParams extends Equatable {

  const GetNewestGamesParams({
    this.limit = 20,
    this.offset = 0,
  });
  final int limit;
  final int offset;

  @override
  List<Object> get props => [limit, offset];
}


