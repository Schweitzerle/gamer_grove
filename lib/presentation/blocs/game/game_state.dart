// presentation/blocs/game/game_state.dart
part of 'game_bloc.dart';

abstract class GameState extends Equatable {
  const GameState();

  @override
  List<Object?> get props => [];
}

class GameInitial extends GameState {}

class GameSearchLoading extends GameState {}

class GameSearchLoaded extends GameState {
  final List<Game> games;
  final bool hasReachedMax;
  final bool isLoadingMore;
  final String currentQuery;

  const GameSearchLoaded({
    required this.games,
    required this.hasReachedMax,
    required this.currentQuery,
    this.isLoadingMore = false,
  });

  GameSearchLoaded copyWith({
    List<Game>? games,
    bool? hasReachedMax,
    bool? isLoadingMore,
    String? currentQuery,
  }) {
    return GameSearchLoaded(
      games: games ?? this.games,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      currentQuery: currentQuery ?? this.currentQuery,
    );
  }

  @override
  List<Object> get props => [games, hasReachedMax, isLoadingMore, currentQuery];
}

class GameDetailsLoading extends GameState {}

class GameDetailsLoaded extends GameState {
  final Game game;

  const GameDetailsLoaded(this.game);

  @override
  List<Object> get props => [game];
}

class GameError extends GameState {
  final String message;

  const GameError(this.message);

  @override
  List<Object> get props => [message];
}