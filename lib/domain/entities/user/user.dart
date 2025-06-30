// lib/domain/entities/user.dart - ENHANCED VERSION
import 'package:equatable/equatable.dart';
import 'package:gamer_grove/domain/entities/user/user_gaming_activity.dart';
import 'package:gamer_grove/domain/entities/user/user_top_three.dart';


class User extends Equatable {
  final String id;
  final String username;
  final String email;
  final String? avatarUrl;
  final String? bio;
  final String? country;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // Gaming Stats
  final int totalGamesRated;
  final int totalGamesWishlisted;
  final int totalGamesRecommended;
  final double? averageRating;

  // Social Stats
  final int followersCount;
  final int followingCount;
  final bool isFollowing; // Whether current user follows this user
  final bool isFollowedBy; // Whether this user follows current user

  // Privacy Settings
  final bool isProfilePublic;
  final bool showWishlist; // Always false for other users
  final bool showRatedGames;
  final bool showRecommendedGames;
  final bool showTopThree;

  // Top Three Games (always 3 positions)
  final UserTopThree topThree;

  // Quick Access to Game IDs (for current user only)
  final List<int> wishlistGameIds;
  final List<int> ratedGameIds;
  final List<int> recommendedGameIds;

  // Activity Stats
  final DateTime? lastActiveAt;
  final UserGamingActivity? activitySummary;

  const User({
    required this.id,
    required this.username,
    required this.email,
    this.avatarUrl,
    this.bio,
    this.country,
    required this.createdAt,
    this.updatedAt,
    this.totalGamesRated = 0,
    this.totalGamesWishlisted = 0,
    this.totalGamesRecommended = 0,
    this.averageRating,
    this.followersCount = 0,
    this.followingCount = 0,
    this.isFollowing = false,
    this.isFollowedBy = false,
    this.isProfilePublic = true,
    this.showWishlist = false, // Default false for privacy
    this.showRatedGames = true,
    this.showRecommendedGames = true,
    this.showTopThree = true,
    this.topThree = const UserTopThree.empty(),
    this.wishlistGameIds = const [],
    this.ratedGameIds = const [],
    this.recommendedGameIds = const [],
    this.lastActiveAt,
    this.activitySummary,
  });

  // Helper getters
  bool get hasTopThree => topThree.isComplete;
  bool get isNewUser => DateTime.now().difference(createdAt).inDays < 7;
  bool get isActiveUser => totalGamesRated > 5;
  bool get canSeeProfile => isProfilePublic || isFollowing;

  // Profile completion percentage
  double get profileCompletion {
    double score = 0.0;
    if (username.isNotEmpty) score += 0.2;
    if (bio?.isNotEmpty == true) score += 0.2;
    if (avatarUrl?.isNotEmpty == true) score += 0.2;
    if (country?.isNotEmpty == true) score += 0.1;
    if (hasTopThree) score += 0.3;
    return score;
  }

  // Create copy with updated values
  User copyWith({
    String? id,
    String? username,
    String? email,
    String? avatarUrl,
    String? bio,
    String? country,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? totalGamesRated,
    int? totalGamesWishlisted,
    int? totalGamesRecommended,
    double? averageRating,
    int? followersCount,
    int? followingCount,
    bool? isFollowing,
    bool? isFollowedBy,
    bool? isProfilePublic,
    bool? showWishlist,
    bool? showRatedGames,
    bool? showRecommendedGames,
    bool? showTopThree,
    UserTopThree? topThree,
    List<int>? wishlistGameIds,
    List<int>? ratedGameIds,
    List<int>? recommendedGameIds,
    DateTime? lastActiveAt,
    UserGamingActivity? activitySummary,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      country: country ?? this.country,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      totalGamesRated: totalGamesRated ?? this.totalGamesRated,
      totalGamesWishlisted: totalGamesWishlisted ?? this.totalGamesWishlisted,
      totalGamesRecommended: totalGamesRecommended ?? this.totalGamesRecommended,
      averageRating: averageRating ?? this.averageRating,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      isFollowing: isFollowing ?? this.isFollowing,
      isFollowedBy: isFollowedBy ?? this.isFollowedBy,
      isProfilePublic: isProfilePublic ?? this.isProfilePublic,
      showWishlist: showWishlist ?? this.showWishlist,
      showRatedGames: showRatedGames ?? this.showRatedGames,
      showRecommendedGames: showRecommendedGames ?? this.showRecommendedGames,
      showTopThree: showTopThree ?? this.showTopThree,
      topThree: topThree ?? this.topThree,
      wishlistGameIds: wishlistGameIds ?? this.wishlistGameIds,
      ratedGameIds: ratedGameIds ?? this.ratedGameIds,
      recommendedGameIds: recommendedGameIds ?? this.recommendedGameIds,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      activitySummary: activitySummary ?? this.activitySummary,
    );
  }

  @override
  List<Object?> get props => [
    id, username, email, avatarUrl, bio, country, createdAt, updatedAt,
    totalGamesRated, totalGamesWishlisted, totalGamesRecommended, averageRating,
    followersCount, followingCount, isFollowing, isFollowedBy,
    isProfilePublic, showWishlist, showRatedGames, showRecommendedGames, showTopThree,
    topThree, wishlistGameIds, ratedGameIds, recommendedGameIds,
    lastActiveAt, activitySummary,
  ];
}