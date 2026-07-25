import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gamer_grove/core/theme/gg_dither.dart';
import 'package:gamer_grove/core/theme/gg_tokens.dart';

/// A placeholder in the shape of the thing that is coming.
///
/// Two loading devices, two jobs, and the difference matters: a skeleton stands
/// in for content inside a screen that is already there, so the layout does not
/// jump when the real thing arrives. The portal loader and the step readout
/// are for waits that own the whole screen.
///
/// The sweep is the icon's dither grid rather than the interchangeable grey
/// gradient every catalogue ships.
class DitherSkeleton extends StatefulWidget {
  const DitherSkeleton({
    required this.width,
    required this.height,
    this.borderRadius,
    super.key,
  });

  /// A block the shape of a cover.
  const DitherSkeleton.cover({double width = 120, Key? key})
      : this(width: width, height: width * 4 / 3, key: key);

  /// A line the shape of a label.
  const DitherSkeleton.line({double width = 90, double height = 10, Key? key})
      : this(width: width, height: height, key: key);

  final double width;
  final double height;
  final BorderRadius? borderRadius;

  @override
  State<DitherSkeleton> createState() => _DitherSkeletonState();
}

class _DitherSkeletonState extends State<DitherSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _sweep = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _sweep.stop();
    } else if (!_sweep.isAnimating) {
      unawaited(_sweep.repeat());
    }
  }

  @override
  void dispose() {
    _sweep.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final radius =
        widget.borderRadius ?? BorderRadius.circular(context.ggTokens.radiusSm);

    return ExcludeSemantics(
      child: ClipRRect(
        borderRadius: radius,
        child: SizedBox(
          width: widget.width,
          height: widget.height,
          child: ColoredBox(
            color: scheme.surfaceContainerHigh,
            child: _sweep.isAnimating
                ? AnimatedBuilder(
                    animation: _sweep,
                    builder: (context, _) => CustomPaint(
                      painter: LightSweepPainter(
                        colour: scheme.primary,
                        progress: _sweep.value,
                        band: 0.22,
                        strength: 0.34,
                      ),
                    ),
                  )
                : const SizedBox.expand(),
          ),
        ),
      ),
    );
  }
}

/// A row of cover-shaped placeholders, matching the rails on the Grove.
class DitherRailSkeleton extends StatelessWidget {
  const DitherRailSkeleton({this.count = 4, this.coverWidth = 120, super.key});

  final int count;
  final double coverWidth;

  @override
  Widget build(BuildContext context) {
    final tokens = context.ggTokens;
    return SizedBox(
      height: coverWidth * 4 / 3 + tokens.spaceLg,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: tokens.spaceMd),
        itemCount: count,
        separatorBuilder: (_, __) => SizedBox(width: tokens.spaceSm),
        itemBuilder: (context, _) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DitherSkeleton.cover(width: coverWidth),
            SizedBox(height: tokens.spaceXs),
            DitherSkeleton.line(width: coverWidth * 0.8),
          ],
        ),
      ),
    );
  }
}
