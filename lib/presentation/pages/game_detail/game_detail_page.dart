// lib/presentation/pages/game_detail/enhanced_game_detail_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamer_grove/presentation/pages/game_detail/widgets/community_info_section.dart';
import 'package:gamer_grove/presentation/pages/game_detail/widgets/enhanced_media_gallery.dart';
import 'package:gamer_grove/presentation/pages/game_detail/widgets/game_description_section.dart';
import 'package:gamer_grove/presentation/pages/game_detail/widgets/game_info_card.dart';
import 'package:gamer_grove/presentation/pages/game_detail/widgets/user_states_section.dart';
import 'package:gamer_grove/presentation/widgets/sections/game_details_accordion.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/image_utils.dart';
import '../../../core/widgets/cached_image_widget.dart';
import '../../../domain/entities/game/game.dart';
import '../../../injection_container.dart';
import '../../blocs/game/game_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../widgets/rating_dialog.dart';
import '../../widgets/sections/content_dlc_section.dart';
import '../../widgets/sections/franchise_collection_section.dart';
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

            // Game Details Accordion
            _buildGameDetailsAccordion(game),

            FranchiseCollectionsSection(game: game), // Franchises&Collections
            ContentDLCSection(game: game),           // 🟢 DLCs & Content
            VersionsRemakesSection(game: game),      // 🔵 Versions & Remakes
            SimilarRelatedSection(game: game),       // 🟣 Similar & Related

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

