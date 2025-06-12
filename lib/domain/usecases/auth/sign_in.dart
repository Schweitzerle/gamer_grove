// domain/usecases/auth/sign_up.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/errors/failures.dart';
import '../../entities/user.dart';
import '../../repositories/auth_repository.dart';
import '../base_usecase.dart';

class SignUp extends UseCase<User, SignUpParams> {
  final AuthRepository repository;

  SignUp(this.repository);

  @override
  Future<Either<Failure, User>> call(SignUpParams params) async {
    // Email validation
    if (!_isValidEmail(params.email)) {
      return const Left(ValidationFailure(message: 'Invalid email format'));
    }

    // Password validation
    if (params.password.length < 6) {
      return const Left(ValidationFailure(message: 'Password must be at least 6 characters'));
    }

    // Username validation
    if (params.username.length < 3) {
      return const Left(ValidationFailure(message: 'Username must be at least 3 characters'));
    }

    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(params.username)) {
      return const Left(ValidationFailure(
        message: 'Username can only contain letters, numbers, and underscores',
      ));
    }

    return await repository.signUp(
      email: params.email,
      password: params.password,
      username: params.username,
    );
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}

class SignUpParams extends Equatable {
  final String email;
  final String password;
  final String username;

  const SignUpParams({
    required this.email,
    required this.password,
    required this.username,
  });

  @override
  List<Object> get props => [email, password, username];
}

