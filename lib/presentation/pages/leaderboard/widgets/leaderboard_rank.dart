import 'package:flutter/material.dart';
import 'package:gamer_grove/core/theme/gg_contrast.dart';
import 'package:gamer_grove/core/theme/gg_tokens.dart';

/// A place on the leaderboard, worn on the avatar.
///
/// It used to be a 50-px column beside the row. On a 320-dp screen that column,
/// the list's padding, the card's own margin and a 64-px avatar left the name
/// **no width at all** and pushed the follow button 30 px past the edge. A rank
/// is a property of the person, so it belongs on them rather than in a lane of
/// its own.
class LeaderboardRank extends StatelessWidget {
  const LeaderboardRank({required this.rank, super.key});

  final int rank;

  /// Medal colours are read as gold, silver and bronze or not at all, so they
  /// are fixed rather than themed — the same reasoning as the brand colours in
  /// `BrandColors`. Legibility is restored per surface by `legibleOn`.
  static const gold = Color(0xFFD4A017);
  static const silver = Color(0xFF9EA7AD);
  static const bronze = Color(0xFFCD7F32);

  static Color medalFor(int rank) => switch (rank) {
        1 => gold,
        2 => silver,
        3 => bronze,
        _ => const Color(0xFF7C8A86),
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final tokens = context.ggTokens;
    final surface = scheme.surfaceContainerHighest;

    return Semantics(
      label: 'Rank $rank',
      child: ExcludeSemantics(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: tokens.spaceSm,
            vertical: tokens.spaceXs / 2,
          ),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(tokens.radiusPill),
            border: Border.all(color: scheme.surface, width: 2),
          ),
          child: Text(
            '#$rank',
            style: theme.textTheme.labelMedium?.copyWith(
              color: medalFor(rank).legibleOn(surface, minimum: 4.5),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
