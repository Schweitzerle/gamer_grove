// ==================================================
// PLATFORM BLOC EVENTS
// ==================================================

// lib/presentation/blocs/platform/game_engine_event.dart
import 'package:equatable/equatable.dart';

abstract class GameEngineEvent extends Equatable {
  const GameEngineEvent();

  @override
  List<Object> get props => [];
}

class GetGameEngineDetailsEvent extends GameEngineEvent {
  final int gameEngineId;
  final bool includeGames;
  final String? userId;

  const GetGameEngineDetailsEvent({
    required this.gameEngineId,
    this.includeGames = true,
    this.userId,
  });

  @override
  List<Object> get props => [gameEngineId, includeGames];
}

class ClearGameEngineEvent extends GameEngineEvent {}


