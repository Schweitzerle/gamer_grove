// ==================================================
// PLATFORM BLOC EVENTS
// ==================================================

// lib/presentation/blocs/platform/game_engine_event.dart
import 'package:equatable/equatable.dart';

abstract class PlatformEvent extends Equatable {
  const PlatformEvent();

  @override
  List<Object> get props => [];
}

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
  List<Object> get props => [platformId, includeGames];
}

class ClearPlatformEvent extends PlatformEvent {}


