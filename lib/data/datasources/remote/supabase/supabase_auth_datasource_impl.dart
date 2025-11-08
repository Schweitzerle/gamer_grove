/// Implementation of authentication data source.
///
/// Handles all authentication operations with Supabase backend.
library;

import 'package:gamer_grove/data/datasources/remote/supabase/models/supabase_auth_exceptions.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;
import 'supabase_auth_datasource.dart';

/// Concrete implementation of [SupabaseAuthDataSource].
///
/// Uses Supabase client for all authentication operations and
/// maps errors to custom exceptions.
class SupabaseAuthDataSourceImpl implements SupabaseAuthDataSource {
  final SupabaseClient _supabase;

  /// Regular expression for username validation.
  ///
  /// Requirements:
  /// - 3-20 characters
  /// - Lowercase letters, numbers, and underscores only
  static final RegExp _usernameRegex = RegExp(r'^[a-z0-9_]{3,20}$');

  /// Regular expression for email validation.
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  /// Minimum password length requirement.
  static const int _minPasswordLength = 6;

  SupabaseAuthDataSourceImpl({required SupabaseClient supabase})
      : _supabase = supabase;

  @override
  Future<User> signIn(String email, String password) async {
    try {
      // Validate inputs
      if (!isValidEmail(email)) {
        throw const InvalidEmailException();
      }
      if (!isValidPassword(password)) {
        throw const WeakPasswordException();
      }

      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) {
        throw const InvalidCredentialsException(
          message: 'Sign in failed - no user returned',
        );
      }

      return user;
    } on AuthException catch (e) {
      throw AuthExceptionMapper.map(e);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw UnknownAuthException(
        message: 'Failed to sign in: $e',
        originalError: e,
      );
    }
  }

  @override
  Future<AuthResponse> signUp(
    String email,
    String password,
    String username,
  ) async {
    try {
      // Validate inputs
      if (!isValidEmail(email)) {
        throw const InvalidEmailException();
      }
      if (!isValidPassword(password)) {
        throw const WeakPasswordException();
      }
      if (!isValidUsername(username)) {
        throw const InvalidUsernameException();
      }

      // Check if username is available using database function
      // This bypasses RLS and is safe for anonymous users
      final isAvailable = await _supabase.rpc<bool>(
        'is_username_available',
        params: {'username_to_check': username},
      );

      if (!isAvailable) {
        throw const UsernameAlreadyExistsException();
      }

      // Sign up the user
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'username': username,
        },
      );

      final user = response.user;
      if (user == null) {
        throw const UnknownAuthException(
          message: 'Sign up failed - no user returned',
        );
      }

      // Debug: Check session status
      final session = response.session;
      print('DEBUG SignUp - User ID: ${user.id}');
      print('DEBUG SignUp - Session exists: ${session != null}');
      print(
          'DEBUG SignUp - Access Token exists: ${session?.accessToken != null}');

      // Note: User profile is automatically created by database trigger
      // (handle_new_user function on auth.users INSERT)

      return response;
    } on AuthException catch (e) {
      throw AuthExceptionMapper.map(e);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw UnknownAuthException(
        message: 'Failed to sign up: $e',
        originalError: e,
      );
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } on AuthException catch (e) {
      throw AuthExceptionMapper.map(e);
    } catch (e) {
      throw UnknownAuthException(
        message: 'Failed to sign out: $e',
        originalError: e,
      );
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      if (!isValidEmail(email)) {
        throw const InvalidEmailException();
      }

      await _supabase.auth.resetPasswordForEmail(email);
    } on AuthException catch (e) {
      throw AuthExceptionMapper.map(e);
    } catch (e) {
      throw UnknownAuthException(
        message: 'Failed to send reset password email: $e',
        originalError: e,
      );
    }
  }

  @override
  Future<void> updatePassword(String newPassword) async {
    try {
      if (!isValidPassword(newPassword)) {
        throw const WeakPasswordException();
      }

      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw const NotAuthenticatedException();
      }

      await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } on AuthException catch (e) {
      throw AuthExceptionMapper.map(e);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw UnknownAuthException(
        message: 'Failed to update password: $e',
        originalError: e,
      );
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    try {
      return _supabase.auth.currentUser;
    } catch (e) {
      // Don't throw exception - return null if user not found
      return null;
    }
  }

  @override
  Future<void> refreshSession() async {
    try {
      final session = _supabase.auth.currentSession;
      if (session == null) {
        throw const InvalidSessionException(
          message: 'No active session to refresh',
        );
      }

      await _supabase.auth.refreshSession();
    } on AuthException catch (e) {
      throw AuthExceptionMapper.map(e);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw UnknownAuthException(
        message: 'Failed to refresh session: $e',
        originalError: e,
      );
    }
  }

  @override
  Future<Session?> getSession() async {
    try {
      return _supabase.auth.currentSession;
    } catch (e) {
      // Don't throw exception - return null if no session
      return null;
    }
  }

  @override
  Future<bool> isSessionValid() async {
    try {
      final session = await getSession();
      if (session == null) return false;

      // Check if session is expired
      final expiresAt = session.expiresAt;
      if (expiresAt == null) return false;

      final expiryDate = DateTime.fromMillisecondsSinceEpoch(expiresAt * 1000);
      final now = DateTime.now();

      return expiryDate.isAfter(now);
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> updateEmail(String newEmail) async {
    try {
      if (!isValidEmail(newEmail)) {
        throw const InvalidEmailException();
      }

      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw const NotAuthenticatedException();
      }

      await _supabase.auth.updateUser(
        UserAttributes(email: newEmail),
      );
    } on AuthException catch (e) {
      throw AuthExceptionMapper.map(e);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw UnknownAuthException(
        message: 'Failed to update email: $e',
        originalError: e,
      );
    }
  }

  @override
  Stream<AuthState> onAuthStateChange() {
    return _supabase.auth.onAuthStateChange;
  }

  @override
  bool isValidUsername(String username) {
    return _usernameRegex.hasMatch(username);
  }

  @override
  bool isValidEmail(String email) {
    return _emailRegex.hasMatch(email);
  }

  @override
  bool isValidPassword(String password) {
    return password.length >= _minPasswordLength;
  }
}
