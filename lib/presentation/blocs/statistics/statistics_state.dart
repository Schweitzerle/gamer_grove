part of 'statistics_bloc.dart';

/// Base state for statistics
abstract class StatisticsState extends Equatable {
  const StatisticsState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class StatisticsInitial extends StatisticsState {
  /// Creates a StatisticsInitial state
  const StatisticsInitial();
}

/// Loading state
class StatisticsLoading extends StatisticsState {
  /// Creates a StatisticsLoading state
  const StatisticsLoading();
}

/// Loaded state with statistics data
class StatisticsLoaded extends StatisticsState {

  /// Creates a StatisticsLoaded state
  const StatisticsLoaded({
    required this.statistics,
    required this.userId,
  });
  /// The statistics data
  final GameStatistics statistics;

  /// User ID these statistics belong to
  final String userId;

  @override
  List<Object?> get props => [statistics, userId];
}

/// Error state
class StatisticsError extends StatisticsState {

  /// Creates a StatisticsError state
  const StatisticsError(this.message);
  /// Error message
  final String message;

  @override
  List<Object?> get props => [message];
}

/// Empty state when user has no rated games
class StatisticsEmpty extends StatisticsState {

  /// Creates a StatisticsEmpty state
  const StatisticsEmpty({required this.userId});
  /// User ID
  final String userId;

  @override
  List<Object?> get props => [userId];
}
