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

  const ActivityFeedLoading(this.currentStep, this.progress);
  final ActivityFeedLoadingStep currentStep;
  final double progress;

  @override
  List<Object> get props => [currentStep, progress];
}

class ActivityFeedLoaded extends ActivityFeedState {

  const ActivityFeedLoaded(this.activities, this.games);
  final List<UserActivity> activities;
  final List<Game> games;

  @override
  List<Object> get props => [activities, games];
}

class ActivityFeedError extends ActivityFeedState {

  const ActivityFeedError(this.message);
  final String message;

  @override
  List<Object> get props => [message];
}
