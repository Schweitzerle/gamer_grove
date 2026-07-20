import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import 'package:gamer_grove/core/network/network_info.dart';
import 'package:gamer_grove/data/datasources/remote/igdb/igdb_datasource.dart';
import 'package:gamer_grove/data/datasources/remote/igdb/models/igdb_query.dart';
import 'package:gamer_grove/data/models/game/game_model.dart';
import 'package:gamer_grove/data/repositories/base/igdb_base_repository.dart';
import 'package:gamer_grove/data/repositories/game_repository_impl.dart';

class _FakeNetworkInfo implements NetworkInfo {
  bool connected = true;

  @override
  Future<bool> get isConnected async => connected;
}

/// Hand-written fake over the many-method [IgdbDataSource]; only the calls the
/// tested repository methods make are implemented. Any other call throws via
/// [Fake.noSuchMethod], surfacing accidental coupling.
class _FakeIgdbDataSource extends Fake implements IgdbDataSource {
  List<GameModel> gamesToReturn = const [];
  Object? queryGamesError;
  int queryGamesCalls = 0;
  IgdbGameQuery? lastQuery;

  @override
  Future<List<GameModel>> queryGames(IgdbGameQuery query) async {
    queryGamesCalls++;
    lastQuery = query;
    final error = queryGamesError;
    if (error != null) throw error;
    return gamesToReturn;
  }
}

void main() {
  late _FakeIgdbDataSource dataSource;
  late _FakeNetworkInfo networkInfo;
  late GameRepositoryImpl repository;

  setUp(() {
    dataSource = _FakeIgdbDataSource();
    networkInfo = _FakeNetworkInfo();
    repository = GameRepositoryImpl(
      igdbDataSource: dataSource,
      networkInfo: networkInfo,
    );
  });

  Failure failureOf(Either<Failure, Object?> result) =>
      result.fold((l) => l, (r) => throw StateError('expected a Left, got $r'));

  group('searchGames', () {
    test('delegates to the data source and returns the games on success',
        () async {
      dataSource.gamesToReturn = [GameModel(id: 1, name: 'Celeste')];

      final result = await repository.searchGames('celeste', 20, 0);

      expect(result.isRight(), isTrue);
      expect(dataSource.queryGamesCalls, 1);
      final games = result.getOrElse(() => const []);
      expect(games.single.name, 'Celeste');
    });

    test('short-circuits an empty query without hitting the data source',
        () async {
      final result = await repository.searchGames('   ', 20, 0);

      expect(result.isRight(), isTrue);
      expect(result.getOrElse(() => const []), isEmpty);
      expect(dataSource.queryGamesCalls, 0);
    });

    test('returns a NetworkFailure when offline and never calls the source',
        () async {
      networkInfo.connected = false;

      final result = await repository.searchGames('celeste', 20, 0);

      expect(failureOf(result), isA<NetworkFailure>());
      expect(dataSource.queryGamesCalls, 0);
    });

    test('maps an IGDB rate-limit exception to a ServerFailure', () async {
      dataSource.queryGamesError = const IgdbRateLimitException();

      final result = await repository.searchGames('celeste', 20, 0);

      expect(failureOf(result), isA<ServerFailure>());
    });

    test('maps an IGDB authentication exception to an AuthenticationFailure',
        () async {
      dataSource.queryGamesError = const IgdbAuthenticationException();

      final result = await repository.searchGames('celeste', 20, 0);

      expect(failureOf(result), isA<AuthenticationFailure>());
    });
  });

  group('getPopularGames', () {
    test('delegates through the _RepoDiscovery mixin seam', () async {
      dataSource.gamesToReturn = [
        GameModel(id: 2, name: 'Hades'),
        GameModel(id: 3, name: 'Hollow Knight'),
      ];

      final result = await repository.getPopularGames(20, 0);

      expect(result.isRight(), isTrue);
      expect(result.getOrElse(() => const []), hasLength(2));
      expect(dataSource.queryGamesCalls, 1);
    });
  });

  group('getGameDetails', () {
    test('rejects a non-positive id with a ValidationFailure', () async {
      final result = await repository.getGameDetails(0);

      expect(failureOf(result), isA<ValidationFailure>());
      expect(dataSource.queryGamesCalls, 0);
    });
  });
}
