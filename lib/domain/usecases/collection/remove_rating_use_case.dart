// ============================================================
// REMOVE RATING USE CASE
// ============================================================

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import 'package:gamer_grove/data/repositories/user_repository_impl.dart';
import 'package:gamer_grove/domain/usecases/usecase.dart';

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

  RemoveRatingUseCase(this.repository);
  final UserRepositoryImpl repository;

  @override
  Future<Either<Failure, void>> call(RemoveRatingParams params) async {
    return repository.removeRating(params.userId, params.gameId);
  }
}

class RemoveRatingParams extends Equatable {

  const RemoveRatingParams({
    required this.userId,
    required this.gameId,
  });
  final String userId;
  final int gameId;

  @override
  List<Object> get props => [userId, gameId];
}
