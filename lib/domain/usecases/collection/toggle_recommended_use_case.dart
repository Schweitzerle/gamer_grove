// ============================================================
// TOGGLE RECOMMENDED USE CASE
// ============================================================

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import 'package:gamer_grove/data/repositories/user_repository_impl.dart';
import 'package:gamer_grove/domain/usecases/usecase.dart';

/// Use case for toggling a game in recommended list.
///
/// NOTE: This use case requires UserRepositoryImpl as it uses implementation-specific methods.
///
/// Example:
/// ```dart
/// final useCase = ToggleRecommendedUseCase(userRepository);
/// final result = await useCase(ToggleRecommendedParams(
///   userId: 'uuid',
///   gameId: 1942,
/// ));
/// ```
class ToggleRecommendedUseCase
    implements UseCase<void, ToggleRecommendedParams> {

  ToggleRecommendedUseCase(this.repository);
  final UserRepositoryImpl repository;

  @override
  Future<Either<Failure, void>> call(ToggleRecommendedParams params) async {
    return repository.toggleRecommended(params.userId, params.gameId);
  }
}

class ToggleRecommendedParams extends Equatable {

  const ToggleRecommendedParams({
    required this.userId,
    required this.gameId,
  });
  final String userId;
  final int gameId;

  @override
  List<Object> get props => [userId, gameId];
}
