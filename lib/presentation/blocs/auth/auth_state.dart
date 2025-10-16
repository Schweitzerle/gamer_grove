// ============================================================
// STATES
// ============================================================

import 'package:equatable/equatable.dart';
import 'package:gamer_grove/domain/entities/user/user.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any auth check.
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Loading state during auth operations.
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// State when user is authenticated.
class AuthAuthenticated extends AuthState {
  final User user;

  const AuthAuthenticated(this.user);

  @override
  List<Object> get props => [user];
}

/// State when user is not authenticated.
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// State when auth operation fails.
class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object> get props => [message];
}

/// State when password reset email is sent.
class PasswordResetSent extends AuthState {
  const PasswordResetSent();
}

/// State when password is successfully updated.
class PasswordUpdated extends AuthState {
  const PasswordUpdated();
}
