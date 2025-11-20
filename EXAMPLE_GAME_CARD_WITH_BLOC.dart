// BEISPIEL: GameCard mit UserGameDataBloc Integration
// Diese Datei zeigt, wie du die GameCard aktualisieren kannst

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamer_grove/core/utils/colorSchemes.dart';
import 'package:gamer_grove/core/utils/date_formatter.dart';
import 'package:gamer_grove/core/utils/image_utils.dart';
import 'package:gamer_grove/core/widgets/cached_image_widget.dart';
import 'package:gamer_grove/domain/entities/game/game.dart';
import 'package:gamer_grove/presentation/blocs/user_game_data/user_game_data_bloc.dart';

/// Aktualisierte GameCard mit UserGameDataBloc Integration
///
/// Diese Karte reagiert automatisch auf Änderungen an:
/// - Wishlist Status
/// - User Ratings
/// - Top Three Status
/// - Recommendations
///
/// Verwendung:
/// ```dart
/// GameCard(
///   game: game,
///   onTap: () => Navigator.push(...),
/// )
/// ```
class GameCardWithBloc extends StatelessWidget {

  const GameCardWithBloc({
    required this.game, required this.onTap, super.key,
    this.blurRated = false,
    this.width,
    this.height,
  });
  final Game game;
  final VoidCallback onTap;
  final bool blurRated;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: width ?? 160,
        height: height ?? 240,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BlocBuilder<UserGameDataBloc, UserGameDataState>(
            builder: (context, userDataState) {
              // Extract user-specific data from global state
              var isWishlisted = false;
              var isRecommended = false;
              double? userRating;
              var isInTopThree = false;
              int? topThreePosition;

              if (userDataState is UserGameDataLoaded) {
                isWishlisted = userDataState.isWishlisted(game.id);
                isRecommended = userDataState.isRecommended(game.id);
                userRating = userDataState.getRating(game.id);
                isInTopThree = userDataState.isInTopThree(game.id);
                topThreePosition = userDataState.getTopThreePosition(game.id);
              }

              return Stack(
                fit: StackFit.expand,
                children: [
                  // Background Cover Image
                  _buildBackgroundImage(context),

                  // Blur Filter für rated games
                  if (blurRated && userRating != null) _buildBlurOverlay(),

                  // Gradient Overlay
                  _buildGradientOverlay(),

                  // User Elements Background Gradient
                  if (_hasUserElements(
                    userRating,
                    isWishlisted,
                    isRecommended,
                    isInTopThree,
                  ))
                    _buildUserElementsBackground(
                      userRating,
                      isWishlisted,
                      isRecommended,
                      isInTopThree,
                    ),

                  // Content Overlay (unten)
                  _buildContentOverlay(context),

                  // Ratings und States Overlay (rechts) - NOW WITH BLOC DATA!
                  _buildRatingsOverlay(
                    context,
                    userRating,
                    isWishlisted,
                    isRecommended,
                    isInTopThree,
                    topThreePosition,
                  ),

                  // IGDB Rating (unten rechts)
                  if (game.totalRating != null)
                    Positioned(
                      bottom: 6,
                      right: 6,
                      child: _buildIGDBRatingCircle(context),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundImage(BuildContext context) {
    if (game.coverUrl != null && game.coverUrl!.isNotEmpty) {
      return CachedImageWidget(
        imageUrl: ImageUtils.getLargeImageUrl(game.coverUrl),
      );
    } else {
      return _buildFallbackBackground(context);
    }
  }

  Widget _buildFallbackBackground(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.3),
            Theme.of(context).colorScheme.primary.withOpacity(0.6),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.videogame_asset,
          size: 48,
          color: Colors.white.withOpacity(0.8),
        ),
      ),
    );
  }

  Widget _buildBlurOverlay() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
        child: Container(
          color: Colors.black.withOpacity(0.1),
        ),
      ),
    );
  }

  Widget _buildGradientOverlay() {
    return Container(
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
          stops: const [0.0, 0.6, 0.8, 1.0],
        ),
      ),
    );
  }

  Widget _buildUserElementsBackground(
    double? userRating,
    bool isWishlisted,
    bool isRecommended,
    bool isInTopThree,
  ) {
    final elementCount = _getUserElementsCount(
      userRating,
      isWishlisted,
      isRecommended,
      isInTopThree,
    );
    final height = _calculateUserElementsHeight(elementCount, userRating);

    return Positioned(
      top: 0,
      right: 0,
      width: 44,
      height: height,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: RadialGradient(
            center: const Alignment(1, -1),
            radius: 2.8,
            colors: [
              Colors.black.withOpacity(0.7),
              Colors.black.withOpacity(0.4),
              Colors.black.withOpacity(0.1),
              Colors.transparent,
            ],
            stops: const [0.0, 0.4, 0.7, 1.0],
          ),
        ),
      ),
    );
  }

  Widget _buildContentOverlay(BuildContext context) {
    return Positioned(
      left: 6,
      right: 50,
      bottom: 6,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            game.name,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 14,
                  shadows: [
                    Shadow(
                      offset: const Offset(0, 1),
                      blurRadius: 2,
                      color: Colors.black.withOpacity(0.7),
                    ),
                  ],
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              if (game.firstReleaseDate != null) ...[
                Icon(
                  Icons.calendar_today,
                  size: 10,
                  color: Colors.white.withOpacity(0.9),
                ),
                const SizedBox(width: 2),
                Text(
                  DateFormatter.formatYearOnly(game.firstReleaseDate!),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                ),
                if (game.genres.isNotEmpty) ...[
                  Text(
                    ' • ',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 10,
                        ),
                  ),
                ],
              ],
              if (game.genres.isNotEmpty)
                Expanded(
                  child: Text(
                    game.genres.take(2).map((g) => g.name).join(', '),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 10,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  /// ⭐ UPDATED: Now uses data from UserGameDataBloc
  Widget _buildRatingsOverlay(
    BuildContext context,
    double? userRating,
    bool isWishlisted,
    bool isRecommended,
    bool isInTopThree,
    int? topThreePosition,
  ) {
    return Positioned(
      top: 4,
      right: 4,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // User Rating
          if (userRating != null) ...[
            _buildUserRatingCircle(context, userRating),
            const SizedBox(height: 4),
          ],

          // Top Three
          if (isInTopThree && topThreePosition != null) ...[
            _buildTopThreeCircle(context, topThreePosition),
            const SizedBox(height: 4),
          ],

          // Wishlist
          if (isWishlisted) ...[
            _buildWishlistCircle(context),
            const SizedBox(height: 4),
          ],

          // Recommend
          if (isRecommended) _buildRecommendCircle(context),
        ],
      ),
    );
  }

  Widget _buildUserRatingCircle(BuildContext context, double userRating) {
    final rating = userRating / 10; // 0-1 range
    final displayRating = userRating * 10;
    final color = ColorScales.getRatingColor(displayRating);

    return Container(
      width: 32,
      height: 32,
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
              strokeWidth: 2,
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
                  size: 10,
                  color: Colors.white,
                ),
                Text(
                  displayRating.toStringAsFixed(0),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        offset: const Offset(0, 1),
                        blurRadius: 2,
                        color: Colors.black.withOpacity(0.7),
                      ),
                    ],
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
      width: 24,
      height: 24,
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
              size: 10,
              color: color,
            ),
            Text(
              '#$position',
              style: TextStyle(
                color: color,
                fontSize: 6,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWishlistCircle(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.black.withOpacity(0.75),
        border: Border.all(
          color: Colors.red.withOpacity(0.8),
        ),
      ),
      child: const Icon(
        Icons.favorite,
        size: 12,
        color: Colors.red,
      ),
    );
  }

  Widget _buildRecommendCircle(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.black.withOpacity(0.75),
        border: Border.all(
          color: Colors.green.withOpacity(0.8),
        ),
      ),
      child: const Icon(
        Icons.thumb_up,
        size: 12,
        color: Colors.green,
      ),
    );
  }

  Widget _buildIGDBRatingCircle(BuildContext context) {
    final rating = game.totalRating! / 100;
    final color = ColorScales.getRatingColor(game.totalRating!);

    return Container(
      width: 44,
      height: 44,
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
                  Icons.public,
                  size: 12,
                  color: Colors.white,
                ),
                const SizedBox(height: 1),
                Text(
                  game.totalRating!.toStringAsFixed(0),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        offset: const Offset(0, 1),
                        blurRadius: 2,
                        color: Colors.black.withOpacity(0.7),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  bool _hasUserElements(
    double? userRating,
    bool isWishlisted,
    bool isRecommended,
    bool isInTopThree,
  ) {
    return userRating != null ||
        isWishlisted ||
        isRecommended ||
        isInTopThree;
  }

  int _getUserElementsCount(
    double? userRating,
    bool isWishlisted,
    bool isRecommended,
    bool isInTopThree,
  ) {
    var count = 0;
    if (userRating != null) count++;
    if (isInTopThree) count++;
    if (isWishlisted) count++;
    if (isRecommended) count++;
    return count;
  }

  double _calculateUserElementsHeight(int count, double? userRating) {
    if (count == 0) return 0;

    double height = 16; // Base padding

    if (userRating != null) {
      height += 32; // User rating is larger
      count--;
      if (count > 0) height += 4;
    }

    height += count * 24;
    height += (count > 0 ? count - 1 : 0) * 4;

    return height;
  }
}
