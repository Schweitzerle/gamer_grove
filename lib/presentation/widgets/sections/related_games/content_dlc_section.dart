import 'package:flutter/material.dart';
import 'package:gamer_grove/core/utils/navigations.dart';
import 'package:gamer_grove/domain/entities/game/game.dart';
import 'package:gamer_grove/presentation/widgets/sections/related_games/related_games_accordion.dart';
import 'package:gamer_grove/presentation/widgets/sections/related_games/related_games_tab.dart';

/// Everything released on top of the game itself.
class ContentDLCSection extends StatelessWidget {
  const ContentDLCSection({required this.game, super.key});

  final Game game;

  @override
  Widget build(BuildContext context) {
    return RelatedGamesAccordion(
      title: 'Additional Content',
      icon: Icons.extension,
      accent: Colors.green,
      gameName: game.name,
      tabs: tabs,
    );
  }

  /// The tabs this section contributes, derived from the game alone.
  List<RelatedGamesTab> get tabs => [
        if (game.dlcs.isNotEmpty)
          RelatedGamesTab(
            label: 'DLCs',
            heading: 'Downloadable Content',
            blurb: 'Additional content • ${game.dlcs.length} DLCs',
            emoji: '⬇️',
            icon: Icons.download,
            accent: Colors.green,
            games: game.dlcs,
            onViewAll: (context) =>
                Navigations.navigateToGameDLCs(context, game.name, game.dlcs),
          ),
        if (game.expansions.isNotEmpty)
          RelatedGamesTab(
            label: 'Expansions',
            heading: 'Expansions',
            blurb: 'Game expansions • ${game.expansions.length} expansions',
            emoji: '📦',
            icon: Icons.expand_more,
            accent: Colors.teal,
            games: game.expansions,
            onViewAll: (context) => Navigations.navigateToGameExpansions(
              context,
              game.name,
              game.expansions,
            ),
          ),
        if (game.standaloneExpansions.isNotEmpty)
          RelatedGamesTab(
            label: 'Standalone',
            heading: 'Standalone Expansions',
            blurb: 'Standalone content • '
                '${game.standaloneExpansions.length} games',
            emoji: '🚀',
            icon: Icons.launch,
            accent: Colors.indigo,
            games: game.standaloneExpansions,
          ),
        if (game.bundles.isNotEmpty)
          RelatedGamesTab(
            label: 'Bundles',
            heading: 'Game Bundles',
            blurb: 'Game collections • ${game.bundles.length} bundles',
            emoji: '📋',
            icon: Icons.inventory,
            accent: Colors.orange,
            games: game.bundles,
          ),
      ];
}
