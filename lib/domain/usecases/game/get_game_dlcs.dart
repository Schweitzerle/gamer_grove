// lib/domain/usecases/game/get_game_dlcs.dart
import 'package:dartz/dartz.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import 'package:gamer_grove/domain/entities/game/game.dart';
import 'package:gamer_grove/domain/repositories/game_repository.dart';
import 'package:gamer_grove/domain/usecases/base_usecase.dart';

class GetGameDLCs implements UseCase<List<Game>, int> {

  GetGameDLCs(this.repository);
  final GameRepository repository;

  @override
  Future<Either<Failure, List<Game>>> call(int gameId) async {
    return repository.getGameDLCs(gameId);
  }
}