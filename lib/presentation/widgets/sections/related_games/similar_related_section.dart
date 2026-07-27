import 'package:flutter/material.dart';
import 'package:gamer_grove/core/utils/navigations.dart';
import 'package:gamer_grove/domain/entities/game/game.dart';
import 'package:gamer_grove/presentation/widgets/sections/related_games/related_games_accordion.dart';
import 'package:gamer_grove/presentation/widgets/sections/related_games/related_games_tab.dart';

/// Where to go next, and where this game came from.
class SimilarRelatedSection extends StatelessWidget {
  const SimilarRelatedSection({required this.game, super.key});

  final Game game;

  @override
  Widget build(BuildContext context) {
    return RelatedGamesAccordion(
      title: 'Similar & Related',
      icon: Icons.lightbulb_outline,
      accent: Colors.purple,
      gameName: game.name,
      tabs: tabs,
    );
  }

  /// The tabs this section contributes, derived from the game alone.
  List<RelatedGamesTab> get tabs => [
        if (game.similarGames.isNotEmpty)
          RelatedGamesTab(
            label: 'Similar',
            heading: 'Similar Games',
            blurb: 'Games you might like • '
                '${game.similarGames.length} games',
            emoji: '💡',
            icon: Icons.lightbulb_outline,
            accent: Colors.blue,
            games: game.similarGames,
            onViewAll: (context) => Navigations.navigateToSimilarGames(
              context,
              game.name,
              game.similarGames,
            ),
          ),
        if (game.forks.isNotEmpty)
          RelatedGamesTab(
            label: 'Forks',
            heading: 'Game Forks',
            blurb: 'Alternative versions • ${game.forks.length} forks',
            emoji: '🔀',
            icon: Icons.call_split,
            accent: Colors.red,
            games: game.forks,
          ),
        if (game.parentGame != null)
          RelatedGamesTab(
            label: 'Main Game',
            heading: 'Main Game',
            blurb: 'Base game • 1 game',
            emoji: '🏠',
            icon: Icons.home,
            accent: Colors.green,
            games: [game.parentGame!],
          ),
      ];
}
