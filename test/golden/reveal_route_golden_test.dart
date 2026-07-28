import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamer_grove/core/navigation/gg_reveal_route.dart';
import 'package:gamer_grove/core/theme/gg_theme.dart';

import '../support/load_app_fonts.dart';

/// A transition cannot be judged from a still, so it is held at three points.
///
/// The middle frame is the one that matters: it is where the two shapes have to
/// be recognisably different from each other, and where a cover growing into a
/// page has to read as a cover rather than as a rectangle wiping across.
void main() {
  setUpAll(loadAppFonts);

  final navigator = GlobalKey<NavigatorState>();

  // Where a card sits in the second row of a grove, roughly.
  const origin = Rect.fromLTWH(24, 430, 150, 225);

  Widget grove(ThemeData theme) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: theme,
        navigatorKey: navigator,
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: GridView.count(
              crossAxisCount: 2,
              childAspectRatio: 2 / 3,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              children: [
                for (var i = 0; i < 6; i++)
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );

  Widget page(ThemeData theme) => Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 240,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF8A6FAE),
                      theme.colorScheme.surface,
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Horizon Zero Dawn',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Standing in the light',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );

  Future<void> hold(
    WidgetTester tester,
    GGRevealRoute<void> route,
    Duration at,
  ) async {
    tester.view.physicalSize = const Size(360, 720);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    unawaited(navigator.currentState!.push(route));
    await tester.pump();
    await tester.pump(at);
  }

  testWidgets('the depth scale exposes no edge, even from a corner',
      (tester) async {
    // The page comes forward as the shape opens, and a transform scaled about
    // the middle of the screen would leave the content short of a clip opening
    // near an edge. Anchoring the scale at the tap is what prevents that, and
    // this is the check: the outgoing page is red, so any gap between the clip
    // and the content behind it shows up as red and cannot be missed.
    tester.view.physicalSize = const Size(360, 720);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        navigatorKey: navigator,
        home: const ColoredBox(color: Color(0xFFFF0000)),
      ),
    );

    unawaited(
      navigator.currentState!.push(
        GGRevealRoute<void>.game(
          // Hard against the top-left corner: the worst case for a scale.
          origin: const Rect.fromLTWH(6, 8, 150, 225),
          builder: (_) => const ColoredBox(color: Color(0xFF1E352E)),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 90));

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/reveal_corner_no_gap.png'),
    );

    await tester.pumpAndSettle();
    navigator.currentState!.pop();
    await tester.pumpAndSettle();
  });

  for (final shape in ['game', 'grove']) {
    for (final at in [60, 130, 220]) {
      testWidgets('$shape reveal at ${at}ms', (tester) async {
        final theme = GGTheme.dark();
        await tester.pumpWidget(grove(theme));

        final route = shape == 'game'
            ? GGRevealRoute<void>.game(
                origin: origin,
                builder: (_) => page(theme),
              )
            : GGRevealRoute<void>.grove(builder: (_) => page(theme));

        await hold(tester, route, Duration(milliseconds: at));

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/reveal_${shape}_${at}ms.png'),
        );

        await tester.pumpAndSettle();
      });
    }
  }
}
