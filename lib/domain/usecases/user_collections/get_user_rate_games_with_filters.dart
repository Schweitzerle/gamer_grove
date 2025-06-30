// ==========================================

// lib/domain/usecases/user_collections/get_user_rated_games_with_filters.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/errors/failures.dart';
import '../../entities/game/game.dart';
import '../../entities/user/user_collection_filters.dart';
import '../../repositories/game_repository.dart';
import '../base_usecase.dart';

class GetUserRatedGamesWithFilters extends UseCase<List<Game>, GetUserRatedGamesWithFiltersParams> {
  final GameRepository repository;

  GetUserRatedGamesWithFilters(this.repository);

  @override
  Future<Either<Failure, List<Game>>> call(GetUserRatedGamesWithFiltersParams params) async {
    if (params.userId.isEmpty) {
      return const Left(ValidationFailure(message: 'User ID cannot be empty'));
    }

    return await repository.getUserRatedGamesWithFilters(
      userId: params.userId,
      filters: params.filters,
      limit: params.limit,
      offset: params.offset,
    );
  }
}

class GetUserRatedGamesWithFiltersParams extends Equatable {
  final String userId;
  final UserCollectionFilters filters;
  final int limit;
  final int offset;

  const GetUserRatedGamesWithFiltersParams({
    required this.userId,
    required this.filters,
    this.limit = 20,
    this.offset = 0,
  });

  @override
  List<Object> get props => [userId, filters, limit, offset];
}

