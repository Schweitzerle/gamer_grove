import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamer_grove/core/theme/gg_theme.dart';
import 'package:gamer_grove/presentation/widgets/loading/coin_loader.dart';
import 'package:gamer_grove/presentation/widgets/loading/dither_skeleton.dart';
import 'package:gamer_grove/presentation/widgets/loading/live_loading_progress.dart';
import 'package:gamer_grove/presentation/widgets/loading/loading_step.dart';
import 'package:gamer_grove/presentation/widgets/loading/loading_thumbnail.dart';
import 'package:gamer_grove/presentation/widgets/loading/portal_loader.dart';

import '../support/load_app_fonts.dart';

/// Both loading devices, caught mid-animation.
///
/// The controllers loop forever, so `pumpAndSettle` would hang — the frames are
/// reached by pumping a fixed duration instead, which is also what makes the
/// goldens deterministic.
void main() {
  setUpAll(loadAppFonts);

  Future<void> pump(
    WidgetTester tester,
    ThemeData theme,
    Widget child, {
    Duration at = const Duration(milliseconds: 620),
    Size size = const Size(360, 260),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: theme,
        home: Scaffold(body: Center(child: child)),
      ),
    );
    await tester.pump(at);
  }

  testWidgets('portal loader — dark', (tester) async {
    await pump(tester, GGTheme.dark(), const PortalLoader(label: 'Lade Spiel'));
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/loading_portal_dark.png'),
    );
  });

  testWidgets('portal loader — light', (tester) async {
    await pump(
      tester,
      GGTheme.light(),
      const PortalLoader(label: 'Lade Spiel'),
    );
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/loading_portal_light.png'),
    );
  });

  testWidgets('rail skeleton keeps the shape of what is coming',
      (tester) async {
    await pump(
      tester,
      GGTheme.dark(),
      const DitherRailSkeleton(),
      size: const Size(360, 220),
    );
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/loading_rail_skeleton.png'),
    );
  });

  testWidgets('reduced motion still shows a lit portal, just still',
      (tester) async {
    tester.view.physicalSize = const Size(360, 260);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      const MediaQuery(
        data: MediaQueryData(disableAnimations: true),
        child: _StillApp(),
      ),
    );
    await tester.pump(const Duration(seconds: 2));

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/loading_portal_still.png'),
    );
  });

  testWidgets('step readout — dark', (tester) async {
    await pump(
      tester,
      GGTheme.dark(),
      const Padding(
        padding: EdgeInsets.all(16),
        child: LiveLoadingProgress(
          title: 'Spiel wird geladen',
          steps: [
            LoadingStep(
              text: 'Verbinde mit IGDB',
              substep: 'Sitzung wird geöffnet',
            ),
            LoadingStep(text: 'Lade Spieldaten'),
            LoadingStep(text: 'Bereite Ansicht vor'),
          ],
          stepDuration: Duration(milliseconds: 300),
        ),
      ),
      at: const Duration(milliseconds: 400),
      size: const Size(400, 320),
    );
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/loading_steps_dark.png'),
    );
  });

  /// The mascot, at four points of one turn-and-drop.
  ///
  /// A single frame would say nothing about a sprite whose whole idea is that
  /// its width follows the turn; the strip is what shows the coin is a disc and
  /// not a rectangle that changes size.
  testWidgets('the coin turns, falls, and the slot answers', (tester) async {
    await pump(
      tester,
      GGTheme.dark(),
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final at in const [0.0, 0.17, 0.62, 0.9])
            Padding(
              padding: const EdgeInsets.all(8),
              child: SizedBox.square(
                dimension: 64,
                child: CustomPaint(
                  painter: CoinPainter(
                    progress: at,
                    gold: const Color(0xFFF2A63C),
                    highlight: const Color(0xFFF7C67F),
                    plinth: const Color(0xFF44514E),
                    shadow: const Color(0xFF0B1614),
                  ),
                ),
              ),
            ),
        ],
      ),
      size: const Size(360, 120),
    );
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/loading_coin_frames.png'),
    );
  });

  /// The whole card, in both themes.
  ///
  /// This is the piece that has been rebuilt four times, so it is the piece
  /// worth pinning: coin on the left, what is being fetched on the right, the
  /// checklist below, and the whole thing sized to its content rather than
  /// stretched across the page.
  for (final (name, theme) in [
    ('dark', GGTheme.dark()),
    ('light', GGTheme.light()),
  ]) {
    testWidgets('the waiting card — $name', (tester) async {
      await pump(
        tester,
        theme,
        Padding(
          padding: const EdgeInsets.all(16),
          child: LiveLoadingProgress(
            title: 'The Witcher 3',
            artwork: const LoadingThumbnail(
              coverUrl: null,
              label: 'Cover of The Witcher 3',
            ),
            steps: const [
              LoadingStep(
                text: 'Opening The Witcher 3',
                substep: 'An RPG game',
              ),
              LoadingStep(text: 'Made by CD Projekt Red'),
              LoadingStep(text: 'Collecting what it is related to'),
            ],
            stepDuration: const Duration(milliseconds: 300),
          ),
        ),
        // Past the last step and past the growth that follows it: a frame
        // caught mid-`AnimatedSize` shows a clipped row and proves nothing.
        at: const Duration(milliseconds: 1200),
        size: const Size(400, 400),
      );
      // A second frame, so the progress bar is where the step counter says it
      // is: `pump` advances the clock once, which leaves implicit animations
      // started by the last step mid-flight.
      await tester.pump(const Duration(milliseconds: 400));
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/loading_card_$name.png'),
      );
    });
  }

  /// The coin at the size it is actually drawn, across a quarter turn.
  ///
  /// The frame strip above is at 64 px, where anything reads. This one is at
  /// the 44 dp the card uses, on the card's own surface, and it is the only
  /// thing that answers whether the slot still reads as a slot at that size —
  /// a sprite that works at twice the size and turns to mush at the real one is
  /// a sprite that does not work.
  testWidgets('the coin at the size it is actually used', (tester) async {
    tester.view.physicalSize = const Size(360, 90);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: GGTheme.dark(),
        home: Builder(
          builder: (context) {
            final scheme = Theme.of(context).colorScheme;
            return ColoredBox(
              color: scheme.surfaceContainer,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // A quarter turn is 1/(4 x turns) of the cycle. Sampled on
                  // that spacing the strip shows the disc turning; sampled on
                  // any multiple of a half turn it would show the same frame
                  // six times and prove nothing.
                  for (final at in const [0.0, 0.04, 0.08, 0.125, 0.62, 0.78])
                    SizedBox.square(
                      dimension: 44,
                      child: CustomPaint(
                        painter: CoinPainter(
                          progress: at,
                          gold: scheme.primary,
                          highlight:
                              Color.lerp(scheme.primary, Colors.white, 0.34)!,
                          plinth: scheme.outlineVariant,
                          shadow: scheme.surface,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
    await tester.pump();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/coin_at_size.png'),
    );
  });
}

class _StillApp extends StatelessWidget {
  const _StillApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: GGTheme.dark(),
      home: const Scaffold(
        body: Center(child: PortalLoader(label: 'Lade Spiel')),
      ),
    );
  }
}
