// domain/usecases/auth/sign_out.dart
import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../repositories/auth_repository.dart';
import '../base_usecase.dart';

class SignOut extends NoParamsUseCase<void> {
  final AuthRepository repository;

  SignOut(this.repository);

  @override
  Future<Either<Failure, void>> call() async {
    return await repository.signOut();
  }
}
