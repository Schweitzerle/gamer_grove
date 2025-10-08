// ==================================================
// PLATFORM BLOC EVENTS
// ==================================================

// lib/presentation/blocs/platform/game_engine_event.dart
import 'package:equatable/equatable.dart';

abstract class CompanyEvent extends Equatable {
  const CompanyEvent();

  @override
  List<Object> get props => [];
}

class GetCompanyDetailsEvent extends CompanyEvent {
  final int gameEngineId;
  final bool includeGames;
  final String? userId;

  const GetCompanyDetailsEvent({
    required this.gameEngineId,
    this.includeGames = true,
    this.userId,
  });

  @override
  List<Object> get props => [gameEngineId, includeGames];
}

class ClearCompanyEvent extends CompanyEvent {}


