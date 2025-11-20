// presentation/blocs/game/game_event.dart
part of 'game_bloc.dart';

abstract class GameEvent extends Equatable {
  const GameEvent();

  @override
  List<Object?> get props => [];
}

class SearchGamesEvent extends GameEvent {

  const SearchGamesEvent(this.query, {this.userId});
  final String query;
  final String? userId;

  @override
  List<Object?> get props => [query, userId];
}

class LoadMoreGamesEvent extends GameEvent {}

class GetGameDetailsEvent extends GameEvent {

  const GetGameDetailsEvent(this.gameId);
  final int gameId;

  @override
  List<Object> get props => [gameId];
}

class RateGameEvent extends GameEvent {

  const RateGameEvent({
    required this.gameId,
    required this.userId,
    required this.rating,
  });
  final int gameId;
  final String userId;
  final double rating;

  @override
  List<Object> get props => [gameId, userId, rating];
}

class RemoveRatingEvent extends GameEvent {

  const RemoveRatingEvent({
    required this.gameId,
    required this.userId,
  });
  final int gameId;
  final String userId;

  @override
  List<Object> get props => [gameId, userId];
}

class ToggleWishlistEvent extends GameEvent {

  const ToggleWishlistEvent({
    required this.gameId,
    required this.userId,
  });
  final int gameId;
  final String userId;

  @override
  List<Object> get props => [gameId, userId];
}

// Toggle Recommendation Event
class ToggleRecommendEvent extends GameEvent {

  const ToggleRecommendEvent({
    required this.gameId,
    required this.userId,
  });
  final int gameId;
  final String userId;

  @override
  List<Object> get props => [gameId, userId];
}

class AddToTopThreeEvent extends GameEvent {

  const AddToTopThreeEvent({
    required this.gameId,
    required this.userId,
    required this.position,
  });
  final int gameId;
  final String userId;
  final int position;

  @override
  List<Object?> get props => [gameId, userId, position];
}

class UpdateTopThreeEvent extends GameEvent {

  const UpdateTopThreeEvent({
    required this.userId,
  });
  final String userId;

  @override
  List<Object> get props => [userId];
}

class RemoveFromTopThreeEvent extends GameEvent {

  const RemoveFromTopThreeEvent({
    required this.userId,
    required this.gameId,
  });
  final String userId;
  final int gameId;

  @override
  List<Object> get props => [userId, gameId];
}

class ClearSearchEvent extends GameEvent {}

// NEW EVENTS FOR HOME PAGE
class LoadPopularGamesEvent extends GameEvent {

  const LoadPopularGamesEvent({
    this.limit = 20,
    this.offset = 0,
  });
  final int limit;
  final int offset;

  @override
  List<Object> get props => [limit, offset];
}

class LoadUpcomingGamesEvent extends GameEvent {

  const LoadUpcomingGamesEvent({
    this.limit = 20,
    this.offset = 0,
  });
  final int limit;
  final int offset;

  @override
  List<Object> get props => [limit, offset];
}

class LoadLatestGamesEvent extends GameEvent {

  const LoadLatestGamesEvent({
    this.limit = 20,
    this.offset = 0,
  });
  final int limit;
  final int offset;

  @override
  List<Object> get props => [limit, offset];
}

class LoadTopRatedGamesEvent extends GameEvent {

  const LoadTopRatedGamesEvent({
    this.limit = 20,
    this.offset = 0,
  });
  final int limit;
  final int offset;

  @override
  List<Object> get props => [limit, offset];
}

class LoadUserRatedEvent extends GameEvent {

  const LoadUserRatedEvent(this.userId);
  final String userId;

  @override
  List<Object> get props => [userId];
}

class LoadUserTopThreeEvent extends GameEvent {

  const LoadUserTopThreeEvent(this.userId);
  final String userId;

  @override
  List<Object> get props => [userId];
}

class LoadUserWishlistEvent extends GameEvent {

  const LoadUserWishlistEvent(this.userId);
  final String userId;

  @override
  List<Object> get props => [userId];
}

class LoadUserRecommendationsEvent extends GameEvent {

  const LoadUserRecommendationsEvent(this.userId);
  final String userId;

  @override
  List<Object> get props => [userId];
}

class GetGameDetailsWithUserDataEvent extends GameEvent { // Optional for logged-in users

  const GetGameDetailsWithUserDataEvent({
    required this.gameId,
    this.userId,
  });
  final int gameId;
  final String? userId;

  @override
  List<Object?> get props => [gameId, userId];
}

class LoadHomePageDataEvent extends GameEvent {

  const LoadHomePageDataEvent({this.userId});
  final String? userId;

  @override
  List<Object?> get props => [userId];
}

class LoadGrovePageDataEvent extends GameEvent {

  const LoadGrovePageDataEvent({this.userId});
  final String? userId;

  @override
  List<Object?> get props => [userId];
}

class GetSimilarGamesEvent extends GameEvent {

  const GetSimilarGamesEvent({required this.gameId});
  final int gameId;

  @override
  List<Object> get props => [gameId];
}

class GetGameDLCsEvent extends GameEvent {

  const GetGameDLCsEvent({required this.gameId});
  final int gameId;

  @override
  List<Object> get props => [gameId];
}

class GetGameExpansionsEvent extends GameEvent {

  const GetGameExpansionsEvent({required this.gameId});
  final int gameId;

  @override
  List<Object> get props => [gameId];
}

class GetCompleteGameDetailsEvent extends GameEvent {

  const GetCompleteGameDetailsEvent({
    required this.gameId,
    this.userId,
  });
  final int gameId;
  final String? userId;

  @override
  List<Object?> get props => [gameId, userId];
}

class LoadGameWithUserDataEvent extends GameEvent {

  const LoadGameWithUserDataEvent({
    required this.gameId,
    this.userId,
  });
  final int gameId;
  final String? userId;

  @override
  List<Object?> get props => [gameId, userId];
}

// ============================================================================
// NEW EVENTS for "View All" functionality
// ============================================================================

// Add these events to your game_event.dart file:

/// Load complete franchise games (for "View All" screens)
class LoadCompleteFranchiseGamesEvent extends GameEvent {

  const LoadCompleteFranchiseGamesEvent({
    required this.franchiseId,
    required this.franchiseName,
    required this.games, // ✅ Bereits vorhandene Games
    this.userId,
  });
  final int franchiseId;
  final String franchiseName;
  final List<Game> games; // ✅ Games direkt übergeben, nicht laden
  final String? userId;

  @override
  List<Object?> get props => [franchiseId, franchiseName, games, userId];
}

/// Load complete collection games (for "View All" screens)
class LoadCompleteCollectionGamesEvent extends GameEvent {

  const LoadCompleteCollectionGamesEvent({
    required this.collectionId,
    required this.collectionName,
    required this.games, // ✅ Bereits vorhandene Games
    this.userId,
  });
  final int collectionId;
  final String collectionName;
  final List<Game> games; // ✅ Games direkt übergeben
  final String? userId;

  @override
  List<Object?> get props => [collectionId, collectionName, games, userId];
}

/// Load complete similar games (for "View All" screens)
class LoadCompleteSimilarGamesEvent extends GameEvent {

  const LoadCompleteSimilarGamesEvent({
    required this.gameId,
    required this.gameName,
    this.userId,
  });
  final int gameId;
  final String gameName;
  final String? userId;

  @override
  List<Object?> get props => [gameId, gameName, userId];
}

/// Load complete game series (DLCs + Expansions + Remakes, etc.)
class LoadCompleteGameSeriesEvent extends GameEvent {

  const LoadCompleteGameSeriesEvent({
    required this.gameId,
    required this.gameName,
    this.userId,
  });
  final int gameId;
  final String gameName;
  final String? userId;

  @override
  List<Object?> get props => [gameId, gameName, userId];
}

// ⚡ NEUE EVENTS
class LoadFranchiseGamesPreviewEvent extends GameEvent {

  const LoadFranchiseGamesPreviewEvent({
    required this.franchiseId,
    required this.franchiseName,
  });
  final int franchiseId;
  final String franchiseName;

  @override
  List<Object> get props => [franchiseId, franchiseName];
}

class LoadCollectionGamesPreviewEvent extends GameEvent {

  const LoadCollectionGamesPreviewEvent({
    required this.collectionId,
    required this.collectionName,
  });
  final int collectionId;
  final String collectionName;

  @override
  List<Object> get props => [collectionId, collectionName];
}

class LoadAllFranchiseGamesEvent extends GameEvent {

  const LoadAllFranchiseGamesEvent({
    required this.franchiseId,
    required this.franchiseName,
    this.userId,
  });
  final int franchiseId;
  final String franchiseName;
  final String? userId;

  @override
  List<Object?> get props => [franchiseId, franchiseName, userId];
}

/// Event to refresh the current state with applied cache
/// This is useful when returning from a detail screen to ensure
/// that any changes made are reflected in the list views
class RefreshCacheEvent extends GameEvent {}

class LoadAllCollectionGamesEvent extends GameEvent {

  const LoadAllCollectionGamesEvent({
    required this.collectionId,
    required this.collectionName,
    this.userId,
  });
  final int collectionId;
  final String collectionName;
  final String? userId;

  @override
  List<Object?> get props => [collectionId, collectionName, userId];
}

class LoadAllUserRatedEvent extends GameEvent {

  const LoadAllUserRatedEvent(this.userId);
  final String userId;

  @override
  List<Object> get props => [userId];
}

class LoadAllUserRatedGameIdsEvent extends GameEvent {

  const LoadAllUserRatedGameIdsEvent(this.userId);
  final String userId;

  @override
  List<Object> get props => [userId];
}

class LoadUserRatedGamesPageEvent extends GameEvent {

  const LoadUserRatedGamesPageEvent(this.gameIds, this.page);
  final List<int> gameIds;
  final int page;

  @override
  List<Object> get props => [gameIds, page];
}

class LoadAllUserWishlistGameIdsEvent extends GameEvent {

  const LoadAllUserWishlistGameIdsEvent(this.userId);
  final String userId;

  @override
  List<Object> get props => [userId];
}

class LoadUserWishlistGamesPageEvent extends GameEvent {

  const LoadUserWishlistGamesPageEvent(this.gameIds, this.page);
  final List<int> gameIds;
  final int page;

  @override
  List<Object> get props => [gameIds, page];
}

class LoadAllUserRecommendedGameIdsEvent extends GameEvent {

  const LoadAllUserRecommendedGameIdsEvent(this.userId);
  final String userId;

  @override
  List<Object> get props => [userId];
}

class LoadUserRecommendedGamesPageEvent extends GameEvent {

  const LoadUserRecommendedGamesPageEvent(this.gameIds, this.page);
  final List<int> gameIds;
  final int page;

  @override
  List<Object> get props => [gameIds, page];
}

class LoadAllUserWishlistEvent extends GameEvent {

  const LoadAllUserWishlistEvent(this.userId);
  final String userId;

  @override
  List<Object> get props => [userId];
}

class LoadAllUserRecommendationsEvent extends GameEvent {

  const LoadAllUserRecommendationsEvent(this.userId);
  final String userId;

  @override
  List<Object> get props => [userId];
}

class LoadAllUserRatedPaginated extends GameEvent {

  const LoadAllUserRatedPaginated(this.userId);
  final String userId;

  @override
  List<Object> get props => [userId];
}

class LoadMoreUserRatedPaginated extends GameEvent {

  const LoadMoreUserRatedPaginated(this.userId);
  final String userId;

  @override
  List<Object> get props => [userId];
}

// Wishlist Paginated
class LoadAllUserWishlistPaginated extends GameEvent {
  const LoadAllUserWishlistPaginated(this.userId);
  final String userId;
  @override
  List<Object> get props => [userId];
}

class LoadMoreUserWishlistPaginated extends GameEvent {
  const LoadMoreUserWishlistPaginated(this.userId);
  final String userId;
  @override
  List<Object> get props => [userId];
}

// Recommended Paginated
class LoadAllUserRecommendedPaginated extends GameEvent {
  const LoadAllUserRecommendedPaginated(this.userId);
  final String userId;
  @override
  List<Object> get props => [userId];
}

class LoadMoreUserRecommendedPaginated extends GameEvent {
  const LoadMoreUserRecommendedPaginated(this.userId);
  final String userId;
  @override
  List<Object> get props => [userId];
}