// lib/presentation/blocs/social_interactions/social_interactions_event.dart

import 'package:equatable/equatable.dart';

/// Base class for social interaction events
abstract class SocialInteractionsEvent extends Equatable {
  const SocialInteractionsEvent();

  @override
  List<Object?> get props => [];
}

/// Event to follow a user
class FollowUserRequested extends SocialInteractionsEvent {

  const FollowUserRequested(this.targetUserId);
  final String targetUserId;

  @override
  List<Object?> get props => [targetUserId];
}

/// Event to unfollow a user
class UnfollowUserRequested extends SocialInteractionsEvent {

  const UnfollowUserRequested(this.targetUserId);
  final String targetUserId;

  @override
  List<Object?> get props => [targetUserId];
}

/// Event to toggle follow status (smart follow/unfollow)
class ToggleFollowRequested extends SocialInteractionsEvent {

  const ToggleFollowRequested(this.targetUserId, this.isCurrentlyFollowing);
  final String targetUserId;
  final bool isCurrentlyFollowing;

  @override
  List<Object?> get props => [targetUserId, isCurrentlyFollowing];
}

/// Event to load initial follow status for a user
class LoadFollowStatusRequested extends SocialInteractionsEvent {

  const LoadFollowStatusRequested(this.targetUserId);
  final String targetUserId;

  @override
  List<Object?> get props => [targetUserId];
}
