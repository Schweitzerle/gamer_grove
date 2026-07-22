import 'package:dartz/dartz.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import 'package:gamer_grove/domain/entities/collection/user_collection.dart';

/// Repository for user-created custom collections.
///
/// Separate from the fixed system lists (wishlist / rated / recommended /
/// top three), which live on the game/user repositories. All operations are
/// scoped to the signed-in owner; server-side RLS is the source of truth for
/// authorization.
abstract class UserCollectionsRepository {
  /// Returns the owner's collections, newest first, each with its game count.
  Future<Either<Failure, List<UserCollection>>> getUserCollections(
    String userId,
  );

  /// Creates a new collection for [userId] and returns the persisted entity.
  Future<Either<Failure, UserCollection>> createCollection({
    required String userId,
    required String name,
    String? description,
  });

  /// Updates mutable fields of a collection. Only non-null fields change.
  Future<Either<Failure, UserCollection>> updateCollection({
    required String collectionId,
    String? name,
    String? description,
    int? coverGameId,
    bool? isPublic,
  });

  /// Deletes a collection and its game membership rows.
  Future<Either<Failure, void>> deleteCollection(String collectionId);

  /// Returns the game ids in a collection, ordered by stored position.
  Future<Either<Failure, List<int>>> getCollectionGameIds(String collectionId);

  /// Adds a game to a collection (idempotent — re-adding is a no-op).
  Future<Either<Failure, void>> addGameToCollection({
    required String collectionId,
    required int gameId,
  });

  /// Removes a game from a collection.
  Future<Either<Failure, void>> removeGameFromCollection({
    required String collectionId,
    required int gameId,
  });
}
