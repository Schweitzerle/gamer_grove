import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gamer_grove/core/theme/gg_dither.dart';
import 'package:gamer_grove/core/theme/gg_tokens.dart';
import 'package:gamer_grove/presentation/widgets/loading/coin_loader.dart';
import 'package:gamer_grove/presentation/widgets/loading/loading_step.dart';

/// A readout for waits that own the whole screen.
///
/// Worth more than a spinner because it says *what* is being fetched — a wait
/// you can follow feels shorter than one you cannot. Use a dither skeleton for
/// content arriving inside a screen that is already on show
/// (`DitherSkeleton`); replacing that with a card like this one makes the
/// layout jump.
///
/// It is a card, not a section: it arrives, it is centred, and everything
/// behind it is backdrop. Drawn as part of the page it stops reading as an
/// interruption and starts reading as one more element of the page that is
/// still loading — which is exactly the wrong thing for it to say.
///
/// The steps run on a timer, not on real progress, so the last one deliberately
/// stays pending rather than reporting success: the readout must never claim
/// something finished that has not.
class LiveLoadingProgress extends StatefulWidget {
  const LiveLoadingProgress({
    required this.title,
    required this.steps,
    super.key,
    this.artwork,
    this.stepDuration = const Duration(milliseconds: 800),
  });

  final String title;
  final List<LoadingStep> steps;

  /// A picture of the thing being fetched, shown opposite the coin. Callers
  /// that have no artwork — a company, an event — pass nothing and get the
  /// live dot on its own.
  final Widget? artwork;

  final Duration stepDuration;

  /// Sits above the title, so the card says what it is before it says what it
  /// is about.
  static const label = 'NOW LOADING';

  @override
  State<LiveLoadingProgress> createState() => _LiveLoadingProgressState();
}

class _LiveLoadingProgressState extends State<LiveLoadingProgress>
    with SingleTickerProviderStateMixin {
  int _current = 0;
  Timer? _timer;

  late final AnimationController _entrance = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );

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
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _entrance.value = 1;
    } else if (!_entrance.isAnimating && _entrance.value == 0) {
      unawaited(_entrance.forward());
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _entrance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final steps = widget.steps;

    return Semantics(
      liveRegion: true,
      // Says what is happening before it says what it is doing. The card shows
      // "NOW LOADING" over the title; spoken, that order only works as a
      // sentence.
      label: 'Loading ${widget.title}. ${steps[_current].text}',
      child: ExcludeSemantics(
        child: _Arriving(
          entrance: _entrance,
          child: _card(context, steps),
        ),
      ),
    );
  }

  Widget _card(BuildContext context, List<LoadingStep> steps) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final tokens = context.ggTokens;

    return Container(
      padding: EdgeInsets.all(tokens.spaceLg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(tokens.radiusLg),
        border: Border.all(color: scheme.outlineVariant),
        color: scheme.surfaceContainer,
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withValues(alpha: _shadow),
            blurRadius: tokens.spaceXl,
            offset: Offset(0, tokens.spaceMd),
          ),
        ],
        // Light pooling from the top, the same move as the Grove's stage.
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.alphaBlend(
              scheme.primary.withValues(alpha: _pool),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CoinLoader(size: tokens.spaceXl * 1.4),
              SizedBox(width: tokens.spaceMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      LiveLoadingProgress.label,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: scheme.primary,
                        letterSpacing: _tracking,
                      ),
                    ),
                    Text(
                      widget.title,
                      style: theme.textTheme.titleLarge,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              SizedBox(width: tokens.spaceSm),
              widget.artwork ?? const SizedBox.shrink(),
            ],
          ),
          SizedBox(height: tokens.spaceLg),
          // Grown, not animated. `AnimatedSize` clips its child while it
          // catches up, so every frame in which a step had just landed showed
          // that step sliced in half with the progress bar drawn across it —
          // for a card whose whole job is to be legible mid-wait, that is the
          // wrong trade for a smoother edge.
          for (var i = 0; i < steps.length; i++)
            if (i <= _current)
              Padding(
                padding: EdgeInsets.only(bottom: tokens.spaceSm),
                child: _StepRow(
                  key: ValueKey(i),
                  step: steps[i],
                  isCurrent: i == _current,
                ),
              ),
          SizedBox(height: tokens.spaceSm),
          _StepProgress(current: _current, total: steps.length),
          SizedBox(height: tokens.spaceSm),
          Text(
            'Step ${_current + 1} of ${steps.length}',
            style: theme.textTheme.labelSmall
                ?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  static const _shadow = 0.32;
  static const _pool = 0.10;
  static const _tracking = 1.6;
}

/// The card fades in, rises, and grows the last three percent.
///
/// Without it the card is simply *there* on the first frame, which is how a
/// part of the page behaves. Arriving is what makes it an interruption.
class _Arriving extends StatelessWidget {
  const _Arriving({required this.entrance, required this.child});

  final Animation<double> entrance;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final curved =
        CurvedAnimation(parent: entrance, curve: Curves.easeOutCubic);
    return AnimatedBuilder(
      animation: curved,
      builder: (context, child) => Opacity(
        opacity: curved.value,
        child: Transform.translate(
          offset: Offset(0, (1 - curved.value) * _rise),
          child: Transform.scale(
            scale: _from + curved.value * (1 - _from),
            child: child,
          ),
        ),
      ),
      child: child,
    );
  }

  static const _rise = 16.0;
  static const _from = 0.97;
}

/// How far through the sequence, in the icon's grain rather than as a plain
/// bar.
class _StepProgress extends StatefulWidget {
  const _StepProgress({required this.current, required this.total});

  final int current;
  final int total;

  @override
  State<_StepProgress> createState() => _StepProgressState();
}

class _StepProgressState extends State<_StepProgress>
    with SingleTickerProviderStateMixin {
  late final AnimationController _sheen = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _sheen.stop();
    } else if (!_sheen.isAnimating) {
      unawaited(_sheen.repeat());
    }
  }

  @override
  void dispose() {
    _sheen.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tokens = context.ggTokens;
    final fraction =
        widget.total <= 1 ? 1.0 : (widget.current + 1) / widget.total;

    return ClipRRect(
      borderRadius: BorderRadius.circular(tokens.radiusSm),
      child: SizedBox(
        height: tokens.spaceSm,
        child: Stack(
          children: [
            Positioned.fill(
              child: ColoredBox(color: scheme.surfaceContainerHigh),
            ),
            AnimatedFractionallySizedBox(
              duration: tokens.durationNormal,
              curve: Curves.easeOutCubic,
              widthFactor: fraction.clamp(0.0, 1.0),
              alignment: Alignment.centerLeft,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ColoredBox(color: scheme.primary),
                  // A pass of light along what is already done, through the
                  // same grain as the rest of the app.
                  AnimatedBuilder(
                    animation: _sheen,
                    builder: (context, _) => CustomPaint(
                      painter: LightSweepPainter(
                        colour: scheme.onPrimary,
                        progress: _sheen.isAnimating ? _sheen.value : 0,
                        band: _band,
                        strength: _strength,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const _band = 0.22;
  static const _strength = 0.45;
}

class _StepRow extends StatelessWidget {
  const _StepRow({required this.step, required this.isCurrent, super.key});

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
