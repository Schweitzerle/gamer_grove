part of 'game_bloc.dart';

extension _GameBlocCurated on GameBloc {
  // Load Popular Games
  Future<void> _onLoadPopularGames(
    LoadPopularGamesEvent event,
    Emitter<GameState> emit,
  ) async {
    if (event.offset == 0) {
      emit(PopularGamesLoading());
    } else if (state is PopularGamesLoaded) {
      final currentState = state as PopularGamesLoaded;
      emit(currentState.copyWith(isLoadingMore: true));
    }

    final result = await getPopularGames(
      GetPopularGamesParams(
        limit: event.limit,
        offset: event.offset,
      ),
    );

    result.fold(
      (failure) => emit(GameError(failure.message)),
      (games) {
        if (event.offset == 0) {
          // Initial load
          emit(
            PopularGamesLoaded(
              games: games,
              hasReachedMax: games.length < event.limit,
            ),
          );
        } else if (state is PopularGamesLoaded) {
          // Load more
          final currentState = state as PopularGamesLoaded;
          emit(
            currentState.copyWith(
              games: List.of(currentState.games)..addAll(games),
              hasReachedMax: games.length < event.limit,
              isLoadingMore: false,
            ),
          );
        }
      },
    );
  }

  // Load Upcoming Games
  Future<void> _onLoadUpcomingGames(
    LoadUpcomingGamesEvent event,
    Emitter<GameState> emit,
  ) async {
    if (event.offset == 0) {
      emit(UpcomingGamesLoading());
    } else if (state is UpcomingGamesLoaded) {
      final currentState = state as UpcomingGamesLoaded;
      emit(currentState.copyWith(isLoadingMore: true));
    }

    final result = await getUpcomingGames(
      GetUpcomingGamesParams(
        limit: event.limit,
        offset: event.offset,
      ),
    );

    result.fold(
      (failure) => emit(GameError(failure.message)),
      (games) {
        if (event.offset == 0) {
          emit(
            UpcomingGamesLoaded(
              games: games,
              hasReachedMax: games.length < event.limit,
            ),
          );
        } else if (state is UpcomingGamesLoaded) {
          final currentState = state as UpcomingGamesLoaded;
          emit(
            currentState.copyWith(
              games: List.of(currentState.games)..addAll(games),
              hasReachedMax: games.length < event.limit,
              isLoadingMore: false,
            ),
          );
        }
      },
    );
  }

  // Load Popular Games
  Future<void> _onLoadTopRatedGames(
    LoadTopRatedGamesEvent event,
    Emitter<GameState> emit,
  ) async {
    if (event.offset == 0) {
      emit(TopRatedGamesLoading());
    } else if (state is TopRatedGamesLoaded) {
      final currentState = state as TopRatedGamesLoaded;
      emit(currentState.copyWith(isLoadingMore: true));
    }

    final result = await getTopRatedGames(
      GetTopRatedGamesParams(
        limit: event.limit,
        offset: event.offset,
      ),
    );

    result.fold(
      (failure) => emit(GameError(failure.message)),
      (games) {
        if (event.offset == 0) {
          // Initial load
          emit(
            TopRatedGamesLoaded(
              games: games,
              hasReachedMax: games.length < event.limit,
            ),
          );
        } else if (state is TopRatedGamesLoaded) {
          // Load more
          final currentState = state as TopRatedGamesLoaded;
          emit(
            currentState.copyWith(
              games: List.of(currentState.games)..addAll(games),
              hasReachedMax: games.length < event.limit,
              isLoadingMore: false,
            ),
          );
        }
      },
    );
  }

  // Home Page Data Loading

  Future<void> _onLoadHomePageData(
    LoadHomePageDataEvent event,
    Emitter<GameState> emit,
  ) async {
    emit(HomePageLoading());

    try {
      // Load all data in parallel
      final results = await Future.wait([
        getPopularGames(const GetPopularGamesParams(limit: 10)),
        getUpcomingGames(const GetUpcomingGamesParams(limit: 10)),
        getLatestGames(const GetLatestGamesParams(limit: 10)),
        getTopRatedGames(const GetTopRatedGamesParams(limit: 10)),
        getUpcomingEvents(const GetUpcomingEventsParams()),
      ]);

      // Extract results
      final popularGames = results[0].fold<List<Game>>(
        (l) {
          return <Game>[];
        },
        (r) {
          return r as List<Game>;
        },
      );
      final upcomingGames = results[1].fold<List<Game>>(
        (l) {
          return <Game>[];
        },
        (r) {
          return r as List<Game>;
        },
      );
      final latestGames = results[2].fold<List<Game>>(
        (l) {
          return <Game>[];
        },
        (r) {
          return r as List<Game>;
        },
      );
      final topRatedGames = results[3].fold<List<Game>>(
        (l) {
          return <Game>[];
        },
        (r) {
          return r as List<Game>;
        },
      );
      final upcomingEvents = results[4].fold<List<Event>>(
        (l) {
          return <Event>[];
        },
        (r) {
          return r as List<Event>;
        },
      );
      final userWishlist = event.userId != null && results.length > 5
          ? results[5].fold((l) => <Game>[], (r) => r as List<Game>)
          : <Game>[];
      final userRecommendations = event.userId != null && results.length > 6
          ? results[6].fold((l) => <Game>[], (r) => r as List<Game>)
          : <Game>[];

      // 🔥 WICHTIG: Alle Games mit User Data anreichern
      if (event.userId != null) {
        final enrichedPopular =
            await enrichGamesWithUserData(popularGames, event.userId!);
        final enrichedUpcoming =
            await enrichGamesWithUserData(upcomingGames, event.userId!);
        final enrichLatest =
            await enrichGamesWithUserData(latestGames, event.userId!);
        final enrichedTopRated =
            await enrichGamesWithUserData(topRatedGames, event.userId!);
        // ✅ NEU: Auch Wishlist und Recommendations anreichern (für Top 3, etc.)
        final enrichedWishlist = userWishlist.isNotEmpty
            ? await enrichGamesWithUserData(userWishlist, event.userId!)
            : <Game>[];
        final enrichedRecommendations = userRecommendations.isNotEmpty
            ? await enrichGamesWithUserData(userRecommendations, event.userId!)
            : <Game>[];

        // 🎯 CACHE GAMES for persistence
        _updateGamesCacheList(enrichedPopular);
        _updateGamesCacheList(enrichedUpcoming);
        _updateGamesCacheList(enrichLatest);
        _updateGamesCacheList(enrichedTopRated);
        _updateGamesCacheList(enrichedWishlist);
        _updateGamesCacheList(enrichedRecommendations);

        // 🎯 APPLY CACHE - this ensures any user actions are reflected!
        emit(
          HomePageLoaded(
            popularGames: _applyCache(enrichedPopular),
            upcomingGames: _applyCache(enrichedUpcoming),
            latestGames: _applyCache(enrichLatest),
            topRatedGames: _applyCache(enrichedTopRated),
            userWishlist: _applyCache(enrichedWishlist),
            userRecommendations: _applyCache(enrichedRecommendations),
            upcomingEvents: upcomingEvents,
          ),
        );
      } else {
        // 🎯 CACHE GAMES even without user data
        _updateGamesCacheList(popularGames);
        _updateGamesCacheList(upcomingGames);
        _updateGamesCacheList(latestGames);
        _updateGamesCacheList(topRatedGames);

        emit(
          HomePageLoaded(
            popularGames: _applyCache(popularGames),
            upcomingGames: _applyCache(upcomingGames),
            latestGames: _applyCache(latestGames),
            topRatedGames: _applyCache(topRatedGames),
            upcomingEvents: upcomingEvents,
          ),
        );
      }
    } catch (e) {
      emit(GameError('Failed to load home page data: $e'));
    }
  }

  Future<void> _onLoadGrovePageData(
    LoadGrovePageDataEvent event,
    Emitter<GameState> emit,
  ) async {
    emit(GrovePageLoading());

    try {
      if (event.userId == null) {
        // Wenn kein User eingeloggt ist, leere Listen zurückgeben
        emit(
          const GrovePageLoaded(
            userRated: <Game>[],
            userWishlist: <Game>[],
            userRecommendations: <Game>[],
            userTopThree: <Game>[],
          ),
        );
        return;
      }

      // Alle Daten parallel laden
      final results = await Future.wait([
        getUserRated(
          GetUserRatedParams(userId: event.userId!, limit: 20, offset: 0),
        ),
        getUserWishlist(
          GetUserWishlistParams(userId: event.userId!, limit: 20, offset: 0),
        ),
        getUserRecommendations(
          GetUserRecommendationsParams(
            userId: event.userId!,
            limit: 20,
            offset: 0,
          ),
        ),
        getUserTopThree(GetUserTopThreeParams(userId: event.userId!)),
      ]);

      // ✅ KORREKTE Result-Extraktion (keine conditional spreads!)
      final userRated = results[0].fold((l) => <Game>[], (r) => r);
      final userWishlist = results[1].fold((l) => <Game>[], (r) => r);
      final userRecommendations = results[2].fold((l) => <Game>[], (r) => r);
      final userTopThree = results[3].fold((l) => <Game>[], (r) => r);

      // Games mit User Data anreichern
      final enrichedRated = userRated.isNotEmpty
          ? await enrichGamesWithUserData(userRated, event.userId!)
          : <Game>[];
      final enrichedWishlist = userWishlist.isNotEmpty
          ? await enrichGamesWithUserData(userWishlist, event.userId!)
          : <Game>[];
      final enrichedRecommendations = userRecommendations.isNotEmpty
          ? await enrichGamesWithUserData(userRecommendations, event.userId!)
          : <Game>[];
      final enrichedTopThree = userTopThree.isNotEmpty
          ? await enrichGamesWithUserData(userTopThree, event.userId!)
          : <Game>[];

      // 🎯 CACHE GAMES for persistence
      _updateGamesCacheList(enrichedRated);
      _updateGamesCacheList(enrichedWishlist);
      _updateGamesCacheList(enrichedRecommendations);
      _updateGamesCacheList(enrichedTopThree);

      // 🎯 APPLY CACHE - this ensures any user actions are reflected!
      emit(
        GrovePageLoaded(
          userRated: _applyCache(enrichedRated),
          userWishlist: _applyCache(enrichedWishlist),
          userRecommendations: _applyCache(enrichedRecommendations),
          userTopThree: _applyCache(enrichedTopThree),
        ),
      );
    } catch (e) {
      emit(GameError('Failed to load grove page data: $e'));
    }
  }
}
