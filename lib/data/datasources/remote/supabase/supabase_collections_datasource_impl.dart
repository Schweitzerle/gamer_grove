/// Supabase implementation of [SupabaseCollectionsDataSource].
library;

import 'package:gamer_grove/data/datasources/remote/supabase/models/supabase_filters.dart';
import 'package:gamer_grove/data/datasources/remote/supabase/models/supabase_query.dart';
import 'package:gamer_grove/data/datasources/remote/supabase/models/supabase_user_exceptions.dart';
import 'package:gamer_grove/data/datasources/remote/supabase/supabase_collections_datasource.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide SortBy;

/// Column list returned for a collection row (excluding the embedded count).
const String _collectionColumns =
    'id, user_id, name, description, cover_game_id, is_public, '
    'created_at, updated_at';

/// Concrete [SupabaseCollectionsDataSource] backed by PostgREST.
class SupabaseCollectionsDataSourceImpl
    implements SupabaseCollectionsDataSource {
  SupabaseCollectionsDataSourceImpl({required SupabaseClient supabase})
      : _supabase = supabase;

  final SupabaseClient _supabase;

  static const String _collectionsTable = 'user_collections';
  static const String _gamesTable = 'user_collection_games';

  @override
  Future<List<Map<String, dynamic>>> getUserCollections(String userId) async {
    try {
      // Embed an aggregate count of member games to avoid an N+1 fan-out.
      final result = await SupabaseQuery(_collectionsTable)
          .select('$_collectionColumns, $_gamesTable(count)')
          .filter(EqualFilter('user_id', userId))
          .sort(const SortBy('created_at', SortOrder.desc))
          .build(_supabase);
      return (result as List).cast<Map<String, dynamic>>();
    } catch (e) {
      throw UserExceptionMapper.map(e);
    }
  }

  @override
  Future<Map<String, dynamic>> createCollection({
    required String userId,
    required String name,
    String? description,
  }) async {
    try {
      final rows = await SupabaseInsert(_collectionsTable)
          .values({
            'user_id': userId,
            'name': name,
            if (description != null && description.isNotEmpty)
              'description': description,
          })
          .returning(_collectionColumns)
          .build(_supabase);
      return (rows as List).first as Map<String, dynamic>;
    } catch (e) {
      throw UserExceptionMapper.map(e);
    }
  }

  @override
  Future<Map<String, dynamic>> updateCollection({
    required String collectionId,
    String? name,
    String? description,
    int? coverGameId,
    bool? isPublic,
  }) async {
    try {
      final values = <String, dynamic>{
        if (name != null) 'name': name,
        if (description != null) 'description': description,
        if (coverGameId != null) 'cover_game_id': coverGameId,
        if (isPublic != null) 'is_public': isPublic,
      };
      final rows = await SupabaseUpdate(_collectionsTable)
          .set(values)
          .filter(EqualFilter('id', collectionId))
          .returning(_collectionColumns)
          .build(_supabase);
      return (rows as List).first as Map<String, dynamic>;
    } catch (e) {
      throw UserExceptionMapper.map(e);
    }
  }

  @override
  Future<void> deleteCollection(String collectionId) async {
    try {
      await SupabaseDelete(_collectionsTable)
          .filter(EqualFilter('id', collectionId))
          .build(_supabase);
    } catch (e) {
      throw UserExceptionMapper.map(e);
    }
  }

  @override
  Future<List<int>> getCollectionGameIds(String collectionId) async {
    try {
      final result = await SupabaseQuery(_gamesTable)
          .select('game_id')
          .filter(EqualFilter('collection_id', collectionId))
          .sort(const SortBy('position', SortOrder.asc))
          .build(_supabase);
      return (result as List)
          .map((e) => (e as Map<String, dynamic>)['game_id'] as int)
          .toList();
    } catch (e) {
      throw UserExceptionMapper.map(e);
    }
  }

  @override
  Future<void> addGameToCollection({
    required String collectionId,
    required int gameId,
  }) async {
    try {
      // Idempotent: skip if the game is already a member.
      final existing = await SupabaseQuery(_gamesTable)
          .select('game_id')
          .filter(EqualFilter('collection_id', collectionId))
          .filter(EqualFilter('game_id', gameId))
          .maybeSingle()
          .build(_supabase);
      if (existing != null) return;

      // Append at the end: next position = current member count.
      final members = await SupabaseQuery(_gamesTable)
          .select('game_id')
          .filter(EqualFilter('collection_id', collectionId))
          .build(_supabase);
      final position = (members as List).length;

      await SupabaseInsert(_gamesTable).values({
        'collection_id': collectionId,
        'game_id': gameId,
        'position': position,
      }).build(_supabase);
    } catch (e) {
      throw UserExceptionMapper.map(e);
    }
  }

  @override
  Future<void> removeGameFromCollection({
    required String collectionId,
    required int gameId,
  }) async {
    try {
      await SupabaseDelete(_gamesTable)
          .filter(EqualFilter('collection_id', collectionId))
          .filter(EqualFilter('game_id', gameId))
          .build(_supabase);
    } catch (e) {
      throw UserExceptionMapper.map(e);
    }
  }
}
