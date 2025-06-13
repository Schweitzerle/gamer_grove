// presentation/blocs/auth/auth_bloc.dart
import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/usecases/auth/sign_in.dart';
import '../../../domain/usecases/auth/sign_up.dart';
import '../../../domain/usecases/auth/sign_out.dart';
import '../../../domain/usecases/base_usecase.dart';
import '../../../domain/usecases/auth/get_current_user.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignIn signIn;
  final SignUp signUp;
  final SignOut signOut;
  final GetCurrentUser getCurrentUser;

  StreamSubscription<User?>? _authStateSubscription;

  AuthBloc({
    required this.signIn,
    required this.signUp,
    required this.signOut,
    required this.getCurrentUser,
  }) : super(AuthInitial()) {
    on<SignInRequested>(_onSignInRequested);
    on<SignUpRequested>(_onSignUpRequested);
    on<SignOutRequested>(_onSignOutRequested);
    on<AuthStateChanged>(_onAuthStateChanged);
    on<CheckAuthStatus>(_onCheckAuthStatus);
  }

  Future<void> _onSignInRequested(
      SignInRequested event,
      Emitter<AuthState> emit,
      ) async {
    emit(AuthLoading());

    final result = await signIn(SignInParams(
      email: event.email,
      password: event.password,
    ));

    result.fold(
          (failure) => emit(AuthError(failure.message)),
          (user) => emit(Authenticated(user)),
    );
  }

  Future<void> _onSignUpRequested(
      SignUpRequested event,
      Emitter<AuthState> emit,
      ) async {
    print('🔐 AuthBloc: Starting signup process...');
    print('📧 AuthBloc: Email: ${event.email}');
    print('👤 AuthBloc: Username: ${event.username}');

    emit(AuthLoading());

    try {
      final result = await signUp(SignUpParams(
        email: event.email,
        password: event.password,
        username: event.username,
      ));

      result.fold(
            (failure) {
          print('❌ AuthBloc: Signup failed with failure: ${failure.message}');
          emit(AuthError(failure.message));
        },
            (user) {
          print('✅ AuthBloc: Signup successful for user: ${user.username}');
          emit(Authenticated(user));
        },
      );
    } catch (e, stackTrace) {
      print('💥 AuthBloc: Unexpected error during signup: $e');
      print('📚 AuthBloc: Stack trace: $stackTrace');
      emit(AuthError('Unexpected error during signup: $e'));
    }
  }

  Future<void> _onSignOutRequested(
      SignOutRequested event,
      Emitter<AuthState> emit,
      ) async {
    emit(AuthLoading());

    final result = await signOut();

    result.fold(
          (failure) => emit(AuthError(failure.message)),
          (_) => emit(Unauthenticated()),
    );
  }

  void _onAuthStateChanged(
      AuthStateChanged event,
      Emitter<AuthState> emit,
      ) {
    if (event.user != null) {
      emit(Authenticated(event.user!));
    } else {
      emit(Unauthenticated());
    }
  }

  Future<void> _onCheckAuthStatus(
      CheckAuthStatus event,
      Emitter<AuthState> emit,
      ) async {
    emit(AuthLoading());

    final result = await getCurrentUser();

    result.fold(
          (failure) => emit(Unauthenticated()),
          (user) => emit(Authenticated(user)),
    );
  }


  @override
  Future<void> close() {
    _authStateSubscription?.cancel();
    return super.close();
  }
}

