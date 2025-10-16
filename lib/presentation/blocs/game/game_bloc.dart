// presentation/blocs/game/game_bloc.dart
import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:gamer_grove/domain/usecases/game/get_top_rated_games.dart';
import 'package:rxdart/rxdart.dart';
import '../../../core/errors/failures.dart';
import '../../../core/utils/game_enrichment_utils.dart';
import '../../../data/datasources/remote/supabase/deprecated/supabase_remote_datasource.dart';
import '../../../data/datasources/remote/supabase/deprecated/supabase_remote_datasource_impl.dart';
import '../../../data/models/game/game_model.dart';
import '../../../domain/entities/collection/collection.dart';
import '../../../domain/entities/franchise.dart';
import '../../../domain/entities/game/game.dart';
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
  final GameRepository gameRepository;

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
    required this.getSimilarGames,
    required this.getGameDLCs,
    required this.getGameExpansions,
    required this.getEnhancedGameDetails,
    required this.getCompleteGameDetailPageData,
    required this.gameRepository,
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
  }

  // Debounce transformer for search
  EventTransformer<T> debounce<T>(Duration duration) {
    return (events, mapper) => events.debounceTime(duration).switchMap(mapper);
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
      (games) => emit(GameSearchLoaded(
        games: games,
        hasReachedMax: games.length < 20,
        currentQuery: event.query,
      )),
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
              print('🔍 Loading user data for game ${event.gameId}');

              final supabaseDataSource = sl<SupabaseRemoteDataSource>()
                  as SupabaseRemoteDataSourceImpl;

              // Try to use RPC function first
              try {
                final userGameData = await supabaseDataSource.getUserGameData(
                    event.userId!, event.gameId);

                // Get top three position separately
                final topThreeData =
                    await supabaseDataSource.getUserTopThreeGames(
                  userId: event.userId!,
                );

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

                print(
                    '✅ User data loaded: wishlist=${enhancedGame.isWishlisted}, '
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
        // Update in allen States
        _updateGameInHomePageState(event.gameId, (game) {
          return game.copyWith(userRating: event.rating);
        }, emit);

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
  void _updateGameInAllStates(
      int gameId, Game Function(Game) updateFunction, Emitter<GameState> emit) {
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
      final updatedPopular = currentState.popularGames.map((game) {
        if (game.id == gameId) {
          return updateFunction(game);
        }
        return game;
      }).toList();

      final updatedUpcoming = currentState.upcomingGames.map((game) {
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

      final updatedRecommendations =
          currentState.userRecommendations?.map((game) {
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
    final result = await getUserWishlist(
        GetUserWishlistParams(userId: userId, limit: 20, offset: 0));
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

  Future<List<int>> _getUserTopThreeGames(String userId) async {
    final result =
        await getUserTopThreeGames(GetUserTopThreeGamesParams(userId: userId));
    return result.fold(
      (failure) => <int>[],
      (topThreeData) {
        // ✅ FIX: Extract game IDs and sort by position
        final List<int> gameIds = [];

        // Sort by position first
        topThreeData.sort(
            (a, b) => (a['position'] as int).compareTo(b['position'] as int));

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
          getUserWishlist(GetUserWishlistParams(
              userId: event.userId!, limit: 20, offset: 0)),
          getUserRecommendations(GetUserRecommendationsParams(
              userId: event.userId!, limit: 20, offset: 0)),
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

        emit(HomePageLoaded(
          popularGames: enrichedPopular,
          upcomingGames: enrichedUpcoming,
          latestGames: enrichLatest,
          topRatedGames: enrichedTopRated,
          userWishlist: enrichedWishlist,
          userRecommendations: enrichedRecommendations,
        ));
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

  Future<List<Game>> enrichGamesWithUserData(
    List<Game> games,
    String userId, {
    int? enrichLimit,
  }) async {
    return await GameEnrichmentUtils.enrichGameDetailGames(
      games,
      userId,
      limit: enrichLimit ?? 15,
    );
  }

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
        }, emit);
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
}
