// lib/domain/usecases/auth/

/// Auth use cases for authentication operations.
library;

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import 'package:gamer_grove/domain/entities/user/user.dart';
import 'package:gamer_grove/domain/repositories/auth_repository.dart';
import 'package:gamer_grove/domain/usecases/usecase.dart';

// ============================================================
// SIGN IN USE CASE
// ============================================================

/// Use case for signing in a user.
///
/// Example:
/// ```dart
/// final useCase = SignInUseCase(authRepository);
/// final result = await useCase(SignInParams(
///   email: 'user@example.com',
///   password: 'password123',
/// ));
///
/// result.fold(
/// );
/// ```
class SignInUseCase implements UseCase<User, SignInParams> {

  SignInUseCase(this.repository);
  final AuthRepository repository;

  @override
  Future<Either<Failure, User>> call(SignInParams params) async {
    // Validate inputs
    if (!_isValidEmail(params.email)) {
      return const Left(ValidationFailure(
        message: 'Invalid email format',
      ),);
    }

    if (!_isValidPassword(params.password)) {
      return const Left(ValidationFailure(
        message: 'Password must be at least 6 characters',
      ),);
    }

    return repository.signIn(
      email: params.email,
      password: params.password,
    );
  }

  /// Validates email format using a simple regex pattern.
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  /// Validates password (minimum 6 characters).
  bool _isValidPassword(String password) {
    return password.length >= 6;
  }
}

class SignInParams extends Equatable {

  const SignInParams({
    required this.email,
    required this.password,
  });
  final String email;
  final String password;

  @override
  List<Object> get props => [email, password];
}
