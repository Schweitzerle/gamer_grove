// lib/data/datasources/remote/supabase/supabase_user_datasource.dart

/// Data source interface for user operations.
///
/// Defines the contract for all user-related operations with Supabase backend.
library;

/// Abstract interface for user data operations.
///
/// Implementations should handle all low-level user operations
/// with the backend service (Supabase).
abstract class SupabaseUserDataSource {
  // ============================================================
  // PROFILE OPERATIONS
  // ============================================================

  /// Gets a user profile by ID.
  ///
  /// Returns user profile data including stats and privacy settings.
  /// Throws [UserNotFoundException] if user doesn't exist.
  ///
  /// Example:
  /// ```dart
  /// final profile = await userDataSource.getUserProfile(userId);
  /// print('Username: ${profile['username']}');
  /// ```
  Future<Map<String, dynamic>> getUserProfile(String userId);

  /// Gets a user profile by username.
  ///
  /// Returns user profile data or null if not found.
  ///
  /// Example:
  /// ```dart
  /// final profile = await userDataSource.getUserProfileByUsername('john_doe');
  /// if (profile != null) print('Found user: ${profile['display_name']}');
  /// ```
  Future<Map<String, dynamic>?> getUserProfileByUsername(String username);

  /// Updates user profile data.
  ///
  /// Only updates the fields present in [updates] map.
  /// Returns updated profile data.
  /// Throws [UserException] on failure.
  ///
  /// Example:
  /// ```dart
  /// await userDataSource.updateUserProfile(userId, {
  ///   'display_name': 'John Doe',
  ///   'bio': 'Passionate gamer',
  ///   'country': 'US',
  /// });
  /// ```
  Future<Map<String, dynamic>> updateUserProfile(
    String userId,
    Map<String, dynamic> updates,
  );

  /// Uploads and sets user avatar.
  ///
  /// [imageData] should be base64 encoded image string.
  /// Returns the public URL of the uploaded avatar.
  /// Throws [AvatarUploadException] on failure.
  ///
  /// Example:
  /// ```dart
  /// final avatarUrl = await userDataSource.updateUserAvatar(
  ///   userId,
  ///   base64ImageData,
  /// );
  /// print('Avatar uploaded: $avatarUrl');
  /// ```
  Future<String> updateUserAvatar(String userId, String imageData);

  /// Deletes user avatar.
  ///
  /// Removes the avatar file and clears avatar_url in profile.
  ///
  /// Example:
  /// ```dart
  /// await userDataSource.deleteUserAvatar(userId);
  /// ```
  Future<void> deleteUserAvatar(String userId);

  /// Updates user privacy settings.
  ///
  /// Example:
  /// ```dart
  /// await userDataSource.updatePrivacySettings(userId, {
  ///   'is_profile_public': true,
  ///   'show_wishlist': true,
  ///   'show_rated_games': false,
  /// });
  /// ```
  Future<void> updatePrivacySettings(
    String userId,
    Map<String, bool> settings,
  );

  // ============================================================
  // GAME COLLECTION OPERATIONS
  // ============================================================

  /// Gets enrichment data for multiple games at once.
  ///
  /// This is the CRITICAL performance function that replaces N+1 queries.
  /// Returns a map where keys are game IDs and values are enrichment data.
  ///
  /// Example:
  /// ```dart
  /// final data = await userDataSource.getUserGameData(userId, [1942, 1905]);
  /// print('Game 1942 is wishlisted: ${data[1942]['is_wishlisted']}');
  /// ```
  Future<Map<int, Map<String, dynamic>>> getUserGameData(
    String userId,
    List<int> gameIds,
  );

  /// Toggles a game in user's wishlist.
  ///
  /// Adds if not present, removes if already wishlisted.
  ///
  /// Example:
  /// ```dart
  /// await userDataSource.toggleWishlist(userId, 1942);
  /// ```
  Future<void> toggleWishlist(String userId, int gameId);

  /// Toggles a game in user's recommended list.
  ///
  /// Adds if not present, removes if already recommended.
  ///
  /// Example:
  /// ```dart
  /// await userDataSource.toggleRecommended(userId, 1942);
  /// ```
  Future<void> toggleRecommended(String userId, int gameId);

  /// Rates a game.
  ///
  /// [rating] must be between 0.0 and 10.0.
  /// Updates existing rating if game was already rated.
  /// Throws [InvalidRatingException] if rating is out of range.
  ///
  /// Example:
  /// ```dart
  /// await userDataSource.rateGame(userId, 1942, 9.5);
  /// ```
  Future<void> rateGame(String userId, int gameId, double rating);

  /// Removes a rating from a game.
  ///
  /// Example:
  /// ```dart
  /// await userDataSource.removeRating(userId, 1942);
  /// ```
  Future<void> removeRating(String userId, int gameId);

  /// Updates user's top 3 games.
  ///
  /// [gameIds] must contain exactly 3 different game IDs.
  /// Throws [InvalidTopThreeException] if validation fails.
  ///
  /// Example:
  /// ```dart
  /// await userDataSource.updateTopThree(userId, [1942, 1905, 113]);
  /// ```
  Future<void> updateTopThree(String userId, List<int> gameIds);

  /// Gets user's top 3 games.
  ///
  /// Returns null if user hasn't set top 3 yet.
  ///
  /// Example:
  /// ```dart
  /// final topThree = await userDataSource.getTopThree(userId);
  /// if (topThree != null) print('Top game: ${topThree[0]}');
  /// ```
  Future<List<int>?> getTopThree(String userId);

  /// Clears user's top 3 games.
  ///
  /// Example:
  /// ```dart
  /// await userDataSource.clearTopThree(userId);
  /// ```
  Future<void> clearTopThree(String userId);

  /// Gets all wishlisted games for a user.
  ///
  /// Returns list of game IDs with metadata.
  ///
  /// Example:
  /// ```dart
  /// final wishlist = await userDataSource.getWishlistedGames(userId);
  /// print('${wishlist.length} games in wishlist');
  /// ```
  Future<List<Map<String, dynamic>>> getWishlistedGames(
    String userId, {
    int? limit,
    int? offset,
  });

  /// Gets all rated games for a user.
  ///
  /// Returns list of game IDs with ratings and dates.
  ///
  /// Example:
  /// ```dart
  /// final rated = await userDataSource.getRatedGames(userId);
  /// ```
  Future<List<Map<String, dynamic>>> getRatedGames(
    String userId, {
    int? limit,
    int? offset,
  });

  /// Gets all recommended games for a user.
  ///
  /// Returns list of game IDs with metadata.
  ///
  /// Example:
  /// ```dart
  /// final recommended = await userDataSource.getRecommendedGames(userId);
  /// ```
  Future<List<Map<String, dynamic>>> getRecommendedGames(
    String userId, {
    int? limit,
    int? offset,
  });

  // ============================================================
  // SOCIAL FEATURES
  // ============================================================

  /// Follows a user.
  ///
  /// Throws [CannotFollowSelfException] if trying to follow self.
  /// Throws [AlreadyFollowingException] if already following.
  ///
  /// Example:
  /// ```dart
  /// await userDataSource.followUser(currentUserId, targetUserId);
  /// ```
  Future<void> followUser(String followerId, String followingId);

  /// Unfollows a user.
  ///
  /// Throws [NotFollowingException] if not currently following.
  ///
  /// Example:
  /// ```dart
  /// await userDataSource.unfollowUser(currentUserId, targetUserId);
  /// ```
  Future<void> unfollowUser(String followerId, String followingId);

  /// Checks if user A is following user B.
  ///
  /// Example:
  /// ```dart
  /// final isFollowing = await userDataSource.isFollowing(userId, targetId);
  /// ```
  Future<bool> isFollowing(String followerId, String followingId);

  /// Gets users who follow the specified user.
  ///
  /// Returns list of follower profiles.
  ///
  /// Example:
  /// ```dart
  /// final followers = await userDataSource.getFollowers(userId, limit: 20);
  /// ```
  Future<List<Map<String, dynamic>>> getFollowers(
    String userId, {
    int? limit,
    int? offset,
  });

  /// Gets users that the specified user follows.
  ///
  /// Returns list of followed user profiles.
  ///
  /// Example:
  /// ```dart
  /// final following = await userDataSource.getFollowing(userId, limit: 20);
  /// ```
  Future<List<Map<String, dynamic>>> getFollowing(
    String userId, {
    int? limit,
    int? offset,
  });

  /// Batch checks follow status for multiple users.
  ///
  /// Returns map where keys are user IDs and values are follow status.
  ///
  /// Example:
  /// ```dart
  /// final statuses = await userDataSource.batchGetFollowStatus(
  ///   currentUserId,
  ///   [userId1, userId2, userId3],
  /// );
  /// ```
  Future<Map<String, bool>> batchGetFollowStatus(
    String currentUserId,
    List<String> targetUserIds,
  );

  /// Gets mutual followers between two users.
  ///
  /// Returns users who follow both user1 and user2.
  ///
  /// Example:
  /// ```dart
  /// final mutuals = await userDataSource.getMutualFollowers(user1, user2);
  /// ```
  Future<List<Map<String, dynamic>>> getMutualFollowers(
    String userId1,
    String userId2,
  );

  // ============================================================
  // DISCOVERY & SEARCH
  // ============================================================

  /// Searches users by username or display name.
  ///
  /// Example:
  /// ```dart
  /// final users = await userDataSource.searchUsers('john', limit: 20);
  /// ```
  Future<List<Map<String, dynamic>>> searchUsers(
    String query, {
    int? limit,
    int? offset,
  });

  /// Gets popular users (most followers).
  ///
  /// Example:
  /// ```dart
  /// final popular = await userDataSource.getPopularUsers(limit: 10);
  /// ```
  Future<List<Map<String, dynamic>>> getPopularUsers({
    int? limit,
    int? offset,
  });

  /// Gets users similar to the specified user.
  ///
  /// Based on game collections and ratings.
  ///
  /// Example:
  /// ```dart
  /// final similar = await userDataSource.getSimilarUsers(userId, limit: 10);
  /// ```
  Future<List<Map<String, dynamic>>> getSimilarUsers(
    String userId, {
    int? limit,
  });

  // ============================================================
  // ACTIVITY & FEED
  // ============================================================

  /// Gets user's activity timeline.
  ///
  /// Returns recent activities (ratings, wishlist adds, etc.).
  ///
  /// Example:
  /// ```dart
  /// final activity = await userDataSource.getUserActivity(userId, limit: 20);
  /// ```
  Future<List<Map<String, dynamic>>> getUserActivity(
    String userId, {
    int? limit,
    int? offset,
  });

  /// Gets activity feed from users that current user follows.
  ///
  /// Example:
  /// ```dart
  /// final feed = await userDataSource.getFollowingActivity(userId, limit: 20);
  /// ```
  Future<List<Map<String, dynamic>>> getFollowingActivity(
    String userId, {
    int? limit,
  });

  /// Gets public activity feed (all users).
  ///
  /// Example:
  /// ```dart
  /// final public = await userDataSource.getPublicActivity(limit: 20);
  /// ```
  Future<List<Map<String, dynamic>>> getPublicActivity({
    int? limit,
    int? offset,
  });

  // ============================================================
  // STATISTICS
  // ============================================================

  /// Gets user statistics.
  ///
  /// Returns total games, ratings, followers, etc.
  ///
  /// Example:
  /// ```dart
  /// final stats = await userDataSource.getUserStats(userId);
  /// print('Total ratings: ${stats['total_games_rated']}');
  /// ```
  Future<Map<String, dynamic>> getUserStats(String userId);

  /// Gets detailed collection statistics.
  ///
  /// Calls PostgreSQL function for comprehensive stats.
  ///
  /// Example:
  /// ```dart
  /// final stats = await userDataSource.getCollectionStats(userId);
  /// ```
  Future<Map<String, dynamic>> getCollectionStats(String userId);

  /// Gets user relationship info.
  ///
  /// Returns relationship status between current user and target user.
  ///
  /// Example:
  /// ```dart
  /// final relationship = await userDataSource.getUserRelationship(
  ///   currentUserId,
  ///   targetUserId,
  /// );
  /// print('Following: ${relationship['is_following']}');
  /// ```
  Future<Map<String, dynamic>> getUserRelationship(
    String currentUserId,
    String targetUserId,
  );
}
