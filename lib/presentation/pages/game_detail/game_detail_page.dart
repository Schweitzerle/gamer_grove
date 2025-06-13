// presentation/pages/game_detail/game_detail_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/image_utils.dart';
import '../../../core/widgets/cached_image_widget.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../core/widgets/error_widget.dart';
import '../../../injection_container.dart';
import '../../blocs/game/game_bloc.dart';
import '../../widgets/rating_widget.dart';

class GameDetailPage extends StatefulWidget {
  final int gameId;

  const GameDetailPage({
    super.key,
    required this.gameId,
  });

  @override
  State<GameDetailPage> createState() => _GameDetailPageState();
}

class _GameDetailPageState extends State<GameDetailPage> {
  late GameBloc _gameBloc;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _gameBloc = sl<GameBloc>();
    _gameBloc.add(GetGameDetailsEvent(widget.gameId));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _gameBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _gameBloc,
      child: Scaffold(
        body: BlocBuilder<GameBloc, GameState>(
          builder: (context, state) {
            if (state is GameDetailsLoading) {
              return const GameLoadingWidget();
            } else if (state is GameDetailsLoaded) {
              return _buildGameDetails(context, state.game);
            } else if (state is GameError) {
              return CustomErrorWidget(
                message: state.message,
                onRetry: () {
                  _gameBloc.add(GetGameDetailsEvent(widget.gameId));
                },
              );
            }
            return const GameLoadingWidget();
          },
        ),
      ),
    );
  }

  Widget _buildGameDetails(BuildContext context, game) {
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        // App Bar with Cover Image
        SliverAppBar(
          expandedHeight: 300,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                // Cover Image
                CachedImageWidget(
                  imageUrl: ImageUtils.getLargeImageUrl(game.coverUrl),
                  fit: BoxFit.cover,
                  errorWidget: Container(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: const Icon(
                      Icons.gamepad_rounded,
                      size: 80,
                    ),
                  ),
                ),
                // Gradient Overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            // Wishlist Button
            IconButton(
              onPressed: () => _toggleWishlist(game.id),
              icon: Icon(
                game.isWishlisted ? Icons.favorite : Icons.favorite_outline,
                color: game.isWishlisted ? Colors.red : Colors.white,
              ),
            ),
            // Share Button
            IconButton(
              onPressed: () => _shareGame(game),
              icon: const Icon(Icons.share, color: Colors.white),
            ),
          ],
        ),

        // Game Content
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Game Title & Basic Info
                _buildGameHeader(context, game),

                const SizedBox(height: AppConstants.paddingLarge),

                // Action Buttons
                _buildActionButtons(context, game),

                const SizedBox(height: AppConstants.paddingLarge),

                // Rating Section
                if (game.rating != null) ...[
                  _buildRatingSection(context, game),
                  const SizedBox(height: AppConstants.paddingLarge),
                ],

                // Summary
                if (game.summary != null) ...[
                  _buildSummarySection(context, game),
                  const SizedBox(height: AppConstants.paddingLarge),
                ],

                // Details Grid
                _buildDetailsGrid(context, game),

                const SizedBox(height: AppConstants.paddingLarge),

                // Screenshots
                if (game.screenshots.isNotEmpty) ...[
                  _buildScreenshotsSection(context, game),
                  const SizedBox(height: AppConstants.paddingLarge),
                ],

                // Platforms
                if (game.platforms.isNotEmpty) ...[
                  _buildPlatformsSection(context, game),
                  const SizedBox(height: AppConstants.paddingLarge),
                ],

                // Genres
                if (game.genres.isNotEmpty) ...[
                  _buildGenresSection(context, game),
                  const SizedBox(height: AppConstants.paddingXLarge),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGameHeader(BuildContext context, game) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Game Title
        Text(
          game.name,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: AppConstants.paddingSmall),

        // Release Date & Status
        Row(
          children: [
            if (game.releaseDate != null) ...[
              Icon(
                Icons.calendar_today,
                size: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                DateFormatter.formatGameReleaseDate(game.releaseDate),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],

            if (game.follows != null) ...[
              const SizedBox(width: 16),
              Icon(
                Icons.people,
                size: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                '${game.follows} followers',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, game) {
    return Row(
      children: [
        // Wishlist Button
        Expanded(
          child: FilledButton.icon(
            onPressed: () => _toggleWishlist(game.id),
            icon: Icon(
              game.isWishlisted ? Icons.favorite : Icons.favorite_outline,
            ),
            label: Text(
              game.isWishlisted ? 'In Wishlist' : 'Add to Wishlist',
            ),
            style: FilledButton.styleFrom(
              backgroundColor: game.isWishlisted
                  ? Theme.of(context).colorScheme.error
                  : Theme.of(context).colorScheme.primary,
            ),
          ),
        ),

        const SizedBox(width: AppConstants.paddingSmall),

        // Recommend Button
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _toggleRecommendation(game.id),
            icon: Icon(
              game.isRecommended ? Icons.thumb_up : Icons.thumb_up_outlined,
            ),
            label: Text(
              game.isRecommended ? 'Recommended' : 'Recommend',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRatingSection(BuildContext context, game) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rating',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppConstants.paddingSmall),

        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            child: Row(
              children: [
                // IGDB Rating
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        game.rating!.toStringAsFixed(1),
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _getRatingColor(game.rating!),
                        ),
                      ),
                      Text(
                        'IGDB Score',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      if (game.ratingCount != null)
                        Text(
                          '${game.ratingCount} ratings',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),

                // Divider
                Container(
                  height: 60,
                  width: 1,
                  color: Theme.of(context).colorScheme.outline,
                ),

                // User Rating
                Expanded(
                  child: Column(
                    children: [
                      if (game.userRating != null) ...[
                        Text(
                          game.userRating!.toStringAsFixed(1),
                          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        Text(
                          'Your Rating',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ] else ...[
                        IconButton(
                          onPressed: () => _showRatingDialog(game.id),
                          icon: const Icon(Icons.star_border),
                        ),
                        Text(
                          'Rate this game',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummarySection(BuildContext context, game) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppConstants.paddingSmall),
        Text(
          game.summary!,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildDetailsGrid(BuildContext context, game) {
    final details = <String, String>{};

    if (game.releaseDate != null) {
      details['Release Date'] = DateFormatter.formatShortDate(game.releaseDate!);
    }

    if (game.genres.isNotEmpty) {
      details['Genres'] = game.genres.take(3).map((g) => g.name).join(', ');
    }

    if (game.platforms.isNotEmpty) {
      details['Platforms'] = game.platforms.take(3).map((p) => p.abbreviation).join(', ');
    }

    if (game.gameModes.isNotEmpty) {
      details['Game Modes'] = game.gameModes.take(3).map((gm) => gm.name).join(', ');
    }

    if (details.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Details',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppConstants.paddingSmall),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            child: Column(
              children: details.entries.map((entry) =>
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 100,
                          child: Text(
                            entry.key,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            entry.value,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
              ).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScreenshotsSection(BuildContext context, game) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Screenshots',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppConstants.paddingSmall),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: game.screenshots.length,
            itemBuilder: (context, index) {
              final screenshot = game.screenshots[index];
              return Container(
                width: 300,
                margin: const EdgeInsets.only(right: AppConstants.paddingSmall),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                  child: CachedImageWidget(
                    imageUrl: ImageUtils.getScreenshotUrl(screenshot),
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPlatformsSection(BuildContext context, game) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available On',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppConstants.paddingSmall),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: game.platforms.map((platform) =>
              Chip(
                label: Text(platform.name),
                avatar: Icon(
                  Icons.devices,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
          ).toList(),
        ),
      ],
    );
  }

  Widget _buildGenresSection(BuildContext context, game) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Genres',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppConstants.paddingSmall),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: game.genres.map((genre) =>
              FilterChip(
                label: Text(genre.name),
                onSelected: (selected) {
                  // TODO: Navigate to genre search
                },
              ),
          ).toList(),
        ),
      ],
    );
  }

  Color _getRatingColor(double rating) {
    if (rating >= 80) return Colors.green;
    if (rating >= 70) return Colors.lightGreen;
    if (rating >= 60) return Colors.orange;
    if (rating >= 50) return Colors.deepOrange;
    return Colors.red;
  }

  void _toggleWishlist(int gameId) {
    // TODO: Implement wishlist toggle
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Wishlist feature coming soon!')),
    );
  }

  void _toggleRecommendation(int gameId) {
    // TODO: Implement recommendation toggle
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Recommendation feature coming soon!')),
    );
  }

  void _shareGame(game) {
    // TODO: Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Share ${game.name} - Coming soon!')),
    );
  }

  void _showRatingDialog(int gameId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rate this game'),
        content: const Text('Rating feature coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}