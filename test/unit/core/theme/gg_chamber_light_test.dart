import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamer_grove/core/theme/gg_chamber_light.dart';
import 'package:gamer_grove/core/theme/gg_dither.dart';

/// The light is drawn from a baked image rather than a masked gradient, because
/// masking needs a `saveLayer` per section per frame. That trade only pays off
/// if the cache actually hits and stays bounded — which is what these check.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget lit(Size size, Color tint) => MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: size.width,
              height: size.height,
              child: ChamberLight(tint: tint, intensity: 1),
            ),
          ),
        ),
      );

  setUp(DitheredWashCache.clear);

  testWidgets('the same section painted twice reuses one baked wash',
      (tester) async {
    await tester.pumpWidget(lit(const Size(320, 180), const Color(0xFF4E86A8)));
    await tester.pump();
    expect(DitheredWashCache.entryCount, 1);

    await tester.pumpWidget(lit(const Size(320, 180), const Color(0xFF4E86A8)));
    await tester.pump();
    expect(
      DitheredWashCache.entryCount,
      1,
      reason: 'a repaint must not bake a second image',
    );
  });

  testWidgets('a different size gets its own wash', (tester) async {
    // Sizes used to be rounded into 32px buckets to save bakes. That forced the
    // image to be stretched or cropped into place, and a stretched dither has
    // the wrong pitch — it stops interlocking with the grain beside it and the
    // join between two lit surfaces reappears as a band. Exact bakes cost
    // nothing in practice: a section's width does not wander.
    await tester.pumpWidget(lit(const Size(300, 170), const Color(0xFF4E86A8)));
    await tester.pump();
    await tester.pumpWidget(lit(const Size(318, 178), const Color(0xFF4E86A8)));
    await tester.pump();

    expect(DitheredWashCache.entryCount, 2);
  });

  testWidgets('a different tint gets its own wash', (tester) async {
    await tester.pumpWidget(lit(const Size(320, 180), const Color(0xFF4E86A8)));
    await tester.pump();
    await tester.pumpWidget(lit(const Size(320, 180), const Color(0xFFB4633C)));
    await tester.pump();

    expect(DitheredWashCache.entryCount, 2);
  });

  testWidgets('the cache stays bounded over a long scroll', (tester) async {
    for (var i = 0; i < 30; i++) {
      await tester.pumpWidget(
        lit(Size(320 + i * 64.0, 180), Color(0xFF000000 + i * 0x010203)),
      );
      await tester.pump();
    }

    // Unbounded caching of full-width images is a leak waiting for a long
    // session, so the cache evicts rather than grows.
    expect(
      DitheredWashCache.entryCount,
      lessThanOrEqualTo(DitheredWashCache.maxEntries),
    );
  });

  group("falloff carries the chamber's meaning", () {
    test('a ranked row leads with its best entry and falls away', () {
      final first = chamberFalloff(ChamberLightMode.brightest, 0, 5);
      final last = chamberFalloff(ChamberLightMode.brightest, 4, 5);
      expect(first, 1);
      expect(last, lessThan(first));
    });

    test('a cold row stays evenly unlit', () {
      expect(
        chamberFalloff(ChamberLightMode.cold, 0, 5),
        chamberFalloff(ChamberLightMode.cold, 4, 5),
      );
    });

    test('steady and breathing rows do not fade along their length', () {
      const modes = [ChamberLightMode.steady, ChamberLightMode.breathing];
      for (final mode in modes) {
        expect(chamberFalloff(mode, 0, 5), 1);
        expect(chamberFalloff(mode, 4, 5), 1);
      }
    });

    test('a single entry is always fully lit', () {
      expect(chamberFalloff(ChamberLightMode.brightest, 0, 1), 1);
    });
  });
}
