import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gamer_grove/core/theme/cover_tint.dart';
import 'package:gamer_grove/core/theme/gg_tokens.dart';

/// Resolves a chamber's light colour from the covers standing in it and hands
/// it to [builder].
///
/// Starts on the brand accent and eases over once the covers have given up
/// their hue, so a section never appears, flickers, and settles. If no cover
/// yields a usable hue — greyscale artwork, or nothing loaded — the brand
/// accent simply stays.
class ChamberTint extends StatefulWidget {
  const ChamberTint({
    required this.coverUrls,
    required this.builder,
    super.key,
  });

  /// The covers to take the hue from. Only the leading few are read: a row's
  /// light should come from what you actually see, and every extra cover is
  /// another fetch and decode.
  final List<String?> coverUrls;

  final Widget Function(BuildContext context, Color tint) builder;

  /// How many covers of a row contribute.
  static const sampleCount = 3;

  @override
  State<ChamberTint> createState() => _ChamberTintState();
}

class _ChamberTintState extends State<ChamberTint> {
  Color? _resolved;

  @override
  void initState() {
    super.initState();
    unawaited(_resolve());
  }

  @override
  void didUpdateWidget(ChamberTint oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.coverUrls, widget.coverUrls) &&
        oldWidget.coverUrls.join('|') != widget.coverUrls.join('|')) {
      unawaited(_resolve());
    }
  }

  Future<void> _resolve() async {
    final urls = widget.coverUrls
        .where((u) => u != null && u.isNotEmpty)
        .take(ChamberTint.sampleCount)
        .toList();
    if (urls.isEmpty) return;

    final tints = await Future.wait(urls.map(CoverTint.resolve));
    final usable = tints.whereType<Color>().toList();
    if (!mounted || usable.isEmpty) return;

    setState(() => _resolved = _blend(usable));
  }

  /// Straight channel average. The inputs already share a fixed saturation and
  /// lightness, so there is no hue-wraparound problem left to solve here — that
  /// was handled where the hues were extracted.
  static Color _blend(List<Color> colours) {
    var r = 0.0;
    var g = 0.0;
    var b = 0.0;
    for (final c in colours) {
      r += c.r;
      g += c.g;
      b += c.b;
    }
    final n = colours.length;
    return Color.from(alpha: 1, red: r / n, green: g / n, blue: b / n);
  }

  @override
  Widget build(BuildContext context) {
    final fallback = Theme.of(context).colorScheme.primary;
    final target = _resolved ?? fallback;

    return TweenAnimationBuilder<Color?>(
      tween: ColorTween(end: target),
      duration: context.ggTokens.durationNormal * 3,
      curve: Curves.easeOutCubic,
      builder: (context, value, _) => widget.builder(context, value ?? target),
    );
  }
}
