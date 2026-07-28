import 'package:flutter/material.dart';
import 'package:gamer_grove/core/theme/gg_detail_light.dart';
import 'package:gamer_grove/core/theme/gg_dither.dart';

/// The two gradients that let artwork meet the page.
///
/// Horizontal so the image does not run into the screen edges, vertical so the
/// bottom hands off to whatever the content starts in.
///
/// There were five copies of this — one per detail screen — and the one in the
/// event screen still carried the comment "genau wie GameDetailScreen" from
/// whoever pasted it. They had drifted only in those comments, which is the
/// best possible argument for having one.
class EntityHeroOverlays extends StatelessWidget {
  const EntityHeroOverlays({this.tint, super.key});

  /// The light the page below is standing in, when it has one.
  ///
  /// A game's page takes a tint from its cover; the other detail screens have
  /// no cover to derive a colour from and leave this null.
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final surface = scheme.surface;

    return Stack(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              stops: const [0.0, 0.05, 0.95, 1.0],
              colors: [
                surface,
                surface.withValues(alpha: .2),
                surface.withValues(alpha: .2),
                surface,
              ],
            ),
          ),
          child: const SizedBox.expand(),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0.0, 0.05, 0.8, 1.0],
              colors: [
                surface,
                surface.withValues(alpha: .2),
                surface.withValues(alpha: .8),
                surface,
              ],
            ),
          ),
          child: const SizedBox.expand(),
        ),
        // Both sides of the hand-off are made of the same material.
        //
        // The first attempt at this seam ended the artwork in a solid tinted
        // surface while the page below showed the same tint through the dither
        // — half the pixels. Opaque meeting half-opaque is a line however well
        // the colours are matched. So the artwork now fades to the plain
        // surface and the tint arrives on both sides the same way: dithered,
        // ramped in across the foot of the image and continuing straight into
        // the page's own wash.
        if (tint != null)
          Positioned.fill(
            child: IgnorePointer(
              child: RepaintBoundary(
                child: CustomPaint(
                  painter: _HeroGrain(tint!, scheme.brightness),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// The dither of the page below, ramped in across the bottom of the artwork.
class _HeroGrain extends CustomPainter {
  const _HeroGrain(this.tint, this.brightness);

  final Color tint;

  /// Which theme the artwork is fading into — the grain borrows that theme's
  /// ceiling so it never out-shouts the wash it hands over to.
  final Brightness brightness;

  /// Where the grain begins, as a fraction of the hero's height.
  ///
  /// High enough that it reads as the page rising into the image rather than
  /// as texture laid over the artwork.
  static const _starts = 0.55;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    // The grain occupies as much of the artwork as the page's wash reaches
    // below it, so the two are the same light seen from either side of the
    // seam — mirrored, not merely similar.
    final top = size.height * _starts;
    final rect = Rect.fromLTRB(0, top, size.width, size.height);
    if (rect.isEmpty) return;

    GGDither.paintGradient(
      canvas,
      rect,
      DetailLight.wash(
        size: rect.size,
        from: Alignment.bottomCenter,
        tint: tint,
        peak: DetailLight.peakOn(brightness),
      ),
    );
  }

  @override
  bool shouldRepaint(_HeroGrain oldDelegate) =>
      oldDelegate.tint != tint || oldDelegate.brightness != brightness;
}
