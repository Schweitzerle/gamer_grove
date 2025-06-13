// presentation/blocs/auth/auth_bloc.dart
import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/usecases/auth/sign_in.dart';
import '../../../domain/usecases/auth/sign_up.dart';
import '../../../domain/usecases/auth/sign_out.dart';
import '../../../domain/usecases/base_usecase.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignIn signIn;
  final SignUp signUp;
  final SignOut signOut;

  StreamSubscription<User?>? _authStateSubscription;

  AuthBloc({
    required this.signIn,
    required this.signUp,
    required this.signOut,
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
    emit(AuthLoading());

    final result = await signUp(SignUpParams(
      email: event.email,
      password: event.password,
      username: event.username,
    ));

    result.fold(
          (failure) => emit(AuthError(failure.message)),
          (user) => emit(Authenticated(user)),
    );
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

    // Try to get current user
    final result = await getCurrentUser(const NoParams());

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

@override
Future<UserModel?> getCurrentUser() async {
  try {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      return null;
    }

    // Get full profile data
    return await getUserProfile(user.id);
  } catch (e) {
    // Return null if user is not authenticated or profile doesn't exist
    return null;
  }
}

@override
Future<Either<Failure, domain.User>> getCurrentUser() async {
  try {
    // Check if network is available for remote check
    if (await networkInfo.isConnected) {
      // Try to get from remote first
      final user = await remoteDataSource.getCurrentUser();
      if (user != null) {
        // Cache the user
        await localDataSource.cacheUser(user);
        return Right(user);
      }
    }

    // If no remote user, try cache
    final cachedUser = await localDataSource.getCachedUser();
    if (cachedUser != null) {
      return Right(cachedUser);
    }

    // No user found anywhere
    return const Left(AuthenticationFailure(message: 'No user logged in'));
  } catch (e) {
    return const Left(AuthenticationFailure(message: 'Failed to get current user'));
  }
}