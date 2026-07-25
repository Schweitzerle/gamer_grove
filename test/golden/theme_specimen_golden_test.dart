import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamer_grove/core/theme/gg_theme.dart';
import 'package:gamer_grove/core/theme/gg_tokens.dart';
import 'package:gamer_grove/core/theme/gg_typography.dart';

import '../support/load_app_fonts.dart';

/// Visual regression for the theme itself.
///
/// The theme is not a screen, so the thing worth snapshotting is a specimen:
/// the type scale and the components whose look the theme actually decides.
/// A change to a colour role or a font size shows up here as an image diff
/// before it quietly reshapes every screen in the app.
void main() {
  setUpAll(loadAppFonts);

  Widget specimen(ThemeData theme) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: Builder(
        builder: (context) {
          final t = Theme.of(context);
          final tokens = context.ggTokens;
          return Scaffold(
            appBar: AppBar(title: const Text('Grove')),
            body: SingleChildScrollView(
              padding: EdgeInsets.all(tokens.spaceMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: tokens.spaceMd,
                children: [
                  Text('Deine Top 3', style: t.textTheme.displaySmall),
                  Text('Weiterspielen', style: t.textTheme.headlineSmall),
                  Text(
                    'Ein Hain ist ein Ort, kein Baum.',
                    style: t.textTheme.bodyLarge,
                  ),
                  Text(
                    'Sekundärer Text, der erklärt statt zu behaupten.',
                    style: t.textTheme.bodySmall,
                  ),
                  // Tabular figures are the reason IBM Plex was chosen: these
                  // have to stay in column across rows.
                  Text(
                    '9,4 · 8,8 · 10,0',
                    style: t.textTheme.titleLarge?.tabular,
                  ),
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(tokens.spaceMd),
                      child: Text(
                        'Cozy games · 14',
                        style: t.textTheme.titleMedium,
                      ),
                    ),
                  ),
                  Row(
                    spacing: tokens.spaceSm,
                    children: [
                      FilledButton(
                        onPressed: () {},
                        child: const Text('Bewerten'),
                      ),
                      OutlinedButton(
                        onPressed: () {},
                        child: const Text('Wunschliste'),
                      ),
                    ],
                  ),
                  Row(
                    spacing: tokens.spaceSm,
                    children: const [
                      Chip(label: Text('Indie')),
                      Chip(label: Text('Metroidvania')),
                    ],
                  ),
                  const TextField(
                    decoration: InputDecoration(labelText: 'Spiel suchen'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> pumpAt(
    WidgetTester tester,
    ThemeData theme, {
    double textScale = 1.0,
  }) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
        child: specimen(theme),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('brand theme — dark', (tester) async {
    await pumpAt(tester, GGTheme.dark());
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/theme_specimen_dark.png'),
    );
  });

  testWidgets('brand theme — light', (tester) async {
    await pumpAt(tester, GGTheme.light());
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/theme_specimen_light.png'),
    );
  });

  // 200% is the WCAG 2.2 bar. If the scale breaks the layout, it breaks here
  // rather than on someone's phone.
  testWidgets('brand theme — dark at 200% text scale', (tester) async {
    await pumpAt(tester, GGTheme.dark(), textScale: 2);
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/theme_specimen_dark_200.png'),
    );
  });
}
