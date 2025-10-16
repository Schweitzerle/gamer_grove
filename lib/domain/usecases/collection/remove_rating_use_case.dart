// ============================================================
// REMOVE RATING USE CASE
// ============================================================

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import '../../../data/repositories/user_repository_impl.dart';
import '../usecase.dart';

/// Use case for removing a game rating.
///
/// NOTE: This use case requires UserRepositoryImpl as it uses implementation-specific methods.
///
/// Example:
/// ```dart
/// final useCase = RemoveRatingUseCase(userRepository);
/// final result = await useCase(RemoveRatingParams(
///   userId: 'uuid',
///   gameId: 1942,
/// ));
/// ```
class RemoveRatingUseCase implements UseCase<void, RemoveRatingParams> {
  final UserRepositoryImpl repository;

  RemoveRatingUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(RemoveRatingParams params) async {
    return await repository.removeRating(params.userId, params.gameId);
  }
}

class RemoveRatingParams extends Equatable {
  final String userId;
  final int gameId;

  const RemoveRatingParams({
    required this.userId,
    required this.gameId,
  });

  @override
  List<Object> get props => [userId, gameId];
}
