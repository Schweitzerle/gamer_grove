// ==========================================

// lib/domain/entities/recommendations/platform_trend.dart
import 'package:equatable/equatable.dart';

class PlatformTrend extends Equatable {
  final int platformId;
  final String platformName;
  final double trendScore;
  final double adoptionRate;
  final int gameCount;
  final double averageRating;
  final DateTime? calculatedAt;

  const PlatformTrend({
    required this.platformId,
    required this.platformName,
    required this.trendScore,
    required this.adoptionRate,
    required this.gameCount,
    required this.averageRating,
    this.calculatedAt,
  });

  bool get isGrowing => adoptionRate > 5.0;
  bool get isTrending => trendScore > 70.0;

  @override
  List<Object?> get props => [
    platformId, platformName, trendScore, adoptionRate,
    gameCount, averageRating, calculatedAt
  ];
}

