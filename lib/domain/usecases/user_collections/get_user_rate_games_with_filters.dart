// ==========================================

// lib/domain/usecases/user_collections/get_user_rated_games_with_filters.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import 'package:gamer_grove/domain/entities/game/game.dart';
import 'package:gamer_grove/domain/entities/user/user_collection_filters.dart';
import 'package:gamer_grove/domain/repositories/game_repository.dart';
import 'package:gamer_grove/domain/usecases/base_usecase.dart';

class GetUserRatedGamesWithFilters extends UseCase<List<Game>, GetUserRatedGamesWithFiltersParams> {

  GetUserRatedGamesWithFilters(this.repository);
  final GameRepository repository;

  @override
  Future<Either<Failure, List<Game>>> call(GetUserRatedGamesWithFiltersParams params) async {
    if (params.userId.isEmpty) {
      return const Left(ValidationFailure(message: 'User ID cannot be empty'));
    }

    return repository.getUserRatedGamesWithFilters(
      userId: params.userId,
      filters: params.filters,
      limit: params.limit,
      offset: params.offset,
    );
  }
}

class GetUserRatedGamesWithFiltersParams extends Equatable {

  const GetUserRatedGamesWithFiltersParams({
    required this.userId,
    required this.filters,
    this.limit = 20,
    this.offset = 0,
  });
  final String userId;
  final UserCollectionFilters filters;
  final int limit;
  final int offset;

  @override
  List<Object> get props => [userId, filters, limit, offset];
}

