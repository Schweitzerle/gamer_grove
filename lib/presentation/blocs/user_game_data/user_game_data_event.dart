// presentation/blocs/user_game_data/user_game_data_event.dart
part of 'user_game_data_bloc.dart';

abstract class UserGameDataEvent extends Equatable {
  const UserGameDataEvent();

  @override
  List<Object?> get props => [];
}

/// Load all user game data for a user
class LoadUserGameDataEvent extends UserGameDataEvent {
  final String userId;

  const LoadUserGameDataEvent(this.userId);

  @override
  List<Object> get props => [userId];
}

/// Toggle wishlist for a game
class ToggleWishlistEvent extends UserGameDataEvent {
  final String userId;
  final int gameId;

  const ToggleWishlistEvent({
    required this.userId,
    required this.gameId,
  });

  @override
  List<Object> get props => [userId, gameId];
}

/// Toggle recommendation for a game
class ToggleRecommendationEvent extends UserGameDataEvent {
  final String userId;
  final int gameId;

  const ToggleRecommendationEvent({
    required this.userId,
    required this.gameId,
  });

  @override
  List<Object> get props => [userId, gameId];
}

/// Rate a game
class RateGameEvent extends UserGameDataEvent {
  final String userId;
  final int gameId;
  final double rating;

  const RateGameEvent({
    required this.userId,
    required this.gameId,
    required this.rating,
  });

  @override
  List<Object> get props => [userId, gameId, rating];
}

/// Remove rating from a game
class RemoveRatingEvent extends UserGameDataEvent {
  final String userId;
  final int gameId;

  const RemoveRatingEvent({
    required this.userId,
    required this.gameId,
  });

  @override
  List<Object> get props => [userId, gameId];
}

/// Update top three games
class UpdateTopThreeEvent extends UserGameDataEvent {
  final String userId;
  final List<int> gameIds;

  const UpdateTopThreeEvent({
    required this.userId,
    required this.gameIds,
  });

  @override
  List<Object> get props => [userId, gameIds];
}

/// Set a game at a specific position in the user's top three
class SetGameTopThreePositionEvent extends UserGameDataEvent {
  final String userId;
  final int gameId;
  final int position; // 1, 2, or 3

  const SetGameTopThreePositionEvent({
    required this.userId,
    required this.gameId,
    required this.position,
  });

  @override
  List<Object> get props => [userId, gameId, position];
}

/// Remove a game from the user's top three
class RemoveFromTopThreeEvent extends UserGameDataEvent {
  final String userId;
  final int gameId;

  const RemoveFromTopThreeEvent({
    required this.userId,
    required this.gameId,
  });

  @override
  List<Object> get props => [userId, gameId];
}

/// Clear user game data (logout)
class ClearUserGameDataEvent extends UserGameDataEvent {
  const ClearUserGameDataEvent();
}

/// Refresh user game data from backend
class RefreshUserGameDataEvent extends UserGameDataEvent {
  final String userId;

  const RefreshUserGameDataEvent(this.userId);

  @override
  List<Object> get props => [userId];
}
