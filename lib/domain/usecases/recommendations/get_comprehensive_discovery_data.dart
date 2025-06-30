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
      // Execute all discovery requests concurrently
      final results = await Future.wait([
        if (params.userId != null) ...[
          getPersonalizedRecommendations(GetPersonalizedRecommendationsParams(
            userId: params.userId!,
            limit: 10,
          )),
          getDiscoveryChallenges(GetDiscoveryChallengesParams(userId: params.userId!)),
        ] else ...[
          Future.value(const Right(<Game>[])),
          Future.value(const Right(<DiscoveryChallenge>[])),
        ],
        getTrendingGames(GetTrendingGamesParams.lastWeek(limit: 15)),
        getGenreTrends(GetGenreTrendsParams.lastMonth(limit: 10)),
        getHiddenGems(const GetHiddenGemsParams(limit: 12)),
        getSeasonalRecommendations(GetSeasonalRecommendationsParams.current(limit: 10)),
      ]);

      // Check if any request failed
      for (final result in results) {
        if (result.isLeft()) {
          return result.fold(
                (failure) => Left(failure),
                (data) => throw Exception('Unexpected success in fold'),
          );
        }
      }

      // Extract successful results
      final personalizedRecommendations = results[0].fold((l) => <Game>[], (r) => r as List<Game>);
      final discoveryChallenges = results[1].fold((l) => <DiscoveryChallenge>[], (r) => r as List<DiscoveryChallenge>);
      final trendingGames = results[2].fold((l) => <Game>[], (r) => r as List<Game>);
      final genreTrends = results[3].fold((l) => <GenreTrend>[], (r) => r as List<GenreTrend>);
      final hiddenGems = results[4].fold((l) => <Game>[], (r) => r as List<Game>);
      final seasonalRecommendations = results[5].fold((l) => <Game>[], (r) => r as List<Game>);

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