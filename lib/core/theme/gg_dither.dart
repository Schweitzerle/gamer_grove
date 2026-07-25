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

  /// Punches the dither grid out of whatever was drawn into the current layer.
  ///
  /// Must be used inside a `saveLayer`, otherwise `dstIn` would eat the rest of
  /// the canvas along with it.
  static Paint maskPaint() => Paint()
    ..blendMode = BlendMode.dstIn
    ..shader = ImageShader(
      tile,
      TileMode.repeated,
      TileMode.repeated,
      Matrix4.identity().storage,
      filterQuality: FilterQuality.none,
    );

  /// Fills [rect] with [gradient], seen through the dither grid.
  static void paintGradient(Canvas canvas, Rect rect, Gradient gradient) {
    canvas
      ..saveLayer(rect, Paint())
      ..drawRect(rect, Paint()..shader = gradient.createShader(rect))
      ..drawRect(rect, maskPaint())
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
