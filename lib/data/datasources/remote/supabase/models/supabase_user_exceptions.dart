// lib/data/datasources/remote/supabase/supabase_user_exceptions.dart

/// Custom exceptions for user operations.
///
/// Provides specific exception types for different user-related scenarios.
library;

/// Base class for all user-related exceptions.
abstract class UserException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const UserException({
    required this.message,
    this.code,
    this.originalError,
  });

  @override
  String toString() =>
      'UserException: $message${code != null ? ' (code: $code)' : ''}';
}

/// Thrown when user profile is not found.
class UserNotFoundException extends UserException {
  const UserNotFoundException({
    String message = 'User profile not found',
    String? code,
    dynamic originalError,
  }) : super(message: message, code: code, originalError: originalError);

  @override
  String toString() => 'UserNotFoundException: $message';
}

/// Thrown when username is already taken.
class UsernameAlreadyTakenException extends UserException {
  const UsernameAlreadyTakenException({
    String message = 'This username is already taken',
    String? code,
    dynamic originalError,
  }) : super(message: message, code: code, originalError: originalError);

  @override
  String toString() => 'UsernameAlreadyTakenException: $message';
}

/// Thrown when trying to follow yourself.
class CannotFollowSelfException extends UserException {
  const CannotFollowSelfException({
    String message = 'You cannot follow yourself',
    String? code,
    dynamic originalError,
  }) : super(message: message, code: code, originalError: originalError);

  @override
  String toString() => 'CannotFollowSelfException: $message';
}

/// Thrown when trying to follow a user that's already followed.
class AlreadyFollowingException extends UserException {
  const AlreadyFollowingException({
    String message = 'You are already following this user',
    String? code,
    dynamic originalError,
  }) : super(message: message, code: code, originalError: originalError);

  @override
  String toString() => 'AlreadyFollowingException: $message';
}

/// Thrown when trying to unfollow a user that's not followed.
class NotFollowingException extends UserException {
  const NotFollowingException({
    String message = 'You are not following this user',
    String? code,
    dynamic originalError,
  }) : super(message: message, code: code, originalError: originalError);

  @override
  String toString() => 'NotFollowingException: $message';
}

/// Thrown when avatar upload fails.
class AvatarUploadException extends UserException {
  const AvatarUploadException({
    String message = 'Failed to upload avatar',
    String? code,
    dynamic originalError,
  }) : super(message: message, code: code, originalError: originalError);

  @override
  String toString() => 'AvatarUploadException: $message';
}

/// Thrown when avatar file is invalid (wrong format, too large, etc.).
class InvalidAvatarException extends UserException {
  const InvalidAvatarException({
    String message = 'Invalid avatar file',
    String? code,
    dynamic originalError,
  }) : super(message: message, code: code, originalError: originalError);

  @override
  String toString() => 'InvalidAvatarException: $message';
}

/// Thrown when game is not found in user's collection.
class GameNotInCollectionException extends UserException {
  const GameNotInCollectionException({
    String message = 'Game is not in your collection',
    String? code,
    dynamic originalError,
  }) : super(message: message, code: code, originalError: originalError);

  @override
  String toString() => 'GameNotInCollectionException: $message';
}

/// Thrown when rating value is invalid.
class InvalidRatingException extends UserException {
  const InvalidRatingException({
    String message = 'Rating must be between 0.0 and 10.0',
    String? code,
    dynamic originalError,
  }) : super(message: message, code: code, originalError: originalError);

  @override
  String toString() => 'InvalidRatingException: $message';
}

/// Thrown when top three games list is invalid.
class InvalidTopThreeException extends UserException {
  const InvalidTopThreeException({
    String message = 'Top three must contain exactly 3 different games',
    String? code,
    dynamic originalError,
  }) : super(message: message, code: code, originalError: originalError);

  @override
  String toString() => 'InvalidTopThreeException: $message';
}

/// Thrown when user profile data is invalid.
class InvalidProfileDataException extends UserException {
  const InvalidProfileDataException({
    String message = 'Invalid profile data',
    String? code,
    dynamic originalError,
  }) : super(message: message, code: code, originalError: originalError);

  @override
  String toString() => 'InvalidProfileDataException: $message';
}

/// Thrown when user lacks permission to perform an action.
class InsufficientPermissionsException extends UserException {
  const InsufficientPermissionsException({
    String message = 'You do not have permission to perform this action',
    String? code,
    dynamic originalError,
  }) : super(message: message, code: code, originalError: originalError);

  @override
  String toString() => 'InsufficientPermissionsException: $message';
}

/// Thrown when user profile is private and cannot be accessed.
class PrivateProfileException extends UserException {
  const PrivateProfileException({
    String message = 'This profile is private',
    String? code,
    dynamic originalError,
  }) : super(message: message, code: code, originalError: originalError);

  @override
  String toString() => 'PrivateProfileException: $message';
}

/// Thrown when an unknown user-related error occurs.
class UnknownUserException extends UserException {
  const UnknownUserException({
    String message = 'An unexpected error occurred',
    String? code,
    dynamic originalError,
  }) : super(message: message, code: code, originalError: originalError);

  @override
  String toString() => 'UnknownUserException: $message';
}

/// Helper class to map Supabase errors to custom user exceptions.
class UserExceptionMapper {
  /// Maps a Supabase error to a custom user exception.
  ///
  /// Example:
  /// ```dart
  /// try {
  ///   await supabase.from('users').select().eq('id', userId).single();
  /// } catch (e) {
  ///   throw UserExceptionMapper.map(e);
  /// }
  /// ```
  static UserException map(dynamic error) {
    if (error is! Exception) {
      return UnknownUserException(
        message: error.toString(),
        originalError: error,
      );
    }

    final errorString = error.toString().toLowerCase();
    final message = error.toString();

    // User not found
    if (errorString.contains('no rows') ||
        errorString.contains('not found') ||
        errorString.contains('multiple (or no) rows')) {
      return UserNotFoundException(
        message: message,
        originalError: error,
      );
    }

    // Username taken
    if (errorString.contains('duplicate key') &&
        errorString.contains('username')) {
      return UsernameAlreadyTakenException(
        message: message,
        originalError: error,
      );
    }

    // Self-follow attempt
    if (errorString.contains('no_self_follow') ||
        (errorString.contains('check constraint') &&
            errorString.contains('follower'))) {
      return CannotFollowSelfException(
        message: message,
        originalError: error,
      );
    }

    // Already following
    if (errorString.contains('duplicate key') &&
        errorString.contains('follow')) {
      return AlreadyFollowingException(
        message: message,
        originalError: error,
      );
    }

    // Permission denied
    if (errorString.contains('permission denied') ||
        errorString.contains('insufficient privileges') ||
        errorString.contains('row level security')) {
      return InsufficientPermissionsException(
        message: message,
        originalError: error,
      );
    }

    // Rating validation
    if (errorString.contains('rating') &&
        (errorString.contains('constraint') || errorString.contains('check'))) {
      return InvalidRatingException(
        message: message,
        originalError: error,
      );
    }

    // Top three validation
    if (errorString.contains('different_games') ||
        (errorString.contains('top_three') &&
            errorString.contains('constraint'))) {
      return InvalidTopThreeException(
        message: message,
        originalError: error,
      );
    }

    // Default to unknown
    return UnknownUserException(
      message: message,
      originalError: error,
    );
  }
}
