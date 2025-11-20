// presentation/blocs/game/game_state.dart
part of 'game_bloc.dart';

abstract class GameState extends Equatable {
  const GameState();

  @override
  List<Object?> get props => [];

  // Helper getter for checking loading state
  bool get isLoadingMore => false;
  List<Game> get games => [];
}

class GameInitial extends GameState {}

// Search States
class GameSearchLoading extends GameState {}

class GameSearchLoaded extends GameState {

  const GameSearchLoaded({
    required this.games,
    required this.hasReachedMax,
    required this.currentQuery,
    this.currentFilters,
    this.isLoadingMore = false,
  });
  @override
  final List<Game> games;
  final bool hasReachedMax;
  @override
  final bool isLoadingMore;
  final String currentQuery;
  final SearchFilters? currentFilters;

  GameSearchLoaded copyWith({
    List<Game>? games,
    bool? hasReachedMax,
    bool? isLoadingMore,
    String? currentQuery,
    SearchFilters? currentFilters,
  }) {
    return GameSearchLoaded(
      games: games ?? this.games,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      currentQuery: currentQuery ?? this.currentQuery,
      currentFilters: currentFilters ?? this.currentFilters,
    );
  }

  @override
  List<Object?> get props => [
        games,
        hasReachedMax,
        isLoadingMore,
        currentQuery,
        currentFilters,
      ];
}

// Popular Games States
class PopularGamesLoading extends GameState {}

class PopularGamesLoaded extends GameState {

  const PopularGamesLoaded({
    required this.games,
    this.hasReachedMax = false,
    this.isLoadingMore = false,
  });
  @override
  final List<Game> games;
  final bool hasReachedMax;
  @override
  final bool isLoadingMore;

  PopularGamesLoaded copyWith({
    List<Game>? games,
    bool? hasReachedMax,
    bool? isLoadingMore,
  }) {
    return PopularGamesLoaded(
      games: games ?? this.games,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object> get props => [games, hasReachedMax, isLoadingMore];
}

// Upcoming Games States
class UpcomingGamesLoading extends GameState {}

class UpcomingGamesLoaded extends GameState {

  const UpcomingGamesLoaded({
    required this.games,
    this.hasReachedMax = false,
    this.isLoadingMore = false,
  });
  @override
  final List<Game> games;
  final bool hasReachedMax;
  @override
  final bool isLoadingMore;

  UpcomingGamesLoaded copyWith({
    List<Game>? games,
    bool? hasReachedMax,
    bool? isLoadingMore,
  }) {
    return UpcomingGamesLoaded(
      games: games ?? this.games,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object> get props => [games, hasReachedMax, isLoadingMore];
}

// Latest Games States
class LatestGamesLoading extends GameState {}

class LatestGamesLoaded extends GameState {

  const LatestGamesLoaded({
    required this.games,
    this.hasReachedMax = false,
    this.isLoadingMore = false,
  });
  @override
  final List<Game> games;
  final bool hasReachedMax;
  @override
  final bool isLoadingMore;

  LatestGamesLoaded copyWith({
    List<Game>? games,
    bool? hasReachedMax,
    bool? isLoadingMore,
  }) {
    return LatestGamesLoaded(
      games: games ?? this.games,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object> get props => [games, hasReachedMax, isLoadingMore];
}

// Popular Games States
class TopRatedGamesLoading extends GameState {}

class TopRatedGamesLoaded extends GameState {

  const TopRatedGamesLoaded({
    required this.games,
    this.hasReachedMax = false,
    this.isLoadingMore = false,
  });
  @override
  final List<Game> games;
  final bool hasReachedMax;
  @override
  final bool isLoadingMore;

  TopRatedGamesLoaded copyWith({
    List<Game>? games,
    bool? hasReachedMax,
    bool? isLoadingMore,
  }) {
    return TopRatedGamesLoaded(
      games: games ?? this.games,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object> get props => [games, hasReachedMax, isLoadingMore];
}

// Wishlist States
class UserWishlistLoading extends GameState {}

class UserWishlistLoaded extends GameState {

  const UserWishlistLoaded({
    required this.games,
    required this.userId,
  });
  @override
  final List<Game> games;
  final String userId;

  UserWishlistLoaded copyWith({
    List<Game>? games,
    String? userId,
  }) {
    return UserWishlistLoaded(
      games: games ?? this.games,
      userId: userId ?? this.userId,
    );
  }

  @override
  List<Object> get props => [games, userId];
}

// Recommendations States
class UserRecommendationsLoading extends GameState {}

class UserRecommendationsLoaded extends GameState {

  const UserRecommendationsLoaded({
    required this.games,
    required this.userId,
  });
  @override
  final List<Game> games;
  final String userId;

  UserRecommendationsLoaded copyWith({
    List<Game>? games,
    String? userId,
  }) {
    return UserRecommendationsLoaded(
      games: games ?? this.games,
      userId: userId ?? this.userId,
    );
  }

  @override
  List<Object> get props => [games, userId];
}

//rated states
class UserRatedLoading extends GameState {}

class UserRatedLoaded extends GameState {

  const UserRatedLoaded({
    required this.games,
    required this.userId,
  });
  @override
  final List<Game> games;
  final String userId;

  UserRatedLoaded copyWith({
    List<Game>? games,
    String? userId,
  }) {
    return UserRatedLoaded(
      games: games ?? this.games,
      userId: userId ?? this.userId,
    );
  }

  @override
  List<Object> get props => [games, userId];
}

//top three states
class UserTopThreeLoading extends GameState {}

class UserTopThreeLoaded extends GameState {

  const UserTopThreeLoaded({
    required this.games,
    required this.userId,
  });
  @override
  final List<Game> games;
  final String userId;

  @override
  List<Object> get props => [games, userId];
}

// Game Details States
class GameDetailsLoading extends GameState {}

class GameDetailsLoaded extends GameState {

  const GameDetailsLoaded(this.game);
  final Game game;

  @override
  List<Object> get props => [game];
}

// Error State
class GameError extends GameState { // Keep existing games on error

  const GameError(this.message, {this.games = const []});
  final String message;
  @override
  final List<Game> games;

  @override
  List<Object> get props => [message, games];
}

// Multi-state for home page (combining multiple data sources)
class HomePageDataLoaded extends GameState {

  const HomePageDataLoaded({
    this.popularGames = const [],
    this.upcomingGames = const [],
    this.userWishlist,
    this.userRecommendations,
    this.isLoading = false,
  });
  final List<Game> popularGames;
  final List<Game> upcomingGames;
  final List<Game>? userWishlist;
  final List<Game>? userRecommendations;
  final bool isLoading;

  HomePageDataLoaded copyWith({
    List<Game>? popularGames,
    List<Game>? upcomingGames,
    List<Game>? userWishlist,
    List<Game>? userRecommendations,
    bool? isLoading,
  }) {
    return HomePageDataLoaded(
      popularGames: popularGames ?? this.popularGames,
      upcomingGames: upcomingGames ?? this.upcomingGames,
      userWishlist: userWishlist ?? this.userWishlist,
      userRecommendations: userRecommendations ?? this.userRecommendations,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [
        popularGames,
        upcomingGames,
        userWishlist,
        userRecommendations,
        isLoading,
      ];
}

class GameDetailsWithUserDataLoaded extends GameState {

  const GameDetailsWithUserDataLoaded({
    required this.game,
    this.isWishlisted = false,
    this.isRecommended = false,
    this.userRating,
    this.isInTopThree = false,
    this.userTopThreeGames = const [],
  });
  final Game game;
  final bool isWishlisted;
  final bool isRecommended;
  final double? userRating;
  final bool isInTopThree;
  final List<int> userTopThreeGames;

  GameDetailsWithUserDataLoaded copyWith({
    Game? game,
    bool? isWishlisted,
    bool? isRecommended,
    double? userRating,
    bool? isInTopThree,
    List<int>? userTopThreeGames,
  }) {
    return GameDetailsWithUserDataLoaded(
      game: game ?? this.game,
      isWishlisted: isWishlisted ?? this.isWishlisted,
      isRecommended: isRecommended ?? this.isRecommended,
      userRating: userRating ?? this.userRating,
      isInTopThree: isInTopThree ?? this.isInTopThree,
      userTopThreeGames: userTopThreeGames ?? this.userTopThreeGames,
    );
  }

  @override
  List<Object?> get props => [
        game,
        isWishlisted,
        isRecommended,
        userRating,
        isInTopThree,
        userTopThreeGames,
      ];
}

// Home Page States
class HomePageLoading extends GameState {}

class HomePageLoaded extends GameState {

  const HomePageLoaded({
    required this.popularGames,
    required this.upcomingGames,
    required this.latestGames,
    required this.topRatedGames,
    this.userWishlist,
    this.userRecommendations,
    this.upcomingEvents = const [],
  });
  final List<Game> popularGames;
  final List<Game> upcomingGames;
  final List<Game> latestGames;
  final List<Game> topRatedGames;
  final List<Game>? userWishlist;
  final List<Game>? userRecommendations;
  final List<Event> upcomingEvents;

  // copyWith Methode hinzufügen
  HomePageLoaded copyWith({
    List<Game>? popularGames,
    List<Game>? upcomingGames,
    List<Game>? latestGames,
    List<Game>? topRatedGames,
    List<Game>? userWishlist,
    List<Game>? userRecommendations,
    List<Event>? upcomingEvents,
  }) {
    return HomePageLoaded(
      popularGames: popularGames ?? this.popularGames,
      upcomingGames: upcomingGames ?? this.upcomingGames,
      latestGames: latestGames ?? this.latestGames,
      topRatedGames: topRatedGames ?? this.topRatedGames,
      userWishlist: userWishlist ?? this.userWishlist,
      userRecommendations: userRecommendations ?? this.userRecommendations,
      upcomingEvents: upcomingEvents ?? this.upcomingEvents,
    );
  }

  @override
  List<Object?> get props => [
        popularGames,
        upcomingGames,
        latestGames,
        topRatedGames,
        userWishlist,
        userRecommendations,
        upcomingEvents,
      ];
}

class GrovePageLoading extends GameState {}

class GrovePageLoaded extends GameState {

  const GrovePageLoaded({
    required this.userRated,
    required this.userWishlist,
    required this.userRecommendations,
    required this.userTopThree,
  });
  final List<Game> userRated;
  final List<Game> userWishlist;
  final List<Game> userRecommendations;
  final List<Game> userTopThree;

  @override
  List<Object> get props => [
        userRated,
        userWishlist,
        userRecommendations,
        userTopThree,
      ];

  // Optional: copyWith method für State updates
  GrovePageLoaded copyWith({
    List<Game>? userRated,
    List<Game>? userWishlist,
    List<Game>? userRecommendations,
    List<Game>? userTopThree,
  }) {
    return GrovePageLoaded(
      userRated: userRated ?? this.userRated,
      userWishlist: userWishlist ?? this.userWishlist,
      userRecommendations: userRecommendations ?? this.userRecommendations,
      userTopThree: userTopThree ?? this.userTopThree,
    );
  }
}

class SimilarGamesLoaded extends GameState {

  const SimilarGamesLoaded(this.games);
  @override
  final List<Game> games;

  SimilarGamesLoaded copyWith({
    List<Game>? games,
  }) {
    return SimilarGamesLoaded(games ?? this.games);
  }

  @override
  List<Object> get props => [games];
}

class GameDLCsLoaded extends GameState {

  const GameDLCsLoaded(this.dlcs);
  final List<Game> dlcs;

  @override
  List<Object> get props => [dlcs];
}

class GameExpansionsLoaded extends GameState {

  const GameExpansionsLoaded(this.expansions);
  final List<Game> expansions;

  @override
  List<Object> get props => [expansions];
}

// ============================================================================
// NEW STATES for "View All" functionality
// ============================================================================

// Add these states to your game_state.dart file:

/// Complete franchise games loaded (for "View All" screens)
class CompleteFranchiseGamesLoaded extends GameState {

  const CompleteFranchiseGamesLoaded({
    required this.franchiseId,
    required this.franchiseName,
    required this.games,
    this.hasMore = false,
    this.currentPage = 0,
  });
  final int franchiseId;
  final String franchiseName;
  @override
  final List<Game> games;
  final bool hasMore;
  final int currentPage;

  CompleteFranchiseGamesLoaded copyWith({
    int? franchiseId,
    String? franchiseName,
    List<Game>? games,
    bool? hasMore,
    int? currentPage,
  }) {
    return CompleteFranchiseGamesLoaded(
      franchiseId: franchiseId ?? this.franchiseId,
      franchiseName: franchiseName ?? this.franchiseName,
      games: games ?? this.games,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  @override
  List<Object> get props =>
      [franchiseId, franchiseName, games, hasMore, currentPage];
}

/// Complete collection games loaded (for "View All" screens)
class CompleteCollectionGamesLoaded extends GameState {

  const CompleteCollectionGamesLoaded({
    required this.collectionId,
    required this.collectionName,
    required this.games,
    this.hasMore = false,
    this.currentPage = 0,
  });
  final int collectionId;
  final String collectionName;
  @override
  final List<Game> games;
  final bool hasMore;
  final int currentPage;

  CompleteCollectionGamesLoaded copyWith({
    int? collectionId,
    String? collectionName,
    List<Game>? games,
    bool? hasMore,
    int? currentPage,
  }) {
    return CompleteCollectionGamesLoaded(
      collectionId: collectionId ?? this.collectionId,
      collectionName: collectionName ?? this.collectionName,
      games: games ?? this.games,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  @override
  List<Object> get props =>
      [collectionId, collectionName, games, hasMore, currentPage];
}

/// Complete similar games loaded (for "View All" screens)
class CompleteSimilarGamesLoaded extends GameState {

  const CompleteSimilarGamesLoaded({
    required this.gameId,
    required this.gameName,
    required this.games,
  });
  final int gameId;
  final String gameName;
  @override
  final List<Game> games;

  @override
  List<Object> get props => [gameId, gameName, games];
}

/// Complete game series loaded (for "View All" screens)
class CompleteGameSeriesLoaded extends GameState { // "dlcs", "expansions", etc.

  const CompleteGameSeriesLoaded({
    required this.gameId,
    required this.gameName,
    required this.gamesByCategory,
  });
  final int gameId;
  final String gameName;
  final Map<String, List<Game>> gamesByCategory;

  @override
  List<Object> get props => [gameId, gameName, gamesByCategory];
}

// ⚡ NEUE STATES
class FranchiseGamesPreviewLoaded extends GameState {

  const FranchiseGamesPreviewLoaded({
    required this.franchiseId,
    required this.franchiseName,
    required this.games,
  });
  final int franchiseId;
  final String franchiseName;
  @override
  final List<GameModel> games;

  @override
  List<Object> get props => [franchiseId, franchiseName, games];
}

class CollectionGamesPreviewLoaded extends GameState {

  const CollectionGamesPreviewLoaded({
    required this.collectionId,
    required this.collectionName,
    required this.games,
  });
  final int collectionId;
  final String collectionName;
  @override
  final List<GameModel> games;

  @override
  List<Object> get props => [collectionId, collectionName, games];
}

class AllUserRatedLoaded extends GameState {

  const AllUserRatedLoaded(this.games);
  @override
  final List<Game> games;

  @override
  List<Object> get props => [games];
}

class AllUserWishlistedLoaded extends GameState {

  const AllUserWishlistedLoaded(this.games);
  @override
  final List<Game> games;

  @override
  List<Object> get props => [games];
}

class AllUserRecommendationsLoaded extends GameState {

  const AllUserRecommendationsLoaded(this.games);
  @override
  final List<Game> games;

  @override
  List<Object> get props => [games];
}

class AllUserRatedPaginatedLoading extends GameState {}

class AllUserRatedPaginatedLoaded extends GameState {

  const AllUserRatedPaginatedLoaded({
    required this.games,
    required this.hasReachedMax,
  });
  @override
  final List<Game> games;
  final bool hasReachedMax;

  AllUserRatedPaginatedLoaded copyWith({
    List<Game>? games,
    bool? hasReachedMax,
  }) {
    return AllUserRatedPaginatedLoaded(
      games: games ?? this.games,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object> get props => [games, hasReachedMax];
}

class AllUserRatedPaginatedError extends GameState {

  const AllUserRatedPaginatedError(this.message);
  final String message;

  @override
  List<Object> get props => [message];
}

// Wishlist Paginated
class AllUserWishlistPaginatedLoading extends GameState {}

class AllUserWishlistPaginatedLoaded extends GameState {

  const AllUserWishlistPaginatedLoaded({
    required this.games,
    required this.hasReachedMax,
  });
  @override
  final List<Game> games;
  final bool hasReachedMax;

  AllUserWishlistPaginatedLoaded copyWith({
    List<Game>? games,
    bool? hasReachedMax,
  }) {
    return AllUserWishlistPaginatedLoaded(
      games: games ?? this.games,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object> get props => [games, hasReachedMax];
}

class AllUserWishlistPaginatedError extends GameState {

  const AllUserWishlistPaginatedError(this.message);
  final String message;

  @override
  List<Object> get props => [message];
}

// Recommended Paginated
class AllUserRecommendedPaginatedLoading extends GameState {}

class AllUserRecommendedPaginatedLoaded extends GameState {

  const AllUserRecommendedPaginatedLoaded({
    required this.games,
    required this.hasReachedMax,
  });
  @override
  final List<Game> games;
  final bool hasReachedMax;

  AllUserRecommendedPaginatedLoaded copyWith({
    List<Game>? games,
    bool? hasReachedMax,
  }) {
    return AllUserRecommendedPaginatedLoaded(
      games: games ?? this.games,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object> get props => [games, hasReachedMax];
}

class AllUserRecommendedPaginatedError extends GameState {

  const AllUserRecommendedPaginatedError(this.message);
  final String message;

  @override
  List<Object> get props => [message];
}