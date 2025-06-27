// lib/presentation/pages/game_detail/enhanced_game_detail_page.dart
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
import '../../../domain/usecases/game/toggle_wishlist.dart';
import '../../../domain/usecases/user/add_to_top_three.dart';
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
  late TabController _mediaTabController;
  late ScrollController _scrollController;
  bool _isHeaderCollapsed = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    _setupBloc();
    _loadGameDetails();
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      final isCollapsed = _scrollController.offset > 200;
      if (isCollapsed != _isHeaderCollapsed) {
        setState(() {
          _isHeaderCollapsed = isCollapsed;
        });
      }
    }
  }

  void _setupBloc() {
    _gameBloc = sl<GameBloc>();
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      _currentUserId = authState.user.id;
    }
  }

  void _initializeMediaTabs(Game game) {
    int tabCount = 0;
    if (game.screenshots.isNotEmpty) tabCount++;
    if (game.videos.isNotEmpty) tabCount++;
    if (game.artworks.isNotEmpty) tabCount++;

    if (tabCount > 0) {
      _mediaTabController = TabController(length: tabCount, vsync: this);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _mediaTabController.dispose();
      super.dispose();
  }

  void _loadGameDetails() {
    _gameBloc.add(GetCompleteGameDetailsEvent(
      gameId: widget.gameId,
      userId: _currentUserId,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
        value: _gameBloc,
      child: Scaffold(
        body: BlocBuilder<GameBloc, GameState>(
          builder: (context, state) {
            if (state is GameDetailsLoading) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (state is GameError) {
              return Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error: ${state.message}'),
                      ElevatedButton(
                        onPressed: _loadGameDetails,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state is GameDetailsLoaded) {
              final game = state.game;
              _initializeMediaTabs(game);

              return Scaffold(
                body: CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    _buildSliverAppBar(game),
                    _buildGameContent(game),
                  ],
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(Game game) {
    return SliverAppBar(
      expandedHeight: 450,
      pinned: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            _buildHeroImage(game),
            _buildGradientOverlays(),
            _buildFloatingGameCard(game),
          ],
        ),
        title: _isHeaderCollapsed
            ? Text(
          game.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        )
            : null,
      ),
      actions: [
        if (game.isWishlisted != null)
          IconButton(
            icon: Icon(
              game.isWishlisted! ? Icons.bookmark : Icons.bookmark_border,
              color: game.isWishlisted! ? Colors.amber : Colors.white,
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
                Theme.of(context).colorScheme.primary.withOpacity(0.8),
                Theme.of(context).colorScheme.secondary.withOpacity(0.8),
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
          stops: [0.0, 0.2, 0.7, 1.0],
          colors: [
            Colors.transparent,
            Colors.black12,
            Colors.black54,
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

            // Game Description with expandable storyline
            if (game.summary != null) _buildEnhancedDescriptionSection(game),

            // Quick Info Cards
            _buildQuickInfoSection(game),

            // Media Gallery with Tabs
            if (game.screenshots.isNotEmpty ||
                game.videos.isNotEmpty ||
                game.artworks.isNotEmpty)
              _buildEnhancedMediaGallery(game),

            // Game Details Accordion
            _buildGameDetailsAccordion(game),

            // External Links & Stores
            if (game.websites.isNotEmpty || game.externalGames.isNotEmpty)
              _buildEnhancedExternalLinksSection(game),

            // Similar Games
            if (game.similarGames.isNotEmpty)
              SimilarGamesSection(games: game.similarGames),

            // DLCs & Expansions
            if (game.dlcs.isNotEmpty || game.expansions.isNotEmpty)
              DLCExpansionSection(
                dlcs: game.dlcs,
                expansions: game.expansions,
              ),

            const SizedBox(height: 100), // Space for bottom navigation
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedDescriptionSection(Game game) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      child: Card(
        elevation: 0,
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.description,
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'About ${game.name}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
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
                Theme(
                  data: Theme.of(context).copyWith(
                    dividerColor: Colors.transparent,
                  ),
                  child: ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    title: Row(
                      children: [
                        Icon(
                          Icons.auto_stories,
                          size: 20,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        const Text('Read Full Storyline'),
                      ],
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          game.storyline!,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            height: 1.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickInfoSection(Game game) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium),
      child: Row(
        children: [
          if (game.rating != null)
            Expanded(
              child: _buildInfoCard(
                icon: Icons.star,
                label: 'IGDB Rating',
                value: '${game.rating!.toStringAsFixed(1)}/10',
                color: Colors.amber,
              ),
            ),
          const SizedBox(width: 8),
          if (game.releaseDate != null)
            Expanded(
              child: _buildInfoCard(
                icon: Icons.calendar_today,
                label: 'Release Date',
                value: DateFormatter.formatShortDate(game.releaseDate!),
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Card(
      elevation: 0,
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
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
        ),
      ),
    );
  }

  Widget _buildEnhancedMediaGallery(Game game) {
    final List<Tab> tabs = [];
    final List<Widget> tabViews = [];

    if (game.screenshots.isNotEmpty) {
      tabs.add(Tab(text: 'Screenshots (${game.screenshots.length})'));
      tabViews.add(_buildScreenshotsView(game.screenshots));
    }

    if (game.videos.isNotEmpty) {
      tabs.add(Tab(text: 'Videos (${game.videos.length})'));
      tabViews.add(_buildVideosView(game.videos));
    }

    if (game.artworks.isNotEmpty) {
      tabs.add(Tab(text: 'Artworks (${game.artworks.length})'));
      tabViews.add(_buildArtworksView(game.artworks));
    }

    return Padding(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      child: Card(
        elevation: 0,
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        child: Column(
          children: [
            TabBar(
              controller: _mediaTabController,
              tabs: tabs,
              labelColor: Theme.of(context).colorScheme.primary,
              unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
              indicatorColor: Theme.of(context).colorScheme.primary,
              indicatorWeight: 3,
            ),
            SizedBox(
              height: 250,
              child: TabBarView(
                controller: _mediaTabController,
                children: tabViews,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScreenshotsView(List<String> screenshots) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      itemCount: screenshots.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            child: InkWell(
              onTap: () => _showFullScreenImage(screenshots[index]),
              child: CachedImageWidget(
                imageUrl: ImageUtils.getMediumImageUrl(screenshots[index]),
                width: 350,
                fit: BoxFit.cover,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildVideosView(List<GameVideo> videos) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      itemCount: videos.length,
      itemBuilder: (context, index) {
        final video = videos[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const Icon(Icons.play_circle_filled, size: 40),
            title: Text(video.title ?? 'Unknown'),
            subtitle: Text('Tap to watch on YouTube'),
            onTap: () => _launchUrl('https://youtube.com/watch?v=${video.videoId}'),
          ),
        );
      },
    );
  }

  Widget _buildArtworksView(List<String> artworks) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      itemCount: artworks.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            child: InkWell(
              onTap: () => _showFullScreenImage(artworks[index]),
              child: CachedImageWidget(
                imageUrl: ImageUtils.getMediumImageUrl(artworks[index]),
                width: 350,
                fit: BoxFit.cover,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGameDetailsAccordion(Game game) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      child: Card(
        elevation: 0,
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: Column(
            children: [
              // Platforms & Release Info
              if (game.platforms.isNotEmpty)
                _buildAccordionTile(
                  title: 'Platforms & Release',
                  icon: Icons.devices,
                  child: _buildPlatformsContent(game),
                ),

              // Genres & Categories
              if (game.genres.isNotEmpty || game.themes.isNotEmpty)
                _buildAccordionTile(
                  title: 'Genres & Categories',
                  icon: Icons.category,
                  child: _buildGenresAndCategoriesContent(game),
                ),

              // Game Features
              if (_hasGameFeatures(game))
                _buildAccordionTile(
                  title: 'Game Features',
                  icon: Icons.featured_play_list,
                  child: _buildGameFeaturesContent(game),
                ),

              // Age Ratings
              if (game.ageRatings.isNotEmpty)
                _buildAccordionTile(
                  title: 'Age Ratings',
                  icon: Icons.verified_user,
                  child: _buildAgeRatingsContent(game),
                ),

              // Companies
              if (game.involvedCompanies.isNotEmpty)
                _buildAccordionTile(
                  title: 'Companies',
                  icon: Icons.business,
                  child: CompanySection(companies: game.involvedCompanies),
                ),

              // Keywords
              if (game.keywords.isNotEmpty)
                _buildAccordionTile(
                  title: 'Keywords',
                  icon: Icons.label,
                  child: _buildKeywordsContent(game),
                ),

              // Game Statistics
              _buildAccordionTile(
                title: 'Statistics',
                icon: Icons.analytics,
                child: _buildStatisticsContent(game),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccordionTile({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return ExpansionTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          child: child,
        ),
      ],
    );
  }

  Widget _buildPlatformsContent(Game game) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: game.platforms.length,
            itemBuilder: (context, index) {
              final platform = game.platforms[index];
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Chip(
                  avatar: const Icon(Icons.devices, size: 16),
                  label: Text(platform.name),
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                ),
              );
            },
          ),
        ),
        if (game.releaseDate != null) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 20),
              const SizedBox(width: 8),
              Text(
                'Released: ${DateFormatter.formatFullDate(game.releaseDate!)}',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildGenresAndCategoriesContent(Game game) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (game.genres.isNotEmpty) ...[
          Text(
            'Genres',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: game.genres.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Chip(
                    label: Text(game.genres[index].name),
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  ),
                );
              },
            ),
          ),
        ],
        if (game.themes.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            'Themes',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: game.themes.map((category) {
              return Chip(
                label: Text(
                  category,
                  style: const TextStyle(fontSize: 12),
                ),
                backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildGameFeaturesContent(Game game) {
    final features = <Widget>[];

    if (game.gameModes.isNotEmpty) {
      features.add(_buildFeatureSection('Game Modes', game.gameModes.map((m) => m.name).toList()));
    }

    if (game.playerPerspectives.isNotEmpty) {
      features.add(_buildFeatureSection('Perspectives', game.playerPerspectives.map((p) => p.name).toList()));
    }

    if (game.hasMultiplayer) {
      final multiplayerFeatures = <String>[];
      if (game.hasOnlineMultiplayer) multiplayerFeatures.add('Online Multiplayer');
      if (game.hasLocalMultiplayer) multiplayerFeatures.add('Local Multiplayer');
      features.add(_buildFeatureSection('Multiplayer', multiplayerFeatures));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: features,
    );
  }

  Widget _buildFeatureSection(String title, List<String> items) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: items.map((item) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  item,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontSize: 12,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAgeRatingsContent(Game game) {
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: game.ageRatings.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _buildEnhancedAgeRatingChip(game.ageRatings[index]),
          );
        },
      ),
    );
  }

  Widget _buildEnhancedAgeRatingChip(AgeRating rating) {
    Color chipColor;
    IconData icon;

    switch (rating.category) {
      case AgeRatingCategory.esrb:
        chipColor = Colors.blue;
        icon = Icons.flag;
        break;
      case AgeRatingCategory.pegi:
        chipColor = Colors.green;
        icon = Icons.euro;
        break;
      default:
        chipColor = Colors.grey;
        icon = Icons.public;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        border: Border.all(color: chipColor, width: 2),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: chipColor, size: 20),
          const SizedBox(width: 8),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                rating.displayName,
                style: TextStyle(
                  color: chipColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                rating.category.name.toUpperCase(),
                style: TextStyle(
                  color: chipColor.withOpacity(0.7),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKeywordsContent(Game game) {
    return SizedBox(
      height: 35,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: game.keywords.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: Chip(
              label: Text(
                game.keywords[index].name,
                style: const TextStyle(fontSize: 11),
              ),
              backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
              visualDensity: VisualDensity.compact,
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatisticsContent(Game game) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem(
          icon: Icons.star,
          label: 'IGDB Rating',
          value: game.rating?.toStringAsFixed(1) ?? 'N/A',
          color: Colors.amber,
        ),
        _buildStatItem(
          icon: Icons.people,
          label: 'Popularity',
          value: game.follows?.toStringAsFixed(0) ?? 'N/A',
          color: Theme.of(context).colorScheme.primary,
        ),
        _buildStatItem(
          icon: Icons.trending_up,
          label: 'Hype',
          value: game.hypes?.toStringAsFixed(0) ?? 'N/A',
          color: Colors.red,
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
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

  Widget _buildEnhancedExternalLinksSection(Game game) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      child: Card(
        elevation: 0,
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.link,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'External Links & Stores',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Official Websites
              if (game.websites.isNotEmpty) ...[
                Text(
                  'Official Links',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                ...game.websites.map((website) => _buildLinkTile(
                  title: _getWebsiteName(website.category),
                  icon: _getWebsiteIcon(website.category),
                  onTap: () => _launchUrl(website.url),
                )),
                const SizedBox(height: 16),
              ],

              // External Stores
              if (game.externalGames.isNotEmpty) ...[
                Text(
                  'Available On',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                ...game.externalGames.map((external) => _buildStoreTile(external)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLinkTile({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      color: Theme.of(context).colorScheme.surface,
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title),
        trailing: const Icon(Icons.open_in_new, size: 18),
        onTap: onTap,
      ),
    );
  }

  Widget _buildStoreTile(ExternalGame external) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      color: Theme.of(context).colorScheme.surface,
      child: ListTile(
        leading: Icon(
          _getStoreIcon(external.category),
          color: _getStoreColor(external.category),
        ),
        title: Text(_getStoreName(external.category)),
        subtitle: external.uid != null ? Text('ID: ${external.uid}') : null,
        trailing: const Icon(Icons.open_in_new, size: 18),
        onTap: external.url != null ? () => _launchUrl(external.url!) : null,
      ),
    );
  }

  // Helper methods
  bool _hasGameFeatures(Game game) {
    return game.gameModes.isNotEmpty ||
        game.playerPerspectives.isNotEmpty ||
        game.hasMultiplayer;
  }

  String _getWebsiteName(WebsiteCategory category) {
    switch (category) {
      case WebsiteCategory.official:
        return 'Official Website';
      case WebsiteCategory.wikia:
        return 'Wikia';
      case WebsiteCategory.wikipedia:
        return 'Wikipedia';
      case WebsiteCategory.facebook:
        return 'Facebook';
      case WebsiteCategory.twitter:
        return 'Twitter';
      case WebsiteCategory.twitch:
        return 'Twitch';
      case WebsiteCategory.instagram:
        return 'Instagram';
      case WebsiteCategory.youtube:
        return 'YouTube';
      case WebsiteCategory.reddit:
        return 'Reddit';
      case WebsiteCategory.discord:
        return 'Discord';
      default:
        return 'Website';
    }
  }

  IconData _getWebsiteIcon(WebsiteCategory category) {
    switch (category) {
      case WebsiteCategory.official:
        return Icons.language;
      case WebsiteCategory.wikia:
      case WebsiteCategory.wikipedia:
        return Icons.menu_book;
      case WebsiteCategory.facebook:
      case WebsiteCategory.twitter:
      case WebsiteCategory.instagram:
        return Icons.people;
      case WebsiteCategory.youtube:
      case WebsiteCategory.twitch:
        return Icons.video_library;
      case WebsiteCategory.reddit:
        return Icons.forum;
      case WebsiteCategory.discord:
        return Icons.chat;
      default:
        return Icons.link;
    }
  }

  String _getStoreName(ExternalGameCategory category) {
    switch (category) {
      case ExternalGameCategory.steam:
        return 'Steam';
      case ExternalGameCategory.gog:
        return 'GOG';
      case ExternalGameCategory.epicGames:
        return 'Epic Games';
      case ExternalGameCategory.playstation:
        return 'PlayStation Store';
      case ExternalGameCategory.xbox:
        return 'Xbox Store';
      case ExternalGameCategory.nintendo:
        return 'Nintendo eShop';
      default:
        return 'Store';
    }
  }

  IconData _getStoreIcon(ExternalGameCategory category) {
    switch (category) {
      case ExternalGameCategory.steam:
        return Icons.games;
      case ExternalGameCategory.gog:
      case ExternalGameCategory.epicGames:
        return Icons.shopping_bag;
      case ExternalGameCategory.playstation:
      case ExternalGameCategory.xbox:
      case ExternalGameCategory.nintendo:
        return Icons.sports_esports;
      default:
        return Icons.store;
    }
  }

  Color _getStoreColor(ExternalGameCategory category) {
    switch (category) {
      case ExternalGameCategory.steam:
        return Colors.blue;
      case ExternalGameCategory.gog:
        return Colors.purple;
      case ExternalGameCategory.epicGames:
        return Colors.grey;
      case ExternalGameCategory.playstation:
        return Colors.blue.shade900;
      case ExternalGameCategory.xbox:
        return Colors.green;
      case ExternalGameCategory.nintendo:
        return Colors.red;
      default:
        return Theme.of(context).colorScheme.primary;
    }
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


  void _showFullScreenImage(String imageUrl) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: Center(
            child: InteractiveViewer(
              child: CachedImageWidget(
                imageUrl: ImageUtils.getLargeImageUrl(imageUrl),
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open $url')),
        );
      }
    }
  }
}

//TODO: media section for images and videos not working (images from old detailscreen version) and media gallery like show 5 images and then click on all and get to a new screen, same for videos
