import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamer_grove/core/theme/gg_chamber_light.dart';
import 'package:gamer_grove/core/theme/gg_theme.dart';
import 'package:gamer_grove/presentation/widgets/sections/lit_section.dart';

import '../support/load_app_fonts.dart';

/// The four light modes side by side.
///
/// This is the gate for the claim the whole system rests on: that the sections
/// tell themselves apart by how they are lit. If two modes ever become
/// indistinguishable, that shows up here as an image diff rather than as a
/// vague feeling on a device.
void main() {
  setUpAll(loadAppFonts);

  const covers = [
    Color(0xFF2E4756),
    Color(0xFF3C3357),
    Color(0xFF4A4136),
    Color(0xFF3A4A3C),
    Color(0xFF553A3A),
  ];

  Widget rail(ChamberLightMode mode) => SizedBox(
        height: 96,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: covers.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, i) {
            // The falloff is what carries a chamber's meaning into the row:
            // the best-rated entry leads, a recently rated row cools off.
            final light = chamberFalloff(mode, i, covers.length);
            return Opacity(
              opacity: 0.45 + 0.55 * light,
              child: Container(
                width: 68,
                decoration: BoxDecoration(
                  color: covers[i],
                  borderRadius: BorderRadius.circular(9),
                ),
              ),
            );
          },
        ),
      );

  Future<void> pump(WidgetTester tester, ThemeData theme) async {
    tester.view.physicalSize = const Size(380, 720);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: theme,
        home: Scaffold(
          body: ListView(
            children: const [
              LitSection(
                title: 'Top Rated',
                lightMode: ChamberLightMode.brightest,
                tint: Color(0xFF4E86A8),
                child: SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('the four modes stay visibly different from one another',
      (tester) async {
    tester.view.physicalSize = const Size(380, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: GGTheme.dark(),
        home: Scaffold(
          body: ListView(
            children: [
              LitSection(
                title: 'Top Rated',
                lightMode: ChamberLightMode.brightest,
                tint: const Color(0xFF4E86A8),
                child: rail(ChamberLightMode.brightest),
              ),
              LitSection(
                title: 'Popular',
                lightMode: ChamberLightMode.breathing,
                tint: const Color(0xFFB4633C),
                child: rail(ChamberLightMode.breathing),
              ),
              LitSection(
                title: 'Wishlist',
                lightMode: ChamberLightMode.cold,
                tint: const Color(0xFF3E5A6E),
                child: rail(ChamberLightMode.cold),
              ),
              LitSection(
                title: 'Recently Rated',
                lightMode: ChamberLightMode.afterglow,
                tint: const Color(0xFFC08A3E),
                child: rail(ChamberLightMode.afterglow),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/chamber_light_modes.png'),
    );
  });

  testWidgets('one chamber in the light theme', (tester) async {
    await pump(tester, GGTheme.light());
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/chamber_light_light_theme.png'),
    );
  });
}
