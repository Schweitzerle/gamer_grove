// ==================================================
// GAME ENGINE BLOC IMPLEMENTATION (ERWEITERT)
// ==================================================

// lib/presentation/blocs/game_engine/game_engine_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamer_grove/core/services/game_enrichment_service.dart';
import 'package:gamer_grove/domain/entities/game/game.dart';
import 'package:gamer_grove/domain/repositories/game_repository.dart';
import 'package:gamer_grove/domain/usecases/gameEngine/get_game_engine_with_games.dart';
import 'game_engine_event.dart';
import 'game_engine_state.dart';

class GameEngineBloc extends Bloc<GameEngineEvent, GameEngineState> {
  final GetGameEngineWithGames getGameEngineWithGames;
  final GameRepository gameRepository; // 🆕 Repository für paginierte Anfragen
  final GameEnrichmentService enrichmentService;

  // Pagination constants
  static const int _pageSize = 20;

  GameEngineBloc({
    required this.getGameEngineWithGames,
    required this.gameRepository,
    required this.enrichmentService,
  }) : super(GameEngineInitial()) {
    on<GetGameEngineDetailsEvent>(_onGetGameEngineDetails);
    on<ClearGameEngineEvent>(_onClearGameEngine);
    // 🆕 Neue Event Handler
    on<LoadGameEngineGamesEvent>(_onLoadGameEngineGames);
    on<LoadMoreGameEngineGamesEvent>(_onLoadMoreGameEngineGames);
    on<ChangeGameEngineSortEvent>(_onChangeGameEngineSort);
  }

  // ==========================================
  // EXISTING EVENT HANDLERS
  // ==========================================

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
            final enrichedGames = await enrichmentService.enrichGames(
              gameEngineWithGames.games,
              event.userId!,
            );

            emit(GameEngineDetailsLoaded(
              gameEngine: gameEngineWithGames.gameEngine,
              games: enrichedGames,
            ));
          } catch (e) {
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

  // ==========================================
  // 🆕 NEW EVENT HANDLERS FOR PAGINATED GAMES
  // ==========================================

  Future<void> _onLoadGameEngineGames(
    LoadGameEngineGamesEvent event,
    Emitter<GameEngineState> emit,
  ) async {

    // Show loading state
    emit(GameEngineGamesLoading(
      gameEngineId: event.gameEngineId,
      gameEngineName: event.gameEngineName,
    ));

    // Fetch first page
    final result = await gameRepository.getGamesByGameEngine(
      gameEngineIds: [event.gameEngineId],
      limit: _pageSize,
      offset: 0,
      sortBy: event.sortBy,
      sortOrder: event.sortOrder,
    );

    await result.fold(
      (failure) async {
        emit(GameEngineGamesError(
          gameEngineId: event.gameEngineId,
          gameEngineName: event.gameEngineName,
          message: failure.message,
        ));
      },
      (games) async {

        // Enrich games if userId is provided
        List<Game> enrichedGames = games;
        if (event.userId != null && games.isNotEmpty) {
          try {
            enrichedGames = await enrichmentService.enrichGames(
              games,
              event.userId!,
            );
          } catch (e) {
          }
        }

        // hasMore = true if we got a full page
        final hasMore = games.length == _pageSize;

        emit(GameEngineGamesLoaded(
          gameEngineId: event.gameEngineId,
          gameEngineName: event.gameEngineName,
          games: enrichedGames,
          hasMore: hasMore,
          currentPage: 0,
          sortBy: event.sortBy,
          sortOrder: event.sortOrder,
          userId: event.userId, // 🆕 Store userId in state
        ));
      },
    );
  }

  Future<void> _onLoadMoreGameEngineGames(
    LoadMoreGameEngineGamesEvent event,
    Emitter<GameEngineState> emit,
  ) async {
    // Only load more if we're in the GameEngineGamesLoaded state
    if (state is! GameEngineGamesLoaded) return;

    final currentState = state as GameEngineGamesLoaded;

    // Don't load if already loading or no more games
    if (currentState.isLoadingMore || !currentState.hasMore) {
      return;
    }


    // Set loading more flag
    emit(currentState.copyWith(isLoadingMore: true));

    final nextPage = currentState.currentPage + 1;
    final offset = nextPage * _pageSize;

    // Fetch next page
    final result = await gameRepository.getGamesByGameEngine(
      gameEngineIds: [currentState.gameEngineId],
      limit: _pageSize,
      offset: offset,
      sortBy: currentState.sortBy,
      sortOrder: currentState.sortOrder,
    );

    await result.fold(
      (failure) async {
        // Keep current state but clear loading flag
        emit(currentState.copyWith(isLoadingMore: false));
      },
      (newGames) async {

        // Enrich new games if userId is available
        List<Game> enrichedNewGames = newGames;
        if (currentState.userId != null && newGames.isNotEmpty) {
          try {
            enrichedNewGames = await enrichmentService.enrichGames(
              newGames,
              currentState.userId!,
            );
          } catch (e) {
          }
        }

        // Combine existing games with new games
        final allGames = [...currentState.games, ...enrichedNewGames];
        final hasMore = newGames.length == _pageSize;

        emit(GameEngineGamesLoaded(
          gameEngineId: currentState.gameEngineId,
          gameEngineName: currentState.gameEngineName,
          games: allGames,
          hasMore: hasMore,
          currentPage: nextPage,
          sortBy: currentState.sortBy,
          sortOrder: currentState.sortOrder,
          isLoadingMore: false,
          userId: currentState.userId, // 🆕 Keep userId
        ));
      },
    );
  }

  Future<void> _onChangeGameEngineSort(
    ChangeGameEngineSortEvent event,
    Emitter<GameEngineState> emit,
  ) async {
    // Only change sort if we're in the GameEngineGamesLoaded state
    if (state is! GameEngineGamesLoaded) return;

    final currentState = state as GameEngineGamesLoaded;


    // Show loading state
    emit(GameEngineGamesLoading(
      gameEngineId: currentState.gameEngineId,
      gameEngineName: currentState.gameEngineName,
    ));

    // Fetch first page with new sort
    final result = await gameRepository.getGamesByGameEngine(
      gameEngineIds: [currentState.gameEngineId],
      limit: _pageSize,
      offset: 0,
      sortBy: event.sortBy,
      sortOrder: event.sortOrder,
    );

    await result.fold(
      (failure) async {
        emit(GameEngineGamesError(
          gameEngineId: currentState.gameEngineId,
          gameEngineName: currentState.gameEngineName,
          message: failure.message,
        ));
      },
      (games) async {

        // 🆕 Enrich games if userId is available
        List<Game> enrichedGames = games;
        if (currentState.userId != null && games.isNotEmpty) {
          try {
            enrichedGames = await enrichmentService.enrichGames(
              games,
              currentState.userId!,
            );
          } catch (e) {
          }
        }

        // hasMore = true if we got a full page
        final hasMore = games.length == _pageSize;

        emit(GameEngineGamesLoaded(
          gameEngineId: currentState.gameEngineId,
          gameEngineName: currentState.gameEngineName,
          games: enrichedGames, // 🆕 Use enriched games
          hasMore: hasMore,
          currentPage: 0,
          sortBy: event.sortBy,
          sortOrder: event.sortOrder,
          userId: currentState.userId, // 🆕 Keep userId
        ));
      },
    );
  }
}
