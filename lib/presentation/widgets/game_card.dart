// presentation/widgets/game_card.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/entities/game.dart';
import 'custom_shimmer.dart';

class GameCard extends StatelessWidget {
  final Game game;
  final VoidCallback onTap;
  final VoidCallback? onWishlistTap;

  const GameCard({
    super.key,
    required this.game,
    required this.onTap,
    this.onWishlistTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Background & Cover
              Positioned.fill(
                child: game.coverUrl != null
                    ? CachedNetworkImage(
                  imageUrl: game.coverUrl!,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => CustomShimmer(
                    child: Container(
                      color: Colors.grey,
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: Icon(
                      Icons.gamepad_rounded,
                      size: 50,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
                    : Container(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: Icon(
                    Icons.gamepad_rounded,
                    size: 50,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              // Gradient Overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                        Colors.black.withOpacity(0.9),
                      ],
                      stops: const [0.0, 0.5, 0.8, 1.0],
                    ),
                  ),
                ),
              ),
              // Content
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title
                    Text(
                      game.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Genres
                    if (game.genres.isNotEmpty)
                      Text(
                        game.genres.take(2).map((g) => g.name).join(', '),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white70,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 8),
                    // Bottom Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Rating
                        if (game.rating != null)
                          _buildRating(context, game.rating!)
                        else
                          const SizedBox.shrink(),
                        // Wishlist Button
                        _buildWishlistButton(context),
                      ],
                    ),
                  ],
                ),
              ),
              // Platform Icons
              if (game.platforms.isNotEmpty)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: _buildPlatformIcons(),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRating(BuildContext context, double rating) {
    final ratingColor = _getRatingColor(rating);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: ratingColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: ratingColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star_rounded,
            size: 16,
            color: ratingColor,
          ),
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
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
              : Colors.white.withOpacity(0.2),
          shape: BoxShape.circle,
          border: Border.all(
            color: game.isWishlisted
                ? Theme.of(context).colorScheme.primary
                : Colors.white.withOpacity(0.5),
            width: 1.5,
          ),
        ),
        child: Icon(
          game.isWishlisted ? Icons.favorite : Icons.favorite_outline,
          size: 18,
          color: game.isWishlisted
              ? Colors.white
              : Colors.white.withOpacity(0.9),
        ),
      ),
    );
  }

  List<Widget> _buildPlatformIcons() {
    final icons = <Widget>[];
    final platformTypes = <String>{};

    for (final platform in game.platforms.take(3)) {
      String iconType = '';
      if (platform.name.toLowerCase().contains('playstation')) {
        iconType = 'playstation';
      } else if (platform.name.toLowerCase().contains('xbox')) {
        iconType = 'xbox';
      } else if (platform.name.toLowerCase().contains('nintendo') ||
          platform.name.toLowerCase().contains('switch')) {
        iconType = 'nintendo';
      } else if (platform.name.toLowerCase().contains('pc') ||
          platform.name.toLowerCase().contains('windows')) {
        iconType = 'pc';
      }

      if (iconType.isNotEmpty && !platformTypes.contains(iconType)) {
        platformTypes.add(iconType);
        icons.add(_getPlatformIcon(iconType));
        if (icons.length < game.platforms.length && icons.length < 3) {
          icons.add(const SizedBox(width: 4));
        }
      }
    }

    return icons;
  }

  Widget _getPlatformIcon(String type) {
    IconData icon;
    switch (type) {
      case 'playstation':
        icon = Icons.sports_esports; // PlayStation icon placeholder
        break;
      case 'xbox':
        icon = Icons.sports_esports_outlined; // Xbox icon placeholder
        break;
      case 'nintendo':
        icon = Icons.videogame_asset; // Nintendo icon placeholder
        break;
      case 'pc':
        icon = Icons.computer;
        break;
      default:
        icon = Icons.devices;
    }

    return Icon(
      icon,
      size: 16,
      color: Colors.white,
    );
  }

  Color _getRatingColor(double rating) {
    if (rating >= 80) {
      return Colors.green;
    } else if (rating >= 60) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}

