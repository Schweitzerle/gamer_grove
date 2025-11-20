// presentation/blocs/user_game_data/user_game_data_state.dart
part of 'user_game_data_bloc.dart';

/// Base state for user game data
abstract class UserGameDataState extends Equatable {
  const UserGameDataState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class UserGameDataInitial extends UserGameDataState {
  const UserGameDataInitial();
}

/// Loading state
class UserGameDataLoading extends UserGameDataState {
  const UserGameDataLoading();
}

/// Loaded state with all user game data
class UserGameDataLoaded extends UserGameDataState {

  const UserGameDataLoaded({
    required this.userId,
    required this.wishlistedGameIds,
    required this.recommendedGameIds,
    required this.ratedGames,
    required this.topThreeGameIds,
  });
  final String userId;
  final Set<int> wishlistedGameIds;
  final Set<int> recommendedGameIds;
  final Map<int, double> ratedGames; // gameId -> rating (0-10)
  final List<int> topThreeGameIds;

  /// Check if a game is wishlisted
  bool isWishlisted(int gameId) => wishlistedGameIds.contains(gameId);

  /// Check if a game is recommended
  bool isRecommended(int gameId) => recommendedGameIds.contains(gameId);

  /// Get rating for a game (null if not rated)
  double? getRating(int gameId) => ratedGames[gameId];

  /// Check if a game is in top three
  bool isInTopThree(int gameId) => topThreeGameIds.contains(gameId);

  /// Get top three position (1-3, or null if not in top three)
  int? getTopThreePosition(int gameId) {
    final index = topThreeGameIds.indexOf(gameId);
    return index >= 0 ? index + 1 : null;
  }

  /// Copy with updated data
  UserGameDataLoaded copyWith({
    String? userId,
    Set<int>? wishlistedGameIds,
    Set<int>? recommendedGameIds,
    Map<int, double>? ratedGames,
    List<int>? topThreeGameIds,
  }) {
    return UserGameDataLoaded(
      userId: userId ?? this.userId,
      wishlistedGameIds: wishlistedGameIds ?? this.wishlistedGameIds,
      recommendedGameIds: recommendedGameIds ?? this.recommendedGameIds,
      ratedGames: ratedGames ?? this.ratedGames,
      topThreeGameIds: topThreeGameIds ?? this.topThreeGameIds,
    );
  }

  @override
  List<Object?> get props => [
        userId,
        wishlistedGameIds,
        recommendedGameIds,
        ratedGames,
        topThreeGameIds,
      ];
}

/// Error state
class UserGameDataError extends UserGameDataState {

  const UserGameDataError(this.message);
  final String message;

  @override
  List<Object> get props => [message];
}

/// Action success states (for showing snackbars, etc.)
class WishlistToggled extends UserGameDataLoaded {

  const WishlistToggled({
    required this.gameId,
    required this.isNowWishlisted,
    required super.userId,
    required super.wishlistedGameIds,
    required super.recommendedGameIds,
    required super.ratedGames,
    required super.topThreeGameIds,
  });
  final int gameId;
  final bool isNowWishlisted;

  @override
  List<Object?> get props => [
        ...super.props,
        gameId,
        isNowWishlisted,
      ];
}

class RecommendationToggled extends UserGameDataLoaded {

  const RecommendationToggled({
    required this.gameId,
    required this.isNowRecommended,
    required super.userId,
    required super.wishlistedGameIds,
    required super.recommendedGameIds,
    required super.ratedGames,
    required super.topThreeGameIds,
  });
  final int gameId;
  final bool isNowRecommended;

  @override
  List<Object?> get props => [
        ...super.props,
        gameId,
        isNowRecommended,
      ];
}

class GameRated extends UserGameDataLoaded {

  const GameRated({
    required this.gameId,
    required this.rating,
    required super.userId,
    required super.wishlistedGameIds,
    required super.recommendedGameIds,
    required super.ratedGames,
    required super.topThreeGameIds,
  });
  final int gameId;
  final double rating;

  @override
  List<Object?> get props => [
        ...super.props,
        gameId,
        rating,
      ];
}

class RatingRemoved extends UserGameDataLoaded {

  const RatingRemoved({
    required this.gameId,
    required super.userId,
    required super.wishlistedGameIds,
    required super.recommendedGameIds,
    required super.ratedGames,
    required super.topThreeGameIds,
  });
  final int gameId;

  @override
  List<Object?> get props => [
        ...super.props,
        gameId,
      ];
}

class TopThreeUpdated extends UserGameDataLoaded {
  const TopThreeUpdated({
    required super.userId,
    required super.wishlistedGameIds,
    required super.recommendedGameIds,
    required super.ratedGames,
    required super.topThreeGameIds,
  });
}
