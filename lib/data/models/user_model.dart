import '../../domain/entities/user/user.dart';
import '../../domain/entities/user/user_top_three.dart';
import '../../domain/entities/user/user_gaming_activity.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.username,
    required super.email,
    super.avatarUrl,
    super.bio,
    super.country,
    required super.createdAt,
    super.updatedAt,
    super.totalGamesRated,
    super.totalGamesWishlisted,
    super.totalGamesRecommended,
    super.averageRating,
    super.followersCount,
    super.followingCount,
    super.isFollowing,
    super.isFollowedBy,
    super.isProfilePublic,
    super.showWishlist,
    super.showRatedGames,
    super.showRecommendedGames,
    super.showTopThree,
    super.topThree,
    super.wishlistGameIds,
    super.ratedGameIds,
    super.recommendedGameIds,
    super.lastActiveAt,
    super.activitySummary,
  });

  // Convert from Supabase JSON to UserModel
  factory UserModel.fromJson(Map<String, dynamic> json, {String? currentUserId}) {
    return UserModel(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      avatarUrl: json['avatar_url'] as String?,
      bio: json['bio'] as String?,
      country: json['country'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,

      // Gaming stats
      totalGamesRated: json['total_games_rated'] as int? ?? 0,
      totalGamesWishlisted: json['total_games_wishlisted'] as int? ?? 0,
      totalGamesRecommended: json['total_games_recommended'] as int? ?? 0,
      averageRating: (json['average_rating'] as num?)?.toDouble(),

      // Social stats
      followersCount: json['followers_count'] as int? ?? 0,
      followingCount: json['following_count'] as int? ?? 0,
      isFollowing: json['is_following'] as bool? ?? false,
      isFollowedBy: json['is_followed_by'] as bool? ?? false,

      // Privacy settings
      isProfilePublic: json['is_profile_public'] as bool? ?? true,
      showWishlist: json['show_wishlist'] as bool? ?? false,
      showRatedGames: json['show_rated_games'] as bool? ?? true,
      showRecommendedGames: json['show_recommended_games'] as bool? ?? true,
      showTopThree: json['show_top_three'] as bool? ?? true,

      // Top three games
      topThree: UserTopThree(
        firstGameId: json['top_game_1'] as int?,
        secondGameId: json['top_game_2'] as int?,
        thirdGameId: json['top_game_3'] as int?,
      ),

      // Game IDs (only for current user)
      wishlistGameIds: currentUserId == json['id']
          ? List<int>.from(json['wishlist_game_ids'] ?? [])
          : [],
      ratedGameIds: currentUserId == json['id']
          ? List<int>.from(json['rated_game_ids'] ?? [])
          : [],
      recommendedGameIds: currentUserId == json['id']
          ? List<int>.from(json['recommended_game_ids'] ?? [])
          : [],

      // Activity
      lastActiveAt: json['last_active_at'] != null
          ? DateTime.parse(json['last_active_at'] as String)
          : null,
      activitySummary: json['activity_summary'] != null
          ? UserGamingActivityModel.fromJson(json['activity_summary'])
          : null,
    );
  }

  // Convert UserModel to JSON for Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'avatar_url': avatarUrl,
      'bio': bio,
      'country': country,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'total_games_rated': totalGamesRated,
      'total_games_wishlisted': totalGamesWishlisted,
      'total_games_recommended': totalGamesRecommended,
      'average_rating': averageRating,
      'followers_count': followersCount,
      'following_count': followingCount,
      'is_profile_public': isProfilePublic,
      'show_wishlist': showWishlist,
      'show_rated_games': showRatedGames,
      'show_recommended_games': showRecommendedGames,
      'show_top_three': showTopThree,
      'top_game_1': topThree.firstGameId,
      'top_game_2': topThree.secondGameId,
      'top_game_3': topThree.thirdGameId,
      'last_active_at': lastActiveAt?.toIso8601String(),
    };
  }

  // Factory method for creating current user from auth
  factory UserModel.fromAuth({
    required String id,
    required String email,
    required String username,
  }) {
    return UserModel(
      id: id,
      username: username,
      email: email,
      createdAt: DateTime.now(),
    );
  }

  // Create UserModel from User entity
  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      username: user.username,
      email: user.email,
      avatarUrl: user.avatarUrl,
      bio: user.bio,
      country: user.country,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
      totalGamesRated: user.totalGamesRated,
      totalGamesWishlisted: user.totalGamesWishlisted,
      totalGamesRecommended: user.totalGamesRecommended,
      averageRating: user.averageRating,
      followersCount: user.followersCount,
      followingCount: user.followingCount,
      isFollowing: user.isFollowing,
      isFollowedBy: user.isFollowedBy,
      isProfilePublic: user.isProfilePublic,
      showWishlist: user.showWishlist,
      showRatedGames: user.showRatedGames,
      showRecommendedGames: user.showRecommendedGames,
      showTopThree: user.showTopThree,
      topThree: user.topThree,
      wishlistGameIds: user.wishlistGameIds,
      ratedGameIds: user.ratedGameIds,
      recommendedGameIds: user.recommendedGameIds,
      lastActiveAt: user.lastActiveAt,
      activitySummary: user.activitySummary,
    );
  }

  // Convert to User entity
  User toEntity() {
    return User(
      id: id,
      username: username,
      email: email,
      avatarUrl: avatarUrl,
      bio: bio,
      country: country,
      createdAt: createdAt,
      updatedAt: updatedAt,
      totalGamesRated: totalGamesRated,
      totalGamesWishlisted: totalGamesWishlisted,
      totalGamesRecommended: totalGamesRecommended,
      averageRating: averageRating,
      followersCount: followersCount,
      followingCount: followingCount,
      isFollowing: isFollowing,
      isFollowedBy: isFollowedBy,
      isProfilePublic: isProfilePublic,
      showWishlist: showWishlist,
      showRatedGames: showRatedGames,
      showRecommendedGames: showRecommendedGames,
      showTopThree: showTopThree,
      topThree: topThree,
      wishlistGameIds: wishlistGameIds,
      ratedGameIds: ratedGameIds,
      recommendedGameIds: recommendedGameIds,
      lastActiveAt: lastActiveAt,
      activitySummary: activitySummary,
    );
  }
}

// ==========================================

// lib/data/models/user_gaming_activity_model.dart
class UserGamingActivityModel extends UserGamingActivity {
  const UserGamingActivityModel({
    super.gamesRatedThisMonth,
    super.gamesAddedToWishlistThisMonth,
    super.gamesRecommendedThisMonth,
    super.genreBreakdown,
    super.platformBreakdown,
    super.lastRatedGameId,
    super.lastAddedToWishlistId,
    super.lastRecommendedGameId,
  });

  factory UserGamingActivityModel.fromJson(Map<String, dynamic> json) {
    return UserGamingActivityModel(
      gamesRatedThisMonth: json['games_rated_this_month'] as int? ?? 0,
      gamesAddedToWishlistThisMonth: json['games_added_to_wishlist_this_month'] as int? ?? 0,
      gamesRecommendedThisMonth: json['games_recommended_this_month'] as int? ?? 0,
      genreBreakdown: Map<String, int>.from(json['genre_breakdown'] ?? {}),
      platformBreakdown: Map<String, int>.from(json['platform_breakdown'] ?? {}),
      lastRatedGameId: json['last_rated_game'] as int? ?? 0,
      lastAddedToWishlistId: json['last_added_to_wishlist'] as int? ?? 0,
      lastRecommendedGameId: json['last_recommended_game'] as int? ?? 0
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'games_rated_this_month': gamesRatedThisMonth,
      'games_added_to_wishlist_this_month': gamesAddedToWishlistThisMonth,
      'games_recommended_this_month': gamesRecommendedThisMonth,
      'genre_breakdown': genreBreakdown,
      'platform_breakdown': platformBreakdown,
      'last_rated_game': lastRatedGameId,
      'last_added_to_wishlist': lastAddedToWishlistId,
      'last_recommended_game': lastRecommendedGameId,
    };
  }
}