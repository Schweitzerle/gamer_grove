// lib/data/datasources/remote/supabase/supabase_remote_datasource_impl.dart - EXTENDED VERSION
import 'package:gamer_grove/data/datasources/remote/supabase/supabase_remote_datasource.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;
import '../../../../core/errors/exceptions.dart';
import '../../../../domain/entities/game/game_sort_options.dart';
import '../../../../domain/entities/user/user_collection_sort_options.dart';
import '../../../../domain/entities/user/user_gaming_activity.dart';
import '../../../../domain/entities/user/user_relationship.dart';
import '../../../../domain/entities/user/user_collection_filters.dart';
import '../../../models/user_model.dart';

class SupabaseRemoteDataSourceImpl implements SupabaseRemoteDataSource {
  final SupabaseClient client;

  SupabaseRemoteDataSourceImpl({required this.client});

  // ==========================================
  // GAME COLLECTIONS - BASIC METHODS
  // ==========================================

  @override
  Future<List<int>> getUserWishlistIds(String userId) async {
    try {
      final response = await client
          .from('user_games')
          .select('game_id')
          .eq('user_id', userId)
          .eq('is_wishlisted', true)
          .order('wishlisted_at', ascending: false);

      return response.map<int>((item) => item['game_id'] as int).toList();
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to get wishlist IDs');
    }
  }

  @override
  Future<List<int>> getUserRecommendedIds(String userId) async {
    try {
      final response = await client
          .from('user_games')
          .select('game_id')
          .eq('user_id', userId)
          .eq('is_recommended', true)
          .order('recommended_at', ascending: false);

      return response.map<int>((item) => item['game_id'] as int).toList();
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to get recommended IDs');
    }
  }

  @override
  Future<List<int>> getUserRatedIds(String userId) async {
    try {
      final response = await client
          .from('user_games')
          .select('game_id')
          .eq('user_id', userId)
          .eq('is_rated', true)
          .order('rated_at', ascending: false);

      return response.map<int>((item) => item['game_id'] as int).toList();
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to get rated IDs');
    }
  }


  @override
  Future<Map<String, dynamic>?> getUserGameData(String userId, int gameId) async {
    try {
      final response = await client
          .from('user_games')
          .select('*')
          .eq('user_id', userId)
          .eq('game_id', gameId)
          .maybeSingle();

      return response;
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to get user game data');
    }
  }

  @override
  Future<Map<int, Map<String, dynamic>>> getBatchUserGameData(List<int> gameIds, String userId) async {
    try {
      final response = await client
          .from('user_games')
          .select('*')
          .eq('user_id', userId)
          .inFilter('game_id', gameIds);

      final Map<int, Map<String, dynamic>> result = {};
      for (final item in response) {
        result[item['game_id'] as int] = item;
      }

      return result;
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to get batch user game data');
    }
  }

  // ==========================================
  // GAME ACTIONS
  // ==========================================

  @override
  Future<void> toggleWishlist(int gameId, String userId) async {
    try {
      // Check if game is already in wishlist
      final existing = await client
          .from('user_games')
          .select('is_wishlisted')
          .eq('user_id', userId)
          .eq('game_id', gameId)
          .maybeSingle();

      if (existing != null) {
        // Update existing record
        final newWishlistStatus = !(existing['is_wishlisted'] as bool? ?? false);
        await client
            .from('user_games')
            .update({
          'is_wishlisted': newWishlistStatus,
          'wishlisted_at': newWishlistStatus ? DateTime.now().toIso8601String() : null,
          'updated_at': DateTime.now().toIso8601String(),
        })
            .eq('user_id', userId)
            .eq('game_id', gameId);
      } else {
        // Insert new record
        await client
            .from('user_games')
            .insert({
          'user_id': userId,
          'game_id': gameId,
          'is_wishlisted': true,
          'wishlisted_at': DateTime.now().toIso8601String(),
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
      }
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to toggle wishlist');
    }
  }

  @override
  Future<void> toggleRecommended(int gameId, String userId) async {
    try {
      // Check if game is already recommended
      final existing = await client
          .from('user_games')
          .select('is_recommended')
          .eq('user_id', userId)
          .eq('game_id', gameId)
          .maybeSingle();

      if (existing != null) {
        // Update existing record
        final newRecommendStatus = !(existing['is_recommended'] as bool? ?? false);
        await client
            .from('user_games')
            .update({
          'is_recommended': newRecommendStatus,
          'recommended_at': newRecommendStatus ? DateTime.now().toIso8601String() : null,
          'updated_at': DateTime.now().toIso8601String(),
        })
            .eq('user_id', userId)
            .eq('game_id', gameId);
      } else {
        // Insert new record
        await client
            .from('user_games')
            .insert({
          'user_id': userId,
          'game_id': gameId,
          'is_recommended': true,
          'recommended_at': DateTime.now().toIso8601String(),
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
      }
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to toggle recommended');
    }
  }

  @override
  Future<void> rateGame(int gameId, String userId, double rating) async {
    try {
      // Check if game is already rated
      final existing = await client
          .from('user_games')
          .select('id')
          .eq('user_id', userId)
          .eq('game_id', gameId)
          .maybeSingle();

      if (existing != null) {
        // Update existing record
        await client
            .from('user_games')
            .update({
          'rating': rating,
          'is_rated': true,
          'rated_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        })
            .eq('user_id', userId)
            .eq('game_id', gameId);
      } else {
        // Insert new record
        await client
            .from('user_games')
            .insert({
          'user_id': userId,
          'game_id': gameId,
          'rating': rating,
          'is_rated': true,
          'rated_at': DateTime.now().toIso8601String(),
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
      }
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to rate game');
    }
  }

  // ==========================================
  // ENHANCED COLLECTIONS WITH FILTERS
  // ==========================================

  // Korrigierte Versionen der problematischen Funktionen

  @override
  Future<List<Map<String, dynamic>>> getUserWishlistWithFilters({
    required String userId,
    required UserCollectionFilters filters,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      // Verwenden Sie 'dynamic' anstatt 'PostgrestFilterBuilder'
      dynamic query = client
          .from('user_games')
          .select('game_id, wishlisted_at, created_at, updated_at')
          .eq('user_id', userId)
          .eq('is_wishlisted', true);

      // Apply date filters
      if (filters.hasReleaseDateFilter) {
        if (filters.releaseDateFrom != null) {
          query = query.gte('wishlisted_at', filters.releaseDateFrom!.toIso8601String());
        }
        if (filters.releaseDateTo != null) {
          query = query.lte('wishlisted_at', filters.releaseDateTo!.toIso8601String());
        }
      }

      // Apply sorting
      switch (filters.sortBy) {
        case UserCollectionSortBy.dateAdded:
          query = query.order('wishlisted_at', ascending: filters.sortOrder == SortOrder.ascending);
          break;
        case UserCollectionSortBy.alphabetical:
        case UserCollectionSortBy.name:
        // Note: Game name sorting would need to be done after fetching game data
          query = query.order('wishlisted_at', ascending: false);
          break;
        default:
          query = query.order('wishlisted_at', ascending: false);
          break;
      }

      final response = await query.range(offset, offset + limit - 1);
      return response.cast<Map<String, dynamic>>();
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to get wishlist with filters');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getUserRatedGamesWithFilters({
    required String userId,
    required UserCollectionFilters filters,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      dynamic query = client
          .from('user_games')
          .select('game_id, rating, rated_at, created_at, updated_at')
          .eq('user_id', userId)
          .eq('is_rated', true);

      // Apply user rating filters
      if (filters.hasUserRatingFilter) {
        if (filters.minUserRating != null) {
          query = query.gte('rating', filters.minUserRating!);
        }
        if (filters.maxUserRating != null) {
          query = query.lte('rating', filters.maxUserRating!);
        }
      }

      // Apply date filters
      if (filters.hasReleaseDateFilter) {
        if (filters.releaseDateFrom != null) {
          query = query.gte('rated_at', filters.releaseDateFrom!.toIso8601String());
        }
        if (filters.releaseDateTo != null) {
          query = query.lte('rated_at', filters.releaseDateTo!.toIso8601String());
        }
      }

      // Apply sorting
      switch (filters.sortBy) {
        case UserCollectionSortBy.rating:
          query = query.order('rating', ascending: filters.sortOrder == SortOrder.ascending);
          break;
        case UserCollectionSortBy.dateAdded:
          query = query.order('rated_at', ascending: filters.sortOrder == SortOrder.ascending);
          break;
        default:
          query = query.order('rated_at', ascending: false);
          break;
      }

      final response = await query.range(offset, offset + limit - 1);
      return response.cast<Map<String, dynamic>>();
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to get rated games with filters');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getUserRecommendedGamesWithFilters({
    required String userId,
    required UserCollectionFilters filters,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      dynamic query = client
          .from('user_games')
          .select('game_id, recommended_at, created_at, updated_at')
          .eq('user_id', userId)
          .eq('is_recommended', true);

      // Apply date filters
      if (filters.hasReleaseDateFilter) {
        if (filters.releaseDateFrom != null) {
          query = query.gte('recommended_at', filters.releaseDateFrom!.toIso8601String());
        }
        if (filters.releaseDateTo != null) {
          query = query.lte('recommended_at', filters.releaseDateTo!.toIso8601String());
        }
      }

      // Apply sorting
      switch (filters.sortBy) {
        case UserCollectionSortBy.dateAdded:
          query = query.order('recommended_at', ascending: filters.sortOrder == SortOrder.ascending);
          break;
        default:
          query = query.order('recommended_at', ascending: false);
          break;
      }

      final response = await query.range(offset, offset + limit - 1);
      return response.cast<Map<String, dynamic>>();
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to get recommended games with filters');
    }
  }
  

  @override
  Future<Map<String, dynamic>> getUserCollectionStatistics({
    required String userId,
    required UserCollectionType collectionType,
  }) async {
    try {
      String condition;
      switch (collectionType) {
        case UserCollectionType.wishlist:
          condition = 'is_wishlisted.eq.true';
          break;
        case UserCollectionType.rated:
          condition = 'is_rated.eq.true';
          break;
        case UserCollectionType.recommended:
          condition = 'is_recommended.eq.true';
          break;
        case UserCollectionType.topThree:
        // Handle top three separately
          final topThreeResponse = await client
              .from('user_top_three')
              .select('game_id')
              .eq('user_id', userId);

          return {
            'total_count': topThreeResponse.length,
            'average_rating': null,
            'average_game_rating': null,
            'genre_breakdown': <String, int>{},
            'platform_breakdown': <String, int>{},
            'year_breakdown': <int, int>{},
            'recently_added_count': 0,
            'last_updated': DateTime.now().toIso8601String(),
          };
      }

      final response = await client.rpc('get_collection_statistics', params: {
        'user_id': userId,
        'collection_type': collectionType.name,
      });

      return response as Map<String, dynamic>;
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to get collection statistics');
    }
  }

  @override
  Future<Map<String, dynamic>> getUserGamingStatistics(String userId) async {
    try {
      final response = await client.rpc('get_user_gaming_statistics', params: {
        'user_id': userId,
      });

      return response as Map<String, dynamic>;
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to get gaming statistics');
    }
  }

  // ==========================================
  // BATCH OPERATIONS
  // ==========================================

  @override
  Future<void> batchAddToWishlist(String userId, List<int> gameIds) async {
    try {
      final insertData = gameIds.map((gameId) => {
        'user_id': userId,
        'game_id': gameId,
        'is_wishlisted': true,
        'wishlisted_at': DateTime.now().toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }).toList();

      await client.from('user_games').upsert(insertData);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to batch add to wishlist');
    }
  }

  @override
  Future<void> batchRateGames(String userId, Map<int, double> gameRatings) async {
    try {
      final insertData = gameRatings.entries.map((entry) => {
        'user_id': userId,
        'game_id': entry.key,
        'rating': entry.value,
        'is_rated': true,
        'rated_at': DateTime.now().toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }).toList();

      await client.from('user_games').upsert(insertData);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to batch rate games');
    }
  }

  @override
  Future<void> batchRemoveFromWishlist(String userId, List<int> gameIds) async {
    try {
      await client
          .from('user_games')
          .update({
        'is_wishlisted': false,
        'wishlisted_at': null,
        'updated_at': DateTime.now().toIso8601String(),
      })
          .eq('user_id', userId)
          .inFilter('game_id', gameIds);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to batch remove from wishlist');
    }
  }

  @override
  Future<void> moveGamesBetweenCollections({
    required String userId,
    required List<int> gameIds,
    required UserCollectionType fromCollection,
    required UserCollectionType toCollection,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      // Remove from source collection
      switch (fromCollection) {
        case UserCollectionType.wishlist:
          updateData['is_wishlisted'] = false;
          updateData['wishlisted_at'] = null;
          break;
        case UserCollectionType.recommended:
          updateData['is_recommended'] = false;
          updateData['recommended_at'] = null;
          break;
        default:
          break;
      }

      // Add to destination collection
      switch (toCollection) {
        case UserCollectionType.wishlist:
          updateData['is_wishlisted'] = true;
          updateData['wishlisted_at'] = DateTime.now().toIso8601String();
          break;
        case UserCollectionType.recommended:
          updateData['is_recommended'] = true;
          updateData['recommended_at'] = DateTime.now().toIso8601String();
          break;
        default:
          break;
      }

      await client
          .from('user_games')
          .update(updateData)
          .eq('user_id', userId)
          .inFilter('game_id', gameIds);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to move games between collections');
    }
  }

  // ==========================================
  // USER ACTIVITY & ANALYTICS
  // ==========================================

  @override
  Future<List<Map<String, dynamic>>> getRecentlyAddedToCollections({
    required String userId,
    required DateTime sinceDate,
    int limit = 50,
  }) async {
    try {
      final response = await client
          .from('user_games')
          .select('game_id, created_at, is_wishlisted, is_rated, is_recommended')
          .eq('user_id', userId)
          .or('is_wishlisted.eq.true,is_rated.eq.true,is_recommended.eq.true')
          .gte('created_at', sinceDate.toIso8601String())
          .order('created_at', ascending: false)
          .limit(limit);

      return response.cast<Map<String, dynamic>>();
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to get recently added games');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getUserTopGenres(String userId, {int limit = 10}) async {
    try {
      final response = await client.rpc('get_user_top_genres', params: {
        'user_id': userId,
        'limit_count': limit,
      });

      return (response as List).cast<Map<String, dynamic>>();
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to get top genres');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getUserActivityTimeline({
    required String userId,
    required DateTime fromDate,
    required DateTime toDate,
    int limit = 50,
  }) async {
    try {
      final response = await client
          .from('user_activity_log')
          .select('*')
          .eq('user_id', userId)
          .gte('created_at', fromDate.toIso8601String())
          .lte('created_at', toDate.toIso8601String())
          .order('created_at', ascending: false)
          .limit(limit);

      return response.cast<Map<String, dynamic>>();
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to get activity timeline');
    }
  }

  @override
  Future<Map<String, double>> getUserGenrePreferences(String userId) async {
    try {
      final response = await client.rpc('get_user_genre_preferences', params: {
        'user_id': userId,
      });

      return Map<String, double>.from(response);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to get genre preferences');
    }
  }

  @override
  Future<Map<String, int>> getUserPlatformStatistics(String userId) async {
    try {
      final response = await client.rpc('get_user_platform_statistics', params: {
        'user_id': userId,
      });

      return Map<String, int>.from(response);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to get platform statistics');
    }
  }

  @override
  Future<Map<String, dynamic>> getUserRatingAnalytics(String userId) async {
    try {
      final response = await client.rpc('get_user_rating_analytics', params: {
        'user_id': userId,
      });

      return response as Map<String, dynamic>;
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to get rating analytics');
    }
  }

  @override
  Future<Map<String, dynamic>> getUserGamingPatternAnalysis(String userId) async {
    try {
      final response = await client.rpc('get_user_gaming_pattern_analysis', params: {
        'user_id': userId,
      });

      return response as Map<String, dynamic>;
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to get gaming pattern analysis');
    }
  }

  @override
  Future<Map<String, dynamic>> getUserGamingProfile(String userId) async {
    try {
      final response = await client.rpc('get_user_gaming_profile', params: {
        'user_id': userId,
      });

      return response as Map<String, dynamic>;
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to get gaming profile');
    }
  }

  // ==========================================
  // RECOMMENDATION SUPPORT
  // ==========================================

  @override
  Future<List<Map<String, dynamic>>> getUserHighlyRatedGames(String userId, {double minRating = 8.0}) async {
    try {
      final response = await client
          .from('user_games')
          .select('game_id, rating, rated_at')
          .eq('user_id', userId)
          .eq('is_rated', true)
          .gte('rating', minRating)
          .order('rating', ascending: false);

      return response.cast<Map<String, dynamic>>();
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to get highly rated games');
    }
  }

  @override
  Future<dynamic> getUserWishlistPatterns(String userId) async {
    try {
      final response = await client.rpc('get_user_wishlist_patterns', params: {
        'user_id': userId,
      });

      return response;
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to get wishlist patterns');
    }
  }

  @override
  Future<dynamic> getUserRatingPatterns(String userId) async {
    try {
      final response = await client.rpc('get_user_rating_patterns', params: {
        'user_id': userId,
      });

      return response;
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to get rating patterns');
    }
  }

  @override
  Future<dynamic> getFriendsActivity(String userId) async {
    try {
      final response = await client.rpc('get_friends_activity', params: {
        'user_id': userId,
      });

      return response;
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to get friends activity');
    }
  }

  @override
  Future<dynamic> getCommunityTrends() async {
    try {
      final response = await client.rpc('get_community_trends');

      return response;
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to get community trends');
    }
  }

  @override
  Future<Map<String, dynamic>> getUserGamingContext(String userId) async {
    try {
      final response = await client.rpc('get_user_gaming_context', params: {
        'user_id': userId,
      });

      return response as Map<String, dynamic>;
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to get gaming context');
    }
  }

  @override
  Future<List<int>> getAllUserGameIds(String userId) async {
    try {
      final response = await client
          .from('user_games')
          .select('game_id')
          .eq('user_id', userId)
          .or('is_wishlisted.eq.true,is_rated.eq.true,is_recommended.eq.true');

      return response.map<int>((item) => item['game_id'] as int).toList();
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to get all user game IDs');
    }
  }

  // ==========================================
  // SOCIAL FEATURES
  // ==========================================

  @override
  Future<List<String>> getUserFriends(String userId) async {
    try {
      final response = await client
          .from('user_follows')
          .select('followed_id')
          .eq('follower_id', userId);

      return response.map<String>((item) => item['followed_id'] as String).toList();
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to get user friends');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getFriendsRecentActivity({
    required List<String> friendIds,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await client
          .from('user_activity_log')
          .select('*')
          .inFilter('user_id', friendIds)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return response.cast<Map<String, dynamic>>();
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to get friends activity');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getFriendsRecommendedGames({
    required List<String> friendIds,
    required String excludeUserId,
    int limit = 20,
  }) async {
    try {
      final response = await client
          .from('user_games')
          .select('game_id, user_id, recommended_at')
          .inFilter('user_id', friendIds)
          .eq('is_recommended', true)
          .order('recommended_at', ascending: false)
          .limit(limit);

      return response.cast<Map<String, dynamic>>();
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to get friends recommended games');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getCommunityFavoritesByGenres({
    required List<int> genreIds,
    int limit = 20,
  }) async {
    try {
      final response = await client.rpc('get_community_favorites_by_genres', params: {
        'genre_ids': genreIds,
        'limit_count': limit,
      });

      return (response as List).cast<Map<String, dynamic>>();
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to get community favorites');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> findSimilarUsers(String userId, {int limit = 10}) async {
    try {
      final response = await client.rpc('find_similar_users', params: {
        'user_id': userId,
        'limit_count': limit,
      });

      return (response as List).cast<Map<String, dynamic>>();
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to find similar users');
    }
  }

  // ==========================================
  // ANALYTICS & TRENDS
  // ==========================================

  @override
  Future<List<Map<String, dynamic>>> getGenreTrendAnalytics({
    required Duration timeWindow,
    int limit = 20,
  }) async {
    try {
      final response = await client.rpc('get_genre_trend_analytics', params: {
        'time_window_days': timeWindow.inDays,
        'limit_count': limit,
      });

      return (response as List).cast<Map<String, dynamic>>();
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to get genre trend analytics');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getPlatformTrendAnalytics({
    required Duration timeWindow,
    int limit = 20,
  }) async {
    try {
      final response = await client.rpc('get_platform_trend_analytics', params: {
        'time_window_days': timeWindow.inDays,
        'limit_count': limit,
      });

      return (response as List).cast<Map<String, dynamic>>();
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to get platform trend analytics');
    }
  }

  @override
  Future<Map<String, dynamic>> getIndustryTrendAnalytics({required Duration timeWindow}) async {
    try {
      final response = await client.rpc('get_industry_trend_analytics', params: {
        'time_window_days': timeWindow.inDays,
      });

      return response as Map<String, dynamic>;
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to get industry trend analytics');
    }
  }

  @override
  Future<Map<String, dynamic>> getPersonalizedInsights(String userId) async {
    try {
      final response = await client.rpc('get_personalized_insights', params: {
        'user_id': userId,
      });

      return response as Map<String, dynamic>;
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to get personalized insights');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getGenreEvolutionTrends() async {
    try {
      final response = await client.rpc('get_genre_evolution_trends');

      return (response as List).cast<Map<String, dynamic>>();
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to get genre evolution trends');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getPlatformAdoptionTrends() async {
    try {
      final response = await client.rpc('get_platform_adoption_trends');

      return (response as List).cast<Map<String, dynamic>>();
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to get platform adoption trends');
    }
  }

  // ==========================================
  // SEARCH SUPPORT
  // ==========================================

  @override
  Future<List<String>> getRecentSearchQueries(String userId, {int limit = 10}) async {
    try {
      final response = await client
          .from('user_search_history')
          .select('query')
          .eq('user_id', userId)
          .order('searched_at', ascending: false)
          .limit(limit);

      return response.map<String>((item) => item['query'] as String).toList();
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to get recent search queries');
    }
  }

  @override
  Future<void> saveSearchQuery(String userId, String query) async {
    try {
      await client.from('user_search_history').insert({
        'user_id': userId,
        'query': query,
        'searched_at': DateTime.now().toIso8601String(),
      });
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to save search query');
    }
  }

  // ==========================================
  // EXISTING IMPLEMENTATIONS FROM PREVIOUS VERSION
  // ==========================================

  @override
  Future<UserModel> getUserProfile(String userId, [String? currentUserId]) async {
    try {
      final response = await client
          .from('users')
          .select('''
            *,
            is_following:user_follows!user_follows_followed_id_fkey(
              follower_id
            ),
            is_followed_by:user_follows!user_follows_follower_id_fkey(
              followed_id
            )
          ''')
          .eq('id', userId)
          .eq('is_active', true)
          .single();

      if (response.isEmpty) {
        throw ServerException(message: 'User not found');
      }

      // Add social context if current user is provided
      Map<String, dynamic> userData = Map<String, dynamic>.from(response);

      if (currentUserId != null) {
        userData['is_following'] = response['is_following']
            ?.any((follow) => follow['follower_id'] == currentUserId) ?? false;
        userData['is_followed_by'] = response['is_followed_by']
            ?.any((follow) => follow['followed_id'] == currentUserId) ?? false;
      }

      return UserModel.fromJson(userData, currentUserId: currentUserId);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to get user profile');
    }
  }

  @override
  Future<UserModel> getCurrentUserProfile() async {
    try {
      final user = client.auth.currentUser;
      if (user == null) {
        throw AuthException(message: 'No authenticated user');
      }

      return await getUserProfile(user.id, user.id);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw ServerException(message: 'Failed to get current user profile');
    }
  }

  @override
  Future<UserModel> updateUserProfile({
    required String userId,
    String? username,
    String? bio,
    String? avatarUrl,
    String? country,
    bool? isProfilePublic,
    bool? showRatedGames,
    bool? showRecommendedGames,
    bool? showTopThree,
  }) async {
    try {
      // Verify current user can update this profile
      final currentUser = client.auth.currentUser;
      if (currentUser == null || currentUser.id != userId) {
        throw AuthException(message: 'Unauthorized to update this profile');
      }

      // Build update data
      final Map<String, dynamic> updateData = {};
      if (username != null) updateData['username'] = username;
      if (bio != null) updateData['bio'] = bio;
      if (avatarUrl != null) updateData['avatar_url'] = avatarUrl;
      if (country != null) updateData['country'] = country;
      if (isProfilePublic != null) updateData['is_profile_public'] = isProfilePublic;
      if (showRatedGames != null) updateData['show_rated_games'] = showRatedGames;
      if (showRecommendedGames != null) updateData['show_recommended_games'] = showRecommendedGames;
      if (showTopThree != null) updateData['show_top_three'] = showTopThree;

      updateData['updated_at'] = DateTime.now().toIso8601String();

      final response = await client
          .from('users')
          .update(updateData)
          .eq('id', userId)
          .select()
          .single();

      return UserModel.fromJson(response, currentUserId: userId);
    } on PostgrestException catch (e) {
      if (e.code == '23505') { // Unique constraint violation
        throw ValidationException(message: 'Username already taken');
      }
      throw ServerException(message: e.message);
    } catch (e) {
      if (e is AuthException || e is ValidationException) rethrow;
      throw ServerException(message: 'Failed to update user profile');
    }
  }

  @override
  Future<String> updateUserAvatar({
    required String userId,
    required String imageData,
  }) async {
    try {
      final currentUser = client.auth.currentUser;
      if (currentUser == null || currentUser.id != userId) {
        throw AuthException(message: 'Unauthorized to update avatar');
      }

      // Upload to Supabase Storage
      final fileName = 'avatar_${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final bytes = Uri.parse(imageData).data?.contentAsBytes();

      if (bytes == null) {
        throw ValidationException(message: 'Invalid image data');
      }

      await client.storage
          .from('avatars')
          .uploadBinary(fileName, bytes);

      final avatarUrl = client.storage
          .from('avatars')
          .getPublicUrl(fileName);

      // Update user record
      await client
          .from('users')
          .update({'avatar_url': avatarUrl, 'updated_at': DateTime.now().toIso8601String()})
          .eq('id', userId);

      return avatarUrl;
    } on StorageException catch (e) {
      throw ServerException(message: 'Failed to upload avatar: ${e.message}');
    } catch (e) {
      if (e is AuthException || e is ValidationException) rethrow;
      throw ServerException(message: 'Failed to update avatar');
    }
  }

  // ==========================================
  // SOCIAL FEATURES - FOLLOW SYSTEM
  // ==========================================

  @override
  Future<void> followUser({
    required String currentUserId,
    required String targetUserId,
  }) async {
    try {
      // Check if users exist and target is not blocked
      final targetUser = await client
          .from('users')
          .select('id, is_active')
          .eq('id', targetUserId)
          .eq('is_active', true)
          .maybeSingle();

      if (targetUser == null) {
        throw ValidationException(message: 'User not found or inactive');
      }

      // Check if already following
      final existingFollow = await client
          .from('user_follows')
          .select('id')
          .eq('follower_id', currentUserId)
          .eq('followed_id', targetUserId)
          .maybeSingle();

      if (existingFollow != null) {
        throw ValidationException(message: 'Already following this user');
      }

      // Check if blocked
      final isBlocked = await isUserBlocked(
        currentUserId: targetUserId,
        targetUserId: currentUserId,
      );

      if (isBlocked) {
        throw ValidationException(message: 'Cannot follow this user');
      }

      // Create follow relationship
      await client
          .from('user_follows')
          .insert({
        'follower_id': currentUserId,
        'followed_id': targetUserId,
      });

    } on PostgrestException catch (e) {
      if (e.code == '23505') { // Unique constraint violation
        throw ValidationException(message: 'Already following this user');
      }
      throw ServerException(message: e.message);
    } catch (e) {
      if (e is ValidationException) rethrow;
      throw ServerException(message: 'Failed to follow user');
    }
  }

  @override
  Future<void> unfollowUser({
    required String currentUserId,
    required String targetUserId,
  }) async {
    try {
      final result = await client
          .from('user_follows')
          .delete()
          .eq('follower_id', currentUserId)
          .eq('followed_id', targetUserId);

      // Note: Supabase doesn't return affected count, so we don't check if unfollowing succeeded
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to unfollow user');
    }
  }

  @override
  Future<bool> isFollowing({
    required String currentUserId,
    required String targetUserId,
  }) async {
    try {
      final follow = await client
          .from('user_follows')
          .select('id')
          .eq('follower_id', currentUserId)
          .eq('followed_id', targetUserId)
          .maybeSingle();

      return follow != null;
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to check follow status');
    }
  }

  @override
  Future<UserRelationship> getUserRelationship({
    required String currentUserId,
    required String targetUserId,
  }) async {
    try {
      final follows = await client
          .from('user_follows')
          .select('follower_id, followed_id, created_at')
          .or('and(follower_id.eq.$currentUserId,followed_id.eq.$targetUserId),and(follower_id.eq.$targetUserId,followed_id.eq.$currentUserId)');

      bool isFollowing = false;
      bool isFollowedBy = false;
      DateTime? followedAt;
      DateTime? followedBackAt;

      for (final follow in follows) {
        if (follow['follower_id'] == currentUserId && follow['followed_id'] == targetUserId) {
          isFollowing = true;
          followedAt = DateTime.parse(follow['created_at']);
        } else if (follow['follower_id'] == targetUserId && follow['followed_id'] == currentUserId) {
          isFollowedBy = true;
          followedBackAt = DateTime.parse(follow['created_at']);
        }
      }

      RelationshipStatus status;
      if (isFollowing && isFollowedBy) {
        status = RelationshipStatus.mutual;
      } else if (isFollowing) {
        status = RelationshipStatus.following;
      } else if (isFollowedBy) {
        status = RelationshipStatus.followedBy;
      } else {
        status = RelationshipStatus.none;
      }

      return UserRelationship(
        userId: currentUserId,
        targetUserId: targetUserId,
        status: status,
        followedAt: followedAt,
        followedBackAt: followedBackAt,
      );
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to get user relationship');
    }
  }

  @override
  Future<List<UserModel>> getUserFollowers({
    required String userId,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await client
          .from('user_follows')
          .select('''
            follower:users!user_follows_follower_id_fkey(*)
          ''')
          .eq('followed_id', userId)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return response
          .map((item) => UserModel.fromJson(item['follower']))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to get user followers');
    }
  }

  @override
  Future<List<UserModel>> getUserFollowing({
    required String userId,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await client
          .from('user_follows')
          .select('''
            followed:users!user_follows_followed_id_fkey(*)
          ''')
          .eq('follower_id', userId)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return response
          .map((item) => UserModel.fromJson(item['followed']))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to get user following');
    }
  }

  @override
  Future<List<UserModel>> getMutualFollowers({
    required String currentUserId,
    required String targetUserId,
    int limit = 20,
  }) async {
    try {
      final response = await client.rpc(
        'get_mutual_followers',
        params: {
          'user_a': currentUserId,
          'user_b': targetUserId,
          'limit_count': limit,
        },
      );

      return (response as List)
          .map((item) => UserModel.fromJson(item))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to get mutual followers');
    }
  }

  @override
  Future<List<UserModel>> getFollowSuggestions({
    required String userId,
    int limit = 20,
  }) async {
    try {
      // Get suggestions based on mutual follows and popular users
      final response = await client
          .from('users')
          .select('*')
          .neq('id', userId)
          .eq('is_active', true)
          .eq('is_profile_public', true)
          .not('id', 'in', '(${await _getAlreadyFollowingIds(userId)})')
          .order('followers_count', ascending: false)
          .limit(limit);

      return response
          .map((item) => UserModel.fromJson(item, currentUserId: userId))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to get follow suggestions');
    }
  }

  Future<String> _getAlreadyFollowingIds(String userId) async {
    final following = await client
        .from('user_follows')
        .select('followed_id')
        .eq('follower_id', userId);

    if (following.isEmpty) return userId; // Just exclude self

    final ids = following.map((f) => f['followed_id']).join(',');
    return '$ids,$userId'; // Include self in exclusion
  }

  // ==========================================
  // USER SEARCH & DISCOVERY
  // ==========================================

  @override
  Future<List<UserModel>> searchUsers({
    required String query,
    String? currentUserId,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await client
          .from('users')
          .select('*')
          .or('username.ilike.%$query%,bio.ilike.%$query%')
          .eq('is_active', true)
          .eq('is_profile_public', true)
          .order('followers_count', ascending: false)
          .range(offset, offset + limit - 1);

      return response
          .map((item) => UserModel.fromJson(item, currentUserId: currentUserId))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to search users');
    }
  }

  @override
  Future<List<UserModel>> getPopularUsers({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await client
          .from('users')
          .select('*')
          .eq('is_active', true)
          .eq('is_profile_public', true)
          .gte('followers_count', 1)
          .order('followers_count', ascending: false)
          .range(offset, offset + limit - 1);

      return response
          .map((item) => UserModel.fromJson(item))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to get popular users');
    }
  }

  @override
  Future<List<UserModel>> getNewUsers({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await client
          .from('users')
          .select('*')
          .eq('is_active', true)
          .eq('is_profile_public', true)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return response
          .map((item) => UserModel.fromJson(item))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to get new users');
    }
  }

  @override
  Future<List<UserModel>> getSimilarUsers({
    required String userId,
    int limit = 20,
  }) async {
    try {
      // This would be more complex in real implementation
      // For now, get users with similar game preferences
      final response = await client.rpc(
        'get_similar_users',
        params: {
          'target_user_id': userId,
          'limit_count': limit,
        },
      );

      return (response as List)
          .map((item) => UserModel.fromJson(item, currentUserId: userId))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to get similar users');
    }
  }

  // ==========================================
  // TOP THREE GAMES MANAGEMENT
  // ==========================================

  @override
  Future<void> updateTopThreeGames({
    required String userId,
    required List<int> gameIds,
  }) async {
    try {
      final currentUser = client.auth.currentUser;
      if (currentUser == null || currentUser.id != userId) {
        throw AuthException(message: 'Unauthorized to update top three');
      }

      if (gameIds.length != 3) {
        throw ValidationException(message: 'Must provide exactly 3 games');
      }

      // Delete existing top three
      await client
          .from('user_top_three')
          .delete()
          .eq('user_id', userId);

      // Insert new top three
      final insertData = gameIds.asMap().entries.map((entry) => {
        'user_id': userId,
        'game_id': entry.value,
        'position': entry.key + 1,
        'created_at': DateTime.now().toIso8601String(),
      }).toList();

      await client
          .from('user_top_three')
          .insert(insertData);

    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      if (e is AuthException || e is ValidationException) rethrow;
      throw ServerException(message: 'Failed to update top three games');
    }
  }

  @override
  Future<void> setTopThreeGameAtPosition({
    required String userId,
    required int position,
    required int gameId,
  }) async {
    try {
      final currentUser = client.auth.currentUser;
      if (currentUser == null || currentUser.id != userId) {
        throw AuthException(message: 'Unauthorized to update top three');
      }

      if (position < 1 || position > 3) {
        throw ValidationException(message: 'Position must be 1, 2, or 3');
      }

      await client
          .from('user_top_three')
          .upsert({
        'user_id': userId,
        'game_id': gameId,
        'position': position,
        'created_at': DateTime.now().toIso8601String(),
      });

    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      if (e is AuthException || e is ValidationException) rethrow;
      throw ServerException(message: 'Failed to set top three game');
    }
  }

  @override
  Future<void> removeFromTopThree({
    required String userId,
    required int position,
  }) async {
    try {
      final currentUser = client.auth.currentUser;
      if (currentUser == null || currentUser.id != userId) {
        throw AuthException(message: 'Unauthorized to update top three');
      }

      if (position < 1 || position > 3) {
        throw ValidationException(message: 'Position must be 1, 2, or 3');
      }

      await client
          .from('user_top_three')
          .delete()
          .eq('user_id', userId)
          .eq('position', position);

    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      if (e is AuthException || e is ValidationException) rethrow;
      throw ServerException(message: 'Failed to remove from top three');
    }
  }

  @override
  Future<void> reorderTopThree({
    required String userId,
    required Map<int, int> positionToGameId,
  }) async {
    try {
      final currentUser = client.auth.currentUser;
      if (currentUser == null || currentUser.id != userId) {
        throw AuthException(message: 'Unauthorized to update top three');
      }

      // Delete existing top three
      await client
          .from('user_top_three')
          .delete()
          .eq('user_id', userId);

      // Insert new arrangement
      final insertData = positionToGameId.entries.map((entry) => {
        'user_id': userId,
        'game_id': entry.value,
        'position': entry.key,
        'created_at': DateTime.now().toIso8601String(),
      }).toList();

      await client
          .from('user_top_three')
          .insert(insertData);

    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      if (e is AuthException || e is ValidationException) rethrow;
      throw ServerException(message: 'Failed to reorder top three');
    }
  }

  // ==========================================
  // USER GAME COLLECTIONS (PUBLIC VISIBILITY)
  // ==========================================

  @override
  Future<List<Map<String, dynamic>>> getUserTopThreeGames({required String userId}) async {
    try {
      final response = await client
          .from('user_top_three')
          .select('game_id, position')
          .eq('user_id', userId)
          .order('position', ascending: true);

      return response.cast<Map<String, dynamic>>();
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to get top three games');
    }
  }

  @override
  Future<Map<String, dynamic>> getUserPublicCollections({
    required String userId,
    String? currentUserId,
  }) async {
    try {
      final userResponse = await client
          .from('users')
          .select('''
            show_rated_games, 
            show_recommended_games, 
            show_top_three,
            is_profile_public,
            total_games_rated,
            total_games_recommended
          ''')
          .eq('id', userId)
          .single();

      final canView = userResponse['is_profile_public'] == true ||
          (currentUserId == userId);

      if (!canView) {
        throw UnauthorizedException(message: 'Cannot view user collections');
      }

      return {
        'show_rated_games': userResponse['show_rated_games'],
        'show_recommended_games': userResponse['show_recommended_games'],
        'show_top_three': userResponse['show_top_three'],
        'total_games_rated': userResponse['total_games_rated'],
        'total_games_recommended': userResponse['total_games_recommended'],
      };

    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      if (e is UnauthorizedException) rethrow;
      throw ServerException(message: 'Failed to get user collections');
    }
  }

  // ==========================================
  // USER ACTIVITY & ANALYTICS
  // ==========================================

  @override
  Future<UserGamingActivity> getUserActivity({
    required String userId,
    Duration? timeWindow,
  }) async {
    try {
      final startDate = timeWindow != null
          ? DateTime.now().subtract(timeWindow)
          : DateTime.now().subtract(const Duration(days: 30));

      final response = await client.rpc(
        'get_user_gaming_activity',
        params: {
          'target_user_id': userId,
          'start_date': startDate.toIso8601String(),
        },
      );

      return UserGamingActivityModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to get user activity');
    }
  }

  @override
  Future<Map<String, dynamic>> getUserGamingStats({
    required String userId,
    String? currentUserId,
  }) async {
    try {
      final response = await client
          .from('users')
          .select('''
            total_games_rated,
            total_games_recommended,
            average_rating,
            created_at
          ''')
          .eq('id', userId)
          .single();

      return response;
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to get gaming stats');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getUserRecentActivity({
    required String userId,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await client
          .from('user_activity_log')
          .select('*')
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return response.cast<Map<String, dynamic>>();
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to get user activity');
    }
  }

  // ==========================================
  // SOCIAL FEED & ACTIVITY
  // ==========================================

  @override
  Future<List<Map<String, dynamic>>> getUserFeed({
    required String userId,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await client.rpc(
        'get_user_feed',
        params: {
          'target_user_id': userId,
          'limit_count': limit,
          'offset_count': offset,
        },
      );

      return (response as List).cast<Map<String, dynamic>>();
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to get user feed');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getGlobalFeed({
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await client
          .from('user_activity_feed')
          .select('*')
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return response.cast<Map<String, dynamic>>();
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to get global feed');
    }
  }

  @override
  Future<List<UserModel>> getTrendingUsers({
    Duration? timeWindow,
    int limit = 20,
  }) async {
    try {
      final since = timeWindow != null
          ? DateTime.now().subtract(timeWindow)
          : DateTime.now().subtract(const Duration(days: 7));

      final response = await client.rpc(
        'get_trending_users',
        params: {
          'since_date': since.toIso8601String(),
          'limit_count': limit,
        },
      );

      return (response as List)
          .map((item) => UserModel.fromJson(item))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to get trending users');
    }
  }

  // ==========================================
  // USER PRIVACY & SETTINGS
  // ==========================================

  @override
  Future<void> updatePrivacySettings({
    required String userId,
    bool? isProfilePublic,
    bool? showRatedGames,
    bool? showRecommendedGames,
    bool? showTopThree,
    bool? allowFollowRequests,
  }) async {
    try {
      final currentUser = client.auth.currentUser;
      if (currentUser == null || currentUser.id != userId) {
        throw AuthException(message: 'Unauthorized to update privacy settings');
      }

      final Map<String, dynamic> updateData = {
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (isProfilePublic != null) updateData['is_profile_public'] = isProfilePublic;
      if (showRatedGames != null) updateData['show_rated_games'] = showRatedGames;
      if (showRecommendedGames != null) updateData['show_recommended_games'] = showRecommendedGames;
      if (showTopThree != null) updateData['show_top_three'] = showTopThree;
      if (allowFollowRequests != null) updateData['allow_follow_requests'] = allowFollowRequests;

      await client
          .from('users')
          .update(updateData)
          .eq('id', userId);

    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw ServerException(message: 'Failed to update privacy settings');
    }
  }

  @override
  Future<void> blockUser({
    required String currentUserId,
    required String targetUserId,
  }) async {
    try {
      // Remove any existing follow relationships
      await unfollowUser(currentUserId: currentUserId, targetUserId: targetUserId);
      await unfollowUser(currentUserId: targetUserId, targetUserId: currentUserId);

      // Create block relationship
      await client
          .from('user_blocks')
          .insert({
        'blocker_id': currentUserId,
        'blocked_id': targetUserId,
      });

    } on PostgrestException catch (e) {
      if (e.code == '23505') { // Already blocked
        return; // Idempotent operation
      }
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to block user');
    }
  }

  @override
  Future<void> unblockUser({
    required String currentUserId,
    required String targetUserId,
  }) async {
    try {
      await client
          .from('user_blocks')
          .delete()
          .eq('blocker_id', currentUserId)
          .eq('blocked_id', targetUserId);

    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to unblock user');
    }
  }

  @override
  Future<List<UserModel>> getBlockedUsers({
    required String userId,
  }) async {
    try {
      final response = await client
          .from('user_blocks')
          .select('''
            blocked:users!user_blocks_blocked_id_fkey(*)
          ''')
          .eq('blocker_id', userId)
          .order('created_at', ascending: false);

      return response
          .map((item) => UserModel.fromJson(item['blocked']))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to get blocked users');
    }
  }

  @override
  Future<bool> isUserBlocked({
    required String currentUserId,
    required String targetUserId,
  }) async {
    try {
      final block = await client
          .from('user_blocks')
          .select('id')
          .eq('blocker_id', currentUserId)
          .eq('blocked_id', targetUserId)
          .maybeSingle();

      return block != null;
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to check block status');
    }
  }

  // ==========================================
  // BATCH OPERATIONS
  // ==========================================

  @override
  Future<void> followMultipleUsers({
    required String currentUserId,
    required List<String> targetUserIds,
  }) async {
    try {
      final followData = targetUserIds.map((id) => {
        'follower_id': currentUserId,
        'followed_id': id,
      }).toList();

      await client
          .from('user_follows')
          .insert(followData);

    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to follow multiple users');
    }
  }

  @override
  Future<List<UserModel>> getMultipleUserProfiles({
    required List<String> userIds,
    String? currentUserId,
  }) async {
    try {
      final response = await client
          .from('users')
          .select('*')
          .inFilter('id', userIds)
          .eq('is_active', true);

      return response
          .map((item) => UserModel.fromJson(item, currentUserId: currentUserId))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to get multiple user profiles');
    }
  }

  @override
  Future<Map<String, bool>> getMultipleFollowStatus({
    required String currentUserId,
    required List<String> targetUserIds,
  }) async {
    try {
      final response = await client
          .from('user_follows')
          .select('followed_id')
          .eq('follower_id', currentUserId)
          .inFilter('followed_id', targetUserIds);

      final followingIds = response.map((item) => item['followed_id'] as String).toSet();

      return Map.fromEntries(
        targetUserIds.map((id) => MapEntry(id, followingIds.contains(id))),
      );
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to get multiple follow status');
    }
  }

  // ==========================================
  // USER VERIFICATION & MODERATION
  // ==========================================

  @override
  Future<void> reportUser({
    required String reporterId,
    required String reportedUserId,
    required String reason,
    String? description,
  }) async {
    try {
      await client
          .from('user_reports')
          .insert({
        'reporter_id': reporterId,
        'reported_id': reportedUserId,
        'reason': reason,
        'description': description,
      });

    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to report user');
    }
  }

  @override
  Future<bool> isUsernameAvailable(String username) async {
    try {
      final response = await client
          .from('users')
          .select('id')
          .eq('username', username)
          .maybeSingle();

      return response == null;
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to check username availability');
    }
  }

  @override
  Future<List<String>> suggestUsernames(String baseUsername) async {
    try {
      // Simple username suggestions
      final suggestions = <String>[];
      for (int i = 1; i <= 5; i++) {
        final suggestion = '${baseUsername}_$i';
        if (await isUsernameAvailable(suggestion)) {
          suggestions.add(suggestion);
        }
      }
      return suggestions;
    } catch (e) {
      throw ServerException(message: 'Failed to suggest usernames');
    }
  }

  // ==========================================
  // USER DELETION & ACCOUNT MANAGEMENT
  // ==========================================

  @override
  Future<void> deleteUserAccount(String userId) async {
    try {
      final currentUser = client.auth.currentUser;
      if (currentUser == null || currentUser.id != userId) {
        throw AuthException(message: 'Unauthorized to delete account');
      }

      // Delete user record (cascading deletes will handle related data)
      await client
          .from('users')
          .delete()
          .eq('id', userId);

      // Sign out the user
      await client.auth.signOut();

    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw ServerException(message: 'Failed to delete user account');
    }
  }

  @override
  Future<void> deactivateUserAccount(String userId) async {
    try {
      final currentUser = client.auth.currentUser;
      if (currentUser == null || currentUser.id != userId) {
        throw AuthException(message: 'Unauthorized to deactivate account');
      }

      await client
          .from('users')
          .update({
        'is_active': false,
        'is_deactivated': true,
        'deactivated_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      })
          .eq('id', userId);

    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw ServerException(message: 'Failed to deactivate user account');
    }
  }

  @override
  Future<void> reactivateUserAccount(String userId) async {
    try {
      final currentUser = client.auth.currentUser;
      if (currentUser == null || currentUser.id != userId) {
        throw AuthException(message: 'Unauthorized to reactivate account');
      }

      await client
          .from('users')
          .update({
        'is_active': true,
        'is_deactivated': false,
        'deactivated_at': null,
        'updated_at': DateTime.now().toIso8601String(),
      })
          .eq('id', userId);

    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw ServerException(message: 'Failed to reactivate user account');
    }
  }

  // ==========================================
  // AUTH RELATED
  // ==========================================

  @override
  Future<UserModel> signIn(String email, String password) async {
    try {
      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw AuthException(message: 'Sign in failed');
      }

      return await getCurrentUserProfile();
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException(message: 'Sign in failed');
    }
  }

  @override
  Future<UserModel> signUp(String email, String password, String username) async {
    try {
      // Check if username is available
      if (!await isUsernameAvailable(username)) {
        throw ValidationException(message: 'Username already taken');
      }

      final response = await client.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw AuthException(message: 'Sign up failed');
      }

      // Create user profile
      final userModel = UserModel.fromAuth(
        id: response.user!.id,
        email: email,
        username: username,
      );

      await client.from('users').insert(userModel.toJson());

      return userModel;
    } on AuthException {
      rethrow;
    } on ValidationException {
      rethrow;
    } catch (e) {
      throw AuthException(message: 'Sign up failed');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await client.auth.signOut();
    } catch (e) {
      throw AuthException(message: 'Sign out failed');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = client.auth.currentUser;
      if (user == null) return null;

      return await getCurrentUserProfile();
    } catch (e) {
      return null;
    }
  }

// Implementierung der fehlenden getUserPublicRatedGames und getUserPublicRecommendedGames Methoden

  @override
  Future<List<Map<String, dynamic>>> getUserPublicRatedGames({
    required String userId,
    String? currentUserId,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      // Überprüfung der Berechtigung und Privacy-Einstellungen
      final userResponse = await client
          .from('users')
          .select('show_rated_games, is_profile_public')
          .eq('id', userId)
          .single();

      // Kann der aktuelle Benutzer das Profil einsehen?
      final canViewProfile = userResponse['is_profile_public'] == true ||
          (currentUserId == userId);

      if (!canViewProfile) {
        throw UnauthorizedException(message: 'Cannot view user profile');
      }

      // Hat der Benutzer seine bewerteten Spiele öffentlich gemacht?
      final showRatedGames = userResponse['show_rated_games'] as bool? ?? false;

      if (!showRatedGames && currentUserId != userId) {
        throw UnauthorizedException(message: 'User has disabled public access to rated games');
      }

      // Abrufen der bewerteten Spiele
      final response = await client
          .from('user_games')
          .select('game_id, rating, rated_at, created_at, updated_at')
          .eq('user_id', userId)
          .eq('is_rated', true)
          .order('rated_at', ascending: false)
          .range(offset, offset + limit - 1);

      return response.cast<Map<String, dynamic>>();

    } on PostgrestException catch (e) {
      if (e.code == '23503') { // Foreign key violation - user not found
        throw ValidationException(message: 'User not found');
      }
      throw ServerException(message: e.message);
    } catch (e) {
      if (e is UnauthorizedException || e is ValidationException) rethrow;
      throw ServerException(message: 'Failed to get user public rated games');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getUserPublicRecommendedGames({
    required String userId,
    String? currentUserId,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      // Überprüfung der Berechtigung und Privacy-Einstellungen
      final userResponse = await client
          .from('users')
          .select('show_recommended_games, is_profile_public')
          .eq('id', userId)
          .single();

      // Kann der aktuelle Benutzer das Profil einsehen?
      final canViewProfile = userResponse['is_profile_public'] == true ||
          (currentUserId == userId);

      if (!canViewProfile) {
        throw UnauthorizedException(message: 'Cannot view user profile');
      }

      // Hat der Benutzer seine empfohlenen Spiele öffentlich gemacht?
      final showRecommendedGames = userResponse['show_recommended_games'] as bool? ?? false;

      if (!showRecommendedGames && currentUserId != userId) {
        throw UnauthorizedException(message: 'User has disabled public access to recommended games');
      }

      // Abrufen der empfohlenen Spiele
      final response = await client
          .from('user_games')
          .select('game_id, recommended_at, created_at, updated_at')
          .eq('user_id', userId)
          .eq('is_recommended', true)
          .order('recommended_at', ascending: false)
          .range(offset, offset + limit - 1);

      return response.cast<Map<String, dynamic>>();

    } on PostgrestException catch (e) {
      if (e.code == '23503') { // Foreign key violation - user not found
        throw ValidationException(message: 'User not found');
      }
      throw ServerException(message: e.message);
    } catch (e) {
      if (e is UnauthorizedException || e is ValidationException) rethrow;
      throw ServerException(message: 'Failed to get user public recommended games');
    }
  }

// ==========================================
// HELPER METHODEN FÜR PRIVACY CHECKS
// ==========================================

  /// Hilfsmethode um zu überprüfen, ob ein Benutzer eine bestimmte Sammlung einsehen kann
  Future<bool> _canViewUserCollection({
    required String userId,
    required String collectionType,
    String? currentUserId,
  }) async {
    try {
      final userResponse = await client
          .from('users')
          .select('is_profile_public, $collectionType')
          .eq('id', userId)
          .single();

      // Eigenes Profil kann immer eingesehen werden
      if (currentUserId == userId) return true;

      // Profil muss öffentlich sein
      final isProfilePublic = userResponse['is_profile_public'] as bool? ?? false;
      if (!isProfilePublic) return false;

      // Sammlung muss öffentlich freigegeben sein
      final isCollectionPublic = userResponse[collectionType] as bool? ?? false;
      return isCollectionPublic;

    } catch (e) {
      return false;
    }
  }

  /// Erweiterte Methode die zusätzliche Metadaten zurückgibt
  Future<Map<String, dynamic>> getUserPublicRatedGamesWithMetadata({
    required String userId,
    String? currentUserId,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      // Privacy-Check
      final canView = await _canViewUserCollection(
        userId: userId,
        collectionType: 'show_rated_games',
        currentUserId: currentUserId,
      );

      if (!canView) {
        throw UnauthorizedException(message: 'Cannot view rated games');
      }

      // Haupt-Query
      final response = await client
          .from('user_games')
          .select('game_id, rating, rated_at, created_at, updated_at')
          .eq('user_id', userId)
          .eq('is_rated', true)
          .order('rated_at', ascending: false)
          .range(offset, offset + limit - 1);

      // Zusätzliche Metadaten abrufen
      final statsResponse = await client
          .from('users')
          .select('total_games_rated, average_rating')
          .eq('id', userId)
          .single();

      return {
        'games': response.cast<Map<String, dynamic>>(),
        'metadata': {
          'total_count': statsResponse['total_games_rated'] ?? 0,
          'average_rating': statsResponse['average_rating'],
          'has_more': response.length == limit,
          'offset': offset,
          'limit': limit,
        },
      };

    } catch (e) {
      if (e is UnauthorizedException) rethrow;
      throw ServerException(message: 'Failed to get rated games with metadata');
    }
  }

  /// Erweiterte Methode für empfohlene Spiele mit Metadaten
  Future<Map<String, dynamic>> getUserPublicRecommendedGamesWithMetadata({
    required String userId,
    String? currentUserId,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      // Privacy-Check
      final canView = await _canViewUserCollection(
        userId: userId,
        collectionType: 'show_recommended_games',
        currentUserId: currentUserId,
      );

      if (!canView) {
        throw UnauthorizedException(message: 'Cannot view recommended games');
      }

      // Haupt-Query
      final response = await client
          .from('user_games')
          .select('game_id, recommended_at, created_at, updated_at')
          .eq('user_id', userId)
          .eq('is_recommended', true)
          .order('recommended_at', ascending: false)
          .range(offset, offset + limit - 1);

      // Zusätzliche Metadaten abrufen
      final statsResponse = await client
          .from('users')
          .select('total_games_recommended')
          .eq('id', userId)
          .single();

      return {
        'games': response.cast<Map<String, dynamic>>(),
        'metadata': {
          'total_count': statsResponse['total_games_recommended'] ?? 0,
          'has_more': response.length == limit,
          'offset': offset,
          'limit': limit,
        },
      };

    } catch (e) {
      if (e is UnauthorizedException) rethrow;
      throw ServerException(message: 'Failed to get recommended games with metadata');
    }
  }

// ==========================================
// BATCH-ABRUF FÜR MEHRERE SAMMLUNGEN
// ==========================================

  /// Ruft alle öffentlichen Sammlungen eines Benutzers auf einmal ab
  Future<Map<String, dynamic>> getAllUserPublicCollections({
    required String userId,
    String? currentUserId,
    int limit = 10,
  }) async {
    try {
      // Überprüfe Profil-Zugang
      final userResponse = await client
          .from('users')
          .select('''
          is_profile_public,
          show_rated_games,
          show_recommended_games,
          show_top_three,
          total_games_rated,
          total_games_recommended
        ''')
          .eq('id', userId)
          .single();

      final canViewProfile = userResponse['is_profile_public'] == true ||
          (currentUserId == userId);

      if (!canViewProfile) {
        throw UnauthorizedException(message: 'Cannot view user profile');
      }

      final result = <String, dynamic>{
        'permissions': {
          'can_view_rated': userResponse['show_rated_games'] == true || currentUserId == userId,
          'can_view_recommended': userResponse['show_recommended_games'] == true || currentUserId == userId,
          'can_view_top_three': userResponse['show_top_three'] == true || currentUserId == userId,
        },
      };

      // Abrufen der bewerteten Spiele (wenn erlaubt)
      if (result['permissions']['can_view_rated']) {
        final ratedGames = await client
            .from('user_games')
            .select('game_id, rating, rated_at')
            .eq('user_id', userId)
            .eq('is_rated', true)
            .order('rated_at', ascending: false)
            .limit(limit);

        result['rated_games'] = {
          'games': ratedGames.cast<Map<String, dynamic>>(),
          'total_count': userResponse['total_games_rated'] ?? 0,
        };
      }

      // Abrufen der empfohlenen Spiele (wenn erlaubt)
      if (result['permissions']['can_view_recommended']) {
        final recommendedGames = await client
            .from('user_games')
            .select('game_id, recommended_at')
            .eq('user_id', userId)
            .eq('is_recommended', true)
            .order('recommended_at', ascending: false)
            .limit(limit);

        result['recommended_games'] = {
          'games': recommendedGames.cast<Map<String, dynamic>>(),
          'total_count': userResponse['total_games_recommended'] ?? 0,
        };
      }

      // Abrufen der Top-Drei (wenn erlaubt)
      if (result['permissions']['can_view_top_three']) {
        final topThreeGames = await client
            .from('user_top_three')
            .select('game_id, position')
            .eq('user_id', userId)
            .order('position', ascending: true);

        result['top_three_games'] = topThreeGames.cast<Map<String, dynamic>>();
      }

      return result;

    } catch (e) {
      if (e is UnauthorizedException) rethrow;
      throw ServerException(message: 'Failed to get user public collections');
    }
  }
}