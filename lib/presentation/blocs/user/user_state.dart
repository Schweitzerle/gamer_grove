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

  const UserProfileLoaded(this.user);
  final User user;

  @override
  List<Object> get props => [user];
}

/// State when profile update succeeds.
class UserProfileUpdated extends UserProfileState {

  const UserProfileUpdated(this.user);
  final User user;

  @override
  List<Object> get props => [user];
}

/// State when avatar upload succeeds.
class AvatarUploadSuccess extends UserProfileState {

  const AvatarUploadSuccess(this.avatarUrl);
  final String avatarUrl;

  @override
  List<Object> get props => [avatarUrl];
}

/// State when follow action succeeds.
class FollowSuccess extends UserProfileState {

  const FollowSuccess(this.targetUserId);
  final String targetUserId;

  @override
  List<Object> get props => [targetUserId];
}

/// State when unfollow action succeeds.
class UnfollowSuccess extends UserProfileState {

  const UnfollowSuccess(this.targetUserId);
  final String targetUserId;

  @override
  List<Object> get props => [targetUserId];
}

/// State when followers are loaded.
class FollowersLoaded extends UserProfileState {

  const FollowersLoaded(this.followers);
  final List<User> followers;

  @override
  List<Object> get props => [followers];
}

/// State when following list is loaded.
class FollowingLoaded extends UserProfileState {

  const FollowingLoaded(this.following);
  final List<User> following;

  @override
  List<Object> get props => [following];
}

/// State when operation fails.
class UserProfileError extends UserProfileState {

  const UserProfileError(this.message);
  final String message;

  @override
  List<Object> get props => [message];
}
