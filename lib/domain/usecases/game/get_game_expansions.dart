// lib/domain/usecases/game/get_game_expansions.dart
import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/game/game.dart';
import '../../repositories/game_repository.dart';
import '../base_usecase.dart';

class GetGameExpansions implements UseCase<List<Game>, int> {
  final GameRepository repository;

  GetGameExpansions(this.repository);

  @override
  Future<Either<Failure, List<Game>>> call(int gameId) async {
    return await repository.getGameExpansions(gameId);
  }
}