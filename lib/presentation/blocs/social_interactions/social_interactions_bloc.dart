// lib/presentation/blocs/social_interactions/social_interactions_bloc.dart

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/user_repository.dart';
import '../../../domain/usecases/user/follow_user.dart';
import '../../../domain/usecases/user/unfollow_user.dart';
import 'social_interactions_event.dart';
import 'social_interactions_state.dart';

/// BLoC for handling social interactions (follow/unfollow)
class SocialInteractionsBloc
    extends Bloc<SocialInteractionsEvent, SocialInteractionsState> {
  final FollowUserUseCase followUser;
  final UnfollowUserUseCase unfollowUser;
  final UserRepository userRepository;
  final String? currentUserId;

  SocialInteractionsBloc({
    required this.followUser,
    required this.unfollowUser,
    required this.userRepository,
    this.currentUserId,
  }) : super(SocialInteractionsState.initial()) {
    on<FollowUserRequested>(_onFollowUserRequested);
    on<UnfollowUserRequested>(_onUnfollowUserRequested);
    on<ToggleFollowRequested>(_onToggleFollowRequested);
    on<LoadFollowStatusRequested>(_onLoadFollowStatusRequested);
  }

  /// Handle follow user request
  Future<void> _onFollowUserRequested(
    FollowUserRequested event,
    Emitter<SocialInteractionsState> emit,
  ) async {
    if (currentUserId == null) {
      emit(state.setError(event.targetUserId, 'You must be logged in'));
      return;
    }

    emit(state.setLoading(event.targetUserId, true));

    final result = await followUser(
      FollowUserParams(
        currentUserId: currentUserId!,
        targetUserId: event.targetUserId,
      ),
    );

    result.fold(
      (failure) => emit(state.setError(event.targetUserId, failure.message)),
      (_) => emit(state.updateFollowStatus(event.targetUserId, true)),
    );
  }

  /// Handle unfollow user request
  Future<void> _onUnfollowUserRequested(
    UnfollowUserRequested event,
    Emitter<SocialInteractionsState> emit,
  ) async {
    if (currentUserId == null) {
      emit(state.setError(event.targetUserId, 'You must be logged in'));
      return;
    }

    emit(state.setLoading(event.targetUserId, true));

    final result = await unfollowUser(
      UnfollowUserParams(
        currentUserId: currentUserId!,
        targetUserId: event.targetUserId,
      ),
    );

    result.fold(
      (failure) => emit(state.setError(event.targetUserId, failure.message)),
      (_) => emit(state.updateFollowStatus(event.targetUserId, false)),
    );
  }

  /// Handle toggle follow request (smart follow/unfollow)
  Future<void> _onToggleFollowRequested(
    ToggleFollowRequested event,
    Emitter<SocialInteractionsState> emit,
  ) async {
    if (event.isCurrentlyFollowing) {
      add(UnfollowUserRequested(event.targetUserId));
    } else {
      add(FollowUserRequested(event.targetUserId));
    }
  }

  /// Handle loading initial follow status
  Future<void> _onLoadFollowStatusRequested(
    LoadFollowStatusRequested event,
    Emitter<SocialInteractionsState> emit,
  ) async {
    if (currentUserId == null) {
      return;
    }

    final result = await userRepository.isFollowing(
      currentUserId: currentUserId!,
      targetUserId: event.targetUserId,
    );

    result.fold(
      (failure) {
        // Silently fail - assume not following
        emit(state.updateFollowStatus(event.targetUserId, false));
      },
      (isFollowing) {
        emit(state.updateFollowStatus(event.targetUserId, isFollowing));
      },
    );
  }
}
