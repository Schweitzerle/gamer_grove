// lib/domain/usecases/collection/get_recommended_games_use_case.dart

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import 'package:gamer_grove/domain/repositories/user_repository.dart';
import 'package:gamer_grove/domain/usecases/usecase.dart';

/// Use case for getting user's recommended game IDs.
///
/// Returns a list of game IDs that the user has recommended.
///
/// Example:
/// ```dart
/// final useCase = GetRecommendedGamesUseCase(userRepository);
/// final result = await useCase(GetRecommendedGamesParams(userId: 'uuid'));
///
/// result.fold(
/// );
/// ```
class GetRecommendedGamesUseCase
    implements UseCase<List<int>, GetRecommendedGamesParams> {

  GetRecommendedGamesUseCase(this.repository);
  final UserRepository repository;

  @override
  Future<Either<Failure, List<int>>> call(
    GetRecommendedGamesParams params,
  ) async {
    return repository.getRecommendedGames(
      params.userId,
      limit: params.limit,
      offset: params.offset,
    );
  }
}

class GetRecommendedGamesParams extends Equatable {

  const GetRecommendedGamesParams({
    required this.userId,
    this.limit,
    this.offset,
  });
  final String userId;
  final int? limit;
  final int? offset;

  @override
  List<Object?> get props => [userId, limit, offset];
}
