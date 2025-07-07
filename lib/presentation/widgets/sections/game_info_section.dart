// ==================================================
// IMPROVED GAME INFORMATION SECTION - FÜR ACCORDION
// ==================================================

// lib/presentation/widgets/sections/game_info_section.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
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
        // ✅ VERSION & TYPE INFO CARDS
        if (_hasVersionOrTypeInfo())
          _buildVersionTypeSection(context),

        // ✅ ALTERNATIVE NAMES
        if (game.alternativeNames.isNotEmpty) ...[
          if (_hasVersionOrTypeInfo()) const SizedBox(height: 24),
          _buildAlternativeNamesSection(context),
        ],

        // ✅ OFFICIAL WEBSITE
        if (game.url != null && game.url!.isNotEmpty) ...[
          if (_hasAnyPreviousSection()) const SizedBox(height: 24),
          _buildOfficialWebsiteSection(context),
        ],
      ],
    );
  }

  // ✅ VERSION & TYPE SECTION - Modern Card Layout
  Widget _buildVersionTypeSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.info_outline,
                size: 18,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Game Details',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Info Cards
        _buildInfoCards(context),

        // Version Title (falls vorhanden)
        if (game.versionTitle != null && game.versionTitle!.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildVersionTitleCard(context),
        ],
      ],
    );
  }

  Widget _buildInfoCards(BuildContext context) {
    final List<Widget> cards = [];

    // Game Type Card
    if (game.gameType != null) {
      cards.add(_buildDetailCard(
        context,
        title: 'Type',
        value: _formatLabel(game.gameType!.name),
        icon: _getTypeIcon(game.gameType!.name),
        color: _getTypeColor(game.gameType!.name),
      ));
    }

    // Game Status Card
    if (game.gameStatus != null) {
      cards.add(_buildDetailCard(
        context,
        title: 'Status',
        value: _formatLabel(game.gameStatus!.name),
        icon: _getStatusIcon(game.gameStatus!.name),
        color: _getStatusColor(game.gameStatus!.name),
      ));
    }

    if (cards.isEmpty) return const SizedBox.shrink();

    // Layout depends on number of cards
    if (cards.length == 1) {
      return cards.first;
    } else {
      return Row(
        children: [
          Expanded(child: cards[0]),
          const SizedBox(width: 12),
          Expanded(child: cards[1]),
        ],
      );
    }
  }

  Widget _buildDetailCard(
      BuildContext context, {
        required String title,
        required String value,
        required IconData icon,
        required Color color,
      }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 18,
                  color: color,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVersionTitleCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primaryContainer.withOpacity(0.8),
            Theme.of(context).colorScheme.primaryContainer.withOpacity(0.4),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.stars_rounded,
              size: 20,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Special Edition',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  game.versionTitle!,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ✅ ALTERNATIVE NAMES SECTION - Improved Layout
  Widget _buildAlternativeNamesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.translate_rounded,
                size: 18,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Also known as',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Alternative Names Container
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: game.alternativeNames.map((name) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).shadowColor.withOpacity(0.05),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Text(
                name,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            )).toList(),
          ),
        ),
      ],
    );
  }

  // ✅ OFFICIAL WEBSITE SECTION - Modern Button Design
  Widget _buildOfficialWebsiteSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.tertiaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.language_rounded,
                size: 18,
                color: Theme.of(context).colorScheme.tertiary,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Official Website',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Website Button Card
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.tertiaryContainer.withOpacity(0.6),
                Theme.of(context).colorScheme.tertiaryContainer.withOpacity(0.3),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.tertiary.withOpacity(0.2),
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _launchWebsite(game.url!),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.tertiary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.open_in_new_rounded,
                        size: 24,
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Visit Official Website',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.tertiary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _formatUrl(game.url!),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: Theme.of(context).colorScheme.tertiary.withOpacity(0.7),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
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
        game.alternativeNames.isNotEmpty;
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

  String _formatUrl(String url) {
    // Remove protocol and www for cleaner display
    return url
        .replaceFirst(RegExp(r'^https?://'), '')
        .replaceFirst(RegExp(r'^www\.'), '');
  }

  // ✅ TYPE HELPERS
  IconData _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'main_game': case 'maingame': return Icons.videogame_asset_rounded;
      case 'dlc_addon': case 'dlcaddon': return Icons.extension_rounded;
      case 'expansion': return Icons.add_box_rounded;
      case 'bundle': return Icons.inventory_2_rounded;
      case 'standalone_expansion': case 'standaloneexpansion': return Icons.launch_rounded;
      case 'mod': return Icons.build_rounded;
      case 'remake': return Icons.refresh_rounded;
      case 'remaster': return Icons.auto_fix_high_rounded;
      case 'port': return Icons.phonelink_rounded;
      case 'episode': return Icons.play_arrow_rounded;
      case 'season': return Icons.calendar_view_week_rounded;
      default: return Icons.category_rounded;
    }
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'main_game': case 'maingame': return const Color(0xFF1976D2); // Blue
      case 'dlc_addon': case 'dlcaddon': return const Color(0xFF7B1FA2); // Purple
      case 'expansion': return const Color(0xFF303F9F); // Indigo
      case 'bundle': return const Color(0xFF388E3C); // Green
      case 'standalone_expansion': case 'standaloneexpansion': return const Color(0xFF00796B); // Teal
      case 'mod': return const Color(0xFFFF8F00); // Orange
      case 'remake': return const Color(0xFF0097A7); // Cyan
      case 'remaster': return const Color(0xFF0288D1); // Light Blue
      case 'port': return const Color(0xFFFFA000); // Amber
      case 'episode': return const Color(0xFF5D4037); // Brown
      case 'season': return const Color(0xFF455A64); // Blue Grey
      default: return const Color(0xFF757575); // Grey
    }
  }

  // ✅ STATUS HELPERS
  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'released': return Icons.check_circle_rounded;
      case 'alpha': return Icons.science_rounded;
      case 'beta': return Icons.bug_report_rounded;
      case 'early_access': case 'earlyaccess': return Icons.preview_rounded;
      case 'cancelled': return Icons.cancel_rounded;
      case 'rumored': return Icons.help_outline_rounded;
      case 'delisted': return Icons.remove_circle_rounded;
      case 'offline': return Icons.offline_bolt_rounded;
      default: return Icons.info_outline_rounded;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'released': return const Color(0xFF4CAF50); // Green
      case 'alpha': return const Color(0xFFFF8F00); // Orange
      case 'beta': return const Color(0xFFFFA000); // Amber
      case 'early_access': case 'earlyaccess': return const Color(0xFF2196F3); // Blue
      case 'cancelled': return const Color(0xFFF44336); // Red
      case 'rumored': return const Color(0xFF9E9E9E); // Grey
      case 'delisted': return const Color(0xFFE57373); // Light Red
      case 'offline': return const Color(0xFF795548); // Brown
      default: return const Color(0xFF757575); // Grey
    }
  }

  // ✅ WEBSITE LAUNCHER
  Future<void> _launchWebsite(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      // Handle error silently or show snackbar
      debugPrint('Could not launch $url: $e');
    }
  }
}