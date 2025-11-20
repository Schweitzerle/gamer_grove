import 'package:dartz/dartz.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import 'package:gamer_grove/domain/entities/user_activity.dart';
import 'package:gamer_grove/domain/repositories/user_activity_repository.dart';

class GetActivityFeedUseCase {

  GetActivityFeedUseCase(this.repository);
  final UserActivityRepository repository;

  Future<Either<Failure, List<UserActivity>>> call(String userId) {
    return repository.getActivityFeed(userId);
  }
}
