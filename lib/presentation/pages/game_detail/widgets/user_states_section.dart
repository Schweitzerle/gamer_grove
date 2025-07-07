// ==================================================
// USER STATES CONTENT - Simplified for Accordion
// ==================================================

import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gamer_grove/core/utils/colorSchemes.dart';

import '../../../../domain/entities/game/game.dart';

class UserStatesContent extends StatelessWidget {
  final Game game;
  final VoidCallback? onRatePressed;
  final VoidCallback? onToggleWishlist;
  final VoidCallback? onToggleRecommend;
  final VoidCallback? onAddToTopThree;

  const UserStatesContent({
    super.key,
    required this.game,
    this.onRatePressed,
    this.onToggleWishlist,
    this.onToggleRecommend,
    this.onAddToTopThree,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // First Row
        Row(
          children: [
            // User Rating Card
            Expanded(
              child: _buildMediumInfoCard(
                context,
                icon: game.userRating != null ? Icons.star : Icons.star_outline,
                label: 'Rate',
                value: game.userRating != null
                    ? '${(game.userRating! * 10).toStringAsFixed(1)}/10'
                    : 'Rate it',
                color: game.userRating != null
                    ? ColorScales.getRatingColor(game.userRating! * 10)
                    : Colors.grey,
                isActive: game.userRating != null,
                onTap: onRatePressed,
              ),
            ),

            const SizedBox(width: 8),

            // Wishlist Card
            Expanded(
              child: _buildMediumInfoCard(
                context,
                icon: game.isWishlisted == true ? Icons.favorite : Icons.favorite_outline,
                label: 'Wishlist',
                value: game.isWishlisted == true ? 'Added' : 'Add',
                color: game.isWishlisted == true ? Colors.red : Colors.grey,
                isActive: game.isWishlisted == true,
                onTap: onToggleWishlist,
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Second Row
        Row(
          children: [
            // Recommend Card
            Expanded(
              child: _buildMediumInfoCard(
                context,
                icon: game.isRecommended == true ? Icons.thumb_up : Icons.thumb_up_outlined,
                label: 'Recommend',
                value: game.isRecommended == true ? 'Recommended' : 'Recommend',
                color: game.isRecommended == true ? Colors.green : Colors.grey,
                isActive: game.isRecommended == true,
                onTap: onToggleRecommend,
              ),
            ),

            const SizedBox(width: 8),

            // Top Three Card
            Expanded(
              child: _buildMediumInfoCard(
                context,
                icon: game.isInTopThree == true ? Icons.emoji_events : Icons.emoji_events_outlined,
                label: 'Top 3',
                value: game.isInTopThree == true
                    ? '#${game.topThreePosition ?? 1}'
                    : 'Add to Top 3',
                color: game.isInTopThree == true
                    ? ColorScales.getTopThreeColor(game.topThreePosition ?? 1)
                    : Colors.grey,
                isActive: game.isInTopThree == true,
                onTap: onAddToTopThree,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ✅ Medium-sized Info Card
  Widget _buildMediumInfoCard(
      BuildContext context, {
        required IconData icon,
        required String label,
        required String value,
        required Color color,
        required bool isActive,
        VoidCallback? onTap,
      }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isActive
                ? color.withOpacity(0.1)
                : Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isActive
                  ? color.withOpacity(0.3)
                  : Theme.of(context).colorScheme.outline.withOpacity(0.2),
              width: isActive ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isActive
                      ? color.withOpacity(0.2)
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  icon,
                  color: isActive ? color : Colors.grey,
                  size: 20,
                ),
              ),

              const SizedBox(height: 6),

              // Label
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                  fontSize: 11,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 3),

              // Value
              Text(
                value,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isActive ? color : Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}