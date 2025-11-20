// ==========================================
// USER GAMING ACTIVITY MODEL
// ==========================================

// lib/data/models/user_gaming_activity_model.dart
import 'package:gamer_grove/domain/entities/user/user_gaming_activity.dart';

// 2. Model anpassen:
class UserGamingActivityModel extends UserGamingActivity {
  const UserGamingActivityModel({
    super.gamesRatedThisMonth,
    super.gamesAddedToWishlistThisMonth,
    super.gamesRecommendedThisMonth,
    super.genreBreakdown,
    super.platformBreakdown,
    super.lastRatedGameId,      // ✅ Geändert
    super.lastAddedToWishlistId, // ✅ Geändert
    super.lastRecommendedGameId, // ✅ Geändert
  });

  factory UserGamingActivityModel.fromJson(Map<String, dynamic> json) {
    return UserGamingActivityModel(
      gamesRatedThisMonth: json['games_rated_this_month'] as int? ?? 0,
      gamesAddedToWishlistThisMonth: json['games_added_to_wishlist_this_month'] as int? ?? 0,
      gamesRecommendedThisMonth: json['games_recommended_this_month'] as int? ?? 0,
      genreBreakdown: Map<String, int>.from(json['genre_breakdown'] ?? {}),
      platformBreakdown: Map<String, int>.from(json['platform_breakdown'] ?? {}),
      lastRatedGameId: json['last_rated_game'] as int?,          // ✅ FIX
      lastAddedToWishlistId: json['last_added_to_wishlist'] as int?, // ✅ FIX
      lastRecommendedGameId: json['last_recommended_game'] as int?,   // ✅ FIX
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