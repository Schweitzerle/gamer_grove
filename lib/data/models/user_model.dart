// data/models/user_model.dart
import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.username,
    required super.email,
    super.avatarUrl,
    super.bio,
    super.country,
    required super.createdAt,
    super.wishlistGameIds = const [],
    super.recommendedGameIds = const [],
    super.gameRatings = const {},
    super.topThreeGames = const [],
    super.followingIds = const [],
    super.followerIds = const [],
    super.totalGamesRated = 0,
  });

  // Create UserModel from Supabase profile data
  factory UserModel.fromSupabase(
      Map<String, dynamic> profileData, {
        List<int> wishlistIds = const [],
        List<int> recommendedIds = const [],
        Map<int, double> ratings = const {},
        List<String> followerIds = const [],
        List<String> followingIds = const [],
        List<int> topThreeGames = const [],
      }) {
    return UserModel(
      id: profileData['id'] as String,
      username: profileData['username'] as String? ?? '',
      email: profileData['email'] as String? ?? '',
      avatarUrl: profileData['avatar_url'] as String?,
      bio: profileData['bio'] as String?,
      country: profileData['country'] as String?,
      createdAt: profileData['created_at'] != null
          ? DateTime.parse(profileData['created_at'] as String)
          : DateTime.now(),
      wishlistGameIds: wishlistIds,
      recommendedGameIds: recommendedIds,
      gameRatings: ratings,
      topThreeGames: topThreeGames,
      followingIds: followingIds,
      followerIds: followerIds,
      totalGamesRated: ratings.length,
    );
  }

  // Create UserModel from JSON (for caching)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      avatarUrl: json['avatar_url'] as String?,
      bio: json['bio'] as String?,
      country: json['country'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      wishlistGameIds: (json['wishlist_game_ids'] as List<dynamic>?)
          ?.map((id) => id as int)
          .toList() ??
          [],
      recommendedGameIds: (json['recommended_game_ids'] as List<dynamic>?)
          ?.map((id) => id as int)
          .toList() ??
          [],
      gameRatings: _parseGameRatings(json['game_ratings']),
      topThreeGames: (json['top_three_games'] as List<dynamic>?)
          ?.map((id) => id as int)
          .toList() ??
          [],
      followingIds: (json['following_ids'] as List<dynamic>?)
          ?.map((id) => id as String)
          .toList() ??
          [],
      followerIds: (json['follower_ids'] as List<dynamic>?)
          ?.map((id) => id as String)
          .toList() ??
          [],
      totalGamesRated: json['total_games_rated'] as int? ?? 0,
    );
  }

  // Convert to JSON (for caching)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'avatar_url': avatarUrl,
      'bio': bio,
      'country': country,
      'created_at': createdAt.toIso8601String(),
      'wishlist_game_ids': wishlistGameIds,
      'recommended_game_ids': recommendedGameIds,
      'game_ratings': _gameRatingsToJson(),
      'top_three_games': topThreeGames,
      'following_ids': followingIds,
      'follower_ids': followerIds,
      'total_games_rated': totalGamesRated,
    };
  }

  // Convert to Supabase format for updates
  Map<String, dynamic> toSupabaseUpdate() {
    final Map<String, dynamic> data = {};

    if (username.isNotEmpty) data['username'] = username;
    if (bio != null) data['bio'] = bio;
    if (avatarUrl != null) data['avatar_url'] = avatarUrl;
    if (country != null) data['country'] = country;

    return data;
  }

  // Helper method to parse game ratings from JSON
  static Map<int, double> _parseGameRatings(dynamic ratingsData) {
    if (ratingsData is Map<String, dynamic>) {
      return ratingsData.map((key, value) => MapEntry(
        int.parse(key),
        (value as num).toDouble(),
      ));
    }
    return {};
  }

  // Helper method to convert game ratings to JSON
  Map<String, dynamic> _gameRatingsToJson() {
    return gameRatings.map((key, value) => MapEntry(key.toString(), value));
  }

  // Create a copy with updated fields
  UserModel copyWith({
    String? id,
    String? username,
    String? email,
    String? avatarUrl,
    String? bio,
    String? country,
    DateTime? createdAt,
    List<int>? wishlistGameIds,
    List<int>? recommendedGameIds,
    Map<int, double>? gameRatings,
    List<int>? topThreeGames,
    List<String>? followingIds,
    List<String>? followerIds,
    int? totalGamesRated,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      country: country ?? this.country,
      createdAt: createdAt ?? this.createdAt,
      wishlistGameIds: wishlistGameIds ?? this.wishlistGameIds,
      recommendedGameIds: recommendedGameIds ?? this.recommendedGameIds,
      gameRatings: gameRatings ?? this.gameRatings,
      topThreeGames: topThreeGames ?? this.topThreeGames,
      followingIds: followingIds ?? this.followingIds,
      followerIds: followerIds ?? this.followerIds,
      totalGamesRated: totalGamesRated ?? this.totalGamesRated,
    );
  }

  // Helper getters for UI
  bool get hasAvatar => avatarUrl != null && avatarUrl!.isNotEmpty;
  bool get hasBio => bio != null && bio!.isNotEmpty;
  bool get hasCountry => country != null && country!.isNotEmpty;

  String get displayName => username.isNotEmpty ? username : email;
  String get initials => username.isNotEmpty
      ? username.substring(0, 1).toUpperCase()
      : email.substring(0, 1).toUpperCase();

  int get followersCount => followerIds.length;
  int get followingCount => followingIds.length;
  int get wishlistCount => wishlistGameIds.length;
  int get recommendedCount => recommendedGameIds.length;

  bool isFollowing(String userId) => followingIds.contains(userId);
  bool isFollowedBy(String userId) => followerIds.contains(userId);
  bool hasGameInWishlist(int gameId) => wishlistGameIds.contains(gameId);
  bool hasGameRecommended(int gameId) => recommendedGameIds.contains(gameId);
  bool hasRatedGame(int gameId) => gameRatings.containsKey(gameId);

  double? getGameRating(int gameId) => gameRatings[gameId];

  double get averageRating {
    if (gameRatings.isEmpty) return 0.0;
    final sum = gameRatings.values.reduce((a, b) => a + b);
    return sum / gameRatings.length;
  }
}