// ==================================================
// GAME ENGINE BLOC STATES (ERWEITERT)
// ==================================================

// lib/presentation/blocs/game_engine/game_engine_state.dart
import 'package:equatable/equatable.dart';
import 'package:gamer_grove/domain/entities/game/game_engine.dart';
import 'package:gamer_grove/domain/entities/game/game_sort_options.dart';
import '../../../domain/entities/game/game.dart';

abstract class GameEngineState extends Equatable {
  const GameEngineState();

  @override
  List<Object?> get props => [];
}

// ==========================================
// EXISTING STATES
// ==========================================

class GameEngineInitial extends GameEngineState {}

class GameEngineLoading extends GameEngineState {}

class GameEngineDetailsLoaded extends GameEngineState {
  final GameEngine gameEngine;
  final List<Game> games;

  const GameEngineDetailsLoaded({
    required this.gameEngine,
    required this.games,
  });

  bool get hasGames => games.isNotEmpty;
  int get gameCount => games.length;

  @override
  List<Object> get props => [gameEngine, games];
}

class GameEngineError extends GameEngineState {
  final String message;

  const GameEngineError({required this.message});

  @override
  List<Object> get props => [message];
}

// ==========================================
// 🆕 NEW STATES FOR PAGINATED GAMES
// ==========================================

/// Loading paginated games (initial load)
class GameEngineGamesLoading extends GameEngineState {
  final int gameEngineId;
  final String gameEngineName;

  const GameEngineGamesLoading({
    required this.gameEngineId,
    required this.gameEngineName,
  });

  @override
  List<Object> get props => [gameEngineId, gameEngineName];
}

/// Paginated games loaded
class GameEngineGamesLoaded extends GameEngineState {
  final int gameEngineId;
  final String gameEngineName;
  final List<Game> games;
  final bool hasMore;
  final int currentPage;
  final GameSortBy sortBy;
  final SortOrder sortOrder;
  final bool isLoadingMore;
  final String? userId; // 🆕 Store userId for enrichment

  const GameEngineGamesLoaded({
    required this.gameEngineId,
    required this.gameEngineName,
    required this.games,
    required this.hasMore,
    this.currentPage = 0,
    this.sortBy = GameSortBy.ratingCount,
    this.sortOrder = SortOrder.descending,
    this.isLoadingMore = false,
    this.userId,
  });

  /// Copy with for updating state
  GameEngineGamesLoaded copyWith({
    List<Game>? games,
    bool? hasMore,
    int? currentPage,
    GameSortBy? sortBy,
    SortOrder? sortOrder,
    bool? isLoadingMore,
    String? userId,
  }) {
    return GameEngineGamesLoaded(
      gameEngineId: gameEngineId,
      gameEngineName: gameEngineName,
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
        gameEngineId,
        gameEngineName,
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
class GameEngineGamesError extends GameEngineState {
  final int gameEngineId;
  final String gameEngineName;
  final String message;

  const GameEngineGamesError({
    required this.gameEngineId,
    required this.gameEngineName,
    required this.message,
  });

  @override
  List<Object> get props => [gameEngineId, gameEngineName, message];
}
