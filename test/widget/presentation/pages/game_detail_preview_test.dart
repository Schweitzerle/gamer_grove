import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamer_grove/core/theme/gg_theme.dart';
import 'package:gamer_grove/domain/entities/game/game.dart';
import 'package:gamer_grove/injection_container.dart';
import 'package:gamer_grove/presentation/blocs/auth/auth_bloc.dart';
import 'package:gamer_grove/presentation/blocs/auth/auth_event.dart';
import 'package:gamer_grove/presentation/blocs/auth/auth_state.dart';
import 'package:gamer_grove/presentation/blocs/game/game_bloc.dart';
import 'package:gamer_grove/presentation/blocs/user_game_data/user_game_data_bloc.dart';
import 'package:gamer_grove/presentation/pages/game_detail/widgets/game_info_card.dart';
import 'package:gamer_grove/presentation/pages/game_detail/game_detail_page.dart';
import 'package:gamer_grove/presentation/widgets/loading/live_loading_progress.dart';
import 'package:gamer_grove/presentation/widgets/loading/loading_thumbnail.dart';

class _MockGameBloc extends MockBloc<GameEvent, GameState>
    implements GameBloc {}

class _MockUserGameDataBloc
    extends MockBloc<UserGameDataEvent, UserGameDataState>
    implements UserGameDataBloc {}

class _MockAuthBloc extends MockBloc<AuthEvent, AuthState>
    implements AuthBloc {}

/// The reveal opens onto whatever the detail page shows first. While that was a
/// spinner, the transition could not reveal anything — which is what a tester
/// meant by "nothing special". The tapped card already knows the game, so the
/// page draws its head immediately and waits only for the rest.
// ignore_for_file: discarded_futures

void main() {
  // No cover URL, so nothing reaches for the network.
  const known = Game(id: 7, name: 'Horizon Zero Dawn');

  late _MockGameBloc gameBloc;
  late _MockUserGameDataBloc userGameData;
  late _MockAuthBloc auth;

  setUp(() {
    gameBloc = _MockGameBloc();
    whenListen(
      gameBloc,
      const Stream<GameState>.empty(),
      initialState: GameDetailsLoading(),
    );
    userGameData = _MockUserGameDataBloc();
    whenListen(
      userGameData,
      const Stream<UserGameDataState>.empty(),
      initialState: const UserGameDataInitial(),
    );
    auth = _MockAuthBloc();
    whenListen(
      auth,
      const Stream<AuthState>.empty(),
      initialState: const AuthInitial(),
    );

    if (sl.isRegistered<GameBloc>()) {
      sl.unregister<GameBloc>();
    }
    if (sl.isRegistered<UserGameDataBloc>()) {
      sl.unregister<UserGameDataBloc>();
    }
    sl
      ..registerFactory<GameBloc>(() => gameBloc)
      ..registerFactory<UserGameDataBloc>(() => userGameData);
  });

  tearDown(() {
    sl
      ..unregister<GameBloc>()
      ..unregister<UserGameDataBloc>();
  });

  Future<void> pump(WidgetTester tester, {Game? knownGame}) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: GGTheme.dark(),
        home: MultiBlocProvider(
          providers: [
            BlocProvider<AuthBloc>.value(value: auth),
            BlocProvider<GameBloc>.value(value: gameBloc),
          ],
          child: GameDetailPage(gameId: known.id, knownGame: knownGame),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('while loading, what the card knew is already on screen',
      (tester) async {
    await pump(tester, knownGame: known);

    expect(find.text('Horizon Zero Dawn'), findsWidgets);
    // The checklist is welcome — inside the page, under the cover. What must
    // not happen is a loading screen standing *instead of* the page, which is
    // what a scrollable page and a hero being present rules out.
    expect(find.byType(CustomScrollView), findsOneWidget);
    expect(find.byType(LiveLoadingProgress), findsOneWidget);
  });

  testWidgets('with nothing handed over it loads as it always did',
      (tester) async {
    // Deep links and id-only callers still exist; they get the old behaviour
    // rather than a blank head.
    await pump(tester);

    expect(find.byType(LiveLoadingProgress), findsOneWidget);
    expect(
      find.byType(CustomScrollView),
      findsNothing,
      reason: 'with nothing to show, there is no page to show it in',
    );
  });

  testWidgets('the hero is out of focus until the game arrives',
      (tester) async {
    // The chamber below read as a section of the page rather than as a state of
    // it. A blurred hero says "not yet" in a way a sharp one with a list under
    // it cannot.
    await pump(tester, knownGame: known);
    expect(find.byType(ImageFiltered), findsOneWidget);
  });

  testWidgets('the steps name the game rather than the database',
      (tester) async {
    await pump(tester, knownGame: known);
    expect(find.text('Opening Horizon Zero Dawn'), findsOneWidget);
  });

  testWidgets('the wait is announced rather than only drawn', (tester) async {
    final handle = tester.ensureSemantics();
    await pump(tester, knownGame: known);

    expect(
      find.bySemanticsLabel(RegExp(r'^Loading Horizon Zero Dawn\.')),
      findsOneWidget,
    );
    handle.dispose();
  });

  testWidgets('the wait is in front of the page, not a part of it',
      (tester) async {
    // Three attempts put this inside the page and all three read as one more
    // element of it. What separates a step *before* the page from a piece *of*
    // it is position: the card is over everything, with the page as backdrop.
    await pump(tester, knownGame: known);

    final card = find.byType(LiveLoadingProgress);
    expect(card, findsOneWidget);
    expect(
      find.ancestor(of: card, matching: find.byType(CustomScrollView)),
      findsNothing,
      reason: 'the card scrolls with the page when it sits inside it',
    );
  });

  testWidgets('the cover is named while it stands in for the page',
      (tester) async {
    await pump(tester, knownGame: known);
    expect(find.byType(LoadingThumbnail), findsOneWidget);
  });

  testWidgets('nothing behind the card repeats what is on it', (tester) async {
    // The hero's info card carries the name and the rating, and so does the
    // waiting card. Drawn together, at low contrast through a scrim, the pair
    // stops being information and becomes texture — which is what a tester
    // meant by "zu viel noise".
    await pump(tester, knownGame: known);
    expect(find.byType(GameInfoCard), findsNothing);
  });

  testWidgets('leaving is still possible while it waits', (tester) async {
    // A full-screen card that swallowed pointers would trap the reader behind
    // a request that can outlast a bad connection: the app bar and its back
    // button sit underneath it.
    await pump(tester, knownGame: known);
    expect(
      find.ancestor(
        of: find.byType(LiveLoadingProgress),
        matching: find.byType(IgnorePointer),
      ),
      findsWidgets,
      reason: 'the overlay must let taps through to the page behind it',
    );
  });
}
