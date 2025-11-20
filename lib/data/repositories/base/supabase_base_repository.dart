// lib/data/repositories/base/supabase_base_repository.dart

/// Base repository for all Supabase operations.
///
/// Provides common functionality and error handling for Supabase repositories.
library;

import 'dart:async';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import 'package:gamer_grove/core/network/network_info.dart';
import 'package:gamer_grove/data/datasources/remote/supabase/models/supabase_auth_exceptions.dart'
    as auth_ex;
import 'package:gamer_grove/data/datasources/remote/supabase/models/supabase_user_exceptions.dart'
    as user_ex;
import 'package:supabase_flutter/supabase_flutter.dart';

/// Abstract base class for all Supabase-based repositories.
///
/// Provides unified query execution with automatic error handling,
/// network checking, and error-to-failure mapping.
///
/// Example usage:
/// ```dart
/// class AuthRepositoryImpl extends SupabaseBaseRepository implements AuthRepository {
///   final SupabaseAuthDataSource authDataSource;
///
///   AuthRepositoryImpl({
///     required this.authDataSource,
///     required super.supabase,
///     required super.networkInfo,
///   });
///
///   @override
///   Future<Either<Failure, User>> signIn(String email, String password) {
///     return executeSupabaseOperation(
///       operation: () => authDataSource.signIn(email, password),
///       errorMessage: 'Failed to sign in',
///     );
///   }
/// }
/// ```
abstract class SupabaseBaseRepository {

  SupabaseBaseRepository({
    required this.supabase,
    required this.networkInfo,
  });
  final SupabaseClient supabase;
  final NetworkInfo networkInfo;

  /// Executes a Supabase operation with unified error handling.
  ///
  /// This is the main method for all repository operations. It:
  /// 1. Checks network connectivity
  /// 2. Executes the operation
  /// 3. Handles all errors and converts them to appropriate Failures
  ///
  /// Type parameter [T] is the expected return type of the operation.
  ///
  /// Parameters:
  /// - [operation]: The async function to execute
  /// - [errorMessage]: Custom error message for logging/debugging
  ///
  /// Returns:
  /// - [Right] with result [T] on success
  /// - [Left] with [Failure] on error
  ///
  /// Example:
  /// ```dart
  /// return executeSupabaseOperation(
  ///   operation: () => userDataSource.getUserProfile(userId),
  ///   errorMessage: 'Failed to get user profile',
  /// );
  /// ```
  Future<Either<Failure, T>> executeSupabaseOperation<T>({
    required Future<T> Function() operation,
    required String errorMessage,
  }) async {
    try {
      // Check network connectivity first
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure(
          message: 'No internet connection. Please check your network.',
        ),);
      }

      // Execute the operation
      final result = await operation();
      return Right(result);
    } on auth_ex.AuthException catch (e) {
      // Handle authentication-specific exceptions
      return Left(_mapAuthException(e));
    } on user_ex.UserException catch (e) {
      // Handle user-specific exceptions
      return Left(_mapUserException(e));
    } on PostgrestException catch (e) {
      // Handle Supabase database exceptions
      return Left(ServerFailure(
        message: _extractPostgrestError(e),
      ),);
    } on StorageException catch (e) {
      // Handle Supabase storage exceptions
      return Left(ServerFailure(
        message: 'Storage error: ${e.message}',
      ),);
    } on SocketException {
      // Handle network socket errors
      return const Left(NetworkFailure(
        message: 'Connection failed. Please check your network.',
      ),);
    } on TimeoutException {
      // Handle timeout errors
      return const Left(NetworkFailure(
        message: 'Request timed out. Please try again.',
      ),);
    } catch (e) {
      // Handle any other unexpected errors
      return Left(ServerFailure(
        message: '$errorMessage: $e',
      ),);
    }
  }

  /// Executes a Supabase operation that returns void.
  ///
  /// Similar to [executeSupabaseOperation] but for operations that don't return data.
  ///
  /// Example:
  /// ```dart
  /// return executeSupabaseVoidOperation(
  ///   operation: () => authDataSource.signOut(),
  ///   errorMessage: 'Failed to sign out',
  /// );
  /// ```
  Future<Either<Failure, void>> executeSupabaseVoidOperation({
    required Future<void> Function() operation,
    required String errorMessage,
  }) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure(
          message: 'No internet connection. Please check your network.',
        ),);
      }

      await operation();
      return const Right(null);
    } on auth_ex.AuthException catch (e) {
      return Left(_mapAuthException(e));
    } on user_ex.UserException catch (e) {
      return Left(_mapUserException(e));
    } on PostgrestException catch (e) {
      return Left(ServerFailure(
        message: _extractPostgrestError(e),
      ),);
    } on StorageException catch (e) {
      return Left(ServerFailure(
        message: 'Storage error: ${e.message}',
      ),);
    } on SocketException {
      return const Left(NetworkFailure(
        message: 'Connection failed. Please check your network.',
      ),);
    } on TimeoutException {
      return const Left(NetworkFailure(
        message: 'Request timed out. Please try again.',
      ),);
    } catch (e) {
      return Left(ServerFailure(
        message: '$errorMessage: $e',
      ),);
    }
  }

  /// Maps authentication exceptions to appropriate failures.
  Failure _mapAuthException(auth_ex.AuthException exception) {
    if (exception is auth_ex.InvalidCredentialsException) {
      return AuthenticationFailure(message: exception.message);
    } else if (exception is auth_ex.EmailAlreadyExistsException) {
      return ValidationFailure(message: exception.message);
    } else if (exception is auth_ex.UsernameAlreadyExistsException) {
      return ValidationFailure(message: exception.message);
    } else if (exception is auth_ex.InvalidEmailException) {
      return ValidationFailure(message: exception.message);
    } else if (exception is auth_ex.WeakPasswordException) {
      return ValidationFailure(message: exception.message);
    } else if (exception is auth_ex.InvalidUsernameException) {
      return ValidationFailure(message: exception.message);
    } else if (exception is auth_ex.InvalidSessionException) {
      return AuthenticationFailure(message: exception.message);
    } else if (exception is auth_ex.NotAuthenticatedException) {
      return AuthenticationFailure(message: exception.message);
    } else if (exception is auth_ex.EmailNotVerifiedException) {
      return AuthenticationFailure(message: exception.message);
    } else if (exception is auth_ex.TooManyRequestsException) {
      return ServerFailure(message: exception.message);
    } else if (exception is auth_ex.NetworkException) {
      return NetworkFailure(message: exception.message);
    } else {
      return ServerFailure(message: exception.message);
    }
  }

  /// Maps user exceptions to appropriate failures.
  Failure _mapUserException(user_ex.UserException exception) {
    if (exception is user_ex.UserNotFoundException) {
      return const ServerFailure(message: 'User not found');
    } else if (exception is user_ex.UsernameAlreadyTakenException) {
      return ValidationFailure(message: exception.message);
    } else if (exception is user_ex.CannotFollowSelfException) {
      return ValidationFailure(message: exception.message);
    } else if (exception is user_ex.AlreadyFollowingException) {
      return ValidationFailure(message: exception.message);
    } else if (exception is user_ex.NotFollowingException) {
      return ValidationFailure(message: exception.message);
    } else if (exception is user_ex.AvatarUploadException) {
      return ServerFailure(message: exception.message);
    } else if (exception is user_ex.InvalidAvatarException) {
      return ValidationFailure(message: exception.message);
    } else if (exception is user_ex.GameNotInCollectionException) {
      return ValidationFailure(message: exception.message);
    } else if (exception is user_ex.InvalidRatingException) {
      return ValidationFailure(message: exception.message);
    } else if (exception is user_ex.InvalidTopThreeException) {
      return ValidationFailure(message: exception.message);
    } else if (exception is user_ex.InvalidProfileDataException) {
      return ValidationFailure(message: exception.message);
    } else if (exception is user_ex.InsufficientPermissionsException) {
      return AuthenticationFailure(message: exception.message);
    } else if (exception is user_ex.PrivateProfileException) {
      return AuthenticationFailure(message: exception.message);
    } else {
      return ServerFailure(message: exception.message);
    }
  }

  /// Extracts a user-friendly error message from PostgrestException.
  String _extractPostgrestError(PostgrestException exception) {
    // Try to extract meaningful error from Postgrest
    final message = exception.message;
    final code = exception.code;

    // Check for common Postgrest error codes
    if (code == '23505') {
      // Unique violation
      return 'This record already exists';
    } else if (code == '23503') {
      // Foreign key violation
      return 'Related record not found';
    } else if (code == '23514') {
      // Check constraint violation
      return 'Invalid data provided';
    } else if (code == '42501') {
      // Insufficient privilege
      return 'You do not have permission to perform this action';
    } else if (code == 'PGRST116') {
      // No rows returned
      return 'Record not found';
    } else if (message.contains('JWT')) {
      // JWT/Auth issues
      return 'Authentication error. Please sign in again';
    }

    // Return the raw message if we can't map it
    return message;
  }

  /// Executes multiple operations in a transaction-like manner.
  ///
  /// Note: Supabase doesn't support true transactions in client libraries,
  /// so this is a best-effort sequential execution with rollback on error.
  ///
  /// Example:
  /// ```dart
  /// return executeSupabaseBatch(
  ///   operations: [
  ///     () => userDataSource.followUser(userId1, userId2),
  ///     () => userDataSource.createActivity(userId1, 'followed_user'),
  ///   ],
  ///   errorMessage: 'Failed to follow user',
  /// );
  /// ```
  Future<Either<Failure, List<T>>> executeSupabaseBatch<T>({
    required List<Future<T> Function()> operations,
    required String errorMessage,
  }) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure(
          message: 'No internet connection. Please check your network.',
        ),);
      }

      final results = <T>[];
      for (final operation in operations) {
        final result = await operation();
        results.add(result);
      }

      return Right(results);
    } on auth_ex.AuthException catch (e) {
      return Left(_mapAuthException(e));
    } on user_ex.UserException catch (e) {
      return Left(_mapUserException(e));
    } on PostgrestException catch (e) {
      return Left(ServerFailure(
        message: _extractPostgrestError(e),
      ),);
    } catch (e) {
      return Left(ServerFailure(
        message: '$errorMessage: $e',
      ),);
    }
  }

  /// Checks if user is authenticated.
  ///
  /// Useful for operations that require authentication.
  ///
  /// Example:
  /// ```dart
  /// if (!await isAuthenticated()) {
  ///   return const Left(AuthenticationFailure(message: 'Not authenticated'));
  /// }
  /// ```
  Future<bool> isAuthenticated() async {
    try {
      final session = supabase.auth.currentSession;
      return session != null;
    } catch (e) {
      return false;
    }
  }

  /// Gets current authenticated user ID.
  ///
  /// Returns null if not authenticated.
  ///
  /// Example:
  /// ```dart
  /// final userId = await getCurrentUserId();
  /// if (userId == null) {
  ///   return const Left(AuthenticationFailure(message: 'Not authenticated'));
  /// }
  /// ```
  Future<String?> getCurrentUserId() async {
    try {
      return supabase.auth.currentUser?.id;
    } catch (e) {
      return null;
    }
  }
}
