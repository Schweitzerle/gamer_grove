// data/repositories/user_repository_impl.dart
import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/local/cache_datasource.dart';
import '../datasources/remote/supabase_remote_datasource.dart';

class UserRepositoryImpl implements UserRepository {
  final SupabaseRemoteDataSource remoteDataSource;
  final LocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  UserRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, User>> getUserProfile(String userId) async {
    if (!await networkInfo.isConnected) {
      // Try to get from cache
      final cachedUser = await localDataSource.getCachedUser();
      if (cachedUser != null && cachedUser.id == userId) {
        return Right(cachedUser);
      }
      return const Left(NetworkFailure());
    }

    try {
      final user = await remoteDataSource.getUserProfile(userId);

      // Cache if it's the current user
      final currentUser = await remoteDataSource.getCurrentUser();
      if (currentUser?.id == userId) {
        await localDataSource.cacheUser(user);
      }

      return Right(user);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, User>> updateUserProfile({
    required String userId,
    String? username,
    String? bio,
    String? avatarUrl,
    String? country,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final updates = <String, dynamic>{};
      if (username != null) updates['username'] = username;
      if (bio != null) updates['bio'] = bio;
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;
      if (country != null) updates['country'] = country;

      final updatedUser = await remoteDataSource.updateUserProfile(userId, updates);

      // Update cache
      await localDataSource.cacheUser(updatedUser);

      return Right(updatedUser);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> updateTopThreeGames({
    required String userId,
    required List<int> gameIds,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    if (gameIds.length > 3) {
      return const Left(ValidationFailure(message: 'Cannot select more than 3 games'));
    }

    try {
      await remoteDataSource.updateTopThreeGames(userId, gameIds);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> followUser({
    required String currentUserId,
    required String targetUserId,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    if (currentUserId == targetUserId) {
      return const Left(ValidationFailure(message: 'Cannot follow yourself'));
    }

    try {
      await remoteDataSource.followUser(currentUserId, targetUserId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> unfollowUser({
    required String currentUserId,
    required String targetUserId,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      await remoteDataSource.unfollowUser(currentUserId, targetUserId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<User>>> searchUsers(String query) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    if (query.length < 2) {
      return const Left(ValidationFailure(message: 'Search query too short'));
    }

    try {
      final users = await remoteDataSource.searchUsers(query);
      return Right(users);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<User>>> getUserFollowers(String userId) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final followerIds = await remoteDataSource.getUserFollowers(userId);
      final followers = <User>[];

      // Get user details for each follower
      for (final followerId in followerIds) {
        try {
          final user = await remoteDataSource.getUserProfile(followerId);
          followers.add(user);
        } catch (_) {
          // Skip if we can't get a follower's details
        }
      }

      return Right(followers);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<User>>> getUserFollowing(String userId) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final followingIds = await remoteDataSource.getUserFollowing(userId);
      final following = <User>[];

      // Get user details for each followed user
      for (final followingId in followingIds) {
        try {
          final user = await remoteDataSource.getUserProfile(followingId);
          following.add(user);
        } catch (_) {
          // Skip if we can't get a user's details
        }
      }

      return Right(following);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return const Left(ServerFailure());
    }
  }

  // In der Repository Implementation anpassen:
  @override
  Future<Either<Failure, List<int>>> getUserTopThreeGames(String userId) async {
    if (await networkInfo.isConnected) {
      try {
        final topThreeData = await remoteDataSource.getTopThreeGamesWithPosition(userId);
        // Extrahiere nur die game_ids
        final topThreeIds = topThreeData
            .map<int>((item) => item['game_id'] as int)
            .toList();
        return Right(topThreeIds);
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, void>> updateUserTopThreeGames(String userId, List<int> gameIds) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.updateTopThreeGames(userId, gameIds);
        return const Right(null);
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }
}