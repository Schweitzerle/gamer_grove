// ==================================================
// ERWEITERTE USE CASES FÜR COMPLETE GAME DETAILS
// ==================================================

// lib/domain/usecases/game/get_complete_game_details.dart
import 'package:dartz/dartz.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import 'package:gamer_grove/domain/entities/game/game.dart';
import 'package:gamer_grove/domain/repositories/game_repository.dart';
import 'package:gamer_grove/domain/usecases/base_usecase.dart';

class GetCompleteGameDetails implements UseCase<Game, GetCompleteGameDetailsParams> {

  GetCompleteGameDetails(this.repository);
  final GameRepository repository;

  @override
  Future<Either<Failure, Game>> call(GetCompleteGameDetailsParams params) async {
    return repository.getCompleteGameDetails(params.gameId, params.userId);
  }
}

class GetCompleteGameDetailsParams {

  GetCompleteGameDetailsParams({
    required this.gameId,
    this.userId,
  });
  final int gameId;
  final String? userId;
}





