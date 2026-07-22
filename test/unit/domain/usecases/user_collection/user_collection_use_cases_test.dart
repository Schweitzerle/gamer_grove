import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import 'package:gamer_grove/domain/entities/collection/user_collection.dart';
import 'package:gamer_grove/domain/repositories/user_collections_repository.dart';
import 'package:gamer_grove/domain/usecases/user_collection/add_game_to_collection_use_case.dart';
import 'package:gamer_grove/domain/usecases/user_collection/create_collection_use_case.dart';
import 'package:gamer_grove/domain/usecases/user_collection/delete_collection_use_case.dart';
import 'package:gamer_grove/domain/usecases/user_collection/get_collection_game_ids_use_case.dart';
import 'package:gamer_grove/domain/usecases/user_collection/get_user_collections_use_case.dart';
import 'package:gamer_grove/domain/usecases/user_collection/remove_game_from_collection_use_case.dart';
import 'package:gamer_grove/domain/usecases/user_collection/update_collection_use_case.dart';

/// In-memory fake repository capturing the last create/update args.
class _FakeRepo implements UserCollectionsRepository {
  String? lastCreatedName;
  String? lastUpdatedName;
  final List<String> calls = [];

  UserCollection _entity(String name) =>
      UserCollection(id: 'c1', userId: 'u1', name: name);

  @override
  Future<Either<Failure, List<UserCollection>>> getUserCollections(
    String userId,
  ) async {
    calls.add('getUserCollections');
    return Right([_entity('Cozy games')]);
  }

  @override
  Future<Either<Failure, UserCollection>> createCollection({
    required String userId,
    required String name,
    String? description,
  }) async {
    calls.add('createCollection');
    lastCreatedName = name;
    return Right(_entity(name));
  }

  @override
  Future<Either<Failure, UserCollection>> updateCollection({
    required String collectionId,
    String? name,
    String? description,
    int? coverGameId,
    bool? isPublic,
  }) async {
    calls.add('updateCollection');
    lastUpdatedName = name;
    return Right(_entity(name ?? 'unchanged'));
  }

  @override
  Future<Either<Failure, void>> deleteCollection(String collectionId) async {
    calls.add('deleteCollection');
    return const Right(null);
  }

  @override
  Future<Either<Failure, List<int>>> getCollectionGameIds(
    String collectionId,
  ) async {
    calls.add('getCollectionGameIds');
    return const Right([1, 2, 3]);
  }

  @override
  Future<Either<Failure, void>> addGameToCollection({
    required String collectionId,
    required int gameId,
  }) async {
    calls.add('addGameToCollection');
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> removeGameFromCollection({
    required String collectionId,
    required int gameId,
  }) async {
    calls.add('removeGameFromCollection');
    return const Right(null);
  }
}

void main() {
  late _FakeRepo repo;

  setUp(() => repo = _FakeRepo());

  group('CreateCollectionUseCase', () {
    test('trims the name and delegates to the repository', () async {
      final useCase = CreateCollectionUseCase(repo);

      final result = await useCase(
        const CreateCollectionParams(userId: 'u1', name: '  Cozy games  '),
      );

      expect(result.isRight(), isTrue);
      expect(repo.lastCreatedName, 'Cozy games');
    });

    test('rejects an empty name with a ValidationFailure', () async {
      final useCase = CreateCollectionUseCase(repo);

      final result = await useCase(
        const CreateCollectionParams(userId: 'u1', name: '   '),
      );

      expect(result.fold((l) => l, (r) => null), isA<ValidationFailure>());
      expect(repo.calls, isEmpty);
    });

    test('rejects an over-long name', () async {
      final useCase = CreateCollectionUseCase(repo);
      final longName = 'a' * (CreateCollectionUseCase.maxNameLength + 1);

      final result = await useCase(
        CreateCollectionParams(userId: 'u1', name: longName),
      );

      expect(result.fold((l) => l, (r) => null), isA<ValidationFailure>());
      expect(repo.calls, isEmpty);
    });
  });

  group('UpdateCollectionUseCase', () {
    test('rejects an empty (whitespace) rename', () async {
      final useCase = UpdateCollectionUseCase(repo);

      final result = await useCase(
        const UpdateCollectionParams(collectionId: 'c1', name: '  '),
      );

      expect(result.fold((l) => l, (r) => null), isA<ValidationFailure>());
      expect(repo.calls, isEmpty);
    });

    test('passes through a null name (metadata-only update)', () async {
      final useCase = UpdateCollectionUseCase(repo);

      final result = await useCase(
        const UpdateCollectionParams(collectionId: 'c1', isPublic: true),
      );

      expect(result.isRight(), isTrue);
      expect(repo.calls, ['updateCollection']);
    });
  });

  group('delegating use cases', () {
    test('GetUserCollectionsUseCase delegates', () async {
      final result = await GetUserCollectionsUseCase(repo)(
        const GetUserCollectionsParams(userId: 'u1'),
      );
      expect(result.getOrElse(() => []).single.name, 'Cozy games');
    });

    test('GetCollectionGameIdsUseCase delegates', () async {
      final result = await GetCollectionGameIdsUseCase(repo)(
        const GetCollectionGameIdsParams(collectionId: 'c1'),
      );
      expect(result.getOrElse(() => []), [1, 2, 3]);
    });

    test('AddGameToCollectionUseCase delegates', () async {
      final result = await AddGameToCollectionUseCase(repo)(
        const AddGameToCollectionParams(collectionId: 'c1', gameId: 7),
      );
      expect(result.isRight(), isTrue);
      expect(repo.calls, ['addGameToCollection']);
    });

    test('RemoveGameFromCollectionUseCase delegates', () async {
      final result = await RemoveGameFromCollectionUseCase(repo)(
        const RemoveGameFromCollectionParams(collectionId: 'c1', gameId: 7),
      );
      expect(result.isRight(), isTrue);
    });

    test('DeleteCollectionUseCase delegates', () async {
      final result = await DeleteCollectionUseCase(repo)(
        const DeleteCollectionParams(collectionId: 'c1'),
      );
      expect(result.isRight(), isTrue);
      expect(repo.calls, ['deleteCollection']);
    });
  });
}
