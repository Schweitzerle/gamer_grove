import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamer_grove/core/theme/brand_colors.dart';
import 'package:gamer_grove/core/theme/gg_color_schemes.dart';
import 'package:gamer_grove/core/theme/gg_contrast.dart';

/// Brand marks belong to other companies, so we keep their hue and only lift
/// their lightness. These tests are the reason that is safe to do.
void main() {
  group('legibleOn', () {
    test('leaves a colour alone when it already reads', () {
      const ground = Color(0xFF0B1614);
      const twitch = Color(0xFF9146FF);
      expect(twitch.legibleOn(ground), twitch);
    });

    test('lifts a near-black mark until it reads on the dark ground', () {
      // Apple's mark is black. On our surface that is 1.05:1 — invisible.
      const ground = Color(0xFF0B1614);
      const apple = Color(0xFF000000);

      expect(ground.contrastAgainst(apple), lessThan(1.2));
      final lifted = apple.legibleOn(ground, minimum: 4.5);
      expect(ground.contrastAgainst(lifted), greaterThanOrEqualTo(4.5));
    });

    test('darkens instead of lightening when the ground is light', () {
      const paper = Color(0xFFFAF7F0);
      const androidGreen = Color(0xFF3DDC84);

      final lifted = androidGreen.legibleOn(paper, minimum: 4.5);
      expect(paper.contrastAgainst(lifted), greaterThanOrEqualTo(4.5));
      expect(
        HSLColor.fromColor(lifted).lightness,
        lessThan(HSLColor.fromColor(androidGreen).lightness),
      );
    });

    test('keeps the hue, which is the whole point', () {
      // Falling back to plain white would make Apple, Epic and Oculus
      // indistinguishable — the brand cue would be gone.
      const ground = Color(0xFF0B1614);
      const playstation = Color(0xFF0070D1);

      final lifted = playstation.legibleOn(ground, minimum: 7);
      expect(
        HSLColor.fromColor(lifted).hue,
        closeTo(HSLColor.fromColor(playstation).hue, 1),
      );
    });

    test('falls back to the best available when the bar is unreachable', () {
      // On mid-grey, 7:1 cannot be met by anything: white scores 3.9 and black
      // 5.3. The helper must return the better extreme rather than loop
      // forever or hand back the invisible input.
      const midGround = Color(0xFF808080);
      const midMark = Color(0xFF808080);

      final result = midMark.legibleOn(midGround, minimum: 7);
      expect(result, Colors.black);
      expect(
        midGround.contrastAgainst(result),
        greaterThan(midGround.contrastAgainst(Colors.white)),
      );
    });
  });

  group('every brand mark reads in both themes', () {
    // The failure this guards against is silent: a mark that disappears looks
    // like a missing icon, not like a bug, and only on one of the two themes.
    for (final scheme in [GGColorSchemes.dark, GGColorSchemes.light]) {
      final name = scheme == GGColorSchemes.dark ? 'dark' : 'light';
      test(name, () {
        for (final brand in BrandColors.names) {
          final mark = BrandColors.of(brand)!;
          final shown = mark.legibleOn(scheme.surface, minimum: 4.5);
          expect(
            scheme.surface.contrastAgainst(shown),
            greaterThanOrEqualTo(4.5),
            reason: '$brand is unreadable on the $name surface',
          );
        }
      });
    }
  });

  test('an unknown service lends no colour', () {
    expect(BrandColors.of('some-store-that-does-not-exist'), isNull);
    expect(BrandColors.of(null), isNull);
  });

  test('lookup ignores case, because IGDB type strings are inconsistent', () {
    expect(BrandColors.of('Steam'), BrandColors.of('steam'));
  });
}
