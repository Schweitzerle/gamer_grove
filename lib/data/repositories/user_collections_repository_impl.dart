import 'package:dartz/dartz.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import 'package:gamer_grove/data/datasources/remote/supabase/supabase_collections_datasource.dart';
import 'package:gamer_grove/data/models/collection/user_collection_model.dart';
import 'package:gamer_grove/data/repositories/base/supabase_base_repository.dart';
import 'package:gamer_grove/domain/entities/collection/user_collection.dart';
import 'package:gamer_grove/domain/repositories/user_collections_repository.dart';

/// Supabase-backed implementation of [UserCollectionsRepository].
class UserCollectionsRepositoryImpl extends SupabaseBaseRepository
    implements UserCollectionsRepository {
  UserCollectionsRepositoryImpl({
    required this.dataSource,
    required super.supabase,
    required super.networkInfo,
  });

  final SupabaseCollectionsDataSource dataSource;

  @override
  Future<Either<Failure, List<UserCollection>>> getUserCollections(
    String userId,
  ) {
    return executeSupabaseOperation(
      operation: () async {
        final rows = await dataSource.getUserCollections(userId);
        return rows.map(UserCollectionModel.fromJson).toList();
      },
      errorMessage: 'Failed to load collections',
    );
  }

  @override
  Future<Either<Failure, UserCollection>> createCollection({
    required String userId,
    required String name,
    String? description,
  }) {
    return executeSupabaseOperation(
      operation: () async {
        final row = await dataSource.createCollection(
          userId: userId,
          name: name,
          description: description,
        );
        return UserCollectionModel.fromJson(row);
      },
      errorMessage: 'Failed to create collection',
    );
  }

  @override
  Future<Either<Failure, UserCollection>> updateCollection({
    required String collectionId,
    String? name,
    String? description,
    int? coverGameId,
    bool? isPublic,
  }) {
    return executeSupabaseOperation(
      operation: () async {
        final row = await dataSource.updateCollection(
          collectionId: collectionId,
          name: name,
          description: description,
          coverGameId: coverGameId,
          isPublic: isPublic,
        );
        return UserCollectionModel.fromJson(row);
      },
      errorMessage: 'Failed to update collection',
    );
  }

  @override
  Future<Either<Failure, void>> deleteCollection(String collectionId) {
    return executeSupabaseVoidOperation(
      operation: () => dataSource.deleteCollection(collectionId),
      errorMessage: 'Failed to delete collection',
    );
  }

  @override
  Future<Either<Failure, List<int>>> getCollectionGameIds(
    String collectionId,
  ) {
    return executeSupabaseOperation(
      operation: () => dataSource.getCollectionGameIds(collectionId),
      errorMessage: 'Failed to load collection games',
    );
  }

  @override
  Future<Either<Failure, void>> addGameToCollection({
    required String collectionId,
    required int gameId,
  }) {
    return executeSupabaseVoidOperation(
      operation: () => dataSource.addGameToCollection(
        collectionId: collectionId,
        gameId: gameId,
      ),
      errorMessage: 'Failed to add game to collection',
    );
  }

  @override
  Future<Either<Failure, void>> removeGameFromCollection({
    required String collectionId,
    required int gameId,
  }) {
    return executeSupabaseVoidOperation(
      operation: () => dataSource.removeGameFromCollection(
        collectionId: collectionId,
        gameId: gameId,
      ),
      errorMessage: 'Failed to remove game from collection',
    );
  }
}
