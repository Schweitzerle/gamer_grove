// ==================================================
// GAME INFORMATION SECTION - FÜR ACCORDION
// ==================================================

// lib/presentation/widgets/sections/game_info_section.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_constants.dart';
import '../../../domain/entities/game/game.dart';

class GameInfoSection extends StatelessWidget {
  final Game game;

  const GameInfoSection({
    super.key,
    required this.game,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ✅ VERSION & TYPE INFO
        if (_hasVersionOrTypeInfo())
          _buildVersionTypeSection(context),

        // ✅ ALTERNATIVE NAMES
        if (game.alternativeNames.isNotEmpty) ...[
          if (_hasVersionOrTypeInfo()) const SizedBox(height: 20),
          _buildAlternativeNamesSection(context),
        ],

        // ✅ GAME ENGINES
        if (game.gameEngines.isNotEmpty) ...[
          if (_hasVersionOrTypeInfo() || game.alternativeNames.isNotEmpty)
            const SizedBox(height: 20),
          _buildGameEnginesSection(context),
        ],

        // ✅ OFFICIAL WEBSITE
        if (game.url != null && game.url!.isNotEmpty) ...[
          if (_hasAnyPreviousSection()) const SizedBox(height: 20),
          _buildOfficialWebsiteSection(context),
        ],
      ],
    );
  }

  // ✅ VERSION & TYPE SECTION
  Widget _buildVersionTypeSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          children: [
            Icon(
              Icons.info_outline,
              size: 18,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'Game Details',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Badges Row
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            // Game Type Badge
            if (game.gameType != null)
              _buildInfoBadge(
                context,
                label: game.gameType!.name,
                icon: _getTypeIcon(game.gameType!.name),
                color: _getTypeColor(game.gameType!.name),
              ),

            // Game Status Badge
            if (game.gameStatus != null)
              _buildInfoBadge(
                context,
                label: game.gameStatus!.name,
                icon: _getStatusIcon(game.gameStatus!.name),
                color: _getStatusColor(game.gameStatus!.name),
              ),
          ],
        ),

        // Version Title (falls vorhanden)
        if (game.versionTitle != null && game.versionTitle!.isNotEmpty) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.stars,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  game.versionTitle!,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontStyle: FontStyle.italic,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  // ✅ ALTERNATIVE NAMES SECTION
  Widget _buildAlternativeNamesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          children: [
            Icon(
              Icons.translate,
              size: 18,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'Also known as',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Alternative Names Chips
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: game.alternativeNames.map((name) => Chip(
            label: Text(
              name,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
            side: BorderSide(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            visualDensity: VisualDensity.compact,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          )).toList(),
        ),
      ],
    );
  }

  // ✅ GAME ENGINES SECTION
  Widget _buildGameEnginesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          children: [
            Icon(
              Icons.settings,
              size: 18,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'Built with',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Game Engines List
        Column(
          children: game.gameEngines.map((engine) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.precision_manufacturing,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        engine.name,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (engine.description != null && engine.description!.isNotEmpty)
                        Text(
                          engine.description!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          )).toList(),
        ),
      ],
    );
  }

  // ✅ OFFICIAL WEBSITE SECTION
  Widget _buildOfficialWebsiteSection(BuildContext context) {
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
              'Official Website',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Website Button
        Container(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _launchWebsite(game.url!),
            icon: const Icon(Icons.open_in_new, size: 18),
            label: const Text('Visit Official Website'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              side: BorderSide(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ✅ INFO BADGE WIDGET
  Widget _buildInfoBadge(
      BuildContext context, {
        required String label,
        required IconData icon,
        required Color color,
      }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            _formatLabel(label),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // ✅ HELPER METHODS

  bool _hasVersionOrTypeInfo() {
    return game.gameType != null ||
        game.gameStatus != null ||
        (game.versionTitle != null && game.versionTitle!.isNotEmpty);
  }

  bool _hasAnyPreviousSection() {
    return _hasVersionOrTypeInfo() ||
        game.alternativeNames.isNotEmpty ||
        game.gameEngines.isNotEmpty;
  }

  String _formatLabel(String label) {
    // Convert snake_case und camelCase zu readable format
    return label
        .replaceAll('_', ' ')
        .replaceAllMapped(RegExp(r'([a-z])([A-Z])'), (match) => '${match[1]} ${match[2]}')
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  // ✅ TYPE HELPERS
  IconData _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'main_game': case 'maingame': return Icons.videogame_asset;
      case 'dlc_addon': case 'dlcaddon': return Icons.extension;
      case 'expansion': return Icons.add_box;
      case 'bundle': return Icons.inventory_2;
      case 'standalone_expansion': case 'standaloneexpansion': return Icons.launch;
      case 'mod': return Icons.build;
      case 'remake': return Icons.refresh;
      case 'remaster': return Icons.auto_fix_high;
      case 'port': return Icons.phonelink;
      default: return Icons.category;
    }
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'main_game': case 'maingame': return Colors.blue;
      case 'dlc_addon': case 'dlcaddon': return Colors.purple;
      case 'expansion': return Colors.indigo;
      case 'bundle': return Colors.green;
      case 'standalone_expansion': case 'standaloneexpansion': return Colors.teal;
      case 'mod': return Colors.orange;
      case 'remake': return Colors.cyan;
      case 'remaster': return Colors.lightBlue;
      case 'port': return Colors.amber;
      default: return Colors.grey;
    }
  }

  // ✅ STATUS HELPERS
  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'released': return Icons.check_circle;
      case 'alpha': return Icons.science;
      case 'beta': return Icons.bug_report;
      case 'early_access': case 'earlyaccess': return Icons.preview;
      case 'cancelled': return Icons.cancel;
      case 'rumored': return Icons.help_outline;
      case 'delisted': return Icons.remove_circle;
      default: return Icons.info_outline;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'released': return Colors.green;
      case 'alpha': return Colors.orange;
      case 'beta': return Colors.amber;
      case 'early_access': case 'earlyaccess': return Colors.blue;
      case 'cancelled': return Colors.red;
      case 'rumored': return Colors.grey;
      case 'delisted': return Colors.red.shade300;
      default: return Colors.grey;
    }
  }

  // ✅ WEBSITE LAUNCHER
  Future<void> _launchWebsite(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}