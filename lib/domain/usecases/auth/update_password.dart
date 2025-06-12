// domain/usecases/auth/update_password.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/errors/failures.dart';
import '../../repositories/auth_repository.dart';
import '../base_usecase.dart';

class UpdatePassword extends UseCase<void, UpdatePasswordParams> {
  final AuthRepository repository;

  UpdatePassword(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdatePasswordParams params) async {
    if (params.currentPassword.isEmpty || params.newPassword.isEmpty) {
      return const Left(ValidationFailure(message: 'Passwords cannot be empty'));
    }

    if (params.newPassword.length < 6) {
      return const Left(ValidationFailure(message: 'New password must be at least 6 characters'));
    }

    if (params.currentPassword == params.newPassword) {
      return const Left(ValidationFailure(message: 'New password must be different from current password'));
    }

    return await repository.updatePassword(
      currentPassword: params.currentPassword,
      newPassword: params.newPassword,
    );
  }
}

class UpdatePasswordParams extends Equatable {
  final String currentPassword;
  final String newPassword;

  const UpdatePasswordParams({
    required this.currentPassword,
    required this.newPassword,
  });

  @override
  List<Object> get props => [currentPassword, newPassword];
}