import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamer_grove/core/theme/gg_detail_light.dart';
import 'package:gamer_grove/core/theme/gg_theme.dart';

import '../support/load_app_fonts.dart';

/// What "Abklingend" actually looks like on a page.
///
/// The decision behind this stage was about reach: light at the top only, light
/// everywhere, or light that falls away. Whether the third one reads as a page
/// you walk out of — rather than as a coloured band with a hard end — is a
/// visual claim, so it is checked as an image and not as prose.
void main() {
  setUpAll(loadAppFonts);

  /// A page shaped like a detail page: artwork on top fading into the lit
  /// surface, then rows of content standing in what is left of the light.
  Widget page(Color tint, ThemeData theme) {
    final scheme = theme.colorScheme;
    final lit = litSurface(scheme.surface, tint);

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          // The real page gets its width from a sliver; without stretching, the
          // stand-in column would shrink to its text and the wash with it.
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Stand-in for the cover: a real network image would make this
            // golden depend on the network.
            SizedBox(
              height: 240,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0, 0.6, 1],
                    colors: [tint, Color.lerp(tint, lit, 0.6)!, lit],
                  ),
                ),
                child: const SizedBox.expand(),
              ),
            ),
            ColoredBox(
              color: scheme.surface,
              child: Stack(
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: DetailLight.reach,
                    child: DetailLight(tint: tint),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final row in const [
                        'Release',
                        'Genres',
                        'Platforms',
                        'Developers',
                        'Similar games',
                        'Screenshots',
                      ])
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(row, style: theme.textTheme.titleMedium),
                              const SizedBox(height: 4),
                              // Secondary text is the binding contrast case, so
                              // it is what stands in the brightest part.
                              Text(
                                'Standing in the light',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> pump(WidgetTester tester, Widget home) async {
    tester.view.physicalSize = const Size(380, 820);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: home,
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('the light falls away down the page — dark', (tester) async {
    final theme = GGTheme.dark();
    await pump(
      tester,
      Theme(data: theme, child: page(const Color(0xFF6B5285), theme)),
    );

    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('goldens/detail_light_dark.png'),
    );
  });

  testWidgets('the light falls away down the page — light', (tester) async {
    final theme = GGTheme.light();
    await pump(
      tester,
      Theme(data: theme, child: page(const Color(0xFF6B5285), theme)),
    );

    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('goldens/detail_light_light.png'),
    );
  });

  testWidgets('two covers give two different pages', (tester) async {
    // The point of deriving the light from the artwork is that two games do not
    // look the same. If the cap ever flattens the tint to the same near-grey,
    // this is where it shows.
    final theme = GGTheme.dark();
    tester.view.physicalSize = const Size(760, 560);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: theme,
        home: Row(
          children: [
            Expanded(child: page(const Color(0xFF6B5285), theme)),
            Expanded(child: page(const Color(0xFF5B7F4E), theme)),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(Row).first,
      matchesGoldenFile('goldens/detail_light_two_covers.png'),
    );
  });
}
