// ============================================================
// GET CURRENT USER USE CASE
// ============================================================

import 'package:dartz/dartz.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import 'package:gamer_grove/domain/entities/user/user.dart';
import 'package:gamer_grove/domain/repositories/auth_repository.dart';
import 'package:gamer_grove/domain/usecases/usecase.dart';

/// Use case for getting the currently authenticated user.
///
/// Example:
/// ```dart
/// final useCase = GetCurrentUserUseCase(authRepository);
/// final result = await useCase(NoParams());
///
/// result.fold(
///   (failure) => print('Error: ${failure.message}'),
///   (user) {
///     if (user != null) {
///       print('Current user: ${user.username}');
///     } else {
///       print('No user signed in');
///     }
///   },
/// );
/// ```
class GetCurrentUserUseCase implements UseCase<User?, NoParams> {
  final AuthRepository repository;

  GetCurrentUserUseCase(this.repository);

  @override
  Future<Either<Failure, User?>> call(NoParams params) async {
    return await repository.getCurrentUser();
  }
}
