import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import 'package:gamer_grove/domain/entities/collection/user_collection.dart';
import 'package:gamer_grove/domain/repositories/user_collections_repository.dart';
import 'package:gamer_grove/domain/usecases/user_collection/add_game_to_collection_use_case.dart';
import 'package:gamer_grove/domain/usecases/user_collection/create_collection_use_case.dart';
import 'package:gamer_grove/domain/usecases/user_collection/delete_collection_use_case.dart';
import 'package:gamer_grove/domain/usecases/user_collection/get_collection_ids_containing_game_use_case.dart';
import 'package:gamer_grove/domain/usecases/user_collection/get_user_collections_use_case.dart';
import 'package:gamer_grove/domain/usecases/user_collection/remove_game_from_collection_use_case.dart';
import 'package:gamer_grove/domain/usecases/user_collection/update_collection_use_case.dart';
import 'package:gamer_grove/injection_container.dart';
import 'package:gamer_grove/presentation/blocs/user_collections/user_collections_bloc.dart';
import 'package:gamer_grove/presentation/pages/collections/widgets/add_to_collection_sheet.dart';

/// Repository serving a fixed list and a configurable add result, so the sheet
/// can be driven through both the success and the failure path.
class _FakeRepo implements UserCollectionsRepository {
  _FakeRepo(
    this._collections, {
    this.addFailure,
    this.containing = const [],
    this.containingFailure,
  });

  final List<UserCollection> _collections;
  final Failure? addFailure;

  /// Collection ids reported as already holding the game.
  final List<String> containing;

  /// Makes the membership lookup fail instead of returning [containing].
  final Failure? containingFailure;
  int addCalls = 0;

  @override
  Future<Either<Failure, List<String>>> getCollectionIdsContainingGame({
    required String userId,
    required int gameId,
  }) async {
    final failure = containingFailure;
    return failure != null ? Left(failure) : Right(containing);
  }

  @override
  Future<Either<Failure, List<UserCollection>>> getUserCollections(
    String userId,
  ) async =>
      Right(_collections);

  @override
  Future<Either<Failure, UserCollection>> createCollection({
    required String userId,
    required String name,
    String? description,
  }) async =>
      Right(UserCollection(id: 'new', userId: userId, name: name));

  @override
  Future<Either<Failure, UserCollection>> updateCollection({
    required String collectionId,
    String? name,
    String? description,
    int? coverGameId,
    bool? isPublic,
  }) async =>
      Right(UserCollection(id: collectionId, userId: 'u1', name: name ?? 'x'));

  @override
  Future<Either<Failure, void>> deleteCollection(String collectionId) async =>
      const Right(null);

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
    addCalls++;
    final failure = addFailure;
    return failure != null ? Left(failure) : const Right(null);
  }

  @override
  Future<Either<Failure, void>> removeGameFromCollection({
    required String collectionId,
    required int gameId,
  }) async =>
      const Right(null);
}

void main() {
  late _FakeRepo repo;

  void register(_FakeRepo r) {
    repo = r;
    sl
      ..registerFactory<UserCollectionsBloc>(
        () => UserCollectionsBloc(
          getUserCollections: GetUserCollectionsUseCase(r),
          createCollection: CreateCollectionUseCase(r),
          updateCollection: UpdateCollectionUseCase(r),
          deleteCollection: DeleteCollectionUseCase(r),
          addGameToCollection: AddGameToCollectionUseCase(r),
          removeGameFromCollection: RemoveGameFromCollectionUseCase(r),
        ),
      )
      ..registerFactory<AddGameToCollectionUseCase>(
        () => AddGameToCollectionUseCase(r),
      )
      ..registerFactory<GetCollectionIdsContainingGameUseCase>(
        () => GetCollectionIdsContainingGameUseCase(r),
      );
  }

  tearDown(() async {
    if (sl.isRegistered<UserCollectionsBloc>()) {
      await sl.unregister<UserCollectionsBloc>();
    }
    if (sl.isRegistered<AddGameToCollectionUseCase>()) {
      await sl.unregister<AddGameToCollectionUseCase>();
    }
    if (sl.isRegistered<GetCollectionIdsContainingGameUseCase>()) {
      await sl.unregister<GetCollectionIdsContainingGameUseCase>();
    }
  });

  /// Pumps a screen whose single button opens the sheet, capturing its result.
  Future<List<AddToCollectionOutcome?>> pumpSheet(WidgetTester tester) async {
    final outcomes = <AddToCollectionOutcome?>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () async => outcomes.add(
                  await showAddToCollectionSheet(
                    context,
                    userId: 'u1',
                    gameId: 42,
                    gameName: 'Hollow Knight',
                  ),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    return outcomes;
  }

  final collections = [
    const UserCollection(id: 'c1', userId: 'u1', name: 'Cozy games'),
  ];

  testWidgets('lists the user collections for the game', (tester) async {
    register(_FakeRepo(collections));

    await pumpSheet(tester);

    expect(find.text('Add to collection'), findsOneWidget);
    expect(find.text('Hollow Knight'), findsOneWidget);
    expect(find.text('Cozy games'), findsOneWidget);
  });

  testWidgets('adds the game and closes with a success outcome',
      (tester) async {
    register(_FakeRepo(collections));

    final outcomes = await pumpSheet(tester);
    await tester.tap(find.text('Cozy games'));
    await tester.pumpAndSettle();

    expect(repo.addCalls, 1);
    expect(find.text('Add to collection'), findsNothing); // sheet closed
    expect(outcomes, hasLength(1));
    expect(outcomes.single!.isAdded, isTrue);
    expect(outcomes.single!.collectionName, 'Cozy games');
  });

  testWidgets('closes with a failure outcome when the write fails',
      (tester) async {
    register(
      _FakeRepo(
        collections,
        addFailure: const ServerFailure(message: 'no connection'),
      ),
    );

    final outcomes = await pumpSheet(tester);
    await tester.tap(find.text('Cozy games'));
    await tester.pumpAndSettle();

    expect(outcomes, hasLength(1));
    expect(outcomes.single!.isAdded, isFalse);
    expect(outcomes.single!.error, 'no connection');
  });

  testWidgets('dismissing without picking yields no outcome', (tester) async {
    register(_FakeRepo(collections));

    final outcomes = await pumpSheet(tester);
    await tester.tapAt(const Offset(400, 20)); // barrier
    await tester.pumpAndSettle();

    expect(repo.addCalls, 0);
    expect(outcomes, [null]);
  });

  testWidgets('marks a collection that already holds the game', (tester) async {
    register(_FakeRepo(collections, containing: ['c1']));

    await pumpSheet(tester);

    expect(find.text('Already in this collection'), findsOneWidget);
    expect(find.text('0 games'), findsNothing);
  });

  testWidgets('tapping an already-added collection does nothing',
      (tester) async {
    register(_FakeRepo(collections, containing: ['c1']));

    final outcomes = await pumpSheet(tester);
    await tester.tap(find.text('Cozy games'));
    await tester.pumpAndSettle();

    expect(repo.addCalls, 0, reason: 'no pointless write');
    expect(find.text('Add to collection'), findsOneWidget); // sheet stays open
    expect(outcomes, isEmpty, reason: 'no toast-triggering outcome');
  });

  testWidgets('stays usable when the membership lookup fails', (tester) async {
    // Membership is advisory — a failed lookup must not lock the sheet.
    register(
      _FakeRepo(
        collections,
        containingFailure: const ServerFailure(message: 'lookup down'),
      ),
    );

    final outcomes = await pumpSheet(tester);
    expect(find.text('Already in this collection'), findsNothing);

    await tester.tap(find.text('Cozy games'));
    await tester.pumpAndSettle();

    expect(repo.addCalls, 1);
    expect(outcomes.single!.isAdded, isTrue);
  });

  testWidgets('meets accessibility guidelines', (tester) async {
    final handle = tester.ensureSemantics();
    register(_FakeRepo(collections));

    await pumpSheet(tester);

    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));

    handle.dispose();
  });
}
