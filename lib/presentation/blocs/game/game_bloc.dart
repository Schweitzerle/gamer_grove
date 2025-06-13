// presentation/blocs/game/game_bloc.dart
import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:rxdart/rxdart.dart';
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

  // Game Details
  Future<void> _onGetGameDetails(GetGameDetailsEvent event,
      Emitter<GameState> emit,) async {
    emit(GameDetailsLoading());

    final result = await getGameDetails(
      GameDetailsParams(gameId: event.gameId),
    );

    result.fold(
          (failure) => emit(GameError(failure.message)),
          (game) => emit(GameDetailsLoaded(game)),
    );
  }

  // Rate Game
  Future<void> _onRateGame(RateGameEvent event,
      Emitter<GameState> emit,) async {
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
        // Update the game in current state if needed
        if (state is GameDetailsLoaded) {
          final currentGame = (state as GameDetailsLoaded).game;
          emit(GameDetailsLoaded(
            currentGame.copyWith(userRating: event.rating),
          ));
        }
      },
    );
  }

  // Toggle Wishlist
  Future<void> _onToggleWishlist(ToggleWishlistEvent event,
      Emitter<GameState> emit,) async {
    final result = await toggleWishlist(
      ToggleWishlistParams(
        gameId: event.gameId,
        userId: event.userId,
      ),
    );

    result.fold(
          (failure) => emit(GameError(failure.message)),
          (_) {
        // Update the game in current state if needed
        if (state is GameDetailsLoaded) {
          final currentGame = (state as GameDetailsLoaded).game;
          emit(GameDetailsLoaded(
            currentGame.copyWith(isWishlisted: !currentGame.isWishlisted),
          ));
        }
        // TODO: Also update other states where this game might appear
      },
    );
  }

  Future<void> _onToggleRecommend(ToggleRecommendEvent event,
      Emitter<GameState> emit,) async {
    final result = await toggleRecommend(
      ToggleRecommendParams(
        gameId: event.gameId,
        userId: event.userId,
      ),
    );

    result.fold(
          (failure) => emit(GameError(failure.message)),
          (_) {
        // Update the game in current state if needed
        if (state is GameDetailsLoaded) {
          final currentGame = (state as GameDetailsLoaded).game;
          emit(GameDetailsLoaded(
            currentGame.copyWith(isRecommended: !currentGame.isRecommended),
          ));
        }
        // TODO: Also update other states where this game might appear
      },
    );
  }

  // Add to Top Three
  Future<void> _onAddToTopThree(AddToTopThreeEvent event,
      Emitter<GameState> emit,) async {
    final result = await addToTopThree(
      AddToTopThreeParams(
        gameId: event.gameId,
        userId: event.userId,
      ),
    );

    result.fold(
          (failure) => emit(GameError(failure.message)),
          (_) {
        // Success - show success state or update UI
        // The actual top three list is managed in user profile/grove
        // Here we just show success via SnackBar in UI
      },
    );
  }


  Future<void> _onGetGameDetailsWithUserData(
      GetGameDetailsWithUserDataEvent event,
      Emitter<GameState> emit,) async {
    emit(GameDetailsLoading());

    try {
      // Get basic game details
      final gameResult = await getGameDetails(
        GameDetailsParams(gameId: event.gameId),
      );

      await gameResult.fold(
            (failure) async => emit(GameError(failure.message)),
            (game) async {
          // If user is logged in, get user-specific data
          if (event.userId != null) {
            try {
              // Get user data in parallel
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

              // Update game with user-specific data
              final enhancedGame = game.copyWith(
                isWishlisted: wishlistIds.contains(game.id),
                isRecommended: recommendedIds.contains(game.id),
                userRating: userRatings[game.id],
              );

              emit(GameDetailsLoaded(enhancedGame));
            } catch (e) {
              // If user data fails, still show game without user data
              print('⚠️ Failed to load user data: $e');
              emit(GameDetailsLoaded(game));
            }
          } else {
            // No user logged in, show game without user data
            emit(GameDetailsLoaded(game));
          }
        },
      );
    } catch (e) {
      emit(GameError('Failed to load game details: $e'));
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
    // You would need to create a GetUserRatings use case
    // For now, return empty map
    return <int, double>{};
  }

  Future<List<int>> _getUserTopThreeGames(String userId) async {
    // You would need to create a GetUserTopThreeGames use case
    // For now, return empty list
    return <int>[];
  }
}




