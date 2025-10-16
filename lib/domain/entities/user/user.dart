// lib/domain/entities/user/user.dart

import 'package:equatable/equatable.dart';

/// Domain entity representing a user.
///
/// Contains user profile information, privacy settings, and gaming statistics.
class User extends Equatable {
  final String id;
  final String username;
  final String? displayName;
  final String? bio;
  final String? avatarUrl;
  final String? country;

  // Privacy Settings
  final bool isProfilePublic;
  final bool showWishlist;
  final bool showRatedGames;
  final bool showRecommendedGames;
  final bool showTopThree;

  // Gaming Statistics
  final int totalGamesRated;
  final int totalGamesWishlisted;
  final int totalGamesRecommended;
  final double? averageRating;

  // Social Statistics
  final int followersCount;
  final int followingCount;

  // Timestamps
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastActiveAt;

  const User({
    required this.id,
    required this.username,
    this.displayName,
    this.bio,
    this.avatarUrl,
    this.country,
    this.isProfilePublic = true,
    this.showWishlist = true,
    this.showRatedGames = true,
    this.showRecommendedGames = true,
    this.showTopThree = true,
    this.totalGamesRated = 0,
    this.totalGamesWishlisted = 0,
    this.totalGamesRecommended = 0,
    this.averageRating,
    this.followersCount = 0,
    this.followingCount = 0,
    required this.createdAt,
    required this.updatedAt,
    this.lastActiveAt,
  });

  /// Empty user instance
  static User empty() {
    return User(
      id: '',
      username: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  // ==========================================
  // HELPER GETTERS
  // ==========================================

  /// Gets the effective display name (displayName or username)
  String get effectiveDisplayName => displayName ?? username;

  /// Checks if the user has a custom display name
  bool get hasDisplayName => displayName != null && displayName!.isNotEmpty;

  /// Checks if the user has a bio
  bool get hasBio => bio != null && bio!.isNotEmpty;

  /// Checks if the user has an avatar
  bool get hasAvatar => avatarUrl != null && avatarUrl!.isNotEmpty;

  /// Checks if the user has set a country
  bool get hasCountry => country != null && country!.isNotEmpty;

  /// Checks if the user is new (registered within last 7 days)
  bool get isNewUser => DateTime.now().difference(createdAt).inDays < 7;

  /// Checks if the user is active (has rated games)
  bool get isActiveUser => totalGamesRated > 5;

  /// Checks if the user has any gaming activity
  bool get hasActivity =>
      totalGamesRated > 0 ||
      totalGamesWishlisted > 0 ||
      totalGamesRecommended > 0;

  /// Checks if the user has rated any games
  bool get hasRatings => totalGamesRated > 0;

  /// Checks if the user has followers
  bool get hasFollowers => followersCount > 0;

  /// Checks if the user follows anyone
  bool get hasFollowing => followingCount > 0;

  /// Checks if the user has social connections
  bool get hasSocialConnections => hasFollowers || hasFollowing;

  /// Total games in all collections
  int get totalGamesInCollections =>
      totalGamesRated + totalGamesWishlisted + totalGamesRecommended;

  /// Profile completion percentage (0.0 to 1.0)
  double get profileCompletion {
    double score = 0.0;
    if (username.isNotEmpty) score += 0.15;
    if (hasDisplayName) score += 0.15;
    if (hasBio) score += 0.20;
    if (hasAvatar) score += 0.25;
    if (hasCountry) score += 0.10;
    if (totalGamesRated >= 3) score += 0.15; // At least 3 rated games
    return score.clamp(0.0, 1.0);
  }

  /// Profile completion percentage as integer (0-100)
  int get profileCompletionPercentage => (profileCompletion * 100).round();

  /// Gets a user level based on activity
  String get userLevel {
    final total = totalGamesInCollections;
    if (total >= 500) return 'Legend';
    if (total >= 200) return 'Master';
    if (total >= 100) return 'Expert';
    if (total >= 50) return 'Enthusiast';
    if (total >= 20) return 'Regular';
    if (total >= 5) return 'Casual';
    return 'Newcomer';
  }

  /// Gets rating personality based on average rating
  String get ratingPersonality {
    if (averageRating == null || !hasRatings) return 'No ratings yet';
    final rating = averageRating!;
    if (rating >= 9.0) return 'Highly Critical';
    if (rating >= 8.0) return 'Critical';
    if (rating >= 7.0) return 'Balanced';
    if (rating >= 6.0) return 'Generous';
    return 'Very Generous';
  }

  /// Checks if user was recently active (within last 30 days)
  bool get isRecentlyActive {
    if (lastActiveAt == null) return false;
    return DateTime.now().difference(lastActiveAt!).inDays <= 30;
  }

  /// Gets a description of the last active time
  String get lastActiveDescription {
    if (lastActiveAt == null) return 'Never active';
    final difference = DateTime.now().difference(lastActiveAt!);
    if (difference.inDays == 0) return 'Active today';
    if (difference.inDays == 1) return 'Active yesterday';
    if (difference.inDays < 7) return 'Active ${difference.inDays} days ago';
    if (difference.inDays < 30)
      return 'Active ${(difference.inDays / 7).floor()} weeks ago';
    if (difference.inDays < 365)
      return 'Active ${(difference.inDays / 30).floor()} months ago';
    return 'Active ${(difference.inDays / 365).floor()} years ago';
  }

  // ==========================================
  // METHODS
  // ==========================================

  /// Creates a copy with modified fields
  User copyWith({
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
    return User(
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
  List<Object?> get props => [
        id,
        username,
        displayName,
        bio,
        avatarUrl,
        country,
        isProfilePublic,
        showWishlist,
        showRatedGames,
        showRecommendedGames,
        showTopThree,
        totalGamesRated,
        totalGamesWishlisted,
        totalGamesRecommended,
        averageRating,
        followersCount,
        followingCount,
        createdAt,
        updatedAt,
        lastActiveAt,
      ];

  @override
  String toString() {
    return 'User(id: $id, username: $username, displayName: $effectiveDisplayName, rated: $totalGamesRated, followers: $followersCount)';
  }
}
