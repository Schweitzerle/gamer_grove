// ==================================================
// CHARACTER BLOC STATES
// ==================================================

// lib/presentation/blocs/character/character_state.dart
import 'package:equatable/equatable.dart';
import 'package:gamer_grove/domain/entities/character/character.dart';
import 'package:gamer_grove/domain/entities/game/game.dart';

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
  final List<Character> characters;

  const CharacterError({
    required this.message,
    this.characters = const [],
  });

  @override
  List<Object> get props => [message, characters];
}

// Home Screen - Popular Characters
class PopularCharactersLoaded extends CharacterState {
  final List<Character> characters;

  const PopularCharactersLoaded({required this.characters});

  @override
  List<Object> get props => [characters];
}

// Search States
class CharacterSearchLoading extends CharacterState {
  final List<Character> characters;
  final bool isLoadingMore;

  const CharacterSearchLoading({
    this.characters = const [],
    this.isLoadingMore = false,
  });

  @override
  List<Object> get props => [characters, isLoadingMore];
}

class CharacterSearchLoaded extends CharacterState {
  final List<Character> characters;
  final String query;
  final bool hasReachedMax;
  final bool isLoadingMore;

  const CharacterSearchLoaded({
    required this.characters,
    required this.query,
    this.hasReachedMax = false,
    this.isLoadingMore = false,
  });

  CharacterSearchLoaded copyWith({
    List<Character>? characters,
    String? query,
    bool? hasReachedMax,
    bool? isLoadingMore,
  }) {
    return CharacterSearchLoaded(
      characters: characters ?? this.characters,
      query: query ?? this.query,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object> get props => [characters, query, hasReachedMax, isLoadingMore];
}
