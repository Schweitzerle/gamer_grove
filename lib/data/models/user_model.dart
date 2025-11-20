// lib/data/models/user_model.dart

/// Data model for User entity.
///
/// Handles JSON serialization/deserialization and conversion to domain entity.
library;

import 'package:gamer_grove/domain/entities/user/user.dart';

/// User model for data layer.
///
/// Represents user data from Supabase database with JSON conversion.
class UserModel {

  const UserModel({
    required this.id,
    required this.username,
    required this.isProfilePublic, required this.showWishlist, required this.showRatedGames, required this.showRecommendedGames, required this.showTopThree, required this.totalGamesRated, required this.totalGamesWishlisted, required this.totalGamesRecommended, required this.followersCount, required this.followingCount, required this.createdAt, required this.updatedAt, this.displayName,
    this.bio,
    this.avatarUrl,
    this.country,
    this.averageRating,
    this.lastActiveAt,
  });

  /// Creates a UserModel from JSON.
  ///
  /// Example:
  /// ```dart
  /// final json = {
  ///   'id': 'uuid',
  ///   'username': 'john_doe',
  ///   'display_name': 'John Doe',
  ///   // ... other fields
  /// };
  /// final model = UserModel.fromJson(json);
  /// ```
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      username: json['username'] as String,
      displayName: json['display_name'] as String?,
      bio: json['bio'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      country: json['country'] as String?,
      isProfilePublic: json['is_profile_public'] as bool? ?? true,
      showWishlist: json['show_wishlist'] as bool? ?? true,
      showRatedGames: json['show_rated_games'] as bool? ?? true,
      showRecommendedGames: json['show_recommended_games'] as bool? ?? true,
      showTopThree: json['show_top_three'] as bool? ?? true,
      totalGamesRated: json['total_games_rated'] as int? ?? 0,
      totalGamesWishlisted: json['total_games_wishlisted'] as int? ?? 0,
      totalGamesRecommended: json['total_games_recommended'] as int? ?? 0,
      averageRating: (json['average_rating'] as num?)?.toDouble(),
      followersCount: json['followers_count'] as int? ?? 0,
      followingCount: json['following_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      lastActiveAt: json['last_active_at'] != null
          ? DateTime.parse(json['last_active_at'] as String)
          : null,
    );
  }

  /// Creates a UserModel from domain User entity.
  ///
  /// Example:
  /// ```dart
  /// final model = UserModel.fromEntity(user);
  /// ```
  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      username: user.username,
      displayName: user.displayName,
      bio: user.bio,
      avatarUrl: user.avatarUrl,
      country: user.country,
      isProfilePublic: user.isProfilePublic,
      showWishlist: user.showWishlist,
      showRatedGames: user.showRatedGames,
      showRecommendedGames: user.showRecommendedGames,
      showTopThree: user.showTopThree,
      totalGamesRated: user.totalGamesRated,
      totalGamesWishlisted: user.totalGamesWishlisted,
      totalGamesRecommended: user.totalGamesRecommended,
      averageRating: user.averageRating,
      followersCount: user.followersCount,
      followingCount: user.followingCount,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
      lastActiveAt: user.lastActiveAt,
    );
  }
  final String id;
  final String username;
  final String? displayName;
  final String? bio;
  final String? avatarUrl;
  final String? country;

  // Privacy settings
  final bool isProfilePublic;
  final bool showWishlist;
  final bool showRatedGames;
  final bool showRecommendedGames;
  final bool showTopThree;

  // Stats
  final int totalGamesRated;
  final int totalGamesWishlisted;
  final int totalGamesRecommended;
  final double? averageRating;
  final int followersCount;
  final int followingCount;

  // Timestamps
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastActiveAt;

  /// Converts UserModel to JSON.
  ///
  /// Example:
  /// ```dart
  /// final json = userModel.toJson();
  /// ```
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'display_name': displayName,
      'bio': bio,
      'avatar_url': avatarUrl,
      'country': country,
      'is_profile_public': isProfilePublic,
      'show_wishlist': showWishlist,
      'show_rated_games': showRatedGames,
      'show_recommended_games': showRecommendedGames,
      'show_top_three': showTopThree,
      'total_games_rated': totalGamesRated,
      'total_games_wishlisted': totalGamesWishlisted,
      'total_games_recommended': totalGamesRecommended,
      'average_rating': averageRating,
      'followers_count': followersCount,
      'following_count': followingCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'last_active_at': lastActiveAt?.toIso8601String(),
    };
  }

  /// Converts UserModel to domain User entity.
  ///
  /// Example:
  /// ```dart
  /// final user = userModel.toEntity();
  /// ```
  User toEntity() {
    return User(
      id: id,
      username: username,
      displayName: displayName,
      bio: bio,
      avatarUrl: avatarUrl,
      country: country,
      isProfilePublic: isProfilePublic,
      showWishlist: showWishlist,
      showRatedGames: showRatedGames,
      showRecommendedGames: showRecommendedGames,
      showTopThree: showTopThree,
      totalGamesRated: totalGamesRated,
      totalGamesWishlisted: totalGamesWishlisted,
      totalGamesRecommended: totalGamesRecommended,
      averageRating: averageRating,
      followersCount: followersCount,
      followingCount: followingCount,
      createdAt: createdAt,
      updatedAt: updatedAt,
      lastActiveAt: lastActiveAt,
    );
  }

  /// Creates a copy with modified fields.
  UserModel copyWith({
    String? id,
    String? username,
    String? displayName,
    String? bio,
    String? avatarUrl,
    String? country,
    bool? isProfilePublic,
    bool? showWishlist,
    bool? showRatedGames,
    bool? showRecommendedGames,
    bool? showTopThree,
    int? totalGamesRated,
    int? totalGamesWishlisted,
    int? totalGamesRecommended,
    double? averageRating,
    int? followersCount,
    int? followingCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastActiveAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      country: country ?? this.country,
      isProfilePublic: isProfilePublic ?? this.isProfilePublic,
      showWishlist: showWishlist ?? this.showWishlist,
      showRatedGames: showRatedGames ?? this.showRatedGames,
      showRecommendedGames: showRecommendedGames ?? this.showRecommendedGames,
      showTopThree: showTopThree ?? this.showTopThree,
      totalGamesRated: totalGamesRated ?? this.totalGamesRated,
      totalGamesWishlisted: totalGamesWishlisted ?? this.totalGamesWishlisted,
      totalGamesRecommended:
          totalGamesRecommended ?? this.totalGamesRecommended,
      averageRating: averageRating ?? this.averageRating,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'UserModel(id: $id, username: $username, displayName: $displayName)';
  }
}
