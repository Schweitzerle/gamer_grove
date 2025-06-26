// ==================================================
// ERWEITERTE ERROR HANDLING
// ==================================================

// lib/core/error/error_handler.dart
import '../../domain/entities/game.dart';
import 'failures.dart';

class ErrorHandler {
  static String getErrorMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        final serverFailure = failure as ServerFailure;
        return serverFailure.message ?? 'Server error occurred';
      case NetworkFailure:
        return 'Please check your internet connection';
      case CacheFailure:
        return 'Local data error occurred';
      case AuthenticationFailure:
        final authFailure = failure as AuthenticationFailure;
        return authFailure.message ?? 'Authentication failed';
      case ValidationFailure:
        final validationFailure = failure as ValidationFailure;
        return validationFailure.message ?? 'Validation error occurred';
      default:
        return 'An unexpected error occurred';
    }
  }

  static bool isRetryableError(Failure failure) {
    return failure is NetworkFailure ||
        failure is ServerFailure ||
        failure is CacheFailure;
  }

  static bool isAuthenticationError(Failure failure) {
    return failure is AuthenticationFailure;
  }
}
