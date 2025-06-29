// ==========================================
// PHASE 1 USE CASES FOR HOME SCREEN
// ==========================================

// lib/domain/usecases/game/get_top_rated_games.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/errors/failures.dart';
import '../../entities/game/game.dart';
import '../../repositories/game_repository.dart';
import '../base_usecase.dart';

class GetTopRatedGames extends UseCase<List<Game>, GetTopRatedGamesParams> {
  final GameRepository repository;

  GetTopRatedGames(this.repository);

  @override
  Future<Either<Failure, List<Game>>> call(GetTopRatedGamesParams params) async {
    return await repository.getTopRatedGames(
      params.limit,
      params.offset,
    );
  }
}

class GetTopRatedGamesParams extends Equatable {
  final int limit;
  final int offset;

  const GetTopRatedGamesParams({
    this.limit = 20,
    this.offset = 0,
  });

  @override
  List<Object> get props => [limit, offset];
}


