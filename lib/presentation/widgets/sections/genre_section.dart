// ==================================================
// GENRE SECTION
// ==================================================
import '../../../domain/entities/game/game.dart';
import 'package:flutter/material.dart';

// lib/presentation/pages/game_detail/widgets/sections/genre_section.dart

class GenreSection extends StatelessWidget {
  final Game game;

  const GenreSection({
    super.key,
    required this.game,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Genres
        if (_hasThemesOrKeywords()) ...[
          _buildThemesKeywordsSection(context),
        ],
      ],
    );
  }

  bool _hasThemesOrKeywords() {
    return game.themes.isNotEmpty || game.keywords.isNotEmpty;
  }

  // ✅ ENHANCED THEMES & KEYWORDS SECTION - MIT BOTTOM SHEET
  Widget _buildThemesKeywordsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          children: [
            Icon(
              Icons.label,
              size: 18,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'Themes & Tags',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (game.genres.isNotEmpty) ...[
          _buildExpandableTagSection(
            context,
            'Genres',
            game.genres.map((genre) => genre.name).toList(),
            Colors.blue,
            Icons.bookmarks,
          ),
        ],

        // Themes
        if (game.themes.isNotEmpty) ...[
          if (game.themes.isNotEmpty) const SizedBox(height: 12),
          _buildExpandableTagSection(
            context,
            'Themes',
            game.themes.map((theme) => theme).toList(),
            Colors.deepPurple,
            Icons.palette,
          ),
        ],

        // Keywords
        if (game.keywords.isNotEmpty) ...[
          if (game.keywords.isNotEmpty) const SizedBox(height: 12),
          _buildExpandableTagSection(
            context,
            'Keywords',
            game.keywords.map((keyword) => keyword.name).toList(),
            Colors.teal,
            Icons.tag,
          ),
        ],
      ],
    );
  }

  // ✅ EXPANDABLE TAG SECTION - MIT BOTTOM SHEET
  Widget _buildExpandableTagSection(
    BuildContext context,
    String title,
    List<String> tags,
    Color color,
    IconData icon,
  ) {
    const int maxDisplayed = 8;
    final bool hasMore = tags.length > maxDisplayed;
    tags.sort((a, b) => a.compareTo(b));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sub-header
        Row(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Tags (first few)
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            // Display first tags
            ...tags.take(maxDisplayed).map((tag) => Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: color.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    tag,
                    style: TextStyle(
                      fontSize: 11,
                      color: color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )),

            // ✅ SHOW ALL BUTTON
            if (hasMore)
              InkWell(
                onTap: () =>
                    _showTagsBottomSheet(context, title, tags, color, icon),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: color.withOpacity(0.5),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.add,
                        size: 12,
                        color: color,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${tags.length - maxDisplayed} more',
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
          ],
        ),
      ],
    );
  }

  // ✅ TAGS BOTTOM SHEET
  void _showTagsBottomSheet(
    BuildContext context,
    String title,
    List<String> tags,
    Color color,
    IconData icon,
  ) {
    showModalBottomSheet(
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
                            'All $title',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            '${tags.length} ${title.toLowerCase()}',
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

              // Tags Grid
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: tags
                        .map((tag) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: color.withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                tag,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: color,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
