// ==========================================

// lib/domain/entities/user/user_gaming_activity.dart
import 'package:equatable/equatable.dart';

class UserGamingActivity extends Equatable {
  final int gamesRatedThisMonth;
  final int gamesAddedToWishlistThisMonth;
  final int gamesRecommendedThisMonth;
  final Map<String, int> genreBreakdown; // Genre name -> count
  final Map<String, int> platformBreakdown; // Platform name -> count
  final DateTime? lastRatedGame;
  final DateTime? lastAddedToWishlist;
  final DateTime? lastRecommendedGame;

  const UserGamingActivity({
    this.gamesRatedThisMonth = 0,
    this.gamesAddedToWishlistThisMonth = 0,
    this.gamesRecommendedThisMonth = 0,
    this.genreBreakdown = const {},
    this.platformBreakdown = const {},
    this.lastRatedGame,
    this.lastAddedToWishlist,
    this.lastRecommendedGame,
  });

  // Helper getters
  bool get isActiveThisMonth => gamesRatedThisMonth > 0 ||
      gamesAddedToWishlistThisMonth > 0 ||
      gamesRecommendedThisMonth > 0;

  String? get favoriteGenre => genreBreakdown.isNotEmpty
      ? genreBreakdown.entries.reduce((a, b) => a.value > b.value ? a : b).key
      : null;

  String? get favoritePlatform => platformBreakdown.isNotEmpty
      ? platformBreakdown.entries.reduce((a, b) => a.value > b.value ? a : b).key
      : null;

  @override
  List<Object?> get props => [
    gamesRatedThisMonth, gamesAddedToWishlistThisMonth, gamesRecommendedThisMonth,
    genreBreakdown, platformBreakdown,
    lastRatedGame, lastAddedToWishlist, lastRecommendedGame,
  ];
}

