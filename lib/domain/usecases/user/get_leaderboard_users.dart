import 'package:dartz/dartz.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import 'package:gamer_grove/domain/entities/user/user.dart';
import 'package:gamer_grove/domain/repositories/user_repository.dart';

class GetLeaderboardUsersUseCase {
  final UserRepository repository;

  GetLeaderboardUsersUseCase(this.repository);

  Future<Either<Failure, List<User>>> call() {
    return repository.getLeaderboardUsers();
  }
}
