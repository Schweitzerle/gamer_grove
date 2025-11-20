// lib/presentation/pages/game_detail/enhanced_game_detail_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamer_grove/core/constants/app_constants.dart';
import 'package:gamer_grove/core/utils/image_utils.dart';
import 'package:gamer_grove/core/widgets/cached_image_widget.dart';
import 'package:gamer_grove/core/widgets/error_widget.dart';
import 'package:gamer_grove/domain/entities/game/game.dart';
import 'package:gamer_grove/injection_container.dart';
import 'package:gamer_grove/presentation/blocs/auth/auth_bloc.dart';
import 'package:gamer_grove/presentation/blocs/auth/auth_state.dart';
import 'package:gamer_grove/presentation/blocs/game/game_bloc.dart';
import 'package:gamer_grove/presentation/blocs/user_game_data/user_game_data_bloc.dart';
import 'package:gamer_grove/presentation/pages/game_detail/widgets/enhanced_media_gallery.dart';
import 'package:gamer_grove/presentation/pages/game_detail/widgets/game_info_card.dart';
import 'package:gamer_grove/presentation/widgets/live_loading_progress.dart'; // ✅ Import Live Loading
import 'package:gamer_grove/presentation/widgets/sections/character_section.dart';
import 'package:gamer_grove/presentation/widgets/sections/content_dlc_section.dart';
import 'package:gamer_grove/presentation/widgets/sections/events_section.dart';
import 'package:gamer_grove/presentation/widgets/sections/franchise_collection_section.dart';
import 'package:gamer_grove/presentation/widgets/sections/game_details_accordion.dart';

class GameDetailPage extends StatefulWidget {

  const GameDetailPage({required this.gameId, super.key});
  final int gameId;

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


    if (authState is AuthAuthenticated) {
      _currentUserId = authState.user.id;
    } else {
    }
  }

  void _loadGameDetails() {

    _gameBloc.add(GetCompleteGameDetailsEvent(
      gameId: widget.gameId,
      userId: _currentUserId,
    ),);
  }

  void _initializeMediaTabs(Game game) {
    var tabCount = 0;
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
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(
          value: _gameBloc,
        ),
        BlocProvider.value(
          value: sl<UserGameDataBloc>(),
        ),
      ],
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
              color: Theme.of(context).colorScheme.onSurface,),
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
                milliseconds: 1000,), // ✅ Slightly faster for games
          ),
        ),
      ),
    );
  }

  // ✅ NEW: Enhanced Error State with Smart Error Detection
  Widget _buildErrorState(String message) {
    // Check if it's a network error
    final isNetworkError = message.toLowerCase().contains('internet') ||
        message.toLowerCase().contains('network') ||
        message.toLowerCase().contains('connection') ||
        message.toLowerCase().contains('timeout');

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
              color: Theme.of(context).colorScheme.onSurface,),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isNetworkError
          ? NetworkErrorWidget(onRetry: _loadGameDetails)
          : CustomErrorWidget(
              message: message,
              onRetry: _loadGameDetails,
            ),
    );
  }

  // 🔄 UPDATE your existing _logGameDetailsData method in game_detail_page.dart:
  void _logGameDetailsData(Game game) {

    // 🆕 UPDATED: Characters data with detailed image info
    if (game.characters.isNotEmpty) {

      for (var i = 0; i < game.characters.length && i < 5; i++) {
        final char = game.characters[i];

        // 🆕 NEW: Log image information
        if (char.hasImage) {
        } else if (char.hasMugShot) {
        } else {
        }

        if (char.description != null) {
        }
      }

      if (game.characters.length > 5) {
      }

    } else {
    }

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
      child: ColoredBox(
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
