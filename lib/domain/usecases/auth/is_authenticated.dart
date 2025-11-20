// ============================================================
// IS AUTHENTICATED USE CASE
// ============================================================

import 'package:dartz/dartz.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import 'package:gamer_grove/domain/repositories/auth_repository.dart';
import 'package:gamer_grove/domain/usecases/usecase.dart';

/// Use case for checking if user is authenticated.
///
/// Example:
/// ```dart
/// final useCase = IsAuthenticatedUseCase(authRepository);
/// final result = await useCase(NoParams());
///
/// result.fold(
///   (failure) => false,
///   (isAuth) => isAuth,
/// );
/// ```
class IsAuthenticatedUseCase implements UseCase<bool, NoParams> {

  IsAuthenticatedUseCase(this.repository);
  final AuthRepository repository;

  @override
  Future<Either<Failure, bool>> call(NoParams params) async {
    final result = await repository.getCurrentUser();

    return result.fold(
      (failure) =>
          const Right(false), // If there's an error, user is not authenticated
      (user) =>
          Right(user != null), // User is authenticated if user object exists
    );
  }
}
