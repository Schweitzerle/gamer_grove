// presentation/blocs/user_game_data/user_game_data_event.dart
part of 'user_game_data_bloc.dart';

abstract class UserGameDataEvent extends Equatable {
  const UserGameDataEvent();

  @override
  List<Object?> get props => [];
}

/// Load all user game data for a user
class LoadUserGameDataEvent extends UserGameDataEvent {

  const LoadUserGameDataEvent(this.userId);
  final String userId;

  @override
  List<Object> get props => [userId];
}

/// Toggle wishlist for a game
class ToggleWishlistEvent extends UserGameDataEvent {

  const ToggleWishlistEvent({
    required this.userId,
    required this.gameId,
  });
  final String userId;
  final int gameId;

  @override
  List<Object> get props => [userId, gameId];
}

/// Toggle recommendation for a game
class ToggleRecommendationEvent extends UserGameDataEvent {

  const ToggleRecommendationEvent({
    required this.userId,
    required this.gameId,
  });
  final String userId;
  final int gameId;

  @override
  List<Object> get props => [userId, gameId];
}

/// Rate a game
class RateGameEvent extends UserGameDataEvent {

  const RateGameEvent({
    required this.userId,
    required this.gameId,
    required this.rating,
  });
  final String userId;
  final int gameId;
  final double rating;

  @override
  List<Object> get props => [userId, gameId, rating];
}

/// Remove rating from a game
class RemoveRatingEvent extends UserGameDataEvent {

  const RemoveRatingEvent({
    required this.userId,
    required this.gameId,
  });
  final String userId;
  final int gameId;

  @override
  List<Object> get props => [userId, gameId];
}

/// Update top three games
class UpdateTopThreeEvent extends UserGameDataEvent {

  const UpdateTopThreeEvent({
    required this.userId,
    required this.gameIds,
  });
  final String userId;
  final List<int> gameIds;

  @override
  List<Object> get props => [userId, gameIds];
}

/// Set a game at a specific position in the user's top three
class SetGameTopThreePositionEvent extends UserGameDataEvent { // 1, 2, or 3

  const SetGameTopThreePositionEvent({
    required this.userId,
    required this.gameId,
    required this.position,
  });
  final String userId;
  final int gameId;
  final int position;

  @override
  List<Object> get props => [userId, gameId, position];
}

/// Remove a game from the user's top three
class RemoveFromTopThreeEvent extends UserGameDataEvent {

  const RemoveFromTopThreeEvent({
    required this.userId,
    required this.gameId,
  });
  final String userId;
  final int gameId;

  @override
  List<Object> get props => [userId, gameId];
}

/// Clear user game data (logout)
class ClearUserGameDataEvent extends UserGameDataEvent {
  const ClearUserGameDataEvent();
}

/// Refresh user game data from backend
class RefreshUserGameDataEvent extends UserGameDataEvent {

  const RefreshUserGameDataEvent(this.userId);
  final String userId;

  @override
  List<Object> get props => [userId];
}
