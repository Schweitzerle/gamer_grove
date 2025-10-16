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
  final String? userId;
  final String? username;

  const LoadUserProfileEvent({
    this.userId,
    this.username,
  });

  @override
  List<Object?> get props => [userId, username];
}

/// Event to update user profile.
class UpdateUserProfileEvent extends UserProfileEvent {
  final String userId;
  final Map<String, dynamic> updates;

  const UpdateUserProfileEvent({
    required this.userId,
    required this.updates,
  });

  @override
  List<Object> get props => [userId, updates];
}

/// Event to update user avatar.
class UpdateUserAvatarEvent extends UserProfileEvent {
  final String userId;
  final String imageData;

  const UpdateUserAvatarEvent({
    required this.userId,
    required this.imageData,
  });

  @override
  List<Object> get props => [userId, imageData];
}

/// Event to follow a user.
class FollowUserEvent extends UserProfileEvent {
  final String currentUserId;
  final String targetUserId;

  const FollowUserEvent({
    required this.currentUserId,
    required this.targetUserId,
  });

  @override
  List<Object> get props => [currentUserId, targetUserId];
}

/// Event to unfollow a user.
class UnfollowUserEvent extends UserProfileEvent {
  final String currentUserId;
  final String targetUserId;

  const UnfollowUserEvent({
    required this.currentUserId,
    required this.targetUserId,
  });

  @override
  List<Object> get props => [currentUserId, targetUserId];
}

/// Event to load followers list.
class LoadFollowersEvent extends UserProfileEvent {
  final String userId;
  final int? limit;
  final int? offset;

  const LoadFollowersEvent({
    required this.userId,
    this.limit,
    this.offset,
  });

  @override
  List<Object?> get props => [userId, limit, offset];
}

/// Event to load following list.
class LoadFollowingEvent extends UserProfileEvent {
  final String userId;
  final int? limit;
  final int? offset;

  const LoadFollowingEvent({
    required this.userId,
    this.limit,
    this.offset,
  });

  @override
  List<Object?> get props => [userId, limit, offset];
}
