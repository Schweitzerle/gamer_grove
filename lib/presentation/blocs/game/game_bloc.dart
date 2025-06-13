// presentation/blocs/game/game_bloc.dart
import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:rxdart/rxdart.dart';
import '../../../domain/entities/game.dart';
import '../../../domain/usecases/game/search_games.dart';
import '../../../domain/usecases/game/get_game_details.dart';
import '../../../domain/usecases/game/rate_game.dart';
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
  final GetPopularGames getPopularGames;
  final GetUpcomingGames getUpcomingGames;
  final GetUserWishlist getUserWishlist;
  final GetUserRecommendations getUserRecommendations;

  GameBloc({
    required this.searchGames,
    required this.getGameDetails,
    required this.rateGame,
    required this.toggleWishlist,
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

  // Load User Wishlist
  Future<void> _onLoadUserWishlist(
      LoadUserWishlistEvent event,
      Emitter<GameState> emit,
      ) async {
    emit(UserWishlistLoading());

    final result = await getUserWishlist(
      GetUserWishlistParams(userId: event.userId),
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
      GetUserRecommendationsParams(userId: event.userId),
    );

    result.fold(
          (failure) => emit(GameError(failure.message)),
          (games) => emit(UserRecommendationsLoaded(
        games: games,
        userId: event.userId,
      )),
    );
  }

  // Game Details
  Future<void> _onGetGameDetails(
      GetGameDetailsEvent event,
      Emitter<GameState> emit,
      ) async {
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
}