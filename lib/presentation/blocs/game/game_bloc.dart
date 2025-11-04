// presentation/blocs/game/game_bloc.dart
import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:gamer_grove/domain/usecases/game/get_top_rated_games.dart';
import 'package:rxdart/rxdart.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import 'package:gamer_grove/core/services/game_enrichment_service.dart';
import '../../../data/models/game/game_model.dart';
import '../../../domain/entities/collection/collection.dart';
import '../../../domain/entities/event/event.dart';
import '../../../domain/entities/franchise.dart';
import '../../../domain/entities/game/game.dart';
import '../../../domain/entities/search/search_filters.dart';
import '../../../domain/repositories/game_repository.dart';
import '../../../domain/usecases/game/get_user_rated.dart';
import '../../../domain/usecases/game/get_game_dlcs.dart';
import '../../../domain/usecases/game/get_game_expansions.dart';
import '../../../domain/usecases/game/get_latest_games.dart';
import '../../../domain/usecases/game/get_similar_games.dart';
import '../../../domain/usecases/game/get_user_top_three.dart';
import '../../../domain/usecases/game_details/get_complete_game_details_page_data.dart';
import '../../../domain/usecases/game_details/get_enhanced_game_details.dart';
import '../../../domain/usecases/user/add_to_top_three.dart';
import '../../../domain/usecases/user/remove_from_top_three.dart';
import '../../../domain/usecases/game/search_games.dart';
import '../../../domain/usecases/game/get_game_details.dart';
import '../../../domain/usecases/game/rate_game.dart';
import '../../../domain/usecases/game/toggle_recommend.dart';
import '../../../domain/usecases/game/toggle_wishlist.dart';
import '../../../domain/usecases/game/get_popular_games.dart';
import '../../../domain/usecases/game/get_upcoming_games.dart';
import '../../../domain/usecases/game/get_user_wishlist.dart';
import '../../../domain/usecases/game/get_user_recommendations.dart';
import '../../../domain/usecases/user/get_user_top_three.dart';
import '../../../domain/usecases/event/get_upcoming_events.dart';
import 'game_extensions.dart';

part 'game_event.dart';

part 'game_state.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  final SearchGames searchGames;
  final GetGameDetails getGameDetails;
  final RateGame rateGame;
  final ToggleWishlist toggleWishlist;
  final ToggleRecommend toggleRecommend;
  final AddToTopThree addToTopThree;
  final RemoveFromTopThree removeFromTopThree;
  final GetPopularGames getPopularGames;
  final GetUpcomingGames getUpcomingGames;
  final GetLatestGames getLatestGames;
  final GetTopRatedGames getTopRatedGames;
  final GetUserWishlist getUserWishlist;
  final GetUserRecommendations getUserRecommendations;
  final GetUserTopThreeGames getUserTopThreeGames;
  final GetUserTopThree getUserTopThree;
  final GetUserRated getUserRated;
  final GetSimilarGames getSimilarGames;
  final GetGameDLCs getGameDLCs;
  final GetGameExpansions getGameExpansions;
  final GetEnhancedGameDetails getEnhancedGameDetails;
  final GetCompleteGameDetailPageData getCompleteGameDetailPageData;
  final GetUpcomingEvents getUpcomingEvents;
  final GameRepository gameRepository;
  final GameEnrichmentService enrichmentService;

  // 🎯 PERSISTENT GAME CACHE - survives state changes!
  final Map<int, Game> _gameCache = {};

  GameBloc({
    required this.searchGames,
    required this.getGameDetails,
    required this.rateGame,
    required this.toggleWishlist,
    required this.toggleRecommend,
    required this.addToTopThree,
    required this.removeFromTopThree,
    required this.getPopularGames,
    required this.getUpcomingGames,
    required this.getLatestGames,
    required this.getTopRatedGames,
    required this.getUserWishlist,
    required this.getUserRecommendations,
    required this.getUserTopThreeGames,
    required this.getUserTopThree,
    required this.getUserRated,
    required this.getSimilarGames,
    required this.getGameDLCs,
    required this.getGameExpansions,
    required this.getEnhancedGameDetails,
    required this.getCompleteGameDetailPageData,
    required this.getUpcomingEvents,
    required this.gameRepository,
    required this.enrichmentService,
  }) : super(GameInitial()) {
    // Search events
    on<SearchGamesEvent>(
      _onSearchGames,
      transformer: debounce(const Duration(milliseconds: 500)),
    );
    on<LoadMoreGamesEvent>(_onLoadMoreGames);
    on<ClearSearchEvent>(_onClearSearch);

    // Game detail events
    on<GetGameDetailsEvent>(_onGetGameDetails);
    on<RateGameEvent>(_onRateGame);
    on<ToggleWishlistEvent>(_onToggleWishlist);
    on<ToggleRecommendEvent>(_onToggleRecommend);
    on<AddToTopThreeEvent>(_onAddToTopThree);
    on<RemoveFromTopThreeEvent>(_onRemoveFromTopThree);
    on<UpdateTopThreeEvent>(_onUpdateTopThree);
    on<GetGameDetailsWithUserDataEvent>(_onGetGameDetailsWithUserData);
    on<GetCompleteGameDetailsEvent>(_onGetCompleteGameDetails);

    // Home page events
    on<LoadPopularGamesEvent>(_onLoadPopularGames);
    on<LoadUpcomingGamesEvent>(_onLoadUpcomingGames);
    on<LoadTopRatedGamesEvent>(_onLoadTopRatedGames);

    // User-specific events
    on<LoadUserWishlistEvent>(_onLoadUserWishlist);
    on<LoadUserRecommendationsEvent>(_onLoadUserRecommendations);
    on<LoadUserRatedEvent>(_onLoadUserRated);

    on<LoadHomePageDataEvent>(_onLoadHomePageData);
    on<LoadGrovePageDataEvent>(_onLoadGrovePageData);

    on<GetSimilarGamesEvent>(_onGetSimilarGames);
    on<GetGameDLCsEvent>(_onGetGameDLCs);
    on<GetGameExpansionsEvent>(_onGetGameExpansions);
    on<LoadCompleteFranchiseGamesEvent>(_onLoadCompleteFranchiseGames);
    on<LoadCompleteCollectionGamesEvent>(_onLoadCompleteCollectionGames);

    on<SearchGamesWithFiltersEvent>(_onSearchGamesWithFilters);
    on<SaveSearchQueryEvent>(_onSaveSearchQuery);
    on<RefreshCacheEvent>(_onRefreshCache);
  }

  // Debounce transformer for search
  EventTransformer<T> debounce<T>(Duration duration) {
    return (events, mapper) => events.debounceTime(duration).switchMap(mapper);
  }

  // 🎯 CACHE MANAGEMENT METHODS

  /// Updates a game in the cache
  void _updateGameCache(int gameId, Game updatedGame) {
    _gameCache[gameId] = updatedGame;
    print('📦 Game $gameId cached: ${updatedGame.name}');
  }

  /// Updates multiple games in the cache
  void _updateGamesCacheList(List<Game> games) {
    for (final game in games) {
      _gameCache[game.id] = game;
    }
    print('📦 Cached ${games.length} games');
  }

  /// Applies cached updates to a list of games
  List<Game> _applyCache(List<Game> games) {
    return games.map((game) {
      // If we have a cached version, use it; otherwise use original
      return _gameCache[game.id] ?? game;
    }).toList();
  }

  /// Updates a specific game in the cache with a transformation function
  void _updateGameInCache(int gameId, Game Function(Game) updateFn) {
    final cachedGame = _gameCache[gameId];
    if (cachedGame != null) {
      _gameCache[gameId] = updateFn(cachedGame);
      print('📦 Updated game $gameId in cache');
    }
  }

  /// Applies cache to a state before emitting it
  GameState _applyCacheToState(GameState state) {
    if (state is HomePageLoaded) {
      return state.copyWith(
        popularGames: _applyCache(state.popularGames),
        upcomingGames: _applyCache(state.upcomingGames),
        latestGames: _applyCache(state.latestGames),
        topRatedGames: _applyCache(state.topRatedGames),
        userWishlist: state.userWishlist != null
            ? _applyCache(state.userWishlist!)
            : null,
        userRecommendations: state.userRecommendations != null
            ? _applyCache(state.userRecommendations!)
            : null,
      );
    } else if (state is GrovePageLoaded) {
      return state.copyWith(
        userRated: _applyCache(state.userRated),
        userWishlist: _applyCache(state.userWishlist),
        userRecommendations: _applyCache(state.userRecommendations),
        userTopThree: _applyCache(state.userTopThree),
      );
    } else if (state is GameSearchLoaded) {
      return state.copyWith(games: _applyCache(state.games));
    } else if (state is PopularGamesLoaded) {
      return state.copyWith(games: _applyCache(state.games));
    } else if (state is UpcomingGamesLoaded) {
      return state.copyWith(games: _applyCache(state.games));
    } else if (state is LatestGamesLoaded) {
      return state.copyWith(games: _applyCache(state.games));
    } else if (state is TopRatedGamesLoaded) {
      return state.copyWith(games: _applyCache(state.games));
    } else if (state is UserWishlistLoaded) {
      return state.copyWith(games: _applyCache(state.games));
    } else if (state is UserRecommendationsLoaded) {
      return state.copyWith(games: _applyCache(state.games));
    } else if (state is UserRatedLoaded) {
      return state.copyWith(games: _applyCache(state.games));
    } else if (state is SimilarGamesLoaded) {
      return state.copyWith(games: _applyCache(state.games));
    } else if (state is CompleteFranchiseGamesLoaded) {
      return state.copyWith(games: _applyCache(state.games));
    } else if (state is CompleteCollectionGamesLoaded) {
      return state.copyWith(games: _applyCache(state.games));
    } else if (state is GameDetailsLoaded) {
      final cachedGame = _gameCache[state.game.id];
      return cachedGame != null ? GameDetailsLoaded(cachedGame) : state;
    }

    return state; // Return unchanged for other states
  }

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
        limit: 20,
        offset: 0,
      ),
    );

    result.fold(
      (failure) => emit(GameError(failure.message)),
      (games) async {
        // Enrich games with user data if userId is provided
        final enrichedGames = event.userId != null
            ? await enrichGamesWithUserData(games, event.userId!)
            : games;

        emit(GameSearchLoaded(
          games: enrichedGames,
          hasReachedMax: games.length < 20,
          currentQuery: event.query,
        ));
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
              limit: 20,
              offset: currentState.games.length,
            )
          : await searchGames(
              SearchGamesParams(
                query: currentState.currentQuery,
                limit: 20,
                offset: currentState.games.length,
              ),
            );

      result.fold(
        (failure) => emit(GameError(failure.message)),
        (games) {
          if (games.isEmpty) {
            emit(currentState.copyWith(
              hasReachedMax: true,
              isLoadingMore: false,
            ));
          } else {
            emit(currentState.copyWith(
              games: List.of(currentState.games)..addAll(games),
              hasReachedMax: games.length < 20,
              isLoadingMore: false,
            ));
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
          emit(PopularGamesLoaded(
            games: games,
            hasReachedMax: games.length < event.limit,
          ));
        } else if (state is PopularGamesLoaded) {
          // Load more
          final currentState = state as PopularGamesLoaded;
          emit(currentState.copyWith(
            games: List.of(currentState.games)..addAll(games),
            hasReachedMax: games.length < event.limit,
            isLoadingMore: false,
          ));
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
          emit(UpcomingGamesLoaded(
            games: games,
            hasReachedMax: games.length < event.limit,
          ));
        } else if (state is UpcomingGamesLoaded) {
          final currentState = state as UpcomingGamesLoaded;
          emit(currentState.copyWith(
            games: List.of(currentState.games)..addAll(games),
            hasReachedMax: games.length < event.limit,
            isLoadingMore: false,
          ));
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
          emit(TopRatedGamesLoaded(
            games: games,
            hasReachedMax: games.length < event.limit,
          ));
        } else if (state is TopRatedGamesLoaded) {
          // Load more
          final currentState = state as TopRatedGamesLoaded;
          emit(currentState.copyWith(
            games: List.of(currentState.games)..addAll(games),
            hasReachedMax: games.length < event.limit,
            isLoadingMore: false,
          ));
        }
      },
    );
  }

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
      (games) => emit(UserWishlistLoaded(
        games: games,
        userId: event.userId,
      )),
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
      (games) => emit(UserRecommendationsLoaded(
        games: games,
        userId: event.userId,
      )),
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
      (games) => emit(UserRatedLoaded(
        games: games,
        userId: event.userId,
      )),
    );
  }

  Future<void> _onGetGameDetailsWithUserData(
    GetGameDetailsWithUserDataEvent event,
    Emitter<GameState> emit,
  ) async {
    emit(GameDetailsLoading());

    try {
      // First get the game details
      final gameResult = await getGameDetails(
        GameDetailsParams(gameId: event.gameId),
      );

      await gameResult.fold(
        (failure) async {
          if (!emit.isDone) {
            emit(GameError(failure.message));
          }
        },
        (game) async {
          if (event.userId != null) {
            try {
              // Use the new enrichment service - much simpler!
              final enrichedGames = await enrichmentService.enrichGames(
                [game],
                event.userId!,
              );

              if (!emit.isDone) {
                emit(GameDetailsLoaded(enrichedGames.first));
              }
            } catch (e) {
              // If user data fails, still show game without user data
              print('❌ Failed to load user data: $e');
              if (!emit.isDone) {
                emit(GameDetailsLoaded(game));
              }
            }
          } else {
            // No user logged in, show game without user data
            if (!emit.isDone) {
              emit(GameDetailsLoaded(game));
            }
          }
        },
      );
    } catch (e) {
      if (!emit.isDone) {
        emit(GameError('Failed to load game details: $e'));
      }
    }
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
            final updatedGame = currentGame.copyWith(isWishlisted: !currentGame.isWishlisted);
            _updateGameCache(event.gameId, updatedGame); // Cache the updated game
            emit(GameDetailsLoaded(updatedGame));
          }
        }

        // Auch andere States updaten
        _updateGameInAllStates(event.gameId, (game) {
          return game.copyWith(isWishlisted: !game.isWishlisted);
        }, emit);
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
            final updatedGame = currentGame.copyWith(isRecommended: !currentGame.isRecommended);
            _updateGameCache(event.gameId, updatedGame);
            emit(GameDetailsLoaded(updatedGame));
          }
        }

        // Auch andere States updaten
        _updateGameInAllStates(event.gameId, (game) {
          return game.copyWith(isRecommended: !game.isRecommended);
        }, emit);
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
        _updateGameInHomePageState(event.gameId, (game) {
          return game.copyWith(userRating: event.rating);
        }, emit);

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

// ✅ COMPREHENSIVE Helper method to update a game in ALL possible states
  void _updateGameInAllStates(
      int gameId, Game Function(Game) updateFunction, Emitter<GameState> emit) {
    final currentState = state;

    // 1. PopularGamesLoaded
    if (currentState is PopularGamesLoaded) {
      final updatedGames = currentState.games.map((game) {
        return game.id == gameId ? updateFunction(game) : game;
      }).toList();
      emit(currentState.copyWith(games: updatedGames));
    }

    // 2. UpcomingGamesLoaded
    else if (currentState is UpcomingGamesLoaded) {
      final updatedGames = currentState.games.map((game) {
        return game.id == gameId ? updateFunction(game) : game;
      }).toList();
      emit(currentState.copyWith(games: updatedGames));
    }

    // 3. LatestGamesLoaded
    else if (currentState is LatestGamesLoaded) {
      final updatedGames = currentState.games.map((game) {
        return game.id == gameId ? updateFunction(game) : game;
      }).toList();
      emit(currentState.copyWith(games: updatedGames));
    }

    // 4. TopRatedGamesLoaded
    else if (currentState is TopRatedGamesLoaded) {
      final updatedGames = currentState.games.map((game) {
        return game.id == gameId ? updateFunction(game) : game;
      }).toList();
      emit(currentState.copyWith(games: updatedGames));
    }

    // 5. HomePageLoaded - Update ALL game lists within
    else if (currentState is HomePageLoaded) {
      final updatedPopular = currentState.popularGames.map((game) {
        return game.id == gameId ? updateFunction(game) : game;
      }).toList();

      final updatedUpcoming = currentState.upcomingGames.map((game) {
        return game.id == gameId ? updateFunction(game) : game;
      }).toList();

      final updatedLatest = currentState.latestGames.map((game) {
        return game.id == gameId ? updateFunction(game) : game;
      }).toList();

      final updatedTopRated = currentState.topRatedGames.map((game) {
        return game.id == gameId ? updateFunction(game) : game;
      }).toList();

      final updatedWishlist = currentState.userWishlist?.map((game) {
        return game.id == gameId ? updateFunction(game) : game;
      }).toList();

      final updatedRecommendations = currentState.userRecommendations?.map((game) {
        return game.id == gameId ? updateFunction(game) : game;
      }).toList();

      emit(currentState.copyWith(
        popularGames: updatedPopular,
        upcomingGames: updatedUpcoming,
        latestGames: updatedLatest,
        topRatedGames: updatedTopRated,
        userWishlist: updatedWishlist,
        userRecommendations: updatedRecommendations,
      ));
    }

    // 6. GrovePageLoaded - Update ALL user collections
    else if (currentState is GrovePageLoaded) {
      final updatedRated = currentState.userRated.map((game) {
        return game.id == gameId ? updateFunction(game) : game;
      }).toList();

      final updatedWishlist = currentState.userWishlist.map((game) {
        return game.id == gameId ? updateFunction(game) : game;
      }).toList();

      final updatedRecommendations = currentState.userRecommendations.map((game) {
        return game.id == gameId ? updateFunction(game) : game;
      }).toList();

      final updatedTopThree = currentState.userTopThree.map((game) {
        return game.id == gameId ? updateFunction(game) : game;
      }).toList();

      emit(currentState.copyWith(
        userRated: updatedRated,
        userWishlist: updatedWishlist,
        userRecommendations: updatedRecommendations,
        userTopThree: updatedTopThree,
      ));
    }

    // 7. GameSearchLoaded
    else if (currentState is GameSearchLoaded) {
      final updatedGames = currentState.games.map((game) {
        return game.id == gameId ? updateFunction(game) : game;
      }).toList();
      emit(currentState.copyWith(games: updatedGames));
    }

    // 8. UserWishlistLoaded
    else if (currentState is UserWishlistLoaded) {
      final updatedGames = currentState.games.map((game) {
        return game.id == gameId ? updateFunction(game) : game;
      }).toList();
      emit(currentState.copyWith(games: updatedGames));
    }

    // 9. UserRecommendationsLoaded
    else if (currentState is UserRecommendationsLoaded) {
      final updatedGames = currentState.games.map((game) {
        return game.id == gameId ? updateFunction(game) : game;
      }).toList();
      emit(currentState.copyWith(games: updatedGames));
    }

    // 10. UserRatedLoaded
    else if (currentState is UserRatedLoaded) {
      final updatedGames = currentState.games.map((game) {
        return game.id == gameId ? updateFunction(game) : game;
      }).toList();
      emit(currentState.copyWith(games: updatedGames));
    }

    // 11. SimilarGamesLoaded
    else if (currentState is SimilarGamesLoaded) {
      final updatedGames = currentState.games.map((game) {
        return game.id == gameId ? updateFunction(game) : game;
      }).toList();
      emit(currentState.copyWith(games: updatedGames));
    }

    // 12. CompleteFranchiseGamesLoaded
    else if (currentState is CompleteFranchiseGamesLoaded) {
      final updatedGames = currentState.games.map((game) {
        return game.id == gameId ? updateFunction(game) : game;
      }).toList();
      emit(currentState.copyWith(games: updatedGames));
    }

    // 13. CompleteCollectionGamesLoaded
    else if (currentState is CompleteCollectionGamesLoaded) {
      final updatedGames = currentState.games.map((game) {
        return game.id == gameId ? updateFunction(game) : game;
      }).toList();
      emit(currentState.copyWith(games: updatedGames));
    }

    // 14. GameDetailsLoaded - Update the single game if it matches
    else if (currentState is GameDetailsLoaded) {
      if (currentState.game.id == gameId) {
        emit(GameDetailsLoaded(updateFunction(currentState.game)));
      }
    }

    print('✅ Game $gameId updated in state: ${currentState.runtimeType}');
  }

// Fix for _onGetGameDetails
  Future<void> _onGetGameDetails(
    GetGameDetailsEvent event,
    Emitter<GameState> emit,
  ) async {
    emit(GameDetailsLoading());

    final result = await getGameDetails(
      GameDetailsParams(gameId: event.gameId),
    );

    if (!emit.isDone) {
      result.fold(
        (failure) => emit(GameError(failure.message)),
        (game) => emit(GameDetailsLoaded(game)),
      );
    }
  }

  // Home Page Data Loading

  Future<void> _onLoadHomePageData(
    LoadHomePageDataEvent event,
    Emitter<GameState> emit,
  ) async {
    print('🏠 GameBloc: Loading home page data (userId: ${event.userId})');
    emit(HomePageLoading());

    try {
      print('🏠 GameBloc: Starting parallel data fetch...');
      // Load all data in parallel
      final results = await Future.wait([
        getPopularGames(const GetPopularGamesParams(limit: 10)),
        getUpcomingGames(const GetUpcomingGamesParams(limit: 10)),
        getLatestGames(const GetLatestGamesParams(limit: 10)),
        getTopRatedGames(const GetTopRatedGamesParams(limit: 10)),
        getUpcomingEvents(const GetUpcomingEventsParams(limit: 10)),
      ]);

      print('🏠 GameBloc: Parallel data fetch complete! Processing results...');

      // Extract results
      final popularGames = results[0].fold<List<Game>>(
        (l) {
          print('❌ GameBloc: Popular games failed: ${l.message}');
          return <Game>[];
        },
        (r) {
          print('✅ GameBloc: Popular games: ${r.length} games');
          return r as List<Game>;
        },
      );
      final upcomingGames = results[1].fold<List<Game>>(
        (l) {
          print('❌ GameBloc: Upcoming games failed: ${l.message}');
          return <Game>[];
        },
        (r) {
          print('✅ GameBloc: Upcoming games: ${r.length} games');
          return r as List<Game>;
        },
      );
      final latestGames = results[2].fold<List<Game>>(
        (l) {
          print('❌ GameBloc: Latest games failed: ${l.message}');
          return <Game>[];
        },
        (r) {
          print('✅ GameBloc: Latest games: ${r.length} games');
          return r as List<Game>;
        },
      );
      final topRatedGames = results[3].fold<List<Game>>(
        (l) {
          print('❌ GameBloc: Top rated games failed: ${l.message}');
          return <Game>[];
        },
        (r) {
          print('✅ GameBloc: Top rated games: ${r.length} games');
          return r as List<Game>;
        },
      );
      final upcomingEvents = results[4].fold<List<Event>>(
        (l) {
          print('❌ GameBloc: Upcoming events failed: ${l.message}');
          return <Event>[];
        },
        (r) {
          print('✅ GameBloc: Upcoming events: ${r.length} events');
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
        final List<Game> enrichedPopular =
            await enrichGamesWithUserData(popularGames, event.userId!);
        final List<Game> enrichedUpcoming =
            await enrichGamesWithUserData(upcomingGames, event.userId!);
        final List<Game> enrichLatest =
            await enrichGamesWithUserData(latestGames, event.userId!);
        final List<Game> enrichedTopRated =
            await enrichGamesWithUserData(topRatedGames, event.userId!);
        // ✅ NEU: Auch Wishlist und Recommendations anreichern (für Top 3, etc.)
        final List<Game> enrichedWishlist = userWishlist.isNotEmpty
            ? await enrichGamesWithUserData(userWishlist, event.userId!)
            : <Game>[];
        final List<Game> enrichedRecommendations = userRecommendations
                .isNotEmpty
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
        emit(HomePageLoaded(
          popularGames: _applyCache(enrichedPopular),
          upcomingGames: _applyCache(enrichedUpcoming),
          latestGames: _applyCache(enrichLatest),
          topRatedGames: _applyCache(enrichedTopRated),
          userWishlist: _applyCache(enrichedWishlist),
          userRecommendations: _applyCache(enrichedRecommendations),
          upcomingEvents: upcomingEvents,
        ));
      } else {
        // 🎯 CACHE GAMES even without user data
        _updateGamesCacheList(popularGames);
        _updateGamesCacheList(upcomingGames);
        _updateGamesCacheList(latestGames);
        _updateGamesCacheList(topRatedGames);

        emit(HomePageLoaded(
          popularGames: _applyCache(popularGames),
          upcomingGames: _applyCache(upcomingGames),
          latestGames: _applyCache(latestGames),
          topRatedGames: _applyCache(topRatedGames),
          upcomingEvents: upcomingEvents,
        ));
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
        emit(const GrovePageLoaded(
          userRated: <Game>[],
          userWishlist: <Game>[],
          userRecommendations: <Game>[],
          userTopThree: <Game>[],
        ));
        return;
      }

      // Alle Daten parallel laden
      final results = await Future.wait([
        getUserRated(
            GetUserRatedParams(userId: event.userId!, limit: 20, offset: 0)),
        getUserWishlist(
            GetUserWishlistParams(userId: event.userId!, limit: 20, offset: 0)),
        getUserRecommendations(GetUserRecommendationsParams(
            userId: event.userId!, limit: 20, offset: 0)),
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
      emit(GrovePageLoaded(
        userRated: _applyCache(enrichedRated),
        userWishlist: _applyCache(enrichedWishlist),
        userRecommendations: _applyCache(enrichedRecommendations),
        userTopThree: _applyCache(enrichedTopThree),
      ));
    } catch (e) {
      print('❌ Failed to load grove page data: $e');
      emit(GameError('Failed to load grove page data: $e'));
    }
  }

  Future<List<Game>> enrichGamesWithUserData(
    List<Game> games,
    String userId, {
    int? enrichLimit,
  }) async {
    print(
        '🎮 enrichGamesWithUserData: Enriching ${games.length} games for user $userId');
    final enrichedGames = await enrichmentService.enrichGames(games, userId);
    print('🎮 enrichGamesWithUserData: Enriched ${enrichedGames.length} games');
    // Debug: print first game enrichment status
    if (enrichedGames.isNotEmpty) {
      final firstGame = enrichedGames.first;
      print('🎮 First game: ${firstGame.name}');
      print('  - isWishlisted: ${firstGame.isWishlisted}');
      print('  - isRecommended: ${firstGame.isRecommended}');
      print('  - userRating: ${firstGame.userRating}');
      print('  - isInTopThree: ${firstGame.isInTopThree}');
    }
    return enrichedGames;
  }

  // ✅ UPDATED: Now includes latestGames and topRatedGames
  void _updateGameInHomePageState(
      int gameId, Game Function(Game) updateFunction, Emitter<GameState> emit) {
    final currentState = state;

    if (currentState is HomePageLoaded) {
      // Update in allen Listen
      final updatedPopular = currentState.popularGames.map((game) {
        return game.id == gameId ? updateFunction(game) : game;
      }).toList();

      final updatedUpcoming = currentState.upcomingGames.map((game) {
        return game.id == gameId ? updateFunction(game) : game;
      }).toList();

      final updatedLatest = currentState.latestGames.map((game) {
        return game.id == gameId ? updateFunction(game) : game;
      }).toList();

      final updatedTopRated = currentState.topRatedGames.map((game) {
        return game.id == gameId ? updateFunction(game) : game;
      }).toList();

      final updatedWishlist = currentState.userWishlist?.map((game) {
        return game.id == gameId ? updateFunction(game) : game;
      }).toList();

      final updatedRecommendations =
          currentState.userRecommendations?.map((game) {
        return game.id == gameId ? updateFunction(game) : game;
      }).toList();

      emit(currentState.copyWith(
        popularGames: updatedPopular,
        upcomingGames: updatedUpcoming,
        latestGames: updatedLatest,
        topRatedGames: updatedTopRated,
        userWishlist: updatedWishlist,
        userRecommendations: updatedRecommendations,
      ));
    }
  }

  Future<void> _onGetCompleteGameDetails(
    GetCompleteGameDetailsEvent event,
    Emitter<GameState> emit,
  ) async {
    if (emit.isDone) return;

    emit(GameDetailsLoading());

    try {
      print(
          '🎮 GameBloc: Loading ENHANCED game details with characters & events...');
      print('📋 GameBloc: gameId = ${event.gameId}, userId = ${event.userId}');

      // 🆕 Use GetEnhancedGameDetails instead of GetCompleteGameDetails
      final result = await getEnhancedGameDetails(
        GetEnhancedGameDetailsParams.fullDetails(
          gameId: event.gameId,
          userId: event.userId,
        ),
      );

      await result.fold(
        (failure) async {
          if (!emit.isDone) {
            print(
                '❌ GameBloc: Failed to load enhanced game details: ${failure.message}');
            emit(GameError(_mapFailureToMessage(failure)));
          }
        },
        (game) async {
          print('✅ GameBloc: Enhanced game details loaded successfully!');
          print('📊 GameBloc: Characters: ${game.characters.length}');
          print('📊 GameBloc: Events: ${game.events.length}');

          // Add user data enrichment if userId provided
          if (event.userId != null && !emit.isDone) {
            try {
              print('🔄 GameBloc: Enriching with user data...');
              final enrichedMainGames =
                  await enrichGamesWithUserData([game], event.userId!);
              Game enrichedGame = enrichedMainGames[0];

              enrichedGame = await _enrichGameWithAllNestedUserData(
                  enrichedGame, event.userId!);

              if (!emit.isDone) {
                emit(GameDetailsLoaded(enrichedGame));
              }
            } catch (e) {
              print('❌ GameBloc: Failed to enrich with user data: $e');
              if (!emit.isDone) {
                emit(GameDetailsLoaded(game)); // Fallback without user data
              }
            }
          } else if (!emit.isDone) {
            emit(GameDetailsLoaded(game));
          }
        },
      );
    } catch (e) {
      print('❌ GameBloc: Exception in _onGetCompleteGameDetails: $e');
      if (!emit.isDone) {
        emit(GameError('Failed to load game details: $e'));
      }
    }
  }

  /*Future<void> _onGetCompleteGameDetails(
    GetCompleteGameDetailsEvent event,
    Emitter<GameState> emit,
  ) async {
    if (emit.isDone) return; // ✅ Safety check

    emit(GameDetailsLoading());

    try {
      // ✅ Game ohne User-Daten laden (Repository sollte userId = null setzen)
      final result = await getCompleteGameDetails(
        GetCompleteGameDetailsParams(
          gameId: event.gameId,
          userId: null, // ✅ Keine User-Daten im Repository
        ),
      );

      await result.fold(
        (failure) async {
          if (!emit.isDone) {
            emit(GameError(_mapFailureToMessage(failure)));
          }
        },
        (game) async {
          // ✅ User-Daten im BLoC hinzufügen (wie bei Home/Grove)
          if (event.userId != null && !emit.isDone) {
            try {
              // 🔧 FIX 1: Main game enrichen
              print('🔄 Enriching main game...');
              final enrichedMainGames =
                  await _enrichGamesWithUserData([game], event.userId!);
              Game enrichedGame = enrichedMainGames[0];

              // 🔧 FIX 2: DANN nested games enrichen (mit dem enriched main game!)
              print('🔄 Enriching nested games...');
              enrichedGame = await _enrichGameWithAllNestedUserData(
                  enrichedGame, event.userId!);

              if (!emit.isDone) {
                // 🔧 FIX 3: Das final enriched game emiten
                emit(GameDetailsLoaded(enrichedGame));
              }
            } catch (e) {
              print('❌ Failed to enrich game with user data: $e');
              if (!emit.isDone) {
                emit(GameDetailsLoaded(game)); // ✅ Fallback ohne User-Daten
              }
            }
          } else if (!emit.isDone) {
            emit(GameDetailsLoaded(game));
          }
        },
      );
    } catch (e) {
      if (!emit.isDone) {
        emit(GameError('Failed to load game details: $e'));
      }
    }
  }
   */

// 🆕 UPDATED: Limits für Franchise/Collection
  Future<Game> _enrichGameWithAllNestedUserData(
      Game game, String userId) async {
    try {
      // ⚡ PERFORMANCE LIMITS für große Listen
      const int franchiseLimit = 10; // Nur erste 10 Franchise Games enrichen
      const int collectionLimit = 10; // Nur erste 10 Collection Games enrichen

      // 1-7. Normale Listen (wie vorher, ohne Limit)
      List<Game> enrichedSimilarGames = game.similarGames;
      if (game.similarGames.isNotEmpty) {
        enrichedSimilarGames =
            await enrichGamesWithUserData(game.similarGames, userId);
      }

      List<Game> enrichedDLCs = game.dlcs;
      if (game.dlcs.isNotEmpty) {
        enrichedDLCs = await enrichGamesWithUserData(game.dlcs, userId);
      }

      List<Game> enrichedExpansions = game.expansions;
      if (game.expansions.isNotEmpty) {
        enrichedExpansions =
            await enrichGamesWithUserData(game.expansions, userId);
      }

      List<Game> enrichedStandaloneExpansions = game.standaloneExpansions;
      if (game.standaloneExpansions.isNotEmpty) {
        enrichedStandaloneExpansions =
            await enrichGamesWithUserData(game.standaloneExpansions, userId);
      }

      List<Game> enrichedBundles = game.bundles;
      if (game.bundles.isNotEmpty) {
        enrichedBundles = await enrichGamesWithUserData(game.bundles, userId);
      }

      List<Game> enrichedRemakes = game.remakes;
      if (game.remakes.isNotEmpty) {
        enrichedRemakes = await enrichGamesWithUserData(game.remakes, userId);
      }

      List<Game> enrichedRemasters = game.remasters;
      if (game.remasters.isNotEmpty) {
        enrichedRemasters =
            await enrichGamesWithUserData(game.remasters, userId);
      }

      List<Game> enrichedPorts = game.ports;
      if (game.ports.isNotEmpty) {
        enrichedPorts = await enrichGamesWithUserData(game.ports, userId);
      }

      List<Game> enrichedExpandedGames = game.expandedGames;
      if (game.expandedGames.isNotEmpty) {
        enrichedExpandedGames =
            await enrichGamesWithUserData(game.expandedGames, userId);
      }

      List<Game> enrichedVersionParent =
          game.versionParent != null ? [game.versionParent!] : [];
      if (game.versionParent != null) {
        enrichedVersionParent = await enrichGamesWithUserData(
            game.versionParent != null ? [game.versionParent!] : [], userId);
      }

      List<Game> enrichedForks = game.forks;
      if (game.forks.isNotEmpty) {
        enrichedForks = await enrichGamesWithUserData(game.forks, userId);
      }

      List<Game> enrichedParentGames =
          game.parentGame != null ? [game.parentGame!] : [];
      if (game.versionParent != null) {
        enrichedParentGames = await enrichGamesWithUserData(
            game.parentGame != null ? [game.parentGame!] : [], userId);
      }

      // 8. 🌟 MAIN FRANCHISE (🆕 MIT LIMIT!)
      Franchise? enrichedMainFranchise = game.mainFranchise;
      if (game.mainFranchise?.games != null &&
          game.mainFranchise!.games!.isNotEmpty) {
        print('🔄 Enriching main franchise games (limit: $franchiseLimit)...');
        final enrichedFranchiseGames = await enrichGamesWithUserData(
            game.mainFranchise!.games!, userId,
            enrichLimit: franchiseLimit // 🎯 NUR ERSTE 10!
            );

        enrichedMainFranchise = Franchise(
          id: game.mainFranchise!.id,
          checksum: game.mainFranchise!.checksum,
          name: game.mainFranchise!.name,
          slug: game.mainFranchise!.slug,
          url: game.mainFranchise!.url,
          gameIds: game.mainFranchise!.gameIds,
          createdAt: game.mainFranchise!.createdAt,
          updatedAt: game.mainFranchise!.updatedAt,
          games: enrichedFranchiseGames,
        );
      }

      // 9. 🌳 OTHER FRANCHISES (🆕 MIT LIMIT!)
      List<Franchise> enrichedFranchises = game.franchises;
      if (game.franchises.isNotEmpty) {
        print('🔄 Enriching other franchise games (limit: $franchiseLimit)...');
        enrichedFranchises = [];

        for (final franchise in game.franchises) {
          if (franchise.games != null && franchise.games!.isNotEmpty) {
            final enrichedGames = await enrichGamesWithUserData(
                franchise.games!, userId,
                enrichLimit: franchiseLimit // 🎯 NUR ERSTE 10!
                );

            enrichedFranchises.add(Franchise(
              id: franchise.id,
              checksum: franchise.checksum,
              name: franchise.name,
              slug: franchise.slug,
              url: franchise.url,
              gameIds: franchise.gameIds,
              createdAt: franchise.createdAt,
              updatedAt: franchise.updatedAt,
              games: enrichedGames,
            ));
          } else {
            enrichedFranchises.add(franchise);
          }
        }
      }

      // 10. 📚 COLLECTIONS (🆕 MIT LIMIT!)
      List<Collection> enrichedCollections = game.collections;
      if (game.collections.isNotEmpty) {
        print('🔄 Enriching collection games (limit: $collectionLimit)...');
        enrichedCollections = [];

        for (final collection in game.collections) {
          if (collection.games != null && collection.games!.isNotEmpty) {
            final enrichedGames = await enrichGamesWithUserData(
                collection.games!, userId,
                enrichLimit: collectionLimit // 🎯 NUR ERSTE 10!
                );

            enrichedCollections.add(Collection(
              id: collection.id,
              checksum: collection.checksum,
              name: collection.name,
              slug: collection.slug,
              url: collection.url,
              asChildRelationIds: collection.asChildRelationIds,
              asParentRelationIds: collection.asParentRelationIds,
              gameIds: collection.gameIds,
              typeId: collection.typeId,
              createdAt: collection.createdAt,
              updatedAt: collection.updatedAt,
              games: enrichedGames,
            ));
          } else {
            enrichedCollections.add(collection);
          }
        }
      }

      // Rest wie vorher...
      final enrichedGame = game.copyWith(
          similarGames: enrichedSimilarGames,
          dlcs: enrichedDLCs,
          expansions: enrichedExpansions,
          standaloneExpansions: enrichedStandaloneExpansions,
          bundles: enrichedBundles,
          remakes: enrichedRemakes,
          remasters: enrichedRemasters,
          mainFranchise: enrichedMainFranchise,
          franchises: enrichedFranchises,
          collections: enrichedCollections,
          ports: enrichedPorts,
          expandedGames: enrichedExpandedGames,
          versionParent: enrichedVersionParent.isNotEmpty
              ? enrichedVersionParent[0]
              : null,
          forks: enrichedForks,
          parentGame:
              enrichedParentGames.isNotEmpty ? enrichedParentGames[0] : null);

      print(
          '✅ Successfully enriched nested games with limits (franchise: $franchiseLimit, collection: $collectionLimit)');
      return enrichedGame;
    } catch (e) {
      print('❌ Error enriching nested games: $e');
      return game;
    }
  }

  Future<void> _onGetSimilarGames(
    GetSimilarGamesEvent event,
    Emitter<GameState> emit,
  ) async {
    final result = await getSimilarGames(event.gameId);

    result.fold(
      (failure) => emit(GameError(_mapFailureToMessage(failure))),
      (games) => emit(SimilarGamesLoaded(games)),
    );
  }

  Future<void> _onGetGameDLCs(
    GetGameDLCsEvent event,
    Emitter<GameState> emit,
  ) async {
    final result = await getGameDLCs(event.gameId);

    result.fold(
      (failure) => emit(GameError(_mapFailureToMessage(failure))),
      (dlcs) => emit(GameDLCsLoaded(dlcs)),
    );
  }

  Future<void> _onGetGameExpansions(
    GetGameExpansionsEvent event,
    Emitter<GameState> emit,
  ) async {
    final result = await getGameExpansions(event.gameId);

    result.fold(
      (failure) => emit(GameError(_mapFailureToMessage(failure))),
      (expansions) => emit(GameExpansionsLoaded(expansions)),
    );
  }

  Future<void> _onAddToTopThree(
    AddToTopThreeEvent event,
    Emitter<GameState> emit,
  ) async {
    print('🎮 GameBloc: _onAddToTopThree called');
    print('   User ID: ${event.userId}');
    print('   Game ID: ${event.gameId}');
    print('   Position: ${event.position}');

    final result = await addToTopThree(AddToTopThreeParams(
      userId: event.userId,
      gameId: event.gameId,
      position: event.position,
    ));

    result.fold(
      (failure) {
        print('❌ GameBloc: Failed to add to top three: ${failure.message}');
        if (!emit.isDone) {
          emit(GameError(_mapFailureToMessage(failure)));
        }
      },
      (_) {
        print('✅ GameBloc: Successfully added to top three');

        // 🎯 UPDATE CACHE FIRST
        _updateGameInCache(event.gameId, (game) {
          return game.copyWith(
            isInTopThree: true,
            topThreePosition: event.position,
          );
        });

        add(UpdateTopThreeEvent(userId: event.userId));

        _updateGameInAllStates(event.gameId, (game) {
          return game.copyWith(
            isInTopThree: true,
            topThreePosition: event.position,
          );
        }, emit);
      },
    );
  }

  Future<void> _onRemoveFromTopThree(
    RemoveFromTopThreeEvent event,
    Emitter<GameState> emit,
  ) async {
    print('🎮 GameBloc: _onRemoveFromTopThree called');
    print('   User ID: ${event.userId}');
    print('   Game ID: ${event.gameId}');

    final result = await removeFromTopThree(RemoveFromTopThreeParams(
      userId: event.userId,
      gameId: event.gameId,
    ));

    result.fold(
      (failure) {
        print('❌ GameBloc: Failed to remove from top three: ${failure.message}');
        if (!emit.isDone) {
          emit(GameError(_mapFailureToMessage(failure)));
        }
      },
      (_) {
        print('✅ GameBloc: Successfully removed from top three');

        // 🎯 UPDATE CACHE FIRST
        _updateGameInCache(event.gameId, (game) {
          return game.copyWith(
            isInTopThree: false,
            topThreePosition: null,
          );
        });

        add(UpdateTopThreeEvent(userId: event.userId));

        _updateGameInAllStates(event.gameId, (game) {
          return game.copyWith(
            isInTopThree: false,
            topThreePosition: null,
          );
        }, emit);
      },
    );
  }

  Future<void> _onUpdateTopThree(
    UpdateTopThreeEvent event,
    Emitter<GameState> emit,
  ) async {
    final currentState = state;
    if (currentState is GrovePageLoaded) {
      final result =
          await getUserTopThree(GetUserTopThreeParams(userId: event.userId));

      result.fold(
        (failure) => emit(GameError(_mapFailureToMessage(failure))),
        (games) {
          emit(currentState.copyWith(userTopThree: games));
        },
      );
    }
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return 'Server error occurred';
      case NetworkFailure:
        return 'Network error occurred';
      case CacheFailure:
        return 'Cache error occurred';
      default:
        return 'An unexpected error occurred';
    }
  }

  /// Handler for complete franchise games - enriches existing games
  Future<void> _onLoadCompleteFranchiseGames(
    LoadCompleteFranchiseGamesEvent event,
    Emitter<GameState> emit,
  ) async {
    emit(GameDetailsLoading());

    try {
      print(
          '🔄 Enriching ${event.games.length} franchise games with user data...');

      // ✅ Einfach die übergebenen Games enrichen, keine Repository-Calls!
      final enrichedGames = event.userId != null
          ? await enrichGamesWithUserData(event.games, event.userId!)
          : event.games;

      emit(CompleteFranchiseGamesLoaded(
        franchiseId: event.franchiseId,
        franchiseName: event.franchiseName,
        games: enrichedGames,
      ));
    } catch (e) {
      emit(GameError('Failed to enrich franchise games: $e'));
    }
  }

  /// Handler for complete collection games - enriches existing games
  Future<void> _onLoadCompleteCollectionGames(
    LoadCompleteCollectionGamesEvent event,
    Emitter<GameState> emit,
  ) async {
    emit(GameDetailsLoading());

    try {
      print(
          '🔄 Enriching ${event.games.length} collection games with user data...');

      // ✅ Einfach die übergebenen Games enrichen, keine Repository-Calls!
      final enrichedGames = event.userId != null
          ? await enrichGamesWithUserData(event.games, event.userId!)
          : event.games;

      emit(CompleteCollectionGamesLoaded(
        collectionId: event.collectionId,
        collectionName: event.collectionName,
        games: enrichedGames,
      ));
    } catch (e) {
      emit(GameError('Failed to enrich collection games: $e'));
    }
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
      limit: 20,
      offset: 0,
    );

    result.fold(
      (failure) => emit(GameSearchError(message: failure.message)),
      (games) => emit(GameSearchLoaded(
        games: games,
        hasReachedMax: games.length < 20,
        currentQuery: event.query,
        currentFilters: event.filters,
      )),
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
      print('Failed to save search query: $e');
    }
  }

  // 🎯 REFRESH CACHE EVENT - Re-emits current state with applied cache
  void _onRefreshCache(
    RefreshCacheEvent event,
    Emitter<GameState> emit,
  ) {
    print('🔄 RefreshCacheEvent: Applying cache to current state');
    final currentState = state;

    // Apply cache to the current state and re-emit it
    final refreshedState = _applyCacheToState(currentState);

    if (refreshedState != currentState) {
      print('✅ Cache applied, re-emitting state: ${refreshedState.runtimeType}');
      emit(refreshedState);
    } else {
      print('ℹ️ No cache changes to apply');
    }
  }
}
