// lib/presentation/blocs/game/game_extensions.dart
// Diese Events und States müssen zum bestehenden GameBloc hinzugefügt werden

// ==========================================
// ZUSÄTZLICHE EVENTS FÜR SEARCH
// ==========================================

import '../../../domain/entities/search/search_filters.dart';
import 'game_bloc.dart';

class SearchGamesWithFiltersEvent extends GameEvent {
  final String query;
  final SearchFilters filters;

  const SearchGamesWithFiltersEvent({
    required this.query,
    required this.filters,
  });

  @override
  List<Object> get props => [query, filters];
}

class LoadRecentSearchesEvent extends GameEvent {
  final String userId;

  const LoadRecentSearchesEvent({required this.userId});

  @override
  List<Object> get props => [userId];
}

class SaveSearchQueryEvent extends GameEvent {
  final String userId;
  final String query;

  const SaveSearchQueryEvent({
    required this.userId,
    required this.query,
  });

  @override
  List<Object> get props => [userId, query];
}

// ==========================================
// ZUSÄTZLICHE STATES FÜR SEARCH
// ==========================================

class RecentSearchesLoaded extends GameState {
  final List<String> queries;

  const RecentSearchesLoaded({required this.queries});

  @override
  List<Object> get props => [queries];
}

class SearchQuerySaved extends GameState {}

// GameSearchError gibt es bereits als GameError, aber für Konsistenz:
class GameSearchError extends GameState {
  final String message;

  const GameSearchError({required this.message});

  @override
  List<Object> get props => [message];
}
