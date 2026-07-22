import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import 'package:gamer_grove/domain/entities/collection/user_collection.dart';
import 'package:gamer_grove/domain/repositories/user_collections_repository.dart';
import 'package:gamer_grove/domain/usecases/user_collection/add_game_to_collection_use_case.dart';
import 'package:gamer_grove/domain/usecases/user_collection/create_collection_use_case.dart';
import 'package:gamer_grove/domain/usecases/user_collection/delete_collection_use_case.dart';
import 'package:gamer_grove/domain/usecases/user_collection/get_user_collections_use_case.dart';
import 'package:gamer_grove/domain/usecases/user_collection/remove_game_from_collection_use_case.dart';
import 'package:gamer_grove/domain/usecases/user_collection/update_collection_use_case.dart';
import 'package:gamer_grove/presentation/blocs/user_collections/user_collections_bloc.dart';

/// Scriptable fake repository. Each getUserCollections call pops the next
/// queued result, so a create-then-reload can return different lists.
class _FakeRepo implements UserCollectionsRepository {
  final List<Either<Failure, List<UserCollection>>> listResults = [];
  Either<Failure, UserCollection> createResult =
      Right(_c('c2', 'Backlog 2026'));
  Either<Failure, void> mutationResult = const Right(null);

  final List<String> calls = [];

  static UserCollection _c(String id, String name, {int count = 0}) =>
      UserCollection(id: id, userId: 'u1', name: name, gameCount: count);

  @override
  Future<Either<Failure, List<UserCollection>>> getUserCollections(
    String userId,
  ) async {
    calls.add('get');
    if (listResults.isEmpty) return const Right([]);
    return listResults.removeAt(0);
  }

  @override
  Future<Either<Failure, UserCollection>> createCollection({
    required String userId,
    required String name,
    String? description,
  }) async {
    calls.add('create');
    return createResult;
  }

  @override
  Future<Either<Failure, UserCollection>> updateCollection({
    required String collectionId,
    String? name,
    String? description,
    int? coverGameId,
    bool? isPublic,
  }) async {
    calls.add('update');
    return Right(_c(collectionId, name ?? 'x'));
  }

  @override
  Future<Either<Failure, void>> deleteCollection(String collectionId) async {
    calls.add('delete');
    return mutationResult;
  }

  @override
  Future<Either<Failure, List<int>>> getCollectionGameIds(
    String collectionId,
  ) async =>
      const Right([]);

  @override
  Future<Either<Failure, void>> addGameToCollection({
    required String collectionId,
    required int gameId,
  }) async {
    calls.add('add');
    return mutationResult;
  }

  @override
  Future<Either<Failure, void>> removeGameFromCollection({
    required String collectionId,
    required int gameId,
  }) async {
    calls.add('remove');
    return mutationResult;
  }
}

void main() {
  late _FakeRepo repo;

  UserCollectionsBloc build() => UserCollectionsBloc(
        getUserCollections: GetUserCollectionsUseCase(repo),
        createCollection: CreateCollectionUseCase(repo),
        updateCollection: UpdateCollectionUseCase(repo),
        deleteCollection: DeleteCollectionUseCase(repo),
        addGameToCollection: AddGameToCollectionUseCase(repo),
        removeGameFromCollection: RemoveGameFromCollectionUseCase(repo),
      );

  var cozy = _FakeRepo._c('c1', 'Cozy games');

  setUp(() {
    repo = _FakeRepo();
    cozy = _FakeRepo._c('c1', 'Cozy games');
  });

  group('LoadCollections', () {
    blocTest<UserCollectionsBloc, UserCollectionsState>(
      'emits [Loading, Loaded] on success',
      build: () {
        repo.listResults.add(Right([cozy]));
        return build();
      },
      act: (b) => b.add(const LoadCollections('u1')),
      expect: () => [
        const UserCollectionsLoading(),
        UserCollectionsLoaded(userId: 'u1', collections: [cozy]),
      ],
    );

    blocTest<UserCollectionsBloc, UserCollectionsState>(
      'emits [Loading, Error] on failure',
      build: () {
        repo.listResults.add(const Left(ServerFailure(message: 'nope')));
        return build();
      },
      act: (b) => b.add(const LoadCollections('u1')),
      expect: () => [
        const UserCollectionsLoading(),
        const UserCollectionsError('nope'),
      ],
    );
  });

  group('CreateCollection', () {
    blocTest<UserCollectionsBloc, UserCollectionsState>(
      'marks mutating then reloads the list with the new collection',
      build: () {
        // seeded as loaded → only the post-create reload calls getUserCollections
        repo.listResults.add(Right([cozy, _FakeRepo._c('c2', 'Backlog 2026')]));
        return build();
      },
      seed: () => UserCollectionsLoaded(userId: 'u1', collections: [cozy]),
      act: (b) =>
          b.add(const CreateCollection(userId: 'u1', name: 'Backlog 2026')),
      expect: () => [
        UserCollectionsLoaded(
          userId: 'u1',
          collections: [cozy],
          isMutating: true,
        ),
        isA<UserCollectionsLoaded>()
            .having((s) => s.count, 'count', 2)
            .having((s) => s.isMutating, 'isMutating', false),
      ],
      verify: (_) => expect(repo.calls, ['create', 'get']),
    );

    blocTest<UserCollectionsBloc, UserCollectionsState>(
      'surfaces a validation error without dropping the list',
      build: build,
      seed: () => UserCollectionsLoaded(userId: 'u1', collections: [cozy]),
      act: (b) => b.add(const CreateCollection(userId: 'u1', name: '   ')),
      expect: () => [
        UserCollectionsLoaded(
          userId: 'u1',
          collections: [cozy],
          isMutating: true,
        ),
        isA<UserCollectionsLoaded>()
            .having((s) => s.actionError, 'actionError', isNotNull)
            .having((s) => s.count, 'count', 1),
      ],
    );
  });

  group('DeleteCollection', () {
    blocTest<UserCollectionsBloc, UserCollectionsState>(
      'reloads the list after a successful delete',
      build: () {
        repo.listResults.add(const Right(<UserCollection>[]));
        return build();
      },
      seed: () => UserCollectionsLoaded(userId: 'u1', collections: [cozy]),
      act: (b) => b.add(const DeleteCollection('c1')),
      expect: () => [
        isA<UserCollectionsLoaded>()
            .having((s) => s.isMutating, 'isMutating', true),
        isA<UserCollectionsLoaded>().having((s) => s.count, 'count', 0),
      ],
      verify: (_) => expect(repo.calls, ['delete', 'get']),
    );

    blocTest<UserCollectionsBloc, UserCollectionsState>(
      'keeps the list and sets actionError when delete fails',
      build: () {
        repo.mutationResult = const Left(ServerFailure(message: 'boom'));
        return build();
      },
      seed: () => UserCollectionsLoaded(userId: 'u1', collections: [cozy]),
      act: (b) => b.add(const DeleteCollection('c1')),
      expect: () => [
        isA<UserCollectionsLoaded>()
            .having((s) => s.isMutating, 'isMutating', true),
        isA<UserCollectionsLoaded>()
            .having((s) => s.actionError, 'actionError', 'boom')
            .having((s) => s.count, 'count', 1),
      ],
    );
  });

  group('AddGameToCollection', () {
    blocTest<UserCollectionsBloc, UserCollectionsState>(
      'reloads counts after adding a game',
      build: () {
        repo.listResults.add(Right([cozy.copyWith(gameCount: 1)]));
        return build();
      },
      seed: () => UserCollectionsLoaded(userId: 'u1', collections: [cozy]),
      act: (b) =>
          b.add(const AddGameToCollection(collectionId: 'c1', gameId: 42)),
      expect: () => [
        isA<UserCollectionsLoaded>()
            .having((s) => s.isMutating, 'isMutating', true),
        isA<UserCollectionsLoaded>().having(
          (s) => s.collections.first.gameCount,
          'gameCount',
          1,
        ),
      ],
      verify: (_) => expect(repo.calls, ['add', 'get']),
    );
  });
}
