import 'package:dartz/dartz.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import 'package:gamer_grove/data/datasources/remote/supabase/supabase_user_activity_datasource.dart';
import 'package:gamer_grove/data/repositories/base/supabase_base_repository.dart';
import 'package:gamer_grove/domain/entities/user_activity.dart';
import 'package:gamer_grove/domain/repositories/user_activity_repository.dart';

class UserActivityRepositoryImpl extends SupabaseBaseRepository implements UserActivityRepository {

  UserActivityRepositoryImpl({
    required this.dataSource,
    required super.supabase,
    required super.networkInfo,
  });
  final SupabaseUserActivityDataSource dataSource;

  @override
  Future<Either<Failure, List<UserActivity>>> getActivityFeed(String userId) {
    return executeSupabaseOperation(
      operation: () async {
        final activityData = await dataSource.getActivityFeed(userId);
        return activityData;
      },
      errorMessage: 'Failed to get activity feed',
    );
  }
}
