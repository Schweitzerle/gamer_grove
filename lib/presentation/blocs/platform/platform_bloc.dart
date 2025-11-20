// ==================================================
// PLATFORM BLOC IMPLEMENTATION (ERWEITERT)
// ==================================================

// lib/presentation/blocs/platform/platform_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamer_grove/core/services/game_enrichment_service.dart';
import 'package:gamer_grove/domain/repositories/game_repository.dart';
import 'package:gamer_grove/domain/usecases/platform/get_platform_with_games.dart';
import 'package:gamer_grove/presentation/blocs/platform/platform_event.dart';
import 'package:gamer_grove/presentation/blocs/platform/platform_state.dart';

class PlatformBloc extends Bloc<PlatformEvent, PlatformState> {

  PlatformBloc({
    required this.getPlatformWithGames,
    required this.gameRepository,
    required this.enrichmentService,
  }) : super(PlatformInitial()) {
    on<GetPlatformDetailsEvent>(_onGetPlatformDetails);
    on<ClearPlatformEvent>(_onClearPlatform);
    // 🆕 Neue Event Handler
    on<LoadPlatformGamesEvent>(_onLoadPlatformGames);
    on<LoadMorePlatformGamesEvent>(_onLoadMorePlatformGames);
    on<ChangePlatformSortEvent>(_onChangePlatformSort);
  }
  final GetPlatformWithGames getPlatformWithGames;
  final GameRepository gameRepository; // 🆕 Repository für paginierte Anfragen
  final GameEnrichmentService enrichmentService;

  // Pagination constants
  static const int _pageSize = 20;

  // ==========================================
  // EXISTING EVENT HANDLERS
  // ==========================================

  Future<void> _onGetPlatformDetails(
    GetPlatformDetailsEvent event,
    Emitter<PlatformState> emit,
  ) async {
    emit(PlatformLoading());

    final result = await getPlatformWithGames(
      GetPlatformWithGamesParams(
        platformId: event.platformId,
        includeGames: event.includeGames,
      ),
    );

    await result.fold(
      (failure) async {
        emit(PlatformError(message: failure.message));
      },
      (platformWithGames) async {
        // 🔧 ENRICHMENT LOGIC mit GameEnrichmentUtils
        if (event.userId != null && platformWithGames.games.isNotEmpty) {
          try {
            final enrichedGames = await enrichmentService.enrichGames(
              platformWithGames.games,
              event.userId!,
            );
            emit(PlatformDetailsLoaded(
              platform: platformWithGames.platform,
              games: enrichedGames,
            ),);
          } catch (e) {
            emit(PlatformDetailsLoaded(
              platform: platformWithGames.platform,
              games: platformWithGames.games,
            ),);
          }
        } else {
          emit(PlatformDetailsLoaded(
            platform: platformWithGames.platform,
            games: platformWithGames.games,
          ),);
        }
      },
    );
  }

  Future<void> _onClearPlatform(
    ClearPlatformEvent event,
    Emitter<PlatformState> emit,
  ) async {
    emit(PlatformInitial());
  }

  // ==========================================
  // 🆕 NEW EVENT HANDLERS FOR PAGINATED GAMES
  // ==========================================

  Future<void> _onLoadPlatformGames(
    LoadPlatformGamesEvent event,
    Emitter<PlatformState> emit,
  ) async {

    // Show loading state
    emit(PlatformGamesLoading(
      platformId: event.platformId,
      platformName: event.platformName,
    ),);

    // Fetch first page
    final result = await gameRepository.getGamesByPlatform(
      platformIds: [event.platformId],
      sortBy: event.sortBy,
      sortOrder: event.sortOrder,
    );

    await result.fold(
      (failure) async {
        emit(PlatformGamesError(
          platformId: event.platformId,
          platformName: event.platformName,
          message: failure.message,
        ),);
      },
      (games) async {

        // Enrich games if userId is provided
        var enrichedGames = games;
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

        emit(PlatformGamesLoaded(
          platformId: event.platformId,
          platformName: event.platformName,
          games: enrichedGames,
          hasMore: hasMore,
          sortBy: event.sortBy,
          sortOrder: event.sortOrder,
          userId: event.userId,
        ),);
      },
    );
  }

  Future<void> _onLoadMorePlatformGames(
    LoadMorePlatformGamesEvent event,
    Emitter<PlatformState> emit,
  ) async {
    // Only load more if we're in the PlatformGamesLoaded state
    if (state is! PlatformGamesLoaded) return;

    final currentState = state as PlatformGamesLoaded;

    // Don't load if already loading or no more games
    if (currentState.isLoadingMore || !currentState.hasMore) {
      return;
    }


    // Set loading more flag
    emit(currentState.copyWith(isLoadingMore: true));

    final nextPage = currentState.currentPage + 1;
    final offset = nextPage * _pageSize;

    // Fetch next page
    final result = await gameRepository.getGamesByPlatform(
      platformIds: [currentState.platformId],
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
        var enrichedNewGames = newGames;
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

        emit(PlatformGamesLoaded(
          platformId: currentState.platformId,
          platformName: currentState.platformName,
          games: allGames,
          hasMore: hasMore,
          currentPage: nextPage,
          sortBy: currentState.sortBy,
          sortOrder: currentState.sortOrder,
          userId: currentState.userId,
        ),);
      },
    );
  }

  Future<void> _onChangePlatformSort(
    ChangePlatformSortEvent event,
    Emitter<PlatformState> emit,
  ) async {
    // Only change sort if we're in the PlatformGamesLoaded state
    if (state is! PlatformGamesLoaded) return;

    final currentState = state as PlatformGamesLoaded;


    // Show loading state
    emit(PlatformGamesLoading(
      platformId: currentState.platformId,
      platformName: currentState.platformName,
    ),);

    // Fetch first page with new sort
    final result = await gameRepository.getGamesByPlatform(
      platformIds: [currentState.platformId],
      sortBy: event.sortBy,
      sortOrder: event.sortOrder,
    );

    await result.fold(
      (failure) async {
        emit(PlatformGamesError(
          platformId: currentState.platformId,
          platformName: currentState.platformName,
          message: failure.message,
        ),);
      },
      (games) async {

        // Enrich games if userId is available
        var enrichedGames = games;
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

        emit(PlatformGamesLoaded(
          platformId: currentState.platformId,
          platformName: currentState.platformName,
          games: enrichedGames,
          hasMore: hasMore,
          sortBy: event.sortBy,
          sortOrder: event.sortOrder,
          userId: currentState.userId,
        ),);
      },
    );
  }
}
