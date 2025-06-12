// domain/entities/user.dart
import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String username;
  final String email;
  final String? avatarUrl;
  final String? bio;
  final String? country;
  final DateTime createdAt;
  final List<int> wishlistGameIds;
  final List<int> recommendedGameIds;
  final Map<int, double> gameRatings; // gameId -> rating
  final List<int> topThreeGames;
  final List<String> followingIds;
  final List<String> followerIds;
  final int totalGamesRated;

  const User({
    required this.id,
    required this.username,
    required this.email,
    this.avatarUrl,
    this.bio,
    this.country,
    required this.createdAt,
    this.wishlistGameIds = const [],
    this.recommendedGameIds = const [],
    this.gameRatings = const {},
    this.topThreeGames = const [],
    this.followingIds = const [],
    this.followerIds = const [],
    this.totalGamesRated = 0,
  });

  @override
  List<Object?> get props => [
    id,
    username,
    email,
    avatarUrl,
    bio,
    country,
    createdAt,
    wishlistGameIds,
    recommendedGameIds,
    gameRatings,
    topThreeGames,
    followingIds,
    followerIds,
    totalGamesRated,
  ];
}

