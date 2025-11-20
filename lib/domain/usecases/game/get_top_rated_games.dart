// ==========================================
// PHASE 1 USE CASES FOR HOME SCREEN
// ==========================================

// lib/domain/usecases/game/get_top_rated_games.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import 'package:gamer_grove/domain/entities/game/game.dart';
import 'package:gamer_grove/domain/repositories/game_repository.dart';
import 'package:gamer_grove/domain/usecases/base_usecase.dart';

class GetTopRatedGames extends UseCase<List<Game>, GetTopRatedGamesParams> {

  GetTopRatedGames(this.repository);
  final GameRepository repository;

  @override
  Future<Either<Failure, List<Game>>> call(GetTopRatedGamesParams params) async {
    return repository.getTopRatedGames(
      params.limit,
      params.offset,
    );
  }
}

class GetTopRatedGamesParams extends Equatable {

  const GetTopRatedGamesParams({
    this.limit = 20,
    this.offset = 0,
  });
  final int limit;
  final int offset;

  @override
  List<Object> get props => [limit, offset];
}


