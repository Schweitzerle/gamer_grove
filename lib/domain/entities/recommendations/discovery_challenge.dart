// ==========================================

// lib/domain/entities/recommendations/discovery_challenge.dart
import 'package:equatable/equatable.dart';

class DiscoveryChallenge extends Equatable {

  const DiscoveryChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.requirements,
    required this.recommendedGameIds,
    required this.rewardPoints,
    this.expiresAt,
    this.isCompleted = false,
  });
  final String id;
  final String title;
  final String description;
  final DiscoveryChallengeType type;
  final Map<String, dynamic> requirements;
  final List<int> recommendedGameIds;
  final int rewardPoints;
  final DateTime? expiresAt;
  final bool isCompleted;

  @override
  List<Object?> get props => [
    id, title, description, type, requirements,
    recommendedGameIds, rewardPoints, expiresAt, isCompleted,
  ];
}

enum DiscoveryChallengeType {
  exploreGenre('explore_genre', 'Genre Explorer'),
  tryPlatform('try_platform', 'Platform Pioneer'),
  playClassic('play_classic', 'Retro Gamer'),
  discoverIndie('discover_indie', 'Indie Supporter'),
  completeSeries('complete_series', 'Series Completionist'),
  diversifyRatings('diversify_ratings', 'Diverse Critic');

  const DiscoveryChallengeType(this.value, this.displayName);
  final String value;
  final String displayName;
}