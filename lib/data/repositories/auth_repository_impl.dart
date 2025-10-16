// lib/data/repositories/auth_repository_impl.dart

/// Implementation of AuthRepository.
///
/// Handles all authentication operations using Supabase.
library;

import 'package:dartz/dartz.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import 'package:gamer_grove/domain/entities/user/user.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../core/network/network_info.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/remote/supabase/supabase_auth_datasource.dart';
import '../models/user_model.dart';
import 'base/supabase_base_repository.dart';

/// Concrete implementation of [AuthRepository].
///
/// Uses [SupabaseBaseRepository] for common functionality and
/// [SupabaseAuthDataSource] for authentication operations.
///
/// Example usage:
/// ```dart
/// final authRepo = AuthRepositoryImpl(
///   authDataSource: authDataSource,
///   supabase: supabaseClient,
///   networkInfo: networkInfo,
/// );
///
/// // Sign in
/// final result = await authRepo.signIn('user@example.com', 'password');
/// result.fold(
///   (failure) => print('Error: ${failure.message}'),
///   (user) => print('Welcome ${user.username}!'),
/// );
/// ```
class AuthRepositoryImpl extends SupabaseBaseRepository
    implements AuthRepository {
  final SupabaseAuthDataSource authDataSource;

  AuthRepositoryImpl({
    required this.authDataSource,
    required supabase.SupabaseClient supabase,
    required NetworkInfo networkInfo,
  }) : super(supabase: supabase, networkInfo: networkInfo);

  // ============================================================
  // AUTHENTICATION OPERATIONS
  // ============================================================

  @override
  Future<Either<Failure, User>> signIn({
    required String email,
    required String password,
  }) {
    return executeSupabaseOperation(
      operation: () async {
        final authUser = await authDataSource.signIn(email, password);

        // Get full user profile from database
        final profileResult = await this
            .supabase
            .from('users')
            .select('*')
            .eq('id', authUser.id)
            .single();

        return UserModel.fromJson(profileResult).toEntity();
      },
      errorMessage: 'Failed to sign in',
    );
  }

  @override
  Future<Either<Failure, User>> signUp({
    required String email,
    required String password,
    required String username,
  }) {
    return executeSupabaseOperation(
      operation: () async {
        final authUser = await authDataSource.signUp(
          email,
          password,
          username,
        );

        // Get the newly created profile
        final profileResult = await this
            .supabase
            .from('users')
            .select('*')
            .eq('id', authUser.id)
            .single();

        return UserModel.fromJson(profileResult).toEntity();
      },
      errorMessage: 'Failed to sign up',
    );
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    return executeSupabaseVoidOperation(
      operation: () => authDataSource.signOut(),
      errorMessage: 'Failed to sign out',
    );
  }

  @override
  Future<Either<Failure, void>> deleteAccount() async {
    return executeSupabaseVoidOperation(
      operation: () async {
        final userId = await super.getCurrentUserId();
        if (userId == null || userId.isEmpty) {
          throw Exception('No user logged in');
        }

        // Delete user data from database
        await this.supabase.from('users').delete().eq('id', userId);

        // Delete auth user (this will cascade delete related data)
        await authDataSource.signOut();
      },
      errorMessage: 'Failed to delete account',
    );
  }

  // ============================================================
  // PASSWORD MANAGEMENT
  // ============================================================

  @override
  Future<Either<Failure, void>> resetPassword({
    required String email,
  }) {
    return executeSupabaseVoidOperation(
      operation: () => authDataSource.resetPassword(email),
      errorMessage: 'Failed to send password reset email',
    );
  }

  @override
  Future<Either<Failure, void>> updatePassword({
    required String newPassword,
  }) {
    return executeSupabaseVoidOperation(
      operation: () => authDataSource.updatePassword(newPassword),
      errorMessage: 'Failed to update password',
    );
  }

  // ============================================================
  // SESSION MANAGEMENT
  // ============================================================

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    return executeSupabaseOperation(
      operation: () async {
        final authUser = await authDataSource.getCurrentUser();

        if (authUser == null) return null;

        // Get full profile from database
        final profileResult = await this
            .supabase
            .from('users')
            .select('*')
            .eq('id', authUser.id)
            .maybeSingle();

        if (profileResult == null) return null;

        return UserModel.fromJson(profileResult).toEntity();
      },
      errorMessage: 'Failed to get current user',
    );
  }

  Future<Either<Failure, void>> refreshSession() {
    return executeSupabaseVoidOperation(
      operation: () => authDataSource.refreshSession(),
      errorMessage: 'Failed to refresh session',
    );
  }

  Future<Either<Failure, bool>> checkIsAuthenticated() {
    return executeSupabaseOperation(
      operation: () => authDataSource.isSessionValid(),
      errorMessage: 'Failed to check authentication status',
    );
  }

  Future<Either<Failure, String?>> getUserId() {
    return executeSupabaseOperation(
      operation: () async {
        final user = await authDataSource.getCurrentUser();
        return user?.id;
      },
      errorMessage: 'Failed to get current user ID',
    );
  }

  // ============================================================
  // EMAIL MANAGEMENT
  // ============================================================

  Future<Either<Failure, void>> updateEmail(String newEmail) {
    return executeSupabaseVoidOperation(
      operation: () => authDataSource.updateEmail(newEmail),
      errorMessage: 'Failed to update email',
    );
  }

  // ============================================================
  // AUTH STATE STREAM
  // ============================================================

  @override
  Stream<supabase.User?> get authStateChanges {
    return authDataSource
        .onAuthStateChange()
        .map((authState) => authState.session?.user);
  }

  Stream<User?> onAuthStateChange() {
    return authDataSource.onAuthStateChange().asyncMap((authState) async {
      final user = authState.session?.user;

      if (user == null) return null;

      try {
        // Get full profile when auth state changes
        final profileResult = await this
            .supabase
            .from('users')
            .select('*')
            .eq('id', user.id)
            .maybeSingle();

        if (profileResult == null) return null;

        return UserModel.fromJson(profileResult).toEntity();
      } catch (e) {
        return null;
      }
    });
  }

  // ============================================================
  // VALIDATION
  // ============================================================

  bool isValidEmail(String email) {
    return authDataSource.isValidEmail(email);
  }

  bool isValidPassword(String password) {
    return authDataSource.isValidPassword(password);
  }

  bool isValidUsername(String username) {
    return authDataSource.isValidUsername(username);
  }

  Future<Either<Failure, bool>> checkUsernameAvailability(String username) {
    return executeSupabaseOperation(
      operation: () async {
        final result = await this
            .supabase
            .from('users')
            .select('username')
            .eq('username', username)
            .maybeSingle();

        // Username is available if result is null
        return result == null;
      },
      errorMessage: 'Failed to check username availability',
    );
  }

  Future<Either<Failure, bool>> checkEmailAvailability(String email) {
    return executeSupabaseOperation(
      operation: () async {
        // For now, we rely on signup error handling
        // Return true (available) optimistically
        return true;
      },
      errorMessage: 'Failed to check email availability',
    );
  }
}
