// ==================================================
// PLATFORM BLOC EVENTS (ERWEITERT)
// ==================================================

// lib/presentation/blocs/platform/platform_event.dart
import 'package:equatable/equatable.dart';
import 'package:gamer_grove/domain/entities/game/game_sort_options.dart';

abstract class PlatformEvent extends Equatable {
  const PlatformEvent();

  @override
  List<Object?> get props => [];
}

// ==========================================
// EXISTING EVENTS
// ==========================================

class GetPlatformDetailsEvent extends PlatformEvent {
  final int platformId;
  final bool includeGames;
  final String? userId;

  const GetPlatformDetailsEvent({
    required this.platformId,
    this.includeGames = true,
    this.userId,
  });

  @override
  List<Object?> get props => [platformId, includeGames, userId];
}

class ClearPlatformEvent extends PlatformEvent {}

// ==========================================
// 🆕 NEW EVENTS FOR PAGINATED GAMES
// ==========================================

/// Load paginated games for a platform
class LoadPlatformGamesEvent extends PlatformEvent {
  final int platformId;
  final String platformName;
  final String? userId;
  final GameSortBy sortBy;
  final SortOrder sortOrder;
  final bool refresh; // If true, reset pagination

  const LoadPlatformGamesEvent({
    required this.platformId,
    required this.platformName,
    this.userId,
    this.sortBy = GameSortBy.ratingCount,
    this.sortOrder = SortOrder.descending,
    this.refresh = false,
  });

  @override
  List<Object?> get props => [
        platformId,
        platformName,
        userId,
        sortBy,
        sortOrder,
        refresh,
      ];
}

/// Load more games (pagination)
class LoadMorePlatformGamesEvent extends PlatformEvent {
  const LoadMorePlatformGamesEvent();
}

/// Change sorting for paginated games
class ChangePlatformSortEvent extends PlatformEvent {
  final GameSortBy sortBy;
  final SortOrder sortOrder;

  const ChangePlatformSortEvent({
    required this.sortBy,
    required this.sortOrder,
  });

  @override
  List<Object> get props => [sortBy, sortOrder];
}
