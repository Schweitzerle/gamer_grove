// data/datasources/remote/supabase_remote_datasource.dart
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import '../../../core/errors/exceptions.dart';
import '../../../core/constants/api_constants.dart';
import '../../models/user_model.dart';
import '../../../main.dart';

abstract class SupabaseRemoteDataSource {
  // Auth
  Future<UserModel> signIn(String email, String password);
  Future<UserModel> signUp(String email, String password, String username);
  Future<void> signOut();
  Future<UserModel?> getCurrentUser();
  Stream<sb.AuthState> get authStateChanges;

  // User Profile
  Future<UserModel> getUserProfile(String userId);
  Future<UserModel> updateUserProfile(String userId, Map<String, dynamic> updates);
  Future<List<UserModel>> searchUsers(String query);

  // Game Operations
  Future<void> toggleWishlist(int gameId, String userId);
  Future<void> toggleRecommended(int gameId, String userId);
  Future<void> rateGame(int gameId, String userId, double rating);
  Future<List<int>> getUserWishlistIds(String userId);
  Future<List<int>> getUserRecommendedIds(String userId);
  Future<Map<int, double>> getUserRatings(String userId);

  // Social
  Future<void> followUser(String currentUserId, String targetUserId);
  Future<void> unfollowUser(String currentUserId, String targetUserId);
  Future<List<String>> getUserFollowers(String userId);
  Future<List<String>> getUserFollowing(String userId);

  // Top Games
  Future<void> updateTopThreeGames(String userId, List<int> gameIds);
  Future<List<int>> getTopThreeGames(String userId);
}

class SupabaseRemoteDataSourceImpl implements SupabaseRemoteDataSource {
  final _supabase = supabase;

  @override
  Future<UserModel> signIn(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw AuthException(message: 'Login failed');
      }

      return await getUserProfile(response.user!.id);
    } on sb.AuthException catch (e) {
      throw AuthException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Unexpected error during sign in');
    }
  }

  @override
  Future<UserModel> signUp(String email, String password, String username) async {
    try {
      // Check if username is already taken
      final existingUser = await _supabase
          .from(SupabaseTables.users)
          .select()
          .eq('username', username)
          .maybeSingle();

      if (existingUser != null) {
        throw AuthException(message: 'Username already taken');
      }

      // Sign up
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'username': username},
      );

      if (response.user == null) {
        throw AuthException(message: 'Sign up failed');
      }

      // Wait a bit for the trigger to create the profile
      await Future.delayed(const Duration(seconds: 1));

      return await getUserProfile(response.user!.id);
    } on sb.AuthException catch (e) {
      throw AuthException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Unexpected error during sign up');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      throw ServerException(message: 'Failed to sign out');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return null;

      return await getUserProfile(user.id);
    } catch (e) {
      return null;
    }
  }

  @override
  Stream<sb.AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  @override
  Future<UserModel> getUserProfile(String userId) async {
    try {
      final profileData = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      // Get email from auth
      final authUser = _supabase.auth.currentUser;
      final email = authUser?.id == userId ? authUser!.email! : '';

      // Add email to profile data
      profileData['email'] = email;

      // Get additional data
      final wishlist = await getUserWishlistIds(userId);
      final recommended = await getUserRecommendedIds(userId);
      final ratings = await getUserRatings(userId);
      final followers = await getUserFollowers(userId);
      final following = await getUserFollowing(userId);
      final topGames = await getTopThreeGames(userId);

      return UserModel.fromSupabase(
        profileData,
        wishlistIds: wishlist,
        recommendedIds: recommended,
        ratings: ratings,
        followerIds: followers,
        followingIds: following,
        topThreeGames: topGames,
      );
    } catch (e) {
      throw ServerException(message: 'Failed to get user profile');
    }
  }

  @override
  Future<UserModel> updateUserProfile(String userId, Map<String, dynamic> updates) async {
    try {
      // Handle avatar upload if present
      if (updates['avatarFile'] != null) {
        final file = updates['avatarFile'];
        updates.remove('avatarFile');

        final fileName = '$userId/avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final uploadResponse = await _supabase.storage
            .from('avatars')
            .upload(fileName, file);

        if (uploadResponse.isNotEmpty) {
          final url = _supabase.storage
              .from('avatars')
              .getPublicUrl(fileName);
          updates['avatar_url'] = url;
        }
      }

      await _supabase
          .from('profiles')
          .update(updates)
          .eq('id', userId);

      return await getUserProfile(userId);
    } catch (e) {
      throw ServerException(message: 'Failed to update profile');
    }
  }

  @override
  Future<List<UserModel>> searchUsers(String query) async {
    try {
      final results = await _supabase
          .from('profiles')
          .select()
          .ilike('username', '%$query%')
          .limit(20);

      return results.map<UserModel>((data) =>
          UserModel.fromSupabase(data)
      ).toList();
    } catch (e) {
      throw ServerException(message: 'Failed to search users');
    }
  }

  @override
  Future<void> toggleWishlist(int gameId, String userId) async {
    try {
      final existing = await _supabase
          .from('user_games')
          .select()
          .eq('user_id', userId)
          .eq('game_id', gameId)
          .maybeSingle();

      if (existing != null) {
        if (existing['is_wishlisted'] == true) {
          // Remove from wishlist
          await _supabase
              .from('user_games')
              .update({'is_wishlisted': false})
              .eq('id', existing['id']);
        } else {
          // Add to wishlist
          await _supabase
              .from('user_games')
              .update({'is_wishlisted': true})
              .eq('id', existing['id']);
        }
      } else {
        // Create new entry
        await _supabase
            .from('user_games')
            .insert({
          'user_id': userId,
          'game_id': gameId,
          'is_wishlisted': true,
          'is_recommended': false,
        });
      }
    } catch (e) {
      throw ServerException(message: 'Failed to toggle wishlist');
    }
  }

  @override
  Future<void> toggleRecommended(int gameId, String userId) async {
    try {
      final existing = await _supabase
          .from('user_games')
          .select()
          .eq('user_id', userId)
          .eq('game_id', gameId)
          .maybeSingle();

      if (existing != null) {
        await _supabase
            .from('user_games')
            .update({'is_recommended': !(existing['is_recommended'] ?? false)})
            .eq('id', existing['id']);
      } else {
        await _supabase
            .from('user_games')
            .insert({
          'user_id': userId,
          'game_id': gameId,
          'is_wishlisted': false,
          'is_recommended': true,
        });
      }
    } catch (e) {
      throw ServerException(message: 'Failed to toggle recommendation');
    }
  }

  @override
  Future<void> rateGame(int gameId, String userId, double rating) async {
    try {
      await _supabase
          .from('game_ratings')
          .upsert({
        'user_id': userId,
        'game_id': gameId,
        'rating': rating,
      }, onConflict: 'user_id,game_id');
    } catch (e) {
      throw ServerException(message: 'Failed to rate game');
    }
  }

  @override
  Future<List<int>> getUserWishlistIds(String userId) async {
    try {
      final results = await _supabase
          .from('user_games')
          .select('game_id')
          .eq('user_id', userId)
          .eq('is_wishlisted', true);

      return results.map<int>((item) => item['game_id'] as int).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<int>> getUserRecommendedIds(String userId) async {
    try {
      final results = await _supabase
          .from('user_games')
          .select('game_id')
          .eq('user_id', userId)
          .eq('is_recommended', true);

      return results.map<int>((item) => item['game_id'] as int).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<Map<int, double>> getUserRatings(String userId) async {
    try {
      final results = await _supabase
          .from('game_ratings')
          .select('game_id, rating')
          .eq('user_id', userId);

      return Map.fromEntries(
        results.map((item) => MapEntry(
          item['game_id'] as int,
          (item['rating'] as num).toDouble(),
        )),
      );
    } catch (e) {
      return {};
    }
  }

  @override
  Future<void> followUser(String currentUserId, String targetUserId) async {
    try {
      await _supabase
          .from('user_follows')
          .insert({
        'follower_id': currentUserId,
        'following_id': targetUserId,
      });
    } catch (e) {
      throw ServerException(message: 'Failed to follow user');
    }
  }

  @override
  Future<void> unfollowUser(String currentUserId, String targetUserId) async {
    try {
      await _supabase
          .from('user_follows')
          .delete()
          .eq('follower_id', currentUserId)
          .eq('following_id', targetUserId);
    } catch (e) {
      throw ServerException(message: 'Failed to unfollow user');
    }
  }

  @override
  Future<List<String>> getUserFollowers(String userId) async {
    try {
      final results = await _supabase
          .from('user_follows')
          .select('follower_id')
          .eq('following_id', userId);

      return results.map<String>((item) => item['follower_id'] as String).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<String>> getUserFollowing(String userId) async {
    try {
      final results = await _supabase
          .from('user_follows')
          .select('following_id')
          .eq('follower_id', userId);

      return results.map<String>((item) => item['following_id'] as String).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> updateTopThreeGames(String userId, List<int> gameIds) async {
    try {
      // Delete existing top games
      await _supabase
          .from('user_top_games')
          .delete()
          .eq('user_id', userId);

      // Insert new top games
      final inserts = gameIds.asMap().entries.map((entry) => {
        'user_id': userId,
        'game_id': entry.value,
        'position': entry.key + 1,
      }).toList();

      if (inserts.isNotEmpty) {
        await _supabase
            .from('user_top_games')
            .insert(inserts);
      }
    } catch (e) {
      throw ServerException(message: 'Failed to update top games');
    }
  }

  @override
  Future<List<int>> getTopThreeGames(String userId) async {
    try {
      final results = await _supabase
          .from('user_top_games')
          .select('game_id, position')
          .eq('user_id', userId)
          .order('position');

      return results.map<int>((item) => item['game_id'] as int).toList();
    } catch (e) {
      return [];
    }
  }
}