// lib/domain/entities/user/user_collection_summary.dart
import 'package:equatable/equatable.dart';
import 'package:gamer_grove/domain/entities/user/user_collection_sort_options.dart';

class UserCollectionSummary extends Equatable {

  const UserCollectionSummary({
    required this.type,
    required this.totalCount,
    this.averageRating,
    this.averageGameRating,
    this.genreBreakdown = const {},
    this.platformBreakdown = const {},
    this.yearBreakdown = const {},
    this.recentlyAddedCount = 0,
    this.lastUpdated,
  });
  final UserCollectionType type;
  final int totalCount;
  final double? averageRating; // User's average rating for rated games
  final double? averageGameRating; // Average game rating in collection
  final Map<String, int> genreBreakdown; // Genre name -> count
  final Map<String, int> platformBreakdown; // Platform name -> count
  final Map<int, int> yearBreakdown; // Year -> count
  final int recentlyAddedCount; // Added in last 30 days
  final DateTime? lastUpdated;

  // Helper getters
  String get mostPlayedGenre =>
      genreBreakdown.isNotEmpty
          ? genreBreakdown.entries.reduce((a, b) => a.value > b.value ? a : b).key
          : 'Unknown';

  String get mostUsedPlatform =>
      platformBreakdown.isNotEmpty
          ? platformBreakdown.entries.reduce((a, b) => a.value > b.value ? a : b).key
          : 'Unknown';

  int get mostActiveYear =>
      yearBreakdown.isNotEmpty
          ? yearBreakdown.entries.reduce((a, b) => a.value > b.value ? a : b).key
          : DateTime.now().year;

  bool get hasRecentActivity => recentlyAddedCount > 0;

  @override
  List<Object?> get props => [
    type,
    totalCount,
    averageRating,
    averageGameRating,
    genreBreakdown,
    platformBreakdown,
    yearBreakdown,
    recentlyAddedCount,
    lastUpdated,
  ];
}