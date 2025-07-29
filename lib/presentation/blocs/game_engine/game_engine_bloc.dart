// ==================================================
// PLATFORM BLOC IMPLEMENTATION
// ==================================================

// lib/presentation/blocs/platform/game_engine_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamer_grove/domain/usecases/gameEngine/get_game_engine_with_games.dart';
import '../../../core/utils/game_enrichment_utils.dart';
import '../../../domain/usecases/platform/get_platform_with_games.dart';
import 'game_engine_event.dart';
import 'game_engine_state.dart';

class GameEngineBloc extends Bloc<GameEngineEvent, GameEngineState> {
  final GetGameEngineWithGames getGameEngineWithGames;
  GameEngineBloc({
    required this.getGameEngineWithGames,
  }) : super(GameEngineInitial()) {
    on<GetGameEngineDetailsEvent>(_onGetGameEngineDetails);
    on<ClearGameEngineEvent>(_onClearGameEngine);
  }

  Future<void> _onGetGameEngineDetails(
      GetGameEngineDetailsEvent event,
      Emitter<GameEngineState> emit,
      ) async {
    emit(GameEngineLoading());

    final result = await getGameEngineWithGames(
      GetGameEngineWithGamesParams(
        gameEngineId: event.gameEngineId,
        includeGames: event.includeGames,
      ),
    );

    await result.fold(
          (failure) async {
        emit(GameEngineError(message: failure.message));
      },
          (gameEngineWithGames) async {
        // 🔧 ENRICHMENT LOGIC mit GameEnrichmentUtils
        if (event.userId != null && gameEngineWithGames.games.isNotEmpty) {
          try {
            print('🎮 GameEngineBloc: Enriching gameEngine games with GameEnrichmentUtils...');

            // Verwende die Utils für Game Enrichment
            final enrichedGames = await GameEnrichmentUtils.enrichGameEngineGames(
              gameEngineWithGames.games,
              event.userId!,
            );

            // Debug Stats
            GameEnrichmentUtils.printEnrichmentStats(enrichedGames, context: 'GameEngine');

            emit(GameEngineDetailsLoaded(
              gameEngine: gameEngineWithGames.gameEngine,
              games: enrichedGames,
            ));
          } catch (e) {
            print('❌ GameEngineBloc: Failed to enrich games: $e');
            emit(GameEngineDetailsLoaded(
              gameEngine: gameEngineWithGames.gameEngine,
              games: gameEngineWithGames.games,
            ));
          }
        } else {
          emit(GameEngineDetailsLoaded(
            gameEngine: gameEngineWithGames.gameEngine,
            games: gameEngineWithGames.games,
          ));
        }
      },
    );
  }

  Future<void> _onClearGameEngine(
      ClearGameEngineEvent event,
      Emitter<GameEngineState> emit,
      ) async {
    emit(GameEngineInitial());
  }
}