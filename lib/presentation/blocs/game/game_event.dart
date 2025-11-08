// presentation/blocs/game/game_event.dart
part of 'game_bloc.dart';

abstract class GameEvent extends Equatable {
  const GameEvent();

  @override
  List<Object?> get props => [];
}

class SearchGamesEvent extends GameEvent {
  final String query;
  final String? userId;

  const SearchGamesEvent(this.query, {this.userId});

  @override
  List<Object?> get props => [query, userId];
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
  final int position;

  const AddToTopThreeEvent({
    required this.gameId,
    required this.userId,
    required this.position,
  });

  @override
  List<Object?> get props => [gameId, userId, position];
}

class UpdateTopThreeEvent extends GameEvent {
  final String userId;

  const UpdateTopThreeEvent({
    required this.userId,
  });

  @override
  List<Object> get props => [userId];
}

class RemoveFromTopThreeEvent extends GameEvent {
  final String userId;
  final int gameId;

  const RemoveFromTopThreeEvent({
    required this.userId,
    required this.gameId,
  });

  @override
  List<Object> get props => [userId, gameId];
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

class LoadLatestGamesEvent extends GameEvent {
  final int limit;
  final int offset;

  const LoadLatestGamesEvent({
    this.limit = 20,
    this.offset = 0,
  });

  @override
  List<Object> get props => [limit, offset];
}

class LoadTopRatedGamesEvent extends GameEvent {
  final int limit;
  final int offset;

  const LoadTopRatedGamesEvent({
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

class GetSimilarGamesEvent extends GameEvent {
  final int gameId;

  const GetSimilarGamesEvent({required this.gameId});

  @override
  List<Object> get props => [gameId];
}

class GetGameDLCsEvent extends GameEvent {
  final int gameId;

  const GetGameDLCsEvent({required this.gameId});

  @override
  List<Object> get props => [gameId];
}

class GetGameExpansionsEvent extends GameEvent {
  final int gameId;

  const GetGameExpansionsEvent({required this.gameId});

  @override
  List<Object> get props => [gameId];
}

class GetCompleteGameDetailsEvent extends GameEvent {
  final int gameId;
  final String? userId;

  const GetCompleteGameDetailsEvent({
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

// ============================================================================
// NEW EVENTS for "View All" functionality
// ============================================================================

// Add these events to your game_event.dart file:

/// Load complete franchise games (for "View All" screens)
class LoadCompleteFranchiseGamesEvent extends GameEvent {
  final int franchiseId;
  final String franchiseName;
  final List<Game> games; // ✅ Games direkt übergeben, nicht laden
  final String? userId;

  const LoadCompleteFranchiseGamesEvent({
    required this.franchiseId,
    required this.franchiseName,
    required this.games, // ✅ Bereits vorhandene Games
    this.userId,
  });

  @override
  List<Object?> get props => [franchiseId, franchiseName, games, userId];
}

/// Load complete collection games (for "View All" screens)
class LoadCompleteCollectionGamesEvent extends GameEvent {
  final int collectionId;
  final String collectionName;
  final List<Game> games; // ✅ Games direkt übergeben
  final String? userId;

  const LoadCompleteCollectionGamesEvent({
    required this.collectionId,
    required this.collectionName,
    required this.games, // ✅ Bereits vorhandene Games
    this.userId,
  });

  @override
  List<Object?> get props => [collectionId, collectionName, games, userId];
}

/// Load complete similar games (for "View All" screens)
class LoadCompleteSimilarGamesEvent extends GameEvent {
  final int gameId;
  final String gameName;
  final String? userId;

  const LoadCompleteSimilarGamesEvent({
    required this.gameId,
    required this.gameName,
    this.userId,
  });

  @override
  List<Object?> get props => [gameId, gameName, userId];
}

/// Load complete game series (DLCs + Expansions + Remakes, etc.)
class LoadCompleteGameSeriesEvent extends GameEvent {
  final int gameId;
  final String gameName;
  final String? userId;

  const LoadCompleteGameSeriesEvent({
    required this.gameId,
    required this.gameName,
    this.userId,
  });

  @override
  List<Object?> get props => [gameId, gameName, userId];
}

// ⚡ NEUE EVENTS
class LoadFranchiseGamesPreviewEvent extends GameEvent {
  final int franchiseId;
  final String franchiseName;

  const LoadFranchiseGamesPreviewEvent({
    required this.franchiseId,
    required this.franchiseName,
  });

  @override
  List<Object> get props => [franchiseId, franchiseName];
}

class LoadCollectionGamesPreviewEvent extends GameEvent {
  final int collectionId;
  final String collectionName;

  const LoadCollectionGamesPreviewEvent({
    required this.collectionId,
    required this.collectionName,
  });

  @override
  List<Object> get props => [collectionId, collectionName];
}

class LoadAllFranchiseGamesEvent extends GameEvent {
  final int franchiseId;
  final String franchiseName;
  final String? userId;

  const LoadAllFranchiseGamesEvent({
    required this.franchiseId,
    required this.franchiseName,
    this.userId,
  });

  @override
  List<Object?> get props => [franchiseId, franchiseName, userId];
}

/// Event to refresh the current state with applied cache
/// This is useful when returning from a detail screen to ensure
/// that any changes made are reflected in the list views
class RefreshCacheEvent extends GameEvent {}

class LoadAllCollectionGamesEvent extends GameEvent {
  final int collectionId;
  final String collectionName;
  final String? userId;

  const LoadAllCollectionGamesEvent({
    required this.collectionId,
    required this.collectionName,
    this.userId,
  });

  @override
  List<Object?> get props => [collectionId, collectionName, userId];
}

class LoadAllUserRatedEvent extends GameEvent {
  final String userId;

  const LoadAllUserRatedEvent(this.userId);

  @override
  List<Object> get props => [userId];
}

class LoadAllUserRatedGameIdsEvent extends GameEvent {
  final String userId;

  const LoadAllUserRatedGameIdsEvent(this.userId);

  @override
  List<Object> get props => [userId];
}

class LoadUserRatedGamesPageEvent extends GameEvent {
  final List<int> gameIds;
  final int page;

  const LoadUserRatedGamesPageEvent(this.gameIds, this.page);

  @override
  List<Object> get props => [gameIds, page];
}

class LoadAllUserWishlistGameIdsEvent extends GameEvent {
  final String userId;

  const LoadAllUserWishlistGameIdsEvent(this.userId);

  @override
  List<Object> get props => [userId];
}

class LoadUserWishlistGamesPageEvent extends GameEvent {
  final List<int> gameIds;
  final int page;

  const LoadUserWishlistGamesPageEvent(this.gameIds, this.page);

  @override
  List<Object> get props => [gameIds, page];
}

class LoadAllUserRecommendedGameIdsEvent extends GameEvent {
  final String userId;

  const LoadAllUserRecommendedGameIdsEvent(this.userId);

  @override
  List<Object> get props => [userId];
}

class LoadUserRecommendedGamesPageEvent extends GameEvent {
  final List<int> gameIds;
  final int page;

  const LoadUserRecommendedGamesPageEvent(this.gameIds, this.page);

  @override
  List<Object> get props => [gameIds, page];
}

class LoadAllUserWishlistEvent extends GameEvent {
  final String userId;

  const LoadAllUserWishlistEvent(this.userId);

  @override
  List<Object> get props => [userId];
}

class LoadAllUserRecommendationsEvent extends GameEvent {
  final String userId;

  const LoadAllUserRecommendationsEvent(this.userId);

  @override
  List<Object> get props => [userId];
}

class LoadAllUserRatedPaginated extends GameEvent {
  final String userId;

  const LoadAllUserRatedPaginated(this.userId);

  @override
  List<Object> get props => [userId];
}

class LoadMoreUserRatedPaginated extends GameEvent {
  final String userId;

  const LoadMoreUserRatedPaginated(this.userId);

  @override
  List<Object> get props => [userId];
}

// Wishlist Paginated
class LoadAllUserWishlistPaginated extends GameEvent {
  final String userId;
  const LoadAllUserWishlistPaginated(this.userId);
  @override
  List<Object> get props => [userId];
}

class LoadMoreUserWishlistPaginated extends GameEvent {
  final String userId;
  const LoadMoreUserWishlistPaginated(this.userId);
  @override
  List<Object> get props => [userId];
}

// Recommended Paginated
class LoadAllUserRecommendedPaginated extends GameEvent {
  final String userId;
  const LoadAllUserRecommendedPaginated(this.userId);
  @override
  List<Object> get props => [userId];
}

class LoadMoreUserRecommendedPaginated extends GameEvent {
  final String userId;
  const LoadMoreUserRecommendedPaginated(this.userId);
  @override
  List<Object> get props => [userId];
}