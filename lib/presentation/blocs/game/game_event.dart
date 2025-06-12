// presentation/blocs/game/game_event.dart
part of 'game_bloc.dart';

abstract class GameEvent extends Equatable {
  const GameEvent();

  @override
  List<Object?> get props => [];
}

class SearchGamesEvent extends GameEvent {
  final String query;

  const SearchGamesEvent(this.query);

  @override
  List<Object> get props => [query];
}

class LoadMoreGamesEvent extends GameEvent {}

class GetGameDetailsEvent extends GameEvent {
  final int gameId;

  const GetGameDetailsEvent(this.gameId);

  @override
  List<Object> get props => [gameId];
}

class RateGameEvent extends GameEvent {
  final int gameId;
  final String userId;
  final double rating;

  const RateGameEvent({
    required this.gameId,
    required this.userId,
    required this.rating,
  });

  @override
  List<Object> get props => [gameId, userId, rating];
}

class ToggleWishlistEvent extends GameEvent {
  final int gameId;
  final String userId;

  const ToggleWishlistEvent({
    required this.gameId,
    required this.userId,
  });

  @override
  List<Object> get props => [gameId, userId];
}

class ClearSearchEvent extends GameEvent {}

