// presentation/blocs/game/game_bloc.dart
import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import 'package:gamer_grove/core/services/game_enrichment_service.dart';
import 'package:gamer_grove/data/models/game/game_model.dart';
import 'package:gamer_grove/domain/entities/collection/collection.dart';
import 'package:gamer_grove/domain/entities/event/event.dart';
import 'package:gamer_grove/domain/entities/franchise.dart';
import 'package:gamer_grove/domain/entities/game/game.dart';
import 'package:gamer_grove/domain/entities/search/search_filters.dart';
import 'package:gamer_grove/domain/repositories/game_repository.dart';
import 'package:gamer_grove/domain/usecases/collection/remove_rating_use_case.dart';
import 'package:gamer_grove/domain/usecases/event/get_upcoming_events.dart';
import 'package:gamer_grove/domain/usecases/game/get_game_details.dart';
import 'package:gamer_grove/domain/usecases/game/get_game_dlcs.dart';
import 'package:gamer_grove/domain/usecases/game/get_game_expansions.dart';
import 'package:gamer_grove/domain/usecases/game/get_latest_games.dart';
import 'package:gamer_grove/domain/usecases/game/get_popular_games.dart';
import 'package:gamer_grove/domain/usecases/game/get_similar_games.dart';
import 'package:gamer_grove/domain/usecases/game/get_top_rated_games.dart';
import 'package:gamer_grove/domain/usecases/game/get_upcoming_games.dart';
import 'package:gamer_grove/domain/usecases/game/get_user_rated.dart';
import 'package:gamer_grove/domain/usecases/game/get_user_rated_game_ids.dart';
import 'package:gamer_grove/domain/usecases/game/get_user_recommendations.dart';
import 'package:gamer_grove/domain/usecases/game/get_user_top_three.dart';
import 'package:gamer_grove/domain/usecases/game/get_user_wishlist.dart';
import 'package:gamer_grove/domain/usecases/game/rate_game.dart';
import 'package:gamer_grove/domain/usecases/game/search_games.dart';
import 'package:gamer_grove/domain/usecases/game/toggle_recommend.dart';
import 'package:gamer_grove/domain/usecases/game/toggle_wishlist.dart';
import 'package:gamer_grove/domain/usecases/game_details/get_complete_game_details_page_data.dart';
import 'package:gamer_grove/domain/usecases/game_details/get_enhanced_game_details.dart';
import 'package:gamer_grove/domain/usecases/user/add_to_top_three.dart';
import 'package:gamer_grove/domain/usecases/user/get_user_top_three.dart';
import 'package:gamer_grove/domain/usecases/user/remove_from_top_three.dart';
import 'package:gamer_grove/presentation/blocs/game/game_extensions.dart';
import 'package:rxdart/rxdart.dart';

part 'game_event.dart';
part 'game_state.dart';
part 'game_bloc_search.dart';
part 'game_bloc_curated.dart';
part 'game_bloc_details.dart';
part 'game_bloc_user_data.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  GameBloc({
    required this.searchGames,
    required this.getGameDetails,
    required this.rateGame,
    required this.removeRating,
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
    required this.getUserRatedGameIds,
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
    on<RemoveRatingEvent>(_onRemoveRating);
    on<ToggleWishlistEvent>(_onToggleWishlist);
    on<ToggleRecommendEvent>(_onToggleRecommend);
    on<AddToTopThreeEvent>(_onAddToTopThree);
    on<RemoveFromTopThreeEvent>(_onRemoveFromTopThree);
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
    on<LoadAllUserRatedEvent>(_onLoadAllUserRated);
    on<LoadAllUserWishlistEvent>(_onLoadAllUserWishlist);
    on<LoadAllUserRecommendationsEvent>(_onLoadAllUserRecommendations);
    on<LoadAllUserRatedPaginated>(_onLoadAllUserRatedPaginated);
    on<LoadMoreUserRatedPaginated>(_onLoadMoreUserRatedPaginated);
    on<LoadAllUserWishlistPaginated>(_onLoadAllUserWishlistPaginated);
    on<LoadMoreUserWishlistPaginated>(_onLoadMoreUserWishlistPaginated);
    on<LoadAllUserRecommendedPaginated>(_onLoadAllUserRecommendedPaginated);
    on<LoadMoreUserRecommendedPaginated>(_onLoadMoreUserRecommendedPaginated);

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
  final SearchGames searchGames;
  final GetGameDetails getGameDetails;
  final RateGame rateGame;
  final RemoveRatingUseCase removeRating;
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
  final GetUserRatedGameIds getUserRatedGameIds;
  final GameRepository gameRepository;
  final GameEnrichmentService enrichmentService;

  // 🎯 PERSISTENT GAME CACHE - survives state changes!
  final Map<int, Game> _gameCache = {};

  // Debounce transformer for search
  EventTransformer<T> debounce<T>(Duration duration) {
    return (events, mapper) => events.debounceTime(duration).switchMap(mapper);
  }

  // 🎯 CACHE MANAGEMENT METHODS

  /// Updates a game in the cache
  void _updateGameCache(int gameId, Game updatedGame) {
    _gameCache[gameId] = updatedGame;
  }

  /// Updates multiple games in the cache
  void _updateGamesCacheList(List<Game> games) {
    for (final game in games) {
      _gameCache[game.id] = game;
    }
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

// ✅ COMPREHENSIVE Helper method to update a game in ALL possible states
  void _updateGameInAllStates(
    int gameId,
    Game Function(Game) updateFunction,
    Emitter<GameState> emit,
  ) {
    final currentState = state;

    // 1. PopularGamesLoaded
    if (currentState is PopularGamesLoaded) {
      final updatedGames = currentState.games.map((game) {
        return game.id == gameId ? updateFunction(game) : game;
      }).toList();
      emit(currentState.copyWith(games: _applyCache(updatedGames)));
    }

    // 2. UpcomingGamesLoaded
    else if (currentState is UpcomingGamesLoaded) {
      final updatedGames = currentState.games.map((game) {
        return game.id == gameId ? updateFunction(game) : game;
      }).toList();
      emit(currentState.copyWith(games: _applyCache(updatedGames)));
    }

    // 3. LatestGamesLoaded
    else if (currentState is LatestGamesLoaded) {
      final updatedGames = currentState.games.map((game) {
        return game.id == gameId ? updateFunction(game) : game;
      }).toList();
      emit(currentState.copyWith(games: _applyCache(updatedGames)));
    }

    // 4. TopRatedGamesLoaded
    else if (currentState is TopRatedGamesLoaded) {
      final updatedGames = currentState.games.map((game) {
        return game.id == gameId ? updateFunction(game) : game;
      }).toList();
      emit(currentState.copyWith(games: _applyCache(updatedGames)));
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

      final updatedRecommendations =
          currentState.userRecommendations?.map((game) {
        return game.id == gameId ? updateFunction(game) : game;
      }).toList();

      emit(
        currentState.copyWith(
          popularGames: _applyCache(updatedPopular),
          upcomingGames: _applyCache(updatedUpcoming),
          latestGames: _applyCache(updatedLatest),
          topRatedGames: _applyCache(updatedTopRated),
          userWishlist:
              updatedWishlist != null ? _applyCache(updatedWishlist) : null,
          userRecommendations: updatedRecommendations != null
              ? _applyCache(updatedRecommendations)
              : null,
        ),
      );
    }

    // 6. GrovePageLoaded - Update ALL user collections
    else if (currentState is GrovePageLoaded) {
      final updatedRated = currentState.userRated.map((game) {
        return game.id == gameId ? updateFunction(game) : game;
      }).toList();

      final updatedWishlist = currentState.userWishlist.map((game) {
        return game.id == gameId ? updateFunction(game) : game;
      }).toList();

      final updatedRecommendations =
          currentState.userRecommendations.map((game) {
        return game.id == gameId ? updateFunction(game) : game;
      }).toList();

      final updatedTopThree = currentState.userTopThree.map((game) {
        return game.id == gameId ? updateFunction(game) : game;
      }).toList();

      emit(
        currentState.copyWith(
          userRated: _applyCache(updatedRated),
          userWishlist: _applyCache(updatedWishlist),
          userRecommendations: _applyCache(updatedRecommendations),
          userTopThree: _applyCache(updatedTopThree),
        ),
      );
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
  }

  Future<List<Game>> enrichGamesWithUserData(
    List<Game> games,
    String userId, {
    int? enrichLimit,
  }) async {
    final enrichedGames = await enrichmentService.enrichGames(games, userId);
    return enrichedGames;
  }

  // ✅ UPDATED: Now includes latestGames and topRatedGames
  void _updateGameInHomePageState(
    int gameId,
    Game Function(Game) updateFunction,
    Emitter<GameState> emit,
  ) {
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

      emit(
        currentState.copyWith(
          popularGames: updatedPopular,
          upcomingGames: updatedUpcoming,
          latestGames: updatedLatest,
          topRatedGames: updatedTopRated,
          userWishlist: updatedWishlist,
          userRecommendations: updatedRecommendations,
        ),
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

  // 🎯 REFRESH CACHE EVENT - Re-emits current state with applied cache
  void _onRefreshCache(
    RefreshCacheEvent event,
    Emitter<GameState> emit,
  ) {
    final currentState = state;

    // Apply cache to the current state and re-emit it
    final refreshedState = _applyCacheToState(currentState);

    if (refreshedState != currentState) {
      emit(refreshedState);
    } else {}
  }
}
