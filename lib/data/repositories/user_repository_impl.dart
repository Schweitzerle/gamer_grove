// lib/data/repositories/user_repository_impl.dart

/// Implementation of UserRepository.
///
/// Handles all user operations including profiles, collections, and social features.
library;

import 'package:dartz/dartz.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import 'package:gamer_grove/domain/entities/user/user.dart';
import 'package:gamer_grove/domain/entities/user/user_gaming_activity.dart';
import 'package:gamer_grove/domain/entities/user/user_relationship.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../core/network/network_info.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/remote/supabase/supabase_user_datasource.dart';
import '../models/user_model.dart';
import 'base/supabase_base_repository.dart';

/// Concrete implementation of [UserRepository].
///
/// Uses [SupabaseBaseRepository] for common functionality and
/// [SupabaseUserDataSource] for user operations.
///
/// Example usage:
/// ```dart
/// final userRepo = UserRepositoryImpl(
///   userDataSource: userDataSource,
///   supabase: supabaseClient,
///   networkInfo: networkInfo,
/// );
///
/// // Get user profile
/// final profile = await userRepo.getUserProfile(userId);
///
/// // Rate a game
/// await userRepo.rateGame(userId, gameId, 9.5);
/// ```
class UserRepositoryImpl extends SupabaseBaseRepository
    implements UserRepository {
  final SupabaseUserDataSource userDataSource;

  UserRepositoryImpl({
    required this.userDataSource,
    required supabase.SupabaseClient supabase,
    required NetworkInfo networkInfo,
  }) : super(supabase: supabase, networkInfo: networkInfo);

  // ============================================================
  // PROFILE OPERATIONS
  // ============================================================

  @override
  Future<Either<Failure, User>> getUserProfile({
    required String userId,
    String? currentUserId,
  }) {
    return executeSupabaseOperation(
      operation: () async {
        final profileData = await userDataSource.getUserProfile(userId);
        return UserModel.fromJson(profileData).toEntity();
      },
      errorMessage: 'Failed to get user profile',
    );
  }

  @override
  Future<Either<Failure, User>> getCurrentUserProfile() {
    return executeSupabaseOperation(
      operation: () async {
        final currentUser = this.supabase.auth.currentUser;
        if (currentUser == null) {
          throw Exception('No authenticated user');
        }
        final profileData = await userDataSource.getUserProfile(currentUser.id);
        return UserModel.fromJson(profileData).toEntity();
      },
      errorMessage: 'Failed to get current user profile',
    );
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
  }) {
    return executeSupabaseOperation(
      operation: () async {
        final updates = <String, dynamic>{};
        if (username != null) updates['username'] = username;
        if (bio != null) updates['bio'] = bio;
        if (avatarUrl != null) updates['avatar_url'] = avatarUrl;
        if (country != null) updates['country'] = country;
        if (isProfilePublic != null)
          updates['is_profile_public'] = isProfilePublic;
        if (showRatedGames != null)
          updates['show_rated_games'] = showRatedGames;
        if (showRecommendedGames != null)
          updates['show_recommended_games'] = showRecommendedGames;
        if (showTopThree != null) updates['show_top_three'] = showTopThree;

        final updatedData = await userDataSource.updateUserProfile(
          userId,
          updates,
        );
        return UserModel.fromJson(updatedData).toEntity();
      },
      errorMessage: 'Failed to update user profile',
    );
  }

  @override
  Future<Either<Failure, String>> updateUserAvatar({
    required String userId,
    required String imageData,
  }) {
    return executeSupabaseOperation(
      operation: () => userDataSource.updateUserAvatar(userId, imageData),
      errorMessage: 'Failed to upload avatar',
    );
  }

  @override
  Future<Either<Failure, void>> updatePrivacySettings({
    required String userId,
    bool? isProfilePublic,
    bool? showRatedGames,
    bool? showRecommendedGames,
    bool? showTopThree,
    bool? allowFollowRequests,
  }) {
    return executeSupabaseVoidOperation(
      operation: () {
        final settings = <String, bool>{};
        if (isProfilePublic != null)
          settings['is_profile_public'] = isProfilePublic;
        if (showRatedGames != null)
          settings['show_rated_games'] = showRatedGames;
        if (showRecommendedGames != null)
          settings['show_recommended_games'] = showRecommendedGames;
        if (showTopThree != null) settings['show_top_three'] = showTopThree;
        if (allowFollowRequests != null)
          settings['allow_follow_requests'] = allowFollowRequests;

        return userDataSource.updatePrivacySettings(userId, settings);
      },
      errorMessage: 'Failed to update privacy settings',
    );
  }

  // ============================================================
  // GAME COLLECTION OPERATIONS (These are implementation-specific)
  // ============================================================

  /// Gets enriched game data for multiple games at once.
  ///
  /// This is the PERFORMANCE-CRITICAL method!
  /// Uses PostgreSQL function for 40x faster enrichment.
  Future<Either<Failure, Map<int, Map<String, dynamic>>>> getUserGameData(
    String userId,
    List<int> gameIds,
  ) {
    return executeSupabaseOperation(
      operation: () => userDataSource.getUserGameData(userId, gameIds),
      errorMessage: 'Failed to get game enrichment data',
    );
  }

  Future<Either<Failure, void>> toggleWishlist(String userId, int gameId) {
    return executeSupabaseVoidOperation(
      operation: () => userDataSource.toggleWishlist(userId, gameId),
      errorMessage: 'Failed to toggle wishlist',
    );
  }

  Future<Either<Failure, void>> toggleRecommended(String userId, int gameId) {
    return executeSupabaseVoidOperation(
      operation: () => userDataSource.toggleRecommended(userId, gameId),
      errorMessage: 'Failed to toggle recommended',
    );
  }

  Future<Either<Failure, void>> rateGame(
    String userId,
    int gameId,
    double rating,
  ) {
    return executeSupabaseVoidOperation(
      operation: () => userDataSource.rateGame(userId, gameId, rating),
      errorMessage: 'Failed to rate game',
    );
  }

  Future<Either<Failure, void>> removeRating(String userId, int gameId) {
    return executeSupabaseVoidOperation(
      operation: () => userDataSource.removeRating(userId, gameId),
      errorMessage: 'Failed to remove rating',
    );
  }

  Future<Either<Failure, void>> updateTopThree(
    String userId,
    List<int> gameIds,
  ) {
    return executeSupabaseVoidOperation(
      operation: () => userDataSource.updateTopThree(userId, gameIds),
      errorMessage: 'Failed to update top three',
    );
  }

  Future<Either<Failure, List<int>?>> getTopThree(String userId) {
    return executeSupabaseOperation(
      operation: () => userDataSource.getTopThree(userId),
      errorMessage: 'Failed to get top three',
    );
  }

  Future<Either<Failure, void>> clearTopThree(String userId) {
    return executeSupabaseVoidOperation(
      operation: () => userDataSource.clearTopThree(userId),
      errorMessage: 'Failed to clear top three',
    );
  }

  Future<Either<Failure, List<int>>> getWishlistedGames(
    String userId, {
    int? limit,
    int? offset,
  }) {
    return executeSupabaseOperation(
      operation: () async {
        final games = await userDataSource.getWishlistedGames(
          userId,
          limit: limit,
          offset: offset,
        );
        return games.map((data) => data['game_id'] as int).toList();
      },
      errorMessage: 'Failed to get wishlisted games',
    );
  }

  Future<Either<Failure, List<Map<String, dynamic>>>> getRatedGames(
    String userId, {
    int? limit,
    int? offset,
  }) {
    return executeSupabaseOperation(
      operation: () => userDataSource.getRatedGames(
        userId,
        limit: limit,
        offset: offset,
      ),
      errorMessage: 'Failed to get rated games',
    );
  }

  Future<Either<Failure, List<int>>> getRecommendedGames(
    String userId, {
    int? limit,
    int? offset,
  }) {
    return executeSupabaseOperation(
      operation: () async {
        final games = await userDataSource.getRecommendedGames(
          userId,
          limit: limit,
          offset: offset,
        );
        return games.map((data) => data['game_id'] as int).toList();
      },
      errorMessage: 'Failed to get recommended games',
    );
  }

  // ============================================================
  // SOCIAL FEATURES
  // ============================================================

  @override
  Future<Either<Failure, void>> followUser({
    required String currentUserId,
    required String targetUserId,
  }) {
    return executeSupabaseVoidOperation(
      operation: () => userDataSource.followUser(currentUserId, targetUserId),
      errorMessage: 'Failed to follow user',
    );
  }

  @override
  Future<Either<Failure, void>> unfollowUser({
    required String currentUserId,
    required String targetUserId,
  }) {
    return executeSupabaseVoidOperation(
      operation: () => userDataSource.unfollowUser(currentUserId, targetUserId),
      errorMessage: 'Failed to unfollow user',
    );
  }

  @override
  Future<Either<Failure, bool>> isFollowing({
    required String currentUserId,
    required String targetUserId,
  }) {
    return executeSupabaseOperation(
      operation: () => userDataSource.isFollowing(currentUserId, targetUserId),
      errorMessage: 'Failed to check follow status',
    );
  }

  @override
  Future<Either<Failure, List<User>>> getUserFollowers({
    required String userId,
    int limit = 50,
    int offset = 0,
  }) {
    return executeSupabaseOperation(
      operation: () async {
        final followersData = await userDataSource.getFollowers(
          userId,
          limit: limit,
          offset: offset,
        );
        return followersData.map((data) {
          // Extract nested user data from join
          final userData = data['users'] as Map<String, dynamic>;
          return UserModel.fromJson(userData).toEntity();
        }).toList();
      },
      errorMessage: 'Failed to get followers',
    );
  }

  @override
  Future<Either<Failure, List<User>>> getUserFollowing({
    required String userId,
    int limit = 50,
    int offset = 0,
  }) {
    return executeSupabaseOperation(
      operation: () async {
        final followingData = await userDataSource.getFollowing(
          userId,
          limit: limit,
          offset: offset,
        );
        return followingData.map((data) {
          // Extract nested user data from join
          final userData = data['users'] as Map<String, dynamic>;
          return UserModel.fromJson(userData).toEntity();
        }).toList();
      },
      errorMessage: 'Failed to get following',
    );
  }

  @override
  Future<Either<Failure, Map<String, bool>>> getMultipleFollowStatus({
    required String currentUserId,
    required List<String> targetUserIds,
  }) {
    return executeSupabaseOperation(
      operation: () => userDataSource.batchGetFollowStatus(
        currentUserId,
        targetUserIds,
      ),
      errorMessage: 'Failed to get follow statuses',
    );
  }

  @override
  Future<Either<Failure, List<User>>> getMutualFollowers({
    required String currentUserId,
    required String targetUserId,
    int limit = 20,
  }) {
    return executeSupabaseOperation(
      operation: () async {
        final mutualData = await userDataSource.getMutualFollowers(
          currentUserId,
          targetUserId,
        );
        return mutualData
            .map((data) => UserModel.fromJson(data).toEntity())
            .toList();
      },
      errorMessage: 'Failed to get mutual followers',
    );
  }

  // ============================================================
  // SEARCH & DISCOVERY
  // ============================================================

  @override
  Future<Either<Failure, List<User>>> searchUsers({
    required String query,
    String? currentUserId,
    int limit = 20,
    int offset = 0,
  }) {
    return executeSupabaseOperation(
      operation: () async {
        final usersData = await userDataSource.searchUsers(
          query,
          limit: limit,
          offset: offset,
        );
        return usersData
            .map((data) => UserModel.fromJson(data).toEntity())
            .toList();
      },
      errorMessage: 'Failed to search users',
    );
  }

  @override
  Future<Either<Failure, List<User>>> getPopularUsers({
    int limit = 20,
    int offset = 0,
  }) {
    return executeSupabaseOperation(
      operation: () async {
        final usersData = await userDataSource.getPopularUsers(
          limit: limit,
          offset: offset,
        );
        return usersData
            .map((data) => UserModel.fromJson(data).toEntity())
            .toList();
      },
      errorMessage: 'Failed to get popular users',
    );
  }

  @override
  Future<Either<Failure, List<User>>> getNewUsers({
    int limit = 20,
    int offset = 0,
  }) {
    return executeSupabaseOperation(
      operation: () async {
        final response = await this
            .supabase
            .from('users')
            .select()
            .order('created_at', ascending: false)
            .limit(limit)
            .range(offset, offset + limit - 1);

        return (response as List)
            .map((data) => UserModel.fromJson(data).toEntity())
            .toList();
      },
      errorMessage: 'Failed to get new users',
    );
  }

  @override
  Future<Either<Failure, List<User>>> getSimilarUsers({
    required String userId,
    int limit = 20,
  }) {
    return executeSupabaseOperation(
      operation: () async {
        final usersData = await userDataSource.getSimilarUsers(
          userId,
          limit: limit,
        );
        return usersData
            .map((data) => UserModel.fromJson(data).toEntity())
            .toList();
      },
      errorMessage: 'Failed to get similar users',
    );
  }

  // ============================================================
  // ACTIVITY & FEED
  // ============================================================

  @override
  Future<Either<Failure, UserGamingActivity>> getUserActivity({
    required String userId,
    Duration? timeWindow,
  }) {
    return executeSupabaseOperation(
      operation: () async {
        // TODO: Implement UserGamingActivity aggregation
        // For now, return a default instance
        throw UnimplementedError('getUserActivity not yet implemented');
      },
      errorMessage: 'Failed to get user activity',
    );
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getUserGamingStats({
    required String userId,
    String? currentUserId,
  }) {
    return executeSupabaseOperation(
      operation: () async {
        // Get stats from datasource
        final statsData = await userDataSource.getUserStats(userId);
        return statsData;
      },
      errorMessage: 'Failed to get gaming stats',
    );
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getUserRecentActivity({
    required String userId,
    int limit = 20,
    int offset = 0,
  }) {
    return executeSupabaseOperation(
      operation: () async {
        final activityData = await userDataSource.getUserActivity(
          userId,
          limit: limit,
          offset: offset,
        );
        return activityData;
      },
      errorMessage: 'Failed to get recent activity',
    );
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getUserFeed({
    required String userId,
    int limit = 50,
    int offset = 0,
  }) {
    return executeSupabaseOperation(
      operation: () async {
        final activityData = await userDataSource.getFollowingActivity(
          userId,
          limit: limit,
        );
        return activityData;
      },
      errorMessage: 'Failed to get user feed',
    );
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getGlobalFeed({
    int limit = 50,
    int offset = 0,
  }) {
    return executeSupabaseOperation(
      operation: () async {
        final activityData = await userDataSource.getPublicActivity(
          limit: limit,
          offset: offset,
        );
        return activityData;
      },
      errorMessage: 'Failed to get global feed',
    );
  }

  @override
  Future<Either<Failure, List<User>>> getTrendingUsers({
    Duration? timeWindow,
    int limit = 20,
  }) {
    return executeSupabaseOperation(
      operation: () async {
        // Get popular users as trending users
        final usersData = await userDataSource.getPopularUsers(
          limit: limit,
          offset: 0,
        );
        return usersData
            .map((data) => UserModel.fromJson(data).toEntity())
            .toList();
      },
      errorMessage: 'Failed to get trending users',
    );
  }

  // ============================================================
  // STATISTICS (implementation-specific methods)
  // ============================================================

  Future<Either<Failure, Map<String, dynamic>>> getUserStats(String userId) {
    return executeSupabaseOperation(
      operation: () async {
        final statsData = await userDataSource.getUserStats(userId);
        return statsData;
      },
      errorMessage: 'Failed to get user stats',
    );
  }

  Future<Either<Failure, Map<String, dynamic>>> getCollectionStats(
    String userId,
  ) {
    return executeSupabaseOperation(
      operation: () => userDataSource.getCollectionStats(userId),
      errorMessage: 'Failed to get collection stats',
    );
  }

  @override
  Future<Either<Failure, UserRelationship>> getUserRelationship({
    required String currentUserId,
    required String targetUserId,
  }) {
    return executeSupabaseOperation(
      operation: () async {
        final relationshipData = await userDataSource.getUserRelationship(
          currentUserId,
          targetUserId,
        );

        // Convert to UserRelationship entity
        final isFollowing = relationshipData['is_following'] as bool? ?? false;
        final isFollowedBy =
            relationshipData['is_followed_by'] as bool? ?? false;

        RelationshipStatus status;
        if (isFollowing && isFollowedBy) {
          status = RelationshipStatus.mutual;
        } else if (isFollowing) {
          status = RelationshipStatus.following;
        } else if (isFollowedBy) {
          status = RelationshipStatus.followedBy;
        } else {
          status = RelationshipStatus.none;
        }

        return UserRelationship(
          userId: currentUserId,
          targetUserId: targetUserId,
          status: status,
          followedAt: relationshipData['followed_at'] != null
              ? DateTime.parse(relationshipData['followed_at'] as String)
              : null,
          followedBackAt: relationshipData['followed_back_at'] != null
              ? DateTime.parse(relationshipData['followed_back_at'] as String)
              : null,
        );
      },
      errorMessage: 'Failed to get user relationship',
    );
  }

  // ============================================================
  // TOP THREE GAMES MANAGEMENT
  // ============================================================

  @override
  Future<Either<Failure, void>> updateTopThreeGames({
    required String userId,
    required List<int> gameIds,
  }) {
    return executeSupabaseVoidOperation(
      operation: () => userDataSource.updateTopThree(userId, gameIds),
      errorMessage: 'Failed to update top three games',
    );
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getUserTopThreeGames({
    required String userId,
  }) {
    return executeSupabaseOperation(
      operation: () async {
        final gameIds = await userDataSource.getTopThree(userId);
        if (gameIds == null || gameIds.isEmpty) {
          return <Map<String, dynamic>>[];
        }

        // Fetch game details for each ID
        final games = <Map<String, dynamic>>[];
        for (final gameId in gameIds) {
          final gameData = await this
              .supabase
              .from('games')
              .select()
              .eq('id', gameId)
              .single();
          games.add(gameData);
        }
        return games;
      },
      errorMessage: 'Failed to get top three games',
    );
  }

  @override
  Future<Either<Failure, void>> setTopThreeGameAtPosition({
    required String userId,
    required int position,
    required int gameId,
  }) {
    return executeSupabaseVoidOperation(
      operation: () async {
        final currentTopThree =
            await userDataSource.getTopThree(userId) ?? [0, 0, 0];
        final updatedTopThree = List<int>.from(currentTopThree);
        if (position >= 1 && position <= 3) {
          updatedTopThree[position - 1] = gameId;
        }
        await userDataSource.updateTopThree(userId, updatedTopThree);
      },
      errorMessage: 'Failed to set top three game at position',
    );
  }

  @override
  Future<Either<Failure, void>> removeFromTopThree({
    required String userId,
    required int position,
  }) {
    return executeSupabaseVoidOperation(
      operation: () async {
        final currentTopThree =
            await userDataSource.getTopThree(userId) ?? [0, 0, 0];
        final updatedTopThree = List<int>.from(currentTopThree);
        if (position >= 1 && position <= 3) {
          updatedTopThree[position - 1] = 0;
        }
        await userDataSource.updateTopThree(userId, updatedTopThree);
      },
      errorMessage: 'Failed to remove from top three',
    );
  }

  @override
  Future<Either<Failure, void>> reorderTopThree({
    required String userId,
    required Map<int, int> positionToGameId,
  }) {
    return executeSupabaseVoidOperation(
      operation: () async {
        final updatedTopThree = [0, 0, 0];
        positionToGameId.forEach((position, gameId) {
          if (position >= 1 && position <= 3) {
            updatedTopThree[position - 1] = gameId;
          }
        });
        await userDataSource.updateTopThree(userId, updatedTopThree);
      },
      errorMessage: 'Failed to reorder top three',
    );
  }

  // ============================================================
  // USER GAME COLLECTIONS (PUBLIC VISIBILITY)
  // ============================================================

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getUserPublicRatedGames({
    required String userId,
    String? currentUserId,
    int limit = 20,
    int offset = 0,
  }) {
    return executeSupabaseOperation(
      operation: () async {
        final profile = await userDataSource.getUserProfile(userId);
        if (profile['show_rated_games'] == false) {
          return <Map<String, dynamic>>[];
        }
        return userDataSource.getRatedGames(userId,
            limit: limit, offset: offset);
      },
      errorMessage: 'Failed to get public rated games',
    );
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>>
      getUserPublicRecommendedGames({
    required String userId,
    String? currentUserId,
    int limit = 20,
    int offset = 0,
  }) {
    return executeSupabaseOperation(
      operation: () async {
        final profile = await userDataSource.getUserProfile(userId);
        if (profile['show_recommended_games'] == false) {
          return <Map<String, dynamic>>[];
        }
        final games = await userDataSource.getRecommendedGames(userId,
            limit: limit, offset: offset);
        return games.cast<Map<String, dynamic>>();
      },
      errorMessage: 'Failed to get public recommended games',
    );
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getUserPublicCollections({
    required String userId,
    String? currentUserId,
  }) {
    return executeSupabaseOperation(
      operation: () async {
        final profile = await userDataSource.getUserProfile(userId);
        final collections = <String, dynamic>{};

        if (profile['show_rated_games'] == true) {
          collections['rated_games'] =
              await userDataSource.getRatedGames(userId);
        }

        if (profile['show_recommended_games'] == true) {
          collections['recommended_games'] =
              await userDataSource.getRecommendedGames(userId);
        }

        if (profile['show_top_three'] == true) {
          collections['top_three'] = await userDataSource.getTopThree(userId);
        }

        return collections;
      },
      errorMessage: 'Failed to get public collections',
    );
  }

  // ============================================================
  // USER PRIVACY & SETTINGS
  // ============================================================

  @override
  Future<Either<Failure, void>> blockUser({
    required String currentUserId,
    required String targetUserId,
  }) {
    return executeSupabaseVoidOperation(
      operation: () async {
        await this.supabase.from('blocked_users').insert({
          'blocker_id': currentUserId,
          'blocked_id': targetUserId,
        });
      },
      errorMessage: 'Failed to block user',
    );
  }

  @override
  Future<Either<Failure, void>> unblockUser({
    required String currentUserId,
    required String targetUserId,
  }) {
    return executeSupabaseVoidOperation(
      operation: () async {
        await this
            .supabase
            .from('blocked_users')
            .delete()
            .eq('blocker_id', currentUserId)
            .eq('blocked_id', targetUserId);
      },
      errorMessage: 'Failed to unblock user',
    );
  }

  @override
  Future<Either<Failure, List<User>>> getBlockedUsers({
    required String userId,
  }) {
    return executeSupabaseOperation(
      operation: () async {
        final response = await this
            .supabase
            .from('blocked_users')
            .select('blocked_id, users!blocked_users_blocked_id_fkey(*)')
            .eq('blocker_id', userId);

        return (response as List)
            .map((data) => UserModel.fromJson(data['users']).toEntity())
            .toList();
      },
      errorMessage: 'Failed to get blocked users',
    );
  }

  @override
  Future<Either<Failure, bool>> isUserBlocked({
    required String currentUserId,
    required String targetUserId,
  }) {
    return executeSupabaseOperation(
      operation: () async {
        final response = await this
            .supabase
            .from('blocked_users')
            .select()
            .eq('blocker_id', currentUserId)
            .eq('blocked_id', targetUserId)
            .maybeSingle();

        return response != null;
      },
      errorMessage: 'Failed to check if user is blocked',
    );
  }

  // ============================================================
  // BATCH OPERATIONS
  // ============================================================

  @override
  Future<Either<Failure, void>> followMultipleUsers({
    required String currentUserId,
    required List<String> targetUserIds,
  }) {
    return executeSupabaseVoidOperation(
      operation: () async {
        for (final targetUserId in targetUserIds) {
          await userDataSource.followUser(currentUserId, targetUserId);
        }
      },
      errorMessage: 'Failed to follow multiple users',
    );
  }

  @override
  Future<Either<Failure, List<User>>> getMultipleUserProfiles({
    required List<String> userIds,
    String? currentUserId,
  }) {
    return executeSupabaseOperation(
      operation: () async {
        final response =
            await this.supabase.from('users').select().inFilter('id', userIds);

        return (response as List)
            .map((data) => UserModel.fromJson(data).toEntity())
            .toList();
      },
      errorMessage: 'Failed to get multiple user profiles',
    );
  }

  // ============================================================
  // USER VERIFICATION & MODERATION
  // ============================================================

  @override
  Future<Either<Failure, void>> reportUser({
    required String reporterId,
    required String reportedUserId,
    required String reason,
    String? description,
  }) {
    return executeSupabaseVoidOperation(
      operation: () async {
        await this.supabase.from('user_reports').insert({
          'reporter_id': reporterId,
          'reported_user_id': reportedUserId,
          'reason': reason,
          'description': description,
        });
      },
      errorMessage: 'Failed to report user',
    );
  }

  @override
  Future<Either<Failure, bool>> isUsernameAvailable(String username) {
    return executeSupabaseOperation(
      operation: () async {
        final response = await this
            .supabase
            .from('users')
            .select('id')
            .eq('username', username)
            .maybeSingle();

        return response == null;
      },
      errorMessage: 'Failed to check username availability',
    );
  }

  @override
  Future<Either<Failure, List<String>>> suggestUsernames(String baseUsername) {
    return executeSupabaseOperation(
      operation: () async {
        final suggestions = <String>[];
        for (int i = 1; i <= 5; i++) {
          final suggestion = '$baseUsername$i';
          final isAvailable = await isUsernameAvailable(suggestion);
          isAvailable.fold(
            (failure) => null,
            (available) {
              if (available) suggestions.add(suggestion);
            },
          );
        }
        return suggestions;
      },
      errorMessage: 'Failed to suggest usernames',
    );
  }

  // ============================================================
  // USER DELETION & ACCOUNT MANAGEMENT
  // ============================================================

  @override
  Future<Either<Failure, void>> deleteUserAccount(String userId) {
    return executeSupabaseVoidOperation(
      operation: () async {
        await this.supabase.from('users').delete().eq('id', userId);
      },
      errorMessage: 'Failed to delete user account',
    );
  }

  @override
  Future<Either<Failure, void>> deactivateUserAccount(String userId) {
    return executeSupabaseVoidOperation(
      operation: () async {
        await this.supabase.from('users').update({
          'is_active': false,
        }).eq('id', userId);
      },
      errorMessage: 'Failed to deactivate user account',
    );
  }

  @override
  Future<Either<Failure, void>> reactivateUserAccount(String userId) {
    return executeSupabaseVoidOperation(
      operation: () async {
        await this.supabase.from('users').update({
          'is_active': true,
        }).eq('id', userId);
      },
      errorMessage: 'Failed to reactivate user account',
    );
  }

  @override
  Future<Either<Failure, List<User>>> getFollowSuggestions({
    required String userId,
    int limit = 20,
  }) {
    return executeSupabaseOperation(
      operation: () async {
        // Get similar users as follow suggestions
        final usersData = await userDataSource.getSimilarUsers(
          userId,
          limit: limit,
        );
        return usersData
            .map((data) => UserModel.fromJson(data).toEntity())
            .toList();
      },
      errorMessage: 'Failed to get follow suggestions',
    );
  }
}
