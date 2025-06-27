// ==================================================
// ERWEITERTE USE CASES FÜR COMPLETE GAME DETAILS
// ==================================================

// lib/domain/usecases/game/get_complete_game_details.dart
import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/game/game.dart';
import '../../repositories/game_repository.dart';
import '../base_usecase.dart';

class GetCompleteGameDetails implements UseCase<Game, GetCompleteGameDetailsParams> {
  final GameRepository repository;

  GetCompleteGameDetails(this.repository);

  @override
  Future<Either<Failure, Game>> call(GetCompleteGameDetailsParams params) async {
    return await repository.getCompleteGameDetails(params.gameId, params.userId);
  }
}

class GetCompleteGameDetailsParams {
  final int gameId;
  final String? userId;

  GetCompleteGameDetailsParams({
    required this.gameId,
    this.userId,
  });
}





