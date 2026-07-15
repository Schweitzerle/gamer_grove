import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import 'package:gamer_grove/domain/entities/user/user.dart';
import 'package:gamer_grove/domain/usecases/auth/get_current_user.dart';
import 'package:gamer_grove/domain/usecases/auth/is_authenticated.dart';
import 'package:gamer_grove/domain/usecases/auth/reset_password.dart';
import 'package:gamer_grove/domain/usecases/auth/sign_in.dart';
import 'package:gamer_grove/domain/usecases/auth/sign_out.dart';
import 'package:gamer_grove/domain/usecases/auth/sign_up.dart';
import 'package:gamer_grove/domain/usecases/auth/update_password.dart';
import 'package:gamer_grove/domain/usecases/usecase.dart';
import 'package:gamer_grove/presentation/blocs/auth/auth_bloc.dart';
import 'package:gamer_grove/presentation/blocs/auth/auth_event.dart';
import 'package:gamer_grove/presentation/blocs/auth/auth_state.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/fixtures.dart';

class _MockSignInUseCase extends Mock implements SignInUseCase {}

class _MockSignUpUseCase extends Mock implements SignUpUseCase {}

class _MockSignOutUseCase extends Mock implements SignOutUseCase {}

class _MockGetCurrentUserUseCase extends Mock
    implements GetCurrentUserUseCase {}

class _MockResetPasswordUseCase extends Mock implements ResetPasswordUseCase {}

class _MockUpdatePasswordUseCase extends Mock
    implements UpdatePasswordUseCase {}

class _MockIsAuthenticatedUseCase extends Mock
    implements IsAuthenticatedUseCase {}

void main() {
  late _MockSignInUseCase signIn;
  late _MockSignUpUseCase signUp;
  late _MockSignOutUseCase signOut;
  late _MockGetCurrentUserUseCase getCurrentUser;
  late _MockResetPasswordUseCase resetPassword;
  late _MockUpdatePasswordUseCase updatePassword;
  late _MockIsAuthenticatedUseCase isAuthenticated;

  final testUser = buildTestUser();

  setUpAll(() {
    registerFallbackValue(const NoParams());
    registerFallbackValue(
      const SignInParams(email: 'a@b.com', password: '123456'),
    );
    registerFallbackValue(
      const SignUpParams(
        email: 'a@b.com',
        password: '123456',
        username: 'tester',
      ),
    );
    registerFallbackValue(const ResetPasswordParams(email: 'a@b.com'));
    registerFallbackValue(const UpdatePasswordParams(newPassword: '123456'));
  });

  setUp(() {
    signIn = _MockSignInUseCase();
    signUp = _MockSignUpUseCase();
    signOut = _MockSignOutUseCase();
    getCurrentUser = _MockGetCurrentUserUseCase();
    resetPassword = _MockResetPasswordUseCase();
    updatePassword = _MockUpdatePasswordUseCase();
    isAuthenticated = _MockIsAuthenticatedUseCase();
  });

  AuthBloc buildBloc() => AuthBloc(
        signInUseCase: signIn,
        signUpUseCase: signUp,
        signOutUseCase: signOut,
        getCurrentUserUseCase: getCurrentUser,
        resetPasswordUseCase: resetPassword,
        updatePasswordUseCase: updatePassword,
        isAuthenticatedUseCase: isAuthenticated,
      );

  test('initial state is AuthInitial', () {
    expect(buildBloc().state, const AuthInitial());
  });

  group('CheckAuthStatusEvent', () {
    blocTest<AuthBloc, AuthState>(
      'emits [Loading, Authenticated] when a user session exists',
      setUp: () => when(() => getCurrentUser(any()))
          .thenAnswer((_) async => Right<Failure, User?>(testUser)),
      build: buildBloc,
      act: (bloc) => bloc.add(const CheckAuthStatusEvent()),
      expect: () => [const AuthLoading(), AuthAuthenticated(testUser)],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [Loading, Unauthenticated] when no user session exists',
      setUp: () => when(() => getCurrentUser(any()))
          .thenAnswer((_) async => const Right<Failure, User?>(null)),
      build: buildBloc,
      act: (bloc) => bloc.add(const CheckAuthStatusEvent()),
      expect: () => [const AuthLoading(), const AuthUnauthenticated()],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [Loading, Unauthenticated] when the lookup fails',
      setUp: () => when(() => getCurrentUser(any())).thenAnswer(
        (_) async => const Left<Failure, User?>(ServerFailure()),
      ),
      build: buildBloc,
      act: (bloc) => bloc.add(const CheckAuthStatusEvent()),
      expect: () => [const AuthLoading(), const AuthUnauthenticated()],
    );
  });

  group('SignInEvent', () {
    blocTest<AuthBloc, AuthState>(
      'emits [Loading, Authenticated] on success',
      setUp: () => when(() => signIn(any()))
          .thenAnswer((_) async => Right<Failure, User>(testUser)),
      build: buildBloc,
      act: (bloc) => bloc.add(
        const SignInEvent(email: 'a@b.com', password: '123456'),
      ),
      expect: () => [const AuthLoading(), AuthAuthenticated(testUser)],
    );

    blocTest<AuthBloc, AuthState>(
      'maps invalid-credentials failure to a friendly message',
      setUp: () => when(() => signIn(any())).thenAnswer(
        (_) async => const Left<Failure, User>(
          AuthenticationFailure(message: 'Invalid login credentials'),
        ),
      ),
      build: buildBloc,
      act: (bloc) => bloc.add(
        const SignInEvent(email: 'a@b.com', password: 'wrongpw'),
      ),
      expect: () => [
        const AuthLoading(),
        const AuthError('Invalid email or password.'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'maps unexpected failures to a generic message',
      setUp: () => when(() => signIn(any())).thenAnswer(
        (_) async => const Left<Failure, User>(ServerFailure()),
      ),
      build: buildBloc,
      act: (bloc) => bloc.add(
        const SignInEvent(email: 'a@b.com', password: '123456'),
      ),
      expect: () => [
        const AuthLoading(),
        const AuthError('An unexpected error occurred. Please try again.'),
      ],
    );
  });

  group('SignUpEvent', () {
    blocTest<AuthBloc, AuthState>(
      'emits [Loading, Authenticated] on success',
      setUp: () => when(() => signUp(any()))
          .thenAnswer((_) async => Right<Failure, User>(testUser)),
      build: buildBloc,
      act: (bloc) => bloc.add(
        const SignUpEvent(
          email: 'a@b.com',
          password: '123456',
          username: 'tester',
        ),
      ),
      expect: () => [const AuthLoading(), AuthAuthenticated(testUser)],
    );

    blocTest<AuthBloc, AuthState>(
      'maps duplicate-user failure to a friendly message',
      setUp: () => when(() => signUp(any())).thenAnswer(
        (_) async => const Left<Failure, User>(
          ServerFailure(message: 'User already exists'),
        ),
      ),
      build: buildBloc,
      act: (bloc) => bloc.add(
        const SignUpEvent(
          email: 'a@b.com',
          password: '123456',
          username: 'tester',
        ),
      ),
      expect: () => [
        const AuthLoading(),
        const AuthError('Email already in use.'),
      ],
    );
  });

  group('SignOutEvent', () {
    blocTest<AuthBloc, AuthState>(
      'emits [Unauthenticated] on success (no loading flicker)',
      setUp: () => when(() => signOut(any()))
          .thenAnswer((_) async => const Right<Failure, void>(null)),
      build: buildBloc,
      act: (bloc) => bloc.add(const SignOutEvent()),
      expect: () => [const AuthUnauthenticated()],
    );
  });

  group('ResetPasswordEvent', () {
    blocTest<AuthBloc, AuthState>(
      'emits [Loading, PasswordResetSent] on success',
      setUp: () => when(() => resetPassword(any()))
          .thenAnswer((_) async => const Right<Failure, void>(null)),
      build: buildBloc,
      act: (bloc) => bloc.add(const ResetPasswordEvent(email: 'a@b.com')),
      expect: () => [const AuthLoading(), const PasswordResetSent()],
    );
  });
}
