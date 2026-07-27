import 'package:flutter/material.dart';
import 'package:gamer_grove/core/theme/gg_detail_light.dart';

/// The two gradients that let artwork meet the page.
///
/// Horizontal so the image does not run into the screen edges, vertical so the
/// bottom hands off to whatever the content starts in.
///
/// There were five copies of this — one per detail screen — and the one in the
/// event screen still carried the comment "genau wie GameDetailScreen" from
/// whoever pasted it. They had drifted only in those comments, which is the
/// best possible argument for having one.
class EntityHeroOverlays extends StatelessWidget {
  const EntityHeroOverlays({this.tint, super.key});

  /// The light the page below is standing in, when it has one.
  ///
  /// A game's page takes a tint from its cover, so its artwork has to fade out
  /// into the lit surface rather than the plain one — otherwise the hand-off
  /// shows as a line. The other detail screens have no cover to derive a colour
  /// from and leave this null.
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;
    final foot = tint == null ? surface : litSurface(surface, tint!);

    return Stack(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              stops: const [0.0, 0.05, 0.95, 1.0],
              colors: [
                surface,
                surface.withValues(alpha: .2),
                surface.withValues(alpha: .2),
                surface,
              ],
            ),
          ),
          child: const SizedBox.expand(),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0.0, 0.05, 0.8, 1.0],
              colors: [
                surface,
                surface.withValues(alpha: .2),
                foot.withValues(alpha: .8),
                foot,
              ],
            ),
          ),
          child: const SizedBox.expand(),
        ),
      ],
    );
  }
}
