import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
import 'package:gamer_grove/presentation/pages/collections/collections_page.dart';

/// Minimal fake repository serving a fixed collection list.
class _FakeRepo implements UserCollectionsRepository {
  _FakeRepo(this._collections);

  final List<UserCollection> _collections;

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
  }) async =>
      const Right(null);

  @override
  Future<Either<Failure, void>> removeGameFromCollection({
    required String collectionId,
    required int gameId,
  }) async =>
      const Right(null);
}

UserCollectionsBloc _bloc(List<UserCollection> collections) {
  final repo = _FakeRepo(collections);
  return UserCollectionsBloc(
    getUserCollections: GetUserCollectionsUseCase(repo),
    createCollection: CreateCollectionUseCase(repo),
    updateCollection: UpdateCollectionUseCase(repo),
    deleteCollection: DeleteCollectionUseCase(repo),
    addGameToCollection: AddGameToCollectionUseCase(repo),
    removeGameFromCollection: RemoveGameFromCollectionUseCase(repo),
  );
}

Widget _wrap(UserCollectionsBloc bloc) {
  return MaterialApp(
    home: BlocProvider.value(
      value: bloc,
      child: const CollectionsPage(userId: 'u1'),
    ),
  );
}

void main() {
  UserCollection col(String id, String name, {int count = 0}) =>
      UserCollection(id: id, userId: 'u1', name: name, gameCount: count);

  testWidgets('shows the empty state when there are no collections',
      (tester) async {
    final bloc = _bloc([])..add(const LoadCollections('u1'));
    addTearDown(bloc.close);

    await tester.pumpWidget(_wrap(bloc));
    await tester.pumpAndSettle();

    expect(find.text('No collections yet'), findsOneWidget);
    expect(find.text('Create your first collection'), findsOneWidget);
  });

  testWidgets('renders a tile per collection with its game count',
      (tester) async {
    final bloc =
        _bloc([col('c1', 'Cozy games', count: 3), col('c2', 'Backlog')])
          ..add(const LoadCollections('u1'));
    addTearDown(bloc.close);

    await tester.pumpWidget(_wrap(bloc));
    await tester.pumpAndSettle();

    expect(find.text('Cozy games'), findsOneWidget);
    expect(find.text('Backlog'), findsOneWidget);
    expect(find.text('3 games'), findsOneWidget);
  });

  testWidgets('opens the create sheet from the FAB', (tester) async {
    final bloc = _bloc([])..add(const LoadCollections('u1'));
    addTearDown(bloc.close);

    await tester.pumpWidget(_wrap(bloc));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.text('New collection'), findsOneWidget);
    expect(find.text('Name'), findsOneWidget); // name field label
    expect(find.text('Create'), findsOneWidget);
  });

  testWidgets('meets accessibility guidelines when loaded', (tester) async {
    final handle = tester.ensureSemantics();
    final bloc = _bloc([col('c1', 'Cozy games', count: 1)])
      ..add(const LoadCollections('u1'));
    addTearDown(bloc.close);

    await tester.pumpWidget(_wrap(bloc));
    await tester.pumpAndSettle();

    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));

    handle.dispose();
  });
}
