// ==================================================
// EVENT BLOC
// ==================================================

// lib/presentation/blocs/event/event_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamer_grove/core/services/game_enrichment_service.dart';
import '../../../domain/entities/event/event.dart';
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
  final GameEnrichmentService enrichmentService;

  EventBloc({
    required this.getEventDetails,
    required this.getCurrentEvents,
    required this.getUpcomingEvents,
    required this.searchEvents,
    required this.getEventsByDateRange,
    required this.getEventsByGames,
    required this.getCompleteEventDetails,
    required this.enrichmentService,
  }) : super(EventInitial()) {
    on<GetEventDetailsEvent>(_onGetEventDetails);
    on<GetCurrentEventsEvent>(_onGetCurrentEvents);
    on<GetUpcomingEventsEvent>(_onGetUpcomingEvents);
    on<SearchEventsEvent>(_onSearchEvents);
    on<GetEventsByDateRangeEvent>(_onGetEventsByDateRange);
    on<GetEventsByGamesEvent>(_onGetEventsByGames);
    on<GetCompleteEventDetailsEvent>(_onGetCompleteEventDetails);
    on<ClearEventsEvent>(_onClearEvents);
    on<GetEventDetailsWithUserDataEvent>(_onGetEventDetailsWithUserData);
    on<GetCompleteEventDetailsWithUserDataEvent>(
        _onGetCompleteEventDetailsWithUserData);
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
      (eventDetails) =>
          emit(CompleteEventDetailsLoaded(eventDetails: eventDetails)),
    );
  }

  Future<void> _onClearEvents(
    ClearEventsEvent event,
    Emitter<EventState> emit,
  ) async {
    emit(EventInitial());
  }

  // 🆕 NEW: Handler für Event Details mit User Data
  Future<void> _onGetEventDetailsWithUserData(
    GetEventDetailsWithUserDataEvent event,
    Emitter<EventState> emit,
  ) async {
    emit(EventLoading());

    final result = await getEventDetails(
      GetEventDetailsParams(eventId: event.eventId),
    );

    await result.fold(
      (failure) async {
        emit(EventError(message: failure.message));
      },
      (eventDetails) async {
// Event Games enrichen wenn User eingeloggt
        if (event.userId != null && eventDetails.games.isNotEmpty) {
          try {
            final enrichedEvent =
                await _enrichEventWithUserData(eventDetails, event.userId!);
            emit(EventDetailsLoaded(event: enrichedEvent));
          } catch (e) {
            print('❌ EventBloc: Failed to enrich event games: $e');
            emit(EventDetailsLoaded(event: eventDetails)); // Fallback
          }
        } else {
          emit(EventDetailsLoaded(event: eventDetails));
        }
      },
    );
  }

// 🆕 NEW: Handler für Complete Event Details mit User Data
  Future<void> _onGetCompleteEventDetailsWithUserData(
    GetCompleteEventDetailsWithUserDataEvent event,
    Emitter<EventState> emit,
  ) async {
    emit(EventLoading());

    final result = await getCompleteEventDetails(
      GetCompleteEventDetailsParams(
        eventId: event.eventId,
        includeGames: event.includeGames,
      ),
    );

    await result.fold(
      (failure) async {
        emit(EventError(message: failure.message));
      },
      (eventDetails) async {
// Event Games enrichen wenn User eingeloggt
        if (event.userId != null && eventDetails.event.games.isNotEmpty) {
          try {
            final enrichedEvent = await _enrichEventWithUserData(
                eventDetails.event, event.userId!);
            final enrichedEventDetails =
                eventDetails.copyWith(event: enrichedEvent);
            emit(
                CompleteEventDetailsLoaded(eventDetails: enrichedEventDetails));
          } catch (e) {
            print('❌ EventBloc: Failed to enrich event games: $e');
            emit(CompleteEventDetailsLoaded(
                eventDetails: eventDetails)); // Fallback
          }
        } else {
          emit(CompleteEventDetailsLoaded(eventDetails: eventDetails));
        }
      },
    );
  }

  Future<Event> _enrichEventWithUserData(Event event, String userId) async {
    if (event.games.isEmpty) return event;

    try {
      final enrichedGames = await enrichmentService.enrichGames(
        event.games,
        userId,
      );

      // Create new Event with enriched games
      final enrichedEvent = Event(
        id: event.id,
        checksum: event.checksum,
        name: event.name,
        slug: event.slug,
        createdAt: event.createdAt,
        updatedAt: event.updatedAt,
        startTime: event.startTime,
        endTime: event.endTime,
        timeZone: event.timeZone,
        description: event.description,
        eventLogo: event.eventLogo,
        eventLogoId: event.eventLogoId,
        liveStreamUrl: event.liveStreamUrl,
        eventNetworks: event.eventNetworks,
        eventNetworkIds: event.eventNetworkIds,
        games: enrichedGames, // 🎯 Enriched games!
        gameIds: event.gameIds,
        videos: event.videos,
        videoIds: event.videoIds,
      );

      print('✅ EventBloc: Event enriched with ${enrichedGames.length} games');
      return enrichedEvent;
    } catch (e) {
      print('❌ EventBloc: Error enriching event games: $e');
      return event;
    }
  }
}
