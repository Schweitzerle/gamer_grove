import 'package:flutter/material.dart';
import 'package:gamer_grove/domain/entities/game/game.dart';
import 'package:gamer_grove/presentation/widgets/sections/related_games/related_games_accordion.dart';
import 'package:gamer_grove/presentation/widgets/sections/related_games/related_games_tab.dart';

/// The same game, made again or moved somewhere else.
class VersionsRemakesSection extends StatelessWidget {
  const VersionsRemakesSection({required this.game, super.key});

  final Game game;

  @override
  Widget build(BuildContext context) {
    return RelatedGamesAccordion(
      title: 'Versions & Remakes',
      icon: Icons.auto_fix_high,
      accent: Colors.blue,
      gameName: game.name,
      tabs: tabs,
    );
  }

  /// The tabs this section contributes, derived from the game alone.
  List<RelatedGamesTab> get tabs => [
        if (game.remakes.isNotEmpty)
          RelatedGamesTab(
            label: 'Remakes',
            heading: 'Remakes',
            blurb: 'Remade versions • ${game.remakes.length} remakes',
            emoji: '🔄',
            icon: Icons.refresh,
            accent: Colors.teal,
            games: game.remakes,
          ),
        if (game.remasters.isNotEmpty)
          RelatedGamesTab(
            label: 'Remasters',
            heading: 'Remasters',
            blurb: 'Enhanced versions • ${game.remasters.length} remasters',
            emoji: '✨',
            icon: Icons.auto_fix_high,
            accent: Colors.cyan,
            games: game.remasters,
          ),
        if (game.ports.isNotEmpty)
          RelatedGamesTab(
            label: 'Ports',
            heading: 'Platform Ports',
            blurb: 'Platform versions • ${game.ports.length} ports',
            emoji: '📱',
            icon: Icons.devices,
            accent: Colors.brown,
            games: game.ports,
          ),
        if (game.expandedGames.isNotEmpty)
          RelatedGamesTab(
            label: 'Expanded',
            heading: 'Expanded Games',
            blurb: 'Enhanced editions • ${game.expandedGames.length} games',
            emoji: '🔍',
            icon: Icons.zoom_out_map,
            accent: Colors.deepOrange,
            games: game.expandedGames,
          ),
        if (game.versionParent != null)
          RelatedGamesTab(
            label: 'Original',
            heading: 'Original Version',
            blurb: 'Original version • 1 game',
            emoji: '📜',
            icon: Icons.source,
            accent: Colors.indigo,
            games: [game.versionParent!],
          ),
      ];
}
