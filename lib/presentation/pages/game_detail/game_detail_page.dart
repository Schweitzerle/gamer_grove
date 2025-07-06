// lib/presentation/pages/game_detail/enhanced_game_detail_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:gamer_grove/presentation/pages/game_detail/widgets/community_info_section.dart';
import 'package:gamer_grove/presentation/pages/game_detail/widgets/company_section.dart';
import 'package:gamer_grove/presentation/pages/game_detail/widgets/dlc_expansion_section.dart';
import 'package:gamer_grove/presentation/pages/game_detail/widgets/enhanced_media_gallery.dart';
import 'package:gamer_grove/presentation/pages/game_detail/widgets/game_description_section.dart';
import 'package:gamer_grove/presentation/pages/game_detail/widgets/game_info_card.dart';
import 'package:gamer_grove/presentation/pages/game_detail/widgets/media_gallery.dart';
import 'package:gamer_grove/presentation/pages/game_detail/widgets/similar_games_section.dart';
import 'package:gamer_grove/presentation/pages/game_detail/widgets/user_states_section.dart';
import 'package:gamer_grove/presentation/widgets/sections/game_details_accordion.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/image_utils.dart';
import '../../../core/widgets/cached_image_widget.dart';
import '../../../domain/entities/externalGame/external_game.dart';
import '../../../domain/entities/game/game.dart';
import '../../../domain/entities/website/website.dart';
import '../../../domain/entities/ageRating/age_rating.dart';
import '../../../domain/entities/website/website_type.dart';
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

    print('🔍 DEBUG: AuthState = ${authState.runtimeType}');

    if (authState is Authenticated) {
      _currentUserId = authState.user.id;
      print('✅ DEBUG: User authenticated, ID = $_currentUserId');
    } else {
      print('❌ DEBUG: User not authenticated, _currentUserId = null');
    }
  }

  void _loadGameDetails() {
    print('🎮 DEBUG: Loading game details...');
    print('📋 DEBUG: gameId = ${widget.gameId}');
    print('👤 DEBUG: userId = $_currentUserId');

    _gameBloc.add(GetCompleteGameDetailsEvent(
      gameId: widget.gameId,
      userId: _currentUserId,
    ));
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
      expandedHeight: 350,
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
    return Stack(
      children: [
        // Horizontaler Gradient (links-rechts)
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              stops: const [0.0, 0.05, 0.95, 1.0],
              colors: [
                Theme.of(context).colorScheme.surface,
                Theme.of(context).colorScheme.surface.withValues(alpha: .2),
                Theme.of(context).colorScheme.surface.withValues(alpha: .2),
                Theme.of(context).colorScheme.surface,
              ],
            ),
          ),
        ),
        // Vertikaler Gradient (oben-unten)
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0.0, 0.05, 0.8, 1.0],
              colors: [
                Theme.of(context).colorScheme.surface,
                Theme.of(context).colorScheme.surface.withValues(alpha: .2),
                Theme.of(context).colorScheme.surface.withValues(alpha: .8),
                Theme.of(context).colorScheme.surface,
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingGameCard(Game game) {
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: GameInfoCard(
        game: game,
      ),
    );
  }


  //Game Content
  Widget _buildGameContent(Game game) {
    return SliverToBoxAdapter(
      child: Container(
        color: Theme.of(context).colorScheme.surface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppConstants.paddingLarge),
            // Quick Info Cards
            _buildCommunityInfoSection(game),

            _buildUserInfoSection(game),

            // Game Description with expandable storyline
            if (game.summary != null) _buildEnhancedDescriptionSection(game),

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
    return GameDescriptionSection(game: game);
  }

  Widget _buildCommunityInfoSection(Game game) {
    return CommunityInfoSection(game: game);
  }

  Widget _buildUserInfoSection(Game game) {
    return UserStatesSection(
      game: game,
      onRatePressed: () => _showRatingDialog(game),
      onToggleWishlist: () => _toggleWishlist(game),
      onToggleRecommend: () => _toggleRecommend(game),
      onAddToTopThree: () => _showTopThreeDialog(game),
    );
  }



  Widget _buildEnhancedMediaGallery(Game game) {
    return EnhancedMediaGallery(game: game);
  }

  Widget _buildGameDetailsAccordion(Game game) {
    return GameDetailsAccordion(game: game);
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
                ...game.externalGames.map((external) => _buildStoreTile(context, external)),
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

  // ===== FIXED STORE TILE WIDGET =====
  Widget _buildStoreTile(BuildContext context, ExternalGame external) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      color: Theme.of(context).colorScheme.surface,
      child: ListTile(
        leading: Icon(
          _getStoreIcon(external.categoryEnum), // FIXED: categoryEnum statt category
          color: _getStoreColor(context, external.categoryEnum), // FIXED: context + categoryEnum
        ),
        title: Text(_getStoreName(external.categoryEnum)), // FIXED: categoryEnum
        subtitle: external.uid.isNotEmpty ? Text('ID: ${external.uid}') : null,
        trailing: const Icon(Icons.open_in_new, size: 18),
        onTap: external.storeUrl != null ? () => _launchUrl(external.storeUrl!) : null, // FIXED: storeUrl
      ),
    );
  }

// ===== WEBSITE HELPER METHODS (FIXED) =====
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
      case WebsiteCategory.steam:
        return 'Steam';
      case WebsiteCategory.epicgames:
        return 'Epic Games';
      case WebsiteCategory.gog:
        return 'GOG';
      case WebsiteCategory.itch:
        return 'itch.io';
      case WebsiteCategory.iphone:
        return 'App Store (iPhone)';
      case WebsiteCategory.ipad:
        return 'App Store (iPad)';
      case WebsiteCategory.android:
        return 'Google Play';
      case WebsiteCategory.bluesky:
        return 'Bluesky';
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
        return Icons.menu_book; // FIXED: menu_book statt menu*book
      case WebsiteCategory.facebook:
        return Icons.facebook;
      case WebsiteCategory.twitter:
        return Icons.alternate_email;
      case WebsiteCategory.instagram:
        return Icons.camera_alt;
      case WebsiteCategory.youtube:
        return Icons.play_circle_fill;
      case WebsiteCategory.twitch:
        return Icons.live_tv;
      case WebsiteCategory.reddit:
        return Icons.forum;
      case WebsiteCategory.discord:
        return Icons.chat;
      case WebsiteCategory.steam:
        return Icons.games;
      case WebsiteCategory.epicgames:
        return Icons.rocket_launch;
      case WebsiteCategory.gog:
        return Icons.shopping_bag;
      case WebsiteCategory.itch:
        return Icons.videogame_asset;
      case WebsiteCategory.iphone:
      case WebsiteCategory.ipad:
        return Icons.phone_iphone;
      case WebsiteCategory.android:
        return Icons.android;
      case WebsiteCategory.bluesky:
        return Icons.cloud;
      default:
        return Icons.link;
    }
  }

  Color _getWebsiteColor(WebsiteCategory category) {
    switch (category) {
      case WebsiteCategory.official:
        return Colors.blue;
      case WebsiteCategory.wikia:
      case WebsiteCategory.wikipedia:
        return Colors.orange;
      case WebsiteCategory.facebook:
        return const Color(0xFF1877F2);
      case WebsiteCategory.twitter:
        return Colors.black;
      case WebsiteCategory.instagram:
        return const Color(0xFFE4405F);
      case WebsiteCategory.youtube:
        return const Color(0xFFFF0000);
      case WebsiteCategory.twitch:
        return const Color(0xFF9146FF);
      case WebsiteCategory.reddit:
        return const Color(0xFFFF4500);
      case WebsiteCategory.discord:
        return const Color(0xFF5865F2);
      case WebsiteCategory.steam:
        return const Color(0xFF1B2838);
      case WebsiteCategory.epicgames:
        return const Color(0xFF0078F2);
      case WebsiteCategory.gog:
        return const Color(0xFF8A2BE2);
      case WebsiteCategory.itch:
        return const Color(0xFFFA5C5C);
      case WebsiteCategory.iphone:
      case WebsiteCategory.ipad:
        return const Color(0xFF007AFF);
      case WebsiteCategory.android:
        return const Color(0xFF3DDC84);
      case WebsiteCategory.bluesky:
        return const Color(0xFF0085FF);
      default:
        return Colors.grey;
    }
  }

// ===== STORE HELPER METHODS (FIXED) =====
  String _getStoreName(ExternalGameCategoryEnum? category) { // FIXED: Parameter type
    if (category == null) return 'Store';

    switch (category) {
      case ExternalGameCategoryEnum.steam: // FIXED: Correct enum reference
        return 'Steam';
      case ExternalGameCategoryEnum.gog:
        return 'GOG';
      case ExternalGameCategoryEnum.epicGameStore: // FIXED: epicGameStore statt epicGames
        return 'Epic Games Store';
      case ExternalGameCategoryEnum.playstationStoreUs: // FIXED: Correct enum name
        return 'PlayStation Store';
      case ExternalGameCategoryEnum.xboxMarketplace: // FIXED: Correct enum name
        return 'Xbox Marketplace';
      case ExternalGameCategoryEnum.microsoft:
        return 'Microsoft Store';
      case ExternalGameCategoryEnum.apple:
        return 'App Store';
      case ExternalGameCategoryEnum.android:
        return 'Google Play';
      case ExternalGameCategoryEnum.itchIo:
        return 'itch.io';
      case ExternalGameCategoryEnum.amazonLuna:
        return 'Amazon Luna';
      case ExternalGameCategoryEnum.oculus:
        return 'Oculus Store';
      case ExternalGameCategoryEnum.twitch:
        return 'Twitch';
      case ExternalGameCategoryEnum.youtube:
        return 'YouTube';
      default:
        return category.displayName; // Fallback auf built-in displayName
    }
  }

  IconData _getStoreIcon(ExternalGameCategoryEnum? category) {
    if (category == null) return Icons.store;

    switch (category) {
      case ExternalGameCategoryEnum.steam:
        return Icons.games;
      case ExternalGameCategoryEnum.gog:
        return Icons.shopping_bag;
      case ExternalGameCategoryEnum.epicGameStore:
        return Icons.rocket_launch;
      case ExternalGameCategoryEnum.playstationStoreUs:
        return Icons.sports_esports;
      case ExternalGameCategoryEnum.xboxMarketplace:
        return Icons.gamepad;
      case ExternalGameCategoryEnum.microsoft:
        return Icons.window;
      case ExternalGameCategoryEnum.apple:
        return Icons.phone_iphone;
      case ExternalGameCategoryEnum.android:
        return Icons.android;
      case ExternalGameCategoryEnum.itchIo:
        return Icons.videogame_asset;
      case ExternalGameCategoryEnum.amazonLuna:
        return Icons.cloud_queue;
      case ExternalGameCategoryEnum.oculus:
        return Icons.view_in_ar;
      case ExternalGameCategoryEnum.twitch:
        return Icons.live_tv;
      case ExternalGameCategoryEnum.youtube:
        return Icons.play_circle_fill;
      default:
        return Icons.store;
    }
  }

  Color _getStoreColor(BuildContext context, ExternalGameCategoryEnum? category) { // FIXED: context parameter
    if (category == null) return Theme.of(context).colorScheme.primary;

    switch (category) {
      case ExternalGameCategoryEnum.steam:
        return const Color(0xFF1B2838);
      case ExternalGameCategoryEnum.gog:
        return const Color(0xFF8A2BE2);
      case ExternalGameCategoryEnum.epicGameStore:
        return const Color(0xFF0078F2);
      case ExternalGameCategoryEnum.playstationStoreUs:
        return const Color(0xFF0070D1);
      case ExternalGameCategoryEnum.xboxMarketplace:
        return const Color(0xFF107C10);
      case ExternalGameCategoryEnum.microsoft:
        return const Color(0xFF00BCF2);
      case ExternalGameCategoryEnum.apple:
        return const Color(0xFF007AFF);
      case ExternalGameCategoryEnum.android:
        return const Color(0xFF3DDC84);
      case ExternalGameCategoryEnum.itchIo:
        return const Color(0xFFFA5C5C);
      case ExternalGameCategoryEnum.amazonLuna:
        return const Color(0xFFFF9900);
      case ExternalGameCategoryEnum.oculus:
        return const Color(0xFF1C1E20);
      case ExternalGameCategoryEnum.twitch:
        return const Color(0xFF9146FF);
      case ExternalGameCategoryEnum.youtube:
        return const Color(0xFFFF0000);
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
    if (_currentUserId != null) {
      _gameBloc.add(
        ToggleWishlistEvent(
          gameId: game.id,
          userId: _currentUserId!,
        ),
      );
    }
  }

  void _toggleRecommend(Game game) {
    if (_currentUserId != null) {
      _gameBloc.add(
        ToggleRecommendEvent(
          gameId: game.id,
          userId: _currentUserId!,
        ),
      );
    }
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

