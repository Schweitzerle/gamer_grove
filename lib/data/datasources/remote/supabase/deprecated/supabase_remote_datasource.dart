/* // lib/data/datasources/remote/supabase/supabase_remote_datasource.dart
// UPDATED COMPLETE VERSION - Combines best of both implementations
import '../../../../domain/entities/user/user_collection_sort_options.dart';
import '../../../../domain/entities/user/user_gaming_activity.dart';
import '../../../../domain/entities/user/user_relationship.dart';
import '../../../../domain/entities/user/user_collection_filters.dart';
import '../../../models/user_model.dart';

abstract class SupabaseRemoteDataSource {
  // ==========================================
  // AUTH METHODS (CORE - OPTIMIZED)
  // ==========================================

  /// Get user's ratings as Map<gameId, rating>
  Future<Map<int, double>> getUserRatings(String userId);

  /// Sign in with email and password
  Future<UserModel> signIn(String email, String password);

  /// Sign up new user with email, password, and username
  Future<UserModel> signUp(String email, String password, String username);

  /// Sign out current user
  Future<void> signOut();

  /// Get current authenticated user
  Future<UserModel?> getCurrentUser();

  // ==========================================
  // CORE USER PROFILE METHODS (OPTIMIZED)
  // ==========================================

  /// Get user profile with optional social context
  Future<UserModel> getUserProfile(String userId, [String? currentUserId]);

  /// Get current user's own profile
  Future<UserModel> getCurrentUserProfile();

  /// Update user profile information
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

  /// Update user avatar via storage upload
  Future<String> updateUserAvatar({
    required String userId,
    required String imageData, // Base64 or file path
  });

  // ==========================================
  // GAME COLLECTIONS - CORE METHODS (NEW SCHEMA)
  // ==========================================

  /// Get user's wishlist game IDs
  Future<List<int>> getUserWishlistIds(String userId);

  /// Get user's recommended game IDs
  Future<List<int>> getUserRecommendedIds(String userId);

  /// Get user's rated game IDs
  Future<List<int>> getUserRatedIds(String userId);

  /// Get user's game data for specific game
  Future<Map<String, dynamic>?> getUserGameData(String userId, int gameId);

  /// Get batch user game data for multiple games
  Future<Map<int, Map<String, dynamic>>> getBatchUserGameData(List<int> gameIds, String userId);

  // ==========================================
  // GAME ACTIONS (NEW SCHEMA OPTIMIZED)
  // ==========================================

  /// Toggle game in user's wishlist
  Future<void> toggleWishlist(int gameId, String userId);

  /// Toggle game recommendation status
  Future<void> toggleRecommended(int gameId, String userId);

  /// Rate a game (0-10 scale)
  Future<void> rateGame(int gameId, String userId, double rating);

  // ==========================================
  // ENHANCED COLLECTIONS WITH FILTERS (KEEP FROM OLD)
  // ==========================================

  /// Get user's wishlist with filters and pagination
  Future<List<Map<String, dynamic>>> getUserWishlistWithFilters({
    required String userId,
    required UserCollectionFilters filters,
    int limit = 20,
    int offset = 0,
  });

  /// Get user's rated games with filters and pagination
  Future<List<Map<String, dynamic>>> getUserRatedGamesWithFilters({
    required String userId,
    required UserCollectionFilters filters,
    int limit = 20,
    int offset = 0,
  });

  /// Get user's recommended games with filters and pagination
  Future<List<Map<String, dynamic>>> getUserRecommendedGamesWithFilters({
    required String userId,
    required UserCollectionFilters filters,
    int limit = 20,
    int offset = 0,
  });

  /// Get user's collection statistics and summaries
  Future<Map<String, dynamic>> getUserCollectionStatistics({
    required String userId,
    String? currentUserId,
  });

  // ==========================================
  // TOP THREE GAMES MANAGEMENT (NEW)
  // ==========================================

  /// Update user's top three games (must be exactly 3 games)
  Future<void> updateTopThreeGames({
    required String userId,
    required List<int> gameIds, // Must be exactly 3 games
  });

  /// Get user's top three games with position data
  Future<List<Map<String, dynamic>>> getUserTopThreeGames({
    required String userId,
  });

  /// Set game at specific position in top three (1, 2, or 3)
  Future<void> setTopThreeGameAtPosition({
    required String userId,
    required int position,
    required int gameId,
  });

  /// Remove game from specific position in top three
  Future<void> removeFromTopThree({
    required String userId,
    required int position,
  });

  /// Reorder top three games
  Future<void> reorderTopThree({
    required String userId,
    required Map<int, int> positionToGameId, // position -> gameId
  });

  // ==========================================
  // SOCIAL FEATURES - FOLLOW SYSTEM (KEEP FROM OLD)
  // ==========================================

  /// Follow a user
  Future<void> followUser({
    required String currentUserId,
    required String targetUserId,
  });

  /// Unfollow a user
  Future<void> unfollowUser({
    required String currentUserId,
    required String targetUserId,
  });

  /// Check if user A follows user B
  Future<bool> isFollowing({
    required String currentUserId,
    required String targetUserId,
  });

  /// Get relationship status between two users
  Future<UserRelationship> getUserRelationship({
    required String currentUserId,
    required String targetUserId,
  });

  /// Get user's followers list
  Future<List<UserModel>> getUserFollowers({
    required String userId,
    int limit = 50,
    int offset = 0,
  });

  /// Get user's following list
  Future<List<UserModel>> getUserFollowing({
    required String userId,
    int limit = 50,
    int offset = 0,
  });

  /// Get mutual followers between two users
  Future<List<UserModel>> getMutualFollowers({
    required String currentUserId,
    required String targetUserId,
    int limit = 20,
  });

  /// Get follow suggestions for user
  Future<List<UserModel>> getFollowSuggestions({
    required String userId,
    int limit = 20,
  });

  // ==========================================
  // USER SEARCH & DISCOVERY (KEEP FROM OLD)
  // ==========================================

  /// Search users by username or display name
  Future<List<UserModel>> searchUsers({
    required String query,
    String? currentUserId,
    int limit = 20,
    int offset = 0,
  });

  /// Get popular/featured users
  Future<List<UserModel>> getPopularUsers({
    int limit = 20,
    int offset = 0,
  });

  /// Get recently joined users
  Future<List<UserModel>> getNewUsers({
    int limit = 20,
    int offset = 0,
  });

  /// Get users with similar gaming preferences
  Future<List<UserModel>> getSimilarUsers({
    required String userId,
    int limit = 20,
  });

  // ==========================================
  // PUBLIC VISIBILITY COLLECTIONS (KEEP FROM OLD)
  // ==========================================

  /// Get user's public rated games with metadata
  Future<List<Map<String, dynamic>>> getUserPublicRatedGames({
    required String userId,
    String? currentUserId,
    int limit = 20,
    int offset = 0,
  });

  /// Get user's public recommended games with metadata
  Future<List<Map<String, dynamic>>> getUserPublicRecommendedGames({
    required String userId,
    String? currentUserId,
    int limit = 20,
    int offset = 0,
  });

  /// Get user's public collections overview
  Future<Map<String, dynamic>> getUserPublicCollections({
    required String userId,
    String? currentUserId,
  });

  // ==========================================
  // USER ACTIVITY & ANALYTICS (KEEP FROM OLD)
  // ==========================================

  /// Get user's gaming activity summary
  Future<UserGamingActivity> getUserActivity({
    required String userId,
    Duration? timeWindow,
  });

  /// Get user's gaming statistics
  Future<Map<String, dynamic>> getUserGamingStats({
    required String userId,
    String? currentUserId, // For privacy checking
  });

  /// Get user's recent activity (for feed)
  Future<List<Map<String, dynamic>>> getUserRecentActivity({
    required String userId,
    int limit = 20,
    int offset = 0,
  });

  // ==========================================
  // BATCH OPERATIONS (KEEP FROM OLD)
  // ==========================================

  /// Get multiple user profiles efficiently
  Future<List<UserModel>> getMultipleUserProfiles({
    required List<String> userIds,
    String? currentUserId,
  });

  /// Get follow status for multiple users at once
  Future<Map<String, bool>> getMultipleFollowStatus({
    required String currentUserId,
    required List<String> targetUserIds,
  });

  /// Follow multiple users at once
  Future<void> followMultipleUsers({
    required String currentUserId,
    required List<String> targetUserIds,
  });

  // ==========================================
  // USER VERIFICATION & MODERATION (KEEP FROM OLD)
  // ==========================================

  /// Report a user for violations
  Future<void> reportUser({
    required String reporterId,
    required String reportedUserId,
    required String reason,
    String? description,
  });

  /// Check if username is available
  Future<bool> isUsernameAvailable(String username);

  /// Suggest available usernames based on input
  Future<List<String>> suggestUsernames(String baseUsername);

  /// Block a user
  Future<void> blockUser({
    required String currentUserId,
    required String targetUserId,
  });

  /// Unblock a user
  Future<void> unblockUser({
    required String currentUserId,
    required String targetUserId,
  });

  /// Check if user is blocked
  Future<bool> isUserBlocked({
    required String currentUserId,
    required String targetUserId,
  });

  /// Get blocked users list
  Future<List<UserModel>> getBlockedUsers({
    required String userId,
  });

  // ==========================================
  // USER DELETION & ACCOUNT MANAGEMENT (KEEP FROM OLD)
  // ==========================================

  /// Delete user account permanently
  Future<void> deleteUserAccount(String userId);

  /// Deactivate user account (soft delete)
  Future<void> deactivateUserAccount(String userId);

  /// Reactivate user account
  Future<void> reactivateUserAccount(String userId);

  // ==========================================
  // SEARCH SUPPORT (KEEP FROM OLD)
  // ==========================================

  /// Get user's recent search queries
  Future<List<String>> getRecentSearchQueries(String userId, {int limit = 10});

  /// Save search query to history
  Future<void> saveSearchQuery(String userId, String query);

  // ==========================================
  // ANALYTICS & INSIGHTS (KEEP FROM OLD)
  // ==========================================

  /// Get personalized insights for user
  Future<Map<String, dynamic>> getPersonalizedInsights(String userId);

  /// Get genre evolution trends
  Future<List<Map<String, dynamic>>> getGenreEvolutionTrends();

  /// Get platform adoption trends
  Future<List<Map<String, dynamic>>> getPlatformAdoptionTrends();

  // ==========================================
  // SOCIAL FEED & ACTIVITY (KEEP FROM OLD)
  // ==========================================

  /// Get activity feed for user (from people they follow)
  Future<List<Map<String, dynamic>>> getUserFeed({
    required String userId,
    int limit = 50,
    int offset = 0,
  });

  /// Get global activity feed
  Future<List<Map<String, dynamic>>> getGlobalFeed({
    int limit = 50,
    int offset = 0,
  });

  /// Get trending users (most followed recently)
  Future<List<UserModel>> getTrendingUsers({
    Duration? timeWindow,
    int limit = 20,
  });

  // ==========================================
  // PRIVACY & SETTINGS (KEEP FROM OLD)
  // ==========================================

  /// Update user privacy settings
  Future<void> updatePrivacySettings({
    required String userId,
    bool? isProfilePublic,
    bool? showRatedGames,
    bool? showRecommendedGames,
    bool? showTopThree,
    bool? allowFollowRequests,
  });

  /// Update user notification settings
  Future<void> updateNotificationSettings({
    required String userId,
    bool? emailNotifications,
    bool? pushNotifications,
    bool? followNotifications,
    bool? ratingNotifications,
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

} */
