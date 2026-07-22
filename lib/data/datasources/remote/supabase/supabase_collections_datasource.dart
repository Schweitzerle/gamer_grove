/// Data source for user-created custom collections.
library;

/// Contract for reading and writing custom collections against Supabase.
///
/// Returns raw maps/ids; mapping to domain entities happens in the repository.
abstract class SupabaseCollectionsDataSource {
  /// Owner's collections (newest first), each including an embedded game count.
  Future<List<Map<String, dynamic>>> getUserCollections(String userId);

  /// Inserts a collection and returns the persisted row.
  Future<Map<String, dynamic>> createCollection({
    required String userId,
    required String name,
    String? description,
  });

  /// Updates the given fields (only non-null are written) and returns the row.
  Future<Map<String, dynamic>> updateCollection({
    required String collectionId,
    String? name,
    String? description,
    int? coverGameId,
    bool? isPublic,
  });

  /// Deletes a collection (membership rows cascade in the DB).
  Future<void> deleteCollection(String collectionId);

  /// Game ids in a collection, ordered by stored position.
  Future<List<int>> getCollectionGameIds(String collectionId);

  /// Adds a game at the end of the collection; idempotent.
  Future<void> addGameToCollection({
    required String collectionId,
    required int gameId,
  });

  /// Removes a game from a collection.
  Future<void> removeGameFromCollection({
    required String collectionId,
    required int gameId,
  });
}
