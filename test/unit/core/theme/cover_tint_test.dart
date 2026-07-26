import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamer_grove/core/theme/cover_tint.dart';

/// Builds raw RGBA for a fake cover made of the given colours in equal parts.
Uint8List pixels(List<Color> colours, {int each = 32}) {
  final bytes = BytesBuilder();
  for (final c in colours) {
    for (var i = 0; i < each; i++) {
      bytes
        ..addByte((c.r * 255).round())
        ..addByte((c.g * 255).round())
        ..addByte((c.b * 255).round())
        ..addByte(255);
    }
  }
  return bytes.toBytes();
}

double hueOf(Color c) => HSVColor.fromColor(c).hue;

void main() {
  setUp(CoverTint.clearCache);

  test('takes the hue from the cover but not its intensity', () {
    // A screaming neon cover must not produce a screaming chamber: the whole
    // point is that the interface stays behind the artwork.
    final tint = CoverTint.tintFromPixels(pixels([const Color(0xFF00FF66)]))!;
    final hsv = HSVColor.fromColor(tint);

    expect(hueOf(tint), closeTo(144, 6), reason: 'hue comes from the cover');
    expect(hsv.saturation, lessThan(0.5), reason: 'ours, and capped');
    expect(hsv.value, lessThan(0.6));
  });

  test('averages hue around the circle rather than through it', () {
    // 350° and 10° are neighbours on the wheel. A plain mean returns 180° —
    // the opposite colour — which is the classic way to get this wrong.
    final tint = CoverTint.tintFromPixels(
      pixels([const Color(0xFFFF0033), const Color(0xFFFF3300)]),
    )!;
    final hue = hueOf(tint);
    expect(
      hue < 30 || hue > 330,
      isTrue,
      reason: 'expected a red, got ${hue.toStringAsFixed(0)}°',
    );
  });

  test('a greyscale cover lends no hue', () {
    expect(
      CoverTint.tintFromPixels(
        pixels([
          const Color(0xFF202020),
          const Color(0xFF808080),
          const Color(0xFFE0E0E0),
        ]),
      ),
      isNull,
      reason: 'callers keep the brand accent instead of inventing a colour',
    );
  });

  test('near-black and near-white are ignored, not averaged in', () {
    // A cover that is mostly black with a small blue mark should read blue.
    // Counting the black would drag every cover towards the same muddy tone.
    final buffer = BytesBuilder()
      ..add(pixels([const Color(0xFF000000)], each: 200))
      ..add(pixels([const Color(0xFF2266FF)], each: 40));
    final tint = CoverTint.tintFromPixels(buffer.toBytes())!;
    expect(hueOf(tint), closeTo(220, 20));
  });

  test('fully transparent pixels do not count', () {
    final opaque = pixels([const Color(0xFF2266FF)]);
    final withGhosts = BytesBuilder()
      ..add(opaque)
      ..add(Uint8List.fromList(List.filled(400, 0)));

    expect(
      hueOf(CoverTint.tintFromPixels(withGhosts.toBytes())!),
      closeTo(hueOf(CoverTint.tintFromPixels(opaque)!), 1),
    );
  });

  test('an empty or tiny buffer is handled rather than thrown at', () {
    expect(CoverTint.tintFromPixels(Uint8List(0)), isNull);
    expect(CoverTint.tintFromPixels(Uint8List(3)), isNull);
  });

  test('a missing cover resolves to nothing without touching the network',
      () async {
    expect(await CoverTint.resolve(null), isNull);
    expect(await CoverTint.resolve(''), isNull);
    expect(CoverTint.cacheSize, 0);
  });
}
