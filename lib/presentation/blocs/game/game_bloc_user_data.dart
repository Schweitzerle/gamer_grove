part of 'game_bloc.dart';

extension _GameBlocUserData on GameBloc {
  // Load User Wishlist
  Future<void> _onLoadUserWishlist(
    LoadUserWishlistEvent event,
    Emitter<GameState> emit,
  ) async {
    emit(UserWishlistLoading());

    final result = await getUserWishlist(
      GetUserWishlistParams(userId: event.userId, limit: 20, offset: 0),
    );

    result.fold(
      (failure) => emit(GameError(failure.message)),
      (games) => emit(
        UserWishlistLoaded(
          games: games,
          userId: event.userId,
        ),
      ),
    );
  }

  // Load User Recommendations
  Future<void> _onLoadUserRecommendations(
    LoadUserRecommendationsEvent event,
    Emitter<GameState> emit,
  ) async {
    emit(UserRecommendationsLoading());

    final result = await getUserRecommendations(
      GetUserRecommendationsParams(userId: event.userId, limit: 20, offset: 0),
    );

    result.fold(
      (failure) => emit(GameError(failure.message)),
      (games) => emit(
        UserRecommendationsLoaded(
          games: games,
          userId: event.userId,
        ),
      ),
    );
  }

  // Load User Rated
  Future<void> _onLoadUserRated(
    LoadUserRatedEvent event,
    Emitter<GameState> emit,
  ) async {
    emit(UserRatedLoading());

    final result = await getUserRated(
      GetUserRatedParams(userId: event.userId, limit: 20, offset: 0),
    );

    result.fold(
      (failure) => emit(GameError(failure.message)),
      (games) => emit(
        UserRatedLoaded(
          games: games,
          userId: event.userId,
        ),
      ),
    );
  }

  // Load All User Rated
  Future<void> _onLoadAllUserRated(
    LoadAllUserRatedEvent event,
    Emitter<GameState> emit,
  ) async {
    emit(UserRatedLoading());

    final result = await getUserRated(
      GetUserRatedParams(userId: event.userId, limit: 500, offset: 0),
    );

    result.fold(
      (failure) => emit(GameError(failure.message)),
      (games) => emit(
        AllUserRatedLoaded(
          games,
        ),
      ),
    );
  }

  // Load All User Wishlist
  Future<void> _onLoadAllUserWishlist(
    LoadAllUserWishlistEvent event,
    Emitter<GameState> emit,
  ) async {
    emit(UserWishlistLoading());

    final result = await getUserWishlist(
      GetUserWishlistParams(userId: event.userId, limit: 500, offset: 0),
    );

    result.fold(
      (failure) => emit(GameError(failure.message)),
      (games) => emit(
        AllUserWishlistedLoaded(
          games,
        ),
      ),
    );
  }

// Load All User Recommendations
  Future<void> _onLoadAllUserRecommendations(
    LoadAllUserRecommendationsEvent event,
    Emitter<GameState> emit,
  ) async {
    emit(UserRecommendationsLoading());

    final result = await getUserRecommendations(
      GetUserRecommendationsParams(userId: event.userId, limit: 500, offset: 0),
    );

    result.fold(
      (failure) => emit(GameError(failure.message)),
      (games) => emit(
        AllUserRecommendationsLoaded(
          games,
        ),
      ),
    );
  }

  Future<void> _onToggleWishlist(
    ToggleWishlistEvent event,
    Emitter<GameState> emit,
  ) async {
    final result = await toggleWishlist(
      ToggleWishlistParams(
        gameId: event.gameId,
        userId: event.userId,
      ),
    );

    result.fold(
      (failure) {
        if (!emit.isDone) {
          emit(GameError(failure.message));
        }
      },
      (_) {
        // 🎯 UPDATE CACHE FIRST - this persists across state changes!
        _updateGameInCache(event.gameId, (game) {
          return game.copyWith(isWishlisted: !game.isWishlisted);
        });

        // ✅ EXPLIZIT GameDetailsLoaded State aktualisieren
        if (state is GameDetailsLoaded && !emit.isDone) {
          final currentGame = (state as GameDetailsLoaded).game;
          if (currentGame.id == event.gameId) {
            final updatedGame =
                currentGame.copyWith(isWishlisted: !currentGame.isWishlisted);
            _updateGameCache(
              event.gameId,
              updatedGame,
            ); // Cache the updated game
            emit(GameDetailsLoaded(updatedGame));
          }
        }

        // Auch andere States updaten
        _updateGameInAllStates(
          event.gameId,
          (game) {
            return game.copyWith(isWishlisted: !game.isWishlisted);
          },
          emit,
        );
      },
    );
  }

  Future<void> _onToggleRecommend(
    ToggleRecommendEvent event,
    Emitter<GameState> emit,
  ) async {
    final result = await toggleRecommend(
      ToggleRecommendParams(
        gameId: event.gameId,
        userId: event.userId,
      ),
    );

    result.fold(
      (failure) {
        if (!emit.isDone) {
          emit(GameError(failure.message));
        }
      },
      (_) {
        // 🎯 UPDATE CACHE FIRST
        _updateGameInCache(event.gameId, (game) {
          return game.copyWith(isRecommended: !game.isRecommended);
        });

        // ✅ EXPLIZIT GameDetailsLoaded State aktualisieren
        if (state is GameDetailsLoaded && !emit.isDone) {
          final currentGame = (state as GameDetailsLoaded).game;
          if (currentGame.id == event.gameId) {
            final updatedGame =
                currentGame.copyWith(isRecommended: !currentGame.isRecommended);
            _updateGameCache(event.gameId, updatedGame);
            emit(GameDetailsLoaded(updatedGame));
          }
        }

        // Auch andere States updaten
        _updateGameInAllStates(
          event.gameId,
          (game) {
            return game.copyWith(isRecommended: !game.isRecommended);
          },
          emit,
        );
      },
    );
  }

  // ✅ Update Rate Game um Home State zu aktualisieren
  Future<void> _onRateGame(
    RateGameEvent event,
    Emitter<GameState> emit,
  ) async {
    final result = await rateGame(
      RateGameParams(
        gameId: event.gameId,
        userId: event.userId,
        rating: event.rating,
      ),
    );

    result.fold(
      (failure) => emit(GameError(failure.message)),
      (_) {
        // 🎯 UPDATE CACHE FIRST
        _updateGameInCache(event.gameId, (game) {
          return game.copyWith(userRating: event.rating);
        });

        // Update in allen States
        _updateGameInHomePageState(
          event.gameId,
          (game) {
            return game.copyWith(userRating: event.rating);
          },
          emit,
        );

        // Falls aktueller State GameDetailsLoaded ist
        if (state is GameDetailsLoaded) {
          final currentGame = (state as GameDetailsLoaded).game;
          if (currentGame.id == event.gameId) {
            final updatedGame = currentGame.copyWith(userRating: event.rating);
            _updateGameCache(event.gameId, updatedGame);
            emit(GameDetailsLoaded(updatedGame));
          }
        }
      },
    );
  }

  Future<void> _onRemoveRating(
    RemoveRatingEvent event,
    Emitter<GameState> emit,
  ) async {
    final result = await removeRating(
      RemoveRatingParams(
        gameId: event.gameId,
        userId: event.userId,
      ),
    );

    result.fold(
      (failure) => emit(GameError(failure.message)),
      (_) {
        // 🎯 UPDATE CACHE FIRST
        _updateGameInCache(event.gameId, (game) {
          return game.copyWith();
        });

        // Update in allen States
        _updateGameInHomePageState(
          event.gameId,
          (game) {
            return game.copyWith();
          },
          emit,
        );

        // Falls aktueller State GameDetailsLoaded ist
        if (state is GameDetailsLoaded) {
          final currentGame = (state as GameDetailsLoaded).game;
          if (currentGame.id == event.gameId) {
            final updatedGame = currentGame.copyWith();
            _updateGameCache(event.gameId, updatedGame);
            emit(GameDetailsLoaded(updatedGame));
          }
        }
      },
    );
  }

  Future<void> _onAddToTopThree(
    AddToTopThreeEvent event,
    Emitter<GameState> emit,
  ) async {
    final result = await addToTopThree(
      AddToTopThreeParams(
        userId: event.userId,
        gameId: event.gameId,
        position: event.position,
      ),
    );

    result.fold(
      (failure) {
        if (!emit.isDone) {
          emit(GameError(_mapFailureToMessage(failure)));
        }
      },
      (_) async {
        // 🎯 UPDATE CACHE FIRST
        _updateGameInCache(event.gameId, (game) {
          return game.copyWith(
            isInTopThree: true,
            topThreePosition: event.position,
          );
        });

        // Update the specific game in all relevant states
        _updateGameInAllStates(
          event.gameId,
          (game) {
            return game.copyWith(
              isInTopThree: true,
              topThreePosition: event.position,
            );
          },
          emit,
        );

        // If the current state is GrovePageLoaded, update its userTopThree list
        if (state is GrovePageLoaded) {
          final result = await getUserTopThree(
              GetUserTopThreeParams(userId: event.userId));
          result.fold(
            (failure) => emit(GameError(_mapFailureToMessage(failure))),
            (games) {
              emit((state as GrovePageLoaded).copyWith(userTopThree: games));
            },
          );
        }
      },
    );
  }

  Future<void> _onRemoveFromTopThree(
    RemoveFromTopThreeEvent event,
    Emitter<GameState> emit,
  ) async {
    final result = await removeFromTopThree(
      RemoveFromTopThreeParams(
        userId: event.userId,
        gameId: event.gameId,
      ),
    );

    result.fold(
      (failure) {
        if (!emit.isDone) {
          emit(GameError(_mapFailureToMessage(failure)));
        }
      },
      (_) async {
        // 🎯 UPDATE CACHE FIRST
        _updateGameInCache(event.gameId, (game) {
          return game.copyWith(
            isInTopThree: false,
          );
        });

        // Update the specific game in all relevant states
        _updateGameInAllStates(
          event.gameId,
          (game) {
            return game.copyWith(
              isInTopThree: false,
            );
          },
          emit,
        );

        // If the current state is GrovePageLoaded, update its userTopThree list
        if (state is GrovePageLoaded) {
          final result = await getUserTopThree(
              GetUserTopThreeParams(userId: event.userId));
          result.fold(
            (failure) => emit(GameError(_mapFailureToMessage(failure))),
            (games) {
              emit((state as GrovePageLoaded).copyWith(userTopThree: games));
            },
          );
        }
      },
    );
  }

  Future<void> _onLoadAllUserRatedPaginated(
    LoadAllUserRatedPaginated event,
    Emitter<GameState> emit,
  ) async {
    emit(AllUserRatedPaginatedLoading());

    final result = await getUserRated(
      GetUserRatedParams(userId: event.userId, limit: 20, offset: 0),
    );

    result.fold(
      (failure) => emit(AllUserRatedPaginatedError(failure.message)),
      (games) {
        emit(
          AllUserRatedPaginatedLoaded(
            games: games,
            hasReachedMax: games.length < 20,
          ),
        );
      },
    );
  }

  Future<void> _onLoadMoreUserRatedPaginated(
    LoadMoreUserRatedPaginated event,
    Emitter<GameState> emit,
  ) async {
    if (state is AllUserRatedPaginatedLoaded) {
      final currentState = state as AllUserRatedPaginatedLoaded;

      if (currentState.hasReachedMax) return;

      final offset = currentState.games.length;
      final result = await getUserRated(
        GetUserRatedParams(userId: event.userId, limit: 20, offset: offset),
      );

      result.fold(
        (failure) => emit(AllUserRatedPaginatedError(failure.message)),
        (newGames) {
          emit(
            currentState.copyWith(
              games: List.of(currentState.games)..addAll(newGames),
              hasReachedMax: newGames.length < 20,
            ),
          );
        },
      );
    }
  }

  Future<void> _onLoadAllUserWishlistPaginated(
    LoadAllUserWishlistPaginated event,
    Emitter<GameState> emit,
  ) async {
    emit(AllUserWishlistPaginatedLoading());

    final result = await getUserWishlist(
      GetUserWishlistParams(userId: event.userId, limit: 20, offset: 0),
    );

    result.fold(
      (failure) => emit(AllUserWishlistPaginatedError(failure.message)),
      (games) {
        emit(
          AllUserWishlistPaginatedLoaded(
            games: games,
            hasReachedMax: games.length < 20,
          ),
        );
      },
    );
  }

  Future<void> _onLoadMoreUserWishlistPaginated(
    LoadMoreUserWishlistPaginated event,
    Emitter<GameState> emit,
  ) async {
    if (state is AllUserWishlistPaginatedLoaded) {
      final currentState = state as AllUserWishlistPaginatedLoaded;

      if (currentState.hasReachedMax) return;

      final offset = currentState.games.length;
      final result = await getUserWishlist(
        GetUserWishlistParams(userId: event.userId, limit: 20, offset: offset),
      );

      result.fold(
        (failure) => emit(AllUserWishlistPaginatedError(failure.message)),
        (newGames) {
          emit(
            currentState.copyWith(
              games: List.of(currentState.games)..addAll(newGames),
              hasReachedMax: newGames.length < 20,
            ),
          );
        },
      );
    }
  }

  Future<void> _onLoadAllUserRecommendedPaginated(
    LoadAllUserRecommendedPaginated event,
    Emitter<GameState> emit,
  ) async {
    emit(AllUserRecommendedPaginatedLoading());

    final result = await getUserRecommendations(
      GetUserRecommendationsParams(userId: event.userId, limit: 20, offset: 0),
    );

    result.fold(
      (failure) => emit(AllUserRecommendedPaginatedError(failure.message)),
      (games) {
        emit(
          AllUserRecommendedPaginatedLoaded(
            games: games,
            hasReachedMax: games.length < 20,
          ),
        );
      },
    );
  }

  Future<void> _onLoadMoreUserRecommendedPaginated(
    LoadMoreUserRecommendedPaginated event,
    Emitter<GameState> emit,
  ) async {
    if (state is AllUserRecommendedPaginatedLoaded) {
      final currentState = state as AllUserRecommendedPaginatedLoaded;

      if (currentState.hasReachedMax) return;

      final offset = currentState.games.length;
      final result = await getUserRecommendations(
        GetUserRecommendationsParams(
          userId: event.userId,
          limit: 20,
          offset: offset,
        ),
      );

      result.fold(
        (failure) => emit(AllUserRecommendedPaginatedError(failure.message)),
        (newGames) {
          emit(
            currentState.copyWith(
              games: List.of(currentState.games)..addAll(newGames),
              hasReachedMax: newGames.length < 20,
            ),
          );
        },
      );
    }
  }
}
