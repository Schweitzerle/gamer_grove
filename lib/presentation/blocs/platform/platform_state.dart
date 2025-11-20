// ==================================================
// PLATFORM BLOC STATES (ERWEITERT)
// ==================================================

// lib/presentation/blocs/platform/platform_state.dart
import 'package:equatable/equatable.dart';
import 'package:gamer_grove/domain/entities/game/game.dart';
import 'package:gamer_grove/domain/entities/game/game_sort_options.dart';
import 'package:gamer_grove/domain/entities/platform/platform.dart';

abstract class PlatformState extends Equatable {
  const PlatformState();

  @override
  List<Object?> get props => [];
}

// ==========================================
// EXISTING STATES
// ==========================================

class PlatformInitial extends PlatformState {}

class PlatformLoading extends PlatformState {}

class PlatformDetailsLoaded extends PlatformState {

  const PlatformDetailsLoaded({
    required this.platform,
    required this.games,
  });
  final Platform platform;
  final List<Game> games;

  bool get hasGames => games.isNotEmpty;
  int get gameCount => games.length;

  @override
  List<Object> get props => [platform, games];
}

class PlatformError extends PlatformState {

  const PlatformError({required this.message});
  final String message;

  @override
  List<Object> get props => [message];
}

// ==========================================
// 🆕 NEW STATES FOR PAGINATED GAMES
// ==========================================

/// Loading paginated games (initial load)
class PlatformGamesLoading extends PlatformState {

  const PlatformGamesLoading({
    required this.platformId,
    required this.platformName,
  });
  final int platformId;
  final String platformName;

  @override
  List<Object> get props => [platformId, platformName];
}

/// Paginated games loaded
class PlatformGamesLoaded extends PlatformState {

  const PlatformGamesLoaded({
    required this.platformId,
    required this.platformName,
    required this.games,
    required this.hasMore,
    this.currentPage = 0,
    this.sortBy = GameSortBy.ratingCount,
    this.sortOrder = SortOrder.descending,
    this.isLoadingMore = false,
    this.userId,
  });
  final int platformId;
  final String platformName;
  final List<Game> games;
  final bool hasMore;
  final int currentPage;
  final GameSortBy sortBy;
  final SortOrder sortOrder;
  final bool isLoadingMore;
  final String? userId;

  /// Copy with for updating state
  PlatformGamesLoaded copyWith({
    List<Game>? games,
    bool? hasMore,
    int? currentPage,
    GameSortBy? sortBy,
    SortOrder? sortOrder,
    bool? isLoadingMore,
    String? userId,
  }) {
    return PlatformGamesLoaded(
      platformId: platformId,
      platformName: platformName,
      games: games ?? this.games,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      userId: userId ?? this.userId,
    );
  }

  @override
  List<Object?> get props => [
        platformId,
        platformName,
        games,
        hasMore,
        currentPage,
        sortBy,
        sortOrder,
        isLoadingMore,
        userId,
      ];
}

/// Error loading paginated games
class PlatformGamesError extends PlatformState {

  const PlatformGamesError({
    required this.platformId,
    required this.platformName,
    required this.message,
  });
  final int platformId;
  final String platformName;
  final String message;

  @override
  List<Object> get props => [platformId, platformName, message];
}
