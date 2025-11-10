// lib/domain/usecases/collection/get_recommended_games_use_case.dart

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import '../../repositories/user_repository.dart';
import '../usecase.dart';

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
///   (failure) => print('Error: ${failure.message}'),
///   (gameIds) => print('Recommended games: $gameIds'),
/// );
/// ```
class GetRecommendedGamesUseCase
    implements UseCase<List<int>, GetRecommendedGamesParams> {
  final UserRepository repository;

  GetRecommendedGamesUseCase(this.repository);

  @override
  Future<Either<Failure, List<int>>> call(
    GetRecommendedGamesParams params,
  ) async {
    return await repository.getRecommendedGames(params.userId);
  }
}

class GetRecommendedGamesParams extends Equatable {
  final String userId;

  const GetRecommendedGamesParams({required this.userId});

  @override
  List<Object> get props => [userId];
}
