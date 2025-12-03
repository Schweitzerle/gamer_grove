// lib/data/models/activity_model.dart

/// Data model for Activity entity.
///
/// Handles JSON serialization/deserialization for user activity feed.
library;

import 'package:gamer_grove/domain/entities/user/activity.dart';

/// Activity model for data layer.
///
/// Represents user activity from Supabase database with JSON conversion.
class ActivityModel {

  const ActivityModel({
    required this.id,
    required this.userId,
    required this.activityType,
    required this.isPublic, required this.createdAt, this.gameId,
    this.metadata,
    this.userData,
  });

  /// Creates an ActivityModel from JSON.
  ///
  /// Example:
  /// ```dart
  /// final json = {
  ///   'id': 'uuid',
  ///   'user_id': 'user-uuid',
  ///   'activity_type': 'rated',
  ///   'game_id': 1942,
  ///   'metadata': {'rating': 9.5},
  ///   'created_at': '2024-01-01T12:00:00Z',
  /// };
  /// final model = ActivityModel.fromJson(json);
  /// ```
  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      activityType: json['activity_type'] as String,
      gameId: json['game_id'] as int?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      isPublic: json['is_public'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      userData: json['profiles'] as Map<String, dynamic>?,
    );
  }

  /// Creates an ActivityModel from domain Activity entity.
  factory ActivityModel.fromEntity(Activity activity) {
    return ActivityModel(
      id: activity.id,
      userId: activity.userId,
      activityType: _mapActivityTypeToString(activity.activityType),
      gameId: activity.gameId,
      metadata: activity.metadata,
      isPublic: activity.isPublic,
      createdAt: activity.createdAt,
      userData: activity.username != null
          ? {
              'username': activity.username,
              'avatar_url': activity.userAvatarUrl,
              'display_name': activity.userDisplayName,
            }
          : null,
    );
  }
  final String id;
  final String userId;
  final String activityType;
  final int? gameId;
  final Map<String, dynamic>? metadata;
  final bool isPublic;
  final DateTime createdAt;

  // Optional: nested user data from join
  final Map<String, dynamic>? userData;

  /// Converts ActivityModel to JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'activity_type': activityType,
      'game_id': gameId,
      'metadata': metadata,
      'is_public': isPublic,
      'created_at': createdAt.toIso8601String(),
      if (userData != null) 'profiles': userData,
    };
  }

  /// Converts ActivityModel to domain Activity entity.
  ///
  /// Example:
  /// ```dart
  /// final activity = activityModel.toEntity();
  /// ```
  Activity toEntity() {
    return Activity(
      id: id,
      userId: userId,
      activityType: _mapActivityType(activityType),
      gameId: gameId,
      metadata: metadata,
      isPublic: isPublic,
      createdAt: createdAt,
      username: userData?['username'] as String?,
      userAvatarUrl: userData?['avatar_url'] as String?,
      userDisplayName: userData?['display_name'] as String?,
    );
  }

  /// Maps string activity type to enum.
  static ActivityType _mapActivityType(String type) {
    switch (type) {
      case 'rated':
        return ActivityType.rated;
      case 'recommended':
        return ActivityType.recommended;
      case 'wishlisted':
        return ActivityType.wishlisted;
      case 'updated_top_three':
        return ActivityType.updatedTopThree;
      case 'followed_user':
        return ActivityType.followedUser;
      case 'updated_profile':
        return ActivityType.updatedProfile;
      default:
        return ActivityType.rated;
    }
  }

  /// Maps enum activity type to string.
  static String _mapActivityTypeToString(ActivityType type) {
    switch (type) {
      case ActivityType.rated:
        return 'rated';
      case ActivityType.recommended:
        return 'recommended';
      case ActivityType.wishlisted:
        return 'wishlisted';
      case ActivityType.updatedTopThree:
        return 'updated_top_three';
      case ActivityType.followedUser:
        return 'followed_user';
      case ActivityType.updatedProfile:
        return 'updated_profile';
    }
  }

  /// Creates a copy with modified fields.
  ActivityModel copyWith({
    String? id,
    String? userId,
    String? activityType,
    int? gameId,
    Map<String, dynamic>? metadata,
    bool? isPublic,
    DateTime? createdAt,
    Map<String, dynamic>? userData,
  }) {
    return ActivityModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      activityType: activityType ?? this.activityType,
      gameId: gameId ?? this.gameId,
      metadata: metadata ?? this.metadata,
      isPublic: isPublic ?? this.isPublic,
      createdAt: createdAt ?? this.createdAt,
      userData: userData ?? this.userData,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ActivityModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ActivityModel(id: $id, type: $activityType, gameId: $gameId)';
  }
}
