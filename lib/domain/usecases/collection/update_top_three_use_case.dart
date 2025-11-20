// ============================================================
// UPDATE TOP THREE USE CASE
// ============================================================

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import 'package:gamer_grove/domain/repositories/user_repository.dart';
import 'package:gamer_grove/domain/usecases/usecase.dart';

/// Use case for updating user's top 3 games.
///
/// Example:
/// ```dart
/// final useCase = UpdateTopThreeUseCase(userRepository);
/// final result = await useCase(UpdateTopThreeParams(
///   userId: 'uuid',
///   gameIds: [1942, 1905, 113],
/// ));
///
/// result.fold(
/// );
/// ```
class UpdateTopThreeUseCase implements UseCase<void, UpdateTopThreeParams> {

  UpdateTopThreeUseCase(this.repository);
  final UserRepository repository;

  @override
  Future<Either<Failure, void>> call(UpdateTopThreeParams params) async {
    // Validate exactly 3 games
    if (params.gameIds.length != 3) {
      return const Left(ValidationFailure(
        message: 'You must provide exactly 3 games',
      ),);
    }

    // Validate all games are different
    if (params.gameIds.toSet().length != 3) {
      return const Left(ValidationFailure(
        message: 'All 3 games must be different',
      ),);
    }

    return repository.updateTopThreeGames(
      userId: params.userId,
      gameIds: params.gameIds,
    );
  }
}

class UpdateTopThreeParams extends Equatable {

  const UpdateTopThreeParams({
    required this.userId,
    required this.gameIds,
  });
  final String userId;
  final List<int> gameIds;

  @override
  List<Object> get props => [userId, gameIds];
}
