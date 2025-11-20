// ============================================================
// SIGN OUT USE CASE
// ============================================================

import 'package:dartz/dartz.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import 'package:gamer_grove/domain/repositories/auth_repository.dart';
import 'package:gamer_grove/domain/usecases/usecase.dart';

/// Use case for signing out the current user.
///
/// Example:
/// ```dart
/// final useCase = SignOutUseCase(authRepository);
/// final result = await useCase(NoParams());
///
/// result.fold(
/// );
/// ```
class SignOutUseCase implements UseCase<void, NoParams> {

  SignOutUseCase(this.repository);
  final AuthRepository repository;

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return repository.signOut();
  }
}
