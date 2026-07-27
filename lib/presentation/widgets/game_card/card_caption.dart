import 'package:flutter/material.dart';
import 'package:gamer_grove/core/utils/date_formatter.dart';
import 'package:gamer_grove/domain/entities/game/game.dart';
import 'package:gamer_grove/presentation/widgets/game_card/card_scrim.dart';

/// Title, year and genres along the foot of a cover.
class CardCaption extends StatelessWidget {
  const CardCaption({required this.game, super.key});

  final Game game;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final released = game.firstReleaseDate;

    return Positioned(
      left: 6,
      // Clear of the badge column down the right edge.
      right: 50,
      bottom: 6,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            game.name,
            style: text.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: CardScrim.paper,
              fontSize: 14,
              shadows: CardScrim.textShadow,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              if (released != null) ...[
                Icon(
                  Icons.calendar_today,
                  size: 10,
                  color: CardScrim.paper.withAlpha(230),
                ),
                const SizedBox(width: 2),
                Text(
                  DateFormatter.formatYearOnly(released),
                  style: text.bodySmall?.copyWith(
                    color: CardScrim.paper.withAlpha(230),
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (game.genres.isNotEmpty)
                  Text(
                    ' • ',
                    style: text.bodySmall?.copyWith(
                      color: CardScrim.paper.withValues(alpha: 0.7),
                      fontSize: 10,
                    ),
                  ),
              ],
              if (game.genres.isNotEmpty)
                Expanded(
                  child: Text(
                    game.genres.take(2).map((g) => g.name).join(', '),
                    style: text.bodySmall?.copyWith(
                      color: CardScrim.paper.withAlpha(204),
                      fontSize: 10,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
