// ==================================================
// PLATFORM BLOC IMPLEMENTATION (ERWEITERT)
// ==================================================

// lib/presentation/blocs/platform/platform_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamer_grove/domain/entities/game/game.dart';
import 'package:gamer_grove/domain/repositories/game_repository.dart';
import 'package:gamer_grove/domain/usecases/platform/get_platform_with_games.dart';
import 'package:gamer_grove/presentation/blocs/platform/platform_event.dart';
import 'package:gamer_grove/presentation/blocs/platform/platform_state.dart';
import '../../../core/utils/game_enrichment_utils.dart';

class PlatformBloc extends Bloc<PlatformEvent, PlatformState> {
  final GetPlatformWithGames getPlatformWithGames;
  final GameRepository gameRepository; // 🆕 Repository für paginierte Anfragen

  // Pagination constants
  static const int _pageSize = 20;

  PlatformBloc({
    required this.getPlatformWithGames,
    required this.gameRepository,
  }) : super(PlatformInitial()) {
    on<GetPlatformDetailsEvent>(_onGetPlatformDetails);
    on<ClearPlatformEvent>(_onClearPlatform);
    // 🆕 Neue Event Handler
    on<LoadPlatformGamesEvent>(_onLoadPlatformGames);
    on<LoadMorePlatformGamesEvent>(_onLoadMorePlatformGames);
    on<ChangePlatformSortEvent>(_onChangePlatformSort);
  }

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
            print(
                '🎮 PlatformBloc: Enriching platform games with GameEnrichmentUtils...');

            // Verwende die Utils für Game Enrichment
            final enrichedGames = await GameEnrichmentUtils.enrichPlatformGames(
              platformWithGames.games,
              event.userId!,
            );

            // Debug Stats
            GameEnrichmentUtils.printEnrichmentStats(enrichedGames,
                context: 'Platform');

            emit(PlatformDetailsLoaded(
              platform: platformWithGames.platform,
              games: enrichedGames,
            ));
          } catch (e) {
            print('❌ PlatformBloc: Failed to enrich games: $e');
            emit(PlatformDetailsLoaded(
              platform: platformWithGames.platform,
              games: platformWithGames.games,
            ));
          }
        } else {
          emit(PlatformDetailsLoaded(
            platform: platformWithGames.platform,
            games: platformWithGames.games,
          ));
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
    print(
        '🎮 PlatformBloc: Loading paginated games for platform ${event.platformId}');
    print(
        '🎮 Sort: ${event.sortBy.displayName} ${event.sortOrder.displayName}');
    print('🎮 Refresh: ${event.refresh}');
    print('🎮 UserId: ${event.userId ?? "none"}');

    // Show loading state
    emit(PlatformGamesLoading(
      platformId: event.platformId,
      platformName: event.platformName,
    ));

    // Fetch first page
    final result = await gameRepository.getGamesByPlatform(
      platformIds: [event.platformId],
      limit: _pageSize,
      offset: 0,
      sortBy: event.sortBy,
      sortOrder: event.sortOrder,
    );

    await result.fold(
      (failure) async {
        print('❌ PlatformBloc: Failed to load games: ${failure.message}');
        emit(PlatformGamesError(
          platformId: event.platformId,
          platformName: event.platformName,
          message: failure.message,
        ));
      },
      (games) async {
        print('✅ PlatformBloc: Loaded ${games.length} games');

        // Enrich games if userId is provided
        List<Game> enrichedGames = games;
        if (event.userId != null && games.isNotEmpty) {
          try {
            enrichedGames = await GameEnrichmentUtils.enrichPlatformGames(
              games,
              event.userId!,
            );
            print('✅ PlatformBloc: Enriched ${enrichedGames.length} games');
          } catch (e) {
            print('❌ PlatformBloc: Failed to enrich games: $e');
          }
        }

        // hasMore = true if we got a full page
        final hasMore = games.length == _pageSize;

        emit(PlatformGamesLoaded(
          platformId: event.platformId,
          platformName: event.platformName,
          games: enrichedGames,
          hasMore: hasMore,
          currentPage: 0,
          sortBy: event.sortBy,
          sortOrder: event.sortOrder,
          userId: event.userId,
        ));
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
      print(
          '⏭️ PlatformBloc: Skipping load more (loading: ${currentState.isLoadingMore}, hasMore: ${currentState.hasMore})');
      return;
    }

    print(
        '🎮 PlatformBloc: Loading more games (page ${currentState.currentPage + 1})');

    // Set loading more flag
    emit(currentState.copyWith(isLoadingMore: true));

    final nextPage = currentState.currentPage + 1;
    final offset = nextPage * _pageSize;

    // Fetch next page
    final result = await gameRepository.getGamesByPlatform(
      platformIds: [currentState.platformId],
      limit: _pageSize,
      offset: offset,
      sortBy: currentState.sortBy,
      sortOrder: currentState.sortOrder,
    );

    await result.fold(
      (failure) async {
        print('❌ PlatformBloc: Failed to load more games: ${failure.message}');
        // Keep current state but clear loading flag
        emit(currentState.copyWith(isLoadingMore: false));
      },
      (newGames) async {
        print('✅ PlatformBloc: Loaded ${newGames.length} more games');

        // Enrich new games if userId is available
        List<Game> enrichedNewGames = newGames;
        if (currentState.userId != null && newGames.isNotEmpty) {
          try {
            enrichedNewGames = await GameEnrichmentUtils.enrichPlatformGames(
              newGames,
              currentState.userId!,
            );
            print(
                '✅ PlatformBloc: Enriched ${enrichedNewGames.length} new games');
          } catch (e) {
            print('❌ PlatformBloc: Failed to enrich new games: $e');
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
          isLoadingMore: false,
          userId: currentState.userId,
        ));
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

    print(
        '🔄 PlatformBloc: Changing sort to ${event.sortBy.displayName} ${event.sortOrder.displayName}');
    print(
        '🔄 PlatformBloc: UserId from state: ${currentState.userId ?? "none"}');

    // Show loading state
    emit(PlatformGamesLoading(
      platformId: currentState.platformId,
      platformName: currentState.platformName,
    ));

    // Fetch first page with new sort
    final result = await gameRepository.getGamesByPlatform(
      platformIds: [currentState.platformId],
      limit: _pageSize,
      offset: 0,
      sortBy: event.sortBy,
      sortOrder: event.sortOrder,
    );

    await result.fold(
      (failure) async {
        print(
            '❌ PlatformBloc: Failed to reload with new sort: ${failure.message}');
        emit(PlatformGamesError(
          platformId: currentState.platformId,
          platformName: currentState.platformName,
          message: failure.message,
        ));
      },
      (games) async {
        print('✅ PlatformBloc: Reloaded ${games.length} games with new sort');

        // Enrich games if userId is available
        List<Game> enrichedGames = games;
        if (currentState.userId != null && games.isNotEmpty) {
          try {
            enrichedGames = await GameEnrichmentUtils.enrichPlatformGames(
              games,
              currentState.userId!,
            );
            print(
                '✅ PlatformBloc: Enriched ${enrichedGames.length} games after sort change');
          } catch (e) {
            print('❌ PlatformBloc: Failed to enrich games after sort: $e');
          }
        }

        // hasMore = true if we got a full page
        final hasMore = games.length == _pageSize;

        emit(PlatformGamesLoaded(
          platformId: currentState.platformId,
          platformName: currentState.platformName,
          games: enrichedGames,
          hasMore: hasMore,
          currentPage: 0,
          sortBy: event.sortBy,
          sortOrder: event.sortOrder,
          userId: currentState.userId,
        ));
      },
    );
  }
}
