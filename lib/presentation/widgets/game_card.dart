// presentation/widgets/game_card.dart
import 'dart:ui'; // Für BackdropFilter

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamer_grove/core/services/toast_service.dart';
import 'package:gamer_grove/core/utils/colorSchemes.dart';
import 'package:gamer_grove/core/utils/date_formatter.dart';
import 'package:gamer_grove/core/utils/image_utils.dart';
import 'package:gamer_grove/core/widgets/cached_image_widget.dart';
import 'package:gamer_grove/domain/entities/game/game.dart';
import 'package:gamer_grove/presentation/blocs/auth/auth_bloc.dart';
import 'package:gamer_grove/presentation/blocs/auth/auth_state.dart';
import 'package:gamer_grove/presentation/blocs/user_game_data/user_game_data_bloc.dart';
import 'package:gamer_grove/presentation/pages/game_detail/widgets/user_states_section.dart';

class GameCard extends StatelessWidget {
  const GameCard({
    required this.game,
    required this.onTap,
    super.key,
    this.blurRated = false,
    this.width,
    this.height,
    this.otherUserId,
    this.otherUserRating,
    this.otherUserIsWishlisted,
    this.otherUserIsRecommended,
    this.otherUserIsInTopThree,
    this.otherUserTopThreePosition,
  });
  final Game game;
  final VoidCallback onTap;
  final bool blurRated;
  final double? width;
  final double? height;
  final String? otherUserId;
  final double? otherUserRating;
  final bool? otherUserIsWishlisted;
  final bool? otherUserIsRecommended;
  final bool? otherUserIsInTopThree;
  final int? otherUserTopThreePosition;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await HapticFeedback.lightImpact();
        onTap.call();
      },
      onLongPress: () async {
        HapticFeedback.vibrate();
        _showUserStatesDialog(context);
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
            buildWhen: (previous, current) {
              // 🐛 DEBUG: Log buildWhen checks

              // Rebuild if state type changes OR if it's UserGameDataLoaded with different data
              if (previous.runtimeType != current.runtimeType) {
                return true;
              }

              // Always rebuild when UserGameDataLoaded state changes
              if (current is UserGameDataLoaded &&
                  previous is UserGameDataLoaded) {
                // Check if THIS game's data has changed
                final prevWishlisted = previous.isWishlisted(game.id);
                final currWishlisted = current.isWishlisted(game.id);
                final prevRecommended = previous.isRecommended(game.id);
                final currRecommended = current.isRecommended(game.id);
                final prevRating = previous.getRating(game.id);
                final currRating = current.getRating(game.id);
                final prevTopThree = previous.isInTopThree(game.id);
                final currTopThree = current.isInTopThree(game.id);

                final hasChanges = prevWishlisted != currWishlisted ||
                    prevRecommended != currRecommended ||
                    prevRating != currRating ||
                    prevTopThree != currTopThree;

                return hasChanges;
              }

              return true; // Rebuild for other state changes
            },
            builder: (context, userDataState) {
              // ✅ ALWAYS read from UserGameDataBloc as single source of truth
              // Default to false/null if not loaded yet
              var isWishlisted = false;
              var isRecommended = false;
              double? userRating;
              var isInTopThree = false;
              int? topThreePosition;

              // 🐛 DEBUG: Log builder state

              // Read from UserGameDataBloc if loaded
              if (userDataState is UserGameDataLoaded) {
                isWishlisted = userDataState.isWishlisted(game.id);
                isRecommended = userDataState.isRecommended(game.id);
                userRating = userDataState.getRating(game.id);
                isInTopThree = userDataState.isInTopThree(game.id);
                topThreePosition = userDataState.getTopThreePosition(game.id);
              } else {}

              return Stack(
                fit: StackFit.expand,
                children: [
                  // Background Cover Image (full card)
                  _buildBackgroundImage(context),

                  // Blur Filter für rated games
                  if (blurRated && userRating != null) _buildBlurOverlay(),

                  // Gradient Overlay
                  _buildGradientOverlay(),

                  // User Elements Background Gradient (logged-in user - right)
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
                      isLeft: false,
                    ),

                  // Other User Elements Background Gradient (left)
                  if (_hasOtherUserElements())
                    _buildUserElementsBackground(
                      otherUserRating,
                      otherUserIsWishlisted ?? false,
                      otherUserIsRecommended ?? false,
                      otherUserIsInTopThree ?? false,
                      isLeft: true,
                    ),

                  // Content Overlay (unten)
                  _buildContentOverlay(context),

                  // Other User States Overlay (left)
                  if (otherUserId != null)
                    _buildOtherUserStatesOverlay(context),

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
            Theme.of(context).colorScheme.primary.withAlpha(77),
            Theme.of(context).colorScheme.primary.withAlpha(153),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.videogame_asset,
          size: 48,
          color: Colors.white.withAlpha(204),
        ),
      ),
    );
  }

  Widget _buildBlurOverlay() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(51),
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
            Colors.black.withAlpha(179),
            Colors.black.withAlpha(230),
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
    bool isInTopThree, {
    required bool isLeft,
  }) {
    final elementCount = _getUserElementsCount(
      userRating,
      isWishlisted,
      isRecommended,
      isInTopThree,
    );
    final height = _calculateUserElementsHeight(elementCount, userRating);

    return Positioned(
      top: 0,
      left: isLeft ? 0 : null,
      right: isLeft ? null : 0,
      width: 44,
      height: height,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: RadialGradient(
            center: isLeft ? const Alignment(-1, -1) : const Alignment(1, -1),
            radius: 2.8,
            colors: [
              Colors.black.withAlpha(179),
              Colors.black.withAlpha(102),
              Colors.black.withAlpha(26),
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
                  color: Colors.white.withAlpha(230),
                ),
                const SizedBox(width: 2),
                Text(
                  DateFormatter.formatYearOnly(game.firstReleaseDate!),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withAlpha(230),
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
                          color: Colors.white.withAlpha(204),
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
          // Circular Progress
          Positioned.fill(
            child: CircularProgressIndicator(
              value: rating,
              strokeWidth: 2.0,
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
        ),
      ),
      child: Stack(
        children: [
          // Circular Progress
          Positioned.fill(
            child: CircularProgressIndicator(
              value: rating,
              strokeWidth: 3.0,
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

  Future<void> _showUserStatesDialog(BuildContext context) async {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      GamerGroveToastService.showWarning(
        context,
        title: 'Login Required',
        message: 'Please log in to manage your game states.',
      );
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (dialogContext) {
        return BlocProvider.value(
          value: BlocProvider.of<UserGameDataBloc>(context),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title
                Text(
                  game.name,
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                const Divider(),
                const SizedBox(height: 8),
                // User States Content
                UserStatesContent(game: game),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOtherUserStatesOverlay(BuildContext context) {
    return Positioned(
      top: 4,
      left: 4,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Other User Rating
          if (otherUserRating != null) ...[
            _buildUserRatingCircle(context, otherUserRating!),
            const SizedBox(height: 4),
          ],

          // Other User Top Three
          if (otherUserIsInTopThree ?? false) ...[
            _buildTopThreeCircle(context, otherUserTopThreePosition!),
            const SizedBox(height: 4),
          ],

          // Other User Wishlist
          if (otherUserIsWishlisted ?? false) ...[
            _buildWishlistCircle(context),
            const SizedBox(height: 4),
          ],

          // Other User Recommend
          if (otherUserIsRecommended ?? false) _buildRecommendCircle(context),
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
    return userRating != null || isWishlisted || isRecommended || isInTopThree;
  }

  bool _hasOtherUserElements() {
    return otherUserRating != null ||
        (otherUserIsWishlisted ?? false) ||
        (otherUserIsRecommended ?? false) ||
        (otherUserIsInTopThree ?? false);
  }

  int _getUserElementsCount(
    double? userRating,
    bool isWishlisted,
    bool isRecommended,
    bool isInTopThree,
  ) {
    var elementCount = 0;
    if (userRating != null) elementCount++;
    if (isInTopThree) elementCount++;
    if (isWishlisted) elementCount++;
    if (isRecommended) elementCount++;
    return elementCount;
  }

  double _calculateUserElementsHeight(int count, double? userRating) {
    if (count == 0) return 0;

    double height = 16; // Base padding (oben und unten)
    var localCount = count;

    if (userRating != null) {
      height += 32; // User rating ist größer
      localCount--;
      if (localCount > 0) height += 4; // Spacing nach User Rating
    }

    height += count * 24; // Andere Elemente sind 24px
    height +=
        (count > 0 ? count - 1 : 0) * 4; // Spacing zwischen anderen Elementen

    return height;
  }
}

// Shimmer Loading Version
class GameCardShimmer extends StatelessWidget {
  const GameCardShimmer({
    super.key,
    this.width,
    this.height,
  });
  final double? width;
  final double? height;

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
