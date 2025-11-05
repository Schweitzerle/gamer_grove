import 'package:gamer_grove/data/models/user_activity_model.dart';

abstract class SupabaseUserActivityDataSource {
  Future<List<UserActivityModel>> getActivityFeed(String userId);
}
