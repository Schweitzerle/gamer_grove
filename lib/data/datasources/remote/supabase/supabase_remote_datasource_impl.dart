// lib/data/datasources/remote/supabase/supabase_remote_datasource_impl.dart
// COMPLETE UPDATED IMPLEMENTATION - Combines best practices from both versions
import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;
import '../../../../core/errors/exceptions.dart';
import '../../../../domain/entities/user/user_collection_sort_options.dart';
import '../../../../domain/entities/user/user_gaming_activity.dart';
import '../../../../domain/entities/user/user_relationship.dart';
import '../../../../domain/entities/user/user_collection_filters.dart';
import '../../../models/user_model.dart';
import 'supabase_remote_datasource.dart';

class SupabaseRemoteDataSourceImpl implements SupabaseRemoteDataSource {
  final SupabaseClient client;

  SupabaseRemoteDataSourceImpl({required this.client});

  // ==========================================
  // AUTH METHODS (OPTIMIZED)
  // ==========================================


  @override
  Future<Map<int, double>> getUserRatings(String userId) async {
    try {
      final response = await client
          .from('user_games')
          .select('game_id, rating')
          .eq('user_id', userId)
          .eq('is_rated', true);

      final Map<int, double> ratings = {};
      for (final item in response) {
        final gameId = item['game_id'] as int;
        final rating = (item['rating'] as num).toDouble();
        ratings[gameId] = rating;
      }

      return ratings;
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to get user ratings');
    }
  }

  @override
  Future<UserModel> signIn(String email, String password) async {
    try {
      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw AuthException(message: 'Login failed');
      }

      // Get user profile from database
      final userProfile = await client
          .from('users')
          .select('*')
          .eq('id', response.user!.id)
          .single();

      return UserModel.fromJson(userProfile);
    } on AuthException catch (e) {
      throw AuthException(message: e.message);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw AuthException(message: 'Authentication failed');
    }
  }

  @override
  Future<UserModel> signUp(
      String email, String password, String username) async {
    try {
      // Check if username is available
      final existingUser = await client
          .from('users')
          .select('id')
          .eq('username', username)
          .maybeSingle();

      if (existingUser != null) {
        throw ValidationException(message: 'Username already taken');
      }

      // Sign up user
      final response = await client.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw AuthException(message: 'Signup failed');
      }

      // Create user profile
      final userProfile = await client
          .from('users')
          .insert({
            'id': response.user!.id,
            'username': username,
            'email': email,
            'created_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      return UserModel.fromJson(userProfile);
    } on AuthException catch (e) {
      throw AuthException(message: e.message);
    } on ValidationException {
      rethrow;
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw AuthException(message: 'Registration failed');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await client.auth.signOut();
    } catch (e) {
      throw AuthException(message: 'Logout failed');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = client.auth.currentUser;
      if (user == null) return null;

      final userProfile =
          await client.from('users').select('*').eq('id', user.id).single();

      return UserModel.fromJson(userProfile);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      return null;
    }
  }

  // ==========================================
  // CORE USER PROFILE METHODS (OPTIMIZED)
  // ==========================================

  @override
  Future<UserModel> getUserProfile(String userId,
      [String? currentUserId]) async {
    try {
      // Base query for user profile
      final userProfile =
          await client.from('users').select('*').eq('id', userId).single();

      // Get social context if currentUserId provided
      if (currentUserId != null && currentUserId != userId) {
        final followRelation = await client
            .from('user_follows')
            .select('follower_id, followed_id')
            .or('and(follower_id.eq.$currentUserId,followed_id.eq.$userId),and(follower_id.eq.$userId,followed_id.eq.$currentUserId)');

        bool isFollowing = false;
        bool isFollowedBy = false;

        for (final follow in followRelation) {
          if (follow['follower_id'] == currentUserId &&
              follow['followed_id'] == userId) {
            isFollowing = true;
          }
          if (follow['follower_id'] == userId &&
              follow['followed_id'] == currentUserId) {
            isFollowedBy = true;
          }
        }

        userProfile['is_following'] = isFollowing;
        userProfile['is_followed_by'] = isFollowedBy;
      }

      return UserModel.fromJson(userProfile, currentUserId: currentUserId);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        throw NotFoundException(message: 'User not found');
      }
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to get user profile');
    }
  }

  @override
  Future<UserModel> getCurrentUserProfile() async {
    try {
      final user = client.auth.currentUser;
      if (user == null) {
        throw AuthException(message: 'Not authenticated');
      }

      return await getUserProfile(user.id);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw ServerException(message: 'Failed to get current user profile');
    }
  }

  @override
  Future<UserModel> updateUserProfile({
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
    try {
      final currentUser = client.auth.currentUser;
      if (currentUser == null || currentUser.id != userId) {
        throw AuthException(message: 'Unauthorized');
      }

      // Build update data
      final updateData = <String, dynamic>{};
      if (username != null) updateData['username'] = username;
      if (bio != null) updateData['bio'] = bio;
      if (avatarUrl != null) updateData['avatar_url'] = avatarUrl;
      if (country != null) updateData['country'] = country;
      if (isProfilePublic != null)
        updateData['is_profile_public'] = isProfilePublic;
      if (showRatedGames != null)
        updateData['show_rated_games'] = showRatedGames;
      if (showRecommendedGames != null)
        updateData['show_recommended_games'] = showRecommendedGames;
      if (showTopThree != null) updateData['show_top_three'] = showTopThree;

      if (updateData.isEmpty) {
        throw ValidationException(message: 'No data to update');
      }

      final updatedProfile = await client
          .from('users')
          .update(updateData)
          .eq('id', userId)
          .select()
          .single();

      return UserModel.fromJson(updatedProfile);
    } on AuthException {
      rethrow;
    } on ValidationException {
      rethrow;
    } on PostgrestException catch (e) {
      if (e.code == '23505' && e.message.contains('username')) {
        throw ValidationException(message: 'Username already taken');
      }
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to update profile');
    }
  }

  @override
  Future<String> updateUserAvatar({
    required String userId,
    required String imageData,
  }) async {
    try {
      final currentUser = client.auth.currentUser;
      if (currentUser == null || currentUser.id != userId) {
        throw AuthException(message: 'Unauthorized');
      }

      // Upload to storage
      final fileName =
          '$userId/avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';
      await client.storage
          .from('avatars')
          .uploadBinary(fileName, base64Decode(imageData));

      // Get public URL
      final publicUrl = client.storage.from('avatars').getPublicUrl(fileName);

      // Update user profile with new avatar URL
      await updateUserProfile(userId: userId, avatarUrl: publicUrl);

      return publicUrl;
    } on AuthException {
      rethrow;
    } on StorageException catch (e) {
      throw ServerException(message: 'Failed to upload avatar: ${e.message}');
    } catch (e) {
      throw ServerException(message: 'Failed to update avatar');
    }
  }

  // ==========================================
  // GAME COLLECTIONS - CORE METHODS (NEW SCHEMA)
  // ==========================================

  @override
  Future<List<int>> getUserWishlistIds(String userId) async {
    try {
      final response = await client
          .from('user_games')
          .select('game_id')
          .eq('user_id', userId)
          .eq('is_wishlisted', true)
          .order('wishlisted_at', ascending: false);

      return response.map<int>((item) => item['game_id'] as int).toList();
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to get wishlist');
    }
  }

  @override
  Future<List<int>> getUserRecommendedIds(String userId) async {
    try {
      final response = await client
          .from('user_games')
          .select('game_id')
          .eq('user_id', userId)
          .eq('is_recommended', true)
          .order('recommended_at', ascending: false);

      return response.map<int>((item) => item['game_id'] as int).toList();
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to get recommended games');
    }
  }

  @override
  Future<List<int>> getUserRatedIds(String userId) async {
    try {
      final response = await client
          .from('user_games')
          .select('game_id')
          .eq('user_id', userId)
          .eq('is_rated', true)
          .order('rated_at', ascending: false);

      return response.map<int>((item) => item['game_id'] as int).toList();
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to get rated games');
    }
  }

  @override
  Future<Map<String, dynamic>?> getUserGameData(
      String userId, int gameId) async {
    try {
      final response = await client
          .from('user_games')
          .select('*')
          .eq('user_id', userId)
          .eq('game_id', gameId)
          .maybeSingle();

      return response;
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to get game data');
    }
  }

  @override
  Future<Map<int, Map<String, dynamic>>> getBatchUserGameData(
      List<int> gameIds, String userId) async {
    try {
      final response = await client
          .from('user_games')
          .select('*')
          .eq('user_id', userId)
          .inFilter('game_id', gameIds);

      final result = <int, Map<String, dynamic>>{};
      for (final item in response) {
        result[item['game_id'] as int] = item;
      }

      return result;
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to get batch game data');
    }
  }

  // ==========================================
  // GAME ACTIONS (NEW SCHEMA OPTIMIZED)
  // ==========================================

  @override
  Future<void> toggleWishlist(int gameId, String userId) async {
    try {
      final existingData = await getUserGameData(userId, gameId);

      if (existingData == null) {
        // Create new entry
        await client.from('user_games').insert({
          'user_id': userId,
          'game_id': gameId,
          'is_wishlisted': true,
          'wishlisted_at': DateTime.now().toIso8601String(),
        });
      } else {
        // Toggle existing entry
        final isCurrentlyWishlisted = existingData['is_wishlisted'] as bool;
        await client
            .from('user_games')
            .update({
              'is_wishlisted': !isCurrentlyWishlisted,
              'wishlisted_at': !isCurrentlyWishlisted
                  ? DateTime.now().toIso8601String()
                  : null,
            })
            .eq('user_id', userId)
            .eq('game_id', gameId);
      }
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to toggle wishlist');
    }
  }

  @override
  Future<void> toggleRecommended(int gameId, String userId) async {
    try {
      final existingData = await getUserGameData(userId, gameId);

      if (existingData == null) {
        // Create new entry
        await client.from('user_games').insert({
          'user_id': userId,
          'game_id': gameId,
          'is_recommended': true,
          'recommended_at': DateTime.now().toIso8601String(),
        });
      } else {
        // Toggle existing entry
        final isCurrentlyRecommended = existingData['is_recommended'] as bool;
        await client
            .from('user_games')
            .update({
              'is_recommended': !isCurrentlyRecommended,
              'recommended_at': !isCurrentlyRecommended
                  ? DateTime.now().toIso8601String()
                  : null,
            })
            .eq('user_id', userId)
            .eq('game_id', gameId);
      }
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to toggle recommendation');
    }
  }

  @override
  Future<void> rateGame(int gameId, String userId, double rating) async {
    try {
      if (rating < 0 || rating > 10) {
        throw ValidationException(message: 'Rating must be between 0 and 10');
      }

      final existingData = await getUserGameData(userId, gameId);

      if (existingData == null) {
        // Create new entry
        await client.from('user_games').insert({
          'user_id': userId,
          'game_id': gameId,
          'is_rated': true,
          'rating': rating,
          'rated_at': DateTime.now().toIso8601String(),
        });
      } else {
        // Update existing entry
        await client
            .from('user_games')
            .update({
              'is_rated': true,
              'rating': rating,
              'rated_at': DateTime.now().toIso8601String(),
            })
            .eq('user_id', userId)
            .eq('game_id', gameId);
      }
    } on ValidationException {
      rethrow;
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to rate game');
    }
  }

  // ==========================================
  // TOP THREE GAMES MANAGEMENT (NEW)
  // ==========================================

  @override
  Future<void> updateTopThreeGames({
    required String userId,
    required List<int> gameIds,
  }) async {
    try {
      if (gameIds.length != 3) {
        throw ValidationException(message: 'Must provide exactly 3 games');
      }

      // Delete existing top three
      await client.from('user_top_three').delete().eq('user_id', userId);

      // Insert new top three
      final inserts = gameIds
          .asMap()
          .entries
          .map((entry) => {
                'user_id': userId,
                'game_id': entry.value,
                'position': entry.key + 1,
              })
          .toList();

      await client.from('user_top_three').insert(inserts);
    } on ValidationException {
      rethrow;
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to update top three games');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getUserTopThreeGames({
    required String userId,
  }) async {
    try {
      final response = await client
          .from('user_top_three')
          .select('game_id, position')
          .eq('user_id', userId)
          .order('position', ascending: true);

      return response.cast<Map<String, dynamic>>();
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to get top three games');
    }
  }

  @override
  Future<void> setTopThreeGameAtPosition({
    required String userId,
    required int position,
    required int gameId,
  }) async {
    try {
      if (position < 1 || position > 3) {
        throw ValidationException(message: 'Position must be 1, 2, or 3');
      }

      // Remove existing game at this position
      await client
          .from('user_top_three')
          .delete()
          .eq('user_id', userId)
          .eq('position', position);

      // Insert new game at position
      await client.from('user_top_three').insert({
        'user_id': userId,
        'game_id': gameId,
        'position': position,
      });
    } on ValidationException {
      rethrow;
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to set top three game');
    }
  }

  @override
  Future<void> removeFromTopThree({
    required String userId,
    required int position,
  }) async {
    try {
      if (position < 1 || position > 3) {
        throw ValidationException(message: 'Position must be 1, 2, or 3');
      }

      await client
          .from('user_top_three')
          .delete()
          .eq('user_id', userId)
          .eq('position', position);
    } on ValidationException {
      rethrow;
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to remove from top three');
    }
  }

  @override
  Future<void> reorderTopThree({
    required String userId,
    required Map<int, int> positionToGameId,
  }) async {
    try {
      if (positionToGameId.length != 3 ||
          !positionToGameId.keys.every((pos) => pos >= 1 && pos <= 3)) {
        throw ValidationException(
            message: 'Must provide exactly 3 positions (1, 2, 3)');
      }

      // Delete existing top three
      await client.from('user_top_three').delete().eq('user_id', userId);

      // Insert reordered games
      final inserts = positionToGameId.entries
          .map((entry) => {
                'user_id': userId,
                'position': entry.key,
                'game_id': entry.value,
              })
          .toList();

      await client.from('user_top_three').insert(inserts);
    } on ValidationException {
      rethrow;
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to reorder top three');
    }
  }

  // ==========================================
  // SOCIAL FEATURES - FOLLOW SYSTEM (FROM OLD IMPLEMENTATION)
  // ==========================================

  @override
  Future<void> followUser({
    required String currentUserId,
    required String targetUserId,
  }) async {
    try {
      if (currentUserId == targetUserId) {
        throw ValidationException(message: 'Cannot follow yourself');
      }

      // Check if target user exists and is active
      final targetUser = await client
          .from('users')
          .select('id, is_active')
          .eq('id', targetUserId)
          .eq('is_active', true)
          .maybeSingle();

      if (targetUser == null) {
        throw NotFoundException(message: 'User not found');
      }

      // Check if already following
      final existingFollow = await client
          .from('user_follows')
          .select('id')
          .eq('follower_id', currentUserId)
          .eq('followed_id', targetUserId)
          .maybeSingle();

      if (existingFollow != null) {
        throw ValidationException(message: 'Already following this user');
      }

      // Create follow relationship
      await client.from('user_follows').insert({
        'follower_id': currentUserId,
        'followed_id': targetUserId,
      });
    } on ValidationException {
      rethrow;
    } on NotFoundException {
      rethrow;
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        throw ValidationException(message: 'Already following this user');
      }
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to follow user');
    }
  }

  @override
  Future<void> unfollowUser({
    required String currentUserId,
    required String targetUserId,
  }) async {
    try {
      await client
          .from('user_follows')
          .delete()
          .eq('follower_id', currentUserId)
          .eq('followed_id', targetUserId);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to unfollow user');
    }
  }

  @override
  Future<bool> isFollowing({
    required String currentUserId,
    required String targetUserId,
  }) async {
    try {
      final follow = await client
          .from('user_follows')
          .select('id')
          .eq('follower_id', currentUserId)
          .eq('followed_id', targetUserId)
          .maybeSingle();

      return follow != null;
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to check follow status');
    }
  }

  @override
  Future<UserRelationship> getUserRelationship({
    required String currentUserId,
    required String targetUserId,
  }) async {
    try {
      final follows = await client
          .from('user_follows')
          .select('follower_id, followed_id, created_at')
          .or('and(follower_id.eq.$currentUserId,followed_id.eq.$targetUserId),and(follower_id.eq.$targetUserId,followed_id.eq.$currentUserId)');

      bool isFollowing = false;
      bool isFollowedBy = false;
      DateTime? followedAt;
      DateTime? followedBackAt;

      for (final follow in follows) {
        if (follow['follower_id'] == currentUserId &&
            follow['followed_id'] == targetUserId) {
          isFollowing = true;
          followedAt = DateTime.parse(follow['created_at']);
        } else if (follow['follower_id'] == targetUserId &&
            follow['followed_id'] == currentUserId) {
          isFollowedBy = true;
          followedBackAt = DateTime.parse(follow['created_at']);
        }
      }

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
        followedAt: followedAt,
        followedBackAt: followedBackAt,
      );
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to get user relationship');
    }
  }

  @override
  Future<List<UserModel>> getUserFollowers({
    required String userId,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await client
          .from('user_follows')
          .select('''
            follower:users!user_follows_follower_id_fkey(*)
          ''')
          .eq('followed_id', userId)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return response
          .map((item) => UserModel.fromJson(item['follower']))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to get followers');
    }
  }

  @override
  Future<List<UserModel>> getUserFollowing({
    required String userId,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await client
          .from('user_follows')
          .select('''
            followed:users!user_follows_followed_id_fkey(*)
          ''')
          .eq('follower_id', userId)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return response
          .map((item) => UserModel.fromJson(item['followed']))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to get following');
    }
  }

  // ==========================================
  // STUB IMPLEMENTATIONS FOR REMAINING METHODS
  // (ADD FULL IMPLEMENTATIONS FROM YOUR EXISTING CODE)
  // ==========================================

  @override
  Future<List<UserModel>> getMutualFollowers(
      {required String currentUserId,
      required String targetUserId,
      int limit = 20}) async {
    // TODO: Implement from your existing code
    throw UnimplementedError('Add implementation from existing code');
  }

  @override
  Future<List<UserModel>> getFollowSuggestions(
      {required String userId, int limit = 20}) async {
    // TODO: Implement from your existing code
    throw UnimplementedError('Add implementation from existing code');
  }

  @override
  Future<List<UserModel>> searchUsers(
      {required String query,
      String? currentUserId,
      int limit = 20,
      int offset = 0}) async {
    // TODO: Implement from your existing code
    throw UnimplementedError('Add implementation from existing code');
  }

  @override
  Future<List<UserModel>> getPopularUsers(
      {int limit = 20, int offset = 0}) async {
    // TODO: Implement from your existing code
    throw UnimplementedError('Add implementation from existing code');
  }

  @override
  Future<List<UserModel>> getNewUsers({int limit = 20, int offset = 0}) async {
    // TODO: Implement from your existing code
    throw UnimplementedError('Add implementation from existing code');
  }

  @override
  Future<List<UserModel>> getSimilarUsers(
      {required String userId, int limit = 20}) async {
    // TODO: Implement from your existing code
    throw UnimplementedError('Add implementation from existing code');
  }

  @override
  Future<List<Map<String, dynamic>>> getUserWishlistWithFilters(
      {required String userId,
      required UserCollectionFilters filters,
      int limit = 20,
      int offset = 0}) async {
    // TODO: Implement from your existing code
    throw UnimplementedError('Add implementation from existing code');
  }

  @override
  Future<List<Map<String, dynamic>>> getUserRatedGamesWithFilters(
      {required String userId,
      required UserCollectionFilters filters,
      int limit = 20,
      int offset = 0}) async {
    // TODO: Implement from your existing code
    throw UnimplementedError('Add implementation from existing code');
  }

  @override
  Future<List<Map<String, dynamic>>> getUserRecommendedGamesWithFilters(
      {required String userId,
      required UserCollectionFilters filters,
      int limit = 20,
      int offset = 0}) async {
    // TODO: Implement from your existing code
    throw UnimplementedError('Add implementation from existing code');
  }

  @override
  Future<Map<String, dynamic>> getUserCollectionStatistics(
      {required String userId, String? currentUserId}) async {
    // TODO: Implement from your existing code
    throw UnimplementedError('Add implementation from existing code');
  }

  @override
  Future<List<Map<String, dynamic>>> getUserPublicRatedGames(
      {required String userId,
      String? currentUserId,
      int limit = 20,
      int offset = 0}) async {
    // TODO: Implement from your existing code
    throw UnimplementedError('Add implementation from existing code');
  }

  @override
  Future<List<Map<String, dynamic>>> getUserPublicRecommendedGames(
      {required String userId,
      String? currentUserId,
      int limit = 20,
      int offset = 0}) async {
    // TODO: Implement from your existing code
    throw UnimplementedError('Add implementation from existing code');
  }

  @override
  Future<Map<String, dynamic>> getUserPublicCollections(
      {required String userId, String? currentUserId}) async {
    // TODO: Implement from your existing code
    throw UnimplementedError('Add implementation from existing code');
  }

  @override
  Future<UserGamingActivity> getUserActivity(
      {required String userId, Duration? timeWindow}) async {
    try {
      final startDate = timeWindow != null
          ? DateTime.now().subtract(timeWindow)
          : DateTime.now().subtract(const Duration(days: 30));

      final response = await client.rpc(
        'get_user_gaming_activity',
        params: {
          'target_user_id': userId,
          'start_date': startDate.toIso8601String(),
        },
      );

      return UserGamingActivityModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to get user activity');
    }
  }

  @override
  Future<Map<String, dynamic>> getUserGamingStats(
      {required String userId, String? currentUserId}) async {
    // TODO: Implement from your existing code
    throw UnimplementedError('Add implementation from existing code');
  }

  @override
  Future<List<Map<String, dynamic>>> getUserRecentActivity(
      {required String userId, int limit = 20, int offset = 0}) async {
    // TODO: Implement from your existing code
    throw UnimplementedError('Add implementation from existing code');
  }

  @override
  Future<List<UserModel>> getMultipleUserProfiles(
      {required List<String> userIds, String? currentUserId}) async {
    // TODO: Implement from your existing code
    throw UnimplementedError('Add implementation from existing code');
  }

  @override
  Future<Map<String, bool>> getMultipleFollowStatus(
      {required String currentUserId,
      required List<String> targetUserIds}) async {
    // TODO: Implement from your existing code
    throw UnimplementedError('Add implementation from existing code');
  }

  @override
  Future<void> followMultipleUsers(
      {required String currentUserId,
      required List<String> targetUserIds}) async {
    // TODO: Implement from your existing code
    throw UnimplementedError('Add implementation from existing code');
  }

  @override
  Future<void> reportUser(
      {required String reporterId,
      required String reportedUserId,
      required String reason,
      String? description}) async {
    // TODO: Implement from your existing code
    throw UnimplementedError('Add implementation from existing code');
  }

  @override
  Future<bool> isUsernameAvailable(String username) async {
    try {
      final response = await client
          .from('users')
          .select('id')
          .eq('username', username)
          .maybeSingle();

      return response == null;
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to check username availability');
    }
  }

  @override
  Future<List<String>> suggestUsernames(String baseUsername) async {
    // TODO: Implement from your existing code
    throw UnimplementedError('Add implementation from existing code');
  }

  @override
  Future<void> blockUser(
      {required String currentUserId, required String targetUserId}) async {
    // TODO: Implement from your existing code
    throw UnimplementedError('Add implementation from existing code');
  }

  @override
  Future<void> unblockUser(
      {required String currentUserId, required String targetUserId}) async {
    // TODO: Implement from your existing code
    throw UnimplementedError('Add implementation from existing code');
  }

  @override
  Future<bool> isUserBlocked(
      {required String currentUserId, required String targetUserId}) async {
    // TODO: Implement from your existing code
    throw UnimplementedError('Add implementation from existing code');
  }

  @override
  Future<List<UserModel>> getBlockedUsers({required String userId}) async {
    // TODO: Implement from your existing code
    throw UnimplementedError('Add implementation from existing code');
  }

  @override
  Future<void> deleteUserAccount(String userId) async {
    // TODO: Implement from your existing code
    throw UnimplementedError('Add implementation from existing code');
  }

  @override
  Future<void> deactivateUserAccount(String userId) async {
    // TODO: Implement from your existing code
    throw UnimplementedError('Add implementation from existing code');
  }

  @override
  Future<void> reactivateUserAccount(String userId) async {
    // TODO: Implement from your existing code
    throw UnimplementedError('Add implementation from existing code');
  }

  @override
  Future<List<String>> getRecentSearchQueries(String userId,
      {int limit = 10}) async {
    try {
      final response = await client
          .from('user_search_history')
          .select('query')
          .eq('user_id', userId)
          .order('searched_at', ascending: false)
          .limit(limit);

      return response.map<String>((item) => item['query'] as String).toList();
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to get search history');
    }
  }

  @override
  Future<void> saveSearchQuery(String userId, String query) async {
    try {
      await client.from('user_search_history').insert({
        'user_id': userId,
        'query': query.trim(),
        'searched_at': DateTime.now().toIso8601String(),
      });
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to save search query');
    }
  }

  @override
  Future<Map<String, dynamic>> getUserGamingStatistics(String userId) async {
    try {
      final response = await client.rpc('get_user_gaming_statistics', params: {
        'user_id': userId,
      });

      return response as Map<String, dynamic>;
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to get gaming statistics');
    }
  }

  @override
  Future<Map<String, dynamic>> getPersonalizedInsights(String userId) async {
    // TODO: Implement from your existing code
    throw UnimplementedError('Add implementation from existing code');
  }

  @override
  Future<List<Map<String, dynamic>>> getGenreEvolutionTrends() async {
    // TODO: Implement from your existing code
    throw UnimplementedError('Add implementation from existing code');
  }

  @override
  Future<List<Map<String, dynamic>>> getPlatformAdoptionTrends() async {
    // TODO: Implement from your existing code
    throw UnimplementedError('Add implementation from existing code');
  }

  @override
  Future<List<Map<String, dynamic>>> getUserFeed(
      {required String userId, int limit = 50, int offset = 0}) async {
    // TODO: Implement from your existing code
    throw UnimplementedError('Add implementation from existing code');
  }

  @override
  Future<List<Map<String, dynamic>>> getGlobalFeed(
      {int limit = 50, int offset = 0}) async {
    // TODO: Implement from your existing code
    throw UnimplementedError('Add implementation from existing code');
  }

  @override
  Future<List<UserModel>> getTrendingUsers(
      {Duration? timeWindow, int limit = 20}) async {
    // TODO: Implement from your existing code
    throw UnimplementedError('Add implementation from existing code');
  }

  @override
  Future<void> updatePrivacySettings(
      {required String userId,
      bool? isProfilePublic,
      bool? showRatedGames,
      bool? showRecommendedGames,
      bool? showTopThree,
      bool? allowFollowRequests}) async {
    // TODO: Implement from your existing code
    throw UnimplementedError('Add implementation from existing code');
  }

  @override
  Future<void> updateNotificationSettings(
      {required String userId,
      bool? emailNotifications,
      bool? pushNotifications,
      bool? followNotifications,
      bool? ratingNotifications}) async {
    // TODO: Implement from your existing code
    throw UnimplementedError('Add implementation from existing code');
  }

  // ==========================================
  // BATCH OPERATIONS
  // ==========================================

  @override
  Future<void> batchAddToWishlist(String userId, List<int> gameIds) async {
    try {
      final insertData = gameIds
          .map((gameId) => {
                'user_id': userId,
                'game_id': gameId,
                'is_wishlisted': true,
                'wishlisted_at': DateTime.now().toIso8601String(),
                'created_at': DateTime.now().toIso8601String(),
                'updated_at': DateTime.now().toIso8601String(),
              })
          .toList();

      await client.from('user_games').upsert(insertData);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to batch add to wishlist');
    }
  }

  @override
  Future<void> batchRateGames(
      String userId, Map<int, double> gameRatings) async {
    try {
      final insertData = gameRatings.entries
          .map((entry) => {
                'user_id': userId,
                'game_id': entry.key,
                'rating': entry.value,
                'is_rated': true,
                'rated_at': DateTime.now().toIso8601String(),
                'created_at': DateTime.now().toIso8601String(),
                'updated_at': DateTime.now().toIso8601String(),
              })
          .toList();

      await client.from('user_games').upsert(insertData);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to batch rate games');
    }
  }

  @override
  Future<void> batchRemoveFromWishlist(String userId, List<int> gameIds) async {
    try {
      await client
          .from('user_games')
          .update({
            'is_wishlisted': false,
            'wishlisted_at': null,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId)
          .inFilter('game_id', gameIds);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to batch remove from wishlist');
    }
  }

  @override
  Future<void> moveGamesBetweenCollections({
    required String userId,
    required List<int> gameIds,
    required UserCollectionType fromCollection,
    required UserCollectionType toCollection,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      // Remove from source collection
      switch (fromCollection) {
        case UserCollectionType.wishlist:
          updateData['is_wishlisted'] = false;
          updateData['wishlisted_at'] = null;
          break;
        case UserCollectionType.recommended:
          updateData['is_recommended'] = false;
          updateData['recommended_at'] = null;
          break;
        default:
          break;
      }

      // Add to destination collection
      switch (toCollection) {
        case UserCollectionType.wishlist:
          updateData['is_wishlisted'] = true;
          updateData['wishlisted_at'] = DateTime.now().toIso8601String();
          break;
        case UserCollectionType.recommended:
          updateData['is_recommended'] = true;
          updateData['recommended_at'] = DateTime.now().toIso8601String();
          break;
        default:
          break;
      }

      await client
          .from('user_games')
          .update(updateData)
          .eq('user_id', userId)
          .inFilter('game_id', gameIds);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(
          message: 'Failed to move games between collections');
    }
  }

  // ==========================================
  // USER ACTIVITY & ANALYTICS
  // ==========================================

  @override
  Future<List<Map<String, dynamic>>> getRecentlyAddedToCollections({
    required String userId,
    required DateTime sinceDate,
    int limit = 50,
  }) async {
    try {
      final response = await client
          .from('user_games')
          .select(
              'game_id, created_at, is_wishlisted, is_rated, is_recommended')
          .eq('user_id', userId)
          .or('is_wishlisted.eq.true,is_rated.eq.true,is_recommended.eq.true')
          .gte('created_at', sinceDate.toIso8601String())
          .order('created_at', ascending: false)
          .limit(limit);

      return response.cast<Map<String, dynamic>>();
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to get recently added games');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getUserTopGenres(String userId,
      {int limit = 10}) async {
    try {
      final response = await client.rpc('get_user_top_genres', params: {
        'user_id': userId,
        'limit_count': limit,
      });

      return (response as List).cast<Map<String, dynamic>>();
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to get top genres');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getUserActivityTimeline({
    required String userId,
    required DateTime fromDate,
    required DateTime toDate,
    int limit = 50,
  }) async {
    try {
      final response = await client
          .from('user_activity_log')
          .select('*')
          .eq('user_id', userId)
          .gte('created_at', fromDate.toIso8601String())
          .lte('created_at', toDate.toIso8601String())
          .order('created_at', ascending: false)
          .limit(limit);

      return response.cast<Map<String, dynamic>>();
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to get activity timeline');
    }
  }

  @override
  Future<Map<String, double>> getUserGenrePreferences(String userId) async {
    try {
      final response = await client.rpc('get_user_genre_preferences', params: {
        'user_id': userId,
      });

      return Map<String, double>.from(response);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to get genre preferences');
    }
  }

  @override
  Future<Map<String, int>> getUserPlatformStatistics(String userId) async {
    try {
      final response =
          await client.rpc('get_user_platform_statistics', params: {
        'user_id': userId,
      });

      return Map<String, int>.from(response);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to get platform statistics');
    }
  }

  @override
  Future<Map<String, dynamic>> getUserRatingAnalytics(String userId) async {
    try {
      final response = await client.rpc('get_user_rating_analytics', params: {
        'user_id': userId,
      });

      return response as Map<String, dynamic>;
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to get rating analytics');
    }
  }

  @override
  Future<Map<String, dynamic>> getUserGamingPatternAnalysis(
      String userId) async {
    try {
      final response =
          await client.rpc('get_user_gaming_pattern_analysis', params: {
        'user_id': userId,
      });

      return response as Map<String, dynamic>;
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to get gaming pattern analysis');
    }
  }

  @override
  Future<Map<String, dynamic>> getUserGamingProfile(String userId) async {
    try {
      final response = await client.rpc('get_user_gaming_profile', params: {
        'user_id': userId,
      });

      return response as Map<String, dynamic>;
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to get gaming profile');
    }
  }

  // ==========================================
  // RECOMMENDATION SUPPORT
  // ==========================================

  @override
  Future<List<Map<String, dynamic>>> getUserHighlyRatedGames(String userId,
      {double minRating = 8.0}) async {
    try {
      final response = await client
          .from('user_games')
          .select('game_id, rating, rated_at')
          .eq('user_id', userId)
          .eq('is_rated', true)
          .gte('rating', minRating)
          .order('rating', ascending: false);

      return response.cast<Map<String, dynamic>>();
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to get highly rated games');
    }
  }

  @override
  Future<dynamic> getUserWishlistPatterns(String userId) async {
    try {
      final response = await client.rpc('get_user_wishlist_patterns', params: {
        'user_id': userId,
      });

      return response;
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to get wishlist patterns');
    }
  }

  @override
  Future<dynamic> getUserRatingPatterns(String userId) async {
    try {
      final response = await client.rpc('get_user_rating_patterns', params: {
        'user_id': userId,
      });

      return response;
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to get rating patterns');
    }
  }

  @override
  Future<dynamic> getFriendsActivity(String userId) async {
    try {
      final response = await client.rpc('get_friends_activity', params: {
        'user_id': userId,
      });

      return response;
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to get friends activity');
    }
  }

  @override
  Future<dynamic> getCommunityTrends() async {
    try {
      final response = await client.rpc('get_community_trends');

      return response;
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to get community trends');
    }
  }

  @override
  Future<Map<String, dynamic>> getUserGamingContext(String userId) async {
    try {
      final response = await client.rpc('get_user_gaming_context', params: {
        'user_id': userId,
      });

      return response as Map<String, dynamic>;
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to get gaming context');
    }
  }

  @override
  Future<List<int>> getAllUserGameIds(String userId) async {
    try {
      final response = await client
          .from('user_games')
          .select('game_id')
          .eq('user_id', userId)
          .or('is_wishlisted.eq.true,is_rated.eq.true,is_recommended.eq.true');

      return response.map<int>((item) => item['game_id'] as int).toList();
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to get all user game IDs');
    }
  }

  // ==========================================
  // SOCIAL FEATURES
  // ==========================================

  @override
  Future<List<String>> getUserFriends(String userId) async {
    try {
      final response = await client
          .from('user_follows')
          .select('followed_id')
          .eq('follower_id', userId);

      return response
          .map<String>((item) => item['followed_id'] as String)
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to get user friends');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getFriendsRecentActivity({
    required List<String> friendIds,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await client
          .from('user_activity_log')
          .select('*')
          .inFilter('user_id', friendIds)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return response.cast<Map<String, dynamic>>();
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to get friends activity');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getFriendsRecommendedGames({
    required List<String> friendIds,
    required String excludeUserId,
    int limit = 20,
  }) async {
    try {
      final response = await client
          .from('user_games')
          .select('game_id, user_id, recommended_at')
          .inFilter('user_id', friendIds)
          .eq('is_recommended', true)
          .order('recommended_at', ascending: false)
          .limit(limit);

      return response.cast<Map<String, dynamic>>();
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to get friends recommended games');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getCommunityFavoritesByGenres({
    required List<int> genreIds,
    int limit = 20,
  }) async {
    try {
      final response =
          await client.rpc('get_community_favorites_by_genres', params: {
        'genre_ids': genreIds,
        'limit_count': limit,
      });

      return (response as List).cast<Map<String, dynamic>>();
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to get community favorites');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> findSimilarUsers(String userId,
      {int limit = 10}) async {
    try {
      final response = await client.rpc('find_similar_users', params: {
        'user_id': userId,
        'limit_count': limit,
      });

      return (response as List).cast<Map<String, dynamic>>();
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to find similar users');
    }
  }

  // ==========================================
  // ANALYTICS & TRENDS
  // ==========================================

  @override
  Future<List<Map<String, dynamic>>> getGenreTrendAnalytics({
    required Duration timeWindow,
    int limit = 20,
  }) async {
    try {
      final response = await client.rpc('get_genre_trend_analytics', params: {
        'time_window_days': timeWindow.inDays,
        'limit_count': limit,
      });

      return (response as List).cast<Map<String, dynamic>>();
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to get genre trend analytics');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getPlatformTrendAnalytics({
    required Duration timeWindow,
    int limit = 20,
  }) async {
    try {
      final response =
          await client.rpc('get_platform_trend_analytics', params: {
        'time_window_days': timeWindow.inDays,
        'limit_count': limit,
      });

      return (response as List).cast<Map<String, dynamic>>();
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to get platform trend analytics');
    }
  }

  @override
  Future<Map<String, dynamic>> getIndustryTrendAnalytics(
      {required Duration timeWindow}) async {
    try {
      final response =
          await client.rpc('get_industry_trend_analytics', params: {
        'time_window_days': timeWindow.inDays,
      });

      return response as Map<String, dynamic>;
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to get industry trend analytics');
    }
  }

// ==========================================
// HELPER METHODEN FÜR PRIVACY CHECKS
// ==========================================

  /// Hilfsmethode um zu überprüfen, ob ein Benutzer eine bestimmte Sammlung einsehen kann
  Future<bool> _canViewUserCollection({
    required String userId,
    required String collectionType,
    String? currentUserId,
  }) async {
    try {
      final userResponse = await client
          .from('users')
          .select('is_profile_public, $collectionType')
          .eq('id', userId)
          .single();

      // Eigenes Profil kann immer eingesehen werden
      if (currentUserId == userId) return true;

      // Profil muss öffentlich sein
      final isProfilePublic =
          userResponse['is_profile_public'] as bool? ?? false;
      if (!isProfilePublic) return false;

      // Sammlung muss öffentlich freigegeben sein
      final isCollectionPublic = userResponse[collectionType] as bool? ?? false;
      return isCollectionPublic;
    } catch (e) {
      return false;
    }
  }

  /// Erweiterte Methode die zusätzliche Metadaten zurückgibt
  Future<Map<String, dynamic>> getUserPublicRatedGamesWithMetadata({
    required String userId,
    String? currentUserId,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      // Privacy-Check
      final canView = await _canViewUserCollection(
        userId: userId,
        collectionType: 'show_rated_games',
        currentUserId: currentUserId,
      );

      if (!canView) {
        throw UnauthorizedException(message: 'Cannot view rated games');
      }

      // Haupt-Query
      final response = await client
          .from('user_games')
          .select('game_id, rating, rated_at, created_at, updated_at')
          .eq('user_id', userId)
          .eq('is_rated', true)
          .order('rated_at', ascending: false)
          .range(offset, offset + limit - 1);

      // Zusätzliche Metadaten abrufen
      final statsResponse = await client
          .from('users')
          .select('total_games_rated, average_rating')
          .eq('id', userId)
          .single();

      return {
        'games': response.cast<Map<String, dynamic>>(),
        'metadata': {
          'total_count': statsResponse['total_games_rated'] ?? 0,
          'average_rating': statsResponse['average_rating'],
          'has_more': response.length == limit,
          'offset': offset,
          'limit': limit,
        },
      };
    } catch (e) {
      if (e is UnauthorizedException) rethrow;
      throw ServerException(message: 'Failed to get rated games with metadata');
    }
  }

  /// Erweiterte Methode für empfohlene Spiele mit Metadaten
  Future<Map<String, dynamic>> getUserPublicRecommendedGamesWithMetadata({
    required String userId,
    String? currentUserId,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      // Privacy-Check
      final canView = await _canViewUserCollection(
        userId: userId,
        collectionType: 'show_recommended_games',
        currentUserId: currentUserId,
      );

      if (!canView) {
        throw UnauthorizedException(message: 'Cannot view recommended games');
      }

      // Haupt-Query
      final response = await client
          .from('user_games')
          .select('game_id, recommended_at, created_at, updated_at')
          .eq('user_id', userId)
          .eq('is_recommended', true)
          .order('recommended_at', ascending: false)
          .range(offset, offset + limit - 1);

      // Zusätzliche Metadaten abrufen
      final statsResponse = await client
          .from('users')
          .select('total_games_recommended')
          .eq('id', userId)
          .single();

      return {
        'games': response.cast<Map<String, dynamic>>(),
        'metadata': {
          'total_count': statsResponse['total_games_recommended'] ?? 0,
          'has_more': response.length == limit,
          'offset': offset,
          'limit': limit,
        },
      };
    } catch (e) {
      if (e is UnauthorizedException) rethrow;
      throw ServerException(
          message: 'Failed to get recommended games with metadata');
    }
  }

// ==========================================
// BATCH-ABRUF FÜR MEHRERE SAMMLUNGEN
// ==========================================

  /// Ruft alle öffentlichen Sammlungen eines Benutzers auf einmal ab
  Future<Map<String, dynamic>> getAllUserPublicCollections({
    required String userId,
    String? currentUserId,
    int limit = 10,
  }) async {
    try {
      // Überprüfe Profil-Zugang
      final userResponse = await client.from('users').select('''
          is_profile_public,
          show_rated_games,
          show_recommended_games,
          show_top_three,
          total_games_rated,
          total_games_recommended
        ''').eq('id', userId).single();

      final canViewProfile = userResponse['is_profile_public'] == true ||
          (currentUserId == userId);

      if (!canViewProfile) {
        throw UnauthorizedException(message: 'Cannot view user profile');
      }

      final result = <String, dynamic>{
        'permissions': {
          'can_view_rated': userResponse['show_rated_games'] == true ||
              currentUserId == userId,
          'can_view_recommended':
              userResponse['show_recommended_games'] == true ||
                  currentUserId == userId,
          'can_view_top_three':
              userResponse['show_top_three'] == true || currentUserId == userId,
        },
      };

      // Abrufen der bewerteten Spiele (wenn erlaubt)
      if (result['permissions']['can_view_rated']) {
        final ratedGames = await client
            .from('user_games')
            .select('game_id, rating, rated_at')
            .eq('user_id', userId)
            .eq('is_rated', true)
            .order('rated_at', ascending: false)
            .limit(limit);

        result['rated_games'] = {
          'games': ratedGames.cast<Map<String, dynamic>>(),
          'total_count': userResponse['total_games_rated'] ?? 0,
        };
      }

      // Abrufen der empfohlenen Spiele (wenn erlaubt)
      if (result['permissions']['can_view_recommended']) {
        final recommendedGames = await client
            .from('user_games')
            .select('game_id, recommended_at')
            .eq('user_id', userId)
            .eq('is_recommended', true)
            .order('recommended_at', ascending: false)
            .limit(limit);

        result['recommended_games'] = {
          'games': recommendedGames.cast<Map<String, dynamic>>(),
          'total_count': userResponse['total_games_recommended'] ?? 0,
        };
      }

      // Abrufen der Top-Drei (wenn erlaubt)
      if (result['permissions']['can_view_top_three']) {
        final topThreeGames = await client
            .from('user_top_three')
            .select('game_id, position')
            .eq('user_id', userId)
            .order('position', ascending: true);

        result['top_three_games'] = topThreeGames.cast<Map<String, dynamic>>();
      }

      return result;
    } catch (e) {
      if (e is UnauthorizedException) rethrow;
      throw ServerException(message: 'Failed to get user public collections');
    }
  }
}
