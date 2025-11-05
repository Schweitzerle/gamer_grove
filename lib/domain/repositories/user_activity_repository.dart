import 'package:dartz/dartz.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import 'package:gamer_grove/domain/entities/user_activity.dart';

abstract class UserActivityRepository {
  Future<Either<Failure, List<UserActivity>>> getActivityFeed(String userId);
}
