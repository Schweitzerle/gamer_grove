// ==========================================
// IMPLEMENTATION
// ==========================================
import 'package:gamer_grove/data/datasources/remote/supabase/supabase_remote_datasource.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;
import '../../../../core/errors/exceptions.dart';
import '../../../../domain/entities/game/game.dart';
import '../../../../domain/entities/user/user_gaming_activity.dart';
import '../../../../domain/entities/user/user_relationship.dart';
import '../../../models/user_model.dart';

class SupabaseRemoteDataSourceImpl implements SupabaseRemoteDataSource {
  final SupabaseClient client;

  SupabaseRemoteDataSourceImpl({required this.client});

  // ==========================================
  // CORE USER PROFILE METHODS
  // ==========================================

  @override
  Future<UserModel> getUserProfile(String userId, [String? currentUserId]) async {
    try {
      final response = await client
          .from('users')
          .select('''
            *,
            is_following:user_follows!user_follows_followed_id_fkey(
              follower_id
            ),
            is_followed_by:user_follows!user_follows_follower_id_fkey(
              followed_id
            )
          ''')
          .eq('id', userId)
          .eq('is_active', true)
          .single();

      if (response.isEmpty) {
        throw ServerException(message: 'User not found');
      }

      // Add social context if current user is provided
      Map<String, dynamic> userData = Map<String, dynamic>.from(response);

      if (currentUserId != null) {
        userData['is_following'] = response['is_following']
            ?.any((follow) => follow['follower_id'] == currentUserId) ?? false;
        userData['is_followed_by'] = response['is_followed_by']
            ?.any((follow) => follow['followed_id'] == currentUserId) ?? false;
      }

      return UserModel.fromJson(userData, currentUserId: currentUserId);
    } on PostgrestException catch (e) {
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
        throw AuthException(message: 'No authenticated user');
      }

      return await getUserProfile(user.id, user.id);
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
      // Verify current user can update this profile
      final currentUser = client.auth.currentUser;
      if (currentUser == null || currentUser.id != userId) {
        throw AuthException(message: 'Unauthorized to update this profile');
      }

      // Build update data
      final Map<String, dynamic> updateData = {};
      if (username != null) updateData['username'] = username;
      if (bio != null) updateData['bio'] = bio;
      if (avatarUrl != null) updateData['avatar_url'] = avatarUrl;
      if (country != null) updateData['country'] = country;
      if (isProfilePublic != null) updateData['is_profile_public'] = isProfilePublic;
      if (showRatedGames != null) updateData['show_rated_games'] = showRatedGames;
      if (showRecommendedGames != null) updateData['show_recommended_games'] = showRecommendedGames;
      if (showTopThree != null) updateData['show_top_three'] = showTopThree;

      updateData['updated_at'] = DateTime.now().toIso8601String();

      final response = await client
          .from('users')
          .update(updateData)
          .eq('id', userId)
          .select()
          .single();

      return UserModel.fromJson(response, currentUserId: userId);
    } on PostgrestException catch (e) {
      if (e.code == '23505') { // Unique constraint violation
        throw ValidationException(message: 'Username already taken');
      }
      throw ServerException(message: e.message);
    } catch (e) {
      if (e is AuthException || e is ValidationException) rethrow;
      throw ServerException(message: 'Failed to update user profile');
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
        throw AuthException(message: 'Unauthorized to update avatar');
      }

      // Upload to Supabase Storage
      final fileName = 'avatar_${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final bytes = Uri.parse(imageData).data?.contentAsBytes();

      if (bytes == null) {
        throw ValidationException(message: 'Invalid image data');
      }

      await client.storage
          .from('avatars')
          .uploadBinary(fileName, bytes);

      final avatarUrl = client.storage
          .from('avatars')
          .getPublicUrl(fileName);

      // Update user record
      await client
          .from('users')
          .update({'avatar_url': avatarUrl, 'updated_at': DateTime.now().toIso8601String()})
          .eq('id', userId);

      return avatarUrl;
    } on StorageException catch (e) {
      throw ServerException(message: 'Failed to upload avatar: ${e.message}');
    } catch (e) {
      if (e is AuthException || e is ValidationException) rethrow;
      throw ServerException(message: 'Failed to update avatar');
    }
  }

  // ==========================================
  // SOCIAL FEATURES - FOLLOW SYSTEM
  // ==========================================

  @override
  Future<void> followUser({
    required String currentUserId,
    required String targetUserId,
  }) async {
    try {
      // Check if users exist and target is not blocked
      final targetUser = await client
          .from('users')
          .select('id, is_active')
          .eq('id', targetUserId)
          .eq('is_active', true)
          .maybeSingle();

      if (targetUser == null) {
        throw ValidationException(message: 'User not found or inactive');
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

      // Check if blocked
      final isBlocked = await isUserBlocked(
        currentUserId: targetUserId,
        targetUserId: currentUserId,
      );

      if (isBlocked) {
        throw ValidationException(message: 'Cannot follow this user');
      }

      // Create follow relationship
      await client
          .from('user_follows')
          .insert({
        'follower_id': currentUserId,
        'followed_id': targetUserId,
      });

    } on PostgrestException catch (e) {
      if (e.code == '23505') { // Unique constraint violation
        throw ValidationException(message: 'Already following this user');
      }
      throw ServerException(message: e.message);
    } catch (e) {
      if (e is ValidationException) rethrow;
      throw ServerException(message: 'Failed to follow user');
    }
  }

  @override
  Future<void> unfollowUser({
    required String currentUserId,
    required String targetUserId,
  }) async {
    try {
      final result = await client
          .from('user_follows')
          .delete()
          .eq('follower_id', currentUserId)
          .eq('followed_id', targetUserId);

      // Note: Supabase doesn't return affected count, so we don't check if unfollowing succeeded
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
        if (follow['follower_id'] == currentUserId && follow['followed_id'] == targetUserId) {
          isFollowing = true;
          followedAt = DateTime.parse(follow['created_at']);
        } else if (follow['follower_id'] == targetUserId && follow['followed_id'] == currentUserId) {
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
      throw ServerException(message: 'Failed to get user followers');
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
      throw ServerException(message: 'Failed to get user following');
    }
  }

  @override
  Future<List<UserModel>> getMutualFollowers({
    required String currentUserId,
    required String targetUserId,
    int limit = 20,
  }) async {
    try {
      final response = await client.rpc(
        'get_mutual_followers',
        params: {
          'user_a': currentUserId,
          'user_b': targetUserId,
          'limit_count': limit,
        },
      );

      return (response as List)
          .map((item) => UserModel.fromJson(item))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to get mutual followers');
    }
  }

  @override
  Future<List<UserModel>> getFollowSuggestions({
    required String userId,
    int limit = 20,
  }) async {
    try {
      // Get suggestions based on mutual follows and popular users
      final response = await client
          .from('users')
          .select('*')
          .neq('id', userId)
          .eq('is_active', true)
          .eq('is_profile_public', true)
          .not('id', 'in', '(${await _getAlreadyFollowingIds(userId)})')
          .order('followers_count', ascending: false)
          .limit(limit);

      return response
          .map((item) => UserModel.fromJson(item, currentUserId: userId))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to get follow suggestions');
    }
  }

  Future<String> _getAlreadyFollowingIds(String userId) async {
    final following = await client
        .from('user_follows')
        .select('followed_id')
        .eq('follower_id', userId);

    if (following.isEmpty) return userId; // Just exclude self

    final ids = following.map((f) => f['followed_id']).join(',');
    return '$ids,$userId'; // Include self in exclusion
  }

  // ==========================================
  // USER SEARCH & DISCOVERY
  // ==========================================

  @override
  Future<List<UserModel>> searchUsers({
    required String query,
    String? currentUserId,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await client
          .from('users')
          .select('*')
          .or('username.ilike.%$query%,bio.ilike.%$query%')
          .eq('is_active', true)
          .eq('is_profile_public', true)
          .order('followers_count', ascending: false)
          .range(offset, offset + limit - 1);

      return response
          .map((item) => UserModel.fromJson(item, currentUserId: currentUserId))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to search users');
    }
  }

  @override
  Future<List<UserModel>> getPopularUsers({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await client
          .from('users')
          .select('*')
          .eq('is_active', true)
          .eq('is_profile_public', true)
          .gte('followers_count', 1)
          .order('followers_count', ascending: false)
          .range(offset, offset + limit - 1);

      return response
          .map((item) => UserModel.fromJson(item))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to get popular users');
    }
  }

  @override
  Future<List<UserModel>> getNewUsers({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await client
          .from('users')
          .select('*')
          .eq('is_active', true)
          .eq('is_profile_public', true)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return response
          .map((item) => UserModel.fromJson(item))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to get new users');
    }
  }

  @override
  Future<List<UserModel>> getSimilarUsers({
    required String userId,
    int limit = 20,
  }) async {
    try {
      // This would be more complex in real implementation
      // For now, get users with similar game preferences
      final response = await client.rpc(
        'get_similar_users',
        params: {
          'target_user_id': userId,
          'limit_count': limit,
        },
      );

      return (response as List)
          .map((item) => UserModel.fromJson(item, currentUserId: userId))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to get similar users');
    }
  }

  // ==========================================
  // TOP THREE GAMES MANAGEMENT
  // ==========================================

  @override
  Future<void> updateTopThreeGames({
    required String userId,
    required List<int> gameIds,
  }) async {
    try {
      final currentUser = client.auth.currentUser;
      if (currentUser == null || currentUser.id != userId) {
        throw AuthException(message: 'Unauthorized to update top three');
      }

      if (gameIds.length != 3) {
        throw ValidationException(message: 'Must provide exactly 3 games');
      }

      await client
          .from('users')
          .update({
        'top_game_1': gameIds[0],
        'top_game_2': gameIds[1],
        'top_game_3': gameIds[2],
        'updated_at': DateTime.now().toIso8601String(),
      })
          .eq('id', userId);

    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      if (e is AuthException || e is ValidationException) rethrow;
      throw ServerException(message: 'Failed to update top three games');
    }
  }

  @override
  Future<List<Game>> getUserTopThreeGames({
    required String userId,
  }) async {
    try {
      final userResponse = await client
          .from('users')
          .select('top_game_1, top_game_2, top_game_3, show_top_three, is_profile_public')
          .eq('id', userId)
          .single();

      final currentUser = client.auth.currentUser;
      final canView = userResponse['is_profile_public'] == true ||
          (currentUser?.id == userId);

      if (!canView || userResponse['show_top_three'] != true) {
        throw UnauthorizedException(message: 'Cannot view top three games');
      }

      final gameIds = [
        userResponse['top_game_1'],
        userResponse['top_game_2'],
        userResponse['top_game_3'],
      ].where((id) => id != null).cast<int>().toList();

      if (gameIds.isEmpty) {
        return [];
      }

      // Here you would fetch game details from IGDB or your games table
      // For now, return empty list or mock games
      return [];

    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      if (e is UnauthorizedException) rethrow;
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
      final currentUser = client.auth.currentUser;
      if (currentUser == null || currentUser.id != userId) {
        throw AuthException(message: 'Unauthorized to update top three');
      }

      if (position < 1 || position > 3) {
        throw ValidationException(message: 'Position must be 1, 2, or 3');
      }

      final columnName = 'top_game_$position';

      await client
          .from('users')
          .update({
        columnName: gameId,
        'updated_at': DateTime.now().toIso8601String(),
      })
          .eq('id', userId);

    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      if (e is AuthException || e is ValidationException) rethrow;
      throw ServerException(message: 'Failed to set top three game');
    }
  }

  @override
  Future<void> removeFromTopThree({
    required String userId,
    required int position,
  }) async {
    try {
      final currentUser = client.auth.currentUser;
      if (currentUser == null || currentUser.id != userId) {
        throw AuthException(message: 'Unauthorized to update top three');
      }

      if (position < 1 || position > 3) {
        throw ValidationException(message: 'Position must be 1, 2, or 3');
      }

      final columnName = 'top_game_$position';

      await client
          .from('users')
          .update({
        columnName: null,
        'updated_at': DateTime.now().toIso8601String(),
      })
          .eq('id', userId);

    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      if (e is AuthException || e is ValidationException) rethrow;
      throw ServerException(message: 'Failed to remove from top three');
    }
  }

  @override
  Future<void> reorderTopThree({
    required String userId,
    required Map<int, int> positionToGameId,
  }) async {
    try {
      final currentUser = client.auth.currentUser;
      if (currentUser == null || currentUser.id != userId) {
        throw AuthException(message: 'Unauthorized to update top three');
      }

      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      for (final entry in positionToGameId.entries) {
        if (entry.key < 1 || entry.key > 3) {
          throw ValidationException(message: 'Invalid position: ${entry.key}');
        }
        updateData['top_game_${entry.key}'] = entry.value;
      }

      await client
          .from('users')
          .update(updateData)
          .eq('id', userId);

    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      if (e is AuthException || e is ValidationException) rethrow;
      throw ServerException(message: 'Failed to reorder top three');
    }
  }

  // ==========================================
  // USER GAME COLLECTIONS (PUBLIC VISIBILITY)
  // ==========================================

  @override
  Future<List<Game>> getUserPublicRatedGames({
    required String userId,
    String? currentUserId,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      // Check if user allows viewing rated games
      final userResponse = await client
          .from('users')
          .select('show_rated_games, is_profile_public')
          .eq('id', userId)
          .single();

      final canView = userResponse['is_profile_public'] == true ||
          (currentUserId == userId);

      if (!canView || userResponse['show_rated_games'] != true) {
        throw UnauthorizedException(message: 'Cannot view rated games');
      }

      final response = await client
          .from('user_games')
          .select('game_id, rating, rated_at')
          .eq('user_id', userId)
          .eq('is_rated', true)
          .order('rated_at', ascending: false)
          .range(offset, offset + limit - 1);

      // Here you would fetch game details from IGDB
      // For now, return empty list
      return [];

    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      if (e is UnauthorizedException) rethrow;
      throw ServerException(message: 'Failed to get rated games');
    }
  }

  @override
  Future<List<Game>> getUserPublicRecommendedGames({
    required String userId,
    String? currentUserId,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      // Check if user allows viewing recommended games
      final userResponse = await client
          .from('users')
          .select('show_recommended_games, is_profile_public')
          .eq('id', userId)
          .single();

      final canView = userResponse['is_profile_public'] == true ||
          (currentUserId == userId);

      if (!canView || userResponse['show_recommended_games'] != true) {
        throw UnauthorizedException(message: 'Cannot view recommended games');
      }

      final response = await client
          .from('user_games')
          .select('game_id, recommended_at')
          .eq('user_id', userId)
          .eq('is_recommended', true)
          .order('recommended_at', ascending: false)
          .range(offset, offset + limit - 1);

      // Here you would fetch game details from IGDB
      // For now, return empty list
      return [];

    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      if (e is UnauthorizedException) rethrow;
      throw ServerException(message: 'Failed to get recommended games');
    }
  }

  @override
  Future<Map<String, dynamic>> getUserPublicCollections({
    required String userId,
    String? currentUserId,
  }) async {
    try {
      final userResponse = await client
          .from('users')
          .select('''
            show_rated_games, 
            show_recommended_games, 
            show_top_three,
            is_profile_public,
            total_games_rated,
            total_games_recommended
          ''')
          .eq('id', userId)
          .single();

      final canView = userResponse['is_profile_public'] == true ||
          (currentUserId == userId);

      if (!canView) {
        throw UnauthorizedException(message: 'Cannot view user collections');
      }

      return {
        'show_rated_games': userResponse['show_rated_games'],
        'show_recommended_games': userResponse['show_recommended_games'],
        'show_top_three': userResponse['show_top_three'],
        'total_games_rated': userResponse['total_games_rated'],
        'total_games_recommended': userResponse['total_games_recommended'],
      };

    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      if (e is UnauthorizedException) rethrow;
      throw ServerException(message: 'Failed to get user collections');
    }
  }

  // ==========================================
  // USER ACTIVITY & ANALYTICS
  // ==========================================

  @override
  Future<UserGamingActivity> getUserActivity({
    required String userId,
    Duration? timeWindow,
  }) async {
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
  Future<Map<String, dynamic>> getUserGamingStats({
    required String userId,
    String? currentUserId,
  }) async {
    try {
      final response = await client
          .from('users')
          .select('''
            total_games_rated,
            total_games_recommended,
            average_rating,
            created_at
          ''')
          .eq('id', userId)
          .single();

      return response;
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to get gaming stats');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getUserRecentActivity({
    required String userId,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await client
          .from('user_activity_log')
          .select('*')
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return response.cast<Map<String, dynamic>>();
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to get user activity');
    }
  }

  // ==========================================
  // SOCIAL FEED & ACTIVITY
  // ==========================================

  @override
  Future<List<Map<String, dynamic>>> getUserFeed({
    required String userId,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await client.rpc(
        'get_user_feed',
        params: {
          'target_user_id': userId,
          'limit_count': limit,
          'offset_count': offset,
        },
      );

      return (response as List).cast<Map<String, dynamic>>();
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to get user feed');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getGlobalFeed({
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await client
          .from('user_activity_feed')
          .select('*')
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return response.cast<Map<String, dynamic>>();
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to get global feed');
    }
  }

  @override
  Future<List<UserModel>> getTrendingUsers({
    Duration? timeWindow,
    int limit = 20,
  }) async {
    try {
      final since = timeWindow != null
          ? DateTime.now().subtract(timeWindow)
          : DateTime.now().subtract(const Duration(days: 7));

      final response = await client.rpc(
        'get_trending_users',
        params: {
          'since_date': since.toIso8601String(),
          'limit_count': limit,
        },
      );

      return (response as List)
          .map((item) => UserModel.fromJson(item))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to get trending users');
    }
  }

  // ==========================================
  // USER PRIVACY & SETTINGS
  // ==========================================

  @override
  Future<void> updatePrivacySettings({
    required String userId,
    bool? isProfilePublic,
    bool? showRatedGames,
    bool? showRecommendedGames,
    bool? showTopThree,
    bool? allowFollowRequests,
  }) async {
    try {
      final currentUser = client.auth.currentUser;
      if (currentUser == null || currentUser.id != userId) {
        throw AuthException(message: 'Unauthorized to update privacy settings');
      }

      final Map<String, dynamic> updateData = {
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (isProfilePublic != null) updateData['is_profile_public'] = isProfilePublic;
      if (showRatedGames != null) updateData['show_rated_games'] = showRatedGames;
      if (showRecommendedGames != null) updateData['show_recommended_games'] = showRecommendedGames;
      if (showTopThree != null) updateData['show_top_three'] = showTopThree;
      if (allowFollowRequests != null) updateData['allow_follow_requests'] = allowFollowRequests;

      await client
          .from('users')
          .update(updateData)
          .eq('id', userId);

    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw ServerException(message: 'Failed to update privacy settings');
    }
  }

  @override
  Future<void> blockUser({
    required String currentUserId,
    required String targetUserId,
  }) async {
    try {
      // Remove any existing follow relationships
      await unfollowUser(currentUserId: currentUserId, targetUserId: targetUserId);
      await unfollowUser(currentUserId: targetUserId, targetUserId: currentUserId);

      // Create block relationship
      await client
          .from('user_blocks')
          .insert({
        'blocker_id': currentUserId,
        'blocked_id': targetUserId,
      });

    } on PostgrestException catch (e) {
      if (e.code == '23505') { // Already blocked
        return; // Idempotent operation
      }
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to block user');
    }
  }

  @override
  Future<void> unblockUser({
    required String currentUserId,
    required String targetUserId,
  }) async {
    try {
      await client
          .from('user_blocks')
          .delete()
          .eq('blocker_id', currentUserId)
          .eq('blocked_id', targetUserId);

    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to unblock user');
    }
  }

  @override
  Future<List<UserModel>> getBlockedUsers({
    required String userId,
  }) async {
    try {
      final response = await client
          .from('user_blocks')
          .select('''
            blocked:users!user_blocks_blocked_id_fkey(*)
          ''')
          .eq('blocker_id', userId)
          .order('created_at', ascending: false);

      return response
          .map((item) => UserModel.fromJson(item['blocked']))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to get blocked users');
    }
  }

  @override
  Future<bool> isUserBlocked({
    required String currentUserId,
    required String targetUserId,
  }) async {
    try {
      final block = await client
          .from('user_blocks')
          .select('id')
          .eq('blocker_id', currentUserId)
          .eq('blocked_id', targetUserId)
          .maybeSingle();

      return block != null;
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to check block status');
    }
  }

  // ==========================================
  // BATCH OPERATIONS
  // ==========================================

  @override
  Future<void> followMultipleUsers({
    required String currentUserId,
    required List<String> targetUserIds,
  }) async {
    try {
      final followData = targetUserIds.map((id) => {
        'follower_id': currentUserId,
        'followed_id': id,
      }).toList();

      await client
          .from('user_follows')
          .insert(followData);

    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to follow multiple users');
    }
  }

  @override
  Future<List<UserModel>> getMultipleUserProfiles({
    required List<String> userIds,
    String? currentUserId,
  }) async {
    try {
      final response = await client
          .from('users')
          .select('*')
          .inFilter('id', userIds)
          .eq('is_active', true);

      return response
          .map((item) => UserModel.fromJson(item, currentUserId: currentUserId))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to get multiple user profiles');
    }
  }

  @override
  Future<Map<String, bool>> getMultipleFollowStatus({
    required String currentUserId,
    required List<String> targetUserIds,
  }) async {
    try {
      final response = await client
          .from('user_follows')
          .select('followed_id')
          .eq('follower_id', currentUserId)
          .inFilter('followed_id', targetUserIds);

      final followingIds = response.map((item) => item['followed_id'] as String).toSet();

      return Map.fromEntries(
        targetUserIds.map((id) => MapEntry(id, followingIds.contains(id))),
      );
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to get multiple follow status');
    }
  }

  // ==========================================
  // USER VERIFICATION & MODERATION
  // ==========================================

  @override
  Future<void> reportUser({
    required String reporterId,
    required String reportedUserId,
    required String reason,
    String? description,
  }) async {
    try {
      await client
          .from('user_reports')
          .insert({
        'reporter_id': reporterId,
        'reported_id': reportedUserId,
        'reason': reason,
        'description': description,
      });

    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to report user');
    }
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
    try {
      // Simple username suggestions
      final suggestions = <String>[];
      for (int i = 1; i <= 5; i++) {
        final suggestion = '${baseUsername}_$i';
        if (await isUsernameAvailable(suggestion)) {
          suggestions.add(suggestion);
        }
      }
      return suggestions;
    } catch (e) {
      throw ServerException(message: 'Failed to suggest usernames');
    }
  }

  // ==========================================
  // USER DELETION & ACCOUNT MANAGEMENT
  // ==========================================

  @override
  Future<void> deleteUserAccount(String userId) async {
    try {
      final currentUser = client.auth.currentUser;
      if (currentUser == null || currentUser.id != userId) {
        throw AuthException(message: 'Unauthorized to delete account');
      }

      // Delete user record (cascading deletes will handle related data)
      await client
          .from('users')
          .delete()
          .eq('id', userId);

      // Sign out the user
      await client.auth.signOut();

    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw ServerException(message: 'Failed to delete user account');
    }
  }

  @override
  Future<void> deactivateUserAccount(String userId) async {
    try {
      final currentUser = client.auth.currentUser;
      if (currentUser == null || currentUser.id != userId) {
        throw AuthException(message: 'Unauthorized to deactivate account');
      }

      await client
          .from('users')
          .update({
        'is_active': false,
        'is_deactivated': true,
        'deactivated_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      })
          .eq('id', userId);

    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw ServerException(message: 'Failed to deactivate user account');
    }
  }

  @override
  Future<void> reactivateUserAccount(String userId) async {
    try {
      final currentUser = client.auth.currentUser;
      if (currentUser == null || currentUser.id != userId) {
        throw AuthException(message: 'Unauthorized to reactivate account');
      }

      await client
          .from('users')
          .update({
        'is_active': true,
        'is_deactivated': false,
        'deactivated_at': null,
        'updated_at': DateTime.now().toIso8601String(),
      })
          .eq('id', userId);

    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw ServerException(message: 'Failed to reactivate user account');
    }
  }

  // ==========================================
  // AUTH RELATED (existing methods from your current implementation)
  // ==========================================

  @override
  Future<UserModel> signIn(String email, String password) async {
    try {
      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw AuthException(message: 'Sign in failed');
      }

      return await getCurrentUserProfile();
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException(message: 'Sign in failed');
    }
  }

  @override
  Future<UserModel> signUp(String email, String password, String username) async {
    try {
      // Check if username is available
      if (!await isUsernameAvailable(username)) {
        throw ValidationException(message: 'Username already taken');
      }

      final response = await client.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw AuthException(message: 'Sign up failed');
      }

      // Create user profile
      final userModel = UserModel.fromAuth(
        id: response.user!.id,
        email: email,
        username: username,
      );

      await client.from('users').insert(userModel.toJson());

      return userModel;
    } on AuthException {
      rethrow;
    } on ValidationException {
      rethrow;
    } catch (e) {
      throw AuthException(message: 'Sign up failed');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await client.auth.signOut();
    } catch (e) {
      throw AuthException(message: 'Sign out failed');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = client.auth.currentUser;
      if (user == null) return null;

      return await getCurrentUserProfile();
    } catch (e) {
      return null;
    }
  }
}