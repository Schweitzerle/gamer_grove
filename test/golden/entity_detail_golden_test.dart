import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamer_grove/core/theme/gg_theme.dart';
import 'package:gamer_grove/presentation/widgets/entity_detail/entity_games_row.dart';

import '../support/load_app_fonts.dart';

/// The empty state four detail screens now share.
///
/// It is here because the event screen's copy said "Games loading..." over a
/// controller icon — a different sentence, a different icon, and not true. This
/// is the one all four say now.
void main() {
  setUpAll(loadAppFonts);

  Future<void> pump(WidgetTester tester, ThemeData theme) async {
    tester.view.physicalSize = const Size(360, 200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: theme,
        home: const Scaffold(
          body: Padding(
            padding: EdgeInsets.all(16),
            child: EntityGamesEmpty(subject: 'company'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('no games — dark', (tester) async {
    await pump(tester, GGTheme.dark());
    await expectLater(
      find.byType(EntityGamesEmpty),
      matchesGoldenFile('goldens/entity_games_empty_dark.png'),
    );
  });

  testWidgets('no games — light', (tester) async {
    await pump(tester, GGTheme.light());
    await expectLater(
      find.byType(EntityGamesEmpty),
      matchesGoldenFile('goldens/entity_games_empty_light.png'),
    );
  });
}
