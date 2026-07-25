import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gamer_grove/core/theme/gg_dither.dart';
import 'package:gamer_grove/core/theme/gg_tokens.dart';
import 'package:gamer_grove/presentation/widgets/loading/loading_step.dart';
import 'package:gamer_grove/presentation/widgets/loading/portal_loader.dart';

/// A readout for waits that own the whole screen.
///
/// Worth more than a spinner because it says *what* is being fetched — a wait
/// you can follow feels shorter than one you cannot. Use a dither skeleton for
/// content arriving inside a screen that is already on show (`DitherSkeleton`);
/// replacing that
/// with a box like this one makes the layout jump.
///
/// The steps run on a timer, not on real progress, so the last one deliberately
/// stays pending rather than reporting success: the readout must never claim
/// something finished that has not.
class LiveLoadingProgress extends StatefulWidget {
  const LiveLoadingProgress({
    required this.title,
    required this.steps,
    super.key,
    this.stepDuration = const Duration(milliseconds: 800),
  });

  final String title;
  final List<LoadingStep> steps;
  final Duration stepDuration;

  @override
  State<LiveLoadingProgress> createState() => _LiveLoadingProgressState();
}

class _LiveLoadingProgressState extends State<LiveLoadingProgress> {
  int _current = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(widget.stepDuration, (timer) {
      if (!mounted) return timer.cancel();
      // Stops on the last step instead of wrapping or completing — the timer
      // knows nothing about whether the data actually arrived.
      if (_current >= widget.steps.length - 1) return timer.cancel();
      setState(() => _current++);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final tokens = context.ggTokens;
    final steps = widget.steps;

    return Semantics(
      liveRegion: true,
      label: '${widget.title}. ${steps[_current].text}',
      child: ExcludeSemantics(
        child: Container(
          padding: EdgeInsets.all(tokens.spaceLg),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(tokens.radiusLg),
            border: Border.all(color: scheme.outlineVariant),
            // Light pooling from the top, the same move as the Grove's stage.
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.alphaBlend(
                  scheme.primary.withValues(alpha: 0.10),
                  scheme.surfaceContainer,
                ),
                scheme.surfaceContainer,
              ],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const PortalLoader(size: 30),
                  SizedBox(width: tokens.spaceMd),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: theme.textTheme.titleLarge,
                    ),
                  ),
                ],
              ),
              SizedBox(height: tokens.spaceMd),
              _StepProgress(current: _current, total: steps.length),
              SizedBox(height: tokens.spaceMd),
              for (var i = 0; i < steps.length; i++)
                if (i <= _current)
                  Padding(
                    padding: EdgeInsets.only(bottom: tokens.spaceSm),
                    child: _StepRow(
                      step: steps[i],
                      isCurrent: i == _current,
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

/// How far through the sequence, in the icon's grain rather than as a plain
/// bar.
class _StepProgress extends StatelessWidget {
  const _StepProgress({required this.current, required this.total});

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tokens = context.ggTokens;
    final fraction = total <= 1 ? 1.0 : (current + 1) / total;

    return ClipRRect(
      borderRadius: BorderRadius.circular(tokens.radiusSm),
      child: SizedBox(
        height: tokens.spaceSm,
        child: Stack(
          children: [
            Positioned.fill(
              child: ColoredBox(color: scheme.surfaceContainerHigh),
            ),
            FractionallySizedBox(
              widthFactor: fraction.clamp(0.0, 1.0),
              child: AnimatedContainer(
                duration: tokens.durationNormal,
                curve: Curves.easeOutCubic,
                color: scheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({required this.step, required this.isCurrent});

  final LoadingStep step;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final tokens = context.ggTokens;
    final accent = step.color ?? scheme.primary;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: tokens.spaceLg,
          height: tokens.spaceLg,
          child: isCurrent
              ? _PendingMark(colour: accent)
              : Icon(
                  Icons.check_rounded,
                  size: 16,
                  color: scheme.onSurfaceVariant,
                ),
        ),
        SizedBox(width: tokens.spaceSm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                step.text,
                style: isCurrent
                    ? theme.textTheme.bodyMedium
                    : theme.textTheme.bodyMedium
                        ?.copyWith(color: scheme.onSurfaceVariant),
              ),
              if (step.substep != null && isCurrent)
                Text(step.substep!, style: theme.textTheme.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}

/// The step in progress: a small dithered pulse rather than a spinner, so the
/// readout has one visual language throughout.
class _PendingMark extends StatefulWidget {
  const _PendingMark({required this.colour});

  final Color colour;

  @override
  State<_PendingMark> createState() => _PendingMarkState();
}

class _PendingMarkState extends State<_PendingMark>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _pulse.stop();
    } else if (!_pulse.isAnimating) {
      unawaited(_pulse.repeat());
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // The sweep travels off the mark for part of its cycle, so it sits on a
    // constant base — a pending indicator that blinks out entirely reads as
    // "nothing is happening".
    return Center(
      child: SizedBox.square(
        dimension: 12,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: ColoredBox(
            color: widget.colour.withValues(alpha: 0.35),
            child: AnimatedBuilder(
              animation: _pulse,
              builder: (context, _) => CustomPaint(
                painter: LightSweepPainter(
                  colour: widget.colour,
                  progress: _pulse.isAnimating ? _pulse.value : 0.5,
                  band: 0.6,
                  strength: 0.95,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
