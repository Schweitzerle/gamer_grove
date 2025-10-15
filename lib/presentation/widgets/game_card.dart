// presentation/widgets/game_card.dart
import 'dart:ui'; // Für BackdropFilter
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gamer_grove/core/utils/colorSchemes.dart';
import '../../domain/entities/game/game.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/utils/image_utils.dart';
import '../../core/widgets/cached_image_widget.dart';

class GameCard extends StatelessWidget {
  final Game game;
  final VoidCallback onTap;
  final bool blurRated;
  final double? width;
  final double? height;

  const GameCard({
    super.key,
    required this.game,
    required this.onTap,
    this.blurRated = false,
    this.width,
    this.height,
  });

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
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background Cover Image (full card)
              _buildBackgroundImage(context),

              // Blur Filter für rated games
              if (blurRated && _isGameRated()) _buildBlurOverlay(),

              // Gradient Overlay
              _buildGradientOverlay(),

              // User Elements Background Gradient
              if (_hasUserElements()) _buildUserElementsBackground(),

              // Content Overlay (unten)
              _buildContentOverlay(context),

              // Ratings und States Overlay (rechts)
              _buildRatingsOverlay(context),

              // IGDB Rating (unten rechts)
              if (game.totalRating != null)
                Positioned(
                  bottom: 6,
                  right: 6,
                  child: _buildIGDBRatingCircle(context),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundImage(BuildContext context) {
    if (game.coverUrl != null && game.coverUrl!.isNotEmpty) {
      return CachedImageWidget(
        imageUrl: ImageUtils.getLargeImageUrl(game.coverUrl),
        fit: BoxFit.cover,
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
        filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
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

  Widget _buildUserElementsBackground() {
    // Dynamische Höhe basierend auf Anzahl der User-Elemente
    final elementCount = _getUserElementsCount();
    final height = _calculateUserElementsHeight(elementCount);

    return Positioned(
      top: 0,
      right: 0,
      width: 44,
      height: height,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: RadialGradient(
            center: const Alignment(1.0, -1.0), // Exakt in der Ecke oben rechts
            radius: 2.8, // Größerer Radius für bessere Abdeckung
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
      right: 50, // Platz für rechte Elemente
      bottom: 6,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Game Title
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

          // Date + Genres in einer Row
          Row(
            children: [
              // Release Date
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

              // Genres
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

  Widget _buildRatingsOverlay(BuildContext context) {
    return Positioned(
      top: 4,
      right: 4,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // User Rating
          game.userRating != null
              ? _buildUserRatingCircle(context)
              : Container(height: 0),

          // Abstand nur wenn User Rating vorhanden
          game.userRating != null
              ? const SizedBox(height: 4)
              : Container(height: 0),

          // Top Three
          (game.isInTopThree)
              ? _buildTopThreeCircle(context)
              : Container(height: 0),

          // Abstand nur wenn Top Three vorhanden
          (game.isInTopThree)
              ? const SizedBox(height: 4)
              : Container(height: 0),

          // Wishlist
          game.isWishlisted
              ? _buildWishlistCircle(context)
              : Container(height: 0),

          // Abstand nur wenn Wishlist vorhanden
          game.isWishlisted ? const SizedBox(height: 4) : Container(height: 0),

          // Recommend
          game.isRecommended
              ? _buildRecommendCircle(context)
              : Container(height: 0),
        ],
      ),
    );
  }

  Widget _buildUserRatingCircle(BuildContext context) {
    final rating = game.userRating! / 10; // 0-1 range
    final displayRating = (game.userRating! * 10);
    final color = ColorScales.getRatingColor(displayRating);

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.black.withOpacity(0.75),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          // Circular Progress
          Positioned.fill(
            child: CircularProgressIndicator(
              value: rating,
              strokeWidth: 2,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),

          // Center Content
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

  Widget _buildTopThreeCircle(BuildContext context) {
    final position = game.topThreePosition ?? 1;
    final color = ColorScales.getTopThreeColor(position);

    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.black.withOpacity(0.75),
        border: Border.all(
          color: color.withOpacity(0.8),
          width: 1,
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
          width: 1,
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
          width: 1,
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
    final rating = game.totalRating! / 100; // 0-1 range für Progress
    final color = ColorScales.getRatingColor(game.totalRating!);

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.black.withOpacity(0.75),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          // Circular Progress
          Positioned.fill(
            child: CircularProgressIndicator(
              value: rating,
              strokeWidth: 3,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),

          // Center Content
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.public, // Globe icon für IGDB/externe Quelle
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
  bool _hasUserElements() {
    return game.userRating != null ||
        game.isWishlisted ||
        game.isRecommended ||
        (game.isInTopThree);
  }

  int _getUserElementsCount() {
    int count = 0;
    if (game.userRating != null) count++;
    if (game.isInTopThree) count++;
    if (game.isWishlisted) count++;
    if (game.isRecommended) count++;
    return count;
  }

  double _calculateUserElementsHeight(int count) {
    if (count == 0) return 0;

    double height = 16; // Base padding (oben und unten)

    if (game.userRating != null) {
      height += 32; // User rating ist größer
      count--;
      if (count > 0) height += 4; // Spacing nach User Rating
    }

    height += count * 24; // Andere Elemente sind 24px
    height +=
        (count > 0 ? count - 1 : 0) * 4; // Spacing zwischen anderen Elementen

    return height;
  }

  bool _isGameRated() {
    return game.userRating != null && game.userRating! > 0;
  }
}

// Shimmer Loading Version
class GameCardShimmer extends StatelessWidget {
  final double? width;
  final double? height;

  const GameCardShimmer({
    super.key,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? 160,
      height: height ?? 240,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Background shimmer
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).colorScheme.surfaceContainerHighest,
                    Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest
                        .withOpacity(0.5),
                  ],
                ),
              ),
            ),

            // User Elements shimmer (rechts oben)
            Positioned(
              top: 12,
              right: 12,
              child: Column(
                children: [
                  // User Rating shimmer
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).colorScheme.surface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // States shimmer
                  ...List.generate(
                    2,
                    (index) => Container(
                      width: 32,
                      height: 32,
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).colorScheme.surface,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // IGDB Rating shimmer (unten rechts)
            Positioned(
              bottom: 12,
              right: 12,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.surface,
                ),
              ),
            ),

            // Content area shimmer (unten links)
            Positioned(
              left: 12,
              right: 70,
              bottom: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title shimmer
                  Container(
                    width: double.infinity,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(7),
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Date + Genres shimmer
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 10,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 60,
                        height: 10,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
