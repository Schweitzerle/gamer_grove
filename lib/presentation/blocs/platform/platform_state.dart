// ==================================================
// PLATFORM BLOC STATES
// ==================================================

// lib/presentation/blocs/platform/game_engine_state.dart
import 'package:equatable/equatable.dart';
import '../../../domain/entities/platform/platform.dart';
import '../../../domain/entities/game/game.dart';

abstract class PlatformState extends Equatable {
  const PlatformState();

  @override
  List<Object?> get props => [];
}

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