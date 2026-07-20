part of 'game_bloc.dart';

extension _GameBlocSearch on GameBloc {
  // Search Games
  Future<void> _onSearchGames(
    SearchGamesEvent event,
    Emitter<GameState> emit,
  ) async {
    if (event.query.isEmpty) {
      emit(GameInitial());
      return;
    }

    emit(GameSearchLoading());

    final result = await searchGames(
      SearchGamesParams(
        query: event.query,
      ),
    );

    result.fold(
      (failure) => emit(GameError(failure.message)),
      (games) async {
        // Enrich games with user data if userId is provided
        final enrichedGames = event.userId != null
            ? await enrichGamesWithUserData(games, event.userId!)
            : games;

        emit(
          GameSearchLoaded(
            games: enrichedGames,
            hasReachedMax: games.length < 20,
            currentQuery: event.query,
          ),
        );
      },
    );
  }

  // Load More Games (for search pagination)
  Future<void> _onLoadMoreGames(
    LoadMoreGamesEvent event,
    Emitter<GameState> emit,
  ) async {
    if (state is GameSearchLoaded) {
      final currentState = state as GameSearchLoaded;

      if (currentState.hasReachedMax) return;

      emit(currentState.copyWith(isLoadingMore: true));

      // Use searchGamesWithFilters if filters are present
      final result = currentState.currentFilters != null
          ? await gameRepository.searchGamesWithFilters(
              query: currentState.currentQuery,
              filters: currentState.currentFilters!,
              offset: currentState.games.length,
            )
          : await searchGames(
              SearchGamesParams(
                query: currentState.currentQuery,
                offset: currentState.games.length,
              ),
            );

      result.fold(
        (failure) => emit(GameError(failure.message)),
        (games) {
          if (games.isEmpty) {
            emit(
              currentState.copyWith(
                hasReachedMax: true,
                isLoadingMore: false,
              ),
            );
          } else {
            emit(
              currentState.copyWith(
                games: List.of(currentState.games)..addAll(games),
                hasReachedMax: games.length < 20,
                isLoadingMore: false,
              ),
            );
          }
        },
      );
    }
  }

  // Clear Search
  void _onClearSearch(
    ClearSearchEvent event,
    Emitter<GameState> emit,
  ) {
    emit(GameInitial());
  }

  // Search Games with Filters
  Future<void> _onSearchGamesWithFilters(
    SearchGamesWithFiltersEvent event,
    Emitter<GameState> emit,
  ) async {
    if (event.query.isEmpty && !event.filters.hasFilters) {
      emit(GameInitial());
      return;
    }

    emit(GameSearchLoading());

    final result = await gameRepository.searchGamesWithFilters(
      query: event.query,
      filters: event.filters,
    );

    result.fold(
      (failure) => emit(GameSearchError(message: failure.message)),
      (games) => emit(
        GameSearchLoaded(
          games: games,
          hasReachedMax: games.length < 20,
          currentQuery: event.query,
          currentFilters: event.filters,
        ),
      ),
    );
  }

  // Save Search Query
  Future<void> _onSaveSearchQuery(
    SaveSearchQueryEvent event,
    Emitter<GameState> emit,
  ) async {
    try {
      await gameRepository.saveSearchQuery(event.userId, event.query);
      // Optional: emit success state if needed
    } catch (e) {
      // Silently fail - search query saving is not critical
    }
  }
}
