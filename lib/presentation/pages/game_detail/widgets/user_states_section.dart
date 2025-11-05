// ==================================================
// ENHANCED USER STATES CONTENT - With UserGameDataBloc Integration
// ==================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamer_grove/core/utils/colorSchemes.dart';
import 'package:gamer_grove/domain/entities/game/game.dart';
import 'package:gamer_grove/presentation/blocs/auth/auth_bloc.dart';
import 'package:gamer_grove/presentation/blocs/auth/auth_state.dart';
import 'package:gamer_grove/presentation/blocs/game/game_bloc.dart';
import 'package:gamer_grove/presentation/blocs/user_game_data/user_game_data_bloc.dart'
    as user_data;
import 'package:gamer_grove/presentation/widgets/rating_dialog.dart';
import 'package:gamer_grove/presentation/widgets/top_three_dialog.dart';

import '../../../../injection_container.dart';

class UserStatesContent extends StatelessWidget {
  final Game game;

  const UserStatesContent({
    super.key,
    required this.game,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ Watch UserGameDataBloc for reactive updates
    return BlocBuilder<user_data.UserGameDataBloc, user_data.UserGameDataState>(
      builder: (context, userDataState) {
        // Extract user-specific data from global state
        // 🔄 Fallback to Game entity data if UserGameDataBloc is not loaded yet
        bool isWishlisted = game.isWishlisted;
        bool isRecommended = game.isRecommended;
        double? userRating = game.userRating;
        bool isInTopThree = game.isInTopThree;
        int? topThreePosition = game.topThreePosition;

        // Override with UserGameDataBloc data if available
        if (userDataState is user_data.UserGameDataLoaded) {
          isWishlisted = userDataState.isWishlisted(game.id);
          isRecommended = userDataState.isRecommended(game.id);
          userRating = userDataState.getRating(game.id);
          isInTopThree = userDataState.isInTopThree(game.id);
          topThreePosition = userDataState.getTopThreePosition(game.id);

          print(
              '🎯 UserStatesContent: Using UserGameDataBloc data for game ${game.id}');
          print(
              '   Wishlisted: $isWishlisted, Recommended: $isRecommended, Rating: $userRating');
        } else {
          print(
              '🎯 UserStatesContent: Using Game entity data (UserGameDataBloc state: ${userDataState.runtimeType})');
          print(
              '   Wishlisted: $isWishlisted, Recommended: $isRecommended, Rating: $userRating');
        }

        return Column(
          children: [
            // First Row
            Row(
              children: [
                // User Rating Card
                Expanded(
                  child: _buildMediumInfoCard(
                    context,
                    icon: userRating != null ? Icons.star : Icons.star_outline,
                    label: 'Rate',
                    value: userRating != null
                        ? '${(userRating * 10).toStringAsFixed(1)}/10'
                        : 'Rate it',
                    color: userRating != null
                        ? ColorScales.getRatingColor(userRating * 10)
                        : Colors.grey,
                    isActive: userRating != null,
                    onTap: () => _showRatingDialog(context, userRating),
                  ),
                ),

                const SizedBox(width: 8),

                // Wishlist Card
                Expanded(
                  child: _buildMediumInfoCard(
                    context,
                    icon:
                        isWishlisted ? Icons.favorite : Icons.favorite_outline,
                    label: 'Wishlist',
                    value: isWishlisted ? 'Added' : 'Add',
                    color: isWishlisted ? Colors.red : Colors.grey,
                    isActive: isWishlisted,
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
                    icon: isRecommended
                        ? Icons.thumb_up
                        : Icons.thumb_up_outlined,
                    label: 'Recommend',
                    value: isRecommended ? 'Recommended' : 'Recommend',
                    color: isRecommended ? Colors.green : Colors.grey,
                    isActive: isRecommended,
                    onTap: () => _toggleRecommend(context),
                  ),
                ),

                const SizedBox(width: 8),

                // Top Three Card
                Expanded(
                  child: _buildMediumInfoCard(
                    context,
                    icon: isInTopThree
                        ? Icons.emoji_events
                        : Icons.emoji_events_outlined,
                    label: 'Top 3',
                    value: isInTopThree
                        ? '#${topThreePosition ?? 1}'
                        : 'Add to Top 3',
                    color: isInTopThree
                        ? ColorScales.getTopThreeColor(topThreePosition ?? 1)
                        : Colors.grey,
                    isActive: isInTopThree,
                    onTap: () => _showTopThreeDialog(context, userDataState),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  // ✅ UPDATED FUNCTIONS - Using UserGameDataBloc

  String? _getCurrentUserId(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
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

    // ✅ Use UserGameDataBloc instead of GameBloc
    final userDataBloc = context.read<user_data.UserGameDataBloc>();
    final userDataState = userDataBloc.state;

    // Get current state before toggle
    final isCurrentlyWishlisted = userDataState is user_data.UserGameDataLoaded
        ? userDataState.isWishlisted(game.id)
        : false;

    userDataBloc.add(
      user_data.ToggleWishlistEvent(
        gameId: game.id,
        userId: userId,
      ),
    );

    HapticFeedback.lightImpact();

    // Show feedback
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

    // ✅ Use UserGameDataBloc instead of GameBloc
    final userDataBloc = context.read<user_data.UserGameDataBloc>();
    final userDataState = userDataBloc.state;

    // Get current state before toggle
    final isCurrentlyRecommended = userDataState is user_data.UserGameDataLoaded
        ? userDataState.isRecommended(game.id)
        : false;

    userDataBloc.add(
      user_data.ToggleRecommendationEvent(
        gameId: game.id,
        userId: userId,
      ),
    );

    HapticFeedback.lightImpact();

    // Show feedback
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

  void _showTopThreeDialog(
      BuildContext context, user_data.UserGameDataState userDataState) {
    final userId = _getCurrentUserId(context);
    if (userId == null) {
      _showLoginRequiredSnackBar(context);
      return;
    }

    // ✅ Get both blocs
    final userDataBloc = context.read<user_data.UserGameDataBloc>();
    final gameBloc = sl<GameBloc>();

    // Get current top three game IDs from the bloc state
    List<int> currentTopThreeIds = [];
    if (userDataState is user_data.UserGameDataLoaded) {
      currentTopThreeIds = userDataState.topThreeGameIds;
    }

    showDialog<void>(
      context: context,
      builder: (dialogContext) => TopThreeDialog(
        game: game,
        gameBloc: gameBloc, // ✅ Pass GameBloc for dialog compatibility
        currentTopThree: null, // Dialog will load from backend if null
        onPositionSelected: (position) {
          _updateTopThree(userDataBloc, userId, position, currentTopThreeIds);
        },
      ),
    );
  }

  void _showRatingDialog(BuildContext context, double? currentRating) {
    final userId = _getCurrentUserId(context);
    if (userId == null) {
      _showLoginRequiredSnackBar(context);
      return;
    }

    // ✅ Get UserGameDataBloc
    final userDataBloc = context.read<user_data.UserGameDataBloc>();

    showDialog<void>(
      context: context,
      builder: (dialogContext) => RatingDialog(
        gameName: game.name,
        currentRating: currentRating,
        onRatingSubmitted: (rating) {
          _rateGame(userDataBloc, userId, rating);
        },
      ),
    );
  }

  void _rateGame(
      user_data.UserGameDataBloc userDataBloc, String userId, double rating) {
    userDataBloc.add(user_data.RateGameEvent(
      gameId: game.id,
      userId: userId,
      rating: rating,
    ));

    HapticFeedback.lightImpact();
  }

  void _updateTopThree(
    user_data.UserGameDataBloc userDataBloc,
    String userId,
    int position,
    List<int> currentTopThreeIds,
  ) {
    // Create updated list with new game at specified position
    final updatedList = List<int>.from(currentTopThreeIds);

    // Remove the game if it's already in the list
    updatedList.remove(game.id);

    // Insert at the specified position (1-indexed to 0-indexed)
    final index = position - 1;
    if (index >= 0 && index <= 2) {
      if (index >= updatedList.length) {
        updatedList.add(game.id);
      } else {
        updatedList.insert(index, game.id);
      }

      // Keep only first 3 games
      if (updatedList.length > 3) {
        updatedList.removeRange(3, updatedList.length);
      }
    }

    userDataBloc.add(user_data.UpdateTopThreeEvent(
      userId: userId,
      gameIds: updatedList,
    ));

    HapticFeedback.lightImpact();
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
