// ==================================================
// EVENT BLOC
// ==================================================

// lib/presentation/blocs/event/event_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/event/get_complete_event_details.dart';
import '../../../domain/usecases/event/get_current_events.dart';
import '../../../domain/usecases/event/get_event_details.dart';
import '../../../domain/usecases/event/get_events_by_date_range.dart';
import '../../../domain/usecases/event/get_events_by_games.dart';
import '../../../domain/usecases/event/get_upcoming_events.dart';
import '../../../domain/usecases/event/search_events.dart';
import 'event_event.dart';
import 'event_state.dart';

class EventBloc extends Bloc<EventEvent, EventState> {
  final GetEventDetails getEventDetails;
  final GetCurrentEvents getCurrentEvents;
  final GetUpcomingEvents getUpcomingEvents;
  final SearchEvents searchEvents;
  final GetEventsByDateRange getEventsByDateRange;
  final GetEventsByGames getEventsByGames;
  final GetCompleteEventDetails getCompleteEventDetails;

  EventBloc({
    required this.getEventDetails,
    required this.getCurrentEvents,
    required this.getUpcomingEvents,
    required this.searchEvents,
    required this.getEventsByDateRange,
    required this.getEventsByGames,
    required this.getCompleteEventDetails,
  }) : super(EventInitial()) {
    on<GetEventDetailsEvent>(_onGetEventDetails);
    on<GetCurrentEventsEvent>(_onGetCurrentEvents);
    on<GetUpcomingEventsEvent>(_onGetUpcomingEvents);
    on<SearchEventsEvent>(_onSearchEvents);
    on<GetEventsByDateRangeEvent>(_onGetEventsByDateRange);
    on<GetEventsByGamesEvent>(_onGetEventsByGames);
    on<GetCompleteEventDetailsEvent>(_onGetCompleteEventDetails);
    on<ClearEventsEvent>(_onClearEvents);
  }

  Future<void> _onGetEventDetails(
      GetEventDetailsEvent event,
      Emitter<EventState> emit,
      ) async {
    emit(EventLoading());

    final result = await getEventDetails(
      GetEventDetailsParams(eventId: event.eventId),
    );

    result.fold(
          (failure) => emit(EventError(message: failure.message)),
          (eventDetails) => emit(EventDetailsLoaded(event: eventDetails)),
    );
  }

  Future<void> _onGetCurrentEvents(
      GetCurrentEventsEvent event,
      Emitter<EventState> emit,
      ) async {
    emit(EventLoading());

    final result = await getCurrentEvents(
      GetCurrentEventsParams(limit: event.limit),
    );

    result.fold(
          (failure) => emit(EventError(message: failure.message)),
          (events) => emit(CurrentEventsLoaded(events: events)),
    );
  }

  Future<void> _onGetUpcomingEvents(
      GetUpcomingEventsEvent event,
      Emitter<EventState> emit,
      ) async {
    emit(EventLoading());

    final result = await getUpcomingEvents(
      GetUpcomingEventsParams(limit: event.limit),
    );

    result.fold(
          (failure) => emit(EventError(message: failure.message)),
          (events) => emit(UpcomingEventsLoaded(events: events)),
    );
  }

  Future<void> _onSearchEvents(
      SearchEventsEvent event,
      Emitter<EventState> emit,
      ) async {
    emit(EventLoading());

    final result = await searchEvents(
      SearchEventsParams(query: event.query),
    );

    result.fold(
          (failure) => emit(EventError(message: failure.message)),
          (events) => emit(EventsSearchLoaded(
        events: events,
        query: event.query,
      )),
    );
  }

  Future<void> _onGetEventsByDateRange(
      GetEventsByDateRangeEvent event,
      Emitter<EventState> emit,
      ) async {
    emit(EventLoading());

    final result = await getEventsByDateRange(
      GetEventsByDateRangeParams(
        startDate: event.startDate,
        endDate: event.endDate,
        limit: event.limit,
      ),
    );

    result.fold(
          (failure) => emit(EventError(message: failure.message)),
          (events) => emit(EventsByDateRangeLoaded(
        events: events,
        startDate: event.startDate,
        endDate: event.endDate,
      )),
    );
  }

  Future<void> _onGetEventsByGames(
      GetEventsByGamesEvent event,
      Emitter<EventState> emit,
      ) async {
    emit(EventLoading());

    final result = await getEventsByGames(
      GetEventsByGamesParams(gameIds: event.gameIds),
    );

    result.fold(
          (failure) => emit(EventError(message: failure.message)),
          (events) => emit(EventsByGamesLoaded(
        events: events,
        gameIds: event.gameIds,
      )),
    );
  }

  Future<void> _onGetCompleteEventDetails(
      GetCompleteEventDetailsEvent event,
      Emitter<EventState> emit,
      ) async {
    emit(EventLoading());

    final result = await getCompleteEventDetails(
      GetCompleteEventDetailsParams(
        eventId: event.eventId,
        includeGames: event.includeGames,
      ),
    );

    result.fold(
          (failure) => emit(EventError(message: failure.message)),
          (eventDetails) => emit(CompleteEventDetailsLoaded(eventDetails: eventDetails)),
    );
  }

  Future<void> _onClearEvents(
      ClearEventsEvent event,
      Emitter<EventState> emit,
      ) async {
    emit(EventInitial());
  }
}