// domain/usecases/auth/reset_password.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/errors/failures.dart';
import '../../repositories/auth_repository.dart';
import '../base_usecase.dart';

class ResetPassword extends UseCase<void, ResetPasswordParams> {
  final AuthRepository repository;

  ResetPassword(this.repository);

  @override
  Future<Either<Failure, void>> call(ResetPasswordParams params) async {
    if (!_isValidEmail(params.email)) {
      return const Left(ValidationFailure(message: 'Invalid email format'));
    }

    return await repository.resetPassword(params.email);
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}

class ResetPasswordParams extends Equatable {
  final String email;

  const ResetPasswordParams({required this.email});

  @override
  List<Object> get props => [email];
}

