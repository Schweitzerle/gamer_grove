// core/utils/input_validator.dart
import '../constants/app_constants.dart';

class InputValidator {
  // Email validation
  static bool isValidEmail(String email) {
    if (email.isEmpty) return false;
    return RegExp(AppConstants.emailPattern).hasMatch(email);
  }

  static String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'Email is required';
    }
    if (!isValidEmail(email)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  // Password validation
  static bool isValidPassword(String password) {
    return password.length >= AppConstants.passwordMinLength;
  }

  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Password is required';
    }
    if (!isValidPassword(password)) {
      return 'Password must be at least ${AppConstants.passwordMinLength} characters';
    }
    return null;
  }

  static String? validatePasswordConfirmation(String? password, String? confirmation) {
    if (confirmation == null || confirmation.isEmpty) {
      return 'Password confirmation is required';
    }
    if (password != confirmation) {
      return 'Passwords do not match';
    }
    return null;
  }

  // Username validation
  static bool isValidUsername(String username) {
    if (username.length < AppConstants.usernameMinLength ||
        username.length > AppConstants.usernameMaxLength) {
      return false;
    }
    return RegExp(AppConstants.usernamePattern).hasMatch(username);
  }

  static String? validateUsername(String? username) {
    if (username == null || username.isEmpty) {
      return 'Username is required';
    }
    if (username.length < AppConstants.usernameMinLength) {
      return 'Username must be at least ${AppConstants.usernameMinLength} characters';
    }
    if (username.length > AppConstants.usernameMaxLength) {
      return 'Username cannot exceed ${AppConstants.usernameMaxLength} characters';
    }
    if (!RegExp(AppConstants.usernamePattern).hasMatch(username)) {
      return 'Username can only contain letters, numbers, and underscores';
    }
    return null;
  }

  // Bio validation
  static String? validateBio(String? bio) {
    if (bio != null && bio.length > AppConstants.bioMaxLength) {
      return 'Bio cannot exceed ${AppConstants.bioMaxLength} characters';
    }
    return null;
  }

  // Rating validation
  static bool isValidRating(double rating) {
    return rating >= AppConstants.minRating && rating <= AppConstants.maxRating;
  }

  static String? validateRating(double? rating) {
    if (rating == null) {
      return 'Rating is required';
    }
    if (!isValidRating(rating)) {
      return 'Rating must be between ${AppConstants.minRating} and ${AppConstants.maxRating}';
    }
    return null;
  }

  // Search query validation
  static bool isValidSearchQuery(String query) {
    return query.trim().length >= AppConstants.minSearchLength;
  }

  static String? validateSearchQuery(String? query) {
    if (query == null || query.trim().isEmpty) {
      return 'Search query cannot be empty';
    }
    if (!isValidSearchQuery(query)) {
      return 'Search query must be at least ${AppConstants.minSearchLength} characters';
    }
    return null;
  }

  // General text validation
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? validateMaxLength(String? value, int maxLength, String fieldName) {
    if (value != null && value.length > maxLength) {
      return '$fieldName cannot exceed $maxLength characters';
    }
    return null;
  }

  static String? validateMinLength(String? value, int minLength, String fieldName) {
    if (value != null && value.isNotEmpty && value.length < minLength) {
      return '$fieldName must be at least $minLength characters';
    }
    return null;
  }
}

