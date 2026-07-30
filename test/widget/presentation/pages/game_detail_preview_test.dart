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
import 'package:gamer_grove/presentation/pages/game_detail/game_detail_page.dart';
import 'package:gamer_grove/presentation/widgets/loading/live_loading_progress.dart';

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
    expect(
      find.byType(LiveLoadingProgress),
      findsNothing,
      reason: 'a page that can already show its subject must not show a '
          'loading screen instead',
    );
  });

  testWidgets('with nothing handed over it loads as it always did',
      (tester) async {
    // Deep links and id-only callers still exist; they get the old behaviour
    // rather than a blank head.
    await pump(tester);

    expect(find.byType(LiveLoadingProgress), findsOneWidget);
  });

  testWidgets('the wait is announced rather than only drawn', (tester) async {
    final handle = tester.ensureSemantics();
    await pump(tester, knownGame: known);

    expect(
      find.bySemanticsLabel('Loading the rest of Horizon Zero Dawn'),
      findsOneWidget,
    );
    handle.dispose();
  });
}
