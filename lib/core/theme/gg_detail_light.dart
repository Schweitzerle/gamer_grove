import 'package:flutter/foundation.dart';
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
  const DetailLight({required this.tint, this.intensity = 1, super.key});

  /// Colour of the light, derived from the artwork by `CoverTint`.
  final Color tint;

  /// How far up the light has come, 0 to 1.
  ///
  /// Driven by the opening transition so the light rises *while* the cover
  /// lands, rather than standing there finished when the page arrives. That
  /// timing is the whole reason the page's colour reads as coming from the
  /// artwork instead of being a decision someone made.
  final double intensity;

  /// How far the light reaches below the artwork, in logical pixels.
  ///
  /// A little over one hero: the first rows of content are still standing in
  /// it, and the page is unmistakably dark again well before the media gallery.
  static const reach = 560.0;

  /// Alpha where the light is strongest, directly under the artwork — per
  /// theme, because the two have very different room.
  ///
  /// Measured by compositing every tint `CoverTint` can produce over each
  /// surface and checking the foregrounds that stand in the light:
  ///
  /// | | secondary text | gold accent |
  /// |---|---|---|
  /// | dark | 0.39 | 0.47 |
  /// | light | 0.26 | **0.17** |
  ///
  /// The first version used one constant for both and took 0.16, which meant
  /// the light theme's ceiling decided what the dark theme — the default — was
  /// allowed to do. At 0.16 on `#0B1614` the lit pixel reaches a relative
  /// luminance of 0.014, barely one surface elevation step, and the dither
  /// leaves half the pixels untouched on top of that. It was reported as "no
  /// difference I can see", and that was correct.
  ///
  /// This is not a relaxation of the contrast rule. It is the same rule applied
  /// to each surface instead of to the stricter of the two.
  static double peakOn(Brightness brightness) =>
      brightness == Brightness.dark ? 0.34 : 0.16;

  /// Alpha at the halfway point, where the light is already mostly spent.
  static double _midOf(double peak) => peak * 0.34;

  /// How far the light carries, as a multiple of the width it is drawn across.
  ///
  /// Expressed against the width rather than the shorter side, so the same
  /// light drawn into two boxes of different heights still falls off over the
  /// same number of pixels. That is what lets the artwork's grain and the
  /// page's wash agree along the edge where they meet.
  static const _spread = 1.3;

  /// The light itself, for a box of [size], falling away from [from].
  ///
  /// One definition, used twice: the page's wash falls from its top edge, and
  /// the artwork's grain rises to its bottom edge. Mirrored like that, the two
  /// carry the same value at every x along the seam, so there is no line to
  /// see. Two separately-tuned gradients cannot manage that — the first attempt
  /// paired a radial wash with a flat ramp, which matched in the middle and
  /// drifted apart towards the edges.
  static Gradient wash({
    required Size size,
    required Alignment from,
    required Color tint,
    required double peak,
  }) {
    final shortest = size.shortestSide;
    return RadialGradient(
      center: from,
      // Flutter measures a radial radius against the shortest side; rewriting
      // it against the width keeps the falloff the same number of pixels
      // whatever the box's height.
      radius: shortest == 0 ? _spread : _spread * size.width / shortest,
      colors: [
        tint.withValues(alpha: peak),
        tint.withValues(alpha: _midOf(peak)),
        tint.withValues(alpha: 0),
      ],
      stops: const [0, 0.45, 1],
    );
  }

  @override
  Widget build(BuildContext context) {
    final peak = peakOn(Theme.of(context).brightness);
    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(
          painter: _DetailLightPainter(tint, intensity, peak),
        ),
      ),
    );
  }
}

class _DetailLightPainter extends CustomPainter {
  const _DetailLightPainter(this.tint, this.intensity, this.peak);

  final Color tint;
  final double intensity;
  final double peak;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty || intensity <= 0.01) return;

    final image = DitheredWashCache.forSize(
      // The peak belongs in the key: the two themes bake different washes for
      // the same tint, and sharing one would give whichever drew first.
      'detail/$peak',
      size,
      tint,
      // Anchored where the artwork ends, so the page reads as lit by the cover
      // above it rather than by a band floating in the content.
      () => DetailLight.wash(
        size: size,
        from: Alignment.topCenter,
        tint: tint,
        peak: peak,
      ),
    );
    DitheredWashCache.draw(
      canvas,
      image,
      Offset.zero & size,
      intensity.clamp(0.0, 1.0),
    );
  }

  @override
  bool shouldRepaint(_DetailLightPainter oldDelegate) =>
      oldDelegate.tint != tint ||
      oldDelegate.intensity != intensity ||
      oldDelegate.peak != peak;
}

/// The surface of a page standing in [tint]'s light at its strongest.
///
/// This is the worst case a foreground has to survive: the brightest point of
/// the wash, before the dither takes half of it away. Nothing draws with it —
/// the seam between artwork and page is carried by the shared grain instead —
/// but every contrast check is made against it, because assuming the dither's
/// average would be assuming the glyph never lands on a lit pixel.
@visibleForTesting
Color litSurface(ColorScheme scheme, Color tint) => Color.alphaBlend(
      tint.withValues(alpha: DetailLight.peakOn(scheme.brightness)),
      scheme.surface,
    );
