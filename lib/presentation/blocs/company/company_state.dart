// ==================================================
// PLATFORM BLOC STATES
// ==================================================

// lib/presentation/blocs/platform/game_engine_state.dart
import 'package:equatable/equatable.dart';
import 'package:gamer_grove/domain/entities/game/game_engine.dart';
import '../../../domain/entities/platform/platform.dart';
import '../../../domain/entities/game/game.dart';

abstract class CompanyState extends Equatable {
  const CompanyState();

  @override
  List<Object?> get props => [];
}

class CompanyInitial extends CompanyState {}

class CompanyLoading extends CompanyState {}

class CompanyDetailsLoaded extends CompanyState {
  final GameEngine gameEngine;
  final List<Game> games;

  const CompanyDetailsLoaded({
    required this.gameEngine,
    required this.games,
  });

  bool get hasGames => games.isNotEmpty;
  int get gameCount => games.length;

  @override
  List<Object> get props => [gameEngine, games];
}

class CompanyError extends CompanyState {
  final String message;

  const CompanyError({required this.message});

  @override
  List<Object> get props => [message];
}