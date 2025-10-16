// lib/domain/usecases/usecase.dart

/// Base use case interface for all use cases.
///
/// Defines a common contract for executing use cases with parameters.
library;

import 'package:dartz/dartz.dart';
import 'package:gamer_grove/core/errors/failures.dart';

/// Base interface for all use cases.
///
/// [Type] is the return type of the use case.
/// [Params] is the parameter type that the use case accepts.
///
/// Example:
/// ```dart
/// class SignInUseCase implements UseCase<User, SignInParams> {
///   final AuthRepository repository;
///
///   SignInUseCase(this.repository);
///
///   @override
///   Future<Either<Failure, User>> call(SignInParams params) {
///     return repository.signIn(params.email, params.password);
///   }
/// }
/// ```
abstract class UseCase<Type, Params> {
  /// Executes the use case with the given parameters.
  ///
  /// Returns [Either] with [Failure] on error or [Type] on success.
  Future<Either<Failure, Type>> call(Params params);
}

/// Use case that doesn't require any parameters.
///
/// Example:
/// ```dart
/// class GetCurrentUserUseCase implements NoParamsUseCase<User?> {
///   final AuthRepository repository;
///
///   GetCurrentUserUseCase(this.repository);
///
///   @override
///   Future<Either<Failure, User?>> call() {
///     return repository.getCurrentUser();
///   }
/// }
/// ```
abstract class NoParamsUseCase<Type> {
  /// Executes the use case without parameters.
  Future<Either<Failure, Type>> call();
}

/// Marker class for use cases that don't need parameters.
///
/// Example:
/// ```dart
/// class SignOutUseCase implements UseCase<void, NoParams> {
///   final AuthRepository repository;
///
///   SignOutUseCase(this.repository);
///
///   @override
///   Future<Either<Failure, void>> call(NoParams params) {
///     return repository.signOut();
///   }
/// }
/// ```
class NoParams {
  const NoParams();
}
