import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamer_grove/core/theme/gg_chamber_light.dart';
import 'package:gamer_grove/core/theme/gg_color_schemes.dart';
import 'package:gamer_grove/core/theme/gg_contrast.dart';
import 'package:gamer_grove/core/theme/gg_detail_light.dart';
import 'package:gamer_grove/core/theme/gg_dither.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// Every tint `CoverTint` is able to produce. Saturation and value are fixed
  /// there on purpose, so the whole space of possible lights is one circle of
  /// hues and can be checked exhaustively rather than sampled.
  final everyTint = [
    for (var hue = 0.0; hue < 360; hue += 2)
      HSVColor.fromAHSV(1, hue, 0.38, 0.52).toColor(),
  ];

  group('the light never costs the page its legibility', () {
    // This is the constraint that set `peak`, so it is also the thing that must
    // fail loudly if anyone raises it. A wash bright enough to look good in a
    // screenshot puts secondary text under 4.5:1 on a yellow cover — and only
    // on a yellow cover, which is exactly the kind of bug nobody reproduces.
    final schemes = {
      'dark': GGColorSchemes.dark,
      'light': GGColorSchemes.light,
    };

    for (final entry in schemes.entries) {
      final scheme = entry.value;
      final foregrounds = {
        'onSurfaceVariant': scheme.onSurfaceVariant,
        'onSurface': scheme.onSurface,
        'primary': scheme.primary,
      };

      for (final fg in foregrounds.entries) {
        test('${fg.key} still reads on ${entry.key} under any cover', () {
          for (final tint in everyTint) {
            final lit = litSurface(scheme.surface, tint);
            expect(
              lit.contrastAgainst(fg.value),
              greaterThanOrEqualTo(4.5),
              reason: '${fg.key} fails on ${entry.key} '
                  'under tint ${tint.toARGB32().toRadixString(16)}',
            );
          }
        });
      }
    }

    test('peak sits below the measured ceiling with room to spare', () {
      // The binding case is the gold accent on paper, which gives out at 0.17.
      expect(DetailLight.peak, lessThan(0.17));
    });
  });

  group('the wash is baked once', () {
    setUp(DitheredWashCache.clear);

    Widget lit(Size size, Color tint) => MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: size.width,
                height: size.height,
                child: DetailLight(tint: tint),
              ),
            ),
          ),
        );

    testWidgets('a repaint reuses the image', (tester) async {
      await tester.pumpWidget(
        lit(const Size(360, DetailLight.reach), const Color(0xFF6B5285)),
      );
      await tester.pump();
      expect(DitheredWashCache.entryCount, 1);

      await tester.pumpWidget(
        lit(const Size(360, DetailLight.reach), const Color(0xFF6B5285)),
      );
      await tester.pump();
      expect(DitheredWashCache.entryCount, 1);
    });

    testWidgets('it does not collide with a chamber wash of the same size',
        (tester) async {
      // Both lights share one cache; keying them apart is what stops a detail
      // page from being painted with a chamber's much brighter gradient.
      await tester.pumpWidget(
        lit(const Size(320, 180), const Color(0xFF4E86A8)),
      );
      await tester.pump();

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 320,
                height: 180,
                child: ChamberLight(tint: Color(0xFF4E86A8), intensity: 1),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(DitheredWashCache.entryCount, 2);
    });
  });
}
