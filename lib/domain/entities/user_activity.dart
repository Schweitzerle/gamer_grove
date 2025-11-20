import 'package:equatable/equatable.dart';
import 'package:gamer_grove/domain/entities/user/user.dart';

class UserActivity extends Equatable {

  const UserActivity({
    required this.id,
    required this.user,
    required this.activityType,
    required this.isPublic, required this.createdAt, this.gameId,
    this.metadata,
  });
  final String id;
  final User user;
  final String activityType;
  final int? gameId;
  final Map<String, dynamic>? metadata;
  final bool isPublic;
  final DateTime createdAt;

  @override
  List<Object?> get props => [id, user, activityType, gameId, metadata, isPublic, createdAt];
}
