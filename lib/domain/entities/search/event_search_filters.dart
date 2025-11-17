// lib/domain/entities/search/event_search_filters.dart
import 'package:equatable/equatable.dart';

enum EventSortBy {
  relevance,
  startTime,
  endTime,
  name,
}

enum EventSortOrder {
  ascending,
  descending,
}

class EventSearchFilters extends Equatable {
  // ============================================================
  // TIME FILTERS (based on event start_time)
  // ============================================================
  final DateTime? startTimeFrom;
  final DateTime? startTimeTo;

  // ============================================================
  // EVENT NETWORKS FILTERS
  // ============================================================
  final List<int> eventNetworkIds;
  final Map<int, String> eventNetworkNames;

  // ============================================================
  // SORTING
  // ============================================================
  final EventSortBy sortBy;
  final EventSortOrder sortOrder;

  const EventSearchFilters({
    // Time Filters
    this.startTimeFrom,
    this.startTimeTo,

    // Event Networks
    this.eventNetworkIds = const [],
    this.eventNetworkNames = const {},

    // Sorting
    this.sortBy = EventSortBy.relevance,
    this.sortOrder = EventSortOrder.descending,
  });

  bool get hasFilters =>
      startTimeFrom != null ||
      startTimeTo != null ||
      eventNetworkIds.isNotEmpty ||
      sortBy != EventSortBy.relevance;

  bool get hasTimeFilter => startTimeFrom != null || startTimeTo != null;

  bool get hasNetworkFilter => eventNetworkIds.isNotEmpty;

  EventSearchFilters copyWith({
    DateTime? startTimeFrom,
    DateTime? startTimeTo,
    List<int>? eventNetworkIds,
    Map<int, String>? eventNetworkNames,
    EventSortBy? sortBy,
    EventSortOrder? sortOrder,
  }) {
    return EventSearchFilters(
      startTimeFrom: startTimeFrom ?? this.startTimeFrom,
      startTimeTo: startTimeTo ?? this.startTimeTo,
      eventNetworkIds: eventNetworkIds ?? this.eventNetworkIds,
      eventNetworkNames: eventNetworkNames ?? this.eventNetworkNames,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  EventSearchFilters clearFilters() {
    return const EventSearchFilters();
  }

  @override
  List<Object?> get props => [
        startTimeFrom,
        startTimeTo,
        eventNetworkIds,
        eventNetworkNames,
        sortBy,
        sortOrder,
      ];
}
