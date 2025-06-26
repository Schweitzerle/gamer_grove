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

// Toggle Recommendation Event
class ToggleRecommendEvent extends GameEvent {
  final int gameId;
  final String userId;

  const ToggleRecommendEvent({
    required this.gameId,
    required this.userId,
  });

  @override
  List<Object> get props => [gameId, userId];
}

class AddToTopThreeEvent extends GameEvent {
  final int gameId;
  final String userId;
  final int? position; // Add position parameter

  const AddToTopThreeEvent({
    required this.gameId,
    required this.userId,
    this.position,
  });

  @override
  List<Object?> get props => [gameId, userId, position];
}

class ClearSearchEvent extends GameEvent {}

// NEW EVENTS FOR HOME PAGE
class LoadPopularGamesEvent extends GameEvent {
  final int limit;
  final int offset;

  const LoadPopularGamesEvent({
    this.limit = 20,
    this.offset = 0,
  });

  @override
  List<Object> get props => [limit, offset];
}

class LoadUpcomingGamesEvent extends GameEvent {
  final int limit;
  final int offset;

  const LoadUpcomingGamesEvent({
    this.limit = 20,
    this.offset = 0,
  });

  @override
  List<Object> get props => [limit, offset];
}

class LoadUserRatedEvent extends GameEvent {
  final String userId;

  const LoadUserRatedEvent(this.userId);

  @override
  List<Object> get props => [userId];
}

class LoadUserTopThreeEvent extends GameEvent {
  final String userId;

  const LoadUserTopThreeEvent(this.userId);

  @override
  List<Object> get props => [userId];
}

class LoadUserWishlistEvent extends GameEvent {
  final String userId;

  const LoadUserWishlistEvent(this.userId);

  @override
  List<Object> get props => [userId];
}

class LoadUserRecommendationsEvent extends GameEvent {
  final String userId;

  const LoadUserRecommendationsEvent(this.userId);

  @override
  List<Object> get props => [userId];
}

class GetGameDetailsWithUserDataEvent extends GameEvent {
  final int gameId;
  final String? userId; // Optional for logged-in users

  const GetGameDetailsWithUserDataEvent({
    required this.gameId,
    this.userId,
  });

  @override
  List<Object?> get props => [gameId, userId];
}


class LoadGameWithUserDataEvent extends GameEvent {
  final int gameId;
  final String? userId;

  const LoadGameWithUserDataEvent({
    required this.gameId,
    this.userId,
  });

  @override
  List<Object?> get props => [gameId, userId];
}

class LoadHomePageDataEvent extends GameEvent {
  final String? userId;

  const LoadHomePageDataEvent({this.userId});

  @override
  List<Object?> get props => [userId];
}

class LoadGrovePageDataEvent extends GameEvent {
  final String? userId;

  const LoadGrovePageDataEvent({this.userId});

  @override
  List<Object?> get props => [userId];
}
