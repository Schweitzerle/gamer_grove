// ==========================================

// lib/domain/usecases/discovery/get_seasonal_recommendations.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/errors/failures.dart';
import '../../entities/game/game.dart';
import '../../entities/recommendations/seasons.dart';
import '../../repositories/game_repository.dart';
import '../base_usecase.dart';

class GetSeasonalRecommendations extends UseCase<List<Game>, GetSeasonalRecommendationsParams> {
  final GameRepository repository;

  GetSeasonalRecommendations(this.repository);

  @override
  Future<Either<Failure, List<Game>>> call(GetSeasonalRecommendationsParams params) async {
    return await repository.getSeasonalRecommendations(
      season: params.season,
      limit: params.limit,
    );
  }
}

class GetSeasonalRecommendationsParams extends Equatable {
  final Season season;
  final int limit;

  const GetSeasonalRecommendationsParams({
    required this.season,
    this.limit = 20,
  });

  // Current season constructor
  GetSeasonalRecommendationsParams.current({this.limit = 20})
      : season = Season.getCurrentSeason();

  @override
  List<Object> get props => [season, limit];
}