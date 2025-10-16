// lib/data/datasources/remote/supabase/supabase_user_datasource_impl.dart

/// Implementation of user data source.
///
/// Handles all user operations with Supabase backend.
library;

import 'dart:convert';
import 'package:gamer_grove/data/datasources/remote/supabase/models/supabase_user_exceptions.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_user_datasource.dart';
import 'models/supabase_query.dart';
import 'models/supabase_presets.dart';
import 'models/supabase_filters.dart';

/// Concrete implementation of [SupabaseUserDataSource].
class SupabaseUserDataSourceImpl implements SupabaseUserDataSource {
  final SupabaseClient _supabase;

  /// Storage bucket name for avatars.
  static const String _avatarBucket = 'avatars';

  /// Maximum avatar file size (5MB).
  static const int _maxAvatarSize = 5 * 1024 * 1024;

  SupabaseUserDataSourceImpl({required SupabaseClient supabase})
      : _supabase = supabase;

  // ============================================================
  // PROFILE OPERATIONS
  // ============================================================

  @override
  Future<Map<String, dynamic>> getUserProfile(String userId) async {
    try {
      final result = await UserQueries.getProfileById(userId).build(_supabase);
      return result as Map<String, dynamic>;
    } catch (e) {
      throw UserExceptionMapper.map(e);
    }
  }

  @override
  Future<Map<String, dynamic>?> getUserProfileByUsername(
      String username) async {
    try {
      final result =
          await UserQueries.getProfileByUsername(username).build(_supabase);
      return result as Map<String, dynamic>?;
    } catch (e) {
      if (e.toString().contains('no rows')) return null;
      throw UserExceptionMapper.map(e);
    }
  }

  @override
  Future<Map<String, dynamic>> updateUserProfile(
    String userId,
    Map<String, dynamic> updates,
  ) async {
    try {
      // Validate updates
      _validateProfileUpdates(updates);

      // Add updated_at timestamp
      updates['updated_at'] = DateTime.now().toIso8601String();

      final result = await SupabaseUpdate('users')
          .set(updates)
          .filter(EqualFilter('id', userId))
          .returning('*')
          .build(_supabase);

      if (result == null || (result as List).isEmpty) {
        throw const UserNotFoundException();
      }

      return result.first as Map<String, dynamic>;
    } catch (e) {
      if (e is UserException) rethrow;
      throw UserExceptionMapper.map(e);
    }
  }

  /// Validates profile update data.
  void _validateProfileUpdates(Map<String, dynamic> updates) {
    // Validate display_name length
    if (updates.containsKey('display_name')) {
      final displayName = updates['display_name'] as String?;
      if (displayName != null &&
          (displayName.isEmpty || displayName.length > 50)) {
        throw const InvalidProfileDataException(
          message: 'Display name must be 1-50 characters',
        );
      }
    }

    // Validate bio length
    if (updates.containsKey('bio')) {
      final bio = updates['bio'] as String?;
      if (bio != null && bio.length > 500) {
        throw const InvalidProfileDataException(
          message: 'Bio must be 500 characters or less',
        );
      }
    }

    // Validate username format (if being changed)
    if (updates.containsKey('username')) {
      final username = updates['username'] as String;
      if (!RegExp(r'^[a-z0-9_]{3,20}$').hasMatch(username)) {
        throw const InvalidProfileDataException(
          message:
              'Username must be 3-20 characters, lowercase alphanumeric and underscores only',
        );
      }
    }
  }

  @override
  Future<String> updateUserAvatar(String userId, String imageData) async {
    try {
      // Decode base64 image
      final bytes = base64Decode(imageData);

      // Validate file size
      if (bytes.length > _maxAvatarSize) {
        throw const InvalidAvatarException(
          message: 'Avatar file is too large (max 5MB)',
        );
      }

      // Generate unique filename
      final fileName = '$userId-${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = '$userId/$fileName';

      // Upload to storage
      await _supabase.storage.from(_avatarBucket).uploadBinary(filePath, bytes);

      // Get public URL
      final publicUrl =
          _supabase.storage.from(_avatarBucket).getPublicUrl(filePath);

      // Update user profile with new avatar URL
      await updateUserProfile(userId, {'avatar_url': publicUrl});

      return publicUrl;
    } catch (e) {
      if (e is UserException) rethrow;
      throw AvatarUploadException(
        message: 'Failed to upload avatar: $e',
        originalError: e,
      );
    }
  }

  @override
  Future<void> deleteUserAvatar(String userId) async {
    try {
      // Get current avatar URL
      final profile = await getUserProfile(userId);
      final avatarUrl = profile['avatar_url'] as String?;

      if (avatarUrl != null && avatarUrl.isNotEmpty) {
        // Extract file path from URL
        final uri = Uri.parse(avatarUrl);
        final path = uri.pathSegments.last;

        // Delete from storage
        await _supabase.storage.from(_avatarBucket).remove(['$userId/$path']);
      }

      // Clear avatar URL in profile
      await updateUserProfile(userId, {'avatar_url': null});
    } catch (e) {
      throw UserExceptionMapper.map(e);
    }
  }

  @override
  Future<void> updatePrivacySettings(
    String userId,
    Map<String, bool> settings,
  ) async {
    try {
      await updateUserProfile(userId, settings);
    } catch (e) {
      throw UserExceptionMapper.map(e);
    }
  }

  // ============================================================
  // GAME COLLECTION OPERATIONS
  // ============================================================

  @override
  Future<Map<int, Map<String, dynamic>>> getUserGameData(
    String userId,
    List<int> gameIds,
  ) async {
    try {
      if (gameIds.isEmpty) return {};

      // Use PostgreSQL function for optimal performance
      final result =
          await RpcQueries.getGameEnrichment(userId, gameIds).build(_supabase);

      final Map<int, Map<String, dynamic>> enrichmentMap = {};
      for (final data in result as List) {
        final gameId = data['game_id'] as int;
        enrichmentMap[gameId] = data as Map<String, dynamic>;
      }

      return enrichmentMap;
    } catch (e) {
      throw UserExceptionMapper.map(e);
    }
  }

  @override
  Future<void> toggleWishlist(String userId, int gameId) async {
    try {
      // Check if game exists in collection
      final existing =
          await UserGameQueries.getUserGame(userId, gameId).build(_supabase);

      if (existing == null) {
        // Add new entry
        await SupabaseInsert('user_games').values({
          'user_id': userId,
          'game_id': gameId,
          'is_wishlisted': true,
          'wishlisted_at': DateTime.now().toIso8601String(),
        }).build(_supabase);
      } else {
        // Toggle existing
        final isWishlisted = existing['is_wishlisted'] as bool;
        await SupabaseUpdate('user_games')
            .set({
              'is_wishlisted': !isWishlisted,
              'wishlisted_at':
                  !isWishlisted ? DateTime.now().toIso8601String() : null,
            })
            .filter(EqualFilter('user_id', userId))
            .filter(EqualFilter('game_id', gameId))
            .build(_supabase);
      }
    } catch (e) {
      throw UserExceptionMapper.map(e);
    }
  }

  @override
  Future<void> toggleRecommended(String userId, int gameId) async {
    try {
      final existing =
          await UserGameQueries.getUserGame(userId, gameId).build(_supabase);

      if (existing == null) {
        await SupabaseInsert('user_games').values({
          'user_id': userId,
          'game_id': gameId,
          'is_recommended': true,
          'recommended_at': DateTime.now().toIso8601String(),
        }).build(_supabase);
      } else {
        final isRecommended = existing['is_recommended'] as bool;
        await SupabaseUpdate('user_games')
            .set({
              'is_recommended': !isRecommended,
              'recommended_at':
                  !isRecommended ? DateTime.now().toIso8601String() : null,
            })
            .filter(EqualFilter('user_id', userId))
            .filter(EqualFilter('game_id', gameId))
            .build(_supabase);
      }
    } catch (e) {
      throw UserExceptionMapper.map(e);
    }
  }

  @override
  Future<void> rateGame(String userId, int gameId, double rating) async {
    try {
      // Validate rating
      if (rating < 0.0 || rating > 10.0) {
        throw const InvalidRatingException();
      }

      final existing =
          await UserGameQueries.getUserGame(userId, gameId).build(_supabase);

      if (existing == null) {
        await SupabaseInsert('user_games').values({
          'user_id': userId,
          'game_id': gameId,
          'is_rated': true,
          'rating': rating,
          'rated_at': DateTime.now().toIso8601String(),
        }).build(_supabase);
      } else {
        await SupabaseUpdate('user_games')
            .set({
              'is_rated': true,
              'rating': rating,
              'rated_at': DateTime.now().toIso8601String(),
            })
            .filter(EqualFilter('user_id', userId))
            .filter(EqualFilter('game_id', gameId))
            .build(_supabase);
      }
    } catch (e) {
      if (e is UserException) rethrow;
      throw UserExceptionMapper.map(e);
    }
  }

  @override
  Future<void> removeRating(String userId, int gameId) async {
    try {
      await SupabaseUpdate('user_games')
          .set({
            'is_rated': false,
            'rating': null,
            'rated_at': null,
          })
          .filter(EqualFilter('user_id', userId))
          .filter(EqualFilter('game_id', gameId))
          .build(_supabase);
    } catch (e) {
      throw UserExceptionMapper.map(e);
    }
  }

  @override
  Future<void> updateTopThree(String userId, List<int> gameIds) async {
    try {
      // Validate input
      if (gameIds.length != 3) {
        throw const InvalidTopThreeException(
          message: 'Must provide exactly 3 game IDs',
        );
      }

      // Check for duplicates
      if (gameIds.toSet().length != 3) {
        throw const InvalidTopThreeException(
          message: 'All 3 games must be different',
        );
      }

      // Upsert top three
      await SupabaseInsert('user_top_three')
          .values({
            'user_id': userId,
            'game_1_id': gameIds[0],
            'game_2_id': gameIds[1],
            'game_3_id': gameIds[2],
            'updated_at': DateTime.now().toIso8601String(),
          })
          .upsert()
          .build(_supabase);
    } catch (e) {
      if (e is UserException) rethrow;
      throw UserExceptionMapper.map(e);
    }
  }

  @override
  Future<List<int>?> getTopThree(String userId) async {
    try {
      final result = await TopThreeQueries.getTopThree(userId).build(_supabase);

      if (result == null) return null;

      return [
        result['game_1_id'] as int,
        result['game_2_id'] as int,
        result['game_3_id'] as int,
      ];
    } catch (e) {
      throw UserExceptionMapper.map(e);
    }
  }

  @override
  Future<void> clearTopThree(String userId) async {
    try {
      await SupabaseDelete('user_top_three')
          .filter(EqualFilter('user_id', userId))
          .build(_supabase);
    } catch (e) {
      throw UserExceptionMapper.map(e);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getWishlistedGames(
    String userId, {
    int? limit,
    int? offset,
  }) async {
    try {
      final result = await UserGameQueries.getWishlistedGames(
        userId,
        pagination: limit != null
            ? Pagination(limit: limit, offset: offset ?? 0)
            : null,
      ).build(_supabase);

      return (result as List).cast<Map<String, dynamic>>();
    } catch (e) {
      throw UserExceptionMapper.map(e);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getRatedGames(
    String userId, {
    int? limit,
    int? offset,
  }) async {
    try {
      final result = await UserGameQueries.getRatedGames(
        userId,
        pagination: limit != null
            ? Pagination(limit: limit, offset: offset ?? 0)
            : null,
      ).build(_supabase);

      return (result as List).cast<Map<String, dynamic>>();
    } catch (e) {
      throw UserExceptionMapper.map(e);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getRecommendedGames(
    String userId, {
    int? limit,
    int? offset,
  }) async {
    try {
      final result = await UserGameQueries.getRecommendedGames(
        userId,
        pagination: limit != null
            ? Pagination(limit: limit, offset: offset ?? 0)
            : null,
      ).build(_supabase);

      return (result as List).cast<Map<String, dynamic>>();
    } catch (e) {
      throw UserExceptionMapper.map(e);
    }
  }

  // ============================================================
  // SOCIAL FEATURES
  // ============================================================

  @override
  Future<void> followUser(String followerId, String followingId) async {
    try {
      // Validate not following self
      if (followerId == followingId) {
        throw const CannotFollowSelfException();
      }

      await SupabaseInsert('user_follows').values({
        'follower_id': followerId,
        'following_id': followingId,
        'created_at': DateTime.now().toIso8601String(),
      }).build(_supabase);
    } catch (e) {
      if (e is UserException) rethrow;
      throw UserExceptionMapper.map(e);
    }
  }

  @override
  Future<void> unfollowUser(String followerId, String followingId) async {
    try {
      await SupabaseDelete('user_follows')
          .filter(EqualFilter('follower_id', followerId))
          .filter(EqualFilter('following_id', followingId))
          .build(_supabase);
    } catch (e) {
      throw UserExceptionMapper.map(e);
    }
  }

  @override
  Future<bool> isFollowing(String followerId, String followingId) async {
    try {
      final result = await FollowQueries.isFollowing(followerId, followingId)
          .build(_supabase);
      return result != null;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getFollowers(
    String userId, {
    int? limit,
    int? offset,
  }) async {
    try {
      final result = await FollowQueries.getFollowers(
        userId,
        pagination: limit != null
            ? Pagination(limit: limit, offset: offset ?? 0)
            : null,
      ).build(_supabase);

      return (result as List).cast<Map<String, dynamic>>();
    } catch (e) {
      throw UserExceptionMapper.map(e);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getFollowing(
    String userId, {
    int? limit,
    int? offset,
  }) async {
    try {
      final result = await FollowQueries.getFollowing(
        userId,
        pagination: limit != null
            ? Pagination(limit: limit, offset: offset ?? 0)
            : null,
      ).build(_supabase);

      return (result as List).cast<Map<String, dynamic>>();
    } catch (e) {
      throw UserExceptionMapper.map(e);
    }
  }

  @override
  Future<Map<String, bool>> batchGetFollowStatus(
    String currentUserId,
    List<String> targetUserIds,
  ) async {
    try {
      final result = await RpcQueries.batchGetFollowStatus(
        currentUserId,
        targetUserIds,
      ).build(_supabase);

      final Map<String, bool> statusMap = {};
      for (final data in result as List) {
        final userId = data['target_user_id'] as String;
        final isFollowing = data['is_following'] as bool;
        statusMap[userId] = isFollowing;
      }

      return statusMap;
    } catch (e) {
      throw UserExceptionMapper.map(e);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getMutualFollowers(
    String userId1,
    String userId2,
  ) async {
    try {
      final result = await RpcQueries.getMutualFollowers(userId1, userId2)
          .build(_supabase);
      return (result as List).cast<Map<String, dynamic>>();
    } catch (e) {
      throw UserExceptionMapper.map(e);
    }
  }

  // ============================================================
  // DISCOVERY & SEARCH
  // ============================================================

  @override
  Future<List<Map<String, dynamic>>> searchUsers(
    String query, {
    int? limit,
    int? offset,
  }) async {
    try {
      final result = await RpcQueries.searchUsers(query, limit: limit ?? 20)
          .build(_supabase);
      return (result as List).cast<Map<String, dynamic>>();
    } catch (e) {
      throw UserExceptionMapper.map(e);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getPopularUsers({
    int? limit,
    int? offset,
  }) async {
    try {
      final result =
          await RpcQueries.getPopularUsers(limit: limit ?? 10).build(_supabase);
      return (result as List).cast<Map<String, dynamic>>();
    } catch (e) {
      throw UserExceptionMapper.map(e);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getSimilarUsers(
    String userId, {
    int? limit,
  }) async {
    try {
      // This would require a more complex algorithm
      // For now, return popular users as a placeholder
      return getPopularUsers(limit: limit ?? 10);
    } catch (e) {
      throw UserExceptionMapper.map(e);
    }
  }

  // ============================================================
  // ACTIVITY & FEED
  // ============================================================

  @override
  Future<List<Map<String, dynamic>>> getUserActivity(
    String userId, {
    int? limit,
    int? offset,
  }) async {
    try {
      final result = await ActivityQueries.getUserActivity(
        userId,
        pagination: limit != null
            ? Pagination(limit: limit, offset: offset ?? 0)
            : null,
      ).build(_supabase);

      return (result as List).cast<Map<String, dynamic>>();
    } catch (e) {
      throw UserExceptionMapper.map(e);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getFollowingActivity(
    String userId, {
    int? limit,
  }) async {
    try {
      final result = await RpcQueries.getFollowingActivity(
        userId,
        limit: limit ?? 20,
      ).build(_supabase);

      return (result as List).cast<Map<String, dynamic>>();
    } catch (e) {
      throw UserExceptionMapper.map(e);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getPublicActivity({
    int? limit,
    int? offset,
  }) async {
    try {
      final result = await ActivityQueries.getPublicActivity(
        pagination: limit != null
            ? Pagination(limit: limit, offset: offset ?? 0)
            : null,
      ).build(_supabase);

      return (result as List).cast<Map<String, dynamic>>();
    } catch (e) {
      throw UserExceptionMapper.map(e);
    }
  }

  // ============================================================
  // STATISTICS
  // ============================================================

  @override
  Future<Map<String, dynamic>> getUserStats(String userId) async {
    try {
      final profile = await getUserProfile(userId);
      return {
        'total_games_rated': profile['total_games_rated'],
        'total_games_wishlisted': profile['total_games_wishlisted'],
        'total_games_recommended': profile['total_games_recommended'],
        'average_rating': profile['average_rating'],
        'followers_count': profile['followers_count'],
        'following_count': profile['following_count'],
      };
    } catch (e) {
      throw UserExceptionMapper.map(e);
    }
  }

  @override
  Future<Map<String, dynamic>> getCollectionStats(String userId) async {
    try {
      final result =
          await RpcQueries.getCollectionStats(userId).build(_supabase);
      return result as Map<String, dynamic>;
    } catch (e) {
      throw UserExceptionMapper.map(e);
    }
  }

  @override
  Future<Map<String, dynamic>> getUserRelationship(
    String currentUserId,
    String targetUserId,
  ) async {
    try {
      final result = await RpcQueries.getUserRelationship(
        currentUserId,
        targetUserId,
      ).build(_supabase);
      return result as Map<String, dynamic>;
    } catch (e) {
      throw UserExceptionMapper.map(e);
    }
  }
}
