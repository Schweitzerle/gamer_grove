// ==================================================
// ENHANCED GAME FEATURES SECTION - MIT BOTTOM SHEETS
// ==================================================

// lib/presentation/widgets/sections/enhanced_expandable_game_features_section.dart
import 'package:flutter/material.dart';
import '../../../domain/entities/game/game.dart';
import '../../../core/utils/navigations.dart';

class GameFeaturesSection extends StatelessWidget {
  final Game game;

  const GameFeaturesSection({
    super.key,
    required this.game,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ✅ GAMEPLAY FEATURES SECTION
        if (_hasGameplayFeatures()) _buildGameplayFeaturesSection(context),

        // ✅ MULTIPLAYER DETAILS SECTION
        if (game.multiplayerModes.isNotEmpty) ...[
          if (_hasGameplayFeatures()) const SizedBox(height: 20),
          _buildMultiplayerSection(context),
        ],

        // ✅ LANGUAGE SUPPORT SECTION
        if (game.languageSupports.isNotEmpty) ...[
          if (_hasGameplayFeatures() || game.multiplayerModes.isNotEmpty)
            const SizedBox(height: 20),
          _buildLanguageSection(context),
        ],

        // ✅ LOCALIZATION SECTION
        if (game.gameLocalizations.isNotEmpty) ...[
          if (_hasAnyPreviousSection()) const SizedBox(height: 20),
          _buildLocalizationSection(context),
        ],
      ],
    );
  }

  // ✅ GAMEPLAY FEATURES SECTION (unchanged)
  Widget _buildGameplayFeaturesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          children: [
            Icon(
              Icons.gamepad,
              size: 18,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'Gameplay Features',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Features Grid
        Column(
          children: [
            // Game Modes & Player Perspectives Row
            if (game.gameModes.isNotEmpty || game.playerPerspectives.isNotEmpty)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Game Modes
                  if (game.gameModes.isNotEmpty)
                    Expanded(
                      child: _buildGameModesCard(context),
                    ),

                  if (game.gameModes.isNotEmpty &&
                      game.playerPerspectives.isNotEmpty)
                    const SizedBox(width: 12),

                  // Player Perspectives
                  if (game.playerPerspectives.isNotEmpty)
                    Expanded(
                      child: _buildPlayerPerspectivesCard(context),
                    ),
                ],
              ),
          ],
        ),
      ],
    );
  }

  // ✅ CLICKABLE GAME MODES CARD
  Widget _buildGameModesCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.blue.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.sports_esports, size: 16, color: Colors.blue),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Game Modes',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.blue,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Clickable Items
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: game.gameModes
                .map((mode) => InkWell(
                      onTap: () => Navigations.navigateToGameModeGames(
                        context,
                        gameModeId: mode.id,
                        gameModeName: mode.name,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.blue.withOpacity(0.2),
                          ),
                        ),
                        child: Text(
                          mode.name,
                          style: const TextStyle(fontSize: 11),
                        ),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  // ✅ CLICKABLE PLAYER PERSPECTIVES CARD
  Widget _buildPlayerPerspectivesCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.green.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.visibility, size: 16, color: Colors.green),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Perspectives',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Clickable Items
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: game.playerPerspectives
                .map((perspective) => InkWell(
                      onTap: () => Navigations.navigateToPlayerPerspectiveGames(
                        context,
                        perspectiveId: perspective.id,
                        perspectiveName: perspective.name,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.green.withOpacity(0.2),
                          ),
                        ),
                        child: Text(
                          perspective.name,
                          style: const TextStyle(fontSize: 11),
                        ),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  // ✅ MULTIPLAYER SECTION (unchanged)
  Widget _buildMultiplayerSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          children: [
            Icon(
              Icons.group,
              size: 18,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'Multiplayer Features',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Multiplayer Cards
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: game.multiplayerModes
              .map((mode) => Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.purple.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Mode Type
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.purple.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(
                                Icons.people,
                                size: 16,
                                color: Colors.purple,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Multiplayer Mode',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.purple,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Mode Details
                        if (mode.onlineMax > 1)
                          _buildModeDetail(context, Icons.wifi,
                              'Online: Up to ${mode.onlineMax} players'),
                        if (mode.offlineMax > 1)
                          _buildModeDetail(context, Icons.home,
                              'Local: Up to ${mode.offlineMax} players'),
                        if (mode.onlineCoop)
                          _buildModeDetail(
                              context, Icons.handshake, 'Online Co-op'),
                        if (mode.offlineCoop)
                          _buildModeDetail(
                              context, Icons.people_alt, 'Local Co-op'),
                        if (mode.splitscreen)
                          _buildModeDetail(
                              context, Icons.splitscreen, 'Split-screen'),
                      ],
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }

  // ✅ ENHANCED LANGUAGE SECTION - MIT BOTTOM SHEET
  Widget _buildLanguageSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          children: [
            Icon(
              Icons.language,
              size: 18,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'Language Support',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Group languages by support type
        _buildEnhancedLanguageSupport(context),
      ],
    );
  }

  Widget _buildEnhancedLanguageSupport(BuildContext context) {
    // Group languages by support type
    final interfaceLanguages = <String>[];
    final audioLanguages = <String>[];
    final subtitleLanguages = <String>[];

    for (final support in game.languageSupports) {
      final langName = support.language?.displayName ?? 'Unknown';

      if (support.hasInterfaceSupport) interfaceLanguages.add(langName);
      interfaceLanguages.sort((a, b) => a.compareTo(b));
      if (support.hasAudioSupport) audioLanguages.add(langName);
      audioLanguages.sort((a, b) => a.compareTo(b));
      if (support.hasSubtitles) subtitleLanguages.add(langName);
      subtitleLanguages.sort((a, b) => a.compareTo(b));
    }

    return Column(
      children: [
        // Interface Languages
        if (interfaceLanguages.isNotEmpty)
          _buildExpandableLanguageTypeCard(
            context,
            'Interface',
            Icons.settings,
            interfaceLanguages,
            Colors.orange,
          ),

        if (interfaceLanguages.isNotEmpty &&
            (audioLanguages.isNotEmpty || subtitleLanguages.isNotEmpty))
          const SizedBox(height: 8),

        // Audio & Subtitles Row
        if (audioLanguages.isNotEmpty || subtitleLanguages.isNotEmpty)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Audio Languages
              if (audioLanguages.isNotEmpty)
                Expanded(
                  child: _buildExpandableLanguageTypeCard(
                    context,
                    'Audio',
                    Icons.volume_up,
                    audioLanguages,
                    Colors.green,
                  ),
                ),

              if (audioLanguages.isNotEmpty && subtitleLanguages.isNotEmpty)
                const SizedBox(width: 8),

              // Subtitle Languages
              if (subtitleLanguages.isNotEmpty)
                Expanded(
                  child: _buildExpandableLanguageTypeCard(
                    context,
                    'Subtitles',
                    Icons.subtitles,
                    subtitleLanguages,
                    Colors.blue,
                  ),
                ),
            ],
          ),
      ],
    );
  }

  // ✅ LOCALIZATION SECTION (unchanged)
  Widget _buildLocalizationSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          children: [
            Icon(
              Icons.public,
              size: 18,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'Regional Versions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Localization Cards
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: game.gameLocalizations
              .map((localization) => Chip(
                    avatar: Icon(
                      Icons.location_on,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    label: Text(
                      localization.name,
                      style: const TextStyle(fontSize: 12),
                    ),
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                    side: BorderSide(
                      color: Theme.of(context)
                          .colorScheme
                          .outline
                          .withOpacity(0.2),
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }

  // ✅ EXPANDABLE LANGUAGE TYPE CARD - MIT BOTTOM SHEET
  Widget _buildExpandableLanguageTypeCard(
    BuildContext context,
    String title,
    IconData icon,
    List<String> languages,
    Color color,
  ) {
    const int maxDisplayed = 6; // Zeige weniger an für bessere UX
    final bool hasMore = languages.length > maxDisplayed;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
              ),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${languages.length}',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Languages (first few)
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: languages
                .take(maxDisplayed)
                .map((lang) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: color.withOpacity(0.2),
                        ),
                      ),
                      child: Text(
                        lang,
                        style: const TextStyle(fontSize: 10),
                      ),
                    ))
                .toList(),
          ),

          // ✅ EXPANDABLE "SHOW ALL" BUTTON
          if (hasMore)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: InkWell(
                onTap: () => _showLanguageBottomSheet(
                    context, title, languages, color, icon),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: color.withOpacity(0.4),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.visibility,
                        size: 12,
                        color: color,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Show all ${languages.length}',
                        style: TextStyle(
                          fontSize: 11,
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ✅ LANGUAGE BOTTOM SHEET
  void _showLanguageBottomSheet(
    BuildContext context,
    String title,
    List<String> languages,
    Color color,
    IconData icon,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(icon, color: color, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$title Languages',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            '${languages.length} languages supported',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Languages List
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: languages.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final language = languages[index];
                    return ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.language,
                          color: color,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        language,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      trailing: Icon(
                        Icons.check_circle,
                        color: color,
                        size: 20,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ HELPER WIDGETS (unchanged)
  Widget _buildFeatureCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<String> items,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, size: 16, color: color),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Items
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: items
                .map((item) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: color.withOpacity(0.2),
                        ),
                      ),
                      child: Text(
                        item,
                        style: const TextStyle(fontSize: 11),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildModeDetail(BuildContext context, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.purple),
          const SizedBox(width: 6),
          Text(
            text,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  // ✅ HELPER METHODS (unchanged)
  bool _hasGameplayFeatures() {
    return game.gameModes.isNotEmpty || game.playerPerspectives.isNotEmpty;
  }

  bool _hasAnyPreviousSection() {
    return _hasGameplayFeatures() ||
        game.multiplayerModes.isNotEmpty ||
        game.languageSupports.isNotEmpty;
  }
}
