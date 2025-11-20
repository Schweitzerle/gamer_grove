// ==================================================
// CHARACTER BLOC SYSTEM - EVENTS, STATES, BLOC
// ==================================================

// lib/presentation/blocs/character/character_event.dart
import 'package:equatable/equatable.dart';
import 'package:gamer_grove/domain/entities/search/character_search_filters.dart';

abstract class CharacterEvent extends Equatable {
  const CharacterEvent();

  @override
  List<Object> get props => [];
}

class GetCharacterDetailsEvent extends CharacterEvent {

  const GetCharacterDetailsEvent({
    required this.characterId,
    this.includeGames = true,
    this.userId,
  });
  final int characterId;
  final bool includeGames;
  final String? userId;

  @override
  List<Object> get props => [characterId, includeGames];
}

class ClearCharacterEvent extends CharacterEvent {}

// Home Screen - Popular Characters
class GetPopularCharactersEvent extends CharacterEvent {

  const GetPopularCharactersEvent({this.limit = 10});
  final int limit;

  @override
  List<Object> get props => [limit];
}

// Search Characters
class SearchCharactersEvent extends CharacterEvent {

  const SearchCharactersEvent({required this.query});
  final String query;

  @override
  List<Object> get props => [query];
}

// Advanced Search with Filters
class SearchCharactersWithFiltersEvent extends CharacterEvent {

  const SearchCharactersWithFiltersEvent({
    required this.query,
    required this.filters,
    this.limit = 20,
    this.offset = 0,
  });
  final String query;
  final CharacterSearchFilters filters;
  final int limit;
  final int offset;

  @override
  List<Object> get props => [query, filters, limit, offset];
}

// Load More Characters (Pagination)
class LoadMoreCharactersEvent extends CharacterEvent {}

// Clear Search
class ClearCharacterSearchEvent extends CharacterEvent {}
