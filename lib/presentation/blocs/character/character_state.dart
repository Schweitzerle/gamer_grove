// ==================================================
// CHARACTER BLOC STATES
// ==================================================

// lib/presentation/blocs/character/character_state.dart
import 'package:equatable/equatable.dart';
import '../../../domain/entities/character/character.dart';
import '../../../domain/entities/game/game.dart';

abstract class CharacterState extends Equatable {
  const CharacterState();

  @override
  List<Object?> get props => [];
}

class CharacterInitial extends CharacterState {}

class CharacterLoading extends CharacterState {}

class CharacterDetailsLoaded extends CharacterState {
  final Character character;
  final List<Game> games;

  const CharacterDetailsLoaded({
    required this.character,
    required this.games,
  });

  bool get hasGames => games.isNotEmpty;
  int get gameCount => games.length;

  @override
  List<Object> get props => [character, games];
}

class CharacterError extends CharacterState {
  final String message;

  const CharacterError({required this.message});

  @override
  List<Object> get props => [message];
}
