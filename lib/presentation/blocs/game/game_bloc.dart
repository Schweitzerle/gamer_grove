// presentation/blocs/game/game_bloc.dart
import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:rxdart/rxdart.dart';
import '../../../data/datasources/remote/supabase_remote_datasource.dart';
import '../../../domain/entities/game.dart';
import '../../../domain/usecases/user/add_to_top_three.dart';
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
import '../../../injection_container.dart';

part 'game_event.dart';
part 'game_state.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  final SearchGames searchGames;
  final GetGameDetails getGameDetails;
  final RateGame rateGame;
  final ToggleWishlist toggleWishlist;
  final ToggleRecommend toggleRecommend;
  final AddToTopThree addToTopThree;
  final GetPopularGames getPopularGames;
  final GetUpcomingGames getUpcomingGames;
  final GetUserWishlist getUserWishlist;
  final GetUserRecommendations getUserRecommendations;
  final GetUserTopThreeGames getUserTopThreeGames;

  GameBloc({
    required this.searchGames,
    required this.getGameDetails,
    required this.rateGame,
    required this.toggleWishlist,
    required this.toggleRecommend,
    required this.addToTopThree,
    required this.getPopularGames,
    required this.getUpcomingGames,
    required this.getUserWishlist,
    required this.getUserRecommendations,
    required this.getUserTopThreeGames,
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
    on<GetGameDetailsWithUserDataEvent>(_onGetGameDetailsWithUserData);

    // Home page events
    on<LoadPopularGamesEvent>(_onLoadPopularGames);
    on<LoadUpcomingGamesEvent>(_onLoadUpcomingGames);

    // User-specific events
    on<LoadUserWishlistEvent>(_onLoadUserWishlist);
    on<LoadUserRecommendationsEvent>(_onLoadUserRecommendations);
  }

  // Debounce transformer for search
  EventTransformer<T> debounce<T>(Duration duration) {
    return (events, mapper) => events.debounceTime(duration).switchMap(mapper);
  }

  // Search Games
  Future<void> _onSearchGames(SearchGamesEvent event,
      Emitter<GameState> emit,) async {
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
          (games) =>
          emit(GameSearchLoaded(
            games: games,
            hasReachedMax: games.length < 20,
            currentQuery: event.query,
          )),
    );
  }

  // Load More Games (for search pagination)
  Future<void> _onLoadMoreGames(LoadMoreGamesEvent event,
      Emitter<GameState> emit,) async {
    if (state is GameSearchLoaded) {
      final currentState = state as GameSearchLoaded;

      if (currentState.hasReachedMax) return;

      emit(currentState.copyWith(isLoadingMore: true));

      final result = await searchGames(
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
              games: List.of(currentState.games)
                ..addAll(games),
              hasReachedMax: games.length < 20,
              isLoadingMore: false,
            ));
          }
        },
      );
    }
  }

  // Clear Search
  void _onClearSearch(ClearSearchEvent event,
      Emitter<GameState> emit,) {
    emit(GameInitial());
  }

  // Load Popular Games
  Future<void> _onLoadPopularGames(LoadPopularGamesEvent event,
      Emitter<GameState> emit,) async {
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
            games: List.of(currentState.games)
              ..addAll(games),
            hasReachedMax: games.length < event.limit,
            isLoadingMore: false,
          ));
        }
      },
    );
  }

  // Load Upcoming Games
  Future<void> _onLoadUpcomingGames(LoadUpcomingGamesEvent event,
      Emitter<GameState> emit,) async {
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
            games: List.of(currentState.games)
              ..addAll(games),
            hasReachedMax: games.length < event.limit,
            isLoadingMore: false,
          ));
        }
      },
    );
  }

  // Load User Wishlist
  Future<void> _onLoadUserWishlist(LoadUserWishlistEvent event,
      Emitter<GameState> emit,) async {
    emit(UserWishlistLoading());

    final result = await getUserWishlist(
      GetUserWishlistParams(userId: event.userId),
    );

    result.fold(
          (failure) => emit(GameError(failure.message)),
          (games) =>
          emit(UserWishlistLoaded(
            games: games,
            userId: event.userId,
          )),
    );
  }

  // Load User Recommendations
  Future<void> _onLoadUserRecommendations(LoadUserRecommendationsEvent event,
      Emitter<GameState> emit,) async {
    emit(UserRecommendationsLoading());

    final result = await getUserRecommendations(
      GetUserRecommendationsParams(userId: event.userId),
    );

    result.fold(
          (failure) => emit(GameError(failure.message)),
          (games) =>
          emit(UserRecommendationsLoaded(
            games: games,
            userId: event.userId,
          )),
    );
  }


  // Komplette _onGetGameDetailsWithUserData Methode für game_bloc.dart

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
              print('🔍 Loading user data for game ${event.gameId}');

              final supabaseDataSource = sl<SupabaseRemoteDataSource>() as SupabaseRemoteDataSourceImpl;

              // Try to use RPC function first
              try {
                final userGameData = await supabaseDataSource.getUserGameData(
                    event.userId!,
                    event.gameId
                );

                // Get top three position separately
                final topThreeData = await supabaseDataSource.getTopThreeGamesWithPosition(event.userId!);

                // Find position for current game
                int? gamePosition;
                bool isInTopThree = false;

                for (var entry in topThreeData) {
                  if (entry['game_id'] == event.gameId) {
                    isInTopThree = true;
                    gamePosition = entry['position'] as int;
                    break;
                  }
                }

                // Update game with all user-specific data
                final enhancedGame = game.copyWith(
                  isWishlisted: userGameData['is_wishlisted'] ?? false,
                  isRecommended: userGameData['is_recommended'] ?? false,
                  userRating: userGameData['user_rating']?.toDouble(),
                  isInTopThree: isInTopThree,
                  topThreePosition: gamePosition,
                );

                print('✅ User data loaded: wishlist=${enhancedGame.isWishlisted}, '
                    'recommended=${enhancedGame.isRecommended}, '
                    'rating=${enhancedGame.userRating}, '
                    'top3=${enhancedGame.isInTopThree} (position: $gamePosition)');

                if (!emit.isDone) {
                  emit(GameDetailsLoaded(enhancedGame));
                }
              } catch (rpcError) {
                // Fallback: Load data individually
                print('⚠️ RPC failed, loading data individually: $rpcError');

                final futures = await Future.wait([
                  _getUserWishlistIds(event.userId!),
                  _getUserRecommendedIds(event.userId!),
                  _getUserRatings(event.userId!),
                  _getUserTopThreeGames(event.userId!),
                ]);

                final wishlistIds = futures[0] as List<int>;
                final recommendedIds = futures[1] as List<int>;
                final userRatings = futures[2] as Map<int, double>;
                final topThreeIds = futures[3] as List<int>;

                // Get position if in top three
                int? gamePosition;
                if (topThreeIds.contains(game.id)) {
                  gamePosition = topThreeIds.indexOf(game.id) + 1;
                }

                final enhancedGame = game.copyWith(
                  isWishlisted: wishlistIds.contains(game.id),
                  isRecommended: recommendedIds.contains(game.id),
                  userRating: userRatings[game.id],
                  isInTopThree: topThreeIds.contains(game.id),
                  topThreePosition: gamePosition,
                );

                if (!emit.isDone) {
                  emit(GameDetailsLoaded(enhancedGame));
                }
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

// Die anderen Handler bleiben gleich, aber hier nochmal die wichtigen:

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

    if (!emit.isDone) {
      result.fold(
            (failure) => emit(GameError(failure.message)),
            (_) {
          if (state is GameDetailsLoaded) {
            final currentGame = (state as GameDetailsLoaded).game;
            emit(GameDetailsLoaded(
              currentGame.copyWith(userRating: event.rating),
            ));
          }
        },
      );
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
          (failure) => emit(GameError(failure.message)),
          (_) {
        // Update the game in all loaded states
        _updateGameInAllStates(event.gameId, (game) {
          return game.copyWith(isWishlisted: !game.isWishlisted);
        });
      },
    );
  }

// Toggle Recommendation
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
          (failure) => emit(GameError(failure.message)),
          (_) {
        // Update the game in all loaded states
        _updateGameInAllStates(event.gameId, (game) {
          return game.copyWith(isRecommended: !game.isRecommended);
        });
      },
    );
  }

// Helper method to update a game in all possible states
  void _updateGameInAllStates(int gameId, Game Function(Game) updateFunction) {
    final currentState = state;

    if (currentState is PopularGamesLoaded) {
      final updatedGames = currentState.games.map((game) {
        if (game.id == gameId) {
          return updateFunction(game);
        }
        return game;
      }).toList();

      emit(currentState.copyWith(games: updatedGames));
    } else if (currentState is HomePageLoaded) {
      final updatedPopular = currentState.popularGames?.map((game) {
        if (game.id == gameId) {
          return updateFunction(game);
        }
        return game;
      }).toList();

      final updatedUpcoming = currentState.upcomingGames?.map((game) {
        if (game.id == gameId) {
          return updateFunction(game);
        }
        return game;
      }).toList();

      final updatedWishlist = currentState.userWishlist?.map((game) {
        if (game.id == gameId) {
          return updateFunction(game);
        }
        return game;
      }).toList();

      final updatedRecommendations = currentState.userRecommendations?.map((game) {
        if (game.id == gameId) {
          return updateFunction(game);
        }
        return game;
      }).toList();

      emit(currentState.copyWith(
        popularGames: updatedPopular,
        upcomingGames: updatedUpcoming,
        userWishlist: updatedWishlist,
        userRecommendations: updatedRecommendations,
      ));
    } else if (currentState is GameSearchLoaded) {
      final updatedGames = currentState.games.map((game) {
        if (game.id == gameId) {
          return updateFunction(game);
        }
        return game;
      }).toList();

      emit(currentState.copyWith(games: updatedGames));
    }
    // Add more state types as needed
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


  Future<void> _onAddToTopThree(
      AddToTopThreeEvent event,
      Emitter<GameState> emit,
      ) async {
    final result = await addToTopThree(
      AddToTopThreeParams(
        gameId: event.gameId,
        userId: event.userId,
        position: event.position,
      ),
    );

    if (!emit.isDone) {
      result.fold(
            (failure) => emit(GameError(failure.message)),
            (_) {
          // Update the game in current state if needed
          if (state is GameDetailsLoaded) {
            final currentGame = (state as GameDetailsLoaded).game;
            emit(GameDetailsLoaded(
              currentGame.copyWith(isInTopThree: true),
            ));
          }
        },
      );
    }
  }


// Helper methods for user data (add to GameBloc)
  Future<List<int>> _getUserWishlistIds(String userId) async {
    final result = await getUserWishlist(GetUserWishlistParams(userId: userId));
    return result.fold(
          (failure) => <int>[],
          (games) => games.map((game) => game.id).toList(),
    );
  }

  Future<List<int>> _getUserRecommendedIds(String userId) async {
    final result = await getUserRecommendations(
        GetUserRecommendationsParams(userId: userId));
    return result.fold(
          (failure) => <int>[],
          (games) => games.map((game) => game.id).toList(),
    );
  }


  Future<Map<int, double>> _getUserRatings(String userId) async {
    try {
      // Directly use the supabase data source since we don't have a use case for this yet
      final supabaseDataSource = sl<SupabaseRemoteDataSource>();
      final ratings = await supabaseDataSource.getUserRatings(userId);
      return ratings;
    } catch (e) {
      print('❌ GameBloc: Failed to get user ratings: $e');
      return <int, double>{};
    }
  }
  Future<List<int>> _getUserTopThreeGames(String userId) async {
    final result = await getUserTopThreeGames(
        GetUserTopThreeGamesParams(userId: userId)
    );
    return result.fold(
          (failure) => <int>[],
          (topThreeIds) => topThreeIds,
    );
  }

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
        if (event.userId != null) ...[
          getUserWishlist(GetUserWishlistParams(userId: event.userId!)),
          getUserRecommendations(GetUserRecommendationsParams(userId: event.userId!)),
        ],
      ]);

      // Extract results
      final popularGames = results[0].fold((l) => <Game>[], (r) => r as List<Game>);
      final upcomingGames = results[1].fold((l) => <Game>[], (r) => r as List<Game>);
      final userWishlist = event.userId != null && results.length > 2
          ? results[2].fold((l) => <Game>[], (r) => r as List<Game>)
          : <Game>[];
      final userRecommendations = event.userId != null && results.length > 3
          ? results[3].fold((l) => <Game>[], (r) => r as List<Game>)
          : <Game>[];

      // Enrich all games with user data if user is logged in
      if (event.userId != null) {
        final enrichedPopular = await _enrichGamesWithUserData(popularGames, event.userId);
        final enrichedUpcoming = await _enrichGamesWithUserData(upcomingGames, event.userId);

        emit(HomePageLoaded(
          popularGames: enrichedPopular,
          upcomingGames: enrichedUpcoming,
          userWishlist: userWishlist,
          userRecommendations: userRecommendations,
        ));
      } else {
        emit(HomePageLoaded(
          popularGames: popularGames,
          upcomingGames: upcomingGames,
        ));
      }
    } catch (e) {
      emit(GameError('Failed to load home page data: $e'));
    }
  }
}




