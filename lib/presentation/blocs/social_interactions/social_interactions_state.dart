// lib/presentation/blocs/social_interactions/social_interactions_state.dart

import 'package:equatable/equatable.dart';

/// Represents the state of social interactions
class SocialInteractionsState extends Equatable {

  const SocialInteractionsState({
    this.followingStatus = const {},
    this.loadingStatus = const {},
    this.errorMessages = const {},
  });

  /// Initial state
  factory SocialInteractionsState.initial() => const SocialInteractionsState();
  /// Map of userId -> follow status
  final Map<String, bool> followingStatus;

  /// Map of userId -> loading state
  final Map<String, bool> loadingStatus;

  /// Map of userId -> error message
  final Map<String, String?> errorMessages;

  /// Check if following a user
  bool isFollowing(String userId) => followingStatus[userId] ?? false;

  /// Check if loading for a user
  bool isLoading(String userId) => loadingStatus[userId] ?? false;

  /// Get error message for a user
  String? getError(String userId) => errorMessages[userId];

  /// Update follow status for a user
  SocialInteractionsState updateFollowStatus(String userId, bool isFollowing) {
    final newFollowingStatus = Map<String, bool>.from(followingStatus);
    newFollowingStatus[userId] = isFollowing;

    // Clear loading and error
    final newLoadingStatus = Map<String, bool>.from(loadingStatus);
    newLoadingStatus.remove(userId);

    final newErrorMessages = Map<String, String?>.from(errorMessages);
    newErrorMessages.remove(userId);

    return SocialInteractionsState(
      followingStatus: newFollowingStatus,
      loadingStatus: newLoadingStatus,
      errorMessages: newErrorMessages,
    );
  }

  /// Set loading state for a user
  SocialInteractionsState setLoading(String userId, bool isLoading) {
    final newLoadingStatus = Map<String, bool>.from(loadingStatus);
    if (isLoading) {
      newLoadingStatus[userId] = true;
    } else {
      newLoadingStatus.remove(userId);
    }

    // Clear error when starting new operation
    final newErrorMessages = Map<String, String?>.from(errorMessages);
    if (isLoading) {
      newErrorMessages.remove(userId);
    }

    return SocialInteractionsState(
      followingStatus: followingStatus,
      loadingStatus: newLoadingStatus,
      errorMessages: newErrorMessages,
    );
  }

  /// Set error for a user
  SocialInteractionsState setError(String userId, String? error) {
    final newErrorMessages = Map<String, String?>.from(errorMessages);
    if (error != null) {
      newErrorMessages[userId] = error;
    } else {
      newErrorMessages.remove(userId);
    }

    // Clear loading
    final newLoadingStatus = Map<String, bool>.from(loadingStatus);
    newLoadingStatus.remove(userId);

    return SocialInteractionsState(
      followingStatus: followingStatus,
      loadingStatus: newLoadingStatus,
      errorMessages: newErrorMessages,
    );
  }

  SocialInteractionsState copyWith({
    Map<String, bool>? followingStatus,
    Map<String, bool>? loadingStatus,
    Map<String, String?>? errorMessages,
  }) {
    return SocialInteractionsState(
      followingStatus: followingStatus ?? this.followingStatus,
      loadingStatus: loadingStatus ?? this.loadingStatus,
      errorMessages: errorMessages ?? this.errorMessages,
    );
  }

  @override
  List<Object?> get props => [followingStatus, loadingStatus, errorMessages];
}
