import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamer_grove/core/theme/gg_theme.dart';
import 'package:gamer_grove/domain/entities/game/game.dart';
import 'package:gamer_grove/presentation/widgets/top_three/top_three_stack.dart';

import '../support/load_app_fonts.dart';

/// Visual regression for the composition: depth, the spotlight, the numerals
/// and the empty places.
///
/// Motion is disabled and covers carry no URL, so nothing here depends on a
/// timer or the network — a golden that races the intro cycle would be a
/// golden that fails at random.
void main() {
  setUpAll(loadAppFonts);

  Game game(int id, String name) => Game(id: id, name: name, totalRating: 92);

  final full = [
    game(1, 'Hollow Knight: Silksong'),
    game(2, 'Outer Wilds'),
    game(3, 'Return of the Obra Dinn'),
  ];

  Future<void> pump(
    WidgetTester tester,
    ThemeData theme,
    List<Game> games, {
    Size size = const Size(400, 420),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: theme,
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: TopThreeStack(games: games, onOpenGame: (_) {}),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('filled — dark', (tester) async {
    await pump(tester, GGTheme.dark(), full);
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/top_three_dark.png'),
    );
  });

  testWidgets('filled — light', (tester) async {
    await pump(tester, GGTheme.light(), full);
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/top_three_light.png'),
    );
  });

  testWidgets('one of three set — the empty places have to invite, not fail',
      (tester) async {
    await pump(tester, GGTheme.dark(), [full.first]);
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/top_three_partial.png'),
    );
  });

  // 320dp is the narrowest device the app supports, and the stack is the
  // widest thing on the home screen.
  testWidgets('narrow screen', (tester) async {
    await pump(tester, GGTheme.dark(), full, size: const Size(320, 400));
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/top_three_320.png'),
    );
  });
}
