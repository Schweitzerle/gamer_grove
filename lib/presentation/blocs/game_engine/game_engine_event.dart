// ==================================================
// GAME ENGINE BLOC EVENTS (ERWEITERT)
// ==================================================

// lib/presentation/blocs/game_engine/game_engine_event.dart
import 'package:equatable/equatable.dart';
import 'package:gamer_grove/domain/entities/game/game_sort_options.dart';

abstract class GameEngineEvent extends Equatable {
  const GameEngineEvent();

  @override
  List<Object?> get props => [];
}

// ==========================================
// EXISTING EVENTS
// ==========================================

class GetGameEngineDetailsEvent extends GameEngineEvent {

  const GetGameEngineDetailsEvent({
    required this.gameEngineId,
    this.includeGames = true,
    this.userId,
  });
  final int gameEngineId;
  final bool includeGames;
  final String? userId;

  @override
  List<Object?> get props => [gameEngineId, includeGames, userId];
}

class ClearGameEngineEvent extends GameEngineEvent {}

// ==========================================
// 🆕 NEW EVENTS FOR PAGINATED GAMES
// ==========================================

/// Load paginated games for a game engine
class LoadGameEngineGamesEvent extends GameEngineEvent { // If true, reset pagination

  const LoadGameEngineGamesEvent({
    required this.gameEngineId,
    required this.gameEngineName,
    this.userId,
    this.sortBy = GameSortBy.ratingCount,
    this.sortOrder = SortOrder.descending,
    this.refresh = false,
  });
  final int gameEngineId;
  final String gameEngineName;
  final String? userId;
  final GameSortBy sortBy;
  final SortOrder sortOrder;
  final bool refresh;

  @override
  List<Object?> get props => [
        gameEngineId,
        gameEngineName,
        userId,
        sortBy,
        sortOrder,
        refresh,
      ];
}

/// Load more games (pagination)
class LoadMoreGameEngineGamesEvent extends GameEngineEvent {
  const LoadMoreGameEngineGamesEvent();
}

/// Change sorting for paginated games
class ChangeGameEngineSortEvent extends GameEngineEvent {

  const ChangeGameEngineSortEvent({
    required this.sortBy,
    required this.sortOrder,
  });
  final GameSortBy sortBy;
  final SortOrder sortOrder;

  @override
  List<Object> get props => [sortBy, sortOrder];
}
