// ==================================================
// PLATFORM BLOC STATES
// ==================================================

// lib/presentation/blocs/platform/game_engine_state.dart
import 'package:equatable/equatable.dart';
import 'package:gamer_grove/domain/entities/game/game_engine.dart';
import '../../../domain/entities/platform/platform.dart';
import '../../../domain/entities/game/game.dart';

abstract class GameEngineState extends Equatable {
  const GameEngineState();

  @override
  List<Object?> get props => [];
}

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