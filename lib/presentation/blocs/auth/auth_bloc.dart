// ============================================================
// BLOC
// ============================================================

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamer_grove/domain/usecases/auth/get_current_user.dart';
import 'package:gamer_grove/domain/usecases/auth/is_authenticated.dart';
import 'package:gamer_grove/domain/usecases/auth/reset_password.dart';
import 'package:gamer_grove/domain/usecases/auth/sign_in.dart';
import 'package:gamer_grove/domain/usecases/auth/sign_out.dart';
import 'package:gamer_grove/domain/usecases/auth/sign_up.dart';
import 'package:gamer_grove/domain/usecases/auth/update_password.dart';
import 'package:gamer_grove/domain/usecases/usecase.dart';
import 'package:gamer_grove/presentation/blocs/auth/auth_event.dart';
import 'package:gamer_grove/presentation/blocs/auth/auth_state.dart';

/// BLoC for handling authentication operations.
///
/// Uses use cases to execute auth operations and manages auth state.
///
/// Example:
/// ```dart
/// // In UI
/// context.read<AuthBloc>().add(SignInEvent(
///   email: emailController.text,
///   password: passwordController.text,
/// ));
///
/// // Listen to state
/// BlocListener<AuthBloc, AuthState>(
///   listener: (context, state) {
///     if (state is AuthAuthenticated) {
///       Navigator.pushReplacementNamed(context, '/home');
///     } else if (state is AuthError) {
///       ScaffoldMessenger.of(context).showSnackBar(
///         SnackBar(content: Text(state.message)),
///       );
///     }
///   },
///   child: YourWidget(),
/// )
/// ```
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInUseCase signInUseCase;
  final SignUpUseCase signUpUseCase;
  final SignOutUseCase signOutUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final ResetPasswordUseCase resetPasswordUseCase;
  final UpdatePasswordUseCase updatePasswordUseCase;
  final IsAuthenticatedUseCase isAuthenticatedUseCase;

  AuthBloc({
    required this.signInUseCase,
    required this.signUpUseCase,
    required this.signOutUseCase,
    required this.getCurrentUserUseCase,
    required this.resetPasswordUseCase,
    required this.updatePasswordUseCase,
    required this.isAuthenticatedUseCase,
  }) : super(const AuthInitial()) {
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<SignInEvent>(_onSignIn);
    on<SignUpEvent>(_onSignUp);
    on<SignOutEvent>(_onSignOut);
    on<ResetPasswordEvent>(_onResetPassword);
    on<UpdatePasswordEvent>(_onUpdatePassword);
    on<AuthStateChangedEvent>(_onAuthStateChanged);
  }

  /// Checks if user is authenticated on app start.
  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await getCurrentUserUseCase(const NoParams());

    result.fold(
      (failure) => emit(const AuthUnauthenticated()),
      (user) {
        if (user != null) {
          emit(AuthAuthenticated(user));
        } else {
          emit(const AuthUnauthenticated());
        }
      },
    );
  }

  /// Handles sign in event.
  Future<void> _onSignIn(
    SignInEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await signInUseCase(
      SignInParams(
        email: event.email,
        password: event.password,
      ),
    );

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  /// Handles sign up event.
  Future<void> _onSignUp(
    SignUpEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await signUpUseCase(
      SignUpParams(
        email: event.email,
        password: event.password,
        username: event.username,
      ),
    );

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  /// Handles sign out event.
  Future<void> _onSignOut(
    SignOutEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await signOutUseCase(const NoParams());

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(const AuthUnauthenticated()),
    );
  }

  /// Handles password reset event.
  Future<void> _onResetPassword(
    ResetPasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await resetPasswordUseCase(
      ResetPasswordParams(email: event.email),
    );

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(const PasswordResetSent()),
    );
  }

  /// Handles password update event.
  Future<void> _onUpdatePassword(
    UpdatePasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    // Keep current user while updating
    final currentState = state;

    emit(const AuthLoading());

    final result = await updatePasswordUseCase(
      UpdatePasswordParams(newPassword: event.newPassword),
    );

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) {
        // Restore authenticated state after password update
        if (currentState is AuthAuthenticated) {
          emit(const PasswordUpdated());
          // Optionally re-emit authenticated state
          emit(AuthAuthenticated(currentState.user));
        } else {
          emit(const PasswordUpdated());
        }
      },
    );
  }

  /// Handles auth state changes from stream.
  Future<void> _onAuthStateChanged(
    AuthStateChangedEvent event,
    Emitter<AuthState> emit,
  ) async {
    if (event.user != null) {
      emit(AuthAuthenticated(event.user!));
    } else {
      emit(const AuthUnauthenticated());
    }
  }
}
