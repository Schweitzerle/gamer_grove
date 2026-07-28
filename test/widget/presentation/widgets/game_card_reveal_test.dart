import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamer_grove/core/navigation/gg_reveal_route.dart';
import 'package:gamer_grove/domain/entities/game/game.dart';
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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MockUserGameDataBloc userGameData;
  late _MockAuthBloc auth;

  setUp(() {
    RevealOrigin.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async => null,
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
  });

  testWidgets('a tapped card reports the box it occupies', (tester) async {
    // The regression this guards was silent and looked like a design choice.
    // Navigation helpers take whatever context the caller has, and inside a
    // `ListView.builder` that is the sliver's — its render object is a
    // `RenderSliver`, so measuring it returned null and every reveal grew out
    // of the middle of the screen instead of out of the cover. Only the card
    // knows its own box, so the card is what records it.
    Rect? recorded;

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<UserGameDataBloc>.value(value: userGameData),
          BlocProvider<AuthBloc>.value(value: auth),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: Center(
              child: GameCard(
                game: const Game(id: 1, name: 'Horizon'),
                onTap: () => recorded = RevealOrigin.take(),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final card = tester.getRect(find.byType(GameCard));

    await tester.tap(find.byType(GameCard));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(
      recorded,
      isNotNull,
      reason: 'without an origin the reveal grows from the middle of the '
          'screen, which is the bug this exists for',
    );
    expect(recorded, card);
  });

  testWidgets('a recorded origin is not inherited by the next navigation',
      (tester) async {
    // Otherwise a later push from somewhere unmeasurable would open out of
    // whatever happened to be tapped before it.
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => const SizedBox(width: 100, height: 100),
        ),
      ),
    );

    RevealOrigin.record(tester.element(find.byType(SizedBox)));
    expect(RevealOrigin.take(), isNotNull);
    expect(RevealOrigin.take(), isNull);
  });
}
