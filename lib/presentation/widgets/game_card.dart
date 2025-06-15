// presentation/widgets/game_card.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/game.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/utils/image_utils.dart';
import '../../core/widgets/cached_image_widget.dart';
import '../blocs/game/game_bloc.dart';
import '../blocs/auth/auth_bloc.dart';
import 'custom_shimmer.dart';
import 'game_quick_actions_dialog.dart';

class GameCard extends StatelessWidget {
  final Game game;
  final VoidCallback onTap;
  final VoidCallback? onWishlistTap;
  final bool showGenres;
  final bool showPlatforms;
  final bool showRating;
  final bool showUserStates;
  final GameBloc? gameBloc; // Optional GameBloc for quick actions

  const GameCard({
    super.key,
    required this.game,
    required this.onTap,
    this.onWishlistTap,
    this.showGenres = true,
    this.showPlatforms = true,
    this.showRating = true,
    this.showUserStates = true,
    this.gameBloc,
  });

  void _showQuickActions(BuildContext context) {
    HapticFeedback.mediumImpact();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => GameQuickActionsDialog(
        game: game,
        gameBloc: gameBloc ?? context.read<GameBloc>(),
      ),
    );
  }

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
        onLongPress: () => _showQuickActions(context),
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

        // User States Overlay (Top Left)
        if (showUserStates)
          Positioned(
            top: AppConstants.paddingSmall,
            left: AppConstants.paddingSmall,
            child: _buildUserStatesOverlay(context),
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
      ],
    );
  }

  Widget _buildStateBadge(
      BuildContext context, {
        required IconData icon,
        String? label,
        required Color color,
      }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          if (label != null) ...[
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
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
          const Icon(
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
    final color = rating >= 8.0
        ? Colors.green
        : rating >= 6.0
        ? Colors.orange
        : Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.9),
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.star_rounded,
            size: 14,
            color: Colors.white,
          ),
          const SizedBox(width: 2),
          Text(
            rating.toStringAsFixed(1),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
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
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const Spacer(),

          // Genres
          if (showGenres && game.genres.isNotEmpty) ...[
            Text(
              game.genres.take(2).map((g) => g.name).join(', '),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],

          // Release Date
          if (game.releaseDate != null) ...[
            const SizedBox(height: 2),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  DateFormatter.formatYearOnly(game.releaseDate!),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildUserStatesOverlay(BuildContext context) {
    final states = <Widget>[];

    // User Rating - nur wenn vorhanden
    if (game.userRating != null) {
      states.add(_buildStateBadge(
        context,
        icon: Icons.star,
        label: game.userRating!.toStringAsFixed(1),
        color: Colors.amber,
      ));
    }

    // Recommended - nur wenn true
    if (game.isRecommended) {
      states.add(_buildStateBadge(
        context,
        icon: Icons.thumb_up,
        label: null,
        color: Colors.green,
      ));
    }

    // In Top 3 - nur wenn true
    if (game.isInTopThree ?? false) {
      final position = game.topThreePosition ?? 1;
      states.add(_buildStateBadge(
        context,
        icon: _getMedalIcon(position),
        label: '#$position',
        color: _getPositionColor(position),
      ));
    }

    // Zeige nichts wenn keine States vorhanden
    if (states.isEmpty) return const SizedBox.shrink();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < states.length; i++) ...[
          states[i],
          if (i < states.length - 1) const SizedBox(width: 4),
        ],
      ],
    );
  }

  IconData _getMedalIcon(int position) {
    switch (position) {
      case 1:
        return Icons.looks_one;
      case 2:
        return Icons.looks_two;
      case 3:
        return Icons.looks_3;
      default:
        return Icons.emoji_events;
    }
  }

  Color _getPositionColor(int position) {
    switch (position) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey[600]!;
      case 3:
        return Colors.brown[600]!;
      default:
        return Colors.grey;
    }
  }

}

// Compact version for lists
class CompactGameCard extends StatelessWidget {
  final Game game;
  final VoidCallback onTap;
  final VoidCallback? onWishlistTap;
  final GameBloc? gameBloc;

  const CompactGameCard({
    super.key,
    required this.game,
    required this.onTap,
    this.onWishlistTap,
    this.gameBloc,
  });

  void _showQuickActions(BuildContext context) {
    HapticFeedback.mediumImpact();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => GameQuickActionsDialog(
        game: game,
        gameBloc: gameBloc ?? context.read<GameBloc>(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        onLongPress: () => _showQuickActions(context),
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
                    // Title with user states
                    // In CompactGameCard, in der Row wo die User States angezeigt werden:
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            game.name,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Zeige User Rating Badge wenn vorhanden
                        if (game.userRating != null)
                          _buildCompactStateBadge(
                            context,
                            icon: Icons.star,
                            label: game.userRating!.toStringAsFixed(1),
                            color: Colors.amber,
                          ),
                        // Zeige Recommended Badge wenn recommended
                        if (game.isRecommended) ...[
                          const SizedBox(width: 4),
                          _buildCompactStateBadge(
                            context,
                            icon: Icons.thumb_up,
                            color: Colors.green,
                          ),
                        ],
                        // Zeige Top 3 Badge wenn in Top 3
                        if (game.isInTopThree ?? false) ...[
                          const SizedBox(width: 4),
                          _buildCompactStateBadge(
                            context,
                            icon: _getMedalIcon(game.topThreePosition ?? 1),
                            label: '#${game.topThreePosition ?? 1}',
                            color: _getPositionColor(game.topThreePosition ?? 1),
                          ),
                        ],
                      ],
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
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactStateBadge(
      BuildContext context, {
        required IconData icon,
        String? label,
        required Color color,
      }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          if (label != null) ...[
            const SizedBox(width: 2),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTopThreeBadge() {
    final position = game.topThreePosition ?? 1;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getPositionColor(position).withOpacity(0.9),
            _getPositionColor(position),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: _getPositionColor(position).withOpacity(0.5),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getMedalIcon(position),
            size: 16,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            '#$position',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getMedalIcon(int position) {
    switch (position) {
      case 1:
        return Icons.looks_one;
      case 2:
        return Icons.looks_two;
      case 3:
        return Icons.looks_3;
      default:
        return Icons.emoji_events;
    }
  }

  Color _getPositionColor(int position) {
    switch (position) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey[600]!;
      case 3:
        return Colors.brown[600]!;
      default:
        return Colors.grey;
    }
  }
}