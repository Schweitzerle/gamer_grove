// ==========================================

// lib/domain/usecases/user_collections/get_user_recommended_games_with_filters.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/errors/failures.dart';
import '../../entities/game/game.dart';
import '../../entities/user/user_collection_filters.dart';
import '../../repositories/game_repository.dart';
import '../base_usecase.dart';

class GetUserRecommendedGamesWithFilters extends UseCase<List<Game>, GetUserRecommendedGamesWithFiltersParams> {
  final GameRepository repository;

  GetUserRecommendedGamesWithFilters(this.repository);

  @override
  Future<Either<Failure, List<Game>>> call(GetUserRecommendedGamesWithFiltersParams params) async {
    if (params.userId.isEmpty) {
      return const Left(ValidationFailure(message: 'User ID cannot be empty'));
    }

    return await repository.getUserRecommendedGamesWithFilters(
      userId: params.userId,
      filters: params.filters,
      limit: params.limit,
      offset: params.offset,
    );
  }
}

class GetUserRecommendedGamesWithFiltersParams extends Equatable {
  final String userId;
  final UserCollectionFilters filters;
  final int limit;
  final int offset;

  const GetUserRecommendedGamesWithFiltersParams({
    required this.userId,
    required this.filters,
    this.limit = 20,
    this.offset = 0,
  });

  @override
  List<Object> get props => [userId, filters, limit, offset];
}

