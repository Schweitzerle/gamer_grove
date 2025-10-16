// lib/data/models/user_stats_model.dart

/// Data model for UserStats entity.
///
/// Handles JSON serialization/deserialization for user statistics.
library;

import '../../domain/entities/user/user_stats.dart';

/// User statistics model for data layer.
///
/// Represents aggregated user statistics from Supabase database.
class UserStatsModel {
  final int totalGamesRated;
  final int totalGamesWishlisted;
  final int totalGamesRecommended;
  final double? averageRating;
  final int followersCount;
  final int followingCount;
  final int? totalPlaytime; // Optional: if tracking playtime
  final int? totalAchievements; // Optional: if tracking achievements

  const UserStatsModel({
    required this.totalGamesRated,
    required this.totalGamesWishlisted,
    required this.totalGamesRecommended,
    this.averageRating,
    required this.followersCount,
    required this.followingCount,
    this.totalPlaytime,
    this.totalAchievements,
  });

  /// Creates a UserStatsModel from JSON.
  ///
  /// Example:
  /// ```dart
  /// final json = {
  ///   'total_games_rated': 42,
  ///   'average_rating': 8.5,
  ///   'followers_count': 120,
  /// };
  /// final model = UserStatsModel.fromJson(json);
  /// ```
  factory UserStatsModel.fromJson(Map<String, dynamic> json) {
    return UserStatsModel(
      totalGamesRated: json['total_games_rated'] as int? ?? 0,
      totalGamesWishlisted: json['total_games_wishlisted'] as int? ?? 0,
      totalGamesRecommended: json['total_games_recommended'] as int? ?? 0,
      averageRating: (json['average_rating'] as num?)?.toDouble(),
      followersCount: json['followers_count'] as int? ?? 0,
      followingCount: json['following_count'] as int? ?? 0,
      totalPlaytime: json['total_playtime'] as int?,
      totalAchievements: json['total_achievements'] as int?,
    );
  }

  /// Converts UserStatsModel to JSON.
  Map<String, dynamic> toJson() {
    return {
      'total_games_rated': totalGamesRated,
      'total_games_wishlisted': totalGamesWishlisted,
      'total_games_recommended': totalGamesRecommended,
      'average_rating': averageRating,
      'followers_count': followersCount,
      'following_count': followingCount,
      'total_playtime': totalPlaytime,
      'total_achievements': totalAchievements,
    };
  }

  /// Converts UserStatsModel to domain UserStats entity.
  UserStats toEntity() {
    return UserStats(
      totalGamesRated: totalGamesRated,
      totalGamesWishlisted: totalGamesWishlisted,
      totalGamesRecommended: totalGamesRecommended,
      averageRating: averageRating,
      followersCount: followersCount,
      followingCount: followingCount,
      totalPlaytime: totalPlaytime,
      totalAchievements: totalAchievements,
    );
  }

  /// Creates a UserStatsModel from domain UserStats entity.
  factory UserStatsModel.fromEntity(UserStats stats) {
    return UserStatsModel(
      totalGamesRated: stats.totalGamesRated,
      totalGamesWishlisted: stats.totalGamesWishlisted,
      totalGamesRecommended: stats.totalGamesRecommended,
      averageRating: stats.averageRating,
      followersCount: stats.followersCount,
      followingCount: stats.followingCount,
      totalPlaytime: stats.totalPlaytime,
      totalAchievements: stats.totalAchievements,
    );
  }

  /// Creates a copy with modified fields.
  UserStatsModel copyWith({
    int? totalGamesRated,
    int? totalGamesWishlisted,
    int? totalGamesRecommended,
    double? averageRating,
    int? followersCount,
    int? followingCount,
    int? totalPlaytime,
    int? totalAchievements,
  }) {
    return UserStatsModel(
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
  String toString() {
    return 'UserStatsModel(rated: $totalGamesRated, avg: $averageRating, followers: $followersCount)';
  }
}
