// lib/data/repositories/base/igdb_base_repository.dart

/// Base repository for all IGDB API operations.
///
/// Provides common functionality and error handling for IGDB repositories.
library;

import 'dart:async';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import 'package:gamer_grove/core/network/network_info.dart';
import 'package:http/http.dart' as http;

/// Abstract base class for all IGDB-based repositories.
///
/// Provides unified API call execution with automatic error handling,
/// network checking, rate limiting, and error-to-failure mapping.
///
/// Example usage:
/// ```dart
/// class GameRepositoryImpl extends IgdbBaseRepository implements GameRepository {
///   final IgdbApiDataSource igdbDataSource;
///
///   GameRepositoryImpl({
///     required this.igdbDataSource,
///     required super.networkInfo,
///   });
///
///   @override
///   Future<Either<Failure, List<Game>>> searchGames(String query) {
///     return executeIgdbOperation(
///       operation: () => igdbDataSource.searchGames(query),
///       errorMessage: 'Failed to search games',
///     );
///   }
/// }
/// ```
abstract class IgdbBaseRepository {

  IgdbBaseRepository({
    required this.networkInfo,
  });
  final NetworkInfo networkInfo;

  /// Executes an IGDB API operation with unified error handling.
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
  /// return executeIgdbOperation(
  ///   operation: () => igdbDataSource.getGameById(gameId),
  ///   errorMessage: 'Failed to get game details',
  /// );
  /// ```
  Future<Either<Failure, T>> executeIgdbOperation<T>({
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
    } on http.ClientException catch (e) {
      // Handle HTTP client errors
      return Left(NetworkFailure(
        message: 'Network error: ${e.message}',
      ),);
    } on FormatException {
      // Handle JSON parsing errors
      return const Left(ServerFailure(
        message: 'Invalid data received from server',
      ),);
    } on IgdbRateLimitException catch (e) {
      // Handle IGDB rate limiting
      return Left(ServerFailure(
        message: e.message,
      ),);
    } on IgdbAuthenticationException catch (e) {
      // Handle IGDB authentication errors
      return Left(AuthenticationFailure(
        message: e.message,
      ),);
    } on IgdbNotFoundException {
      // Handle 404 errors
      return const Left(ServerFailure(
        message: 'Resource not found',
      ),);
    } on IgdbApiException catch (e) {
      // Handle general IGDB API errors
      return Left(ServerFailure(
        message: e.message,
      ),);
    } catch (e) {
      // Handle any other unexpected errors
      return Left(ServerFailure(
        message: '$errorMessage: $e',
      ),);
    }
  }

  /// Executes an IGDB operation that returns void.
  ///
  /// Similar to [executeIgdbOperation] but for operations that don't return data.
  ///
  /// Example:
  /// ```dart
  /// return executeIgdbVoidOperation(
  ///   operation: () => igdbDataSource.clearCache(),
  ///   errorMessage: 'Failed to clear cache',
  /// );
  /// ```
  Future<Either<Failure, void>> executeIgdbVoidOperation({
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
    } on SocketException {
      return const Left(NetworkFailure(
        message: 'Connection failed. Please check your network.',
      ),);
    } on TimeoutException {
      return const Left(NetworkFailure(
        message: 'Request timed out. Please try again.',
      ),);
    } on IgdbRateLimitException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on IgdbAuthenticationException catch (e) {
      return Left(AuthenticationFailure(message: e.message));
    } on IgdbApiException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(
        message: '$errorMessage: $e',
      ),);
    }
  }

  /// Executes multiple IGDB operations in parallel.
  ///
  /// Useful for fetching multiple resources simultaneously.
  ///
  /// Example:
  /// ```dart
  /// return executeIgdbBatch(
  ///   operations: [
  ///     () => igdbDataSource.getGameById(1942),
  ///     () => igdbDataSource.getGameById(1905),
  ///     () => igdbDataSource.getGameById(113),
  ///   ],
  ///   errorMessage: 'Failed to fetch games',
  /// );
  /// ```
  Future<Either<Failure, List<T>>> executeIgdbBatch<T>({
    required List<Future<T> Function()> operations,
    required String errorMessage,
  }) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure(
          message: 'No internet connection. Please check your network.',
        ),);
      }

      // Execute all operations in parallel
      final futures = operations.map((op) => op()).toList();
      final results = await Future.wait(futures);

      return Right(results);
    } on SocketException {
      return const Left(NetworkFailure(
        message: 'Connection failed. Please check your network.',
      ),);
    } on TimeoutException {
      return const Left(NetworkFailure(
        message: 'Request timed out. Please try again.',
      ),);
    } on IgdbRateLimitException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on IgdbAuthenticationException catch (e) {
      return Left(AuthenticationFailure(message: e.message));
    } on IgdbApiException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(
        message: '$errorMessage: $e',
      ),);
    }
  }

  /// Executes an IGDB operation with retry logic.
  ///
  /// Automatically retries the operation on transient failures.
  ///
  /// Parameters:
  /// - [operation]: The operation to execute
  /// - [errorMessage]: Error message for logging
  /// - [maxRetries]: Maximum number of retry attempts (default: 3)
  /// - [retryDelay]: Delay between retries (default: 1 second)
  ///
  /// Example:
  /// ```dart
  /// return executeIgdbWithRetry(
  ///   operation: () => igdbDataSource.searchGames(query),
  ///   errorMessage: 'Failed to search games',
  ///   maxRetries: 3,
  /// );
  /// ```
  Future<Either<Failure, T>> executeIgdbWithRetry<T>({
    required Future<T> Function() operation,
    required String errorMessage,
    int maxRetries = 3,
    Duration retryDelay = const Duration(seconds: 1),
  }) async {
    var attempts = 0;

    while (attempts <= maxRetries) {
      final result = await executeIgdbOperation(
        operation: operation,
        errorMessage: errorMessage,
      );

      // Return immediately on success
      if (result.isRight()) {
        return result;
      }

      attempts++;

      // If this was the last attempt, return the error
      if (attempts > maxRetries) {
        return result;
      }

      // Check if error is retryable
      final failure = result.fold((l) => l, (r) => null);
      if (failure is NetworkFailure ||
          (failure is ServerFailure && failure.message.contains('timeout'))) {
        // Wait before retrying
        await Future<void>.delayed(retryDelay * attempts);
        continue;
      } else {
        // Non-retryable error, return immediately
        return result;
      }
    }

    return Left(ServerFailure(message: errorMessage));
  }
}

/// Base exception for all IGDB API errors.
abstract class IgdbApiException implements Exception {

  const IgdbApiException(this.message, {this.statusCode});
  final String message;
  final int? statusCode;

  @override
  String toString() =>
      'IgdbApiException: $message${statusCode != null ? ' (status: $statusCode)' : ''}';
}

/// Thrown when IGDB API rate limit is exceeded.
class IgdbRateLimitException extends IgdbApiException {
  const IgdbRateLimitException({
    String message = 'Rate limit exceeded. Please try again later.',
    int? statusCode,
  }) : super(message, statusCode: statusCode);

  @override
  String toString() => 'IgdbRateLimitException: $message';
}

/// Thrown when IGDB API authentication fails.
class IgdbAuthenticationException extends IgdbApiException {
  const IgdbAuthenticationException({
    String message =
        'Authentication failed. Please check your API credentials.',
    int? statusCode,
  }) : super(message, statusCode: statusCode);

  @override
  String toString() => 'IgdbAuthenticationException: $message';
}

/// Thrown when requested resource is not found (404).
class IgdbNotFoundException extends IgdbApiException {
  const IgdbNotFoundException({
    String message = 'Resource not found',
    int? statusCode = 404,
  }) : super(message, statusCode: statusCode);

  @override
  String toString() => 'IgdbNotFoundException: $message';
}

/// Thrown when IGDB API returns a bad request (400).
class IgdbBadRequestException extends IgdbApiException {
  const IgdbBadRequestException({
    String message = 'Bad request',
    int? statusCode = 400,
  }) : super(message, statusCode: statusCode);

  @override
  String toString() => 'IgdbBadRequestException: $message';
}

/// Thrown when IGDB API returns a server error (5xx).
class IgdbServerException extends IgdbApiException {
  const IgdbServerException({
    String message = 'Server error',
    int? statusCode,
  }) : super(message, statusCode: statusCode);

  @override
  String toString() => 'IgdbServerException: $message';
}
