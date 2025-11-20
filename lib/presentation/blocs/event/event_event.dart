// ==================================================
// EVENT BLOC FOR STATE MANAGEMENT
// ==================================================

// lib/presentation/blocs/event/event_event.dart
import 'package:equatable/equatable.dart';

abstract class EventEvent extends Equatable {
  const EventEvent();

  @override
  List<Object?> get props => [];
}

// ==========================================
// BASIC EVENT EVENTS
// ==========================================

class GetEventDetailsEvent extends EventEvent {

  const GetEventDetailsEvent({required this.eventId});
  final int eventId;

  @override
  List<Object> get props => [eventId];
}

class GetCurrentEventsEvent extends EventEvent {

  const GetCurrentEventsEvent({this.limit = 10});
  final int limit;

  @override
  List<Object> get props => [limit];
}

class GetUpcomingEventsEvent extends EventEvent {

  const GetUpcomingEventsEvent({this.limit = 10});
  final int limit;

  @override
  List<Object> get props => [limit];
}

class SearchEventsEvent extends EventEvent {

  const SearchEventsEvent({required this.query});
  final String query;

  @override
  List<Object> get props => [query];
}

class GetEventsByDateRangeEvent extends EventEvent {

  const GetEventsByDateRangeEvent({
    this.startDate,
    this.endDate,
    this.limit = 50,
  });
  final DateTime? startDate;
  final DateTime? endDate;
  final int limit;

  @override
  List<Object?> get props => [startDate, endDate, limit];
}

class GetEventsByGamesEvent extends EventEvent {

  const GetEventsByGamesEvent({required this.gameIds});
  final List<int> gameIds;

  @override
  List<Object> get props => [gameIds];
}

class GetCompleteEventDetailsEvent extends EventEvent {

  const GetCompleteEventDetailsEvent({
    required this.eventId,
    this.includeGames = true,
  });
  final int eventId;
  final bool includeGames;

  @override
  List<Object> get props => [eventId, includeGames];
}

// Clear events (for cleanup)
class ClearEventsEvent extends EventEvent {}

class GetEventDetailsWithUserDataEvent extends EventEvent {

  const GetEventDetailsWithUserDataEvent({
    required this.eventId,
    this.userId,
  });
  final int eventId;
  final String? userId;

  @override
  List<Object?> get props => [eventId, userId];
}

class GetCompleteEventDetailsWithUserDataEvent extends EventEvent {

  const GetCompleteEventDetailsWithUserDataEvent({
    required this.eventId,
    this.userId,
    this.includeGames = true,
  });
  final int eventId;
  final String? userId;
  final bool includeGames;

  @override
  List<Object?> get props => [eventId, userId, includeGames];
}

// ==========================================
// ADVANCED EVENT SEARCH EVENTS
// ==========================================

class SearchEventsWithFiltersEvent extends EventEvent { // EventSearchFilters

  const SearchEventsWithFiltersEvent({
    required this.query,
    required this.filters,
  });
  final String query;
  final dynamic filters;

  @override
  List<Object> get props => [query, filters];
}

class LoadMoreEventsEvent extends EventEvent {
  const LoadMoreEventsEvent();
}

class ClearEventSearchEvent extends EventEvent {
  const ClearEventSearchEvent();
}
