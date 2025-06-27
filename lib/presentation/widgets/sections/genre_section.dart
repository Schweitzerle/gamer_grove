// ==================================================
// GENRE SECTION
// ==================================================
import '../../../../../domain/entities/game.dart';
import 'package:flutter/material.dart';


// lib/presentation/pages/game_detail/widgets/sections/genre_section.dart
import 'package:flutter/material.dart';
import '../../../../../domain/entities/game.dart';

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
        if (game.genres.isNotEmpty) ...[
          Text(
            'Genres',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: game.genres.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Chip(
                    label: Text(game.genres[index].name),
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  ),
                );
              },
            ),
          ),
        ],

        // Themes
        if (game.themes.isNotEmpty) ...[
          if (game.genres.isNotEmpty) const SizedBox(height: 16),
          Text(
            'Themes',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: game.themes.map((category) {
              return Chip(
                label: Text(
                  category,
                  style: const TextStyle(fontSize: 12),
                ),
                backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
              );
            }).toList(),
          ),
        ],

        // Keywords
        if (game.keywords.isNotEmpty) ...[
          if (game.genres.isNotEmpty || game.themes.isNotEmpty)
            const SizedBox(height: 16),
          Row(
            children: [
              Text(
                'Keywords',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${game.keywords.length}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 35,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: game.keywords.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Chip(
                    label: Text(
                      game.keywords[index].name,
                      style: const TextStyle(fontSize: 11),
                    ),
                    backgroundColor: Theme.of(context).colorScheme.outline.withOpacity(0.1),
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                      width: 0.5,
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}
