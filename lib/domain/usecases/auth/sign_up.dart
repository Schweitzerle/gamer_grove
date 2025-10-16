// ============================================================
// SIGN UP USE CASE
// ============================================================

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import 'package:gamer_grove/domain/entities/user/user.dart';
import 'package:gamer_grove/domain/repositories/auth_repository.dart';
import 'package:gamer_grove/domain/usecases/usecase.dart';

/// Use case for signing up a new user.
///
/// Example:
/// ```dart
/// final useCase = SignUpUseCase(authRepository);
/// final result = await useCase(SignUpParams(
///   email: 'newuser@example.com',
///   password: 'securePassword123',
///   username: 'john_doe',
/// ));
///
/// result.fold(
///   (failure) => print('Signup failed: ${failure.message}'),
///   (user) => print('Account created for ${user.username}'),
/// );
/// ```
class SignUpUseCase implements UseCase<User, SignUpParams> {
  final AuthRepository repository;

  SignUpUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call(SignUpParams params) async {
    // Validate email
    if (!_isValidEmail(params.email)) {
      return const Left(ValidationFailure(
        message: 'Invalid email format',
      ));
    }

    // Validate password
    if (!_isValidPassword(params.password)) {
      return const Left(ValidationFailure(
        message: 'Password must be at least 6 characters',
      ));
    }

    // Validate username
    if (!_isValidUsername(params.username)) {
      return const Left(ValidationFailure(
        message:
            'Username must be 3-20 characters, lowercase alphanumeric and underscores only',
      ));
    }

    return await repository.signUp(
      email: params.email,
      password: params.password,
      username: params.username,
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

  /// Validates username (3-20 characters, lowercase alphanumeric and underscores).
  bool _isValidUsername(String username) {
    final usernameRegex = RegExp(r'^[a-z0-9_]{3,20}$');
    return usernameRegex.hasMatch(username);
  }
}

class SignUpParams extends Equatable {
  final String email;
  final String password;
  final String username;

  const SignUpParams({
    required this.email,
    required this.password,
    required this.username,
  });

  @override
  List<Object> get props => [email, password, username];
}
