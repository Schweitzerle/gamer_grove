// ============================================================
// RATE GAME USE CASE
// ============================================================

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import 'package:gamer_grove/data/repositories/user_repository_impl.dart';
import 'package:gamer_grove/domain/usecases/usecase.dart';

/// Use case for rating a game.
///
/// NOTE: This use case requires UserRepositoryImpl as it uses implementation-specific methods.
///
/// Example:
/// ```dart
/// final useCase = RateGameUseCase(userRepository);
/// final result = await useCase(RateGameParams(
///   userId: 'uuid',
///   gameId: 1942,
///   rating: 9.5,
/// ));
///
/// result.fold(
/// );
/// ```
class RateGameUseCase implements UseCase<void, RateGameParams> {

  RateGameUseCase(this.repository);
  final UserRepositoryImpl repository;

  @override
  Future<Either<Failure, void>> call(RateGameParams params) async {
    // Validate rating range
    if (params.rating < 0.0 || params.rating > 10.0) {
      return const Left(ValidationFailure(
        message: 'Rating must be between 0.0 and 10.0',
      ),);
    }

    return repository.rateGame(
      params.userId,
      params.gameId,
      params.rating,
    );
  }
}

class RateGameParams extends Equatable {

  const RateGameParams({
    required this.userId,
    required this.gameId,
    required this.rating,
  });
  final String userId;
  final int gameId;
  final double rating;

  @override
  List<Object> get props => [userId, gameId, rating];
}
