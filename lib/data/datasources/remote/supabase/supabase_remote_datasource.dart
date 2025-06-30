// lib/data/datasources/remote/supabase_remote_datasource.dart - ENHANCED VERSION
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../domain/entities/game/game.dart';
import '../../../../domain/entities/user/user_gaming_activity.dart';
import '../../../../domain/entities/user/user_relationship.dart';
import '../../../models/user_model.dart';

abstract class SupabaseRemoteDataSource {
  // ==========================================
  // CORE USER PROFILE METHODS
  // ==========================================

  Future<UserModel> getUserProfile(String userId, [String? currentUserId]);
  Future<UserModel> getCurrentUserProfile();
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
  });
  Future<String> updateUserAvatar({
    required String userId,
    required String imageData,
  });

  // ==========================================
  // SOCIAL FEATURES - FOLLOW SYSTEM
  // ==========================================

  Future<void> followUser({
    required String currentUserId,
    required String targetUserId,
  });
  Future<void> unfollowUser({
    required String currentUserId,
    required String targetUserId,
  });
  Future<bool> isFollowing({
    required String currentUserId,
    required String targetUserId,
  });
  Future<UserRelationship> getUserRelationship({
    required String currentUserId,
    required String targetUserId,
  });
  Future<List<UserModel>> getUserFollowers({
    required String userId,
    int limit = 50,
    int offset = 0,
  });
  Future<List<UserModel>> getUserFollowing({
    required String userId,
    int limit = 50,
    int offset = 0,
  });
  Future<List<UserModel>> getMutualFollowers({
    required String currentUserId,
    required String targetUserId,
    int limit = 20,
  });
  Future<List<UserModel>> getFollowSuggestions({
    required String userId,
    int limit = 20,
  });

  // ==========================================
  // USER SEARCH & DISCOVERY
  // ==========================================

  Future<List<UserModel>> searchUsers({
    required String query,
    String? currentUserId,
    int limit = 20,
    int offset = 0,
  });
  Future<List<UserModel>> getPopularUsers({
    int limit = 20,
    int offset = 0,
  });
  Future<List<UserModel>> getNewUsers({
    int limit = 20,
    int offset = 0,
  });
  Future<List<UserModel>> getSimilarUsers({
    required String userId,
    int limit = 20,
  });

  // ==========================================
  // TOP THREE GAMES MANAGEMENT
  // ==========================================

  Future<void> updateTopThreeGames({
    required String userId,
    required List<int> gameIds,
  });
  Future<List<Game>> getUserTopThreeGames({
    required String userId,
  });
  Future<void> setTopThreeGameAtPosition({
    required String userId,
    required int position,
    required int gameId,
  });
  Future<void> removeFromTopThree({
    required String userId,
    required int position,
  });
  Future<void> reorderTopThree({
    required String userId,
    required Map<int, int> positionToGameId,
  });

  // ==========================================
  // USER GAME COLLECTIONS (PUBLIC VISIBILITY)
  // ==========================================

  Future<List<Game>> getUserPublicRatedGames({
    required String userId,
    String? currentUserId,
    int limit = 20,
    int offset = 0,
  });
  Future<List<Game>> getUserPublicRecommendedGames({
    required String userId,
    String? currentUserId,
    int limit = 20,
    int offset = 0,
  });
  Future<Map<String, dynamic>> getUserPublicCollections({
    required String userId,
    String? currentUserId,
  });

  // ==========================================
  // USER ACTIVITY & ANALYTICS
  // ==========================================

  Future<UserGamingActivity> getUserActivity({
    required String userId,
    Duration? timeWindow,
  });
  Future<Map<String, dynamic>> getUserGamingStats({
    required String userId,
    String? currentUserId,
  });
  Future<List<Map<String, dynamic>>> getUserRecentActivity({
    required String userId,
    int limit = 20,
    int offset = 0,
  });

  // ==========================================
  // SOCIAL FEED & ACTIVITY
  // ==========================================

  Future<List<Map<String, dynamic>>> getUserFeed({
    required String userId,
    int limit = 50,
    int offset = 0,
  });
  Future<List<Map<String, dynamic>>> getGlobalFeed({
    int limit = 50,
    int offset = 0,
  });
  Future<List<UserModel>> getTrendingUsers({
    Duration? timeWindow,
    int limit = 20,
  });

  // ==========================================
  // USER PRIVACY & SETTINGS
  // ==========================================

  Future<void> updatePrivacySettings({
    required String userId,
    bool? isProfilePublic,
    bool? showRatedGames,
    bool? showRecommendedGames,
    bool? showTopThree,
    bool? allowFollowRequests,
  });
  Future<void> blockUser({
    required String currentUserId,
    required String targetUserId,
  });
  Future<void> unblockUser({
    required String currentUserId,
    required String targetUserId,
  });
  Future<List<UserModel>> getBlockedUsers({
    required String userId,
  });
  Future<bool> isUserBlocked({
    required String currentUserId,
    required String targetUserId,
  });

  // ==========================================
  // BATCH OPERATIONS
  // ==========================================

  Future<void> followMultipleUsers({
    required String currentUserId,
    required List<String> targetUserIds,
  });
  Future<List<UserModel>> getMultipleUserProfiles({
    required List<String> userIds,
    String? currentUserId,
  });
  Future<Map<String, bool>> getMultipleFollowStatus({
    required String currentUserId,
    required List<String> targetUserIds,
  });

  // ==========================================
  // USER VERIFICATION & MODERATION
  // ==========================================

  Future<void> reportUser({
    required String reporterId,
    required String reportedUserId,
    required String reason,
    String? description,
  });
  Future<bool> isUsernameAvailable(String username);
  Future<List<String>> suggestUsernames(String baseUsername);

  // ==========================================
  // USER DELETION & ACCOUNT MANAGEMENT
  // ==========================================

  Future<void> deleteUserAccount(String userId);
  Future<void> deactivateUserAccount(String userId);
  Future<void> reactivateUserAccount(String userId);

  // ==========================================
  // AUTH RELATED (existing methods)
  // ==========================================

  Future<UserModel> signIn(String email, String password);
  Future<UserModel> signUp(String email, String password, String username);
  Future<void> signOut();
  Future<UserModel?> getCurrentUser();
}

