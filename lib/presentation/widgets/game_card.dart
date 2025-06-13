// presentation/widgets/game_card.dart
import 'package:flutter/material.dart';
import '../../domain/entities/game.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/utils/image_utils.dart';
import '../../core/widgets/cached_image_widget.dart';
import 'custom_shimmer.dart';

class GameCard extends StatelessWidget {
  final Game game;
  final VoidCallback onTap;
  final VoidCallback? onWishlistTap;
  final bool showGenres;
  final bool showPlatforms;
  final bool showRating;

  const GameCard({
    super.key,
    required this.game,
    required this.onTap,
    this.onWishlistTap,
    this.showGenres = true,
    this.showPlatforms = true,
    this.showRating = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: AppConstants.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Game Cover Image
            Expanded(
              flex: 3,
              child: _buildCoverImage(context),
            ),

            // Game Information
            Expanded(
              flex: 2,
              child: _buildGameInfo(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoverImage(BuildContext context) {
    return Stack(
      children: [
        // Cover Image
        Positioned.fill(
          child: CachedImageWidget(
            imageUrl: ImageUtils.getMediumImageUrl(game.coverUrl),
            fit: BoxFit.cover,
            placeholder: _buildImagePlaceholder(context),
            errorWidget: _buildImageError(context),
          ),
        ),

        // Platform Icons (Top Right)
        if (showPlatforms && game.platforms.isNotEmpty)
          Positioned(
            top: AppConstants.paddingSmall,
            right: AppConstants.paddingSmall,
            child: _buildPlatformBadge(context),
          ),

        // Wishlist Button (Bottom Right)
        if (onWishlistTap != null)
          Positioned(
            bottom: AppConstants.paddingSmall,
            right: AppConstants.paddingSmall,
            child: _buildWishlistButton(context),
          ),

        // Rating Badge (Bottom Left)
        if (showRating && game.rating != null)
          Positioned(
            bottom: AppConstants.paddingSmall,
            left: AppConstants.paddingSmall,
            child: _buildRatingBadge(context),
          ),

        // Release Date Badge (Top Left)
        if (game.releaseDate != null)
          Positioned(
            top: AppConstants.paddingSmall,
            left: AppConstants.paddingSmall,
            child: _buildReleaseDateBadge(context),
          ),
      ],
    );
  }

  Widget _buildImagePlaceholder(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: CustomShimmer(
        child: Container(
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildImageError(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.gamepad_rounded,
            size: 40,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 8),
          Text(
            'No Image',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlatformBadge(BuildContext context) {
    final platformNames = game.platforms.take(3).map((p) => p.abbreviation).toList();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.devices,
            size: 12,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            platformNames.join(', '),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildWishlistButton(BuildContext context) {
    return GestureDetector(
      onTap: onWishlistTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: game.isWishlisted
              ? Theme.of(context).colorScheme.primary
              : Colors.black.withOpacity(0.7),
          shape: BoxShape.circle,
          border: Border.all(
            color: game.isWishlisted
                ? Theme.of(context).colorScheme.primary
                : Colors.white.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Icon(
          game.isWishlisted ? Icons.favorite : Icons.favorite_outline,
          size: 16,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildRatingBadge(BuildContext context) {
    final rating = game.rating!;
    final color = _getRatingColor(rating);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.9),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star_rounded,
            size: 12,
            color: Colors.white,
          ),
          const SizedBox(width: 2),
          Text(
            rating.toStringAsFixed(0),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReleaseDateBadge(BuildContext context) {
    final releaseDate = game.releaseDate!;
    final isUpcoming = DateFormatter.isFutureDate(releaseDate);
    final now = DateTime.now();
    final daysDifference = releaseDate.difference(now).inDays;

    // Don't show badge for very old games (more than 2 years old)
    if (!isUpcoming && now.difference(releaseDate).inDays > 730) {
      return const SizedBox.shrink();
    }

    // Show "NEW" for games released within the last 6 months
    final isNew = !isUpcoming && now.difference(releaseDate).inDays <= 180;

    if (!isUpcoming && !isNew) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: isUpcoming
            ? Colors.orange.withOpacity(0.9)
            : Colors.green.withOpacity(0.9),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        isUpcoming
            ? (daysDifference < 30 ? 'SOON' : 'UPCOMING')
            : 'NEW',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildGameInfo(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.paddingSmall),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Game Title
          Text(
            game.name,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 4),

          // Genres
          if (showGenres && game.genres.isNotEmpty)
            Text(
              game.genres.take(2).map((g) => g.name).join(' • '),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

          const Spacer(),

          // Bottom Row: Rating & Release Date
          Row(
            children: [
              // Detailed Rating
              if (game.rating != null) ...[
                Icon(
                  Icons.star_rounded,
                  size: 14,
                  color: _getRatingColor(game.rating!),
                ),
                const SizedBox(width: 2),
                Text(
                  '${game.rating!.toStringAsFixed(1)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _getRatingColor(game.rating!),
                  ),
                ),
                if (game.ratingCount != null) ...[
                  Text(
                    ' (${_formatRatingCount(game.ratingCount!)})',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ] else ...[
                Text(
                  'Not rated',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],

              const Spacer(),

              // Release Year
              if (game.releaseDate != null)
                Text(
                  DateFormatter.formatYearOnly(game.releaseDate!),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getRatingColor(double rating) {
    if (rating >= 80) return Colors.green;
    if (rating >= 70) return Colors.lightGreen;
    if (rating >= 60) return Colors.orange;
    if (rating >= 50) return Colors.deepOrange;
    return Colors.red;
  }

  String _formatRatingCount(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    }
    return count.toString();
  }
}

// Compact version for lists
class CompactGameCard extends StatelessWidget {
  final Game game;
  final VoidCallback onTap;
  final VoidCallback? onWishlistTap;

  const CompactGameCard({
    super.key,
    required this.game,
    required this.onTap,
    this.onWishlistTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingSmall),
          child: Row(
            children: [
              // Cover Image
              SizedBox(
                width: 60,
                height: 80,
                child: CachedImageWidget(
                  imageUrl: ImageUtils.getSmallImageUrl(game.coverUrl),
                  fit: BoxFit.cover,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),

              const SizedBox(width: AppConstants.paddingSmall),

              // Game Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      game.name,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (game.genres.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        game.genres.take(2).map((g) => g.name).join(', '),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (game.rating != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.star_rounded,
                            size: 14,
                            color: Colors.amber,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            game.rating!.toStringAsFixed(1),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Wishlist Button
              if (onWishlistTap != null)
                IconButton(
                  onPressed: onWishlistTap,
                  icon: Icon(
                    game.isWishlisted ? Icons.favorite : Icons.favorite_outline,
                    color: game.isWishlisted
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}