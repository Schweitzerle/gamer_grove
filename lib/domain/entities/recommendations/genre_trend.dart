// ==========================================

// lib/domain/entities/recommendations/genre_trend.dart
import 'package:equatable/equatable.dart';

class GenreTrend extends Equatable {
  final int genreId;
  final String genreName;
  final double trendScore; // How trending this genre is (0-100)
  final double growthRate; // Percentage growth in popularity
  final int gameCount; // Number of games in this genre
  final double averageRating; // Average rating of games in genre
  final DateTime? calculatedAt;

  const GenreTrend({
    required this.genreId,
    required this.genreName,
    required this.trendScore,
    required this.growthRate,
    required this.gameCount,
    required this.averageRating,
    this.calculatedAt,
  });

  bool get isRising => growthRate > 10.0;
  bool get isHot => trendScore > 75.0;
  bool get isPopular => gameCount > 100;

  @override
  List<Object?> get props => [
    genreId, genreName, trendScore, growthRate,
    gameCount, averageRating, calculatedAt
  ];
}

