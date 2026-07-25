import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gamer_grove/core/theme/gg_dither.dart';
import 'package:gamer_grove/core/theme/gg_tokens.dart';
import 'package:gamer_grove/domain/entities/game/game.dart';
import 'package:gamer_grove/presentation/widgets/top_three/stacked_cover.dart';

/// The Top 3 as a stack in depth: whichever cover is in front stands in the
/// light, the other two step back into the dark.
///
/// Three entries is a fixed number, so it can be composed rather than listed —
/// and rank reads as *nearness* instead of as a position in a row. On first
/// appearance the stack cycles once so all three are seen, then rests on rank
/// one; after that it only moves when the user swipes or taps.
///
/// Only the front cover opens a game. The ones behind are partly hidden and
/// darker, which makes them poor tap targets, so tapping one brings it forward
/// instead — and its semantic label says so.
class TopThreeStack extends StatefulWidget {
  const TopThreeStack({
    required this.games,
    required this.onOpenGame,
    this.onFillSlot,
    super.key,
  });

  /// Up to three games, best first. Fewer than three renders empty places.
  final List<Game> games;

  final ValueChanged<Game> onOpenGame;

  /// Invoked when an unfilled place is tapped.
  final VoidCallback? onFillSlot;

  static const slots = 3;

  @override
  State<TopThreeStack> createState() => _TopThreeStackState();
}

class _TopThreeStackState extends State<TopThreeStack>
    with SingleTickerProviderStateMixin {
  static const _introDwell = Duration(milliseconds: 2600);

  late final AnimationController _arrival = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );

  int _front = 0;
  Timer? _intro;
  int _introSteps = 0;
  bool _introDone = false;

  @override
  void dispose() {
    _intro?.cancel();
    _arrival.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Introduce the stack once per mount, and never when the user asked the
    // system for less motion.
    if (!_introDone && !MediaQuery.disableAnimationsOf(context)) {
      _introDone = true;
      _intro = Timer.periodic(_introDwell, (timer) {
        if (!mounted) return timer.cancel();
        _advance(1);
        if (++_introSteps >= TopThreeStack.slots) timer.cancel();
      });
    }
  }

  void _stopIntro() {
    _intro?.cancel();
    _intro = null;
  }

  void _advance(int direction) {
    setState(() {
      _front = (_front + direction) % TopThreeStack.slots;
      if (_front < 0) _front += TopThreeStack.slots;
    });
    if (!MediaQuery.disableAnimationsOf(context)) {
      unawaited(_arrival.forward(from: 0));
    }
  }

  void _bringForward(int index) {
    _stopIntro();
    if (index == _front) return;
    setState(() => _front = index);
    if (!MediaQuery.disableAnimationsOf(context)) {
      unawaited(_arrival.forward(from: 0));
    }
  }

  /// slot 0 is the front, 1 waits on the right, 2 has just stepped off left.
  int _slotOf(int index) =>
      (index - _front + TopThreeStack.slots) % TopThreeStack.slots;

  @override
  Widget build(BuildContext context) {
    final tokens = context.ggTokens;
    final scheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final cardWidth = width * 0.46;
        final cardHeight = cardWidth * 4 / 3;
        // Room above the covers for the beam to travel through — without it
        // the cone is drawn entirely behind the front cover and never seen.
        final beamRoom = tokens.spaceLg;
        final height = cardHeight + beamRoom + tokens.spaceXl;

        // Painting order: the two in the back first, the front one last.
        final order = List.generate(TopThreeStack.slots, (i) => i)
          ..sort((a, b) => _slotOf(b).compareTo(_slotOf(a)));

        return GestureDetector(
          onHorizontalDragEnd: (details) {
            final v = details.primaryVelocity ?? 0;
            if (v.abs() < 120) return;
            _stopIntro();
            _advance(v < 0 ? 1 : -1);
          },
          child: SizedBox(
            height: height,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                // The beam sits behind everything and always points at the
                // front position, which is why that cover is the lit one.
                Positioned.fill(
                  child: IgnorePointer(
                    child: AnimatedBuilder(
                      animation: _arrival,
                      builder: (context, _) => CustomPaint(
                        painter: SpotlightPainter(
                          colour: scheme.primary,
                          // Flares as a cover arrives, then settles back to a
                          // constant, weaker light.
                          intensity: 0.6 + 0.4 * _flare(_arrival.value),
                        ),
                      ),
                    ),
                  ),
                ),
                for (final index in order)
                  _positioned(
                    index: index,
                    width: width,
                    cardWidth: cardWidth,
                    cardHeight: cardHeight,
                    beamRoom: beamRoom,
                    tokens: tokens,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Bright on arrival, fading to the resting level.
  double _flare(double t) =>
      t <= 0 || t >= 1 ? 0 : Curves.easeOutCubic.transform(1 - t);

  Widget _positioned({
    required int index,
    required double width,
    required double cardWidth,
    required double cardHeight,
    required double beamRoom,
    required GGTokens tokens,
  }) {
    final slot = _slotOf(index);
    final isFront = slot == 0;
    final side = slot == 1 ? 1.0 : -1.0;

    final dx = isFront ? 0.0 : side * width * 0.25;
    final scale = isFront ? 1.0 : 0.84;
    // AnimatedRotation counts *turns*, not radians: 0.1 here would be 36°.
    final turns = isFront ? 0.0 : side * 0.028;
    final game = index < widget.games.length ? widget.games[index] : null;

    return AnimatedPositioned(
      key: ValueKey('top3-slot-$index'),
      duration: tokens.durationNormal,
      curve: Curves.easeOutCubic,
      top: beamRoom + (isFront ? 0 : tokens.spaceLg),
      left: (width - cardWidth) / 2 + dx,
      width: cardWidth,
      height: cardHeight,
      child: AnimatedScale(
        scale: scale,
        duration: tokens.durationNormal,
        curve: Curves.easeOutCubic,
        child: AnimatedRotation(
          turns: turns,
          duration: tokens.durationNormal,
          curve: Curves.easeOutCubic,
          child: AnimatedBuilder(
            animation: _arrival,
            builder: (context, child) => StackedCover(
              rank: index + 1,
              game: game,
              isFront: isFront,
              // slot 1 sits to the right, tucked behind the front cover.
              numeralOnOuterRight: slot == 1,
              sweepProgress: isFront ? _arrival.value : 0,
              onTap: switch ((game, isFront)) {
                (null, _) => widget.onFillSlot,
                (final g?, true) => () => widget.onOpenGame(g),
                (_, false) => () => _bringForward(index),
              },
            ),
          ),
        ),
      ),
    );
  }
}
