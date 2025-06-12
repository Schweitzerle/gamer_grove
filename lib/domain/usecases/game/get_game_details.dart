// domain/usecases/game/get_game_details.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/errors/failures.dart';
import '../../entities/game.dart';
import '../../repositories/game_repository.dart';
import '../base_usecase.dart';

class GetGameDetails extends UseCase<Game, GameDetailsParams> {
  final GameRepository repository;

  GetGameDetails(this.repository);

  @override
  Future<Either<Failure, Game>> call(GameDetailsParams params) async {
    return await repository.getGameDetails(params.gameId);
  }
}

class GameDetailsParams extends Equatable {
  final int gameId;

  const GameDetailsParams({required this.gameId});

  @override
  List<Object> get props => [gameId];
}