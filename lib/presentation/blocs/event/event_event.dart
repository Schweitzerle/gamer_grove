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
  final int eventId;

  const GetEventDetailsEvent({required this.eventId});

  @override
  List<Object> get props => [eventId];
}

class GetCurrentEventsEvent extends EventEvent {
  final int limit;

  const GetCurrentEventsEvent({this.limit = 10});

  @override
  List<Object> get props => [limit];
}

class GetUpcomingEventsEvent extends EventEvent {
  final int limit;

  const GetUpcomingEventsEvent({this.limit = 10});

  @override
  List<Object> get props => [limit];
}

class SearchEventsEvent extends EventEvent {
  final String query;

  const SearchEventsEvent({required this.query});

  @override
  List<Object> get props => [query];
}

class GetEventsByDateRangeEvent extends EventEvent {
  final DateTime? startDate;
  final DateTime? endDate;
  final int limit;

  const GetEventsByDateRangeEvent({
    this.startDate,
    this.endDate,
    this.limit = 50,
  });

  @override
  List<Object?> get props => [startDate, endDate, limit];
}

class GetEventsByGamesEvent extends EventEvent {
  final List<int> gameIds;

  const GetEventsByGamesEvent({required this.gameIds});

  @override
  List<Object> get props => [gameIds];
}

class GetCompleteEventDetailsEvent extends EventEvent {
  final int eventId;
  final bool includeGames;

  const GetCompleteEventDetailsEvent({
    required this.eventId,
    this.includeGames = true,
  });

  @override
  List<Object> get props => [eventId, includeGames];
}

// Clear events (for cleanup)
class ClearEventsEvent extends EventEvent {}

