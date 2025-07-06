// presentation/blocs/game/game_bloc.dart
import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:gamer_grove/domain/usecases/game/get_top_rated_games.dart';
import 'package:rxdart/rxdart.dart';
import '../../../core/errors/failures.dart';
import '../../../data/datasources/remote/supabase/supabase_remote_datasource.dart';
import '../../../data/datasources/remote/supabase/supabase_remote_datasource_impl.dart';
import '../../../domain/entities/game/game.dart';
import '../../../domain/usecases/game/getUserRated.dart';
import '../../../domain/usecases/game/get_complete_game_details.dart';
import '../../../domain/usecases/game/get_game_dlcs.dart';
import '../../../domain/usecases/game/get_game_expansions.dart';
import '../../../domain/usecases/game/get_latest_games.dart';
import '../../../domain/usecases/game/get_similar_games.dart';
import '../../../domain/usecases/game/get_user_top_three.dart';
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
import '../../pages/game_detail/game_detail_page.dart';

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
  final GetLatestGames getLatestGames;
  final GetTopRatedGames getTopRatedGames;
  final GetUserWishlist getUserWishlist;
  final GetUserRecommendations getUserRecommendations;
  final GetUserTopThreeGames getUserTopThreeGames;
  final GetUserTopThree getUserTopThree;
  final GetUserRated getUserRated;
  final GetCompleteGameDetails getCompleteGameDetails;
  final GetSimilarGames getSimilarGames;
  final GetGameDLCs getGameDLCs;
  final GetGameExpansions getGameExpansions;

  GameBloc({
    required this.searchGames,
    required this.getGameDetails,
    required this.rateGame,
    required this.toggleWishlist,
    required this.toggleRecommend,
    required this.addToTopThree,
    required this.getPopularGames,
    required this.getUpcomingGames,
    required this.getLatestGames,
    required this.getTopRatedGames,
    required this.getUserWishlist,
    required this.getUserRecommendations,
    required this.getUserTopThreeGames,
    required this.getUserTopThree,
    required this.getUserRated,
    required this.getCompleteGameDetails,
    required this.getSimilarGames,
    required this.getGameDLCs,
    required this.getGameExpansions,
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
    on<LoadTopRatedGamesEvent>(_onLoadTopRatedGames);

    // User-specific events
    on<LoadUserWishlistEvent>(_onLoadUserWishlist);
    on<LoadUserRecommendationsEvent>(_onLoadUserRecommendations);
    on<LoadUserRatedEvent>(_onLoadUserRated);

    on<LoadHomePageDataEvent>(_onLoadHomePageData);
    on<LoadGrovePageDataEvent>(_onLoadGrovePageData);

    on<GetCompleteGameDetailsEvent>(_onGetCompleteGameDetails);
    on<GetSimilarGamesEvent>(_onGetSimilarGames);
    on<GetGameDLCsEvent>(_onGetGameDLCs);
    on<GetGameExpansionsEvent>(_onGetGameExpansions);
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


  // Load Popular Games
  Future<void> _onLoadTopRatedGames(LoadTopRatedGamesEvent event,
      Emitter<GameState> emit,) async {
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
      GetUserWishlistParams(userId: event.userId, limit: 20, offset: 0),
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
      GetUserRecommendationsParams(userId: event.userId, limit: 20, offset: 0),
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

  // Load User Rated
  Future<void> _onLoadUserRated(LoadUserRatedEvent event,
      Emitter<GameState> emit,) async {
    emit(UserRatedLoading());

    final result = await getUserRated(
      GetUserRatedParams(userId: event.userId, limit: 20, offset: 0),
    );

    result.fold(
          (failure) => emit(GameError(failure.message)),
          (games) =>
          emit(UserRatedLoaded(
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
                final topThreeData = await supabaseDataSource.getUserTopThreeGames( userId: event.userId!,);

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
                  isWishlisted: userGameData?['is_wishlisted'] ?? false,
                  isRecommended: userGameData?['is_recommended'] ?? false,
                  userRating: userGameData?['user_rating']?.toDouble(),
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
        // ✅ EXPLIZIT GameDetailsLoaded State aktualisieren
        if (state is GameDetailsLoaded && !emit.isDone) {
          final currentGame = (state as GameDetailsLoaded).game;
          if (currentGame.id == event.gameId) {
            emit(GameDetailsLoaded(
              currentGame.copyWith(isWishlisted: !currentGame.isWishlisted),
            ));
          }
        }

        // Auch andere States updaten
        _updateGameInAllStates(event.gameId, (game) {
          return game.copyWith(isWishlisted: !game.isWishlisted);
        });
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
        // ✅ EXPLIZIT GameDetailsLoaded State aktualisieren
        if (state is GameDetailsLoaded && !emit.isDone) {
          final currentGame = (state as GameDetailsLoaded).game;
          if (currentGame.id == event.gameId) {
            emit(GameDetailsLoaded(
              currentGame.copyWith(isRecommended: !currentGame.isRecommended),
            ));
          }
        }

        // Auch andere States updaten
        _updateGameInAllStates(event.gameId, (game) {
          return game.copyWith(isRecommended: !game.isRecommended);
        });
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
        // Update in allen States
        _updateGameInHomePageState(event.gameId, (game) {
          return game.copyWith(userRating: event.rating);
        });

        // Falls aktueller State GameDetailsLoaded ist
        if (state is GameDetailsLoaded) {
          final currentGame = (state as GameDetailsLoaded).game;
          if (currentGame.id == event.gameId) {
            emit(GameDetailsLoaded(
              currentGame.copyWith(userRating: event.rating),
            ));
          }
        }
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




// Helper methods for user data (add to GameBloc)
  Future<List<int>> _getUserWishlistIds(String userId) async {
    final result = await getUserWishlist(GetUserWishlistParams(userId: userId, limit: 20, offset: 0));
    return result.fold(
          (failure) => <int>[],
          (games) => games.map((game) => game.id).toList(),
    );
  }

  Future<List<int>> _getUserRecommendedIds(String userId) async {
    final result = await getUserRecommendations(
        GetUserRecommendationsParams(userId: userId, limit: 20, offset: 0));
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

  Future<List<int>> _getTopThreeGames(String userId) async {
    final result = await getUserTopThree(
        GetUserTopThreeParams(userId: userId)
    );
    return result.fold(
          (failure) => <int>[],
          (topThreeIds) => topThreeIds.map((game) => game.id).toList(),
    );
  }

  Future<List<int>> _getUserTopThreeGames(String userId) async {
    final result = await getUserTopThreeGames(
        GetUserTopThreeGamesParams(userId: userId)
    );
    return result.fold(
          (failure) => <int>[],
          (topThreeData) {
        // ✅ FIX: Extract game IDs and sort by position
        final List<int> gameIds = [];

        // Sort by position first
        topThreeData.sort((a, b) =>
            (a['position'] as int).compareTo(b['position'] as int));

        // Extract game IDs in correct order
        for (final item in topThreeData) {
          final gameId = item['game_id'] as int;
          gameIds.add(gameId);
        }

        return gameIds;
      },
    );
  }
  // 4. Aktualisierte _onLoadHomePageData Methode:

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
        if (event.userId != null) ...[
          getUserWishlist(GetUserWishlistParams(userId: event.userId!, limit: 20, offset: 0)),
          getUserRecommendations(GetUserRecommendationsParams(userId: event.userId!, limit: 20, offset: 0)),
        ],
      ]);

      // Extract results
      final popularGames = results[0].fold((l) => <Game>[], (r) => r);
      final upcomingGames = results[1].fold((l) => <Game>[], (r) => r);
      final latestGames = results[2].fold((l) => <Game>[], (r) => r);
      final topRatedGames = results[3].fold((l) => <Game>[], (r) => r);
      final userWishlist = event.userId != null && results.length > 2
          ? results[4].fold((l) => <Game>[], (r) => r)
          : <Game>[];
      final userRecommendations = event.userId != null && results.length > 3
          ? results[5].fold((l) => <Game>[], (r) => r)
          : <Game>[];

      // 🔥 WICHTIG: Alle Games mit User Data anreichern
      if (event.userId != null) {
        final enrichedPopular = await _enrichGamesWithUserData(popularGames, event.userId!);
        final enrichedUpcoming = await _enrichGamesWithUserData(upcomingGames, event.userId!);
        final enrichLatest = await _enrichGamesWithUserData(latestGames, event.userId!);
        final enrichedTopRated = await _enrichGamesWithUserData(topRatedGames, event.userId!);
        // ✅ NEU: Auch Wishlist und Recommendations anreichern (für Top 3, etc.)
        final enrichedWishlist = userWishlist.isNotEmpty
            ? await _enrichGamesWithUserData(userWishlist, event.userId!)
            : <Game>[];
        final enrichedRecommendations = userRecommendations.isNotEmpty
            ? await _enrichGamesWithUserData(userRecommendations, event.userId!)
            : <Game>[];

        emit(HomePageLoaded(
          popularGames: enrichedPopular,
          upcomingGames: enrichedUpcoming,
          latestGames: enrichLatest,
          topRatedGames: enrichedTopRated,
          userWishlist: enrichedWishlist,
          userRecommendations: enrichedRecommendations,));
      } else {
        emit(HomePageLoaded(
          popularGames: popularGames,
          upcomingGames: upcomingGames,
          latestGames: latestGames,
          topRatedGames: topRatedGames,
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
        getUserRated(GetUserRatedParams(userId: event.userId!, limit: 20, offset: 0)),
        getUserWishlist(GetUserWishlistParams(userId: event.userId!, limit: 20, offset: 0)),
        getUserRecommendations(GetUserRecommendationsParams(userId: event.userId!, limit: 20, offset: 0)),
        getUserTopThree(GetUserTopThreeParams(userId: event.userId!)),
      ]);

      // ✅ KORREKTE Result-Extraktion (keine conditional spreads!)
      final userRated = results[0].fold((l) => <Game>[], (r) => r);
      final userWishlist = results[1].fold((l) => <Game>[], (r) => r);
      final userRecommendations = results[2].fold((l) => <Game>[], (r) => r);
      final userTopThree = results[3].fold((l) => <Game>[], (r) => r);

      // Games mit User Data anreichern
      final enrichedRated = userRated.isNotEmpty
          ? await _enrichGamesWithUserData(userRated, event.userId!)
          : <Game>[];
      final enrichedWishlist = userWishlist.isNotEmpty
          ? await _enrichGamesWithUserData(userWishlist, event.userId!)
          : <Game>[];
      final enrichedRecommendations = userRecommendations.isNotEmpty
          ? await _enrichGamesWithUserData(userRecommendations, event.userId!)
          : <Game>[];
      final enrichedTopThree = userTopThree.isNotEmpty
          ? await _enrichGamesWithUserData(userTopThree, event.userId!)
          : <Game>[];

      // ✅ State emittieren (das fehlte!)
      emit(GrovePageLoaded(
        userRated: enrichedRated,
        userWishlist: enrichedWishlist,
        userRecommendations: enrichedRecommendations,
        userTopThree: enrichedTopThree,
      ));

    } catch (e) {
      print('❌ Failed to load grove page data: $e');
      emit(GameError('Failed to load grove page data: $e'));
    }
  }


  Future<List<Game>> _enrichGamesWithUserData(List<Game> games, String? userId) async {
    if (userId == null || games.isEmpty) return games;

    try {
      final supabaseDataSource = sl<SupabaseRemoteDataSource>();

      // Hole alle User-Game Daten parallel
      final futures = games.map((game) =>
          supabaseDataSource.getUserGameData(userId, game.id)
      ).toList();

      final userGameDataList = await Future.wait(futures);

      final topThreeData = await supabaseDataSource.getUserTopThreeGames(userId: userId);
      final topThreeMap = <int, int>{};
      for (var entry in topThreeData) {
        topThreeMap[entry['game_id'] as int] = entry['position'] as int;
      }

      // Erstelle angereicherte Games Liste
      final enrichedGames = <Game>[];
      for (int i = 0; i < games.length; i++) {
        final game = games[i];
        final userGameData = userGameDataList[i];

        if (userGameData != null) {
          enrichedGames.add(game.copyWith(
            isWishlisted: userGameData['is_wishlisted'] ?? false,
            isRecommended: userGameData['is_recommended'] ?? false,
            userRating: userGameData['rating']?.toDouble(),
            isInTopThree: topThreeMap.containsKey(game.id),
            topThreePosition: topThreeMap[game.id],
          ));
        } else {
          enrichedGames.add(game.copyWith(
            isWishlisted: false,
            isRecommended: false,
            userRating: null,
            isInTopThree: false,
          ));
        }
      }

      return enrichedGames;
    } catch (e) {
      print('❌ GameBloc: Error enriching games with user data: $e');
      return games; // Return original games if enrichment fails
    }
  }

  void _updateGameInHomePageState(int gameId, Game Function(Game) updateFunction) {
    final currentState = state;

    if (currentState is HomePageLoaded) {
      // Update in allen Listen
      final updatedPopular = currentState.popularGames.map((game) {
        return game.id == gameId ? updateFunction(game) : game;
      }).toList();

      final updatedUpcoming = currentState.upcomingGames.map((game) {
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
        userWishlist: updatedWishlist,
        userRecommendations: updatedRecommendations,
      ));
    }
  }


  Future<void> _onGetCompleteGameDetails(
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
              final enrichedGames = await _enrichGamesWithUserData([game], event.userId!);
              if (!emit.isDone) {
                emit(GameDetailsLoaded(enrichedGames.first));
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
    final result = await addToTopThree(AddToTopThreeParams(
      userId: event.userId,
      gameId: event.gameId,
      position: event.position,
    ));

    result.fold(
          (failure) {
        if (!emit.isDone) {
          emit(GameError(_mapFailureToMessage(failure)));
        }
      },
          (_) {
        // ✅ NICHT rekursiv ein neues Event triggern!
        // Stattdessen aktuellen State updaten
        if (state is GameDetailsLoaded && !emit.isDone) {
          final currentGame = (state as GameDetailsLoaded).game;
          if (currentGame.id == event.gameId) {
            final updatedGame = currentGame.copyWith(
              isInTopThree: true,
              topThreePosition: event.position,
            );
            emit(GameDetailsLoaded(updatedGame));
          }
        }

        // ✅ Auch andere States updaten
        _updateGameInAllStates(event.gameId, (game) {
          return game.copyWith(
            isInTopThree: true,
            topThreePosition: event.position,
          );
        });
      },
    );
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
}




