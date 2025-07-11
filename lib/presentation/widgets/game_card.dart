// presentation/widgets/game_card.dart
import 'dart:ui'; // 🆕 NEW: For BackdropFilter
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gamer_grove/core/utils/colorSchemes.dart';
import '../../domain/entities/game/game.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/utils/image_utils.dart';
import '../../core/widgets/cached_image_widget.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';

class GameCard extends StatelessWidget {
  final Game game;
  final VoidCallback onTap;
  final bool blurRated; // 🆕 NEW: Blur rated games feature

  const GameCard({
    super.key,
    required this.game,
    required this.onTap,
    this.blurRated = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover Image Section with Overlay Info
            Expanded(
              flex: 4,
              child: _buildCoverSection(context),
            ),

            // Bottom Info Section
            Expanded(
              flex: 2,
              child: _buildInfoSection(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoverSection(BuildContext context) {
    final isRated = _isGameRated();
    final shouldBlurCover = blurRated && isRated;

    return Stack(
      fit: StackFit.expand,
      children: [
        // Cover Image
        CachedImageWidget(
          imageUrl: ImageUtils.getMediumImageUrl(game.coverUrl),
          fit: BoxFit.cover,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
          ),
        ),

        // 🆕 Blur Filter for rated games (simple overlay)
        if (shouldBlurCover)
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
              ),
            ),
          ),

        // Community Rating (bottom left)
        if (game.totalRating != null)
          Positioned(
            bottom: 8,
            left: 8,
            child: _buildRatingChip(
              context,
              icon: Icons.star_outline,
              rating: game.totalRating!,
              isUserRating: false,
            ),
          ),

        // User Rating (bottom right)
        if (game.userRating != null)
          Positioned(
            bottom: 8,
            right: 8,
            child: _buildRatingChip(
              context,
              icon: Icons.star,
              rating: game.userRating! * 10,
              isUserRating: true,
            ),
          ),
      ],
    );
  }

  Widget _buildInfoSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Game Title
          Expanded(
            flex: 3,
            child: FittedBox(
              child: Text(
                game.name,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),

          const SizedBox(height: 4),

          // Release Date and Genres Row
          Expanded(
            flex: 2,
            child: Row(
              children: [
                // Release Date
                if (game.firstReleaseDate != null) ...[
                  Text(
                    DateFormatter.formatYearOnly(game.firstReleaseDate!),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (game.genres.isNotEmpty) ...[
                    Text(
                      ' • ',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color:
                        Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],

                // Genres
                if (game.genres.isNotEmpty)
                  Expanded(
                    child: Text(
                      game.genres.take(2).map((g) => g.name).join(', '),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color:
                        Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 4),

          Expanded(
              flex: 3,
              child: _buildQuickStateIndicators(context))
        ],
      ),
    );
  }

  Widget _buildRatingChip(
      BuildContext context, {
        required IconData icon,
        required double rating,
        required bool isUserRating,
      }) {
    final ratingColor = ColorScales.getRatingColor(rating);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: ratingColor.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ratingColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: ratingColor.onColor,
          ),
          const SizedBox(width: 3),
          Text(
            rating.toStringAsFixed(1),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: ratingColor.onColor,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStateIndicators(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        if (game.isWishlisted) ...[
          _buildStateIcon(
            context,
            icon: Icons.favorite,
            color: Colors.red,
            size: 16,
          ),
        ],
        if (game.isRecommended) ...[
          _buildStateIcon(
            context,
            icon: Icons.thumb_up,
            color: Colors.green,
            size: 16,
          ),
        ],
        if (game.isInTopThree ?? false) _buildTopThreeCrown(context),
      ],
    );
  }

  Widget _buildStateIcon(
      BuildContext context, {
        required IconData icon,
        required Color color,
        required double size,
      }) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Icon(
        icon,
        size: size,
        color: color,
      ),
    );
  }

  Widget _buildTopThreeCrown(BuildContext context) {
    final position = game.topThreePosition ?? 1;
    final crownColor = ColorScales.getTopThreeColor(position);

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: crownColor,
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          boxShadow: [
            BoxShadow(
              color: crownColor.withValues(alpha: 0.4),
              offset: const Offset(0, 2),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.emoji_events,
              color: crownColor.onColor,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              '#$position',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: crownColor.onColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🆕 NEW: Helper method to check if game is rated
  bool _isGameRated() {
    return game.userRating != null && game.userRating! > 0;
  }
}

// Shimmer Loading Version
class GameCardShimmer extends StatelessWidget {
  const GameCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cover Image Shimmer
          Expanded(
            flex: 4,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
            ),
          ),

          // Info Section Shimmer
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Rating chips shimmer
                  Row(
                    children: [
                      Container(
                        width: 50,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 60,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Genres shimmer
                  Container(
                    width: 80,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}