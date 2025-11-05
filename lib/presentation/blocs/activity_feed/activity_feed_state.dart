import 'package:equatable/equatable.dart';
import 'package:gamer_grove/domain/entities/game/game.dart';
import 'package:gamer_grove/domain/entities/user_activity.dart';
import 'package:gamer_grove/presentation/blocs/activity_feed/activity_feed_loading_steps.dart';

abstract class ActivityFeedState extends Equatable {
  const ActivityFeedState();

  @override
  List<Object> get props => [];
}

class ActivityFeedInitial extends ActivityFeedState {}

class ActivityFeedLoading extends ActivityFeedState {
  final ActivityFeedLoadingStep currentStep;
  final double progress;

  const ActivityFeedLoading(this.currentStep, this.progress);

  @override
  List<Object> get props => [currentStep, progress];
}

class ActivityFeedLoaded extends ActivityFeedState {
  final List<UserActivity> activities;
  final List<Game> games;

  const ActivityFeedLoaded(this.activities, this.games);

  @override
  List<Object> get props => [activities, games];
}

class ActivityFeedError extends ActivityFeedState {
  final String message;

  const ActivityFeedError(this.message);

  @override
  List<Object> get props => [message];
}
