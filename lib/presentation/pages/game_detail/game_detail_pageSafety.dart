// lib/presentation/pages/game_detail/game_detail_page.dart
// ==================================================
// KOMPLETT NEUE GAME DETAIL PAGE MIT VOLLSTÄNDIGER API INTEGRATION
// ==================================================

// lib/presentation/pages/game_detail/enhanced_game_detail_page.dart
/*
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:gamer_grove/presentation/pages/game_detail/widgets/company_section.dart';
import 'package:gamer_grove/presentation/pages/game_detail/widgets/dlc_expansion_section.dart';
import 'package:gamer_grove/presentation/pages/game_detail/widgets/game_info_card.dart';
import 'package:gamer_grove/presentation/pages/game_detail/widgets/media_gallery.dart';
import 'package:gamer_grove/presentation/pages/game_detail/widgets/similar_games_section.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/image_utils.dart';
import '../../../core/widgets/cached_image_widget.dart';
import '../../../domain/entities/external_game.dart';
import '../../../domain/entities/game.dart';
import '../../../domain/entities/website.dart';
import '../../../domain/entities/age_rating.dart';
import '../../../domain/entities/game_video.dart';
import '../../../injection_container.dart';
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

class _GameDetailPageState extends State<GameDetailPage>
    with TickerProviderStateMixin {
  String? _currentUserId;
  late GameBloc _gameBloc;
  late ScrollController _scrollController;
  late AnimationController _fabAnimationController;
  late AnimationController _headerAnimationController;
  bool _showTitle = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _setupBloc();
    _loadGameDetails();
  }

  void _initializeControllers() {
    _scrollController = ScrollController();
    _fabAnimationController = AnimationController(
      duration: AppConstants.mediumAnimation,
      vsync: this,
    );
    _headerAnimationController = AnimationController(
      duration: AppConstants.mediumAnimation,
      vsync: this,
    );

    _scrollController.addListener(_onScroll);
  }

  void _setupBloc() {
    _gameBloc = sl<GameBloc>();
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      _currentUserId = authState.user.id;
    }
  }

  void _loadGameDetails() {
    _gameBloc.add(GetCompleteGameDetailsEvent(
      gameId: widget.gameId,
      userId: _currentUserId,
    ));
  }

  void _onScroll() {
    const showTitleOffset = 300.0;
    final shouldShowTitle = _scrollController.offset > showTitleOffset;

    if (shouldShowTitle != _showTitle) {
      setState(() {
        _showTitle = shouldShowTitle;
      });

      if (shouldShowTitle) {
        _headerAnimationController.forward();
      } else {
        _headerAnimationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _fabAnimationController.dispose();
    _headerAnimationController.dispose();
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
              return _buildLoadingState();
            } else if (state is GameDetailsLoaded) {
              return _buildLoadedState(state.game);
            } else if (state is GameError) {
              return _buildErrorState(state.message);
            }
            return _buildInitialState();
          },
        ),
        floatingActionButton: _buildFloatingActionButtons(),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading complete game details...'),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error loading game',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(message),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadGameDetails,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInitialState() {
    return const Scaffold(
      body: Center(child: Text('Loading...')),
    );
  }

  Widget _buildLoadedState(Game game) {
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        _buildAnimatedSliverAppBar(game),
        _buildGameContent(game),
      ],
    );
  }

  Widget _buildAnimatedSliverAppBar(Game game) {
    return SliverAppBar(
      expandedHeight: 500,
      pinned: true,
      floating: false,
      snap: false,
      backgroundColor: Theme.of(context).colorScheme.surface,
      foregroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        title: AnimatedBuilder(
          animation: _headerAnimationController,
          builder: (context, child) {
            return Opacity(
              opacity: _headerAnimationController.value,
              child: Text(
                game.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            );
          },
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Hero Background Image
            _buildHeroImage(game),

            // Gradient Overlays
            _buildGradientOverlays(),

            // Floating Game Info Card
            _buildFloatingGameCard(game),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: () => _shareGame(game),
        ),
        if (_currentUserId != null)
          IconButton(
            icon: Icon(
              game.isWishlisted ? Icons.bookmark : Icons.bookmark_border,
              color: game.isWishlisted ? Colors.amber : Colors.white,
            ),
            onPressed: () => _toggleWishlist(game),
          ),
      ],
    );
  }

  Widget _buildHeroImage(Game game) {
    return Hero(
      tag: 'game_cover_${game.id}',
      child: CachedImageWidget(
        imageUrl: ImageUtils.getLargeImageUrl(game.coverUrl),
        fit: BoxFit.cover,
        placeholder: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.secondary,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGradientOverlays() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.0, 0.3, 0.7, 1.0],
          colors: [
            Colors.transparent,
            Colors.black12,
            Colors.black45,
            Colors.black87,
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingGameCard(Game game) {
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: GameInfoCard(
        game: game,
        onRatePressed: () => _showRatingDialog(game),
        onAddToTopThreePressed: () => _showTopThreeDialog(game),
      ),
    );
  }

  Widget _buildGameContent(Game game) {
    return SliverToBoxAdapter(
      child: Container(
        color: Theme.of(context).colorScheme.surface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppConstants.paddingLarge),

            // Game Description
            if (game.summary != null) _buildDescriptionSection(game),

            // Age Ratings
            if (game.ageRatings.isNotEmpty) _buildAgeRatingsSection(game),

            // Companies (Developer, Publisher)
            if (game.involvedCompanies.isNotEmpty)
              CompanySection(companies: game.involvedCompanies),

            // Platforms & Release Info
            if (game.platforms.isNotEmpty) _buildPlatformsSection(game),

            // Genres & Tags
            _buildGenresAndTagsSection(game),

            // Game Features
            _buildGameFeaturesSection(game),

            // Media Gallery (Screenshots, Videos, Artwork)
            if (game.screenshots.isNotEmpty ||
                game.videos.isNotEmpty ||
                game.artworks.isNotEmpty)
              MediaGallery(
                screenshots: game.screenshots,
                videos: game.videos,
                artworks: game.artworks,
              ),

            // External Links & Stores
            if (game.websites.isNotEmpty || game.externalGames.isNotEmpty)
              _buildExternalLinksSection(game),

            // System Requirements (if available)
            // RequirementsSection(),

            // Similar Games
            if (game.similarGames.isNotEmpty)
              SimilarGamesSection(games: game.similarGames),

            // DLCs & Expansions
            if (game.dlcs.isNotEmpty || game.expansions.isNotEmpty)
              DLCExpansionSection(
                dlcs: game.dlcs,
                expansions: game.expansions,
              ),

            // Franchise & Collection
            if (game.franchises.isNotEmpty) _buildFranchiseSection(game),

            // Game Statistics
            _buildStatisticsSection(game),

            const SizedBox(height: 100), // Space for FAB
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionSection(Game game) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About ${game.name}',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          Text(
            game.summary!,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              height: 1.6,
            ),
          ),
          if (game.storyline != null) ...[
            const SizedBox(height: AppConstants.paddingMedium),
            ExpansionTile(
              title: const Text('Full Storyline'),
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppConstants.paddingMedium),
                  child: Text(
                    game.storyline!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.6,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAgeRatingsSection(Game game) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Age Ratings',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: game.ageRatings.map((rating) => _buildAgeRatingChip(rating)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAgeRatingChip(AgeRating rating) {
    Color chipColor;
    switch (rating.category) {
      case AgeRatingCategory.esrb:
        chipColor = Colors.blue;
        break;
      case AgeRatingCategory.pegi:
        chipColor = Colors.green;
        break;
      default:
        chipColor = Colors.grey;
    }

    return Chip(
      backgroundColor: chipColor.withOpacity(0.1),
      side: BorderSide(color: chipColor),
      label: Text(
        rating.displayName,
        style: TextStyle(
          color: chipColor,
          fontWeight: FontWeight.bold,
        ),
      ),
      avatar: Icon(
        Icons.verified_user,
        color: chipColor,
        size: 18,
      ),
    );
  }

  Widget _buildPlatformsSection(Game game) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Available Platforms',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: game.platforms.map((platform) => Chip(
              label: Text(platform.name),
              avatar: const Icon(Icons.devices, size: 16),
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            )).toList(),
          ),
          if (game.releaseDate != null) ...[
            const SizedBox(height: AppConstants.paddingMedium),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Release Date'),
              subtitle: Text(DateFormatter.formatFullDate(game.releaseDate!)),
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGenresAndTagsSection(Game game) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (game.genres.isNotEmpty) ...[
            Text(
              'Genres',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: game.genres.map((genre) => Chip(
                label: Text(genre.name),
                backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
              )).toList(),
            ),
            const SizedBox(height: AppConstants.paddingLarge),
          ],

          if (game.themes.isNotEmpty) ...[
            Text(
              'Themes',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: game.themes.map((theme) => Chip(
                label: Text(theme),
                backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
              )).toList(),
            ),
          ],

          if (game.keywords.isNotEmpty) ...[
            const SizedBox(height: AppConstants.paddingLarge),
            Text(
              'Keywords',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: game.keywords.map((keyword) => Chip(
                label: Text(
                  keyword.name,
                  style: const TextStyle(fontSize: 12),
                ),
                backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
              )).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGameFeaturesSection(Game game) {
    final features = <String>[];

    if (game.gameModes.isNotEmpty) {
      features.addAll(game.gameModes.map((mode) => mode.name));
    }

    if (game.playerPerspectives.isNotEmpty) {
      features.addAll(game.playerPerspectives.map((perspective) => perspective.name));
    }

    if (game.hasMultiplayer) {
      if (game.hasOnlineMultiplayer) features.add('Online Multiplayer');
      if (game.hasLocalMultiplayer) features.add('Local Multiplayer');
    }

    if (features.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Game Features',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: features.map((feature) => Chip(
              label: Text(feature),
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              labelStyle: TextStyle(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildExternalLinksSection(Game game) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'External Links & Stores',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppConstants.paddingMedium),

          // Store Links
          if (game.externalGames.isNotEmpty) ...[
            Text(
              'Buy Game',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            ...game.externalGames.map((store) => _buildExternalLinkTile(
              title: store.categoryDisplayName,
              url: store.url,
              icon: _getStoreIcon(store.category),
            )),
          ],

          // Official & Social Links
          if (game.websites.isNotEmpty) ...[
            const SizedBox(height: AppConstants.paddingMedium),
            Text(
              'Official Links',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            ...game.websites.map((website) => _buildExternalLinkTile(
              title: website.categoryDisplayName,
              url: website.url,
              icon: _getWebsiteIcon(website.category),
            )),
          ],
        ],
      ),
    );
  }

  Widget _buildExternalLinkTile({
    required String title,
    required String? url,
    required IconData icon,
  }) {
    if (url == null) return const SizedBox.shrink();

    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.open_in_new),
      onTap: () => _launchUrl(url),
      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
    );
  }

  Widget _buildFranchiseSection(Game game) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Part of Franchise',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          ...game.franchises.map((franchise) => Card(
            child: ListTile(
              leading: const Icon(Icons.library_books),
              title: Text(franchise.name),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                // Navigate to franchise page
              },
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildStatisticsSection(Game game) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Community Stats',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          Row(
            children: [
              _buildStatCard(
                title: 'Rating',
                value: game.rating?.toStringAsFixed(1) ?? 'N/A',
                subtitle: '${game.ratingCount ?? 0} reviews',
                icon: Icons.star,
              ),
              const SizedBox(width: AppConstants.paddingMedium),
              _buildStatCard(
                title: 'Follows',
                value: _formatNumber(game.follows ?? 0),
                subtitle: 'followers',
                icon: Icons.people,
              ),
              const SizedBox(width: AppConstants.paddingMedium),
              _buildStatCard(
                title: 'Hype',
                value: _formatNumber(game.hypes ?? 0),
                subtitle: 'hype points',
                icon: Icons.trending_up,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
  }) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          child: Column(
            children: [
              Icon(icon, size: 24),
              const SizedBox(height: 8),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                title,
                style: Theme.of(context).textTheme.labelMedium,
              ),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingActionButtons() {
    return BlocBuilder<GameBloc, GameState>(
      builder: (context, state) {
        if (state is! GameDetailsLoaded) return const SizedBox.shrink();

        final game = state.game;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FloatingActionButton(
              heroTag: 'rate_fab',
              onPressed: () => _showRatingDialog(game),
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Icon(
                game.userRating != null ? Icons.star : Icons.star_border,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            FloatingActionButton(
              heroTag: 'wishlist_fab',
              onPressed: () => _toggleWishlist(game),
              backgroundColor: game.isWishlisted
                  ? Colors.amber
                  : Theme.of(context).colorScheme.secondary,
              child: Icon(
                game.isWishlisted ? Icons.bookmark : Icons.bookmark_border,
                color: Colors.white,
              ),
            ),
          ],
        );
      },
    );
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

  void _showTopThreeDialog(Game game) {
    if (_currentUserId == null) {
      _showLoginRequiredSnackBar();
      return;
    }

    showDialog(
      context: context,
      builder: (context) => TopThreeDialog(
        game: game,
        onPositionSelected: (position) {
          _addToTopThree(game.id, position);
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
      ),
    );
  }

  void _addToTopThree(int gameId, int position) {
    if (_currentUserId == null) return;

    _gameBloc.add(AddToTopThreeEvent(
      gameId: gameId,
      userId: _currentUserId!,
      position: position,
    ));

    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added to Top 3 at position $position'),
        backgroundColor: Colors.amber,
        behavior: SnackBarBehavior.floating,
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
  }

  void _shareGame(Game game) {
    // Implement game sharing
    HapticFeedback.selectionClick();
  }

  void _showLoginRequiredSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please login to use this feature'),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  // ==========================================
  // HELPER METHODS
  // ==========================================

  IconData _getStoreIcon(ExternalGameCategory category) {
    switch (category) {
      case ExternalGameCategory.steam:
        return Icons.store;
      case ExternalGameCategory.epicGames:
        return Icons.store;
      case ExternalGameCategory.gog:
        return Icons.store;
      case ExternalGameCategory.playstation:
        return Icons.gamepad;
      case ExternalGameCategory.xbox:
        return Icons.gamepad;
      case ExternalGameCategory.nintendo:
        return Icons.gamepad;
      default:
        return Icons.shopping_cart;
    }
  }

  IconData _getWebsiteIcon(WebsiteCategory category) {
    switch (category) {
      case WebsiteCategory.official:
        return Icons.home;
      case WebsiteCategory.facebook:
        return Icons.facebook;
      case WebsiteCategory.twitter:
        return Icons.alternate_email;
      case WebsiteCategory.youtube:
        return Icons.play_circle;
      case WebsiteCategory.twitch:
        return Icons.live_tv;
      case WebsiteCategory.instagram:
        return Icons.photo_camera;
      case WebsiteCategory.discord:
        return Icons.chat;
      case WebsiteCategory.reddit:
        return Icons.forum;
      case WebsiteCategory.wikipedia:
        return Icons.article;
      case WebsiteCategory.wikia:
        return Icons.library_books;
      default:
        return Icons.link;
    }
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}
 */