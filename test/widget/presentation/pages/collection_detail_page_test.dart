import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import 'package:gamer_grove/domain/entities/collection/user_collection.dart';
import 'package:gamer_grove/domain/entities/game/game.dart';
import 'package:gamer_grove/domain/repositories/game_repository.dart';
import 'package:gamer_grove/domain/repositories/user_collections_repository.dart';
import 'package:gamer_grove/domain/usecases/game/get_games_by_ids.dart';
import 'package:gamer_grove/domain/usecases/user_collection/get_collection_game_ids_use_case.dart';
import 'package:gamer_grove/presentation/blocs/auth/auth_bloc.dart';
import 'package:gamer_grove/presentation/blocs/auth/auth_event.dart';
import 'package:gamer_grove/presentation/blocs/auth/auth_state.dart';
import 'package:gamer_grove/presentation/blocs/user_collections/user_collections_bloc.dart';
import 'package:gamer_grove/presentation/blocs/user_game_data/user_game_data_bloc.dart';
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

/// Returns the games whose ids were requested, in request order.
class _FakeGameRepo extends Fake implements GameRepository {
  _FakeGameRepo(this.games);

  final List<Game> games;

  @override
  Future<Either<Failure, List<Game>>> getGamesByIds(List<int> ids) async =>
      Right([
        for (final id in ids) ...games.where((g) => g.id == id),
      ]);
}

class _MockUserCollectionsBloc
    extends MockBloc<UserCollectionsEvent, UserCollectionsState>
    implements UserCollectionsBloc {}

class _MockUserGameDataBloc
    extends MockBloc<UserGameDataEvent, UserGameDataState>
    implements UserGameDataBloc {}

class _MockAuthBloc extends MockBloc<AuthEvent, AuthState>
    implements AuthBloc {}

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

  group('edit mode', () {
    late _MockUserCollectionsBloc collectionsBloc;
    late _MockUserGameDataBloc userGameDataBloc;
    late _MockAuthBloc authBloc;

    setUp(() {
      collectionsBloc = _MockUserCollectionsBloc();
      userGameDataBloc = _MockUserGameDataBloc();
      authBloc = _MockAuthBloc();
      whenListen(
        collectionsBloc,
        const Stream<UserCollectionsState>.empty(),
        initialState: const UserCollectionsInitial(),
      );
      whenListen(
        userGameDataBloc,
        const Stream<UserGameDataState>.empty(),
        initialState: UserGameDataInitial(),
      );
      whenListen(
        authBloc,
        const Stream<AuthState>.empty(),
        initialState: const AuthUnauthenticated(),
      );
      // GameCard awaits HapticFeedback; give the channel a handler.
      TestWidgetsFlutterBinding.ensureInitialized()
          .defaultBinaryMessenger
          .setMockMethodCallHandler(
            SystemChannels.platform,
            (call) async => null,
          );
    });

    tearDown(() {
      TestWidgetsFlutterBinding.ensureInitialized()
          .defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null);
      collectionsBloc.close();
      userGameDataBloc.close();
      authBloc.close();
    });

    Future<void> pumpWithGames(WidgetTester tester) async {
      const collection =
          UserCollection(id: 'c1', userId: 'u1', name: 'Cozy games');
      final games = [
        const Game(id: 1, name: 'Stardew Valley'),
        const Game(id: 2, name: 'Spiritfarer'),
      ];
      await tester.pumpWidget(
        MaterialApp(
          home: MultiBlocProvider(
            providers: [
              BlocProvider<UserCollectionsBloc>.value(value: collectionsBloc),
              BlocProvider<UserGameDataBloc>.value(value: userGameDataBloc),
              BlocProvider<AuthBloc>.value(value: authBloc),
            ],
            child: CollectionDetailPage(
              collection: collection,
              getCollectionGameIds: GetCollectionGameIdsUseCase(
                _FakeCollectionsRepo(const Right([1, 2])),
              ),
              getGamesByIds: GetGamesByIdsUseCase(_FakeGameRepo(games)),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('offers a visible way into removing games', (tester) async {
      await pumpWithGames(tester);

      expect(find.byTooltip('Remove games'), findsOneWidget);
      expect(find.text('Stardew Valley'), findsOneWidget);
    });

    testWidgets('shows a remove badge per game once enabled', (tester) async {
      await pumpWithGames(tester);

      await tester.tap(find.byTooltip('Remove games'));
      await tester.pumpAndSettle();

      expect(find.text('Remove games'), findsOneWidget); // app bar title
      expect(
        find.text('Tap the − on a game to remove it from this collection.'),
        findsOneWidget,
      );
      expect(find.bySemanticsLabel('Remove Stardew Valley from collection'),
          findsOneWidget);
      expect(find.text('Done'), findsOneWidget);
    });

    testWidgets('the badge asks for confirmation before removing',
        (tester) async {
      await pumpWithGames(tester);
      await tester.tap(find.byTooltip('Remove games'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.remove_rounded).first);
      await tester.pumpAndSettle();

      expect(find.text('Remove from collection?'), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.text('Stardew Valley'), findsOneWidget, reason: 'kept');
    });

    testWidgets('no edit affordance while the collection is empty',
        (tester) async {
      await tester.pumpWidget(_wrap(const Right([])));
      await tester.pumpAndSettle();

      expect(find.byTooltip('Remove games'), findsNothing);
    });
  });
}
