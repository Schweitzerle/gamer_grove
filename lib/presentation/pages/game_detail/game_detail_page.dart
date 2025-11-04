// lib/presentation/pages/game_detail/enhanced_game_detail_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamer_grove/presentation/blocs/auth/auth_state.dart';
import 'package:gamer_grove/presentation/pages/game_detail/widgets/enhanced_media_gallery.dart';
import 'package:gamer_grove/presentation/pages/game_detail/widgets/game_info_card.dart';
import 'package:gamer_grove/presentation/widgets/sections/game_details_accordion.dart';
import 'package:gamer_grove/presentation/widgets/live_loading_progress.dart'; // ✅ Import Live Loading
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/image_utils.dart';
import '../../../core/widgets/cached_image_widget.dart';
import '../../../domain/entities/game/game.dart';
import '../../../injection_container.dart';
import '../../blocs/game/game_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../widgets/sections/character_section.dart';
import '../../widgets/sections/content_dlc_section.dart';
import '../../widgets/sections/events_section.dart';
import '../../widgets/sections/franchise_collection_section.dart';

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

    if (authState is AuthAuthenticated) {
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

    // 🎯 REFRESH CACHE - Ensure home screen shows updated game data
    // This triggers a cache refresh when navigating back from detail screen
    context.read<GameBloc>().add(RefreshCacheEvent());

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
              return _buildLiveLoadingState(); // ✅ NEW: Live Loading
            }

            if (state is GameError) {
              return _buildErrorState(state.message); // ✅ Enhanced Error State
            }

            if (state is GameDetailsLoaded) {
              final game = state.game;
              _initializeMediaTabs(game);
              _logGameDetailsData(game);
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

            return _buildLiveLoadingState(); // ✅ Default to Live Loading
          },
        ),
      ),
    );
  }

  // ✅ NEW: Live Loading State with Console-Style Progress
  Widget _buildLiveLoadingState() {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: Theme.of(context).colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: LiveLoadingProgress(
            title: 'Loading Game Details',
            steps: EventLoadingSteps.gameDetails(context),
            stepDuration: const Duration(
                milliseconds: 1000), // ✅ Slightly faster for games
          ),
        ),
      ),
    );
  }

  // ✅ NEW: Enhanced Error State
  Widget _buildErrorState(String message) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        title: Text(
          'Game Details',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: Theme.of(context).colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Error Icon with Theme Color
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),

              const SizedBox(height: 24),

              // Error Title
              Text(
                'Failed to Load Game',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              // Error Message
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color:
                        Theme.of(context).colorScheme.outline.withOpacity(0.2),
                  ),
                ),
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontFamily:
                            'monospace', // ✅ Console-style for error messages
                      ),
                ),
              ),

              const SizedBox(height: 32),

              // Retry Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _loadGameDetails,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry Loading'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Go Back Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Go Back'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.onSurface,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔄 UPDATE your existing _logGameDetailsData method in game_detail_page.dart:
  void _logGameDetailsData(Game game) {
    print('\n=== 🎮 ENHANCED GAME DETAILS LOADED ===');
    print('🎯 Game: ${game.name} (ID: ${game.id})');

    // 🆕 UPDATED: Characters data with detailed image info
    if (game.characters.isNotEmpty) {
      print(
          '\n👥 CHARACTERS (${game.characters.length}): ✅ CHARACTERS SECTION WILL SHOW');
      print('   📱 UI: Container with Card elevation, preview of 4 characters');
      print(
          '   🔗 Navigation: Tap "View All" → CharactersScreen with filter/sort');

      for (var i = 0; i < game.characters.length && i < 5; i++) {
        final char = game.characters[i];
        print('  • ${char.name} (ID: ${char.id})');

        // 🆕 NEW: Log image information
        if (char.hasImage) {
          print('    🖼️ Image: ✅ Has mugShotImageId: ${char.mugShotImageId}');
          print('    🔗 URL: ${char.imageUrl}');
          print('    📏 Sizes Available: thumb, micro, medium, large');
        } else if (char.hasMugShot) {
          print(
              '    🖼️ Image: ⚠️ Has mugShotId: ${char.mugShot} but no imageId (needs separate fetch)');
        } else {
          print('    🖼️ Image: ❌ No image data available');
        }

        if (char.description != null) {
          print(
              '    📝 Description: ${char.description!.length > 50 ? '${char.description!.substring(0, 50)}...' : char.description}');
        }
      }

      if (game.characters.length > 5) {
        print('  ... and ${game.characters.length - 5} more characters');
      }

      // 🆕 NEW: Summary of image availability
      final charactersWithImages =
          game.characters.where((c) => c.hasImage).length;
      final charactersWithMugShotIds =
          game.characters.where((c) => c.hasMugShot).length;

      print('\n📊 CHARACTER IMAGE SUMMARY:');
      print(
          '   ✅ With Images: $charactersWithImages/${game.characters.length}');
      print(
          '   🔗 With MugShot IDs: $charactersWithMugShotIds/${game.characters.length}');
      print(
          '   📱 UI Ready: ${charactersWithImages > 0 ? 'YES - Images will display' : 'PARTIAL - Fallback icons will show'}');
    } else {
      print('\n👥 CHARACTERS: None found ❌ Characters section hidden');
    }

    print('=== END GAME DETAILS LOG ===\n');
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
                maxLines: 1, // ✅ Same ellipsis fix as EventDetailScreen
                overflow: TextOverflow.ellipsis,
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

            // Game Details Accordion
            _buildGameDetailsAccordion(game),

            CharactersSection(game: game),

            // 🆕 EVENTS SECTION (NEW!)
            if (game.events.isNotEmpty)
              Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingMedium,
                  vertical: AppConstants.paddingMedium,
                ),
                child: Card(
                  elevation: 2,
                  child: EventsSection(
                    game: game,
                    currentUserId: _currentUserId,
                    showViewAll: true,
                    maxDisplayedEvents: 6,
                  ),
                ),
              ),

            FranchiseCollectionsSection(game: game), // Franchises&Collections
            ContentDLCSection(game: game), // 🟢 DLCs & Content
            VersionsRemakesSection(game: game), // 🔵 Versions & Remakes
            SimilarRelatedSection(game: game), // 🟣 Similar & Related

            // Media Gallery with Tabs
            if (game.screenshots.isNotEmpty ||
                game.videos.isNotEmpty ||
                game.artworks.isNotEmpty)
              _buildEnhancedMediaGallery(game),
            const SizedBox(height: 20), // Space for bottom navigation
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedMediaGallery(Game game) {
    return EnhancedMediaGallery(game: game);
  }

  Widget _buildGameDetailsAccordion(Game game) {
    return GameDetailsAccordion(game: game);
  }
}
