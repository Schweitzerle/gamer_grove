import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamer_grove/core/theme/gg_theme.dart';
import 'package:gamer_grove/domain/entities/game/game.dart';
import 'package:gamer_grove/presentation/blocs/user_game_data/user_game_data_bloc.dart';
import 'package:gamer_grove/presentation/widgets/sections/related_games/content_dlc_section.dart';
import 'package:gamer_grove/presentation/widgets/sections/related_games/similar_related_section.dart';
import 'package:gamer_grove/presentation/widgets/sections/related_games/versions_remakes_section.dart';

import '../support/load_app_fonts.dart';

class _MockUserGameDataBloc
    extends MockBloc<UserGameDataEvent, UserGameDataState>
    implements UserGameDataBloc {}

/// The three related-games groups, closed.
///
/// This is the gate on a change that is easy to make and hard to see: the tab
/// accents used to be drawn raw, and `Colors.green` reads at 2.60:1 on the
/// light surface while `Colors.purple` reads at 2.92:1 on the dark one. They
/// are now lifted per surface, which means these two images are the only place
/// the difference is visible side by side.
void main() {
  setUpAll(loadAppFonts);

  const other = Game(id: 2, name: 'The Frozen Wilds');

  const game = Game(
    id: 1,
    name: 'Horizon',
    dlcs: [other],
    expansions: [other],
    bundles: [other],
    remakes: [other],
    ports: [other],
    similarGames: [other],
    forks: [other],
  );

  late _MockUserGameDataBloc userGameData;

  setUp(() {
    userGameData = _MockUserGameDataBloc();
    whenListen(
      userGameData,
      const Stream<UserGameDataState>.empty(),
      initialState: const UserGameDataInitial(),
    );
  });

  Future<void> pump(WidgetTester tester, ThemeData theme) async {
    tester.view.physicalSize = const Size(400, 380);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: theme,
        home: BlocProvider<UserGameDataBloc>.value(
          value: userGameData,
          child: const Scaffold(
            body: Column(
              children: [
                ContentDLCSection(game: game),
                VersionsRemakesSection(game: game),
                SimilarRelatedSection(game: game),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('the three groups, closed — dark', (tester) async {
    await pump(tester, GGTheme.dark());
    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('goldens/related_games_dark.png'),
    );
  });

  testWidgets('the three groups, closed — light', (tester) async {
    await pump(tester, GGTheme.light());
    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('goldens/related_games_light.png'),
    );
  });
}
