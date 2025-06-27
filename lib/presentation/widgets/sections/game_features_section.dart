// ==================================================
// GAME FEATURES SECTION
// ==================================================
import 'package:flutter/material.dart';
import '../../../../../domain/entities/game.dart';


class GameFeaturesSection extends StatelessWidget {
  final Game game;

  const GameFeaturesSection({
    super.key,
    required this.game,
  });

  @override
  Widget build(BuildContext context) {
    final features = <Widget>[];

    if (game.gameModes.isNotEmpty) {
      features.add(_buildFeatureSection(
        context,
        'Game Modes',
        game.gameModes.map((m) => m.name).toList(),
      ));
    }

    if (game.playerPerspectives.isNotEmpty) {
      features.add(_buildFeatureSection(
        context,
        'Perspectives',
        game.playerPerspectives.map((p) => p.name).toList(),
      ));
    }

    if (game.hasMultiplayer) {
      final multiplayerFeatures = <String>[];
      if (game.hasOnlineMultiplayer) multiplayerFeatures.add('Online Multiplayer');
      if (game.hasLocalMultiplayer) multiplayerFeatures.add('Local Multiplayer');
      features.add(_buildFeatureSection(context, 'Multiplayer', multiplayerFeatures));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: features,
    );
  }

  Widget _buildFeatureSection(BuildContext context, String title, List<String> items) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              alignment: WrapAlignment.start,
              crossAxisAlignment: WrapCrossAlignment.start,
              spacing: 8,
              runSpacing: 8,
              children: items.map((item) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    item,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontSize: 12,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

