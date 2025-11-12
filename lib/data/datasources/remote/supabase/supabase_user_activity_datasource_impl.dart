import 'package:gamer_grove/data/datasources/remote/supabase/models/supabase_user_exceptions.dart';
import 'package:gamer_grove/data/models/user_activity_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_user_activity_datasource.dart';

class SupabaseUserActivityDataSourceImpl
    implements SupabaseUserActivityDataSource {
  final SupabaseClient _supabase;

  SupabaseUserActivityDataSourceImpl({required SupabaseClient supabase})
      : _supabase = supabase;

  @override
  Future<List<UserActivityModel>> getActivityFeed(String userId) async {
    try {
      // 1. Get the list of users the current user is following
      final followingResponse = await _supabase
          .from('user_follows')
          .select('following_id')
          .eq('follower_id', userId);

      if (followingResponse.isEmpty) {
        return [];
      }

      final followingIds =
          followingResponse.map((e) => e['following_id'] as String).toList();

      // 2. Fetch activities from the followed users
      final activityResponse = await _supabase
          .from('user_activity')
          .select('*, user:users(*)')
          .inFilter('user_id', followingIds)
          .inFilter('activity_type',
              ['rated', 'updated_top_three', 'recommended', 'wishlisted'])
          .order('created_at', ascending: false)
          .limit(50);

      return activityResponse
          .map((json) => UserActivityModel.fromJson(json))
          .toList();
    } catch (e) {
      throw UserExceptionMapper.map(e);
    }
  }
}
