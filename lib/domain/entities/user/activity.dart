// lib/domain/entities/user/activity.dart

import 'package:equatable/equatable.dart';

/// Types of user activities that can be tracked
enum ActivityType {
  rated,
  recommended,
  wishlisted,
  updatedTopThree,
  followedUser,
  updatedProfile,
}

/// Domain entity representing a user activity.
///
/// Represents actions performed by users that can be displayed in activity feeds.
class Activity extends Equatable {

  const Activity({
    required this.id,
    required this.userId,
    required this.activityType,
    required this.createdAt, this.gameId,
    this.metadata,
    this.isPublic = true,
    this.username,
    this.userAvatarUrl,
    this.userDisplayName,
  });
  final String id;
  final String userId;
  final ActivityType activityType;
  final int? gameId;
  final Map<String, dynamic>? metadata;
  final bool isPublic;
  final DateTime createdAt;

  // Optional user data (populated when fetching activity feed)
  final String? username;
  final String? userAvatarUrl;
  final String? userDisplayName;

  /// Gets the display name or falls back to username
  String get displayName => userDisplayName ?? username ?? 'Unknown User';

  /// Checks if the activity has user data populated
  bool get hasUserData => username != null;

  /// Checks if the activity is related to a game
  bool get hasGameData => gameId != null;

  /// Gets a human-readable description of the activity type
  String get activityTypeDescription {
    switch (activityType) {
      case ActivityType.rated:
        return 'rated a game';
      case ActivityType.recommended:
        return 'recommended a game';
      case ActivityType.wishlisted:
        return 'added to wishlist';
      case ActivityType.updatedTopThree:
        return 'updated top three';
      case ActivityType.followedUser:
        return 'followed a user';
      case ActivityType.updatedProfile:
        return 'updated profile';
    }
  }

  /// Gets the rating from metadata if this is a rating activity
  double? get rating {
    if (activityType == ActivityType.rated && metadata != null) {
      final ratingValue = metadata!['rating'];
      if (ratingValue is num) {
        return ratingValue.toDouble();
      }
    }
    return null;
  }

  /// Gets the position from metadata if this is a top three update
  int? get topThreePosition {
    if (activityType == ActivityType.updatedTopThree && metadata != null) {
      final positionValue = metadata!['position'];
      if (positionValue is int) {
        return positionValue;
      }
    }
    return null;
  }

  /// Gets the followed user ID from metadata if this is a follow activity
  String? get followedUserId {
    if (activityType == ActivityType.followedUser && metadata != null) {
      return metadata!['followed_user_id'] as String?;
    }
    return null;
  }

  /// Creates a copy with modified fields
  Activity copyWith({
    String? id,
    String? userId,
    ActivityType? activityType,
    int? gameId,
    Map<String, dynamic>? metadata,
    bool? isPublic,
    DateTime? createdAt,
    String? username,
    String? userAvatarUrl,
    String? userDisplayName,
  }) {
    return Activity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      activityType: activityType ?? this.activityType,
      gameId: gameId ?? this.gameId,
      metadata: metadata ?? this.metadata,
      isPublic: isPublic ?? this.isPublic,
      createdAt: createdAt ?? this.createdAt,
      username: username ?? this.username,
      userAvatarUrl: userAvatarUrl ?? this.userAvatarUrl,
      userDisplayName: userDisplayName ?? this.userDisplayName,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        activityType,
        gameId,
        metadata,
        isPublic,
        createdAt,
        username,
        userAvatarUrl,
        userDisplayName,
      ];

  @override
  String toString() {
    return 'Activity(id: $id, type: $activityType, user: $displayName, gameId: $gameId)';
  }
}
