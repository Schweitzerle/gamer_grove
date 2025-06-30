// ==========================================

// lib/domain/usecases/recommendations/get_ai_recommendations.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/errors/failures.dart';
import '../../entities/game/game.dart';
import '../../entities/recommendations/recommendation_signal.dart';
import '../../repositories/game_repository.dart';
import '../base_usecase.dart';

class GetAIRecommendations extends UseCase<List<Game>, GetAIRecommendationsParams> {
  final GameRepository repository;

  GetAIRecommendations(this.repository);

  @override
  Future<Either<Failure, List<Game>>> call(GetAIRecommendationsParams params) async {
    if (params.userId.isEmpty) {
      return const Left(ValidationFailure(message: 'User ID cannot be empty'));
    }

    if (params.signals.isEmpty) {
      return const Left(ValidationFailure(message: 'At least one recommendation signal required'));
    }

    return await repository.getAIRecommendations(
      userId: params.userId,
      limit: params.limit,
      signals: params.signals,
    );
  }
}

class GetAIRecommendationsParams extends Equatable {
  final String userId;
  final int limit;
  final List<RecommendationSignal> signals;

  const GetAIRecommendationsParams({
    required this.userId,
    this.limit = 20,
    this.signals = const [
      RecommendationSignal.ratings,
      RecommendationSignal.wishlist,
      RecommendationSignal.genres,
      RecommendationSignal.platforms,
    ],
  });

  // Predefined signal combinations for different use cases
  GetAIRecommendationsParams.comprehensive({
    required this.userId,
    this.limit = 20,
  }) : signals = RecommendationSignal.values;

  GetAIRecommendationsParams.basicPreferences({
    required this.userId,
    this.limit = 20,
  }) : signals = const [
    RecommendationSignal.ratings,
    RecommendationSignal.genres,
    RecommendationSignal.platforms,
  ];

  GetAIRecommendationsParams.socialBased({
    required this.userId,
    this.limit = 20,
  }) : signals = const [
    RecommendationSignal.friends,
    RecommendationSignal.community,
    RecommendationSignal.similarity,
  ];

  @override
  List<Object> get props => [userId, limit, signals];
}