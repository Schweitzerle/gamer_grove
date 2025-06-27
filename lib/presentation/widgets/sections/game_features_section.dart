// ==================================================
// GAME FEATURES SECTION (ERWEITERT FÜR NEUE API)
// ==================================================
import 'package:flutter/material.dart';
import '../../../domain/entities/game/game.dart';

class GameFeaturesSection extends StatelessWidget {
  final Game game;
  final bool showExtendedFeatures;

  const GameFeaturesSection({
    super.key,
    required this.game,
    this.showExtendedFeatures = false,
  });

  @override
  Widget build(BuildContext context) {
    final features = <Widget>[];

    // Game Modes
    if (game.gameModes.isNotEmpty) {
      features.add(_buildFeatureSection(
        context,
        'Game Modes',
        game.gameModes.map((m) => m.name).toList(),
        Icons.gamepad,
      ));
    }

    // Player Perspectives
    if (game.playerPerspectives.isNotEmpty) {
      features.add(_buildFeatureSection(
        context,
        'Perspectives',
        game.playerPerspectives.map((p) => p.name).toList(),
        Icons.visibility,
      ));
    }

    // Multiplayer Features (Erweitert)
    if (game.hasMultiplayer) {
      final multiplayerFeatures = <String>[];

      if (game.hasOnlineMultiplayer) {
        multiplayerFeatures.add('Online Multiplayer (${game.maxOnlinePlayers} players)');
      }
      if (game.hasLocalMultiplayer) {
        multiplayerFeatures.add('Local Multiplayer (${game.maxOfflinePlayers} players)');
      }
      if (game.hasCooperative) {
        multiplayerFeatures.add('Co-operative');
      }
      if (game.hasSplitScreen) {
        multiplayerFeatures.add('Split Screen');
      }

      if (multiplayerFeatures.isNotEmpty) {
        features.add(_buildFeatureSection(
          context,
          'Multiplayer',
          multiplayerFeatures,
          Icons.group,
        ));
      }
    }

    // Language Support
    if (game.hasMultipleLanguages) {
      final languageFeatures = <String>[];

      // Weitere Sprachen hinzufügen (max 5 anzeigen)
      final otherLanguages = game.supportedLanguages
          .where((lang) =>
      !lang.toLowerCase().contains('english') &&
          !lang.toLowerCase().contains('german'))
          .take(3)
          .toList();

      languageFeatures.addAll(otherLanguages);

      if (game.supportedLanguages.length > 5) {
        languageFeatures.add('+${game.supportedLanguages.length - 5} more');
      }

      features.add(_buildFeatureSection(
        context,
        'Languages (${game.supportedLanguages.length})',
        languageFeatures,
        Icons.language,
      ));
    }

    // Erweiterte Features (optional)
    if (showExtendedFeatures) {
      features.addAll(_buildExtendedFeatures(context));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: features,
    );
  }

  List<Widget> _buildExtendedFeatures(BuildContext context) {
    final features = <Widget>[];

    // Platform Availability
    final platformFeatures = <String>[];
    if (game.isAvailableOnPC) platformFeatures.add('PC');
    if (game.isAvailableOnConsoles) platformFeatures.add('Console');

    if (platformFeatures.isNotEmpty) {
      features.add(_buildFeatureSection(
        context,
        'Platform Types',
        platformFeatures,
        Icons.devices,
      ));
    }

    // Game Engines
    if (game.gameEngines.isNotEmpty) {
      features.add(_buildFeatureSection(
        context,
        'Game Engines',
        game.gameEngines.map((engine) => engine.name).toList(),
        Icons.settings,
      ));
    }

    // Special Game Types
    final specialFeatures = <String>[];
    if (game.isMMO) specialFeatures.add('MMO');
    if (game.isBattleRoyale) specialFeatures.add('Battle Royale');
    if (game.isDLC) specialFeatures.add('DLC/Expansion');
    if (game.isBundle) specialFeatures.add('Game Bundle');

    if (specialFeatures.isNotEmpty) {
      features.add(_buildFeatureSection(
        context,
        'Special Features',
        specialFeatures,
        Icons.star,
      ));
    }

    // Themes
    if (game.themes.isNotEmpty) {
      features.add(_buildFeatureSection(
        context,
        'Themes',
        game.themes.take(5).toList(), // Limit to 5 themes
        Icons.palette,
      ));
    }

    return features;
  }

  Widget _buildFeatureSection(
      BuildContext context,
      String title,
      List<String> items,
      IconData icon,
      ) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
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
                final isHighlighted = _isHighlightedFeature(item);

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isHighlighted
                        ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                        : Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                    border: isHighlighted
                        ? Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 1,
                    )
                        : null,
                  ),
                  child: Text(
                    item,
                    style: TextStyle(
                      color: isHighlighted
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onPrimaryContainer,
                      fontSize: 12,
                      fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.normal,
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

  /// Prüft ob ein Feature hervorgehoben werden soll
  bool _isHighlightedFeature(String feature) {
    final highlightKeywords = [
      'online multiplayer',
      'co-operative',
      'battle royale',
      'mmo',
      'english',
      'german',
      'pc',
    ];

    return highlightKeywords.any((keyword) =>
        feature.toLowerCase().contains(keyword));
  }
}

/// Kompakte Version für kleinere Spaces
class CompactGameFeaturesSection extends StatelessWidget {
  final Game game;
  final int maxFeatures;

  const CompactGameFeaturesSection({
    super.key,
    required this.game,
    this.maxFeatures = 3,
  });

  @override
  Widget build(BuildContext context) {
    final features = <String>[];

    // Wichtigste Features sammeln
    if (game.hasSinglePlayer) features.add('Single Player');
    if (game.hasMultiplayer) features.add('Multiplayer');
    if (game.hasCooperative) features.add('Co-op');
    if (game.isMMO) features.add('MMO');
    if (game.isBattleRoyale) features.add('Battle Royale');

    // Game Modes hinzufügen falls Platz
    if (features.length < maxFeatures) {
      final remainingSlots = maxFeatures - features.length;
      final additionalModes = game.gameModes
          .map((mode) => mode.name)
          .where((name) => !features.any((f) =>
          f.toLowerCase().contains(name.toLowerCase())))
          .take(remainingSlots)
          .toList();
      features.addAll(additionalModes);
    }

    if (features.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: features.take(maxFeatures).map((feature) =>
          Chip(
            label: Text(
              feature,
              style: const TextStyle(fontSize: 11),
            ),
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
      ).toList(),
    );
  }
}

/// Erweiterte Multiplayer Details Section
class MultiplayerDetailsSection extends StatelessWidget {
  final Game game;

  const MultiplayerDetailsSection({
    super.key,
    required this.game,
  });

  @override
  Widget build(BuildContext context) {
    if (!game.hasMultiplayer) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.group, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Multiplayer Details',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Multiplayer Modes Details
            ...game.multiplayerModes.map((mode) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.people,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (mode.onlineMax > 1)
                          Text('Online: Up to ${mode.onlineMax} players'),
                        if (mode.offlineMax > 1)
                          Text('Local: Up to ${mode.offlineMax} players'),
                        if (mode.onlineCoop || mode.offlineCoop)
                          const Text('Co-operative supported'),
                        if (mode.splitscreen)
                          const Text('Split-screen supported'),
                      ],
                    ),
                  ),
                ],
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }
}