// lib/presentation/blocs/auth/auth_bloc.dart

/// Authentication BLoC for handling all auth-related operations.
library;

import 'package:equatable/equatable.dart';
import 'package:gamer_grove/domain/entities/user/user.dart';

// ============================================================
// EVENTS
// ============================================================

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Event to check authentication status on app start.
class CheckAuthStatusEvent extends AuthEvent {
  const CheckAuthStatusEvent();
}

/// Event to sign in with email and password.
class SignInEvent extends AuthEvent {
  final String email;
  final String password;

  const SignInEvent({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}

/// Event to sign up a new user.
class SignUpEvent extends AuthEvent {
  final String email;
  final String password;
  final String username;

  const SignUpEvent({
    required this.email,
    required this.password,
    required this.username,
  });

  @override
  List<Object> get props => [email, password, username];
}

/// Event to sign out the current user.
class SignOutEvent extends AuthEvent {
  const SignOutEvent();
}

/// Event to send password reset email.
class ResetPasswordEvent extends AuthEvent {
  final String email;

  const ResetPasswordEvent({required this.email});

  @override
  List<Object> get props => [email];
}

/// Event to update password.
class UpdatePasswordEvent extends AuthEvent {
  final String newPassword;

  const UpdatePasswordEvent({required this.newPassword});

  @override
  List<Object> get props => [newPassword];
}

/// Event triggered when auth state changes (from stream).
class AuthStateChangedEvent extends AuthEvent {
  final User? user;

  const AuthStateChangedEvent(this.user);

  @override
  List<Object?> get props => [user];
}

/// Event to update user data in the auth state.
class UserDataUpdated extends AuthEvent {
  final User user;

  const UserDataUpdated(this.user);

  @override
  List<Object> get props => [user];
}
