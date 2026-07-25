import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';

/// Guards the generated launcher artwork.
///
/// Golden tests do not apply here — these are native launcher resources, not
/// widgets, and nothing in the Flutter tree ever renders them. What can go
/// wrong instead is geometric: Android crops adaptive layers with a mask that
/// only guarantees the inner 66%, and masks range from squircles to full
/// circles. The previous icon shipped broken for exactly that reason, so these
/// tests decode the artwork and check the mark survives a circular mask.
void main() {
  const safeFraction = 72 / 108;

  Future<ui.Image> decode(String path) async {
    final file = File(path);
    expect(file.existsSync(), isTrue, reason: 'missing generated asset: $path');
    final codec = await ui.instantiateImageCodec(await file.readAsBytes());
    return (await codec.getNextFrame()).image;
  }

  /// Bounding box of everything that is not fully transparent.
  Future<ui.Rect> inkBounds(ui.Image image) async {
    final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    final pixels = data!.buffer.asUint8List();
    var minX = image.width, minY = image.height, maxX = -1, maxY = -1;
    for (var y = 0; y < image.height; y++) {
      for (var x = 0; x < image.width; x++) {
        if (pixels[(y * image.width + x) * 4 + 3] == 0) continue;
        if (x < minX) minX = x;
        if (y < minY) minY = y;
        if (x > maxX) maxX = x;
        if (y > maxY) maxY = y;
      }
    }
    expect(maxX, greaterThanOrEqualTo(0), reason: 'layer is fully transparent');
    return ui.Rect.fromLTRB(
      minX.toDouble(),
      minY.toDouble(),
      (maxX + 1).toDouble(),
      (maxY + 1).toDouble(),
    );
  }

  group('source layers', () {
    test('every layer is generated at the size its target expects', () async {
      const expected = <String, int>{
        'assets/icon/app_icon.png': 1024,
        'assets/icon/app_icon_background.png': 1024,
        'assets/icon/app_icon_foreground.png': 1024,
        'assets/icon/app_icon_monochrome.png': 1024,
        'assets/splash/splash_logo.png': 1024,
        // Android 12+ splashes are authored on a 1152px canvas.
        'assets/splash/splash_logo_android12.png': 1152,
      };

      for (final entry in expected.entries) {
        final image = await decode(entry.key);
        expect(
          image.width,
          entry.value,
          reason: '${entry.key} should be ${entry.value}px wide',
        );
        expect(image.height, image.width,
            reason: '${entry.key} must be square');
      }
    });

    test('adaptive foreground stays inside the circular safe zone', () async {
      final image = await decode('assets/icon/app_icon_foreground.png');
      final bounds = await inkBounds(image);
      final size = image.width.toDouble();

      // A circular mask keeps a centred circle of 66% of the layer, so the
      // mark's diagonal — not merely its width — has to fit inside it.
      final diagonal = ui.Offset(bounds.width, bounds.height).distance;
      expect(
        diagonal,
        lessThanOrEqualTo(size * safeFraction),
        reason: 'mark would be clipped by a circular launcher mask',
      );

      // ...and it has to be centred, or the mask crops one side first.
      expect((bounds.center.dx - size / 2).abs(), lessThan(size * 0.02));
      expect((bounds.center.dy - size / 2).abs(), lessThan(size * 0.02));
    });

    test('monochrome layer is a single-colour silhouette', () async {
      final image = await decode('assets/icon/app_icon_monochrome.png');
      final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      final pixels = data!.buffer.asUint8List();

      // Android tints this layer wholesale, so any hue in it is a mistake.
      // Edge pixels are anti-aliased and come back premultiplied, so the test
      // is that no pixel carries colour — the channels have to stay equal —
      // and that solid pixels are white rather than some grey.
      var solid = 0;
      for (var i = 0; i < pixels.length; i += 4) {
        final alpha = pixels[i + 3];
        if (alpha == 0) continue;
        expect(
          <int>[pixels[i + 1], pixels[i + 2]],
          <int>[pixels[i], pixels[i]],
          reason: 'monochrome layer must be colourless',
        );
        if (alpha == 255) {
          solid++;
          expect(pixels[i], 255, reason: 'solid pixels must be white');
        }
      }
      expect(solid, greaterThan(0), reason: 'monochrome layer is empty');
    });
  });

  group('generated Android resources', () {
    const res = 'android/app/src/main/res';

    test('adaptive icon declares all three layers without extra inset', () {
      final xml =
          File('$res/mipmap-anydpi-v26/ic_launcher.xml').readAsStringSync();

      expect(xml, contains('ic_launcher_background'));
      expect(xml, contains('ic_launcher_foreground'));
      expect(
        xml,
        contains('ic_launcher_monochrome'),
        reason: 'without this, Android 13 themed icons fall back to a guess',
      );
      expect(
        xml,
        isNot(contains(RegExp(r'android:inset="(?!0%)'))),
        reason: 'the vector already applies the safe zone; a second inset '
            'only shrinks the mark',
      );
    });

    test('splash uses the cave colour on both light and dark', () {
      for (final path in <String>[
        '$res/values-v31/styles.xml',
        '$res/values-night-v31/styles.xml',
      ]) {
        final xml = File(path).readAsStringSync();
        expect(xml, contains('#0B1614'),
            reason: '$path lost the splash colour');
        expect(xml, contains('android12splash'));
      }
    });
  });
}
