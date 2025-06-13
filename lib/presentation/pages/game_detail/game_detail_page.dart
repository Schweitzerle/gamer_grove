// lib/presentation/pages/game_detail/game_detail_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/image_utils.dart';
import '../../../core/widgets/cached_image_widget.dart';
import '../../../domain/entities/game.dart';
import '../../blocs/game/game_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../widgets/rating_dialog.dart';
import '../../widgets/top_three_dialog.dart';

class GameDetailPage extends StatefulWidget {
  final int gameId;

  const GameDetailPage({super.key, required this.gameId});

  @override
  State<GameDetailPage> createState() => _GameDetailPageState();
}

class _GameDetailPageState extends State<GameDetailPage> {
  String? _currentUserId;

  @override
  void initState() {
    super.initState();

    // Get current user
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      _currentUserId = authState.user.id;
    }

    // Load game details using the provided GameBloc
    context.read<GameBloc>().add(GetGameDetailsEvent(widget.gameId));

    // Also load user-specific data if logged in
    if (_currentUserId != null) {
      _loadUserSpecificData();
    }
  }

  void _loadUserSpecificData() {
    if (_currentUserId == null) return;

    // Load user's wishlist, recommendations, ratings, etc.
    context.read<GameBloc>().add(LoadUserWishlistEvent(_currentUserId!));
    context.read<GameBloc>().add(LoadUserRecommendationsEvent(_currentUserId!));
    // TODO: Add LoadUserRatingsEvent and LoadUserTopThreeEvent when available
  }

  // ==========================================
  // ACTION METHODS
  // ==========================================

  void _showRatingDialog(Game game) {
    if (_currentUserId == null) {
      _showLoginRequiredSnackBar();
      return;
    }

    showDialog(
      context: context,
      builder: (context) => RatingDialog(
        gameName: game.name,
        currentRating: game.userRating,
        onRatingSubmitted: (rating) {
          _rateGame(game.id, rating);
        },
      ),
    );
  }

  void _rateGame(int gameId, double rating) {
    if (_currentUserId == null) return;

    context.read<GameBloc>().add(RateGameEvent(
      gameId: gameId,
      userId: _currentUserId!,
      rating: rating,
    ));

    HapticFeedback.lightImpact();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Game rated ${rating.toStringAsFixed(1)}/10'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'UNDO',
          textColor: Colors.white,
          onPressed: () {
            // TODO: Implement undo rating
          },
        ),
      ),
    );
  }

  void _toggleWishlist(Game game) {
    if (_currentUserId == null) {
      _showLoginRequiredSnackBar();
      return;
    }

    context.read<GameBloc>().add(ToggleWishlistEvent(
      gameId: game.id,
      userId: _currentUserId!,
    ));

    HapticFeedback.lightImpact();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          game.isWishlisted
              ? 'Removed from wishlist'
              : 'Added to wishlist',
        ),
        backgroundColor: game.isWishlisted ? Colors.orange : Colors.green,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'UNDO',
          textColor: Colors.white,
          onPressed: () {
            // Undo the action
            context.read<GameBloc>().add(ToggleWishlistEvent(
              gameId: game.id,
              userId: _currentUserId!,
            ));
          },
        ),
      ),
    );
  }

  void _toggleRecommendation(Game game) {
    if (_currentUserId == null) {
      _showLoginRequiredSnackBar();
      return;
    }

    context.read<GameBloc>().add(ToggleRecommendEvent(
      gameId: game.id,
      userId: _currentUserId!,
    ));

    HapticFeedback.lightImpact();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          game.isRecommended
              ? 'Removed recommendation'
              : 'Game recommended!',
        ),
        backgroundColor: game.isRecommended ? Colors.orange : Colors.blue,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _addToTopThree(Game game) {
    if (_currentUserId == null) {
      _showLoginRequiredSnackBar();
      return;
    }

    // Show position selection dialog
    showDialog(
      context: context,
      builder: (dialogContext) => TopThreeDialog(
        game: game,
        userId: _currentUserId!,
        currentTopThree: [], // TODO: Get from user profile
      ),
    );
  }

  void _shareGame(Game game) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Share "${game.name}" - Coming soon!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showLoginRequiredSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Please log in to use this feature'),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'LOGIN',
          textColor: Colors.white,
          onPressed: () {
            Navigator.of(context).pushNamed('/login');
          },
        ),
      ),
    );
  }

  // ==========================================
  // UI BUILDING METHODS
  // ==========================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<GameBloc, GameState>(
        listener: (context, state) {
          if (state is GameError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is GameDetailsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is GameDetailsLoaded) {
            return _buildGameDetail(context, state.game);
          } else if (state is GameError) {
            return _buildErrorView(state.message);
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildGameDetail(BuildContext context, Game game) {
    return CustomScrollView(
      slivers: [
        // App Bar with Cover Image
        SliverAppBar(
          expandedHeight: 300,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                // Cover Image with better error handling
                game.coverUrl != null && game.coverUrl!.isNotEmpty
                    ? CachedNetworkImage(
                  imageUrl: ImageUtils.getLargeImageUrl(game.coverUrl!),
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  errorWidget: (context, url, error) {
                    print('🖼️ Cover image error: $error');
                    print('🔗 URL: $url');
                    return Container(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      child: const Icon(
                        Icons.gamepad_rounded,
                        size: 80,
                        color: Colors.white54,
                      ),
                    );
                  },
                )
                    : Container(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: const Icon(
                    Icons.gamepad_rounded,
                    size: 80,
                    color: Colors.white54,
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
              onPressed: () => _toggleWishlist(game),
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
                // Game Header
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

  Widget _buildGameHeader(BuildContext context, Game game) {
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

  Widget _buildActionButtons(BuildContext context, Game game) {
    return Column(
      children: [
        // Row 1: Wishlist & Recommend
        Row(
          children: [
            // Wishlist Button
            Expanded(
              child: FilledButton.icon(
                onPressed: () => _toggleWishlist(game),
                icon: Icon(
                  game.isWishlisted ? Icons.favorite : Icons.favorite_outline,
                ),
                label: Text(
                  game.isWishlisted ? 'In Wishlist' : 'Add to Wishlist',
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: game.isWishlisted
                      ? Colors.red
                      : Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(width: AppConstants.paddingSmall),
            // Recommend Button
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _toggleRecommendation(game),
                icon: Icon(
                  game.isRecommended ? Icons.thumb_up : Icons.thumb_up_outlined,
                ),
                label: Text(
                  game.isRecommended ? 'Recommended' : 'Recommend',
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: game.isRecommended ? Colors.blue : null,
                  side: BorderSide(
                    color: game.isRecommended ? Colors.blue : Colors.grey,
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: AppConstants.paddingSmall),

        // Row 2: Rate & Add to Top 3
        Row(
          children: [
            // Rate Button
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _showRatingDialog(game),
                icon: Icon(
                  game.userRating != null ? Icons.star : Icons.star_outline,
                ),
                label: Text(
                  game.userRating != null
                      ? 'Rated ${game.userRating!.toStringAsFixed(1)}'
                      : 'Rate Game',
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: game.userRating != null ? Colors.amber : null,
                ),
              ),
            ),
            const SizedBox(width: AppConstants.paddingSmall),
            // Add to Top 3 Button
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _addToTopThree(game),
                icon: const Icon(Icons.star),
                label: const Text('Add to Top 3'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.amber[700],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRatingSection(BuildContext context, Game game) {
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
                      const SizedBox(height: 4),
                      Text(
                        'IGDB Rating',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (game.ratingCount != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          '${_formatRatingCount(game.ratingCount!)} votes',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Divider
                Container(
                  width: 1,
                  height: 50,
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                ),

                // User Rating or Rate Button
                Expanded(
                  child: game.userRating != null
                      ? Column(
                    children: [
                      Text(
                        game.userRating!.toStringAsFixed(1),
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _getRatingColor(game.userRating!),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Your Rating',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => _showRatingDialog(game),
                        child: const Text('Change Rating'),
                      ),
                    ],
                  )
                      : Column(
                    children: [
                      Icon(
                        Icons.star_outline,
                        size: 32,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 8),
                      FilledButton(
                        onPressed: () => _showRatingDialog(game),
                        child: const Text('Rate Game'),
                      ),
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

  Widget _buildSummarySection(BuildContext context, Game game) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Summary',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppConstants.paddingSmall),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            child: Text(
              game.summary!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.justify,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsGrid(BuildContext context, Game game) {
    final Map<String, String> details = {};

    if (game.releaseDate != null) {
      details['Release Date'] = DateFormatter.formatGameReleaseDate(game.releaseDate);
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
              children: details.entries.map<Widget>((entry) =>
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

  Widget _buildScreenshotsSection(BuildContext context, Game game) {
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
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: game.screenshots.length,
            itemBuilder: (context, index) {
              final screenshotUrl = game.screenshots[index]; // Already a String
              return Container(
                width: 250,
                margin: const EdgeInsets.only(right: AppConstants.paddingSmall),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                  child: CachedNetworkImage(
                    imageUrl: ImageUtils.getLargeImageUrl(screenshotUrl),
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      child: const Icon(Icons.broken_image),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPlatformsSection(BuildContext context, Game game) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Platforms',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppConstants.paddingSmall),
        Wrap(
          spacing: AppConstants.paddingSmall,
          runSpacing: AppConstants.paddingSmall,
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

  Widget _buildGenresSection(BuildContext context, Game game) {
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
          spacing: AppConstants.paddingSmall,
          runSpacing: AppConstants.paddingSmall,
          children: game.genres.map((genre) =>
              Chip(
                label: Text(genre.name),
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                labelStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
          ).toList(),
        ),
      ],
    );
  }

  Widget _buildErrorView(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Error loading game details',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () {
              context.read<GameBloc>().add(GetGameDetailsEvent(widget.gameId));
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // HELPER METHODS
  // ==========================================

  Color _getRatingColor(double rating) {
    if (rating >= 80) return Colors.green;
    if (rating >= 70) return Colors.lightGreen;
    if (rating >= 60) return Colors.orange;
    if (rating >= 50) return Colors.deepOrange;
    return Colors.red;
  }

  String _formatRatingCount(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    }
    return count.toString();
  }
}