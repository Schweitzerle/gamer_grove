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

  Color _getGameAccentColor(BuildContext context) {
    // Use primary color or customize based on game category
    return Theme.of(context).colorScheme.primary;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main Summary (enhanced)
        if (game.summary != null && game.summary!.isNotEmpty) ...[
          Stack(
            children: [
              // Main content container with gradient background
              Container(
                constraints: const BoxConstraints(
                  maxHeight: 200,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _getGameAccentColor(context).withOpacity(0.05),
                      _getGameAccentColor(context).withOpacity(0.08),
                      _getGameAccentColor(context).withOpacity(0.10),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _getGameAccentColor(context).withOpacity(0.2),
                    width: 1.5,
                  ),
                ),
                child: Stack(
                  children: [
                    // Scrollable text
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Decorative quote icon
                          Icon(
                            Icons.format_quote,
                            size: 24,
                            color: _getGameAccentColor(context).withOpacity(0.3),
                          ),
                          const SizedBox(height: 8),
                          // Summary text
                          Text(
                            game.summary!,
                            style:
                                Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      height: 1.6,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                      fontStyle: FontStyle.italic,
                                      letterSpacing: 0.2,
                                    ),
                          ),
                          const SizedBox(height: 8),
                          // Closing quote
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Icon(
                              Icons.format_quote,
                              size: 24,
                              color:
                                  _getGameAccentColor(context).withOpacity(0.3),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Bottom fade effect
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: 40,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Theme.of(context)
                                  .colorScheme
                                  .surface
                                  .withOpacity(0.8),
                            ],
                          ),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Scroll indicator hint
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getGameAccentColor(context).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.swipe_vertical,
                        size: 12,
                        color: _getGameAccentColor(context).withOpacity(0.6),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Scroll',
                        style: TextStyle(
                          fontSize: 10,
                          color: _getGameAccentColor(context).withOpacity(0.6),
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
    final storylineColor = Colors.deepPurple;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            storylineColor.withOpacity(0.05),
            storylineColor.withOpacity(0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: storylineColor.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: storylineColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.auto_stories,
                  size: 20,
                  color: storylineColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Full Storyline',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: storylineColor,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Tap to read the complete story',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.6),
                            fontSize: 11,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Stack(
                children: [
                  // Main storyline container
                  Container(
                    constraints: const BoxConstraints(
                      maxHeight: 250,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .surface
                          .withOpacity(0.8),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: storylineColor.withOpacity(0.15),
                        width: 1,
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Scrollable storyline text
                        SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Opening book icon
                              Row(
                                children: [
                                  Icon(
                                    Icons.menu_book,
                                    size: 20,
                                    color: storylineColor.withOpacity(0.4),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Story',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          color: storylineColor.withOpacity(0.6),
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 1.2,
                                        ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              // Storyline text
                              Text(
                                game.storyline!,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      height: 1.7,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                      letterSpacing: 0.1,
                                    ),
                              ),
                              const SizedBox(height: 8),
                            ],
                          ),
                        ),
                        // Bottom fade effect
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          height: 40,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Theme.of(context)
                                      .colorScheme
                                      .surface
                                      .withOpacity(0.9),
                                ],
                              ),
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(10),
                                bottomRight: Radius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Scroll indicator
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: storylineColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.swipe_vertical,
                            size: 12,
                            color: storylineColor.withOpacity(0.6),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Scroll',
                            style: TextStyle(
                              fontSize: 10,
                              color: storylineColor.withOpacity(0.6),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
