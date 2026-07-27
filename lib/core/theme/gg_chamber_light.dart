import 'package:flutter/material.dart';
import 'package:gamer_grove/core/theme/gg_dither.dart';

/// How a section of the Grove is lit.
///
/// The light is not decoration: each mode says something true about the
/// section, which is what makes the sections tell themselves apart without
/// giving each one its own colour scheme.
enum ChamberLightMode {
  /// Steady — the default for a section with nothing particular to say.
  steady,

  /// The section's own ranking is the brightness: the best-rated entry throws
  /// the most light and the rest fall away.
  brightest,

  /// Slowly breathing: a lot of people are in here right now.
  breathing,

  /// Unlit and desaturated. These are games not played yet — they wait in the
  /// dark rather than glowing like something owned.
  cold,

  /// Warm and fading towards the end of the row: recently rated glows, older
  /// entries cool off.
  afterglow,
}

/// Draws a chamber's light: a dithered wash rising from behind the content.
///
/// Baked once and redrawn as an image rather than masked every frame — see
/// [DitheredWashCache] for why.
class ChamberLight extends StatelessWidget {
  const ChamberLight({
    required this.tint,
    required this.intensity,
    this.mode = ChamberLightMode.steady,
    super.key,
  });

  /// The colour of the light. Later derived from the covers in the section;
  /// for now a fixed tone per section type.
  final Color tint;

  /// 0 → dark, 1 → fully lit. Driven by scroll position.
  final double intensity;

  final ChamberLightMode mode;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(
          painter: _ChamberLightPainter(
            tint: tint,
            intensity: intensity,
            mode: mode,
          ),
        ),
      ),
    );
  }
}

class _ChamberLightPainter extends CustomPainter {
  const _ChamberLightPainter({
    required this.tint,
    required this.intensity,
    required this.mode,
  });

  final Color tint;
  final double intensity;
  final ChamberLightMode mode;

  /// Cold chambers stay dim however close they are to the middle of the
  /// screen: that is the point of them.
  double get _ceiling => mode == ChamberLightMode.cold ? 0.35 : 1.0;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty || intensity <= 0) return;
    final alpha = (intensity * _ceiling).clamp(0.0, 1.0);
    if (alpha <= 0.01) return;

    final image = DitheredWashCache.forSize(
      'chamber',
      size,
      tint,
      () => RadialGradient(
        // Centred low but not at the very edge: anchored at the bottom the
        // whole wash lands on the seam instead of behind the row it is meant
        // to light.
        center: const Alignment(0, 0.7),
        radius: 1.25,
        colors: [
          tint.withValues(alpha: 0.9),
          tint.withValues(alpha: 0.34),
          tint.withValues(alpha: 0),
        ],
        stops: const [0, 0.5, 1],
      ),
    );
    DitheredWashCache.draw(canvas, image, Offset.zero & size, alpha);
  }

  @override
  bool shouldRepaint(_ChamberLightPainter oldDelegate) =>
      oldDelegate.intensity != intensity ||
      oldDelegate.tint != tint ||
      oldDelegate.mode != mode;
}

/// The seam between two chambers: grain rather than a line, so one light fades
/// into the next instead of meeting at an edge.
class ChamberSeam extends StatelessWidget {
  const ChamberSeam({required this.tint, this.height = 28, super.key});

  final Color tint;
  final double height;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: SizedBox(
          height: height,
          width: double.infinity,
          child: CustomPaint(painter: _SeamPainter(tint)),
        ),
      ),
    );
  }
}

class _SeamPainter extends CustomPainter {
  const _SeamPainter(this.tint);

  final Color tint;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    GGDither.paintGradient(
      canvas,
      Offset.zero & size,
      LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [tint.withValues(alpha: 0.22), tint.withValues(alpha: 0)],
      ),
    );
  }

  @override
  bool shouldRepaint(_SeamPainter oldDelegate) => oldDelegate.tint != tint;
}

/// Per-entry falloff inside a lit chamber.
///
/// Returns how brightly the entry at [index] should read, so a row can carry
/// the chamber's meaning — the top-rated entry leading, or a recently rated row
/// cooling towards the end.
double chamberFalloff(ChamberLightMode mode, int index, int total) {
  if (total <= 1) return 1;
  final t = index / (total - 1);
  return switch (mode) {
    // A ranking leads clearly but stays readable to the end — the fifth-best
    // game is still a game you rated highly.
    ChamberLightMode.brightest => 1 - 0.4 * t,
    // Recency cools off much faster: the point of the row is what just
    // happened, not what happened three weeks ago.
    ChamberLightMode.afterglow => 1 - 0.7 * t,
    ChamberLightMode.cold => 0.55,
    ChamberLightMode.steady || ChamberLightMode.breathing => 1,
  };
}
