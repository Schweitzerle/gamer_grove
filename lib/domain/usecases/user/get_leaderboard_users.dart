import 'package:dartz/dartz.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import 'package:gamer_grove/domain/entities/user/user.dart';
import 'package:gamer_grove/domain/repositories/user_repository.dart';

class GetLeaderboardUsersUseCase {

  GetLeaderboardUsersUseCase(this.repository);
  final UserRepository repository;

  Future<Either<Failure, List<User>>> call() {
    return repository.getLeaderboardUsers();
  }
}
