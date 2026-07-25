import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gamer_grove/core/theme/gg_dither.dart';
import 'package:gamer_grove/core/theme/gg_tokens.dart';

/// The app's spinner: the icon's doorway, with light rising through it.
///
/// A gamepad or a console would have been the obvious animated mark, and it is
/// the same trap the app icon avoided — device motifs age with the hardware and
/// look like every other games app. The portal is already ours, and "the way is
/// opening" is a fair description of what loading is.
class PortalLoader extends StatefulWidget {
  const PortalLoader({this.size = 56, this.label, super.key});

  final double size;

  /// Announced to screen readers, and shown underneath when given.
  final String? label;

  @override
  State<PortalLoader> createState() => _PortalLoaderState();
}

class _PortalLoaderState extends State<PortalLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _rise = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // A looping animation that nobody asked for is exactly what reduced-motion
    // is about; the portal then simply stands lit.
    if (MediaQuery.disableAnimationsOf(context)) {
      _rise.stop();
    } else if (!_rise.isAnimating) {
      unawaited(_rise.repeat());
    }
  }

  @override
  void dispose() {
    _rise.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.ggTokens;
    final label = widget.label;

    return Semantics(
      label: label ?? 'Wird geladen',
      liveRegion: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ExcludeSemantics(
            child: SizedBox(
              width: widget.size,
              height: widget.size * 1.15,
              child: AnimatedBuilder(
                animation: _rise,
                builder: (context, _) => CustomPaint(
                  painter: _PortalPainter(
                    frame: theme.colorScheme.primary,
                    opening: theme.colorScheme.surface,
                    light: theme.colorScheme.primary,
                    progress: _rise.isAnimating ? _rise.value : 0.35,
                  ),
                ),
              ),
            ),
          ),
          if (label != null) ...[
            SizedBox(height: tokens.spaceSm),
            ExcludeSemantics(
              child: Text(label, style: theme.textTheme.bodySmall),
            ),
          ],
        ],
      ),
    );
  }
}

class _PortalPainter extends CustomPainter {
  const _PortalPainter({
    required this.frame,
    required this.opening,
    required this.light,
    required this.progress,
  });

  final Color frame;
  final Color opening;
  final Color light;
  final double progress;

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
    final outer = Offset.zero & size;
    final thickness = size.width * 0.13;
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

    // A band of light travelling up through the opening, stepped through the
    // icon's grain rather than smoothly blended.
    final travel = inner.height * 1.6;
    final top = inner.bottom - travel * progress;
    GGDither.paintGradient(
      canvas,
      Rect.fromLTRB(inner.left, top, inner.right, top + inner.height),
      LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          light.withValues(alpha: 0),
          light.withValues(alpha: 0.85),
          light.withValues(alpha: 0),
        ],
        stops: const [0, 0.5, 1],
      ),
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(_PortalPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.frame != frame ||
      oldDelegate.opening != opening ||
      oldDelegate.light != light;
}
