// ==========================================

// lib/domain/entities/user/user_relationship.dart
import 'package:equatable/equatable.dart';

enum RelationshipStatus {
  none,
  following,
  followedBy,
  mutual, // Both following each other
}

class UserRelationship extends Equatable {

  const UserRelationship({
    required this.userId,
    required this.targetUserId,
    required this.status,
    this.followedAt,
    this.followedBackAt,
  });
  final String userId;
  final String targetUserId;
  final RelationshipStatus status;
  final DateTime? followedAt;
  final DateTime? followedBackAt;

  bool get isFollowing => status == RelationshipStatus.following || status == RelationshipStatus.mutual;
  bool get isFollowedBy => status == RelationshipStatus.followedBy || status == RelationshipStatus.mutual;
  bool get isMutual => status == RelationshipStatus.mutual;

  @override
  List<Object?> get props => [userId, targetUserId, status, followedAt, followedBackAt];
}