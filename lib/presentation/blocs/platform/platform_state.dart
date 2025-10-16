// ==================================================
// PLATFORM BLOC STATES (ERWEITERT)
// ==================================================

// lib/presentation/blocs/platform/platform_state.dart
import 'package:equatable/equatable.dart';
import 'package:gamer_grove/domain/entities/game/game_sort_options.dart';
import 'package:gamer_grove/domain/entities/platform/platform.dart';
import '../../../domain/entities/game/game.dart';

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
  final Platform platform;
  final List<Game> games;

  const PlatformDetailsLoaded({
    required this.platform,
    required this.games,
  });

  bool get hasGames => games.isNotEmpty;
  int get gameCount => games.length;

  @override
  List<Object> get props => [platform, games];
}

class PlatformError extends PlatformState {
  final String message;

  const PlatformError({required this.message});

  @override
  List<Object> get props => [message];
}

// ==========================================
// 🆕 NEW STATES FOR PAGINATED GAMES
// ==========================================

/// Loading paginated games (initial load)
class PlatformGamesLoading extends PlatformState {
  final int platformId;
  final String platformName;

  const PlatformGamesLoading({
    required this.platformId,
    required this.platformName,
  });

  @override
  List<Object> get props => [platformId, platformName];
}

/// Paginated games loaded
class PlatformGamesLoaded extends PlatformState {
  final int platformId;
  final String platformName;
  final List<Game> games;
  final bool hasMore;
  final int currentPage;
  final GameSortBy sortBy;
  final SortOrder sortOrder;
  final bool isLoadingMore;
  final String? userId;

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
  final int platformId;
  final String platformName;
  final String message;

  const PlatformGamesError({
    required this.platformId,
    required this.platformName,
    required this.message,
  });

  @override
  List<Object> get props => [platformId, platformName, message];
}
