import 'package:dartz/dartz.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import 'package:gamer_grove/domain/entities/user/user.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

/// Abstract repository for handling user authentication.
///
/// This repository defines the contract for authentication-related operations,
/// abstracting the data source from the application's business logic.
abstract class AuthRepository {
  /// Stream that notifies of authentication state changes.
  Stream<supabase.User?> get authStateChanges;

  /// Signs up a new user.
  Future<Either<Failure, User>> signUp({
    required String email,
    required String password,
    required String username,
  });

  /// Signs in an existing user.
  Future<Either<Failure, User>> signIn({
    required String email,
    required String password,
  });

  /// Signs out the current user.
  Future<Either<Failure, void>> signOut();

  /// Resets the password for a given email.
  Future<Either<Failure, void>> resetPassword({
    required String email,
  });

  /// Updates the current user's password.
  Future<Either<Failure, void>> updatePassword({
    required String newPassword,
  });

  /// Deletes the current user's account.
  Future<Either<Failure, void>> deleteAccount();

  /// Gets the current authenticated user.
  Future<Either<Failure, User?>> getCurrentUser();
}
