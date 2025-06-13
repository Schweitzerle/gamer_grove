// domain/repositories/user_repository.dart
import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/user.dart';

abstract class UserRepository {
  Future<Either<Failure, User>> getUserProfile(String userId);

  Future<Either<Failure, User>> updateUserProfile({
    required String userId,
    String? username,
    String? bio,
    String? avatarUrl,
    String? country,
  });

  Future<Either<Failure, void>> updateTopThreeGames({
    required String userId,
    required List<int> gameIds,
  });

  Future<Either<Failure, void>> followUser({
    required String currentUserId,
    required String targetUserId,
  });

  Future<Either<Failure, void>> unfollowUser({
    required String currentUserId,
    required String targetUserId,
  });

  Future<Either<Failure, List<User>>> searchUsers(String query);

  Future<Either<Failure, List<User>>> getUserFollowers(String userId);

  Future<Either<Failure, List<User>>> getUserFollowing(String userId);

  Future<Either<Failure, List<int>>> getUserTopThreeGames(String userId);

  Future<Either<Failure, void>> updateUserTopThreeGames(String userId, List<int> gameIds);
}