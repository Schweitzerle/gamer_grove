import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamer_grove/core/theme/gg_theme.dart';
import 'package:gamer_grove/domain/entities/game/game.dart';
import 'package:gamer_grove/presentation/blocs/auth/auth_bloc.dart';
import 'package:gamer_grove/presentation/blocs/auth/auth_event.dart';
import 'package:gamer_grove/presentation/blocs/auth/auth_state.dart';
import 'package:gamer_grove/presentation/blocs/user_game_data/user_game_data_bloc.dart';
import 'package:gamer_grove/presentation/widgets/game_card.dart';

import '../support/load_app_fonts.dart';

class _MockUserGameDataBloc
    extends MockBloc<UserGameDataEvent, UserGameDataState>
    implements UserGameDataBloc {}

class _MockAuthBloc extends MockBloc<AuthEvent, AuthState>
    implements AuthBloc {}

/// The card carries the brand on every screen it appears on, so it gets its own
/// visual gate.
///
/// Games are given no cover URL on purpose: the widget then paints its local
/// fallback and the goldens stay offline and deterministic. What is under test
/// here is the card's own chrome — radius, shadow, scrims and badges — not the
/// artwork behind it.
void main() {
  setUpAll(loadAppFonts);

  late _MockUserGameDataBloc userGameData;
  late _MockAuthBloc auth;

  setUp(() {
    userGameData = _MockUserGameDataBloc();
    auth = _MockAuthBloc();
    whenListen(
      userGameData,
      const Stream<UserGameDataState>.empty(),
      initialState: const UserGameDataLoaded(
        userId: 'user-1',
        wishlistedGameIds: {2},
        recommendedGameIds: {},
        ratedGames: {1: 8.4},
        topThreeGameIds: [1],
      ),
    );
    whenListen(
      auth,
      const Stream<AuthState>.empty(),
      initialState: const AuthUnauthenticated(),
    );
  });

  tearDown(() async {
    await userGameData.close();
    await auth.close();
  });

  Future<void> pump(WidgetTester tester, ThemeData theme, Game game) async {
    tester.view.physicalSize = const Size(240, 320);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: theme,
        home: Scaffold(
          body: Center(
            child: MultiBlocProvider(
              providers: [
                BlocProvider<UserGameDataBloc>.value(value: userGameData),
                BlocProvider<AuthBloc>.value(value: auth),
              ],
              child: GameCard(game: game, onTap: () {}),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  const rated = Game(id: 1, name: 'Return of the Obra Dinn', totalRating: 89);
  const plain = Game(id: 3, name: 'Pentiment');

  testWidgets('rated and ranked — dark', (tester) async {
    await pump(tester, GGTheme.dark(), rated);
    await expectLater(
      find.byType(GameCard),
      matchesGoldenFile('goldens/game_card_dark.png'),
    );
  });

  testWidgets('rated and ranked — light', (tester) async {
    await pump(tester, GGTheme.light(), rated);
    await expectLater(
      find.byType(GameCard),
      matchesGoldenFile('goldens/game_card_light.png'),
    );
  });

  testWidgets('nothing set yet — dark', (tester) async {
    await pump(tester, GGTheme.dark(), plain);
    await expectLater(
      find.byType(GameCard),
      matchesGoldenFile('goldens/game_card_plain_dark.png'),
    );
  });
}
