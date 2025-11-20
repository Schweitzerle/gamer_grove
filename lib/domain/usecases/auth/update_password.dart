// ============================================================
// UPDATE PASSWORD USE CASE
// ============================================================

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import 'package:gamer_grove/domain/repositories/auth_repository.dart';
import 'package:gamer_grove/domain/usecases/usecase.dart';

/// Use case for updating the current user's password.
///
/// Example:
/// ```dart
/// final useCase = UpdatePasswordUseCase(authRepository);
/// final result = await useCase(UpdatePasswordParams(
///   newPassword: 'newSecurePassword123',
/// ));
///
/// result.fold(
/// );
/// ```
class UpdatePasswordUseCase implements UseCase<void, UpdatePasswordParams> {

  UpdatePasswordUseCase(this.repository);
  final AuthRepository repository;

  @override
  Future<Either<Failure, void>> call(UpdatePasswordParams params) async {
    if (!_isValidPassword(params.newPassword)) {
      return const Left(ValidationFailure(
        message: 'Password must be at least 6 characters',
      ),);
    }

    return repository.updatePassword(newPassword: params.newPassword);
  }

  /// Validates password (minimum 6 characters).
  bool _isValidPassword(String password) {
    return password.length >= 6;
  }
}

class UpdatePasswordParams extends Equatable {

  const UpdatePasswordParams({required this.newPassword});
  final String newPassword;

  @override
  List<Object> get props => [newPassword];
}
