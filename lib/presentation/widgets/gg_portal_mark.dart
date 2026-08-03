import 'package:flutter/material.dart';
import 'package:gamer_grove/core/theme/gg_dither.dart';

/// The app's mark: the doorway from the icon, standing still.
///
/// The brand decision behind the icon was that the games signal lives in the
/// **technique** — flat blocks and ordered dithering on a 32-unit grid — and not
/// in an object, because a controller dates with the hardware it copies. The
/// icon on the home screen was rebuilt on that basis; the marks *inside* the app
/// were not, and went on showing a d-pad on the sign-in screen, in the app bar
/// and on the Grove's own tab.
///
/// Same construction as the portal loader, which is the animated form of this:
/// an arch, an opening, and light through the opening. Here the light stands at a
/// fixed height rather than travelling, so the mark is a mark and not a thing
/// that moves in the corner of the eye.
class GGPortalMark extends StatelessWidget {
  const GGPortalMark({
    super.key,
    this.size = 24,
    this.colour,
    this.lit = _restingLight,
  });

  /// Width. The arch is slightly taller than it is wide, as in the icon.
  final double size;

  /// Defaults to whatever the surrounding [IconTheme] is using, so the mark
  /// takes part in selection and disabled states like any icon would.
  final Color? colour;

  /// Where the band of light stands in the opening, 0 at the threshold and 1
  /// at the top.
  final double lit;

  /// High enough to read as light coming through, low enough to leave the
  /// arch as the shape you notice first.
  static const _restingLight = 0.35;

  static const _aspect = 1.15;

  /// Below this the grain stops being the brand's technique and starts being
  /// noise: at 24 px the opening is about a dozen dither cells across, and a
  /// checkerboard that small reads as a smudge. The light is drawn solid there
  /// and the mark stays crisp.
  static const _grainFrom = 32.0;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tint = colour ?? IconTheme.of(context).color ?? scheme.primary;

    return ExcludeSemantics(
      child: SizedBox(
        width: size,
        height: size * _aspect,
        child: CustomPaint(
          painter: PortalMarkPainter(
            frame: tint,
            opening: scheme.surface,
            light: tint,
            progress: lit,
            grain: size >= _grainFrom,
          ),
        ),
      ),
    );
  }
}

/// Paints the arch, its opening, and the light rising through it.
///
/// Public because both the mark and the loader draw it; they differ only in
/// whether `progress` is animated.
class PortalMarkPainter extends CustomPainter {
  const PortalMarkPainter({
    required this.frame,
    required this.opening,
    required this.light,
    required this.progress,
    this.grain = true,
  });

  final Color frame;
  final Color opening;
  final Color light;
  final double progress;

  /// Whether the light is stepped through the icon's dither or drawn smooth.
  final bool grain;

  static const _thickness = 0.13;
  static const _travel = 1.6;
  static const _peak = 0.85;

  Path _arch(Rect r) {
    final radius = r.width / 2;
    return Path()
      ..moveTo(r.left, r.bottom)
      ..lineTo(r.left, r.top + radius)
      ..arcToPoint(
        Offset(r.right, r.top + radius),
        radius: Radius.circular(radius),
      )
      ..lineTo(r.right, r.bottom)
      ..close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final outer = Offset.zero & size;
    final thickness = size.width * _thickness;
    final inner = Rect.fromLTRB(
      outer.left + thickness,
      outer.top + thickness,
      outer.right - thickness,
      outer.bottom,
    );

    canvas
      ..drawPath(_arch(outer), Paint()..color = frame)
      ..drawPath(_arch(inner), Paint()..color = opening)
      ..save()
      ..clipPath(_arch(inner));

    // A band of light travelling up through the opening.
    final travel = inner.height * _travel;
    final top = inner.bottom - travel * progress;
    final band =
        Rect.fromLTRB(inner.left, top, inner.right, top + inner.height);
    final gradient = LinearGradient(
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
      colors: [
        light.withValues(alpha: 0),
        light.withValues(alpha: _peak),
        light.withValues(alpha: 0),
      ],
      stops: const [0, 0.5, 1],
    );

    if (grain) {
      GGDither.paintGradient(canvas, band, gradient);
    } else {
      canvas.drawRect(band, Paint()..shader = gradient.createShader(band));
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(PortalMarkPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.frame != frame ||
      oldDelegate.opening != opening ||
      oldDelegate.light != light ||
      oldDelegate.grain != grain;
}
