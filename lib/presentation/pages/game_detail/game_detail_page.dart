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
import '../../../injection_container.dart';
import '../../../data/datasources/remote/supabase_remote_datasource.dart';
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
  late GameBloc _gameBloc;

  @override
  void initState() {
    super.initState();

    // Create a new GameBloc instance for this page
    _gameBloc = sl<GameBloc>();

    // Get current user
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      _currentUserId = authState.user.id;
    }

    // Load game details with user data
    _gameBloc.add(GetGameDetailsWithUserDataEvent(
      gameId: widget.gameId,
      userId: _currentUserId,
    ));
  }

  @override
  void dispose() {
    _gameBloc.close();
    super.dispose();
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

    _gameBloc.add(RateGameEvent(
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

    _gameBloc.add(ToggleWishlistEvent(
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
            _gameBloc.add(ToggleWishlistEvent(
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

    _gameBloc.add(ToggleRecommendEvent(
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
        backgroundColor: game.isRecommended ? Colors.orange : Colors.green,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'UNDO',
          textColor: Colors.white,
          onPressed: () {
            _gameBloc.add(ToggleRecommendEvent(
              gameId: game.id,
              userId: _currentUserId!,
            ));
          },
        ),
      ),
    );
  }

  void _showTopThreeDialog(Game game) {
    if (_currentUserId == null) {
      _showLoginRequiredSnackBar();
      return;
    }

    showDialog(
      context: context,
      builder: (context) => BlocProvider.value(
        value: _gameBloc,
        child: TopThreeDialog(
          game: game,
          userId: _currentUserId!,
        ),
      ),
    );
  }

  void _showLoginRequiredSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please log in to use this feature'),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ==========================================
  // BUILD METHODS
  // ==========================================

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _gameBloc,
      child: Scaffold(
        body: BlocBuilder<GameBloc, GameState>(
          bloc: _gameBloc,
          builder: (context, state) {
            if (state is GameDetailsLoading) {
              return _buildLoadingState();
            } else if (state is GameDetailsLoaded) {
              return _buildLoadedState(state.game);
            } else if (state is GameError) {
              return _buildErrorState(state.message);
            }
            return _buildInitialState();
          },
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 60,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            'Error loading game',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(message),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              _gameBloc.add(GetGameDetailsWithUserDataEvent(
                gameId: widget.gameId,
                userId: _currentUserId,
              ));
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialState() {
    return const Center(
      child: Text('Loading game details...'),
    );
  }


  Widget _buildLoadedState(Game game) {
    return CustomScrollView(
      slivers: [
        // App Bar with Cover
        _buildSliverAppBar(game),

        // WICHTIG: Wrap den Container in SliverToBoxAdapter
        SliverToBoxAdapter(
          child: _buildGameStatusBar(game),
        ),

        // Content
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Game Title and Year
                _buildTitleSection(game),
                const SizedBox(height: AppConstants.paddingMedium),

                // Action Buttons
                _buildActionButtons(game),
                const SizedBox(height: AppConstants.paddingLarge),

                // User Stats (if logged in)
                if (_currentUserId != null) ...[
                  _buildUserStats(game),
                  const SizedBox(height: AppConstants.paddingLarge),
                ],

                // Quick Info
                _buildQuickInfo(game),
                const SizedBox(height: AppConstants.paddingLarge),

                // Description
                if (game.summary != null) ...[
                  _buildSection('Summary', game.summary!),
                  const SizedBox(height: AppConstants.paddingLarge),
                ],

                // Genres
                if (game.genres.isNotEmpty) ...[
                  _buildGenresSection(game),
                  const SizedBox(height: AppConstants.paddingLarge),
                ],

                // Platforms
                if (game.platforms.isNotEmpty) ...[
                  _buildPlatformsSection(game),
                  const SizedBox(height: AppConstants.paddingLarge),
                ],

                // Screenshots
                if (game.screenshots.isNotEmpty) ...[
                  _buildScreenshotsSection(game),
                  const SizedBox(height: AppConstants.paddingLarge),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSliverAppBar(Game game) {
    return SliverAppBar(
      expandedHeight: 400,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Background Image
            CachedImageWidget(
              imageUrl: ImageUtils.getLargeImageUrl(game.coverUrl),
              fit: BoxFit.cover,
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
    );
  }

  Widget _buildTitleSection(Game game) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          game.name,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        if (game.releaseDate != null) ...[
          const SizedBox(height: 4),
          Text(
            'Released ${DateFormatter.formatYearOnly(game.releaseDate!)}',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActionButtons(Game game) {
    return Row(
      children: [
        // Rating Button
        Expanded(
          child: _ActionButton(
            onPressed: () => _showRatingDialog(game),
            icon: Icons.star,
            label: game.userRating != null
                ? 'Rated ${game.userRating!.toStringAsFixed(1)}'
                : 'Rate',
            isActive: game.userRating != null,
            activeColor: Colors.amber,
          ),
        ),
        const SizedBox(width: 8),

        // Wishlist Button
        Expanded(
          child: _ActionButton(
            onPressed: () => _toggleWishlist(game),
            icon: game.isWishlisted ? Icons.favorite : Icons.favorite_outline,
            label: game.isWishlisted ? 'Wishlisted' : 'Wishlist',
            isActive: game.isWishlisted,
            activeColor: Colors.red,
          ),
        ),
        const SizedBox(width: 8),

        // Recommend Button
        Expanded(
          child: _ActionButton(
            onPressed: () => _toggleRecommendation(game),
            icon: game.isRecommended ? Icons.thumb_up : Icons.thumb_up_outlined,
            label: game.isRecommended ? 'Recommended' : 'Recommend',
            isActive: game.isRecommended,
            activeColor: Colors.green,
          ),
        ),
        const SizedBox(width: 8),

        // Top 3 Button
        IconButton.filled(
          onPressed: () => _showTopThreeDialog(game),
          icon: const Icon(Icons.emoji_events),
          tooltip: 'Add to Top 3',
        ),
      ],
    );
  }

  Widget _buildUserStats(Game game) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(
              icon: Icons.star,
              value: game.userRating?.toStringAsFixed(1) ?? '-',
              label: 'Your Rating',
              color: Colors.amber,
            ),
            _buildStatItem(
              icon: Icons.favorite,
              value: game.isWishlisted ? 'Yes' : 'No',
              label: 'Wishlisted',
              color: Colors.red,
            ),
            _buildStatItem(
              icon: Icons.thumb_up,
              value: game.isRecommended ? 'Yes' : 'No',
              label: 'Recommended',
              color: Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickInfo(Game game) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          children: [
            if (game.rating != null)
              _buildInfoRow(
                'IGDB Rating',
                '${game.rating!.toStringAsFixed(1)}/10',
                Icons.star,
              ),
            if (game.releaseDate != null)
              _buildInfoRow(
                'Release Date',
                DateFormatter.formatShortDate(game.releaseDate!),
                Icons.calendar_today,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );
  }

  Widget _buildGenresSection(Game game) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Genres',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: game.genres
              .map((genre) => Chip(
            label: Text(genre.name),
            backgroundColor:
            Theme.of(context).colorScheme.primaryContainer,
          ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildPlatformsSection(Game game) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Platforms',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: game.platforms
              .map((platform) => Chip(
            label: Text(platform.name),
            avatar: const Icon(Icons.devices, size: 16),
          ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildScreenshotsSection(Game game) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Screenshots',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: game.screenshots.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                  child: CachedImageWidget(
                    imageUrl: ImageUtils.getMediumImageUrl(
                      game.screenshots[index],
                    ),
                    width: 300,
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
  Widget _buildTopThreeIndicator(Game game) {
    final position = game.topThreePosition ?? 1;
    final medal = _getMedalIcon(position);
    final color = _getPositionColor(position);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.8), color],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            medal,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '#$position',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                'Favorite',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGameStatusBar(Game game) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if (game.isInTopThree ?? false)
            _buildTopThreeIndicator(game),
          if (game.userRating != null)
            _buildRatingIndicator(game.userRating!),
          if (game.isWishlisted)
            _buildStatusIndicator(
              Icons.favorite,
              'In Wishlist',
              Colors.red,
            ),
          if (game.isRecommended)
            _buildStatusIndicator(
              Icons.thumb_up,
              'Recommended',
              Colors.green,
            ),
        ],
      ),
    );
  }


  Widget _buildRatingIndicator(double rating) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _getRatingColor(rating),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _getRatingColor(rating).withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.star,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                rating.toStringAsFixed(1),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                'Your Rating',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Color _getRatingColor(double rating) {
    if (rating >= 90.0) return const Color(0xFF5b041d); // Iridescent (orchid/lila)
    if (rating >= 80.0) return const Color(0xFFd98b0b); // Gold
    if (rating >= 60.0) return const Color(0xFF6a6f75); // Silver
    if (rating >= 40.0) return const Color(0xFF7c3614); // Bronze
    return const Color(0xFF51483a); // Ash (dunkelgrau)
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

// Action Button Widget
class _ActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String label;
  final bool isActive;
  final Color activeColor;

  const _ActionButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.isActive,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isActive
          ? activeColor.withOpacity(0.1)
          : Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingSmall,
            vertical: AppConstants.paddingSmall + 4,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: isActive
                    ? activeColor
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    color: isActive
                        ? activeColor
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}