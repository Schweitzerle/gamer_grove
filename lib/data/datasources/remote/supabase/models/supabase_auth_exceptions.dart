// lib/data/datasources/remote/supabase/supabase_auth_exceptions.dart

/// Custom exceptions for authentication operations.
///
/// Provides specific exception types for different authentication scenarios.
library;

/// Base class for all authentication exceptions.
abstract class AuthException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const AuthException({
    required this.message,
    this.code,
    this.originalError,
  });

  @override
  String toString() =>
      'AuthException: $message${code != null ? ' (code: $code)' : ''}';
}

/// Thrown when user credentials are invalid.
class InvalidCredentialsException extends AuthException {
  const InvalidCredentialsException({
    String message = 'Invalid email or password',
    String? code,
    dynamic originalError,
  }) : super(message: message, code: code, originalError: originalError);

  @override
  String toString() => 'InvalidCredentialsException: $message';
}

/// Thrown when user email already exists during signup.
class EmailAlreadyExistsException extends AuthException {
  const EmailAlreadyExistsException({
    String message = 'An account with this email already exists',
    String? code,
    dynamic originalError,
  }) : super(message: message, code: code, originalError: originalError);

  @override
  String toString() => 'EmailAlreadyExistsException: $message';
}

/// Thrown when username is already taken during signup.
class UsernameAlreadyExistsException extends AuthException {
  const UsernameAlreadyExistsException({
    String message = 'This username is already taken',
    String? code,
    dynamic originalError,
  }) : super(message: message, code: code, originalError: originalError);

  @override
  String toString() => 'UsernameAlreadyExistsException: $message';
}

/// Thrown when email format is invalid.
class InvalidEmailException extends AuthException {
  const InvalidEmailException({
    String message = 'Invalid email format',
    String? code,
    dynamic originalError,
  }) : super(message: message, code: code, originalError: originalError);

  @override
  String toString() => 'InvalidEmailException: $message';
}

/// Thrown when password doesn't meet requirements.
class WeakPasswordException extends AuthException {
  const WeakPasswordException({
    String message = 'Password must be at least 6 characters',
    String? code,
    dynamic originalError,
  }) : super(message: message, code: code, originalError: originalError);

  @override
  String toString() => 'WeakPasswordException: $message';
}

/// Thrown when username doesn't meet requirements.
class InvalidUsernameException extends AuthException {
  const InvalidUsernameException({
    String message =
        'Username must be 3-20 characters, alphanumeric and underscores only',
    String? code,
    dynamic originalError,
  }) : super(message: message, code: code, originalError: originalError);

  @override
  String toString() => 'InvalidUsernameException: $message';
}

/// Thrown when user session is invalid or expired.
class InvalidSessionException extends AuthException {
  const InvalidSessionException({
    String message = 'Your session has expired. Please sign in again',
    String? code,
    dynamic originalError,
  }) : super(message: message, code: code, originalError: originalError);

  @override
  String toString() => 'InvalidSessionException: $message';
}

/// Thrown when user is not authenticated.
class NotAuthenticatedException extends AuthException {
  const NotAuthenticatedException({
    String message = 'You must be signed in to perform this action',
    String? code,
    dynamic originalError,
  }) : super(message: message, code: code, originalError: originalError);

  @override
  String toString() => 'NotAuthenticatedException: $message';
}

/// Thrown when email verification is required.
class EmailNotVerifiedException extends AuthException {
  const EmailNotVerifiedException({
    String message = 'Please verify your email address',
    String? code,
    dynamic originalError,
  }) : super(message: message, code: code, originalError: originalError);

  @override
  String toString() => 'EmailNotVerifiedException: $message';
}

/// Thrown when too many authentication attempts are made.
class TooManyRequestsException extends AuthException {
  const TooManyRequestsException({
    String message = 'Too many requests. Please try again later',
    String? code,
    dynamic originalError,
  }) : super(message: message, code: code, originalError: originalError);

  @override
  String toString() => 'TooManyRequestsException: $message';
}

/// Thrown when network connection is unavailable during auth operation.
class NetworkException extends AuthException {
  const NetworkException({
    String message = 'No internet connection. Please check your network',
    String? code,
    dynamic originalError,
  }) : super(message: message, code: code, originalError: originalError);

  @override
  String toString() => 'NetworkException: $message';
}

/// Thrown when an unknown authentication error occurs.
class UnknownAuthException extends AuthException {
  const UnknownAuthException({
    String message = 'An unexpected error occurred',
    String? code,
    dynamic originalError,
  }) : super(message: message, code: code, originalError: originalError);

  @override
  String toString() => 'UnknownAuthException: $message';
}

/// Helper class to map Supabase auth errors to custom exceptions.
class AuthExceptionMapper {
  /// Maps a Supabase AuthException to a custom exception.
  ///
  /// Example:
  /// ```dart
  /// try {
  ///   await supabase.auth.signIn(email: email, password: password);
  /// } on AuthException catch (e) {
  ///   throw AuthExceptionMapper.map(e);
  /// }
  /// ```
  static AuthException map(dynamic error) {
    if (error is! Exception) {
      return UnknownAuthException(
        message: error.toString(),
        originalError: error,
      );
    }

    final errorString = error.toString().toLowerCase();
    final message = error.toString();

    // Invalid credentials
    if (errorString.contains('invalid login credentials') ||
        errorString.contains('invalid email or password') ||
        errorString.contains('invalid_credentials')) {
      return InvalidCredentialsException(
        message: message,
        originalError: error,
      );
    }

    // Email already exists
    if (errorString.contains('user already registered') ||
        errorString.contains('email already exists') ||
        errorString.contains('duplicate key value')) {
      return EmailAlreadyExistsException(
        message: message,
        originalError: error,
      );
    }

    // Invalid email format
    if (errorString.contains('invalid email') ||
        errorString.contains('email validation failed')) {
      return InvalidEmailException(
        message: message,
        originalError: error,
      );
    }

    // Weak password
    if (errorString.contains('password') &&
        (errorString.contains('short') ||
            errorString.contains('weak') ||
            errorString.contains('length'))) {
      return WeakPasswordException(
        message: message,
        originalError: error,
      );
    }

    // Session expired
    if (errorString.contains('session') &&
        (errorString.contains('expired') || errorString.contains('invalid'))) {
      return InvalidSessionException(
        message: message,
        originalError: error,
      );
    }

    // Not authenticated
    if (errorString.contains('not authenticated') ||
        errorString.contains('unauthorized')) {
      return NotAuthenticatedException(
        message: message,
        originalError: error,
      );
    }

    // Email not verified
    if (errorString.contains('email not confirmed') ||
        errorString.contains('email verification')) {
      return EmailNotVerifiedException(
        message: message,
        originalError: error,
      );
    }

    // Rate limiting
    if (errorString.contains('too many requests') ||
        errorString.contains('rate limit')) {
      return TooManyRequestsException(
        message: message,
        originalError: error,
      );
    }

    // Network errors
    if (errorString.contains('network') ||
        errorString.contains('connection') ||
        errorString.contains('socket')) {
      return NetworkException(
        message: message,
        originalError: error,
      );
    }

    // Default to unknown
    return UnknownAuthException(
      message: message,
      originalError: error,
    );
  }
}
