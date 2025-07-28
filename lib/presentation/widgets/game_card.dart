// presentation/widgets/game_card.dart
import 'dart:ui'; // Für BackdropFilter
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

              // Content Overlay (noch weniger Höhe - nur für Titel und Genres)
              _buildContentOverlay(context),

              // Ratings und States Overlay
              _buildRatingsOverlay(context),
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
            Colors.black.withOpacity(0.3),
            Colors.black.withOpacity(0.8),
          ],
          stops: const [0.0, 0.4, 0.7, 1.0],
        ),
      ),
    );
  }

  Widget _buildContentOverlay(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Nur Game Title - viel mehr Platz
          Text(
            game.name,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 16,
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

          const SizedBox(height: 0),

          // Release Date & Genres Row - mehr Platz
          Row(
            children: [
              // Release Date
              if (game.firstReleaseDate != null) ...[
                Icon(
                  Icons.calendar_today,
                  size: 12,
                  color: Colors.white.withOpacity(0.9),
                ),
                const SizedBox(width: 4),
                Text(
                  DateFormatter.formatYearOnly(game.firstReleaseDate!),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (game.genres.isNotEmpty) ...[
                  Text(
                    ' • ',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white.withOpacity(0.7),
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
                      fontSize: 11,
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
    return Stack(
      children: [
        // IGDB Rating (oben links)
        if (game.totalRating != null)
          Positioned(
            top: 12,
            left: 12,
            child: _buildIGDBRatingCircle(context),
          ),

        // User Rating mit States (oben rechts)
        if (game.userRating != null || _hasUserStates())
          Positioned(
            top: 12,
            right: 12,
            child: _buildUserDataCircle(context),
          ),
      ],
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
                Icon(
                  Icons.star_outline,
                  size: 14,
                  color: Colors.white,
                ),
                const SizedBox(height: 2),
                Text(
                  game.totalRating!.toStringAsFixed(0),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
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

  Widget _buildUserDataCircle(BuildContext context) {
    final hasUserRating = game.userRating != null;
    final userStates = _getUserStates(context);

    return Container(
      constraints: const BoxConstraints(
        minWidth: 44,
        minHeight: 44,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: Colors.black.withOpacity(0.75),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // User Rating Circle (wenn vorhanden)
          if (hasUserRating) _buildUserRatingSection(context),

          // User States (darunter)
          if (userStates.isNotEmpty) ...[
            if (hasUserRating) const SizedBox(height: 6),
            _buildUserStatesSection(context, userStates),
          ],
        ],
      ),
    );
  }

  Widget _buildUserRatingSection(BuildContext context) {
    final rating = game.userRating! / 10; // 0-1 range
    final displayRating = (game.userRating! * 10);
    final color = ColorScales.getRatingColor(displayRating);

    return Container(
      width: 40,
      height: 40,
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.transparent,
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
                Icon(
                  Icons.star,
                  size: 12,
                  color: Colors.white,
                ),
                Text(
                  displayRating.toStringAsFixed(0),
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

  Widget _buildUserStatesSection(BuildContext context, List<Widget> states) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 0, 6, 6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: states
            .map((state) => Padding(
          padding: const EdgeInsets.only(bottom: 3),
          child: state,
        ))
            .toList()
          ..removeLast(), // Remove last padding
      ),
    );
  }

  List<Widget> _getUserStates(BuildContext context) {
    final states = <Widget>[];

    if (game.isWishlisted) {
      states.add(_buildCompactStateIcon(
        Icons.favorite,
        Colors.red,
      ));
    }

    if (game.isRecommended) {
      states.add(_buildCompactStateIcon(
        Icons.thumb_up,
        Colors.green,
      ));
    }

    if (game.isInTopThree) {
      states.add(_buildTopThreeCompact(context));
    }

    return states;
  }

  Widget _buildCompactStateIcon(IconData icon, Color color) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.2),
        border: Border.all(
          color: color.withOpacity(0.6),
          width: 1,
        ),
      ),
      child: Icon(
        icon,
        size: 12,
        color: color,
      ),
    );
  }

  Widget _buildTopThreeCompact(BuildContext context) {
    final position = game.topThreePosition ?? 1;
    final color = ColorScales.getTopThreeColor(position);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withOpacity(0.6),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.emoji_events,
            size: 10,
            color: color,
          ),
          const SizedBox(width: 2),
          Text(
            '#$position',
            style: TextStyle(
              color: color,
              fontSize: 8,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  bool _hasUserStates() {
    return game.isWishlisted ||
        game.isRecommended ||
        (game.isInTopThree ?? false);
  }

  // Helper method to check if game is rated
  bool _isGameRated() {
    return game.userRating != null && game.userRating! > 0;
  }
}

// Shimmer Loading Version (angepasst an neues Design)
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
        color: Theme.of(context).colorScheme.surfaceVariant,
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
                    Theme.of(context).colorScheme.surfaceVariant,
                    Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                  ],
                ),
              ),
            ),

            // Content area shimmer
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              height: (height ?? 240) * 0.3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Title shimmer
                  Container(
                    width: double.infinity,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Subtitle shimmer
                  Container(
                    width: 100,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ],
              ),
            ),

            // Rating shimmer (top right)
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.surface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}