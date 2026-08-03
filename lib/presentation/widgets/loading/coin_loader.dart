import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:gamer_grove/core/theme/gg_dither.dart';

/// A coin turning over a slot, falling in, and the light that comes back up.
///
/// The loading screen needed a mascot, and a mascot is an object — which sits
/// awkwardly beside the rule the icon was built on: the games signal lives in
/// the *technique*, not in a thing, because a controller dates with the
/// hardware. A coin slot does not date, because it is history rather than
/// hardware, and "insert coin" has meant *a game is about to start* for forty
/// years. That is exactly what this screen is for.
///
/// Drawn on a 16-unit grid in whole units, like the app icon, so it reads as
/// pixel art rather than as vector shapes that happen to be blocky.
class CoinLoader extends StatefulWidget {
  const CoinLoader({super.key, this.size = 44});

  final double size;

  /// One turn-and-drop. Slow enough to follow, short enough that a fast load
  /// still shows a whole one.
  static const cycle = Duration(milliseconds: 1500);

  @override
  State<CoinLoader> createState() => _CoinLoaderState();
}

class _CoinLoaderState extends State<CoinLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _turn = AnimationController(
    vsync: this,
    duration: CoinLoader.cycle,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _turn.stop();
    } else if (!_turn.isAnimating) {
      unawaited(_turn.repeat());
    }
  }

  @override
  void dispose() {
    _turn.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    // Decorative: the card around it already says what is happening, and a
    // screen reader gains nothing from "a coin is spinning".
    return ExcludeSemantics(
      child: RepaintBoundary(
        child: SizedBox.square(
          dimension: widget.size,
          child: AnimatedBuilder(
            animation: _turn,
            builder: (context, _) => CustomPaint(
              painter: CoinPainter(
                // Held mid-turn rather than at zero, so a still frame shows a
                // coin and not an edge-on line.
                progress: _turn.isAnimating ? _turn.value : _restingFrame,
                gold: scheme.primary,
                // The struck face is *lighter* gold, not `onPrimary` — that is
                // a dark colour by construction, and a dark middle turns the
                // coin into a washer.
                highlight: Color.lerp(scheme.primary, _sheen, _struck)!,
                // `outlineVariant` rather than a surface tone: the slot has to
                // read as a thing standing on the card, and the surface tones
                // are by design almost the card itself.
                plinth: scheme.outlineVariant,
                shadow: scheme.surface,
              ),
            ),
          ),
        ),
      ),
    );
  }

  static const _restingFrame = 0.08;

  /// Metal catches light rather than taking a hue from the theme, so this one
  /// value is fixed. It is only ever mixed into the brand colour, never used
  /// on its own.
  static const _sheen = Color(0xFFFFFFFF);
  static const _struck = 0.34;
}

/// Paints one frame of [CoinLoader]. Split out so a golden can ask for a
/// specific moment instead of racing a controller.
@visibleForTesting
class CoinPainter extends CustomPainter {
  const CoinPainter({
    required this.progress,
    required this.gold,
    required this.highlight,
    required this.plinth,
    required this.shadow,
  });

  /// 0..1 through one turn-and-drop.
  final double progress;
  final Color gold;
  final Color highlight;
  final Color plinth;
  final Color shadow;

  /// The sprite is 16 units wide and tall.
  static const grid = 16.0;

  /// The coin turns above the slot for this much of the cycle, then falls.
  static const _fallsAfter = 0.62;

  /// Turns per cycle while it hovers. Three full turns is enough to read as
  /// spinning without strobing.
  static const _turns = 3;

  static const _topOfSlot = 10.0;
  static const _coinRests = 2.0;
  static const _coinHeight = 4.0;

  /// Half the coin at its widest, in grid units.
  static const _widest = 3.0;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final unit = size.shortestSide / grid;

    void block(double x, double y, double w, double h, Color colour) {
      canvas.drawRect(
        Rect.fromLTWH(x * unit, y * unit, w * unit, h * unit),
        Paint()..color = colour,
      );
    }

    final falling = progress > _fallsAfter;
    final fall = falling ? (progress - _fallsAfter) / (1 - _fallsAfter) : 0.0;
    final drop = Curves.easeInQuad.transform(fall);

    // The light comes back up as the coin goes down: the slot answers.
    if (fall > 0.55) {
      final glow = (fall - 0.55) / 0.45;
      GGDither.paintGradient(
        canvas,
        Rect.fromLTWH(3 * unit, 5 * unit, 10 * unit, 6 * unit),
        RadialGradient(
          colors: [
            gold.withValues(alpha: (1 - glow) * _glowPeak),
            gold.withValues(alpha: 0),
          ],
        ),
      );
    }

    // The plinth: a lit top face, and a dark mouth the coin disappears into.
    // The mouth has to be the darkest thing here or the coin looks like it is
    // landing *on* the box rather than going into it.
    block(3, _topOfSlot, 10, 4, plinth);
    block(3, _topOfSlot, 10, 1, Color.lerp(plinth, gold, _litRim)!);
    block(7, _topOfSlot, 2, 1, shadow);

    // Width follows the turn, so the coin reads as a disc seen from the side.
    // Quantised to whole units — a smoothly interpolated width would be the
    // one part of the sprite that is not pixel art.
    final face = math.cos(progress * _turns * 2 * math.pi).abs();
    final half = math.max(1, (face * _widest).round()).toDouble();

    final top = _coinRests + drop * (_topOfSlot - _coinRests);
    // Clipped at the mouth: past it the coin is inside the slot, not in front
    // of it.
    final visible = math.min(_coinHeight, _topOfSlot + 1 - top);
    if (visible <= 0) return;

    block(8 - half, top, half * 2, visible, gold);
    if (half >= 2 && visible >= 3) {
      // The struck face, only when the coin is wide enough to show one.
      block(8 - half + 1, top + 1, half * 2 - 2, visible - 2, highlight);
    }
  }

  static const _glowPeak = 0.55;
  static const _litRim = 0.22;

  @override
  bool shouldRepaint(CoinPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.gold != gold ||
      oldDelegate.highlight != highlight ||
      oldDelegate.plinth != plinth ||
      oldDelegate.shadow != shadow;
}
