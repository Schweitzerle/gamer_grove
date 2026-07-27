import 'package:flutter/material.dart';
import 'package:gamer_grove/presentation/widgets/game_card/card_badges.dart';
import 'package:gamer_grove/presentation/widgets/game_card/card_user_states.dart';

/// A person's states down one edge of a cover.
///
/// The card draws this twice: the reader's own down the right edge, and — when
/// looking at someone else's grove — theirs down the left. Those were two
/// near-identical methods before; the only thing that ever differed was the
/// edge and where the data came from.
class CardBadgeColumn extends StatelessWidget {
  const CardBadgeColumn({
    required this.states,
    required this.alignment,
    super.key,
  });

  final CardUserStates states;

  /// Which edge the column runs down.
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final rating = states.rating;
    final position = states.topThreePosition;
    final isLeft = alignment == Alignment.centerLeft;

    final badges = <Widget>[
      if (rating != null) RatingBadge.user(rating),
      if (position != null) TopThreeBadge(position),
      if (states.isWishlisted) const StateBadge.wishlisted(),
      if (states.isRecommended) const StateBadge.recommended(),
    ];

    return Positioned(
      top: 4,
      left: isLeft ? 4 : null,
      right: isLeft ? null : 4,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < badges.length; i++) ...[
            if (i > 0) const SizedBox(height: 4),
            badges[i],
          ],
        ],
      ),
    );
  }
}
