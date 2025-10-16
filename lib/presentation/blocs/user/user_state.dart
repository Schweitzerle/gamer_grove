// ============================================================
// STATES
// ============================================================

import 'package:equatable/equatable.dart';
import 'package:gamer_grove/domain/entities/user/user.dart';

abstract class UserProfileState extends Equatable {
  const UserProfileState();

  @override
  List<Object?> get props => [];
}

/// Initial state.
class UserProfileInitial extends UserProfileState {
  const UserProfileInitial();
}

/// Loading state during profile operations.
class UserProfileLoading extends UserProfileState {
  const UserProfileLoading();
}

/// State when profile is loaded successfully.
class UserProfileLoaded extends UserProfileState {
  final User user;

  const UserProfileLoaded(this.user);

  @override
  List<Object> get props => [user];
}

/// State when profile update succeeds.
class UserProfileUpdated extends UserProfileState {
  final User user;

  const UserProfileUpdated(this.user);

  @override
  List<Object> get props => [user];
}

/// State when avatar upload succeeds.
class AvatarUploadSuccess extends UserProfileState {
  final String avatarUrl;

  const AvatarUploadSuccess(this.avatarUrl);

  @override
  List<Object> get props => [avatarUrl];
}

/// State when follow action succeeds.
class FollowSuccess extends UserProfileState {
  final String targetUserId;

  const FollowSuccess(this.targetUserId);

  @override
  List<Object> get props => [targetUserId];
}

/// State when unfollow action succeeds.
class UnfollowSuccess extends UserProfileState {
  final String targetUserId;

  const UnfollowSuccess(this.targetUserId);

  @override
  List<Object> get props => [targetUserId];
}

/// State when followers are loaded.
class FollowersLoaded extends UserProfileState {
  final List<User> followers;

  const FollowersLoaded(this.followers);

  @override
  List<Object> get props => [followers];
}

/// State when following list is loaded.
class FollowingLoaded extends UserProfileState {
  final List<User> following;

  const FollowingLoaded(this.following);

  @override
  List<Object> get props => [following];
}

/// State when operation fails.
class UserProfileError extends UserProfileState {
  final String message;

  const UserProfileError(this.message);

  @override
  List<Object> get props => [message];
}
