part of 'statistics_bloc.dart';

/// Base class for statistics events
abstract class StatisticsEvent extends Equatable {
  const StatisticsEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load statistics for a user
class LoadStatisticsEvent extends StatisticsEvent {

  /// Creates a LoadStatisticsEvent
  const LoadStatisticsEvent({required this.userId});
  /// User ID to load statistics for
  final String userId;

  @override
  List<Object?> get props => [userId];
}

/// Event to refresh statistics for a user
class RefreshStatisticsEvent extends StatisticsEvent {

  /// Creates a RefreshStatisticsEvent
  const RefreshStatisticsEvent({required this.userId});
  /// User ID to refresh statistics for
  final String userId;

  @override
  List<Object?> get props => [userId];
}
