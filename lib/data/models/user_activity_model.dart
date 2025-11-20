import 'package:gamer_grove/data/models/user_model.dart';
import 'package:gamer_grove/domain/entities/user_activity.dart';

class UserActivityModel extends UserActivity {
  const UserActivityModel({
    required super.id,
    required super.user,
    required super.activityType,
    required super.isPublic, required super.createdAt, super.gameId,
    super.metadata,
  });

  factory UserActivityModel.fromJson(Map<String, dynamic> json) {
    return UserActivityModel(
      id: json['id'],
      user: UserModel.fromJson(json['user']).toEntity(),
      activityType: json['activity_type'],
      gameId: json['game_id'],
      metadata: json['metadata'] as Map<String, dynamic>?,
      isPublic: json['is_public'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': user.id,
      'activity_type': activityType,
      'game_id': gameId,
      'metadata': metadata,
      'is_public': isPublic,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
