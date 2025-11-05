import 'package:equatable/equatable.dart';

abstract class ActivityFeedEvent extends Equatable {
  const ActivityFeedEvent();

  @override
  List<Object> get props => [];
}

class LoadActivityFeed extends ActivityFeedEvent {}
