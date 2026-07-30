// lib/presentation/pages/game_detail/enhanced_game_detail_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamer_grove/core/constants/app_constants.dart';
import 'package:gamer_grove/core/theme/gg_detail_light.dart';
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
import 'package:gamer_grove/presentation/widgets/entity_detail/entity_hero_overlays.dart';
import 'package:gamer_grove/presentation/widgets/loading/live_loading_progress.dart';
import 'package:gamer_grove/presentation/widgets/loading/loading_steps.dart'; // ✅ Import Live Loading
import 'package:gamer_grove/presentation/widgets/sections/chamber_tint.dart';
import 'package:gamer_grove/presentation/widgets/sections/character_section.dart';
import 'package:gamer_grove/presentation/widgets/sections/events_section.dart';
import 'package:gamer_grove/presentation/widgets/sections/franchise_collection_section.dart';
import 'package:gamer_grove/presentation/widgets/sections/game_details_accordion.dart';
import 'package:gamer_grove/presentation/widgets/sections/related_games/content_dlc_section.dart';
import 'package:gamer_grove/presentation/widgets/sections/related_games/similar_related_section.dart';
import 'package:gamer_grove/presentation/widgets/sections/related_games/versions_remakes_section.dart';

class GameDetailPage extends StatefulWidget {
  const GameDetailPage({required this.gameId, this.knownGame, super.key});

  final int gameId;

  /// What the card that was tapped already knew — cover, name, rating, genres.
  ///
  /// The page used to throw this away and load from nothing, so the reveal
  /// opened onto a spinner: a transition that by construction could not reveal
  /// anything. With it the head of the page is drawn on the first frame and
  /// only the rest waits, which is also what makes the arriving colour the
  /// colour of the cover you touched.
  ///
  /// Null when there was nothing to hand over — a deep link, or a caller that
  /// only has an id. The page then loads as it always did.
  final Game? knownGame;

  @override
  State<GameDetailPage> createState() => _GameDetailPageState();
}

class _GameDetailPageState extends State<GameDetailPage>
    with TickerProviderStateMixin {
  String? _currentUserId;
  late GameBloc _gameBloc;

  /// Only exists once a game with media has arrived.
  ///
  /// It was `late` and disposed unconditionally, so leaving the page for a game
  /// with no screenshots, videos or artworks threw a
  /// `LateInitializationError` — and so did leaving it before the request came
  /// back, which the preview state made easy to reach.
  TabController? _mediaTabController;
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

  /// The Grove's own bloc, held so the cache can be refreshed on the way out.
  ///
  /// Captured here rather than read in `dispose`: looking up an ancestor from a
  /// deactivated element is unsafe and throws once the page is torn down at the
  /// wrong moment — leaving before the request returned was enough.
  GameBloc? _callerBloc;

  void _setupBloc() {
    _gameBloc = sl<GameBloc>();
    _callerBloc = context.read<GameBloc>();
    final authState = context.read<AuthBloc>().state;

    if (authState is AuthAuthenticated) {
      _currentUserId = authState.user.id;
    }
  }

  void _loadGameDetails() {
    _gameBloc.add(
      GetCompleteGameDetailsEvent(
        gameId: widget.gameId,
        userId: _currentUserId,
      ),
    );
  }

  void _initializeMediaTabs(Game game) {
    var tabCount = 0;
    if (game.screenshots.isNotEmpty) tabCount++;
    if (game.videos.isNotEmpty) tabCount++;
    if (game.artworks.isNotEmpty) tabCount++;

    if (tabCount == 0) return;
    if (_mediaTabController?.length == tabCount) return;
    _mediaTabController?.dispose();
    _mediaTabController = TabController(length: tabCount, vsync: this);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _mediaTabController?.dispose();

    // Refresh the cache so the Grove shows updated game data on the way back.
    _callerBloc?.add(RefreshCacheEvent());

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
              // Everything the tapped card knew is already on screen; only what
              // it could not know is still coming.
              final known = widget.knownGame;
              if (known != null) return _buildPreview(known);
              return _buildLiveLoadingState();
            }

            if (state is GameError) {
              return _buildErrorState(state.message); // ✅ Enhanced Error State
            }

            if (state is GameDetailsLoaded) {
              final game = state.game;
              _initializeMediaTabs(game);
              // The page takes its light from the cover it is about, the same
              // way a chamber of the Grove takes its light from the covers
              // standing in it.
              return ChamberTint(
                coverUrls: [game.coverUrl],
                builder: (context, tint) => CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    _buildSliverAppBar(game, tint),
                    _buildGameContent(game, tint),
                  ],
                ),
              );
            }

            final known = widget.knownGame;
            if (known != null) return _buildPreview(known);
            return _buildLiveLoadingState();
          },
        ),
      ),
    );
  }

  /// The page as far as the tapped card could describe it.
  ///
  /// The same hero and the same light as the finished page — it is the same
  /// page, with the parts that need a request still on their way. Under it a
  /// row of placeholders, so the arriving sections push nothing around.
  Widget _buildPreview(Game game) {
    return ChamberTint(
      coverUrls: [game.coverUrl],
      builder: (context, tint) => CustomScrollView(
        controller: _scrollController,
        slivers: [
          _buildSliverAppBar(game, tint),
          SliverToBoxAdapter(
            child: ColoredBox(
              color: Theme.of(context).colorScheme.surface,
              child: Stack(
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: DetailLight.reach,
                    child: _ArrivingLight(tint: tint),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      top: AppConstants.paddingLarge,
                    ),
                    child: Semantics(
                      label: 'Loading the rest of ${game.name}',
                      liveRegion: true,
                      child: const _PendingSections(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).colorScheme.onSurface,
          ),
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
              milliseconds: 1000,
            ), // ✅ Slightly faster for games
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
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).colorScheme.onSurface,
          ),
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

  Widget _buildSliverAppBar(Game game, Color tint) {
    return SliverAppBar(
      expandedHeight: 350,
      pinned: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            _buildHeroImage(game),
            EntityHeroOverlays(tint: tint),
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
    // No `Hero` here any more. It carried the tag `game_cover_<id>` with no
    // partner anywhere in the app, so it never flew; and giving it one would
    // throw the moment a game stood in two of the Grove's rows at once.
    // `GGRevealRoute` does the flight without needing unique tags.
    final scheme = Theme.of(context).colorScheme;
    return CachedImageWidget(
      imageUrl: ImageUtils.getLargeImageUrl(game.coverUrl),
      placeholder: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              scheme.primary.withValues(alpha: 0.8),
              scheme.secondary.withValues(alpha: 0.8),
            ],
          ),
        ),
        child: const SizedBox.expand(),
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
      ),
    );
  }

  //Game Content
  Widget _buildGameContent(Game game, Color tint) {
    return SliverToBoxAdapter(
      child: ColoredBox(
        color: Theme.of(context).colorScheme.surface,
        child: Stack(
          children: [
            // Over the page's own surface and under its content: behind the
            // opaque surface the light would not show at all, in front of the
            // content it would tint the text along with the background.
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: DetailLight.reach,
              child: _ArrivingLight(tint: tint),
            ),
            _buildContentColumn(game),
          ],
        ),
      ),
    );
  }

  Widget _buildContentColumn(Game game) {
    return Column(
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
    );
  }

  Widget _buildEnhancedMediaGallery(Game game) {
    return EnhancedMediaGallery(game: game);
  }

  Widget _buildGameDetailsAccordion(Game game) {
    return GameDetailsAccordion(game: game);
  }
}

/// The page's light, rising as the page arrives.
///
/// This is the half of the opening that makes it ours. A container transform on
/// its own is the Material convention — the cover grows, the page is there. The
/// light coming up *behind* the cover while it lands is what turns the
/// transition into the explanation for why this page is that colour.
///
/// It reads the route's own animation rather than running a controller of its
/// own, so the two cannot drift apart, and it costs nothing on a page that was
/// not pushed with a reveal.
class _ArrivingLight extends StatelessWidget {
  const _ArrivingLight({required this.tint});

  final Color tint;

  /// The light starts once the cover is most of the way home.
  static const _startsAt = 0.45;

  @override
  Widget build(BuildContext context) {
    final route = ModalRoute.of(context);
    if (route == null || MediaQuery.disableAnimationsOf(context)) {
      return DetailLight(tint: tint);
    }

    return AnimatedBuilder(
      animation: route.animation ?? kAlwaysCompleteAnimation,
      builder: (context, _) {
        final t = route.animation?.value ?? 1;
        final rise = ((t - _startsAt) / (1 - _startsAt)).clamp(0.0, 1.0);
        return DetailLight(
          tint: tint,
          intensity: Curves.easeOut.transform(rise),
        );
      },
    );
  }
}

/// Placeholders for the sections that are still on their way.
///
/// Shaped like what replaces them, so nothing jumps when the request lands.
class _PendingSections extends StatelessWidget {
  const _PendingSections();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return ExcludeSemantics(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final width in const [0.45, 0.6, 0.35])
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppConstants.paddingMedium,
                0,
                AppConstants.paddingMedium,
                AppConstants.paddingLarge,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FractionallySizedBox(
                    widthFactor: width,
                    child: Container(
                      height: 14,
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(7),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),
                  SizedBox(
                    height: 180,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 3,
                      separatorBuilder: (_, __) =>
                          const SizedBox(width: AppConstants.paddingMedium),
                      itemBuilder: (context, _) => Container(
                        width: 120,
                        decoration: BoxDecoration(
                          color: scheme.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
