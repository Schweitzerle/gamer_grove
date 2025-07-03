// ==========================================

// lib/domain/usecases/recommendations/get_comprehensive_discovery_data.dart
// Composite Use Case for Discovery page
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/errors/failures.dart';
import '../../entities/game/game.dart';
import '../../entities/recommendations/genre_trend.dart';
import '../../entities/recommendations/discovery_challenge.dart';
import '../../entities/recommendations/seasons.dart';
import '../base_usecase.dart';
import '../discovery/get_dicovery_challenges.dart';
import 'get_personalized_recommendations.dart';
import 'get_ai_recommendations.dart';
import '../trends/get_trending_games.dart';
import '../trends/get_genre_trends.dart';
import '../discovery/get_hidden_gems.dart';
import '../discovery/get_seasonal_recommendations.dart';

class GetComprehensiveDiscoveryData extends UseCase<DiscoveryPageData, GetComprehensiveDiscoveryDataParams> {
  final GetPersonalizedRecommendations getPersonalizedRecommendations;
  final GetTrendingGames getTrendingGames;
  final GetGenreTrends getGenreTrends;
  final GetHiddenGems getHiddenGems;
  final GetSeasonalRecommendations getSeasonalRecommendations;
  final GetDiscoveryChallenges getDiscoveryChallenges;

  GetComprehensiveDiscoveryData({
    required this.getPersonalizedRecommendations,
    required this.getTrendingGames,
    required this.getGenreTrends,
    required this.getHiddenGems,
    required this.getSeasonalRecommendations,
    required this.getDiscoveryChallenges,
  });

  @override
  Future<Either<Failure, DiscoveryPageData>> call(GetComprehensiveDiscoveryDataParams params) async {
    try {
      // Method 1: Sequential execution (simpler, no casting issues)

      // Get personalized recommendations
      List<Game> personalizedRecommendations = [];
      if (params.userId != null) {
        final result = await getPersonalizedRecommendations(GetPersonalizedRecommendationsParams(
          userId: params.userId!,
          limit: 10,
        ));
        personalizedRecommendations = result.fold((l) => <Game>[], (r) => r);
      }

      // Get discovery challenges
      List<DiscoveryChallenge> discoveryChallenges = [];
      if (params.userId != null) {
        final result = await getDiscoveryChallenges(GetDiscoveryChallengesParams(userId: params.userId!));
        discoveryChallenges = result.fold((l) => <DiscoveryChallenge>[], (r) => r);
      }

      // Get trending games
      final trendingResult = await getTrendingGames(GetTrendingGamesParams.lastWeek(limit: 15));
      final trendingGames = trendingResult.fold((l) => <Game>[], (r) => r);

      // Get genre trends
      final genreTrendsResult = await getGenreTrends(GetGenreTrendsParams.lastMonth(limit: 10));
      final genreTrends = genreTrendsResult.fold((l) => <GenreTrend>[], (r) => r);

      // Get hidden gems
      final hiddenGemsResult = await getHiddenGems(const GetHiddenGemsParams(limit: 12));
      final hiddenGems = hiddenGemsResult.fold((l) => <Game>[], (r) => r);

      // Get seasonal recommendations
      final seasonalResult = await getSeasonalRecommendations(GetSeasonalRecommendationsParams.current(limit: 10));
      final seasonalRecommendations = seasonalResult.fold((l) => <Game>[], (r) => r);

      return Right(DiscoveryPageData(
        personalizedRecommendations: personalizedRecommendations,
        trendingGames: trendingGames,
        genreTrends: genreTrends,
        hiddenGems: hiddenGems,
        seasonalRecommendations: seasonalRecommendations,
        discoveryChallenges: discoveryChallenges,
        currentSeason: Season.getCurrentSeason(),
      ));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to load discovery data: $e'));
    }
  }
}

class GetComprehensiveDiscoveryDataParams extends Equatable {
  final String? userId; // nullable for non-authenticated users

  const GetComprehensiveDiscoveryDataParams({this.userId});

  @override
  List<Object?> get props => [userId];
}

class DiscoveryPageData extends Equatable {
  final List<Game> personalizedRecommendations;
  final List<Game> trendingGames;
  final List<GenreTrend> genreTrends;
  final List<Game> hiddenGems;
  final List<Game> seasonalRecommendations;
  final List<DiscoveryChallenge> discoveryChallenges;
  final Season currentSeason;

  const DiscoveryPageData({
    required this.personalizedRecommendations,
    required this.trendingGames,
    required this.genreTrends,
    required this.hiddenGems,
    required this.seasonalRecommendations,
    required this.discoveryChallenges,
    required this.currentSeason,
  });

  // Helper getters
  bool get hasPersonalizedRecommendations => personalizedRecommendations.isNotEmpty;
  bool get hasTrendingGames => trendingGames.isNotEmpty;
  bool get hasGenreTrends => genreTrends.isNotEmpty;
  bool get hasHiddenGems => hiddenGems.isNotEmpty;
  bool get hasSeasonalRecommendations => seasonalRecommendations.isNotEmpty;
  bool get hasDiscoveryChallenges => discoveryChallenges.isNotEmpty;

  GenreTrend? get hottestGenre => genreTrends.isNotEmpty
      ? genreTrends.reduce((a, b) => a.trendScore > b.trendScore ? a : b)
      : null;

  @override
  List<Object> get props => [
    personalizedRecommendations,
    trendingGames,
    genreTrends,
    hiddenGems,
    seasonalRecommendations,
    discoveryChallenges,
    currentSeason,
  ];
}