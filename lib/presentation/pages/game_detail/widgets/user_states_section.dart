// ==================================================
// ENHANCED USER STATES CONTENT - With Integrated Functions
// ==================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamer_grove/core/utils/colorSchemes.dart';

import '../../../../domain/entities/game/game.dart';
import '../../../blocs/auth/auth_bloc.dart';
import '../../../blocs/game/game_bloc.dart';
import '../../../widgets/rating_dialog.dart';
import '../../../widgets/top_three_dialog.dart';

class UserStatesContent extends StatelessWidget {
  final Game game;

  const UserStatesContent({
    super.key,
    required this.game,
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
                onTap: () => _showRatingDialog(context),
              ),
            ),

            const SizedBox(width: 8),

            // Wishlist Card
            Expanded(
              child: _buildMediumInfoCard(
                context,
                icon: game.isWishlisted == true
                    ? Icons.favorite
                    : Icons.favorite_outline,
                label: 'Wishlist',
                value: game.isWishlisted == true ? 'Added' : 'Add',
                color: game.isWishlisted == true ? Colors.red : Colors.grey,
                isActive: game.isWishlisted == true,
                onTap: () => _toggleWishlist(context),
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
                icon: game.isRecommended == true
                    ? Icons.thumb_up
                    : Icons.thumb_up_outlined,
                label: 'Recommend',
                value: game.isRecommended == true ? 'Recommended' : 'Recommend',
                color: game.isRecommended == true ? Colors.green : Colors.grey,
                isActive: game.isRecommended == true,
                onTap: () => _toggleRecommend(context),
              ),
            ),

            const SizedBox(width: 8),

            // Top Three Card
            Expanded(
              child: _buildMediumInfoCard(
                context,
                icon: game.isInTopThree == true
                    ? Icons.emoji_events
                    : Icons.emoji_events_outlined,
                label: 'Top 3',
                value: game.isInTopThree == true
                    ? '#${game.topThreePosition ?? 1}'
                    : 'Add to Top 3',
                color: game.isInTopThree == true
                    ? ColorScales.getTopThreeColor(game.topThreePosition ?? 1)
                    : Colors.grey,
                isActive: game.isInTopThree == true,
                onTap: () => _showTopThreeDialog(context),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ✅ INTEGRATED FUNCTIONS

  String? _getCurrentUserId(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      return authState.user.id;
    }
    return null;
  }

  void _showLoginRequiredSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please log in to use this feature'),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _toggleWishlist(BuildContext context) {
    final userId = _getCurrentUserId(context);
    if (userId == null) {
      _showLoginRequiredSnackBar(context);
      return;
    }

    final gameBloc = context.read<GameBloc>();
    gameBloc.add(
      ToggleWishlistEvent(
        gameId: game.id,
        userId: userId,
      ),
    );

    HapticFeedback.lightImpact();

    // Show feedback
    final isCurrentlyWishlisted = game.isWishlisted == true;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isCurrentlyWishlisted
            ? 'Removed from wishlist'
            : 'Added to wishlist'),
        backgroundColor: isCurrentlyWishlisted ? Colors.grey : Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _toggleRecommend(BuildContext context) {
    final userId = _getCurrentUserId(context);
    if (userId == null) {
      _showLoginRequiredSnackBar(context);
      return;
    }

    final gameBloc = context.read<GameBloc>();
    gameBloc.add(
      ToggleRecommendEvent(
        gameId: game.id,
        userId: userId,
      ),
    );

    HapticFeedback.lightImpact();

    // Show feedback
    final isCurrentlyRecommended = game.isRecommended == true;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isCurrentlyRecommended
            ? 'Recommendation removed'
            : 'Game recommended'),
        backgroundColor: isCurrentlyRecommended ? Colors.grey : Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showTopThreeDialog(BuildContext context) {
    final userId = _getCurrentUserId(context);
    if (userId == null) {
      _showLoginRequiredSnackBar(context);
      return;
    }

    // ✅ GameBloc VOR dem Dialog holen
    final gameBloc = context.read<GameBloc>();

    showDialog(
      context: context,
      builder: (context) => TopThreeDialog(
        game: game,
        onPositionSelected: (position) {
          _addToTopThree(gameBloc, userId, position);
        },
      ),
    );
  }

  void _showRatingDialog(BuildContext context) {
    final userId = _getCurrentUserId(context);
    if (userId == null) {
      _showLoginRequiredSnackBar(context);
      return;
    }

    // ✅ GameBloc VOR dem Dialog holen
    final gameBloc = context.read<GameBloc>();

    showDialog(
      context: context,
      builder: (context) => RatingDialog(
        gameName: game.name,
        currentRating: game.userRating,
        onRatingSubmitted: (rating) {
          _rateGame(gameBloc, userId, rating);
        },
      ),
    );
  }

  void _rateGame(GameBloc gameBloc, String userId, double rating) {
    gameBloc.add(RateGameEvent(
      gameId: game.id,
      userId: userId,
      rating: rating,
    ));

    HapticFeedback.lightImpact();
    // Note: SnackBar wird im Parent Context angezeigt, nicht im Dialog Context
  }

  void _addToTopThree(GameBloc gameBloc, String userId, int position) {
    gameBloc.add(AddToTopThreeEvent(
      gameId: game.id,
      userId: userId,
      position: position,
    ));

    HapticFeedback.lightImpact();
    // Note: SnackBar wird im Parent Context angezeigt, nicht im Dialog Context
  }

  // ✅ Medium-sized Info Card (unchanged)
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
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.7),
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
