/// Predefined, commonly used Supabase queries.
///
/// This file contains preset query builders for frequent database operations,
/// reducing code duplication and ensuring consistency.
library;

import 'package:gamer_grove/data/datasources/remote/supabase/models/supabase_filters.dart';
import 'package:gamer_grove/data/datasources/remote/supabase/models/supabase_query.dart';

/// Preset queries for the `users` table.
class UserQueries {
  /// Query to get a user profile by ID.
  ///
  /// Returns: id, username, display_name, bio, avatar_url, country,
  ///          privacy settings, stats, and timestamps.
  ///
  /// Example:
  /// ```dart
  /// final query = UserQueries.getProfileById(userId);
  /// final user = await query.build(supabase);
  /// ```
  static SupabaseQuery getProfileById(String userId) {
    return SupabaseQuery('profiles').select('''
          id,
          username,
          display_name,
          bio,
          avatar_url,
          country,
          is_profile_public,
          show_wishlist,
          show_rated_games,
          show_recommended_games,
          show_top_three,
          total_games_rated,
          total_games_wishlisted,
          total_games_recommended,
          average_rating,
          followers_count,
          following_count,
          created_at,
          updated_at,
          last_active_at
        ''').filter(EqualFilter('id', userId)).single();
  }

  /// Query to get a user profile by username.
  ///
  /// Example:
  /// ```dart
  /// final query = UserQueries.getProfileByUsername('john_doe');
  /// final user = await query.maybeSingle().build(supabase);
  /// ```
  static SupabaseQuery getProfileByUsername(String username) {
    return SupabaseQuery('profiles').select('''
          id,
          username,
          display_name,
          bio,
          avatar_url,
          country,
          is_profile_public,
          show_wishlist,
          show_rated_games,
          show_recommended_games,
          show_top_three,
          total_games_rated,
          total_games_wishlisted,
          total_games_recommended,
          average_rating,
          followers_count,
          following_count,
          created_at,
          updated_at,
          last_active_at
        ''').filter(EqualFilter('username', username)).maybeSingle();
  }

  /// Query to get public user profiles.
  ///
  /// Example:
  /// ```dart
  /// final query = UserQueries.getPublicProfiles(
  ///   pagination: Pagination.page(1, pageSize: 20),
  /// );
  /// final users = await query.build(supabase);
  /// ```
  static SupabaseQuery getPublicProfiles({
    Pagination? pagination,
    SortBy? sortBy,
  }) {
    return SupabaseQuery('profiles')
        .select(
            'id, username, display_name, avatar_url, country, followers_count, total_games_rated',)
        .filter(const IsTrueFilter('is_profile_public'))
        .sort(sortBy ?? const SortBy('followers_count', SortOrder.desc))
        .paginate(pagination ?? const Pagination(limit: 20));
  }

  /// Query to search users by username pattern.
  ///
  /// Example:
  /// ```dart
  /// final query = UserQueries.searchByUsername('john');
  /// final users = await query.build(supabase);
  /// ```
  static SupabaseQuery searchByUsername(
    String searchTerm, {
    Pagination? pagination,
  }) {
    return SupabaseQuery('profiles')
        .select('id, username, display_name, avatar_url, followers_count')
        .filter(ILikeFilter('username', '%$searchTerm%'))
        .filter(const IsTrueFilter('is_profile_public'))
        .sort(const SortBy('followers_count', SortOrder.desc))
        .paginate(pagination ?? const Pagination(limit: 20));
  }

  /// Query to get users with most followers.
  ///
  /// Example:
  /// ```dart
  /// final query = UserQueries.getPopularUsers(limit: 10);
  /// final users = await query.build(supabase);
  /// ```
  static SupabaseQuery getPopularUsers({
    int limit = 10,
  }) {
    return SupabaseQuery('profiles')
        .select(
            'id, username, display_name, avatar_url, followers_count, total_games_rated',)
        .filter(const IsTrueFilter('is_profile_public'))
        .filter(const GreaterThanFilter('followers_count', 0))
        .sort(const SortBy('followers_count', SortOrder.desc))
        .paginate(Pagination(limit: limit));
  }
}

/// Preset queries for the `user_games` table.
class UserGameQueries {
  /// Query to get all games for a user.
  ///
  /// Example:
  /// ```dart
  /// final query = UserGameQueries.getAllUserGames(userId);
  /// final games = await query.build(supabase);
  /// ```
  static SupabaseQuery getAllUserGames(String userId) {
    return SupabaseQuery('user_games')
        .select('*')
        .filter(EqualFilter('user_id', userId));
  }

  /// Query to get wishlisted games for a user.
  ///
  /// Example:
  /// ```dart
  /// final query = UserGameQueries.getWishlistedGames(userId);
  /// final games = await query.build(supabase);
  /// ```
  static SupabaseQuery getWishlistedGames(String userId,
      {Pagination? pagination,}) {
    return SupabaseQuery('user_games')
        .select('game_id, wishlisted_at')
        .filter(EqualFilter('user_id', userId))
        .filter(const IsTrueFilter('is_wishlisted'))
        .sort(const SortBy('wishlisted_at', SortOrder.desc))
        .paginate(pagination ?? const Pagination(limit: 50));
  }

  /// Query to get rated games for a user.
  ///
  /// Example:
  /// ```dart
  /// final query = UserGameQueries.getRatedGames(userId);
  /// final games = await query.build(supabase);
  /// ```
  static SupabaseQuery getRatedGames(String userId, {Pagination? pagination}) {
    return SupabaseQuery('user_games')
        .select('game_id, rating, rated_at')
        .filter(EqualFilter('user_id', userId))
        .filter(const IsTrueFilter('is_rated'))
        .sort(const SortBy('rated_at', SortOrder.desc))
        .paginate(pagination ?? const Pagination(limit: 50));
  }

  /// Query to get recommended games for a user.
  ///
  /// Example:
  /// ```dart
  /// final query = UserGameQueries.getRecommendedGames(userId);
  /// final games = await query.build(supabase);
  /// ```
  static SupabaseQuery getRecommendedGames(String userId,
      {Pagination? pagination,}) {
    return SupabaseQuery('user_games')
        .select('game_id, recommended_at')
        .filter(EqualFilter('user_id', userId))
        .filter(const IsTrueFilter('is_recommended'))
        .sort(const SortBy('recommended_at', SortOrder.desc))
        .paginate(pagination ?? const Pagination(limit: 50));
  }

  /// Query to get highly rated games (rating >= threshold).
  ///
  /// Example:
  /// ```dart
  /// final query = UserGameQueries.getHighlyRatedGames(userId, minRating: 8.0);
  /// final games = await query.build(supabase);
  /// ```
  static SupabaseQuery getHighlyRatedGames(
    String userId, {
    double minRating = 8.0,
    Pagination? pagination,
  }) {
    return SupabaseQuery('user_games')
        .select('game_id, rating, rated_at')
        .filter(EqualFilter('user_id', userId))
        .filter(const IsTrueFilter('is_rated'))
        .filter(GreaterThanOrEqualFilter('rating', minRating))
        .sort(const SortBy('rating', SortOrder.desc))
        .paginate(pagination ?? const Pagination(limit: 50));
  }

  /// Query to check if a specific game exists in user's collections.
  ///
  /// Example:
  /// ```dart
  /// final query = UserGameQueries.getUserGame(userId, gameId);
  /// final game = await query.build(supabase);
  /// ```
  static SupabaseQuery getUserGame(String userId, int gameId) {
    return SupabaseQuery('user_games')
        .select('*')
        .filter(EqualFilter('user_id', userId))
        .filter(EqualFilter('game_id', gameId))
        .maybeSingle();
  }

  /// Query to get enrichment data for multiple games at once.
  ///
  /// Example:
  /// ```dart
  /// final query = UserGameQueries.batchGetUserGames(userId, [1942, 1905, 113]);
  /// final games = await query.build(supabase);
  /// ```
  static SupabaseQuery batchGetUserGames(String userId, List<int> gameIds) {
    return SupabaseQuery('user_games')
        .select('*')
        .filter(EqualFilter('user_id', userId))
        .filter(InFilter('game_id', gameIds));
  }
}

/// Preset queries for the `user_top_three` table.
class TopThreeQueries {
  /// Query to get user's top 3 games.
  ///
  /// Example:
  /// ```dart
  /// final query = TopThreeQueries.getTopThree(userId);
  /// final topThree = await query.build(supabase);
  /// ```
  static SupabaseQuery getTopThree(String userId) {
    return SupabaseQuery('user_top_three')
        .select('game_1_id, game_2_id, game_3_id, updated_at')
        .filter(EqualFilter('user_id', userId))
        .maybeSingle();
  }
}

/// Preset queries for the `user_follows` table.
class FollowQueries {
  /// Query to get followers of a user.
  ///
  /// Example:
  /// ```dart
  /// final query = FollowQueries.getFollowers(userId);
  /// final followers = await query.build(supabase);
  /// ```
  static SupabaseQuery getFollowers(
    String userId, {
    Pagination? pagination,
  }) {
    return SupabaseQuery('user_follows')
        .select('''
          follower_id,
          created_at,
          profiles!user_follows_follower_id_fkey(
            id,
            username,
            display_name,
            avatar_url,
            bio,
            country,
            is_profile_public,
            show_wishlist,
            show_rated_games,
            show_recommended_games,
            show_top_three,
            total_games_rated,
            total_games_wishlisted,
            total_games_recommended,
            average_rating,
            followers_count,
            following_count,
            created_at,
            updated_at,
            last_active_at
          )
        ''')
        .filter(EqualFilter('following_id', userId))
        .sort(const SortBy('created_at', SortOrder.desc))
        .paginate(pagination ?? const Pagination(limit: 20));
  }

  /// Query to get users that a user is following.
  ///
  /// Example:
  /// ```dart
  /// final query = FollowQueries.getFollowing(userId);
  /// final following = await query.build(supabase);
  /// ```
  static SupabaseQuery getFollowing(
    String userId, {
    Pagination? pagination,
  }) {
    return SupabaseQuery('user_follows')
        .select('''
          following_id,
          created_at,
          profiles!user_follows_following_id_fkey(
            id,
            username,
            display_name,
            avatar_url,
            bio,
            country,
            is_profile_public,
            show_wishlist,
            show_rated_games,
            show_recommended_games,
            show_top_three,
            total_games_rated,
            total_games_wishlisted,
            total_games_recommended,
            average_rating,
            followers_count,
            following_count,
            created_at,
            updated_at,
            last_active_at
          )
        ''')
        .filter(EqualFilter('follower_id', userId))
        .sort(const SortBy('created_at', SortOrder.desc))
        .paginate(pagination ?? const Pagination(limit: 20));
  }

  /// Query to check if user A follows user B.
  ///
  /// Example:
  /// ```dart
  /// final query = FollowQueries.isFollowing(userId, targetUserId);
  /// final result = await query.build(supabase);
  /// final isFollowing = result != null;
  /// ```
  static SupabaseQuery isFollowing(String followerId, String followingId) {
    return SupabaseQuery('user_follows')
        .select('id')
        .filter(EqualFilter('follower_id', followerId))
        .filter(EqualFilter('following_id', followingId))
        .maybeSingle();
  }

  /// Query to get recent followers.
  ///
  /// Example:
  /// ```dart
  /// final query = FollowQueries.getRecentFollowers(userId, limit: 5);
  /// final recent = await query.build(supabase);
  /// ```
  static SupabaseQuery getRecentFollowers(
    String userId, {
    int limit = 10,
  }) {
    return SupabaseQuery('user_follows')
        .select('''
          follower_id,
          created_at,
          profiles!user_follows_follower_id_fkey(
            id,
            username,
            display_name,
            avatar_url
          )
        ''')
        .filter(EqualFilter('following_id', userId))
        .sort(const SortBy('created_at', SortOrder.desc))
        .paginate(Pagination(limit: limit));
  }
}

/// Preset queries for the `user_activity` table.
class ActivityQueries {
  /// Query to get user's activity timeline.
  ///
  /// Example:
  /// ```dart
  /// final query = ActivityQueries.getUserActivity(userId);
  /// final activities = await query.build(supabase);
  /// ```
  static SupabaseQuery getUserActivity(
    String userId, {
    Pagination? pagination,
  }) {
    return SupabaseQuery('user_activity')
        .select('*')
        .filter(EqualFilter('user_id', userId))
        .sort(const SortBy('created_at', SortOrder.desc))
        .paginate(pagination ?? const Pagination(limit: 20));
  }

  /// Query to get public activities from users that current user follows.
  ///
  /// Note: This is simplified. In practice, you'd use the PostgreSQL function
  /// get_following_activity_feed for better performance.
  ///
  /// Example:
  /// ```dart
  /// final query = ActivityQueries.getPublicActivity();
  /// final activities = await query.build(supabase);
  /// ```
  static SupabaseQuery getPublicActivity({
    Pagination? pagination,
  }) {
    return SupabaseQuery('user_activity')
        .select('''
          id,
          user_id,
          activity_type,
          game_id,
          metadata,
          created_at,
          profiles(
            username,
            display_name,
            avatar_url
          )
        ''')
        .filter(const IsTrueFilter('is_public'))
        .sort(const SortBy('created_at', SortOrder.desc))
        .paginate(pagination ?? const Pagination(limit: 20));
  }

  /// Query to get activities of a specific type.
  ///
  /// Example:
  /// ```dart
  /// final query = ActivityQueries.getActivitiesByType(userId, 'rated');
  /// final ratings = await query.build(supabase);
  /// ```
  static SupabaseQuery getActivitiesByType(
    String userId,
    String activityType, {
    Pagination? pagination,
  }) {
    return SupabaseQuery('user_activity')
        .select('*')
        .filter(EqualFilter('user_id', userId))
        .filter(EqualFilter('activity_type', activityType))
        .sort(const SortBy('created_at', SortOrder.desc))
        .paginate(pagination ?? const Pagination(limit: 20));
  }

  /// Query to get activities for a specific game.
  ///
  /// Example:
  /// ```dart
  /// final query = ActivityQueries.getGameActivities(userId, 1942);
  /// final activities = await query.build(supabase);
  /// ```
  static SupabaseQuery getGameActivities(
    String userId,
    int gameId, {
    Pagination? pagination,
  }) {
    return SupabaseQuery('user_activity')
        .select('*')
        .filter(EqualFilter('user_id', userId))
        .filter(EqualFilter('game_id', gameId))
        .sort(const SortBy('created_at', SortOrder.desc))
        .paginate(pagination ?? const Pagination(limit: 10));
  }
}

/// Preset RPC queries for complex operations.
class RpcQueries {
  /// RPC to get enriched game data for a user.
  ///
  /// This is the CRITICAL performance function!
  ///
  /// Example:
  /// ```dart
  /// final query = RpcQueries.getGameEnrichment(userId, [1942, 1905, 113]);
  /// final enrichedData = await query.build(supabase);
  /// ```
  static SupabaseRpcQuery getGameEnrichment(
    String userId,
    List<int> gameIds,
  ) {
    return SupabaseRpcQuery('get_user_game_enrichment_data')
        .param('p_user_id', userId)
        .param('p_game_ids', gameIds);
  }

  /// RPC to get user collection statistics.
  ///
  /// Example:
  /// ```dart
  /// final query = RpcQueries.getCollectionStats(userId);
  /// final stats = await query.build(supabase);
  /// ```
  static SupabaseRpcQuery getCollectionStats(String userId) {
    return SupabaseRpcQuery('get_user_collection_stats')
        .param('p_user_id', userId);
  }

  /// RPC to get activity feed from followed users.
  ///
  /// Example:
  /// ```dart
  /// final query = RpcQueries.getFollowingActivity(userId, limit: 20);
  /// final feed = await query.build(supabase);
  /// ```
  static SupabaseRpcQuery getFollowingActivity(
    String userId, {
    int limit = 20,
  }) {
    return SupabaseRpcQuery('get_following_activity_feed')
        .param('p_user_id', userId)
        .param('p_limit', limit);
  }

  /// RPC to get relationship status between two users.
  ///
  /// Example:
  /// ```dart
  /// final query = RpcQueries.getUserRelationship(currentUserId, targetUserId);
  /// final relationship = await query.build(supabase);
  /// ```
  static SupabaseRpcQuery getUserRelationship(
    String currentUserId,
    String targetUserId,
  ) {
    return SupabaseRpcQuery('get_user_relationship')
        .param('p_current_user_id', currentUserId)
        .param('p_target_user_id', targetUserId);
  }

  /// RPC to search users with full-text search.
  ///
  /// Example:
  /// ```dart
  /// final query = RpcQueries.searchUsers('john', limit: 10);
  /// final users = await query.build(supabase);
  /// ```
  static SupabaseRpcQuery searchUsers(
    String searchQuery, {
    int limit = 20,
  }) {
    return SupabaseRpcQuery('search_users')
        .param('search_query', searchQuery)
        .param('result_limit', limit);
  }

  /// RPC to get popular users.
  ///
  /// Example:
  /// ```dart
  /// final query = RpcQueries.getPopularUsers(limit: 10);
  /// final users = await query.build(supabase);
  /// ```
  static SupabaseRpcQuery getPopularUsers({int limit = 10}) {
    return SupabaseRpcQuery('get_popular_users').param('result_limit', limit);
  }

  /// RPC to get mutual followers between two users.
  ///
  /// Example:
  /// ```dart
  /// final query = RpcQueries.getMutualFollowers(userId1, userId2);
  /// final mutuals = await query.build(supabase);
  /// ```
  static SupabaseRpcQuery getMutualFollowers(
    String userId1,
    String userId2,
  ) {
    return SupabaseRpcQuery('get_mutual_followers')
        .param('p_user1_id', userId1)
        .param('p_user2_id', userId2);
  }

  /// RPC to batch check follow status for multiple users.
  ///
  /// Example:
  /// ```dart
  /// final query = RpcQueries.batchGetFollowStatus(
  ///   currentUserId,
  ///   [targetId1, targetId2, targetId3],
  /// );
  /// final statuses = await query.build(supabase);
  /// ```
  static SupabaseRpcQuery batchGetFollowStatus(
    String currentUserId,
    List<String> targetUserIds,
  ) {
    return SupabaseRpcQuery('batch_get_follow_status')
        .param('p_current_user_id', currentUserId)
        .param('p_target_user_ids', targetUserIds);
  }
}
