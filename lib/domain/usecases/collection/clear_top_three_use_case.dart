// ============================================================
// CLEAR TOP THREE USE CASE
// ============================================================

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import 'package:gamer_grove/domain/repositories/user_repository.dart';
import 'package:gamer_grove/domain/usecases/usecase.dart';

/// Use case for clearing user's top 3 games.
///
/// Example:
/// ```dart
/// final useCase = ClearTopThreeUseCase(userRepository);
/// final result = await useCase(ClearTopThreeParams(userId: 'uuid'));
/// ```
class ClearTopThreeUseCase implements UseCase<void, ClearTopThreeParams> {

  ClearTopThreeUseCase(this.repository);
  final UserRepository repository;

  @override
  Future<Either<Failure, void>> call(ClearTopThreeParams params) async {
    // Clear by setting empty list
    return repository.updateTopThreeGames(
      userId: params.userId,
      gameIds: [0, 0, 0], // Clear with placeholder values
    );
  }
}

class ClearTopThreeParams extends Equatable {

  const ClearTopThreeParams({required this.userId});
  final String userId;

  @override
  List<Object> get props => [userId];
}
