// ==================================================
// CHARACTER BLOC SYSTEM - EVENTS, STATES, BLOC
// ==================================================

// lib/presentation/blocs/character/character_event.dart
import 'package:equatable/equatable.dart';

abstract class CharacterEvent extends Equatable {
  const CharacterEvent();

  @override
  List<Object> get props => [];
}

class GetCharacterDetailsEvent extends CharacterEvent {
  final int characterId;
  final bool includeGames;
  final String? userId; // 🆕

  const GetCharacterDetailsEvent({
    required this.characterId,
    this.includeGames = true,
    this.userId, // 🆕
  });

  @override
  List<Object> get props => [characterId, includeGames];
}

class ClearCharacterEvent extends CharacterEvent {}
