import 'package:equatable/equatable.dart';
import 'package:gamer_grove/domain/entities/user/user.dart';

class UserActivity extends Equatable {
  final String id;
  final User user;
  final String activityType;
  final int? gameId;
  final Map<String, dynamic>? metadata;
  final bool isPublic;
  final DateTime createdAt;

  const UserActivity({
    required this.id,
    required this.user,
    required this.activityType,
    this.gameId,
    this.metadata,
    required this.isPublic,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, user, activityType, gameId, metadata, isPublic, createdAt];
}
