import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// Derives a chamber's light from the covers standing in it.
///
/// Written by hand rather than pulled from a palette package for two reasons.
/// The dependency already in the pubspec (`palette_generator_master`) was never
/// imported and is a third-party fork wearing a name that reads official — it
/// is removed alongside this. And a palette extractor returns the cover's most
/// prominent colours, which is the wrong answer here: a neon cover would then
/// out-shout the artwork the interface is supposed to stay behind.
///
/// So only the **hue** comes from the cover. Saturation and lightness are ours
/// and fixed, which caps how loud any single cover can get.
abstract final class CoverTint {
  /// Decode size. 16x16 is 256 pixels — enough for a stable hue, small enough
  /// that the maths is free.
  static const _sample = 16;

  /// Fixed saturation and value for the result, so the light is always a
  /// whisper of the cover rather than a copy of it.
  static const _saturation = 0.38;
  static const _value = 0.52;

  static final _cache = <String, Color?>{};
  static final _inFlight = <String, Future<Color?>>{};

  /// The tint for [url], or null when the cover has no usable hue (greyscale
  /// artwork) — callers then keep the brand accent.
  static Future<Color?> resolve(String? url) {
    if (url == null || url.isEmpty) return Future.value();
    if (_cache.containsKey(url)) return Future.value(_cache[url]);
    // Several covers in one row start at once; without this each would fetch
    // and decode the same bytes.
    final pending = _inFlight[url];
    if (pending != null) return pending;
    final future = _resolve(url);
    _inFlight[url] = future;
    return future.whenComplete(() => _inFlight.remove(url));
  }

  static Future<Color?> _resolve(String url) async {
    try {
      final file = await DefaultCacheManager().getSingleFile(url);
      final bytes = await file.readAsBytes();
      final codec = await ui.instantiateImageCodec(
        bytes,
        targetWidth: _sample,
        targetHeight: _sample,
      );
      final frame = await codec.getNextFrame();
      final data = await frame.image.toByteData();
      frame.image.dispose();
      codec.dispose();
      if (data == null) return _cache[url] = null;
      return _cache[url] = tintFromPixels(data.buffer.asUint8List());
    } on Exception {
      // A cover that will not load is not worth a broken screen; the section
      // simply keeps the brand accent.
      return _cache[url] = null;
    }
  }

  /// The pure half, so the interesting part is testable without a network or a
  /// decoder.
  ///
  /// Takes raw RGBA and returns a colour built from the artwork's dominant hue
  /// at our own fixed saturation and lightness, or null when there is no hue
  /// worth using.
  @visibleForTesting
  static Color? tintFromPixels(Uint8List rgba) {
    var x = 0.0;
    var y = 0.0;
    var weight = 0.0;

    for (var i = 0; i + 3 < rgba.length; i += 4) {
      if (rgba[i + 3] < 128) continue;
      final hsv = HSVColor.fromColor(
        Color.fromARGB(255, rgba[i], rgba[i + 1], rgba[i + 2]),
      );

      // Skip what carries no usable hue: near-black, near-white and greys.
      // Averaging those in is what turns every cover into the same brown.
      if (hsv.value < 0.15 || hsv.saturation < 0.18) continue;
      if (hsv.value > 0.95 && hsv.saturation < 0.25) continue;

      // Hue is circular, so it is averaged as a vector — a plain mean of 350°
      // and 10° gives 180°, the opposite colour.
      final w = hsv.saturation * hsv.value;
      final radians = hsv.hue * math.pi / 180;
      x += math.cos(radians) * w;
      y += math.sin(radians) * w;
      weight += w;
    }

    // A greyscale or near-greyscale cover has no hue to lend.
    if (weight < 1.5 || (x * x + y * y) < 0.04) return null;

    var hue = math.atan2(y, x) * 180 / math.pi;
    if (hue < 0) hue += 360;
    return HSVColor.fromAHSV(1, hue, _saturation, _value).toColor();
  }

  @visibleForTesting
  static void clearCache() {
    _cache.clear();
    _inFlight.clear();
  }

  @visibleForTesting
  static int get cacheSize => _cache.length;
}
