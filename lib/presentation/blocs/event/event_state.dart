// ==================================================
// EVENT STATE
// ==================================================

// lib/presentation/blocs/event/event_state.dart
import 'package:equatable/equatable.dart';
import '../../../../domain/entities/event/event.dart';
import '../../../domain/usecases/event/get_complete_event_details.dart';

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
  final Event event;

  const EventDetailsLoaded({required this.event});

  @override
  List<Object> get props => [event];
}

class CompleteEventDetailsLoaded extends EventState {
  final CompleteEventDetails eventDetails;

  const CompleteEventDetailsLoaded({required this.eventDetails});

  @override
  List<Object> get props => [eventDetails];
}

class CurrentEventsLoaded extends EventState {
  final List<Event> events;

  const CurrentEventsLoaded({required this.events});

  @override
  List<Object> get props => [events];
}

class UpcomingEventsLoaded extends EventState {
  final List<Event> events;

  const UpcomingEventsLoaded({required this.events});

  @override
  List<Object> get props => [events];
}

class EventsSearchLoaded extends EventState {
  final List<Event> events;
  final String query;

  const EventsSearchLoaded({
    required this.events,
    required this.query,
  });

  @override
  List<Object> get props => [events, query];
}

class EventsByDateRangeLoaded extends EventState {
  final List<Event> events;
  final DateTime? startDate;
  final DateTime? endDate;

  const EventsByDateRangeLoaded({
    required this.events,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [events, startDate, endDate];
}

class EventsByGamesLoaded extends EventState {
  final List<Event> events;
  final List<int> gameIds;

  const EventsByGamesLoaded({
    required this.events,
    required this.gameIds,
  });

  @override
  List<Object> get props => [events, gameIds];
}

// ==========================================
// ADVANCED EVENT SEARCH STATES
// ==========================================

class EventSearchLoading extends EventState {
  final List<Event> events;
  final bool isLoadingMore;

  const EventSearchLoading({
    this.events = const [],
    this.isLoadingMore = false,
  });

  @override
  List<Object> get props => [events, isLoadingMore];
}

class EventSearchLoaded extends EventState {
  final List<Event> events;
  final String query;
  final bool hasReachedMax;
  final bool isLoadingMore;

  const EventSearchLoaded({
    required this.events,
    required this.query,
    this.hasReachedMax = false,
    this.isLoadingMore = false,
  });

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
  final String message;
  final List<Event> events;

  const EventError({
    required this.message,
    this.events = const [],
  });

  @override
  List<Object> get props => [message, events];
}
