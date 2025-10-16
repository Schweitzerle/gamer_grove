// ============================================================
// BLOC
// ============================================================

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamer_grove/domain/usecases/user/follow_user.dart';
import 'package:gamer_grove/domain/usecases/user/get_user_followers.dart';
import 'package:gamer_grove/domain/usecases/user/get_user_following.dart';
import 'package:gamer_grove/domain/usecases/user/get_user_profile.dart';
import 'package:gamer_grove/domain/usecases/user/unfollow_user.dart';
import 'package:gamer_grove/domain/usecases/user/update_user_avatar.dart';
import 'package:gamer_grove/domain/usecases/user/update_user_profile.dart';
import 'package:gamer_grove/presentation/blocs/user/user_event.dart';
import 'package:gamer_grove/presentation/blocs/user/user_state.dart';

/// BLoC for handling user profile operations.
///
/// Example:
/// ```dart
/// // Load profile
/// context.read<UserProfileBloc>().add(
///   LoadUserProfileEvent(userId: 'uuid'),
/// );
///
/// // Update profile
/// context.read<UserProfileBloc>().add(
///   UpdateUserProfileEvent(
///     userId: 'uuid',
///     updates: {'display_name': 'John Doe', 'bio': 'Gamer'},
///   ),
/// );
///
/// // Follow user
/// context.read<UserProfileBloc>().add(
///   FollowUserEvent(
///     currentUserId: currentUser.id,
///     targetUserId: targetUser.id,
///   ),
/// );
/// ```
class UserProfileBloc extends Bloc<UserProfileEvent, UserProfileState> {
  final GetUserProfileUseCase getUserProfileUseCase;
  final UpdateUserProfileUseCase updateUserProfileUseCase;
  final UpdateUserAvatarUseCase updateUserAvatarUseCase;
  final FollowUserUseCase followUserUseCase;
  final UnfollowUserUseCase unfollowUserUseCase;
  final GetFollowersUseCase getFollowersUseCase;
  final GetFollowingUseCase getFollowingUseCase;

  UserProfileBloc({
    required this.getUserProfileUseCase,
    required this.updateUserProfileUseCase,
    required this.updateUserAvatarUseCase,
    required this.followUserUseCase,
    required this.unfollowUserUseCase,
    required this.getFollowersUseCase,
    required this.getFollowingUseCase,
  }) : super(const UserProfileInitial()) {
    on<LoadUserProfileEvent>(_onLoadUserProfile);
    on<UpdateUserProfileEvent>(_onUpdateUserProfile);
    on<UpdateUserAvatarEvent>(_onUpdateUserAvatar);
    on<FollowUserEvent>(_onFollowUser);
    on<UnfollowUserEvent>(_onUnfollowUser);
    on<LoadFollowersEvent>(_onLoadFollowers);
    on<LoadFollowingEvent>(_onLoadFollowing);
  }

  /// Loads a user profile by ID or username.
  Future<void> _onLoadUserProfile(
    LoadUserProfileEvent event,
    Emitter<UserProfileState> emit,
  ) async {
    emit(const UserProfileLoading());

    final result = await getUserProfileUseCase(
      GetUserProfileParams(
        userId: event.userId,
        username: event.username,
      ),
    );

    result.fold(
      (failure) => emit(UserProfileError(failure.message)),
      (user) => emit(UserProfileLoaded(user)),
    );
  }

  /// Updates user profile data.
  Future<void> _onUpdateUserProfile(
    UpdateUserProfileEvent event,
    Emitter<UserProfileState> emit,
  ) async {
    emit(const UserProfileLoading());

    final result = await updateUserProfileUseCase(
      UpdateUserProfileParams(
        userId: event.userId,
        updates: event.updates,
      ),
    );

    result.fold(
      (failure) => emit(UserProfileError(failure.message)),
      (user) => emit(UserProfileUpdated(user)),
    );
  }

  /// Uploads and updates user avatar.
  Future<void> _onUpdateUserAvatar(
    UpdateUserAvatarEvent event,
    Emitter<UserProfileState> emit,
  ) async {
    emit(const UserProfileLoading());

    final result = await updateUserAvatarUseCase(
      UpdateUserAvatarParams(
        userId: event.userId,
        imageData: event.imageData,
      ),
    );

    result.fold(
      (failure) => emit(UserProfileError(failure.message)),
      (avatarUrl) => emit(AvatarUploadSuccess(avatarUrl)),
    );
  }

  /// Follows a user.
  Future<void> _onFollowUser(
    FollowUserEvent event,
    Emitter<UserProfileState> emit,
  ) async {
    // Store current state to restore if needed

    emit(const UserProfileLoading());

    final result = await followUserUseCase(
      FollowUserParams(
        currentUserId: event.currentUserId,
        targetUserId: event.targetUserId,
      ),
    );

    result.fold(
      (failure) => emit(UserProfileError(failure.message)),
      (_) => emit(FollowSuccess(event.targetUserId)),
    );
  }

  /// Unfollows a user.
  Future<void> _onUnfollowUser(
    UnfollowUserEvent event,
    Emitter<UserProfileState> emit,
  ) async {
    emit(const UserProfileLoading());

    final result = await unfollowUserUseCase(
      UnfollowUserParams(
        currentUserId: event.currentUserId,
        targetUserId: event.targetUserId,
      ),
    );

    result.fold(
      (failure) => emit(UserProfileError(failure.message)),
      (_) => emit(UnfollowSuccess(event.targetUserId)),
    );
  }

  /// Loads followers list.
  Future<void> _onLoadFollowers(
    LoadFollowersEvent event,
    Emitter<UserProfileState> emit,
  ) async {
    emit(const UserProfileLoading());

    final result = await getFollowersUseCase(
      GetFollowersParams(
        userId: event.userId,
        limit: event.limit,
        offset: event.offset,
      ),
    );

    result.fold(
      (failure) => emit(UserProfileError(failure.message)),
      (followers) => emit(FollowersLoaded(followers)),
    );
  }

  /// Loads following list.
  Future<void> _onLoadFollowing(
    LoadFollowingEvent event,
    Emitter<UserProfileState> emit,
  ) async {
    emit(const UserProfileLoading());

    final result = await getFollowingUseCase(
      GetFollowingParams(
        userId: event.userId,
        limit: event.limit,
        offset: event.offset,
      ),
    );

    result.fold(
      (failure) => emit(UserProfileError(failure.message)),
      (following) => emit(FollowingLoaded(following)),
    );
  }
}
