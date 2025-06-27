// lib/domain/usecases/game/get_similar_games.dart
import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/game/game.dart';
import '../../repositories/game_repository.dart';
import '../base_usecase.dart';

class GetSimilarGames implements UseCase<List<Game>, int> {
  final GameRepository repository;

  GetSimilarGames(this.repository);

  @override
  Future<Either<Failure, List<Game>>> call(int gameId) async {
    return await repository.getSimilarGames(gameId);
  }
}