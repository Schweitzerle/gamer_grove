// lib/domain/usecases/game/get_game_dlcs.dart
import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/game.dart';
import '../../repositories/game_repository.dart';
import '../base_usecase.dart';

class GetGameDLCs implements UseCase<List<Game>, int> {
  final GameRepository repository;

  GetGameDLCs(this.repository);

  @override
  Future<Either<Failure, List<Game>>> call(int gameId) async {
    return await repository.getGameDLCs(gameId);
  }
}