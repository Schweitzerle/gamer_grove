import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gamer_grove/core/theme/gg_tokens.dart';
import 'package:gamer_grove/presentation/widgets/gg_portal_mark.dart';

/// The app's spinner: [GGPortalMark] with the light actually rising.
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
      label: label ?? 'Loading',
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
                  painter: PortalMarkPainter(
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
