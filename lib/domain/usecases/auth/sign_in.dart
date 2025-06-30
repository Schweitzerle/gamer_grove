// domain/usecases/auth/sign_in.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/errors/failures.dart';
import '../../entities/user/user.dart';
import '../../repositories/auth_repository.dart';
import '../base_usecase.dart';

class SignIn extends UseCase<User, SignInParams> {
  final AuthRepository repository;

  SignIn(this.repository);

  @override
  Future<Either<Failure, User>> call(SignInParams params) async {
    // Email validation
    if (!_isValidEmail(params.email)) {
      return const Left(ValidationFailure(message: 'Invalid email format'));
    }

    // Password validation
    if (params.password.isEmpty) {
      return const Left(ValidationFailure(message: 'Password cannot be empty'));
    }

    if (params.password.length < 6) {
      return const Left(ValidationFailure(message: 'Password must be at least 6 characters'));
    }

    return await repository.signIn(
      email: params.email,
      password: params.password,
    );
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}

class SignInParams extends Equatable {
  final String email;
  final String password;

  const SignInParams({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}



