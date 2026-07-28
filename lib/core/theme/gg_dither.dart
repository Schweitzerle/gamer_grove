import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// The app's grain: ordered dithering, the same technique the icon is drawn
/// with.
///
/// Every soft light in GamerGrove is stepped through this grid instead of being
/// smoothly blended — loading states, empty states, the spotlight on the Top 3.
/// It is what keeps those surfaces recognisably this app rather than the
/// interchangeable grey shimmer every catalogue ships.
///
/// The pattern is painted as a repeating 4x4 shader tile, so a full-screen wash
/// costs one draw call rather than thousands of little rectangles.
abstract final class GGDither {
  /// Side of one checker square, in logical pixels.
  static const cell = 2.0;

  static ui.Image? _tile;

  /// A 4x4 tile holding two opaque 2x2 squares on transparent — the classic
  /// 50% dither.
  static ui.Image get tile => _tile ??= _buildTile();

  static ui.Image _buildTile() {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()..color = const Color(0xFFFFFFFF);
    canvas
      ..drawRect(const Rect.fromLTWH(0, 0, cell, cell), paint)
      ..drawRect(const Rect.fromLTWH(cell, cell, cell, cell), paint);
    return recorder
        .endRecording()
        .toImageSync((cell * 2).round(), (cell * 2).round());
  }

  /// One period of the grid: two cells across, two down.
  static const period = cell * 2;

  /// Punches the dither grid out of whatever was drawn into the current layer.
  ///
  /// Must be used inside a `saveLayer`, otherwise `dstIn` would eat the rest of
  /// the canvas along with it.
  ///
  /// [phase] shifts the grid. Two surfaces that meet — artwork above, page
  /// below — have to be squares of one continuous checkerboard, not two grids
  /// that happen to have the same pitch. Half a period out and the light and
  /// dark squares sit under each other instead of interlocking, and the join
  /// shows as a band.
  static Paint maskPaint({Offset phase = Offset.zero}) => Paint()
    ..blendMode = BlendMode.dstIn
    ..shader = ImageShader(
      tile,
      TileMode.repeated,
      TileMode.repeated,
      Matrix4.translationValues(phase.dx, phase.dy, 0).storage,
      filterQuality: FilterQuality.none,
    );

  /// Fills [rect] with [gradient], seen through the dither grid.
  static void paintGradient(
    Canvas canvas,
    Rect rect,
    Gradient gradient, {
    Offset phase = Offset.zero,
  }) {
    canvas
      ..saveLayer(rect, Paint())
      ..drawRect(rect, Paint()..shader = gradient.createShader(rect))
      ..drawRect(rect, maskPaint(phase: phase))
      ..restore();
  }

  /// Fills [path] with [gradient], seen through the dither grid.
  static void paintPath(Canvas canvas, Path path, Gradient gradient) {
    final bounds = path.getBounds();
    if (bounds.isEmpty) return;
    canvas
      ..saveLayer(bounds, Paint())
      ..drawPath(path, Paint()..shader = gradient.createShader(bounds))
      ..drawRect(bounds, maskPaint())
      ..restore();
  }
}

/// Rasterised dithered washes, keyed by what they were baked for.
///
/// **Why the app's big lights are images rather than painters.** The obvious
/// implementation — a gradient masked by the dither grid — needs a `saveLayer`
/// per light per frame, because masking is a compositing operation. During a
/// scroll that is one offscreen buffer per light per frame, which is exactly
/// the kind of thing that costs frames on mid-range Android. A wash only
/// changes when its tint or its size changes, so it is rasterised once and then
/// drawn as a single textured quad. Scrolling costs one image draw per light.
///
/// Bounded on purpose: a handful of lights at a handful of widths is all the
/// app ever needs, and an unbounded cache of full-width images is a memory leak
/// waiting for a long scroll session.
abstract final class DitheredWashCache {
  /// How many baked washes are kept before the oldest is dropped.
  static const maxEntries = 12;

  static final _entries = <String, ui.Image>{};
  static final _order = <String>[];

  /// The wash of [kind] baked for [size] in [tint].
  ///
  /// [gradient] is only called on a miss, and describes the light for exactly
  /// the rect the image is baked at.
  ///
  /// Baked at the size asked for, not rounded to a grid. Rounding up meant the
  /// image had to be either stretched into place — which changes the dither's
  /// pitch and stops it interlocking with any grain beside it — or cropped,
  /// which moves the gradient's centre by up to the rounding. Neither is worth
  /// the bakes it saves: a section's width does not wander, so the cache hits
  /// just as often on exact sizes.
  static ui.Image forSize(
    String kind,
    Size size,
    Color tint,
    Gradient Function() gradient,
  ) {
    final w = size.width.round();
    final h = size.height.round();
    final key = '$kind/${w}x$h/${tint.toARGB32()}';

    final cached = _entries[key];
    if (cached != null) return cached;

    final image = _bake(Size(w.toDouble(), h.toDouble()), gradient());
    _entries[key] = image;
    _order.add(key);
    if (_order.length > maxEntries) {
      final evicted = _order.removeAt(0);
      _entries.remove(evicted)?.dispose();
    }
    return image;
  }

  static ui.Image _bake(Size size, Gradient gradient) {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    GGDither.paintGradient(canvas, Offset.zero & size, gradient);
    return recorder
        .endRecording()
        .toImageSync(size.width.round(), size.height.round());
  }

  /// Draws [image] across [rect] with its own alpha scaled by [alpha].
  ///
  /// Taken one pixel to one pixel, never stretched: the bake is the size it is
  /// drawn at, and scaling would change the dither's pitch — enough that the
  /// page's checkerboard would stop interlocking with the artwork's above it
  /// and the join would reappear as a band.
  static void draw(Canvas canvas, ui.Image image, Rect rect, double alpha) {
    final src = Rect.fromLTWH(
      0,
      0,
      rect.width.clamp(0, image.width.toDouble()),
      rect.height.clamp(0, image.height.toDouble()),
    );
    canvas.drawImageRect(
      image,
      src,
      Rect.fromLTWH(rect.left, rect.top, src.width, src.height),
      // Alpha on the paint modulates the image; the colour itself is ignored.
      Paint()..color = Color.fromRGBO(0, 0, 0, alpha),
    );
  }

  @visibleForTesting
  static void clear() {
    for (final image in _entries.values) {
      image.dispose();
    }
    _entries.clear();
    _order.clear();
  }

  @visibleForTesting
  static int get entryCount => _entries.length;
}

/// A shaft of light aimed at whatever is currently in front.
///
/// Narrow at the top, widening downward, fading out — and stepped through the
/// dither grid, so it reads as the same material as the icon rather than as a
/// generic glow. [intensity] carries the arrival flare: bright as a card steps
/// forward, then settling to a lower constant.
class SpotlightPainter extends CustomPainter {
  const SpotlightPainter({
    required this.colour,
    required this.intensity,
    this.spread = 0.66,
  });

  final Color colour;
  final double intensity;

  /// Half-width of the beam at the bottom, as a fraction of the width.
  final double spread;

  @override
  void paint(Canvas canvas, Size size) {
    if (intensity <= 0) return;
    final centre = size.width / 2;
    final top = size.width * 0.05;
    final path = Path()
      ..moveTo(centre - top, 0)
      ..lineTo(centre + top, 0)
      ..lineTo(centre + size.width * spread, size.height)
      ..lineTo(centre - size.width * spread, size.height)
      ..close();

    GGDither.paintPath(
      canvas,
      path,
      LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          // Kept low on purpose: a bright wedge reads as a solid shape, a
          // faint one reads as light.
          colour.withValues(alpha: 0.22 * intensity),
          colour.withValues(alpha: 0.07 * intensity),
          colour.withValues(alpha: 0),
        ],
        stops: const [0, 0.45, 1],
      ),
    );
  }

  @override
  bool shouldRepaint(SpotlightPainter oldDelegate) =>
      oldDelegate.intensity != intensity ||
      oldDelegate.colour != colour ||
      oldDelegate.spread != spread;
}

/// A band of light travelling across a cover as it arrives in front.
///
/// [progress] runs 0 → 1 across one pass; outside that range nothing is drawn.
class LightSweepPainter extends CustomPainter {
  const LightSweepPainter({
    required this.colour,
    required this.progress,
    this.band = 0.42,
    this.strength = 0.75,
  });

  final Color colour;
  final double progress;

  /// Half-width of the band, as a fraction of the painted width. A wide band on
  /// a small placeholder stops reading as a sweep and starts reading as
  /// texture.
  final double band;

  /// Peak opacity at the centre of the band.
  final double strength;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || progress >= 1) return;
    // Travels from just off one edge to just off the other.
    final centre = size.width * (progress * 2.2 - 0.6);
    final half = size.width * band;
    final rect = Rect.fromLTWH(centre - half, 0, half * 2, size.height);
    if (!rect.overlaps(Offset.zero & size)) return;

    // Fades in and out so neither end of the pass pops.
    final fade = (progress < 0.2)
        ? progress / 0.2
        : (progress > 0.7)
            ? (1 - progress) / 0.3
            : 1.0;

    GGDither.paintGradient(
      canvas,
      rect,
      LinearGradient(
        colors: [
          colour.withValues(alpha: 0),
          colour.withValues(alpha: strength * fade.clamp(0, 1)),
          colour.withValues(alpha: 0),
        ],
      ),
    );
  }

  @override
  bool shouldRepaint(LightSweepPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.colour != colour ||
      oldDelegate.band != band ||
      oldDelegate.strength != strength;
}
