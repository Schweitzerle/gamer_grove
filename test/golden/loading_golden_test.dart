import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamer_grove/core/theme/gg_theme.dart';
import 'package:gamer_grove/presentation/widgets/loading/dither_skeleton.dart';
import 'package:gamer_grove/presentation/widgets/loading/live_loading_progress.dart';
import 'package:gamer_grove/presentation/widgets/loading/loading_step.dart';
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
