// ============================================================
// RESET PASSWORD USE CASE
// ============================================================

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import 'package:gamer_grove/domain/repositories/auth_repository.dart';
import 'package:gamer_grove/domain/usecases/usecase.dart';

/// Use case for sending a password reset email.
///
/// Example:
/// ```dart
/// final useCase = ResetPasswordUseCase(authRepository);
/// final result = await useCase(ResetPasswordParams(
///   email: 'user@example.com',
/// ));
///
/// result.fold(
/// );
/// ```
class ResetPasswordUseCase implements UseCase<void, ResetPasswordParams> {
  final AuthRepository repository;

  ResetPasswordUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(ResetPasswordParams params) async {
    if (!_isValidEmail(params.email)) {
      return const Left(ValidationFailure(
        message: 'Invalid email format',
      ));
    }

    return await repository.resetPassword(email: params.email);
  }

  /// Validates email format using a simple regex pattern.
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }
}

class ResetPasswordParams extends Equatable {
  final String email;

  const ResetPasswordParams({required this.email});

  @override
  List<Object> get props => [email];
}
