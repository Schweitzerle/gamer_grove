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
  Future<List<int>> getUserRatedIds(String userId);
  Future<Map<int, double>> getUserRatings(String userId);
  Future<Map<String, dynamic>?> getUserGameData(String userId, int gameId);

    // Social
  Future<void> followUser(String currentUserId, String targetUserId);
  Future<void> unfollowUser(String currentUserId, String targetUserId);
  Future<List<String>> getUserFollowers(String userId);
  Future<List<String>> getUserFollowing(String userId);

  // Top Games
  Future<void> updateTopThreeGames(String userId, List<int> gameIds);
  Future<List<Map<String, dynamic>>> getTopThreeGamesWithPosition(String userId);
  Future<List<int>> getTopThreeGames(String userId);
}

class SupabaseRemoteDataSourceImpl implements SupabaseRemoteDataSource {
  final _supabase = supabase;

  // Angepasste supabase_remote_datasource.dart für die neue Struktur
// Ersetze die Game Operations Methoden mit diesen:

  // =======================================
  // GAME OPERATIONS - NEUE IMPLEMENTIERUNG
  // =======================================

  @override
  Future<void> toggleWishlist(int gameId, String userId) async {
    try {
      print('💝 Supabase: Toggling wishlist for game $gameId, user $userId');

      // Check current state
      final existing = await _supabase
          .from('user_game_interactions')
          .select('is_wishlisted')
          .eq('user_id', userId)
          .eq('game_id', gameId)
          .maybeSingle();

      if (existing != null) {
        // Toggle existing
        final newState = !(existing['is_wishlisted'] ?? false);
        await _supabase
            .from('user_game_interactions')
            .update({
          'is_wishlisted': newState,
          // Timestamp wird automatisch durch Trigger gesetzt
        })
            .eq('user_id', userId)
            .eq('game_id', gameId);
        print('✅ Supabase: Wishlist toggled to: $newState');
      } else {
        // Create new entry
        await _supabase
            .from('user_game_interactions')
            .insert({
          'user_id': userId,
          'game_id': gameId,
          'is_wishlisted': true,
        });
        print('✅ Supabase: New wishlist entry created');
      }
    } catch (e) {
      print('❌ Supabase: Failed to toggle wishlist: $e');
      throw ServerException(message: 'Failed to toggle wishlist: $e');
    }
  }

  @override
  Future<void> toggleRecommended(int gameId, String userId) async {
    try {
      print('👍 Supabase: Toggling recommendation for game $gameId, user $userId');

      // Check current state
      final existing = await _supabase
          .from('user_game_interactions')
          .select('is_recommended')
          .eq('user_id', userId)
          .eq('game_id', gameId)
          .maybeSingle();

      if (existing != null) {
        // Toggle existing
        final newState = !(existing['is_recommended'] ?? false);
        await _supabase
            .from('user_game_interactions')
            .update({
          'is_recommended': newState,
          // Timestamp wird automatisch durch Trigger gesetzt
        })
            .eq('user_id', userId)
            .eq('game_id', gameId);
        print('✅ Supabase: Recommendation toggled to: $newState');
      } else {
        // Create new entry
        await _supabase
            .from('user_game_interactions')
            .insert({
          'user_id': userId,
          'game_id': gameId,
          'is_recommended': true,
        });
        print('✅ Supabase: New recommendation entry created');
      }
    } catch (e) {
      print('❌ Supabase: Failed to toggle recommendation: $e');
      throw ServerException(message: 'Failed to toggle recommendation: $e');
    }
  }

  @override
  Future<void> rateGame(int gameId, String userId, double rating) async {
    try {
      print('⭐ Supabase: Rating game $gameId with $rating by user $userId');

      // Validate rating
      if (rating < 0 || rating > 10) {
        throw ServerException(message: 'Rating must be between 0 and 10');
      }

      // Check if entry exists
      final existing = await _supabase
          .from('user_game_interactions')
          .select('id')
          .eq('user_id', userId)
          .eq('game_id', gameId)
          .maybeSingle();

      if (existing != null) {
        // Update existing
        await _supabase
            .from('user_game_interactions')
            .update({
          'rating': rating,
          // rated_at wird automatisch durch Trigger gesetzt
        })
            .eq('user_id', userId)
            .eq('game_id', gameId);
        print('✅ Supabase: Rating updated: $rating');
      } else {
        // Create new entry
        await _supabase
            .from('user_game_interactions')
            .insert({
          'user_id': userId,
          'game_id': gameId,
          'rating': rating,
        });
        print('✅ Supabase: New rating created: $rating');
      }
    } catch (e) {
      print('❌ Supabase: Failed to rate game: $e');
      throw ServerException(message: 'Failed to rate game: $e');
    }
  }

  @override
  Future<List<int>> getUserWishlistIds(String userId) async {
    try {
      final results = await _supabase
          .from('user_game_interactions')
          .select('game_id')
          .eq('user_id', userId)
          .eq('is_wishlisted', true)
          .order('wishlisted_at', ascending: false);

      return results.map<int>((item) => item['game_id'] as int).toList();
    } catch (e) {
      print('⚠️ Supabase: Error getting wishlist: $e');
      return [];
    }
  }

  @override
  Future<List<int>> getUserRecommendedIds(String userId) async {
    try {
      final results = await _supabase
          .from('user_game_interactions')
          .select('game_id')
          .eq('user_id', userId)
          .eq('is_recommended', true)
          .order('recommended_at', ascending: false);

      return results.map<int>((item) => item['game_id'] as int).toList();
    } catch (e) {
      print('⚠️ Supabase: Error getting recommended games: $e');
      return [];
    }
  }

  @override
  Future<Map<int, double>> getUserRatings(String userId) async {
    try {
      final results = await _supabase
          .from('user_game_interactions')
          .select('game_id, rating')
          .eq('user_id', userId)
          .not('rating', 'is', null)
          .order('rated_at', ascending: false);

      return Map.fromEntries(
        results.map((item) => MapEntry(
          item['game_id'] as int,
          double.parse(item['rating'].toString()),
        )),
      );
    } catch (e) {
      print('⚠️ Supabase: Error getting ratings: $e');
      return {};
    }
  }

  // NEUE HILFSMETHODE: Hole alle User-Game Daten auf einmal
  Future<Map<String, dynamic>?> getUserGameInteraction(int gameId, String userId) async {
    try {
      final result = await _supabase
          .from('user_game_interactions')
          .select()
          .eq('user_id', userId)
          .eq('game_id', gameId)
          .maybeSingle();

      return result;
    } catch (e) {
      print('⚠️ Supabase: Error getting user game interaction: $e');
      return null;
    }
  }

  // Top Games bleiben gleich, da die Tabelle nicht geändert wurde
  @override
  Future<void> updateTopThreeGames(String userId, List<int> gameIds) async {
    try {
      print('🏆 Supabase: Updating top games for user $userId: $gameIds');

      if (gameIds.length > 3) {
        throw ServerException(message: 'Maximum 3 games allowed');
      }

      // Delete existing top games
      await _supabase
          .from('user_top_games')
          .delete()
          .eq('user_id', userId);

      // Insert new top games
      if (gameIds.isNotEmpty) {
        final inserts = gameIds.asMap().entries.map((entry) => {
          'user_id': userId,
          'game_id': entry.value,
          'position': entry.key + 1,
        }).toList();

        await _supabase
            .from('user_top_games')
            .insert(inserts);
      }

      print('✅ Supabase: Top games updated');
    } catch (e) {
      print('❌ Supabase: Failed to update top games: $e');
      throw ServerException(message: 'Failed to update top games: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getTopThreeGamesWithPosition(String userId) async {
    try {
      final results = await _supabase
          .from('user_top_games')
          .select('game_id, position')
          .eq('user_id', userId)
          .order('position');

      return results;
    } catch (e) {
      print('⚠️ Supabase: Error getting top games with position: $e');
      return [];
    }
  }

// Also update AddToTopThree to handle the position properly
  Future<void> addToTopThree(int gameId, String userId, int position) async {
    try {
      print('🏆 Supabase: Adding game $gameId to position $position for user $userId');

      // Get current top three
      final currentTopThree = await getTopThreeGamesWithPosition(userId);

      // Create new list with the game at the specified position
      List<int> newTopThree = List.from(currentTopThree);

      // Remove the game if it already exists
      newTopThree.remove(gameId);

      // Ensure list has enough space
      while (newTopThree.length < 3) {
        newTopThree.add(0); // Use 0 as placeholder
      }

      // Insert at the specified position (converting from 1-based to 0-based)
      if (position > 0 && position <= 3) {
        newTopThree[position - 1] = gameId;
      }

      // Remove any 0 placeholders
      newTopThree = newTopThree.where((id) => id != 0).toList();

      // Update the top three
      await updateTopThreeGames(userId, newTopThree);

      print('✅ Supabase: Game added to top three at position $position');
    } catch (e) {
      print('❌ Supabase: Failed to add to top three: $e');
      throw ServerException(message: 'Failed to add to top three: $e');
    }
  }

  @override
  Future<UserModel> signIn(String email, String password) async {
    try {
      print('🔐 Supabase: Signing in user...');
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw AuthException(message: 'Login failed');
      }

      print('✅ Supabase: Sign in successful');
      return await getUserProfile(response.user!.id);
    } on sb.AuthException catch (e) {
      print('❌ Supabase: Auth exception: ${e.message}');
      throw AuthException(message: e.message);
    } catch (e) {
      print('💥 Supabase: Unexpected error during sign in: $e');
      throw ServerException(message: 'Unexpected error during sign in');
    }
  }

  @override
  Future<UserModel> signUp(String email, String password, String username) async {
    print('📡 Supabase: Starting signup process...');
    print('📧 Supabase: Email: $email');
    print('👤 Supabase: Username: $username');

    try {
      // Check if username is already taken
      print('🔍 Supabase: Checking if username exists...');
      final existingUser = await _supabase
          .from(SupabaseTables.profiles)
          .select()
          .eq('username', username)
          .maybeSingle();

      if (existingUser != null) {
        print('❌ Supabase: Username already taken: $username');
        throw AuthException(message: 'Username already taken');
      }
      print('✅ Supabase: Username available');

      // Sign up
      print('🔐 Supabase: Calling auth.signUp...');
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'username': username},
      );

      print('📨 Supabase: Auth response received');
      print('👤 Supabase: User ID: ${response.user?.id}');

      if (response.user == null) {
        print('❌ Supabase: No user in response');
        throw AuthException(message: 'Sign up failed - no user returned');
      }

      print('⏳ Supabase: Waiting for profile creation trigger...');
      // Wait a bit for the trigger to create the profile
      await Future.delayed(const Duration(seconds: 2));

      print('📋 Supabase: Getting user profile...');
      final userProfile = await getUserProfile(response.user!.id);
      print('✅ Supabase: Signup complete for: ${userProfile.username}');

      return userProfile;
    } on sb.AuthException catch (e) {
      print('🔐 Supabase: Auth exception: ${e.message}');
      throw AuthException(message: e.message);
    } catch (e, stackTrace) {
      print('💥 Supabase: Unexpected error: $e');
      print('📚 Supabase: Stack trace: $stackTrace');
      throw ServerException(message: 'Unexpected error during sign up: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      print('🔐 Supabase: Signing out...');
      await _supabase.auth.signOut();
      print('✅ Supabase: Sign out successful');
    } catch (e) {
      print('❌ Supabase: Sign out error: $e');
      throw ServerException(message: 'Failed to sign out');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        print('ℹ️ Supabase: No current user');
        return null;
      }

      // Get full profile data
      return await getUserProfile(user.id);
    } catch (e) {
      print('⚠️ Supabase: Error getting current user: $e');
      // Return null if user is not authenticated or profile doesn't exist
      return null;
    }
  }

  @override
  Stream<sb.AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  @override
  Future<UserModel> getUserProfile(String userId) async {
    print('👤 Supabase: Getting user profile for ID: $userId');

    try {
      print('📋 Supabase: Querying profiles table...');
      final profileData = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      print('✅ Supabase: Profile data received');

      // Get email from auth
      final authUser = _supabase.auth.currentUser;
      final email = authUser?.id == userId ? authUser!.email! : '';

      // Add email to profile data
      profileData['email'] = email;

      print('📊 Supabase: Getting additional user data...');
      // Get additional data in parallel
      final futures = await Future.wait([
        getUserWishlistIds(userId),
        getUserRecommendedIds(userId),
        getUserRatings(userId),
        getUserFollowers(userId),
        getUserFollowing(userId),
        getTopThreeGames(userId),
      ]);

      final wishlist = futures[0] as List<int>;
      final recommended = futures[1] as List<int>;
      final ratings = futures[2] as Map<int, double>;
      final followers = futures[3] as List<String>;
      final following = futures[4] as List<String>;
      final topGames = futures[5] as List<int>;

      print('📈 Supabase: User stats - Wishlist: ${wishlist.length}, Recommended: ${recommended.length}, Ratings: ${ratings.length}');

      final userModel = UserModel.fromSupabase(
        profileData,
        wishlistIds: wishlist,
        recommendedIds: recommended,
        ratings: ratings,
        followerIds: followers,
        followingIds: following,
        topThreeGames: topGames,
      );

      print('✅ Supabase: UserModel created for: ${userModel.username}');
      return userModel;
    } catch (e, stackTrace) {
      print('💥 Supabase: Error getting user profile: $e');
      print('📚 Supabase: Stack trace: $stackTrace');
      throw ServerException(message: 'Failed to get user profile: $e');
    }
  }

  @override
  Future<UserModel> updateUserProfile(String userId, Map<String, dynamic> updates) async {
    try {
      print('📝 Supabase: Updating profile for user: $userId');
      print('📊 Supabase: Updates: $updates');

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

      print('✅ Supabase: Profile updated successfully');
      return await getUserProfile(userId);
    } catch (e) {
      print('❌ Supabase: Failed to update profile: $e');
      throw ServerException(message: 'Failed to update profile: $e');
    }
  }

  @override
  Future<List<UserModel>> searchUsers(String query) async {
    try {
      print('🔍 Supabase: Searching users with query: "$query"');

      final results = await _supabase
          .from('profiles')
          .select()
          .ilike('username', '%$query%')
          .limit(20);

      print('✅ Supabase: Found ${results.length} users');
      return results.map<UserModel>((data) =>
          UserModel.fromSupabase(data)
      ).toList();
    } catch (e) {
      print('❌ Supabase: Failed to search users: $e');
      throw ServerException(message: 'Failed to search users: $e');
    }
  }

  @override
  Future<void> followUser(String currentUserId, String targetUserId) async {
    try {
      print('👥 Supabase: User $currentUserId following $targetUserId');

      // Validate user IDs
      if (currentUserId == targetUserId) {
        throw ServerException(message: 'Cannot follow yourself');
      }

      // Check if target user exists
      final targetExists = await _supabase
          .from('profiles')
          .select('id')
          .eq('id', targetUserId)
          .maybeSingle();

      if (targetExists == null) {
        throw ServerException(message: 'Target user does not exist');
      }

      // Check if already following
      final existing = await _supabase
          .from(SupabaseTables.userFollows)
          .select()
          .eq('follower_id', currentUserId)
          .eq('following_id', targetUserId)
          .maybeSingle();

      if (existing != null) {
        throw ServerException(message: 'Already following this user');
      }

      // Create follow relationship
      await _supabase
          .from(SupabaseTables.userFollows)
          .insert({
        'follower_id': currentUserId,
        'following_id': targetUserId,
      });

      print('✅ Supabase: Follow relationship created');
    } catch (e) {
      print('❌ Supabase: Failed to follow user: $e');
      throw ServerException(message: 'Failed to follow user: $e');
    }
  }

  @override
  Future<void> unfollowUser(String currentUserId, String targetUserId) async {
    try {
      print('👥 Supabase: User $currentUserId unfollowing $targetUserId');

      final result = await _supabase
          .from(SupabaseTables.userFollows)
          .delete()
          .eq('follower_id', currentUserId)
          .eq('following_id', targetUserId);

      print('✅ Supabase: Unfollow successful');
    } catch (e) {
      print('❌ Supabase: Failed to unfollow user: $e');
      throw ServerException(message: 'Failed to unfollow user: $e');
    }
  }

  @override
  Future<List<String>> getUserFollowers(String userId) async {
    try {
      final results = await _supabase
          .from(SupabaseTables.userFollows)
          .select('follower_id')
          .eq('following_id', userId);

      return results.map<String>((item) => item['follower_id'] as String).toList();
    } catch (e) {
      print('⚠️ Supabase: Error getting followers: $e');
      return [];
    }
  }

  @override
  Future<List<String>> getUserFollowing(String userId) async {
    try {
      final results = await _supabase
          .from(SupabaseTables.userFollows)
          .select('following_id')
          .eq('follower_id', userId);

      return results.map<String>((item) => item['following_id'] as String).toList();
    } catch (e) {
      print('⚠️ Supabase: Error getting following: $e');
      return [];
    }
  }

  @override
  Future<Map<String, dynamic>?> getUserGameData(String userId, int gameId) async {
    try {
      print('🎮 Supabase: Getting user game data for user $userId, game $gameId');

      final result = await _supabase
          .from('user_game_interactions')
          .select('*')
          .eq('user_id', userId)
          .eq('game_id', gameId)
          .maybeSingle();

      if (result != null) {
        print('✅ Supabase: Found user game data');
        return result;
      } else {
        print('ℹ️ Supabase: No user game data found');
        return null;
      }
    } catch (e) {
      print('⚠️ Supabase: Error getting user game data: $e');
      return null;
    }
  }

  // Diese Methode sollte weiterhin existieren für Kompatibilität
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
      print('⚠️ Supabase: Error getting top games: $e');
      return [];
    }
  }

  @override
  Future<List<int>> getUserRatedIds(String userId) async {
    try {
      final results = await _supabase
          .from('user_game_interactions')
          .select('game_id, rating')
          .eq('user_id', userId)
          .not('rating', 'is', null)
          .order('rated_at', ascending: false);

      final ratedMap = Map.fromEntries(
        results.map((item) => MapEntry(
          item['game_id'] as int,
          double.parse(item['rating'].toString()),
        )),
      );
      return ratedMap.keys.toList();
    } catch (e) {
      print('⚠️ Supabase: Error getting wishlist: $e');
      return [];
    }
  }

}