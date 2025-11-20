// lib/data/datasources/remote/supabase/supabase_auth_datasource.dart

/// Data source interface for authentication operations.
///
/// Defines the contract for all authentication-related operations
/// with Supabase backend.
library;

import 'package:supabase_flutter/supabase_flutter.dart';

/// Abstract interface for authentication data operations.
///
/// Implementations should handle all low-level authentication
/// operations with the backend service (Supabase).
abstract class SupabaseAuthDataSource {
  /// Signs in a user with email and password.
  ///
  /// Returns the authenticated [User] on success.
  /// Throws [AuthException] on failure.
  ///
  /// Example:
  /// ```dart
  /// try {
  ///   final user = await authDataSource.signIn(
  ///     'user@example.com',
  ///     'password123',
  ///   );
  /// } on InvalidCredentialsException {
  /// }
  /// ```
  Future<User> signIn(String email, String password);

  /// Signs up a new user with email, password, and username.
  ///
  /// Creates both an auth user and a profile record.
  /// Returns the newly created [User] on success.
  /// Throws [AuthException] on failure.
  ///
  /// Example:
  /// ```dart
  /// try {
  ///   final user = await authDataSource.signUp(
  ///     'newuser@example.com',
  ///     'securePassword123',
  ///     'john_doe',
  ///   );
  /// } on EmailAlreadyExistsException {
  /// } on UsernameAlreadyExistsException {
  /// }
  /// ```
  Future<AuthResponse> signUp(
    String email,
    String password,
    String username,
  );

  /// Signs out the current user.
  ///
  /// Clears the session and revokes the access token.
  /// Throws [AuthException] on failure.
  ///
  /// Example:
  /// ```dart
  /// try {
  ///   await authDataSource.signOut();
  /// } on AuthException catch (e) {
  /// }
  /// ```
  Future<void> signOut();

  /// Sends a password reset email to the user.
  ///
  /// User will receive an email with a link to reset their password.
  /// Throws [AuthException] on failure.
  ///
  /// Example:
  /// ```dart
  /// try {
  ///   await authDataSource.resetPassword('user@example.com');
  /// } on InvalidEmailException {
  /// }
  /// ```
  Future<void> resetPassword(String email);

  /// Updates the current user's password.
  ///
  /// Requires an active authenticated session.
  /// Throws [AuthException] on failure.
  ///
  /// Example:
  /// ```dart
  /// try {
  ///   await authDataSource.updatePassword('newSecurePassword123');
  /// } on WeakPasswordException {
  /// } on NotAuthenticatedException {
  /// }
  /// ```
  Future<void> updatePassword(String newPassword);

  /// Gets the currently authenticated user.
  ///
  /// Returns [User] if authenticated, null otherwise.
  /// Does not throw exceptions.
  ///
  /// Example:
  /// ```dart
  /// final user = await authDataSource.getCurrentUser();
  /// if (user != null) {
  /// } else {
  /// }
  /// ```
  Future<User?> getCurrentUser();

  /// Refreshes the current session.
  ///
  /// Obtains a new access token using the refresh token.
  /// Throws [AuthException] if refresh fails.
  ///
  /// Example:
  /// ```dart
  /// try {
  ///   await authDataSource.refreshSession();
  /// } on InvalidSessionException {
  /// }
  /// ```
  Future<void> refreshSession();

  /// Gets the current session.
  ///
  /// Returns [Session] if active, null otherwise.
  /// Does not throw exceptions.
  ///
  /// Example:
  /// ```dart
  /// final session = await authDataSource.getSession();
  /// if (session != null) {
  /// }
  /// ```
  Future<Session?> getSession();

  /// Verifies if the current session is valid.
  ///
  /// Checks if user is authenticated and session hasn't expired.
  ///
  /// Example:
  /// ```dart
  /// final isValid = await authDataSource.isSessionValid();
  /// if (isValid) {
  /// } else {
  /// }
  /// ```
  Future<bool> isSessionValid();

  /// Updates the user's email address.
  ///
  /// Sends a confirmation email to the new address.
  /// Throws [AuthException] on failure.
  ///
  /// Example:
  /// ```dart
  /// try {
  ///   await authDataSource.updateEmail('newemail@example.com');
  /// } on EmailAlreadyExistsException {
  /// }
  /// ```
  Future<void> updateEmail(String newEmail);

  /// Listens to authentication state changes.
  ///
  /// Emits events when user signs in, signs out, or token refreshes.
  ///
  /// Example:
  /// ```dart
  /// authDataSource.onAuthStateChange().listen((event) {
  ///   if (event.event == AuthChangeEvent.signedIn) {
  ///   } else if (event.event == AuthChangeEvent.signedOut) {
  ///   }
  /// });
  /// ```
  Stream<AuthState> onAuthStateChange();

  /// Validates username format before signup.
  ///
  /// Returns true if username is valid, false otherwise.
  /// Valid username: 3-20 chars, lowercase, alphanumeric + underscore.
  ///
  /// Example:
  /// ```dart
  /// final isValid = authDataSource.isValidUsername('john_doe');
  /// if (!isValid) {
  /// }
  /// ```
  bool isValidUsername(String username);

  /// Validates email format.
  ///
  /// Returns true if email format is valid, false otherwise.
  ///
  /// Example:
  /// ```dart
  /// final isValid = authDataSource.isValidEmail('user@example.com');
  /// if (!isValid) {
  /// }
  /// ```
  bool isValidEmail(String email);

  /// Validates password strength.
  ///
  /// Returns true if password meets requirements, false otherwise.
  /// Minimum requirement: 6 characters.
  ///
  /// Example:
  /// ```dart
  /// final isValid = authDataSource.isValidPassword('myPassword123');
  /// if (!isValid) {
  /// }
  /// ```
  bool isValidPassword(String password);
}
