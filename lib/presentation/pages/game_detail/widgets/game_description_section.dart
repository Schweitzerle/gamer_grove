// ==================================================
// GAME DESCRIPTION CONTENT - Simplified for Accordion
// ==================================================

import 'package:flutter/material.dart';

import '../../../../domain/entities/game/game.dart';

class GameDescriptionContent extends StatelessWidget {
  final Game game;

  const GameDescriptionContent({
    super.key,
    required this.game,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main Summary
        if (game.summary != null && game.summary!.isNotEmpty) ...[
          Text(
            game.summary!,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              height: 1.6,
            ),
          ),
        ],

        // Storyline (if available)
        if (game.storyline != null && game.storyline!.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildStorylineSection(context),
        ],
      ],
    );
  }

  // ✅ Storyline als eigene Expansion (Nested Accordion)
  Widget _buildStorylineSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.auto_stories,
                  size: 18,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Read Full Storyline',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          children: [
            Text(
              game.storyline!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}