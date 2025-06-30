// domain/usecases/auth/get_current_user.dart
import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/user/user.dart';
import '../../repositories/auth_repository.dart';
import '../base_usecase.dart';

class GetCurrentUser extends NoParamsUseCase<User> {
  final AuthRepository repository;

  GetCurrentUser(this.repository);

  @override
  Future<Either<Failure, User>> call() async {
    return await repository.getCurrentUser();
  }
}