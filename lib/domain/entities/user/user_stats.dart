// lib/domain/entities/user/user_stats.dart

import 'package:equatable/equatable.dart';

/// Domain entity representing user statistics.
///
/// Contains aggregated statistics about a user's gaming activity.
class UserStats extends Equatable {
  final int totalGamesRated;
  final int totalGamesWishlisted;
  final int totalGamesRecommended;
  final double? averageRating;
  final int followersCount;
  final int followingCount;
  final int? totalPlaytime; // Optional: if tracking playtime
  final int? totalAchievements; // Optional: if tracking achievements

  const UserStats({
    this.totalGamesRated = 0,
    this.totalGamesWishlisted = 0,
    this.totalGamesRecommended = 0,
    this.averageRating,
    this.followersCount = 0,
    this.followingCount = 0,
    this.totalPlaytime,
    this.totalAchievements,
  });

  /// Empty stats instance (default values)
  static const empty = UserStats();

  /// Checks if the user has any activity
  bool get hasActivity =>
      totalGamesRated > 0 ||
      totalGamesWishlisted > 0 ||
      totalGamesRecommended > 0;

  /// Checks if the user has rated any games
  bool get hasRatings => totalGamesRated > 0;

  /// Checks if the user has any followers
  bool get hasFollowers => followersCount > 0;

  /// Checks if the user follows anyone
  bool get hasFollowing => followingCount > 0;

  /// Checks if the user has social connections
  bool get hasSocialConnections => hasFollowers || hasFollowing;

  /// Total number of games in user's collections
  int get totalGamesInCollections =>
      totalGamesRated + totalGamesWishlisted + totalGamesRecommended;

  /// Gets a rating level description based on average rating
  String get ratingLevel {
    if (averageRating == null || !hasRatings) return 'No ratings yet';
    final rating = averageRating!;
    if (rating >= 9.0) return 'Highly Critical';
    if (rating >= 8.0) return 'Critical';
    if (rating >= 7.0) return 'Balanced';
    if (rating >= 6.0) return 'Generous';
    return 'Very Generous';
  }

  /// Gets engagement level based on total activity
  String get engagementLevel {
    final total = totalGamesInCollections;
    if (total >= 100) return 'Power User';
    if (total >= 50) return 'Active';
    if (total >= 20) return 'Regular';
    if (total >= 5) return 'Casual';
    return 'Newcomer';
  }

  /// Gets social influence level based on followers
  String get socialInfluence {
    if (followersCount >= 1000) return 'Influencer';
    if (followersCount >= 100) return 'Popular';
    if (followersCount >= 50) return 'Well-Known';
    if (followersCount >= 10) return 'Social';
    return 'Growing';
  }

  /// Formats playtime in a human-readable way (assumes minutes)
  String get formattedPlaytime {
    if (totalPlaytime == null || totalPlaytime == 0) return '0 hours';
    final hours = totalPlaytime! ~/ 60;
    if (hours == 0) return '$totalPlaytime minutes';
    if (hours >= 1000) return '${(hours / 1000).toStringAsFixed(1)}k hours';
    return '$hours hours';
  }

  /// Checks if this is essentially empty stats
  bool get isEmpty =>
      totalGamesRated == 0 &&
      totalGamesWishlisted == 0 &&
      totalGamesRecommended == 0 &&
      followersCount == 0 &&
      followingCount == 0;

  /// Creates a copy with modified fields
  UserStats copyWith({
    int? totalGamesRated,
    int? totalGamesWishlisted,
    int? totalGamesRecommended,
    double? averageRating,
    int? followersCount,
    int? followingCount,
    int? totalPlaytime,
    int? totalAchievements,
  }) {
    return UserStats(
      totalGamesRated: totalGamesRated ?? this.totalGamesRated,
      totalGamesWishlisted: totalGamesWishlisted ?? this.totalGamesWishlisted,
      totalGamesRecommended:
          totalGamesRecommended ?? this.totalGamesRecommended,
      averageRating: averageRating ?? this.averageRating,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      totalPlaytime: totalPlaytime ?? this.totalPlaytime,
      totalAchievements: totalAchievements ?? this.totalAchievements,
    );
  }

  @override
  List<Object?> get props => [
        totalGamesRated,
        totalGamesWishlisted,
        totalGamesRecommended,
        averageRating,
        followersCount,
        followingCount,
        totalPlaytime,
        totalAchievements,
      ];

  @override
  String toString() {
    return 'UserStats(rated: $totalGamesRated, wishlist: $totalGamesWishlisted, recommended: $totalGamesRecommended, avgRating: $averageRating, followers: $followersCount, following: $followingCount)';
  }
}
