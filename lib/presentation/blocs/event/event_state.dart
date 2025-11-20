// ==================================================
// EVENT STATE
// ==================================================

// lib/presentation/blocs/event/event_state.dart
import 'package:equatable/equatable.dart';
import 'package:gamer_grove/domain/entities/event/event.dart';
import 'package:gamer_grove/domain/usecases/event/get_complete_event_details.dart';

abstract class EventState extends Equatable {
  const EventState();

  @override
  List<Object?> get props => [];
}

class EventInitial extends EventState {}

class EventLoading extends EventState {}

// ==========================================
// SUCCESS STATES
// ==========================================

class EventDetailsLoaded extends EventState {

  const EventDetailsLoaded({required this.event});
  final Event event;

  @override
  List<Object> get props => [event];
}

class CompleteEventDetailsLoaded extends EventState {

  const CompleteEventDetailsLoaded({required this.eventDetails});
  final CompleteEventDetails eventDetails;

  @override
  List<Object> get props => [eventDetails];
}

class CurrentEventsLoaded extends EventState {

  const CurrentEventsLoaded({required this.events});
  final List<Event> events;

  @override
  List<Object> get props => [events];
}

class UpcomingEventsLoaded extends EventState {

  const UpcomingEventsLoaded({required this.events});
  final List<Event> events;

  @override
  List<Object> get props => [events];
}

class EventsSearchLoaded extends EventState {

  const EventsSearchLoaded({
    required this.events,
    required this.query,
  });
  final List<Event> events;
  final String query;

  @override
  List<Object> get props => [events, query];
}

class EventsByDateRangeLoaded extends EventState {

  const EventsByDateRangeLoaded({
    required this.events,
    this.startDate,
    this.endDate,
  });
  final List<Event> events;
  final DateTime? startDate;
  final DateTime? endDate;

  @override
  List<Object?> get props => [events, startDate, endDate];
}

class EventsByGamesLoaded extends EventState {

  const EventsByGamesLoaded({
    required this.events,
    required this.gameIds,
  });
  final List<Event> events;
  final List<int> gameIds;

  @override
  List<Object> get props => [events, gameIds];
}

// ==========================================
// ADVANCED EVENT SEARCH STATES
// ==========================================

class EventSearchLoading extends EventState {

  const EventSearchLoading({
    this.events = const [],
    this.isLoadingMore = false,
  });
  final List<Event> events;
  final bool isLoadingMore;

  @override
  List<Object> get props => [events, isLoadingMore];
}

class EventSearchLoaded extends EventState {

  const EventSearchLoaded({
    required this.events,
    required this.query,
    this.hasReachedMax = false,
    this.isLoadingMore = false,
  });
  final List<Event> events;
  final String query;
  final bool hasReachedMax;
  final bool isLoadingMore;

  EventSearchLoaded copyWith({
    List<Event>? events,
    String? query,
    bool? hasReachedMax,
    bool? isLoadingMore,
  }) {
    return EventSearchLoaded(
      events: events ?? this.events,
      query: query ?? this.query,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object> get props => [events, query, hasReachedMax, isLoadingMore];
}

class EventError extends EventState {

  const EventError({
    required this.message,
    this.events = const [],
  });
  final String message;
  final List<Event> events;

  @override
  List<Object> get props => [message, events];
}
