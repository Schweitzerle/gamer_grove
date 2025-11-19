// lib/domain/repositories/user_repository.dart - ENHANCED VERSION
import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/user/user.dart';
import '../entities/user/user_gaming_activity.dart';
import '../entities/user/user_relationship.dart';

abstract class UserRepository {
  // ==========================================
  // CORE USER PROFILE METHODS
  // ==========================================

  /// Get user profile with social context (following status, etc.)
  Future<Either<Failure, User>> getUserProfile({
    required String userId,
    String? currentUserId, // For social context
  });

  /// Get current user's own profile
  Future<Either<Failure, User>> getCurrentUserProfile();

  /// Update user profile information
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
  });

  /// Update user avatar
  Future<Either<Failure, String>> updateUserAvatar({
    required String userId,
    required String imageData, // Base64 or file path
  });

  // ==========================================
  // SOCIAL FEATURES - FOLLOW SYSTEM
  // ==========================================

  /// Follow a user
  Future<Either<Failure, void>> followUser({
    required String currentUserId,
    required String targetUserId,
  });

  /// Unfollow a user
  Future<Either<Failure, void>> unfollowUser({
    required String currentUserId,
    required String targetUserId,
  });

  /// Check if user A follows user B
  Future<Either<Failure, bool>> isFollowing({
    required String currentUserId,
    required String targetUserId,
  });

  /// Get relationship status between two users
  Future<Either<Failure, UserRelationship>> getUserRelationship({
    required String currentUserId,
    required String targetUserId,
  });

  /// Get user's followers
  Future<Either<Failure, List<User>>> getUserFollowers({
    required String userId,
    int limit = 50,
    int offset = 0,
  });

  /// Get user's following list
  Future<Either<Failure, List<User>>> getUserFollowing({
    required String userId,
    int limit = 50,
    int offset = 0,
  });

  /// Get mutual followers between two users
  Future<Either<Failure, List<User>>> getMutualFollowers({
    required String currentUserId,
    required String targetUserId,
    int limit = 20,
  });

  /// Get follow suggestions for user
  Future<Either<Failure, List<User>>> getFollowSuggestions({
    required String userId,
    int limit = 20,
  });

  // ==========================================
  // USER SEARCH & DISCOVERY
  // ==========================================

  /// Search users by username or display name
  Future<Either<Failure, List<User>>> searchUsers({
    required String query,
    String? currentUserId, // For social context
    int limit = 20,
    int offset = 0,
  });

  /// Get popular/featured users
  Future<Either<Failure, List<User>>> getPopularUsers({
    int limit = 20,
    int offset = 0,
  });

  /// Get recently joined users
  Future<Either<Failure, List<User>>> getNewUsers({
    int limit = 20,
    int offset = 0,
  });

  /// Get users with similar gaming preferences
  Future<Either<Failure, List<User>>> getSimilarUsers({
    required String userId,
    int limit = 20,
  });

  /// Get users for the leaderboard, sorted by rated games count
  Future<Either<Failure, List<User>>> getLeaderboardUsers({
    int limit = 100,
    int offset = 0,
  });

  // ==========================================
  // TOP THREE GAMES MANAGEMENT
  // ==========================================

  /// Update user's top three games
  Future<Either<Failure, void>> updateTopThreeGames({
    required String userId,
    required List<int> gameIds, // Must be exactly 3 games
  });

  /// Get user's top three games as Game entities
  Future<Either<Failure, List<Map<String, dynamic>>>> getUserTopThreeGames({
    required String userId,
  });

  /// Add game to specific position in top three
  Future<Either<Failure, void>> setTopThreeGameAtPosition({
    required String userId,
    required int position, // 1, 2, or 3
    required int gameId,
  });

  /// Remove game from top three
  Future<Either<Failure, void>> removeFromTopThree({
    required String userId,
    required int gameId,
  });

  /// Reorder top three games
  Future<Either<Failure, void>> reorderTopThree({
    required String userId,
    required Map<int, int> positionToGameId, // position -> gameId
  });

  // ==========================================
  // USER GAME COLLECTIONS (PUBLIC VISIBILITY)
  // ==========================================

  /// Get user's public rated games
  Future<Either<Failure, List<Map<String, dynamic>>>> getUserPublicRatedGames({
    required String userId,
    String? currentUserId,
    int limit = 20,
    int offset = 0,
  });

  /// Get user's public recommended games
  Future<Either<Failure, List<Map<String, dynamic>>>>
      getUserPublicRecommendedGames({
    required String userId,
    String? currentUserId,
    int limit = 20,
    int offset = 0,
  });

  /// Get user's public collections overview
  Future<Either<Failure, Map<String, dynamic>>> getUserPublicCollections({
    required String userId,
    String? currentUserId,
  });

  // ==========================================
  // USER ACTIVITY & ANALYTICS
  // ==========================================

  /// Get user's gaming activity summary
  Future<Either<Failure, UserGamingActivity>> getUserActivity({
    required String userId,
    Duration? timeWindow,
  });

  /// Get user's gaming statistics
  Future<Either<Failure, Map<String, dynamic>>> getUserGamingStats({
    required String userId,
    String? currentUserId, // For privacy checking
  });

  /// Get user's recent activity (for feed)
  Future<Either<Failure, List<Map<String, dynamic>>>> getUserRecentActivity({
    required String userId,
    int limit = 20,
    int offset = 0,
  });

  // ==========================================
  // SOCIAL FEED & ACTIVITY
  // ==========================================

  /// Get activity feed for user (from people they follow)
  Future<Either<Failure, List<Map<String, dynamic>>>> getUserFeed({
    required String userId,
    int limit = 50,
    int offset = 0,
  });

  /// Get global activity feed
  Future<Either<Failure, List<Map<String, dynamic>>>> getGlobalFeed({
    int limit = 50,
    int offset = 0,
  });

  /// Get trending users (most followed recently)
  Future<Either<Failure, List<User>>> getTrendingUsers({
    Duration? timeWindow,
    int limit = 20,
  });

  // ==========================================
  // USER PRIVACY & SETTINGS
  // ==========================================

  /// Update user privacy settings
  Future<Either<Failure, void>> updatePrivacySettings({
    required String userId,
    bool? isProfilePublic,
    bool? showRatedGames,
    bool? showRecommendedGames,
    bool? showTopThree,
    bool? allowFollowRequests,
  });

  /// Block/Unblock user
  Future<Either<Failure, void>> blockUser({
    required String currentUserId,
    required String targetUserId,
  });

  Future<Either<Failure, void>> unblockUser({
    required String currentUserId,
    required String targetUserId,
  });

  /// Get blocked users list
  Future<Either<Failure, List<User>>> getBlockedUsers({
    required String userId,
  });

  /// Check if user is blocked
  Future<Either<Failure, bool>> isUserBlocked({
    required String currentUserId,
    required String targetUserId,
  });

  // ==========================================
  // BATCH OPERATIONS
  // ==========================================

  /// Follow multiple users
  Future<Either<Failure, void>> followMultipleUsers({
    required String currentUserId,
    required List<String> targetUserIds,
  });

  /// Get multiple user profiles
  Future<Either<Failure, List<User>>> getMultipleUserProfiles({
    required List<String> userIds,
    String? currentUserId,
  });

  /// Check follow status for multiple users
  Future<Either<Failure, Map<String, bool>>> getMultipleFollowStatus({
    required String currentUserId,
    required List<String> targetUserIds,
  });

  // ==========================================
  // USER VERIFICATION & MODERATION
  // ==========================================

  /// Report user
  Future<Either<Failure, void>> reportUser({
    required String reporterId,
    required String reportedUserId,
    required String reason,
    String? description,
  });

  /// Check if username is available
  Future<Either<Failure, bool>> isUsernameAvailable(String username);

  /// Suggest alternative usernames
  Future<Either<Failure, List<String>>> suggestUsernames(String baseUsername);

  // ==========================================
  // USER DELETION & ACCOUNT MANAGEMENT
  // ==========================================

  /// Delete user account and all associated data
  Future<Either<Failure, void>> deleteUserAccount(String userId);

  /// Deactivate user account
  Future<Either<Failure, void>> deactivateUserAccount(String userId);

  /// Reactivate user account
  Future<Either<Failure, void>> reactivateUserAccount(String userId);

  // ==========================================
  // USER GAME COLLECTIONS (IDs ONLY)
  // ==========================================

  /// Get user's wishlisted game IDs
  Future<Either<Failure, List<int>>> getWishlistedGames(
    String userId, {
    int? limit,
    int? offset,
  });

  /// Get user's rated game IDs with ratings
  Future<Either<Failure, List<Map<String, dynamic>>>> getRatedGames(
    String userId, {
    int? limit,
    int? offset,
  });

  /// Get user's recommended game IDs
  Future<Either<Failure, List<int>>> getRecommendedGames(
    String userId, {
    int? limit,
    int? offset,
  });

  // ==========================================
  // FOLLOWED USERS GAME DATA
  // ==========================================

  /// Get ratings for a specific game from users that current user follows
  Future<Either<Failure, List<Map<String, dynamic>>>>
      getFollowedUsersGameRatings({
    required String currentUserId,
    required int gameId,
    int limit = 100,
  });
}
