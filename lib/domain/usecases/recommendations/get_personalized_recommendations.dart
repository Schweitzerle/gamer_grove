// ==========================================
// PHASE 5 USE CASES FOR ADVANCED FEATURES & RECOMMENDATIONS
// ==========================================

// lib/domain/usecases/recommendations/get_personalized_recommendations.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/errors/failures.dart';
import '../../entities/game/game.dart';
import '../../repositories/game_repository.dart';
import '../base_usecase.dart';

class GetPersonalizedRecommendations extends UseCase<List<Game>, GetPersonalizedRecommendationsParams> {
  final GameRepository repository;

  GetPersonalizedRecommendations(this.repository);

  @override
  Future<Either<Failure, List<Game>>> call(GetPersonalizedRecommendationsParams params) async {
    if (params.userId.isEmpty) {
      return const Left(ValidationFailure(message: 'User ID cannot be empty'));
    }

    return await repository.getPersonalizedRecommendations(
      userId: params.userId,
      limit: params.limit,
      offset: params.offset,
    );
  }
}

class GetPersonalizedRecommendationsParams extends Equatable {
  final String userId;
  final int limit;
  final int offset;

  const GetPersonalizedRecommendationsParams({
    required this.userId,
    this.limit = 20,
    this.offset = 0,
  });

  @override
  List<Object> get props => [userId, limit, offset];
}
