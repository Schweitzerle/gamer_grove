// domain/usecases/game/get_game_details.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import 'package:gamer_grove/domain/entities/game/game.dart';
import 'package:gamer_grove/domain/repositories/game_repository.dart';
import 'package:gamer_grove/domain/usecases/base_usecase.dart';

class GetGameDetails extends UseCase<Game, GameDetailsParams> {

  GetGameDetails(this.repository);
  final GameRepository repository;

  @override
  Future<Either<Failure, Game>> call(GameDetailsParams params) async {
    return repository.getGameDetails(params.gameId);
  }
}

class GameDetailsParams extends Equatable {

  const GameDetailsParams({required this.gameId});
  final int gameId;

  @override
  List<Object> get props => [gameId];
}

