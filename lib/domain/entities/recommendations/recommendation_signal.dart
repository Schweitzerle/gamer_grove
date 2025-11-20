// ==========================================

// lib/domain/entities/recommendations/recommendation_signal.dart
enum RecommendationSignal {
  ratings('ratings', 'User Ratings', "Based on games you've rated highly"),
  wishlist('wishlist', 'Wishlist', 'Based on games in your wishlist'),
  genres('genres', 'Preferred Genres', 'Based on your favorite genres'),
  platforms('platforms', 'Platform Usage', 'Based on your platform preferences'),
  playtime('playtime', 'Play Patterns', 'Based on your gaming patterns'),
  friends('friends', 'Friends Activity', 'Based on what friends are playing'),
  community('community', 'Community Trends', 'Based on community preferences'),
  similarity('similarity', 'Similar Games', 'Based on games you like'),
  newReleases('new_releases', 'New Releases', 'Based on recent game releases'),
  critics('critics', 'Critical Acclaim', 'Based on critically acclaimed games');

  const RecommendationSignal(this.value, this.displayName, this.description);
  final String value;
  final String displayName;
  final String description;
}

