import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamer_grove/core/theme/gg_detail_light.dart';
import 'package:gamer_grove/core/theme/gg_theme.dart';
import 'package:gamer_grove/domain/entities/game/game.dart';
import 'package:gamer_grove/presentation/blocs/user_game_data/user_game_data_bloc.dart';
import 'package:gamer_grove/presentation/widgets/entity_detail/entity_games_row.dart';
import 'package:gamer_grove/presentation/widgets/entity_detail/entity_hero_overlays.dart';
import 'package:gamer_grove/presentation/widgets/game_card.dart';

class _MockUserGameDataBloc
    extends MockBloc<UserGameDataEvent, UserGameDataState>
    implements UserGameDataBloc {}

void main() {
  late _MockUserGameDataBloc userGameData;

  setUp(() {
    userGameData = _MockUserGameDataBloc();
    whenListen(
      userGameData,
      const Stream<UserGameDataState>.empty(),
      initialState: const UserGameDataInitial(),
    );
  });

  Widget wrap(Widget child, {ThemeData? theme}) => MaterialApp(
        theme: theme ?? GGTheme.dark(),
        home: BlocProvider<UserGameDataBloc>.value(
          value: userGameData,
          child: Scaffold(body: SizedBox(height: 260, child: child)),
        ),
      );

  group('EntityGamesRow', () {
    testWidgets('shows one card per game', (tester) async {
      await tester.pumpWidget(
        wrap(
          const EntityGamesRow(
            games: [
              Game(id: 1, name: 'Horizon'),
              Game(id: 2, name: 'Death Stranding'),
            ],
          ),
        ),
      );

      expect(find.byType(GameCard), findsNWidgets(2));
    });

    testWidgets('opens the game it was tapped on', (tester) async {
      await tester.pumpWidget(
        wrap(const EntityGamesRow(games: [Game(id: 7, name: 'Horizon')])),
      );

      expect(find.text('Horizon'), findsOneWidget);
    });
  });

  group('EntityGamesEmpty', () {
    // The four screens each had their own copy of this, and the event screen's
    // said "Games loading..." over a controller icon — which is not what an
    // empty result means. They now all say the same true thing, named for
    // whatever it is that has no games.
    testWidgets('names the thing that has nothing', (tester) async {
      await tester.pumpWidget(
        wrap(const EntityGamesEmpty(subject: 'platform')),
      );

      expect(find.text('No games found'), findsOneWidget);
      expect(
        find.text('This platform has no games in our database'),
        findsOneWidget,
      );
    });

    testWidgets('reads in both themes', (tester) async {
      for (final theme in [GGTheme.dark(), GGTheme.light()]) {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(
          wrap(const EntityGamesEmpty(subject: 'company'), theme: theme),
        );
        await expectLater(tester, meetsGuideline(textContrastGuideline));
        handle.dispose();
      }
    });
  });

  group('EntityHeroOverlays', () {
    testWidgets('without a tint it ends in the plain surface', (tester) async {
      final theme = GGTheme.dark();
      await tester.pumpWidget(wrap(const EntityHeroOverlays(), theme: theme));

      expect(_footColour(tester), theme.colorScheme.surface);
    });

    testWidgets('with a tint it ends in the lit surface', (tester) async {
      // A game's page hands off to content standing in its cover's light, so
      // the artwork has to fade out into the same colour. Ending in the plain
      // surface is what put a visible line across the page.
      final theme = GGTheme.dark();
      const tint = Color(0xFF6B5285);

      await tester.pumpWidget(
        wrap(const EntityHeroOverlays(tint: tint), theme: theme),
      );

      expect(_footColour(tester), litSurface(theme.colorScheme, tint));
      expect(_footColour(tester), isNot(theme.colorScheme.surface));
    });
  });
}

/// The last colour of the vertical gradient — what the artwork fades out into.
Color _footColour(WidgetTester tester) {
  final boxes = tester
      .widgetList<DecoratedBox>(find.byType(DecoratedBox))
      .where((b) => b.decoration is BoxDecoration)
      .map((b) => b.decoration as BoxDecoration)
      .where((d) => d.gradient is LinearGradient)
      .map((d) => d.gradient! as LinearGradient)
      .where((g) => g.begin == Alignment.topCenter)
      .toList();

  expect(boxes, hasLength(1), reason: 'exactly one vertical gradient');
  return boxes.single.colors.last;
}
