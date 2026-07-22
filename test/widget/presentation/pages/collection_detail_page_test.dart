import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import 'package:gamer_grove/domain/entities/collection/user_collection.dart';
import 'package:gamer_grove/domain/repositories/game_repository.dart';
import 'package:gamer_grove/domain/repositories/user_collections_repository.dart';
import 'package:gamer_grove/domain/usecases/game/get_games_by_ids.dart';
import 'package:gamer_grove/domain/usecases/user_collection/get_collection_game_ids_use_case.dart';
import 'package:gamer_grove/presentation/pages/collections/collection_detail_page.dart';

/// Serves canned game ids; a null [result] means "return this error".
class _FakeCollectionsRepo extends Fake implements UserCollectionsRepository {
  _FakeCollectionsRepo(this.result);

  final Either<Failure, List<int>> result;

  @override
  Future<Either<Failure, List<int>>> getCollectionGameIds(
    String collectionId,
  ) async =>
      result;
}

/// Never called in these tests (ids are empty or errored before game loading).
class _UnusedGameRepo extends Fake implements GameRepository {}

Widget _wrap(
  Either<Failure, List<int>> idsResult,
) {
  const collection = UserCollection(id: 'c1', userId: 'u1', name: 'Cozy games');
  return MaterialApp(
    home: CollectionDetailPage(
      collection: collection,
      getCollectionGameIds:
          GetCollectionGameIdsUseCase(_FakeCollectionsRepo(idsResult)),
      getGamesByIds: GetGamesByIdsUseCase(_UnusedGameRepo()),
    ),
  );
}

void main() {
  testWidgets('shows the empty state for a collection with no games',
      (tester) async {
    await tester.pumpWidget(_wrap(const Right([])));
    await tester.pumpAndSettle();

    expect(find.text('No games yet'), findsOneWidget);
    expect(find.text('Cozy games'), findsOneWidget); // app bar title
  });

  testWidgets('shows an error with retry when loading ids fails',
      (tester) async {
    await tester.pumpWidget(
      _wrap(const Left(ServerFailure(message: 'offline'))),
    );
    await tester.pumpAndSettle();

    expect(find.text('offline'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });
}
