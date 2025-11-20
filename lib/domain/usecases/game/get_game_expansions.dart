// lib/domain/usecases/game/get_game_expansions.dart
import 'package:dartz/dartz.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import 'package:gamer_grove/domain/entities/game/game.dart';
import 'package:gamer_grove/domain/repositories/game_repository.dart';
import 'package:gamer_grove/domain/usecases/base_usecase.dart';

class GetGameExpansions implements UseCase<List<Game>, int> {

  GetGameExpansions(this.repository);
  final GameRepository repository;

  @override
  Future<Either<Failure, List<Game>>> call(int gameId) async {
    return repository.getGameExpansions(gameId);
  }
}