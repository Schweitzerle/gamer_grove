import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:gamer_grove/core/utils/colorSchemes.dart';
import 'package:gamer_grove/core/utils/navigations.dart';
import 'package:gamer_grove/domain/entities/game/game.dart';
import 'package:gamer_grove/domain/entities/user_activity.dart';
import 'package:gamer_grove/presentation/widgets/game_card.dart';

class ActivityContent extends StatelessWidget {

  const ActivityContent(
      {required this.activity, required this.games, super.key,});
  final UserActivity activity;
  final List<Game> games;

  @override
  Widget build(BuildContext context) {
    switch (activity.activityType) {
      case 'rated':
        return _buildRatedContent(context);
      case 'recommended':
        return _buildRecommendedContent(context);
      case 'wishlisted':
        return _buildWishlistededContent(context);
      case 'updated_top_three':
        return _buildTopThreeContent(context);
      default:
        return const SizedBox();
    }
  }

  Widget _buildRatedContent(BuildContext context) {
    final game = games.firstWhereOrNull((g) => g.id == activity.gameId);
    if (game == null) return const SizedBox();

    final rating = (activity.metadata?['rating'] as num?)?.toDouble();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SizedBox(
          width: 160,
          child: AspectRatio(
            aspectRatio: 2 / 3,
            child: GameCard(
              game: game,
              onTap: () => Navigations.navigateToGameDetail(game.id, context),
            ),
          ),
        ),
        if (rating != null)
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: _buildUserRatingCircle(context, rating),
          ),
      ],
    );
  }

  Widget _buildRecommendedContent(BuildContext context) {
    final game = games.firstWhereOrNull((g) => g.id == activity.gameId);
    if (game == null) return const SizedBox();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SizedBox(
          width: 160,
          child: AspectRatio(
            aspectRatio: 2 / 3,
            child: GameCard(
              game: game,
              onTap: () => Navigations.navigateToGameDetail(game.id, context),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.green.withOpacity(0.2),
            ),
            child: const Icon(Icons.thumb_up, color: Colors.green, size: 28),
          ),
        ),
      ],
    );
  }

  Widget _buildWishlistededContent(BuildContext context) {
    final game = games.firstWhereOrNull((g) => g.id == activity.gameId);
    if (game == null) return const SizedBox();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SizedBox(
          width: 160,
          child: AspectRatio(
            aspectRatio: 2 / 3,
            child: GameCard(
              game: game,
              onTap: () => Navigations.navigateToGameDetail(game.id, context),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.red.withOpacity(0.2),
            ),
            child: const Icon(Icons.favorite, color: Colors.red, size: 28),
          ),
        ),
      ],
    );
  }

  Widget _buildTopThreeContent(BuildContext context) {
    final game1Id = activity.metadata?['game_1_id'] as int?;
    final game2Id = activity.metadata?['game_2_id'] as int?;
    final game3Id = activity.metadata?['game_3_id'] as int?;

    final game1 = games.firstWhereOrNull((g) => g.id == game1Id);
    final game2 = games.firstWhereOrNull((g) => g.id == game2Id);
    final game3 = games.firstWhereOrNull((g) => g.id == game3Id);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        if (game1 != null) _buildTopThreeGameColumn(context, game1, 1),
        if (game2 != null) _buildTopThreeGameColumn(context, game2, 2),
        if (game3 != null) _buildTopThreeGameColumn(context, game3, 3),
      ],
    );
  }

  Widget _buildTopThreeGameColumn(
      BuildContext context, Game game, int position,) {
    return Column(
      children: [
        _buildTopThreeCircle(context, position),
        const SizedBox(height: 8),
        SizedBox(
          width: 140,
          child: AspectRatio(
            aspectRatio: 2 / 3,
            child: GameCard(
              game: game,
              onTap: () => Navigations.navigateToGameDetail(game.id, context),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserRatingCircle(BuildContext context, double userRating) {
    final rating = userRating / 10; // 0-1 range
    final displayRating = userRating * 10;
    final color = ColorScales.getRatingColor(displayRating);

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.black.withOpacity(0.75),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: CircularProgressIndicator(
              value: rating,
              strokeWidth: 3,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.person,
                  size: 16,
                  color: Colors.white,
                ),
                Text(
                  displayRating.toStringAsFixed(0),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopThreeCircle(BuildContext context, int position) {
    final color = ColorScales.getTopThreeColor(position);

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.black.withOpacity(0.75),
        border: Border.all(
          color: color.withOpacity(0.8),
        ),
      ),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.emoji_events,
              size: 24,
              color: color,
            ),
            Text(
              '#$position',
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
