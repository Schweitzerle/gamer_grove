import 'package:flutter/material.dart';
import 'package:gamer_grove/core/theme/gg_dither.dart';

/// The light a detail page takes from its own artwork — and where that light
/// stops.
///
/// Three reaches were on the table: light only at the very top, light
/// everywhere, or this one — the artwork lights the head of the page and the
/// light falls away beneath it. Abklingend is the one that says something true.
/// You arrive in the game's colour and then walk out of it, which is the rule
/// the Grove's chambers already follow; a page tinted end to end would just be
/// a coloured background, and a light confined to the header would be a stripe.
///
/// The wash scrolls with the content rather than sitting fixed in the viewport,
/// so the decay is a property of the page and not of where you happen to have
/// stopped scrolling.
///
/// Baked once and redrawn as an image rather than masked every frame — see
/// [DitheredWashCache].
class DetailLight extends StatelessWidget {
  const DetailLight({required this.tint, super.key});

  /// Colour of the light, derived from the artwork by `CoverTint`.
  final Color tint;

  /// How far the light reaches below the artwork, in logical pixels.
  ///
  /// A little over one hero: the first rows of content are still standing in
  /// it, and the page is unmistakably dark again well before the media gallery.
  static const reach = 560.0;

  /// Alpha where the light is strongest, directly under the artwork.
  ///
  /// Measured against the palette rather than chosen by eye, the same way
  /// `LitSection.maxVeil` was. Every tint the cover extractor can produce was
  /// composited over both surfaces and checked against the foregrounds that sit
  /// in the light:
  ///
  /// | | secondary text | gold accent |
  /// |---|---|---|
  /// | dark | 0.39 | 0.47 |
  /// | light | 0.26 | **0.17** |
  ///
  /// The gold accent on paper binds, and one constant serves both themes, so
  /// the light stops just under it. The consequence is honest: this is a
  /// quieter light than a mock-up would promise, and it has to be — the
  /// alternative is text that fails AA on a yellow cover.
  static const peak = 0.16;

  /// Alpha at the halfway point, where the light is already mostly spent.
  static const double _mid = peak * 0.34;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(painter: _DetailLightPainter(tint)),
      ),
    );
  }
}

class _DetailLightPainter extends CustomPainter {
  const _DetailLightPainter(this.tint);

  final Color tint;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    final image = DitheredWashCache.forSize(
      'detail',
      size,
      tint,
      () => RadialGradient(
        // Anchored where the artwork ends, so the page reads as lit by the
        // cover above it rather than by a band floating in the content.
        center: Alignment.topCenter,
        radius: 1.3,
        colors: [
          tint.withValues(alpha: DetailLight.peak),
          tint.withValues(alpha: DetailLight._mid),
          tint.withValues(alpha: 0),
        ],
        stops: const [0, 0.45, 1],
      ),
    );
    DitheredWashCache.draw(canvas, image, Offset.zero & size, 1);
  }

  @override
  bool shouldRepaint(_DetailLightPainter oldDelegate) =>
      oldDelegate.tint != tint;
}

/// The surface of a page standing in [tint]'s light at its strongest.
///
/// The hero's gradients have to end in this rather than in plain `surface`,
/// otherwise the artwork fades out into one colour and the content below starts
/// in another, and the seam between them is visible as a line.
Color litSurface(Color surface, Color tint) =>
    Color.alphaBlend(tint.withValues(alpha: DetailLight.peak), surface);
