// ==================================================
// GAME DESCRIPTION SECTION - ACCORDION VERSION
// ==================================================

// lib/presentation/pages/game_detail/widgets/game_description_section.dart
import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../domain/entities/game/game.dart';

class GameDescriptionSection extends StatefulWidget {
  final Game game;

  const GameDescriptionSection({
    super.key,
    required this.game,
  });

  @override
  State<GameDescriptionSection> createState() => _GameDescriptionSectionState();
}

class _GameDescriptionSectionState extends State<GameDescriptionSection> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    // Nur rendern wenn Summary vorhanden
    if (widget.game.summary == null || widget.game.summary!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      child: Card(
        elevation: 0,
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
        child: Column(
          children: [
            // ✅ Accordion Header
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => setState(() => _isExpanded = !_isExpanded),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.paddingMedium),
                  child: Row(
                    children: [
                      // Icon
                      Icon(
                        Icons.description,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),

                      // Title - ✅ Mit Overflow-Fix
                      Expanded(
                        child: Text(
                          'About ${widget.game.name}',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      const SizedBox(width: 8),

                      // Expand/Collapse Icon
                      AnimatedRotation(
                        turns: _isExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: const Icon(Icons.keyboard_arrow_down),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ✅ Expandable Content
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppConstants.paddingMedium,
                  0,
                  AppConstants.paddingMedium,
                  AppConstants.paddingMedium,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Main Summary
                    Text(
                      widget.game.summary!,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        height: 1.6,
                      ),
                    ),

                    // Storyline (if available)
                    if (widget.game.storyline != null && widget.game.storyline!.isNotEmpty) ...[
                      const SizedBox(height: AppConstants.paddingMedium),
                      _buildStorylineSection(),
                    ],
                  ],
                ),
              ),
              crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 200),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Storyline als eigene Expansion (Nested Accordion)
  Widget _buildStorylineSection() {
    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
      ),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(top: 8),
        title: Row(
          children: [
            Icon(
              Icons.auto_stories,
              size: 18,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'Read Full Storyline',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        children: [
          Text(
            widget.game.storyline!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}