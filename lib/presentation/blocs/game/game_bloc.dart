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

part 'game_event.dart';
part 'game_state.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  final SearchGames searchGames;
  final GetGameDetails getGameDetails;
  final RateGame rateGame;
  final ToggleWishlist toggleWishlist;

  GameBloc({
    required this.searchGames,
    required this.getGameDetails,
    required this.rateGame,
    required this.toggleWishlist,
  }) : super(GameInitial()) {
    on<SearchGamesEvent>(
      _onSearchGames,
      transformer: debounce(const Duration(milliseconds: 500)),
    );
    on<LoadMoreGamesEvent>(_onLoadMoreGames);
    on<GetGameDetailsEvent>(_onGetGameDetails);
    on<RateGameEvent>(_onRateGame);
    on<ToggleWishlistEvent>(_onToggleWishlist);
    on<ClearSearchEvent>(_onClearSearch);
  }

  // Debounce transformer for search
  EventTransformer<T> debounce<T>(Duration duration) {
    return (events, mapper) => events.debounceTime(duration).switchMap(mapper);
  }

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
      },
    );
  }

  void _onClearSearch(
      ClearSearchEvent event,
      Emitter<GameState> emit,
      ) {
    emit(GameInitial());
  }
}

