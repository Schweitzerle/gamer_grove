// lib/data/repositories/user_repository_impl.dart - ENHANCED VERSION
import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/user/user.dart';
import '../../domain/entities/user/user_relationship.dart';
import '../../domain/entities/user/user_gaming_activity.dart';
import '../../domain/entities/game/game.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/local/cache_datasource.dart';
import '../datasources/remote/supabase/supabase_remote_datasource.dart';
import '../models/user_model.dart';

class UserRepositoryImpl implements UserRepository {
  final SupabaseRemoteDataSource remoteDataSource;
  final LocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  UserRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  // ==========================================
  // CORE USER PROFILE METHODS
  // ==========================================

  @override
  Future<Either<Failure, User>> getUserProfile({
    required String userId,
    String? currentUserId,
  }) async {
    if (!await networkInfo.isConnected) {
      // Try to get from cache if it's the current user
      if (currentUserId != null && userId == currentUserId) {
        final cachedUser = await localDataSource.getCachedUser();
        if (cachedUser != null) {
          return Right(cachedUser);
        }
      }
      return const Left(NetworkFailure());
    }

    try {
      final user = await remoteDataSource.getUserProfile(userId, currentUserId);

      // Cache if it's the current user
      if (currentUserId != null && userId == currentUserId) {
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
  Future<Either<Failure, User>> getCurrentUserProfile() async {
    if (!await networkInfo.isConnected) {
      final cachedUser = await localDataSource.getCachedUser();
      if (cachedUser != null) {
        return Right(cachedUser);
      }
      return const Left(NetworkFailure());
    }

    try {
      final user = await remoteDataSource.getCurrentUserProfile();
      await localDataSource.cacheUser(user);
      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthenticationFailure(message: e.message));
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
    bool? isProfilePublic,
    bool? showRatedGames,
    bool? showRecommendedGames,
    bool? showTopThree,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final updatedUser = await remoteDataSource.updateUserProfile(
        userId: userId,
        username: username,
        bio: bio,
        avatarUrl: avatarUrl,
        country: country,
        isProfilePublic: isProfilePublic,
        showRatedGames: showRatedGames,
        showRecommendedGames: showRecommendedGames,
        showTopThree: showTopThree,
      );

      // Update cache if it's the current user
      final currentUser = await remoteDataSource.getCurrentUser();
      if (currentUser?.id == userId) {
        await localDataSource.cacheUser(updatedUser);
      }

      return Right(updatedUser);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, String>> updateUserAvatar({
    required String userId,
    required String imageData,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final avatarUrl = await remoteDataSource.updateUserAvatar(
        userId: userId,
        imageData: imageData,
      );
      return Right(avatarUrl);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return const Left(ServerFailure());
    }
  }

  // ==========================================
  // SOCIAL FEATURES - FOLLOW SYSTEM
  // ==========================================

  @override
  Future<Either<Failure, void>> followUser({
    required String currentUserId,
    required String targetUserId,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      await remoteDataSource.followUser(
        currentUserId: currentUserId,
        targetUserId: targetUserId,
      );
      return const Right(null);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.message));
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
      await remoteDataSource.unfollowUser(
        currentUserId: currentUserId,
        targetUserId: targetUserId,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> isFollowing({
    required String currentUserId,
    required String targetUserId,
  }) async {
    try {
      final isFollowing = await remoteDataSource.isFollowing(
        currentUserId: currentUserId,
        targetUserId: targetUserId,
      );
      return Right(isFollowing);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, UserRelationship>> getUserRelationship({
    required String currentUserId,
    required String targetUserId,
  }) async {
    try {
      final relationship = await remoteDataSource.getUserRelationship(
        currentUserId: currentUserId,
        targetUserId: targetUserId,
      );
      return Right(relationship);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<User>>> getUserFollowers({
    required String userId,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final followers = await remoteDataSource.getUserFollowers(
        userId: userId,
        limit: limit,
        offset: offset,
      );
      return Right(followers);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<User>>> getUserFollowing({
    required String userId,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final following = await remoteDataSource.getUserFollowing(
        userId: userId,
        limit: limit,
        offset: offset,
      );
      return Right(following);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<User>>> getMutualFollowers({
    required String currentUserId,
    required String targetUserId,
    int limit = 20,
  }) async {
    try {
      final mutualFollowers = await remoteDataSource.getMutualFollowers(
        currentUserId: currentUserId,
        targetUserId: targetUserId,
        limit: limit,
      );
      return Right(mutualFollowers);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<User>>> getFollowSuggestions({
    required String userId,
    int limit = 20,
  }) async {
    try {
      final suggestions = await remoteDataSource.getFollowSuggestions(
        userId: userId,
        limit: limit,
      );
      return Right(suggestions);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return const Left(ServerFailure());
    }
  }

  // ==========================================
  // USER SEARCH & DISCOVERY
  // ==========================================

  @override
  Future<Either<Failure, List<User>>> searchUsers({
    required String query,
    String? currentUserId,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final users = await remoteDataSource.searchUsers(
        query: query,
        currentUserId: currentUserId,
        limit: limit,
        offset: offset,
      );
      return Right(users);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<User>>> getPopularUsers({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final users = await remoteDataSource.getPopularUsers(
        limit: limit,
        offset: offset,
      );
      return Right(users);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<User>>> getNewUsers({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final users = await remoteDataSource.getNewUsers(
        limit: limit,
        offset: offset,
      );
      return Right(users);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<User>>> getSimilarUsers({
    required String userId,
    int limit = 20,
  }) async {
    try {
      final users = await remoteDataSource.getSimilarUsers(
        userId: userId,
        limit: limit,
      );
      return Right(users);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return const Left(ServerFailure());
    }
  }

  // ==========================================
  // TOP THREE GAMES MANAGEMENT
  // ==========================================

  @override
  Future<Either<Failure, void>> updateTopThreeGames({
    required String userId,
    required List<int> gameIds,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      await remoteDataSource.updateTopThreeGames(
        userId: userId,
        gameIds: gameIds,
      );
      return const Right(null);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<Game>>> getUserTopThreeGames({
    required String userId,
  }) async {
    try {
      final games = await remoteDataSource.getUserTopThreeGames(userId: userId);
      return Right(games);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> setTopThreeGameAtPosition({
    required String userId,
    required int position,
    required int gameId,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      await remoteDataSource.setTopThreeGameAtPosition(
        userId: userId,
        position: position,
        gameId: gameId,
      );
      return const Right(null);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> removeFromTopThree({
    required String userId,
    required int position,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      await remoteDataSource.removeFromTopThree(
        userId: userId,
        position: position,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> reorderTopThree({
    required String userId,
    required Map<int, int> positionToGameId,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      await remoteDataSource.reorderTopThree(
        userId: userId,
        positionToGameId: positionToGameId,
      );
      return const Right(null);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return const Left(ServerFailure());
    }
  }

  // ==========================================
  // USER GAME COLLECTIONS (PUBLIC VISIBILITY)
  // ==========================================

  @override
  Future<Either<Failure, List<Game>>> getUserPublicRatedGames({
    required String userId,
    String? currentUserId,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final games = await remoteDataSource.getUserPublicRatedGames(
        userId: userId,
        currentUserId: currentUserId,
        limit: limit,
        offset: offset,
      );
      return Right(games);
    } on UnauthorizedException catch (e) {
      return Left(AuthorizationFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<Game>>> getUserPublicRecommendedGames({
    required String userId,
    String? currentUserId,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final games = await remoteDataSource.getUserPublicRecommendedGames(
        userId: userId,
        currentUserId: currentUserId,
        limit: limit,
        offset: offset,
      );
      return Right(games);
    } on UnauthorizedException catch (e) {
      return Left(AuthorizationFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getUserPublicCollections({
    required String userId,
    String? currentUserId,
  }) async {
    try {
      final collections = await remoteDataSource.getUserPublicCollections(
        userId: userId,
        currentUserId: currentUserId,
      );
      return Right(collections);
    } on UnauthorizedException catch (e) {
      return Left(AuthorizationFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return const Left(ServerFailure());
    }
  }

  // ==========================================
  // USER ACTIVITY & ANALYTICS
  // ==========================================

  @override
  Future<Either<Failure, UserGamingActivity>> getUserActivity({
    required String userId,
    Duration? timeWindow,
  }) async {
    try {
      final activity = await remoteDataSource.getUserActivity(
        userId: userId,
        timeWindow: timeWindow,
      );
      return Right(activity);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getUserGamingStats({
    required String userId,
    String? currentUserId,
  }) async {
    try {
      final stats = await remoteDataSource.getUserGamingStats(
        userId: userId,
        currentUserId: currentUserId,
      );
      return Right(stats);
    } on UnauthorizedException catch (e) {
      return Left(AuthorizationFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getUserRecentActivity({
    required String userId,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final activity = await remoteDataSource.getUserRecentActivity(
        userId: userId,
        limit: limit,
        offset: offset,
      );
      return Right(activity);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return const Left(ServerFailure());
    }
  }

  // ==========================================
  // SOCIAL FEED & ACTIVITY
  // ==========================================

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getUserFeed({
    required String userId,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final feed = await remoteDataSource.getUserFeed(
        userId: userId,
        limit: limit,
        offset: offset,
      );
      return Right(feed);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getGlobalFeed({
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final feed = await remoteDataSource.getGlobalFeed(
        limit: limit,
        offset: offset,
      );
      return Right(feed);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<User>>> getTrendingUsers({
    Duration? timeWindow,
    int limit = 20,
  }) async {
    try {
      final users = await remoteDataSource.getTrendingUsers(
        timeWindow: timeWindow,
        limit: limit,
      );
      return Right(users);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return const Left(ServerFailure());
    }
  }

  // ==========================================
  // USER PRIVACY & SETTINGS
  // ==========================================

  @override
  Future<Either<Failure, void>> updatePrivacySettings({
    required String userId,
    bool? isProfilePublic,
    bool? showRatedGames,
    bool? showRecommendedGames,
    bool? showTopThree,
    bool? allowFollowRequests,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      await remoteDataSource.updatePrivacySettings(
        userId: userId,
        isProfilePublic: isProfilePublic,
        showRatedGames: showRatedGames,
        showRecommendedGames: showRecommendedGames,
        showTopThree: showTopThree,
        allowFollowRequests: allowFollowRequests,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> blockUser({
    required String currentUserId,
    required String targetUserId,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      await remoteDataSource.blockUser(
        currentUserId: currentUserId,
        targetUserId: targetUserId,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> unblockUser({
    required String currentUserId,
    required String targetUserId,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      await remoteDataSource.unblockUser(
        currentUserId: currentUserId,
        targetUserId: targetUserId,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<User>>> getBlockedUsers({
    required String userId,
  }) async {
    try {
      final users = await remoteDataSource.getBlockedUsers(userId: userId);
      return Right(users);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> isUserBlocked({
    required String currentUserId,
    required String targetUserId,
  }) async {
    try {
      final isBlocked = await remoteDataSource.isUserBlocked(
        currentUserId: currentUserId,
        targetUserId: targetUserId,
      );
      return Right(isBlocked);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return const Left(ServerFailure());
    }
  }

  // ==========================================
  // BATCH OPERATIONS
  // ==========================================

  @override
  Future<Either<Failure, void>> followMultipleUsers({
    required String currentUserId,
    required List<String> targetUserIds,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      await remoteDataSource.followMultipleUsers(
        currentUserId: currentUserId,
        targetUserIds: targetUserIds,
      );
      return const Right(null);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<User>>> getMultipleUserProfiles({
    required List<String> userIds,
    String? currentUserId,
  }) async {
    try {
      final users = await remoteDataSource.getMultipleUserProfiles(
        userIds: userIds,
        currentUserId: currentUserId,
      );
      return Right(users);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Map<String, bool>>> getMultipleFollowStatus({
    required String currentUserId,
    required List<String> targetUserIds,
  }) async {
    try {
      final statuses = await remoteDataSource.getMultipleFollowStatus(
        currentUserId: currentUserId,
        targetUserIds: targetUserIds,
      );
      return Right(statuses);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return const Left(ServerFailure());
    }
  }

  // ==========================================
  // USER VERIFICATION & MODERATION
  // ==========================================

  @override
  Future<Either<Failure, void>> reportUser({
    required String reporterId,
    required String reportedUserId,
    required String reason,
    String? description,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      await remoteDataSource.reportUser(
        reporterId: reporterId,
        reportedUserId: reportedUserId,
        reason: reason,
        description: description,
      );
      return const Right(null);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> isUsernameAvailable(String username) async {
    try {
      final isAvailable = await remoteDataSource.isUsernameAvailable(username);
      return Right(isAvailable);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<String>>> suggestUsernames(String baseUsername) async {
    try {
      final suggestions = await remoteDataSource.suggestUsernames(baseUsername);
      return Right(suggestions);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return const Left(ServerFailure());
    }
  }

  // ==========================================
  // USER DELETION & ACCOUNT MANAGEMENT
  // ==========================================

  @override
  Future<Either<Failure, void>> deleteUserAccount(String userId) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      await remoteDataSource.deleteUserAccount(userId);
      await localDataSource.clearCache(); // Clear all cached data
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deactivateUserAccount(String userId) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      await remoteDataSource.deactivateUserAccount(userId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> reactivateUserAccount(String userId) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      await remoteDataSource.reactivateUserAccount(userId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return const Left(ServerFailure());
    }
  }
}