// ==================================================
// GameEngine USE CASE IMPLEMENTATION
// ==================================================

// lib/domain/usecases/gameEngine/get_game_engine_with_games.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:gamer_grove/domain/entities/game/game_engine.dart';
import '../../../core/errors/failures.dart';
import '../../entities/game/game.dart';
import '../../repositories/game_repository.dart';
import '../base_usecase.dart';

class GetGameEngineWithGames extends UseCase<GameEngineWithGames, GetGameEngineWithGamesParams> {
  final GameRepository repository;

  GetGameEngineWithGames(this.repository);

  @override
  Future<Either<Failure, GameEngineWithGames>> call(GetGameEngineWithGamesParams params) async {
    try {
      print('🎮 UseCase: Getting game engine details for ID: ${params.gameEngineId}');
      print('🎮 UseCase: Include games: ${params.includeGames}');

      // Get gameEngine details first
      final gameEngineResult = await repository.getGameEngineDetails(params.gameEngineId);

      if (gameEngineResult.isLeft()) {
        return gameEngineResult.fold(
              (failure) {
            print('❌ UseCase: Repository failed: ${failure.message}');
            return Left(failure);
          },
              (gameEngine) => throw Exception('Unexpected success'),
        );
      }

      final gameEngine = gameEngineResult.fold(
            (l) => throw Exception('Unexpected failure'),
            (r) => r,
      );

      print('✅ UseCase: GameEngine loaded: ${gameEngine.name}');

      List<Game> games = [];

      // Load games for this gameEngine if requested
      if (params.includeGames) {
        print('🎮 UseCase: Loading games for gameEngine: ${gameEngine.name}');

        final gamesResult = await repository.getGamesByGameEngine( //TODO: ändfern in gmaeengine
          gameEngineIds: [gameEngine.id],
          limit: params.limit,
          offset: 0,
        );

        games = gamesResult.fold(
              (failure) {
            print('❌ UseCase: Failed to load games: ${failure.message}');
            return <Game>[];
          },
              (gamesList) {
            print('✅ UseCase: Loaded ${gamesList.length} games for gameEngine');
            return gamesList;
          },
        );
      }

      final result = GameEngineWithGames(
        gameEngine: gameEngine,
        games: games,
      );

      print('🎯 UseCase: Final result - ${result.gameEngine.name} with ${result.games.length} games');
      return Right(result);

    } catch (e) {
      print('❌ UseCase: Exception occurred: $e');
      print('📍 UseCase: Exception type: ${e.runtimeType}');
      return Left(ServerFailure(message: 'Failed to load gameEngine with games: $e'));
    }
  }
}

class GetGameEngineWithGamesParams extends Equatable {
  final int gameEngineId;
  final bool includeGames;
  final int limit;

  const GetGameEngineWithGamesParams({
    required this.gameEngineId,
    this.includeGames = true,
    this.limit = 10,
  });

  @override
  List<Object> get props => [gameEngineId, includeGames, limit];
}

class GameEngineWithGames extends Equatable {
  final GameEngine gameEngine;
  final List<Game> games;

  const GameEngineWithGames({
    required this.gameEngine,
    required this.games,
  });

  bool get hasGames => games.isNotEmpty;
  int get gameCount => games.length;

  @override
  List<Object> get props => [gameEngine, games];
}