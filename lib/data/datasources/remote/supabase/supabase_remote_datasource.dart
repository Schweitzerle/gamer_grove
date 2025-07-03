// lib/data/datasources/remote/supabase/supabase_remote_datasource.dart - EXTENDED VERSION
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../domain/entities/game/game.dart';
import '../../../../domain/entities/user/user_gaming_activity.dart';
import '../../../../domain/entities/user/user_relationship.dart';
import '../../../../domain/entities/user/user_collection_filters.dart';
import '../../../../domain/entities/user/user_collection_sort_options.dart';
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
  // GAME COLLECTIONS - BASIC METHODS
  // ==========================================

  Future<List<int>> getUserWishlistIds(String userId);
  Future<List<int>> getUserRecommendedIds(String userId);
  Future<List<int>> getUserRatedIds(String userId);
  Future<Map<String, dynamic>?> getUserGameData(String userId, int gameId);
  Future<Map<int, Map<String, dynamic>>> getBatchUserGameData(List<int> gameIds, String userId);

  // ==========================================
  // GAME ACTIONS
  // ==========================================

  Future<void> toggleWishlist(int gameId, String userId);
  Future<void> toggleRecommended(int gameId, String userId);
  Future<void> rateGame(int gameId, String userId, double rating);

  // ==========================================
  // ENHANCED COLLECTIONS WITH FILTERS
  // ==========================================

  Future<List<Map<String, dynamic>>> getUserWishlistWithFilters({
    required String userId,
    required UserCollectionFilters filters,
    int limit = 20,
    int offset = 0,
  });

  Future<List<Map<String, dynamic>>> getUserRatedGamesWithFilters({
    required String userId,
    required UserCollectionFilters filters,
    int limit = 20,
    int offset = 0,
  });

  Future<List<Map<String, dynamic>>> getUserRecommendedGamesWithFilters({
    required String userId,
    required UserCollectionFilters filters,
    int limit = 20,
    int offset = 0,
  });

  Future<Map<String, dynamic>> getUserCollectionStatistics({
    required String userId,
    required UserCollectionType collectionType,
  });

  Future<Map<String, dynamic>> getUserGamingStatistics(String userId);

  // ==========================================
  // BATCH OPERATIONS
  // ==========================================

  Future<void> batchAddToWishlist(String userId, List<int> gameIds);
  Future<void> batchRateGames(String userId, Map<int, double> gameRatings);
  Future<void> batchRemoveFromWishlist(String userId, List<int> gameIds);
  Future<void> moveGamesBetweenCollections({
    required String userId,
    required List<int> gameIds,
    required UserCollectionType fromCollection,
    required UserCollectionType toCollection,
  });

  // ==========================================
  // USER ACTIVITY & ANALYTICS
  // ==========================================

  Future<List<Map<String, dynamic>>> getRecentlyAddedToCollections({
    required String userId,
    required DateTime sinceDate,
    int limit = 50,
  });

  Future<List<Map<String, dynamic>>> getUserTopGenres(String userId, {int limit = 10});
  Future<List<Map<String, dynamic>>> getUserActivityTimeline({
    required String userId,
    required DateTime fromDate,
    required DateTime toDate,
    int limit = 50,
  });

  Future<Map<String, double>> getUserGenrePreferences(String userId);
  Future<Map<String, int>> getUserPlatformStatistics(String userId);
  Future<Map<String, dynamic>> getUserRatingAnalytics(String userId);
  Future<Map<String, dynamic>> getUserGamingPatternAnalysis(String userId);
  Future<Map<String, dynamic>> getUserGamingProfile(String userId);

  // ==========================================
  // RECOMMENDATION SUPPORT
  // ==========================================

  Future<List<Map<String, dynamic>>> getUserHighlyRatedGames(String userId, {double minRating = 8.0});
  Future<dynamic> getUserWishlistPatterns(String userId);
  Future<dynamic> getUserRatingPatterns(String userId);
  Future<dynamic> getFriendsActivity(String userId);
  Future<dynamic> getCommunityTrends();
  Future<Map<String, dynamic>> getUserGamingContext(String userId);
  Future<List<int>> getAllUserGameIds(String userId);

  // ==========================================
  // SOCIAL FEATURES
  // ==========================================

  Future<List<String>> getUserFriends(String userId);
  Future<List<Map<String, dynamic>>> getFriendsRecentActivity({
    required List<String> friendIds,
    int limit = 50,
    int offset = 0,
  });
  Future<List<Map<String, dynamic>>> getFriendsRecommendedGames({
    required List<String> friendIds,
    required String excludeUserId,
    int limit = 20,
  });
  Future<List<Map<String, dynamic>>> getCommunityFavoritesByGenres({
    required List<int> genreIds,
    int limit = 20,
  });
  Future<List<Map<String, dynamic>>> findSimilarUsers(String userId, {int limit = 10});

  // ==========================================
  // ANALYTICS & TRENDS
  // ==========================================

  Future<List<Map<String, dynamic>>> getGenreTrendAnalytics({
    required Duration timeWindow,
    int limit = 20,
  });
  Future<List<Map<String, dynamic>>> getPlatformTrendAnalytics({
    required Duration timeWindow,
    int limit = 20,
  });
  Future<Map<String, dynamic>> getIndustryTrendAnalytics({required Duration timeWindow});
  Future<Map<String, dynamic>> getPersonalizedInsights(String userId);
  Future<List<Map<String, dynamic>>> getGenreEvolutionTrends();
  Future<List<Map<String, dynamic>>> getPlatformAdoptionTrends();

  // ==========================================
  // SEARCH SUPPORT
  // ==========================================

  Future<List<String>> getRecentSearchQueries(String userId, {int limit = 10});
  Future<void> saveSearchQuery(String userId, String query);

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
  Future<List<Map<String, dynamic>>> getUserTopThreeGames({
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

  Future<List<Map<String, dynamic>>> getUserPublicRatedGames({
    required String userId,
    String? currentUserId,
    int limit = 20,
    int offset = 0,
  });

// ÄNDERN: Von Future<List<Game>> zu Future<List<Map<String, dynamic>>>
  Future<List<Map<String, dynamic>>> getUserPublicRecommendedGames({
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
  // AUTH RELATED
  // ==========================================

  Future<UserModel> signIn(String email, String password);
  Future<UserModel> signUp(String email, String password, String username);
  Future<void> signOut();
  Future<UserModel?> getCurrentUser();
}