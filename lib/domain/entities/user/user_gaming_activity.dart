// 1. Entity ändern:
// lib/domain/entities/user/user_gaming_activity.dart
import 'package:equatable/equatable.dart';

class UserGamingActivity extends Equatable { // <- Game ID statt DateTime

  const UserGamingActivity({
    this.gamesRatedThisMonth = 0,
    this.gamesAddedToWishlistThisMonth = 0,
    this.gamesRecommendedThisMonth = 0,
    this.genreBreakdown = const {},
    this.platformBreakdown = const {},
    this.lastRatedGameId,
    this.lastAddedToWishlistId,
    this.lastRecommendedGameId,
  });
  final int gamesRatedThisMonth;
  final int gamesAddedToWishlistThisMonth;
  final int gamesRecommendedThisMonth;
  final Map<String, int> genreBreakdown;
  final Map<String, int> platformBreakdown;

  // ✅ ÄNDERN zu game IDs statt timestamps
  final int? lastRatedGameId;      // <- Game ID statt DateTime
  final int? lastAddedToWishlistId; // <- Game ID statt DateTime
  final int? lastRecommendedGameId;

  @override
  List<Object?> get props => [
    gamesRatedThisMonth, gamesAddedToWishlistThisMonth, gamesRecommendedThisMonth,
    genreBreakdown, platformBreakdown,
    lastRatedGameId, lastAddedToWishlistId, lastRecommendedGameId,
  ];
}

