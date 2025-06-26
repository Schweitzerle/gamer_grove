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

// Popular Games States
class PopularGamesLoading extends GameState {}

class PopularGamesLoaded extends GameState {
  final List<Game> games;
  final bool hasReachedMax;
  final bool isLoadingMore;

  const PopularGamesLoaded({
    required this.games,
    this.hasReachedMax = false,
    this.isLoadingMore = false,
  });

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
  final List<Game> games;
  final bool hasReachedMax;
  final bool isLoadingMore;

  const UpcomingGamesLoaded({
    required this.games,
    this.hasReachedMax = false,
    this.isLoadingMore = false,
  });

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

// Wishlist States
class UserWishlistLoading extends GameState {}

class UserWishlistLoaded extends GameState {
  final List<Game> games;
  final String userId;

  const UserWishlistLoaded({
    required this.games,
    required this.userId,
  });

  @override
  List<Object> get props => [games, userId];
}

// Recommendations States
class UserRecommendationsLoading extends GameState {}

class UserRecommendationsLoaded extends GameState {
  final List<Game> games;
  final String userId;

  const UserRecommendationsLoaded({
    required this.games,
    required this.userId,
  });

  @override
  List<Object> get props => [games, userId];
}

//rated states
class UserRatedLoading extends GameState {}

class UserRatedLoaded extends GameState {
  final List<Game> games;
  final String userId;

  const UserRatedLoaded({
    required this.games,
    required this.userId,
  });

  @override
  List<Object> get props => [games, userId];
}


// Game Details States
class GameDetailsLoading extends GameState {}

class GameDetailsLoaded extends GameState {
  final Game game;

  const GameDetailsLoaded(this.game);

  @override
  List<Object> get props => [game];
}

// Error State
class GameError extends GameState {
  final String message;
  final List<Game> games; // Keep existing games on error

  const GameError(this.message, {this.games = const []});

  @override
  List<Object> get props => [message, games];
}

// Multi-state for home page (combining multiple data sources)
class HomePageDataLoaded extends GameState {
  final List<Game> popularGames;
  final List<Game> upcomingGames;
  final List<Game>? userWishlist;
  final List<Game>? userRecommendations;
  final bool isLoading;

  const HomePageDataLoaded({
    this.popularGames = const [],
    this.upcomingGames = const [],
    this.userWishlist,
    this.userRecommendations,
    this.isLoading = false,
  });

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
  final Game game;
  final bool isWishlisted;
  final bool isRecommended;
  final double? userRating;
  final bool isInTopThree;
  final List<int> userTopThreeGames;

  const GameDetailsWithUserDataLoaded({
    required this.game,
    this.isWishlisted = false,
    this.isRecommended = false,
    this.userRating,
    this.isInTopThree = false,
    this.userTopThreeGames = const [],
  });

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

// 1. Füge diese States zu deiner game_state.dart hinzu:

// Home Page States
class HomePageLoading extends GameState {}

class HomePageLoaded extends GameState {
  final List<Game> popularGames;
  final List<Game> upcomingGames;
  final List<Game>? userWishlist;
  final List<Game>? userRecommendations;

  const HomePageLoaded({
    required this.popularGames,
    required this.upcomingGames,
    this.userWishlist,
    this.userRecommendations,
  });

  // copyWith Methode hinzufügen
  HomePageLoaded copyWith({
    List<Game>? popularGames,
    List<Game>? upcomingGames,
    List<Game>? userWishlist,
    List<Game>? userRecommendations,
  }) {
    return HomePageLoaded(
      popularGames: popularGames ?? this.popularGames,
      upcomingGames: upcomingGames ?? this.upcomingGames,
      userWishlist: userWishlist ?? this.userWishlist,
      userRecommendations: userRecommendations ?? this.userRecommendations,
    );
  }

  @override
  List<Object?> get props => [
    popularGames,
    upcomingGames,
    userWishlist,
    userRecommendations,
  ];
}


class GrovePageLoading extends GameState {}

class GrovePageLoaded extends GameState {
  final List<Game>? userRated;
  final List<Game>? userWishlist;
  final List<Game>? userRecommendations;

  const GrovePageLoaded({
    this.userRated,
    this.userWishlist,
    this.userRecommendations,
  });

  // copyWith Methode hinzufügen
  GrovePageLoaded copyWith({
    List<Game>? userRated,
    List<Game>? userWishlist,
    List<Game>? userRecommendations,
  }) {
    return GrovePageLoaded(
      userRated: userRated ?? this.userRated,
      userWishlist: userWishlist ?? this.userWishlist,
      userRecommendations: userRecommendations ?? this.userRecommendations,
    );
  }

  @override
  List<Object?> get props => [
    userRated,
    userWishlist,
    userRecommendations,
  ];
}



