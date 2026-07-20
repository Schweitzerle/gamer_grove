import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamer_grove/domain/entities/game/game.dart';
import 'package:gamer_grove/domain/entities/genre.dart';
import 'package:gamer_grove/presentation/blocs/auth/auth_bloc.dart';
import 'package:gamer_grove/presentation/blocs/auth/auth_event.dart';
import 'package:gamer_grove/presentation/blocs/auth/auth_state.dart';
import 'package:gamer_grove/presentation/blocs/user_game_data/user_game_data_bloc.dart';
import 'package:gamer_grove/presentation/widgets/game_card.dart';

class _MockUserGameDataBloc
    extends MockBloc<UserGameDataEvent, UserGameDataState>
    implements UserGameDataBloc {}

class _MockAuthBloc extends MockBloc<AuthEvent, AuthState>
    implements AuthBloc {}

/// A game without a cover URL renders the local fallback background, so the
/// widget tests never touch the network.
Game _buildGame({
  int id = 1,
  String name = 'The Witcher 3',
  double? totalRating,
  List<Genre> genres = const [],
  DateTime? firstReleaseDate,
}) {
  return Game(
    id: id,
    name: name,
    totalRating: totalRating,
    genres: genres,
    firstReleaseDate: firstReleaseDate,
  );
}

UserGameDataLoaded _loaded({
  String userId = 'user-1',
  Set<int> wishlisted = const {},
  Set<int> recommended = const {},
  Map<int, double> rated = const {},
  List<int> topThree = const [],
}) {
  return UserGameDataLoaded(
    userId: userId,
    wishlistedGameIds: wishlisted,
    recommendedGameIds: recommended,
    ratedGames: rated,
    topThreeGameIds: topThree,
  );
}

void main() {
  late _MockUserGameDataBloc userGameDataBloc;
  late _MockAuthBloc authBloc;

  setUp(() {
    userGameDataBloc = _MockUserGameDataBloc();
    authBloc = _MockAuthBloc();
    _stubState(userGameDataBloc, UserGameDataInitial());
    _stubState(authBloc, const AuthUnauthenticated());
    // GameCard awaits HapticFeedback before firing onTap; give the platform
    // channel a handler so the awaited future resolves in the test env.
    TestWidgetsFlutterBinding.ensureInitialized()
        .defaultBinaryMessenger
        .setMockMethodCallHandler(
            SystemChannels.platform, (call) async => null);
  });

  tearDown(() {
    TestWidgetsFlutterBinding.ensureInitialized()
        .defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
    userGameDataBloc.close();
    authBloc.close();
  });

  Future<void> pumpCard(
    WidgetTester tester, {
    required Game game,
    VoidCallback? onTap,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: MultiBlocProvider(
              providers: [
                BlocProvider<UserGameDataBloc>.value(value: userGameDataBloc),
                BlocProvider<AuthBloc>.value(value: authBloc),
              ],
              child: GameCard(game: game, onTap: onTap ?? () {}),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  group('GameCard rendering', () {
    testWidgets('shows the game title', (tester) async {
      await pumpCard(tester, game: _buildGame(name: 'Hollow Knight'));

      expect(find.text('Hollow Knight'), findsOneWidget);
    });

    testWidgets('shows up to two genres joined by a comma', (tester) async {
      await pumpCard(
        tester,
        game: _buildGame(
          genres: const [
            Genre(id: 1, checksum: 'c1', name: 'RPG'),
            Genre(id: 2, checksum: 'c2', name: 'Adventure'),
            Genre(id: 3, checksum: 'c3', name: 'Strategy'),
          ],
        ),
      );

      expect(find.text('RPG, Adventure'), findsOneWidget);
    });

    testWidgets('renders the IGDB rating circle when totalRating is set',
        (tester) async {
      await pumpCard(tester, game: _buildGame(totalRating: 87.4));

      expect(find.text('87'), findsOneWidget);
      expect(find.byIcon(Icons.public), findsOneWidget);
    });

    testWidgets('hides the IGDB rating circle when totalRating is null',
        (tester) async {
      await pumpCard(tester, game: _buildGame());

      expect(find.byIcon(Icons.public), findsNothing);
    });
  });

  group('GameCard reads user state from UserGameDataBloc', () {
    testWidgets('shows the user rating circle for a rated game',
        (tester) async {
      _stubState(userGameDataBloc, _loaded(rated: const {1: 9}));

      await pumpCard(tester, game: _buildGame());

      // Rating is stored 0-10 and rendered as *10 => "90".
      expect(find.text('90'), findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('shows wishlist and recommend indicators', (tester) async {
      _stubState(
        userGameDataBloc,
        _loaded(wishlisted: const {1}, recommended: const {1}),
      );

      await pumpCard(tester, game: _buildGame());

      expect(find.byIcon(Icons.favorite), findsOneWidget);
      expect(find.byIcon(Icons.thumb_up), findsOneWidget);
    });

    testWidgets('shows no user indicators when nothing is set', (tester) async {
      await pumpCard(tester, game: _buildGame());

      expect(find.byIcon(Icons.person), findsNothing);
      expect(find.byIcon(Icons.favorite), findsNothing);
      expect(find.byIcon(Icons.thumb_up), findsNothing);
    });
  });

  group('GameCard interaction', () {
    testWidgets('invokes onTap when tapped', (tester) async {
      var tapped = 0;
      await pumpCard(
        tester,
        game: _buildGame(),
        onTap: () => tapped++,
      );

      await tester.tap(find.byType(GameCard));
      await tester.pumpAndSettle();

      expect(tapped, 1);
    });
  });

  group('GameCard accessibility', () {
    testWidgets('exposes a button semantics node labelled with the game name',
        (tester) async {
      final handle = tester.ensureSemantics();
      await pumpCard(tester, game: _buildGame(name: 'Celeste'));

      final semantics = tester.getSemantics(find.byType(GameCard));
      expect(semantics.label, contains('Celeste'));
      expect(semantics, isSemantics(isButton: true));

      handle.dispose();
    });

    testWidgets('meets tap-target and labelled-target guidelines',
        (tester) async {
      final handle = tester.ensureSemantics();
      await pumpCard(tester, game: _buildGame(totalRating: 80));

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));

      handle.dispose();
    });
  });
}

void _stubState<E, S>(MockBloc<E, S> bloc, S state) {
  whenListen(bloc, Stream<S>.value(state), initialState: state);
}
