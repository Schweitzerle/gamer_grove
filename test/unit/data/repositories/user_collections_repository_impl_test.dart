import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import 'package:gamer_grove/core/network/network_info.dart';
import 'package:gamer_grove/data/datasources/remote/supabase/supabase_collections_datasource.dart';
import 'package:gamer_grove/data/repositories/user_collections_repository_impl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _FakeNetworkInfo implements NetworkInfo {
  bool connected = true;

  @override
  Future<bool> get isConnected async => connected;
}

/// Hand-written fake capturing calls and letting tests inject results/errors.
class _FakeCollectionsDataSource extends Fake
    implements SupabaseCollectionsDataSource {
  List<Map<String, dynamic>> collections = const [];
  Map<String, dynamic> createResult = const {};
  Map<String, dynamic> updateResult = const {};
  List<int> gameIds = const [];
  Object? error;

  final List<String> calls = [];
  Map<String, Object?> lastArgs = const {};

  @override
  Future<List<Map<String, dynamic>>> getUserCollections(String userId) async {
    calls.add('getUserCollections');
    lastArgs = {'userId': userId};
    if (error != null) throw error!;
    return collections;
  }

  @override
  Future<Map<String, dynamic>> createCollection({
    required String userId,
    required String name,
    String? description,
  }) async {
    calls.add('createCollection');
    lastArgs = {'userId': userId, 'name': name, 'description': description};
    if (error != null) throw error!;
    return createResult;
  }

  @override
  Future<Map<String, dynamic>> updateCollection({
    required String collectionId,
    String? name,
    String? description,
    int? coverGameId,
    bool? isPublic,
  }) async {
    calls.add('updateCollection');
    lastArgs = {
      'collectionId': collectionId,
      'name': name,
      'isPublic': isPublic,
    };
    if (error != null) throw error!;
    return updateResult;
  }

  @override
  Future<void> deleteCollection(String collectionId) async {
    calls.add('deleteCollection');
    lastArgs = {'collectionId': collectionId};
    if (error != null) throw error!;
  }

  @override
  Future<List<int>> getCollectionGameIds(String collectionId) async {
    calls.add('getCollectionGameIds');
    lastArgs = {'collectionId': collectionId};
    if (error != null) throw error!;
    return gameIds;
  }

  @override
  Future<void> addGameToCollection({
    required String collectionId,
    required int gameId,
  }) async {
    calls.add('addGameToCollection');
    lastArgs = {'collectionId': collectionId, 'gameId': gameId};
    if (error != null) throw error!;
  }

  @override
  Future<void> removeGameFromCollection({
    required String collectionId,
    required int gameId,
  }) async {
    calls.add('removeGameFromCollection');
    lastArgs = {'collectionId': collectionId, 'gameId': gameId};
    if (error != null) throw error!;
  }
}

Map<String, dynamic> _row({
  String id = 'c1',
  String userId = 'u1',
  String name = 'Cozy games',
  int? count,
}) {
  return {
    'id': id,
    'user_id': userId,
    'name': name,
    'description': null,
    'cover_game_id': null,
    'is_public': false,
    'created_at': '2026-07-22T10:00:00Z',
    'updated_at': '2026-07-22T10:00:00Z',
    if (count != null)
      'user_collection_games': [
        {'count': count},
      ],
  };
}

void main() {
  late _FakeCollectionsDataSource dataSource;
  late _FakeNetworkInfo networkInfo;
  late UserCollectionsRepositoryImpl repository;

  // A headless client — constructed but never used for network by these tests
  // (the repository only touches the injected data source).
  final client = SupabaseClient('http://localhost', 'test-anon-key');

  setUp(() {
    dataSource = _FakeCollectionsDataSource();
    networkInfo = _FakeNetworkInfo();
    repository = UserCollectionsRepositoryImpl(
      dataSource: dataSource,
      supabase: client,
      networkInfo: networkInfo,
    );
  });

  Failure failureOf(Either<Failure, Object?> result) =>
      result.fold((l) => l, (r) => throw StateError('expected Left, got $r'));

  group('getUserCollections', () {
    test('maps rows to entities including the embedded game count', () async {
      dataSource.collections = [_row(count: 3), _row(id: 'c2', count: 0)];

      final result = await repository.getUserCollections('u1');

      expect(result.isRight(), isTrue);
      final list = result.getOrElse(() => []);
      expect(list, hasLength(2));
      expect(list.first.name, 'Cozy games');
      expect(list.first.gameCount, 3);
      expect(dataSource.calls, ['getUserCollections']);
    });

    test('returns NetworkFailure when offline without hitting the source',
        () async {
      networkInfo.connected = false;

      final result = await repository.getUserCollections('u1');

      expect(failureOf(result), isA<NetworkFailure>());
      expect(dataSource.calls, isEmpty);
    });

    test('maps a thrown exception to a Failure', () async {
      dataSource.error = Exception('boom');

      final result = await repository.getUserCollections('u1');

      expect(result.isLeft(), isTrue);
    });
  });

  group('createCollection', () {
    test('delegates and returns the persisted entity', () async {
      dataSource.createResult = _row(name: 'Backlog 2026');

      final result = await repository.createCollection(
        userId: 'u1',
        name: 'Backlog 2026',
      );

      expect(result.isRight(), isTrue);
      expect(
          result.getOrElse(() => throw StateError('x')).name, 'Backlog 2026');
      expect(dataSource.lastArgs['name'], 'Backlog 2026');
    });
  });

  group('game membership', () {
    test('getCollectionGameIds returns the ordered ids', () async {
      dataSource.gameIds = [10, 20, 30];

      final result = await repository.getCollectionGameIds('c1');

      expect(result.getOrElse(() => []), [10, 20, 30]);
    });

    test('addGameToCollection delegates with the right args', () async {
      final result =
          await repository.addGameToCollection(collectionId: 'c1', gameId: 42);

      expect(result.isRight(), isTrue);
      expect(dataSource.calls, ['addGameToCollection']);
      expect(dataSource.lastArgs, {'collectionId': 'c1', 'gameId': 42});
    });

    test('removeGameFromCollection delegates with the right args', () async {
      final result = await repository.removeGameFromCollection(
        collectionId: 'c1',
        gameId: 42,
      );

      expect(result.isRight(), isTrue);
      expect(dataSource.calls, ['removeGameFromCollection']);
    });
  });

  group('deleteCollection', () {
    test('delegates and reports network failure when offline', () async {
      networkInfo.connected = false;

      final result = await repository.deleteCollection('c1');

      expect(failureOf(result), isA<NetworkFailure>());
      expect(dataSource.calls, isEmpty);
    });
  });
}
