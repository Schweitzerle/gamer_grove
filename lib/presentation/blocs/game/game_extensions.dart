// lib/presentation/blocs/game/game_extensions.dart
// Diese Events und States müssen zum bestehenden GameBloc hinzugefügt werden

// ==========================================
// ZUSÄTZLICHE EVENTS FÜR SEARCH
// ==========================================

import 'package:gamer_grove/domain/entities/search/search_filters.dart';
import 'package:gamer_grove/presentation/blocs/game/game_bloc.dart';

class SearchGamesWithFiltersEvent extends GameEvent {

  const SearchGamesWithFiltersEvent({
    required this.query,
    required this.filters,
  });
  final String query;
  final SearchFilters filters;

  @override
  List<Object> get props => [query, filters];
}

class LoadRecentSearchesEvent extends GameEvent {

  const LoadRecentSearchesEvent({required this.userId});
  final String userId;

  @override
  List<Object> get props => [userId];
}

class SaveSearchQueryEvent extends GameEvent {

  const SaveSearchQueryEvent({
    required this.userId,
    required this.query,
  });
  final String userId;
  final String query;

  @override
  List<Object> get props => [userId, query];
}

// ==========================================
// ZUSÄTZLICHE STATES FÜR SEARCH
// ==========================================

class RecentSearchesLoaded extends GameState {

  const RecentSearchesLoaded({required this.queries});
  final List<String> queries;

  @override
  List<Object> get props => [queries];
}

class SearchQuerySaved extends GameState {}

// GameSearchError gibt es bereits als GameError, aber für Konsistenz:
class GameSearchError extends GameState {

  const GameSearchError({required this.message});
  final String message;

  @override
  List<Object> get props => [message];
}
