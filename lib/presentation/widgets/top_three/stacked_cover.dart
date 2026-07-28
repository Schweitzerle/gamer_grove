import 'package:gamer_grove/core/navigation/gg_reveal_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gamer_grove/core/theme/gg_dither.dart';
import 'package:gamer_grove/core/theme/gg_tokens.dart';
import 'package:gamer_grove/core/theme/gg_typography.dart';
import 'package:gamer_grove/core/utils/image_utils.dart';
import 'package:gamer_grove/domain/entities/game/game.dart';

/// One cover in the Top 3 stack, or an empty place waiting to be filled.
///
/// Depth is faked with scale, offset and a darkening veil rather than a real
/// perspective transform: cheaper, and it keeps the covers rectangular so
/// nothing of the artwork is cropped.
class StackedCover extends StatelessWidget {
  const StackedCover({
    required this.rank,
    required this.game,
    required this.isFront,
    required this.numeralOnOuterRight,
    required this.sweepProgress,
    required this.onTap,
    super.key,
  });

  final int rank;
  final Game? game;
  final bool isFront;

  /// Back covers sit partly behind the front one, so their numeral has to move
  /// to the outer edge or it is simply hidden.
  final bool numeralOnOuterRight;

  /// 0 → 1 while a band of light passes over this cover; 0 when at rest.
  final double sweepProgress;

  /// Null makes this place inert — an unfilled slot with nowhere to go is not
  /// a button and must not announce itself as one.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final tokens = context.ggTokens;
    final radius = BorderRadius.circular(tokens.radiusMd);
    final title = game?.name;

    // Only the front cover opens a game. The others say what they will do
    // instead, so nobody taps expecting to open and gets a shuffle.
    final label = switch ((game, isFront, onTap)) {
      // Nowhere to send anyone yet, so it promises nothing.
      (null, _, null) => 'Place $rank is still empty',
      (null, _, _) => 'Place $rank is still empty. Tap to choose a game.',
      (final g?, true, _) => 'Place $rank: ${g.name}. Tap to open the game.',
      (final g?, false, _) =>
        'Place $rank: ${g.name}. Tap to bring it to the front.',
    };

    return Semantics(
      // An inert place has no action to force a node of its own, so without
      // this its label would be merged into the parent and never announced as
      // a separate place.
      container: true,
      button: onTap != null,
      label: label,
      child: GestureDetector(
        onTap: onTap == null
            ? null
            : () {
                // The Grove's headline is these stacked covers, not a
                // `GameCard`, so without this the reveal fell back to measuring
                // the whole section — a near-full-screen rectangle growing to
                // full screen, which looks like no transition at all.
                RevealOrigin.record(context);
                onTap!.call();
              },
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: radius,
            boxShadow: [
              BoxShadow(
                color: isFront
                    ? scheme.primary.withValues(alpha: 0.22)
                    : Colors.black.withValues(alpha: 0.45),
                blurRadius: isFront ? 30 : 18,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: radius,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (game?.coverUrl != null)
                  CachedNetworkImage(
                    imageUrl: ImageUtils.getLargeImageUrl(game!.coverUrl),
                    fit: BoxFit.cover,
                    placeholder: (_, __) =>
                        ColoredBox(color: scheme.surfaceContainerHigh),
                    errorWidget: (_, __, ___) =>
                        _Placeholder(rank: rank, isEmpty: false),
                  )
                else
                  _Placeholder(rank: rank, isEmpty: game == null),

                // The veil is what makes "further back" read as "further into
                // the dark" rather than merely smaller.
                AnimatedOpacity(
                  opacity: isFront ? 0 : 0.58,
                  duration: tokens.durationNormal,
                  curve: Curves.easeOutCubic,
                  child: ColoredBox(color: scheme.surface),
                ),

                if (sweepProgress > 0 && sweepProgress < 1)
                  IgnorePointer(
                    child: CustomPaint(
                      painter: LightSweepPainter(
                        colour: const Color(0xFFFFF1D2),
                        progress: sweepProgress,
                      ),
                    ),
                  ),

                Positioned(
                  left: numeralOnOuterRight ? null : tokens.spaceSm,
                  right: numeralOnOuterRight ? tokens.spaceSm : null,
                  top: tokens.spaceXs,
                  // Rank 1 keeps its gold numeral wherever it stands, so
                  // cycling never reads as a re-ranking.
                  child: ExcludeSemantics(
                    child: Text(
                      '$rank',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: rank == 1 ? scheme.primary : Colors.white,
                        shadows: const [
                          Shadow(blurRadius: 8, color: Color(0xCC000000)),
                        ],
                      ),
                    ),
                  ),
                ),

                if (title != null && isFront)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: _TitleScrim(title: title, rating: game?.totalRating),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.rank, required this.isEmpty});

  final int rank;
  final bool isEmpty;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return CustomPaint(
      painter: _EmptySlotPainter(
        colour: scheme.primary,
        background: scheme.surfaceContainer,
        dashed: isEmpty,
      ),
      child: Center(
        child: ExcludeSemantics(
          child: Icon(
            isEmpty ? Icons.add_rounded : Icons.videogame_asset_outlined,
            color: scheme.onSurfaceVariant,
            size: rank == 1 ? 32 : 24,
          ),
        ),
      ),
    );
  }
}

/// An unfilled place: dark, with the icon's grain washing up from the bottom,
/// so it reads as waiting rather than broken.
class _EmptySlotPainter extends CustomPainter {
  const _EmptySlotPainter({
    required this.colour,
    required this.background,
    required this.dashed,
  });

  final Color colour;
  final Color background;
  final bool dashed;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..color = background);
    GGDither.paintGradient(
      canvas,
      rect,
      LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [colour.withValues(alpha: 0.30), colour.withValues(alpha: 0)],
      ),
    );
  }

  @override
  bool shouldRepaint(_EmptySlotPainter oldDelegate) =>
      oldDelegate.colour != colour ||
      oldDelegate.background != background ||
      oldDelegate.dashed != dashed;
}

class _TitleScrim extends StatelessWidget {
  const _TitleScrim({required this.title, this.rating});

  final String title;
  final double? rating;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.ggTokens;
    return Container(
      padding: EdgeInsets.all(tokens.spaceSm),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            theme.colorScheme.surface.withValues(alpha: 0.92),
            theme.colorScheme.surface.withValues(alpha: 0),
          ],
        ),
      ),
      child: ExcludeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleSmall,
            ),
            if (rating != null)
              Text(
                (rating! / 10).toStringAsFixed(1).replaceAll('.', ','),
                style: theme.textTheme.labelMedium
                    ?.copyWith(color: theme.colorScheme.primary)
                    .tabular,
              ),
          ],
        ),
      ),
    );
  }
}
