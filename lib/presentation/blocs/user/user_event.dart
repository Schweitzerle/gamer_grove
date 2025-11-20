// lib/presentation/blocs/user_profile/user_profile_bloc.dart

/// User Profile BLoC for handling user profile operations.
library;

import 'package:equatable/equatable.dart';

// ============================================================
// EVENTS
// ============================================================

abstract class UserProfileEvent extends Equatable {
  const UserProfileEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load a user profile.
class LoadUserProfileEvent extends UserProfileEvent {

  const LoadUserProfileEvent({
    this.userId,
    this.username,
  });
  final String? userId;
  final String? username;

  @override
  List<Object?> get props => [userId, username];
}

/// Event to update user profile.
class UpdateUserProfileEvent extends UserProfileEvent {

  const UpdateUserProfileEvent({
    required this.userId,
    required this.updates,
  });
  final String userId;
  final Map<String, dynamic> updates;

  @override
  List<Object> get props => [userId, updates];
}

/// Event to update user avatar.
class UpdateUserAvatarEvent extends UserProfileEvent {

  const UpdateUserAvatarEvent({
    required this.userId,
    required this.imageData,
  });
  final String userId;
  final String imageData;

  @override
  List<Object> get props => [userId, imageData];
}

/// Event to follow a user.
class FollowUserEvent extends UserProfileEvent {

  const FollowUserEvent({
    required this.currentUserId,
    required this.targetUserId,
  });
  final String currentUserId;
  final String targetUserId;

  @override
  List<Object> get props => [currentUserId, targetUserId];
}

/// Event to unfollow a user.
class UnfollowUserEvent extends UserProfileEvent {

  const UnfollowUserEvent({
    required this.currentUserId,
    required this.targetUserId,
  });
  final String currentUserId;
  final String targetUserId;

  @override
  List<Object> get props => [currentUserId, targetUserId];
}

/// Event to load followers list.
class LoadFollowersEvent extends UserProfileEvent {

  const LoadFollowersEvent({
    required this.userId,
    this.limit,
    this.offset,
  });
  final String userId;
  final int? limit;
  final int? offset;

  @override
  List<Object?> get props => [userId, limit, offset];
}

/// Event to load following list.
class LoadFollowingEvent extends UserProfileEvent {

  const LoadFollowingEvent({
    required this.userId,
    this.limit,
    this.offset,
  });
  final String userId;
  final int? limit;
  final int? offset;

  @override
  List<Object?> get props => [userId, limit, offset];
}
