import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_constants.dart';
import '../../../domain/entities/game.dart';
import '../../../injection_container.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/game/game_bloc.dart';
import '../../widgets/game_card.dart';
import '../game_detail/game_detail_page.dart';

class GrovePage extends StatefulWidget {
  const GrovePage({super.key});

  @override
  State<GrovePage> createState() => _GrovePageState();
}

class _GrovePageState extends State<GrovePage> {
  late GameBloc _gameBloc;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _gameBloc = sl<GameBloc>();
    _loadInitialData();
  }

  @override
  void dispose() {
    _gameBloc.close();
    super.dispose();
  }

  void _loadInitialData() {
    // Get current user
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      _currentUserId = authState.user.id;
    }

    // Load all data at once
    _gameBloc.add(LoadGrovePageDataEvent(userId: _currentUserId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _gameBloc,
      child: Scaffold(
        body: RefreshIndicator(
          onRefresh: () async {
            _loadInitialData();
          },
          child: CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                floating: true,
                pinned: false,
                title: Row(
                  children: [
                    Icon(
                      Icons.gamepad_rounded,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    const Text('Gamer Grove'),
                  ],
                ),
              ),


              if (_currentUserId != null)
                SliverToBoxAdapter(
                  child: _buildTopThreeSection(),
                ),

              // Rated Game Section
              if (_currentUserId != null)
              SliverToBoxAdapter(
                child: _buildRatedSection(),
              ),

              // User Wishlist Section (if logged in)
              if (_currentUserId != null)
                SliverToBoxAdapter(
                  child: _buildWishlistSection(),
                ),

              // User Recommendations Section (if logged in)
              if (_currentUserId != null)
                SliverToBoxAdapter(
                  child: _buildRecommendationsSection(),
                ),

              // Bottom padding
              const SliverToBoxAdapter(
                child: SizedBox(height: AppConstants.paddingXLarge),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRatedSection() {
    return BlocBuilder<GameBloc, GameState>(
      builder: (context, state) {
        return _buildGameSection(
          title: 'My Rated',
          subtitle: 'Games you want rated',
          icon: Icons.numbers,
          showViewAll: true,
          onViewAll: () => _navigateToRatedGames(),
          child: _buildRatedContent(state),
        );
      },
    );
  }

  Widget _buildRatedContent(GameState state) {
    if (state is UserRatedLoading || state is GrovePageLoading) {
      return _buildHorizontalGameListSkeleton();
    } else if (state is UserRatedLoaded) {
      if (state.games.isEmpty) {
        return _buildEmptySection('Your ratings is empty');
      }
      return _buildHorizontalGameList(state.games.take(10).toList());
    } else if (state is GrovePageLoaded && state.userRated != null) {
      // ✅ Neu: Reagiere auch auf HomePageLoaded State
      if (state.userRated!.isEmpty) {
        return _buildEmptySection('Your rated is empty');
      }
      return _buildHorizontalGameList(state.userRated!.take(10).toList());
    } else if (state is GameError) {
      return _buildErrorSection('Failed to load rated', () {
        if (_currentUserId != null) {
          _gameBloc.add(LoadUserRatedEvent(_currentUserId!));
        }
      });
    }
    return _buildHorizontalGameListSkeleton();
  }

  Widget _buildWishlistSection() {
    return BlocBuilder<GameBloc, GameState>(
      builder: (context, state) {
        return _buildGameSection(
          title: 'My Wishlist',
          subtitle: 'Games you want to play',
          icon: Icons.favorite,
          showViewAll: true,
          onViewAll: () => _navigateToWishlist(),
          child: _buildWishlistContent(state),
        );
      },
    );
  }

  Widget _buildWishlistContent(GameState state) {
    if (state is UserWishlistLoading || state is GrovePageLoading) { // ✅ GrovePageLoading hinzugefügt
      return _buildHorizontalGameListSkeleton();
    } else if (state is UserWishlistLoaded) {
      if (state.games.isEmpty) {
        return _buildEmptySection('Your wishlist is empty');
      }
      return _buildHorizontalGameList(state.games.take(10).toList());
    } else if (state is GrovePageLoaded && state.userWishlist != null) { // ✅ GrovePageLoaded hinzugefügt
      if (state.userWishlist!.isEmpty) {
        return _buildEmptySection('Your wishlist is empty');
      }
      return _buildHorizontalGameList(state.userWishlist!.take(10).toList());
    } else if (state is HomePageLoaded && state.userWishlist != null) {
      // Backup für HomePageLoaded (falls irgendwo noch verwendet)
      if (state.userWishlist!.isEmpty) {
        return _buildEmptySection('Your wishlist is empty');
      }
      return _buildHorizontalGameList(state.userWishlist!.take(10).toList());
    } else if (state is GameError) {
      return _buildErrorSection('Failed to load wishlist', () {
        if (_currentUserId != null) {
          _gameBloc.add(LoadUserWishlistEvent(_currentUserId!));
        }
      });
    }
    return _buildHorizontalGameListSkeleton();
  }

  Widget _buildRecommendationsSection() {
    return BlocBuilder<GameBloc, GameState>(
      builder: (context, state) {
        return _buildGameSection(
          title: 'Recommended for You',
          subtitle: 'Games you might enjoy',
          icon: Icons.recommend,
          showViewAll: true,
          onViewAll: () => _navigateToRecommendations(),
          child: _buildRecommendationsContent(state),
        );
      },
    );
  }

  Widget _buildRecommendationsContent(GameState state) {
    if (state is UserRecommendationsLoading || state is GrovePageLoading) { // ✅ GrovePageLoading hinzugefügt
      return _buildHorizontalGameListSkeleton();
    } else if (state is UserRecommendationsLoaded) {
      if (state.games.isEmpty) {
        return _buildEmptySection('No recommendations yet');
      }
      return _buildHorizontalGameList(state.games.take(10).toList());
    } else if (state is GrovePageLoaded && state.userRecommendations != null) { // ✅ GrovePageLoaded hinzugefügt
      if (state.userRecommendations!.isEmpty) {
        return _buildEmptySection('No recommendations yet');
      }
      return _buildHorizontalGameList(state.userRecommendations!.take(10).toList());
    } else if (state is HomePageLoaded && state.userRecommendations != null) {
      // Backup für HomePageLoaded (falls irgendwo noch verwendet)
      if (state.userRecommendations!.isEmpty) {
        return _buildEmptySection('No recommendations yet');
      }
      return _buildHorizontalGameList(state.userRecommendations!.take(10).toList());
    } else if (state is GameError) {
      return _buildErrorSection('Failed to load recommendations', () {
        if (_currentUserId != null) {
          _gameBloc.add(LoadUserRecommendationsEvent(_currentUserId!));
        }
      });
    }
    return _buildHorizontalGameListSkeleton();
  }

  Widget _buildGameSection({
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget child,
    bool showViewAll = false,
    VoidCallback? onViewAll,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingMedium,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (showViewAll && onViewAll != null)
                  TextButton(
                    onPressed: onViewAll,
                    child: const Text('View All'),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.paddingSmall),

          // Section Content
          child,
        ],
      ),
    );
  }
  Widget _buildHorizontalGameList(List<Game> games) {
    return SizedBox(
      height: 280,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingMedium,
        ),
        itemCount: games.length,
        itemBuilder: (context, index) {
          final game = games[index];
          return Container(
            width: 160,
            margin: const EdgeInsets.only(right: AppConstants.paddingSmall),
            child: GameCard(
              game: game,
              onTap: () => _navigateToGameDetail(game.id),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHorizontalGameListSkeleton() {
    return SizedBox(
      height: 280,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingMedium,
        ),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Container(
            width: 160,
            margin: const EdgeInsets.only(right: AppConstants.paddingSmall),
            child: Card(
              child: Column(
                children: [
                  Expanded(
                    flex: 3,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(AppConstants.borderRadius),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(AppConstants.paddingSmall),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 16,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 12,
                            width: 80,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptySection(String message) {
    return Container(
      height: 120,
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingMedium,
      ),
      child: Card(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.gamepad_rounded,
                size: 32,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorSection(String message, VoidCallback onRetry) {
    return Container(
      height: 120,
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingMedium,
      ),
      child: Card(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 32,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Retry'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(80, 32),
                  textStyle: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  void _navigateToGameDetail(int gameId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => sl<GameBloc>(),
            ),
            BlocProvider.value(
              value: context.read<AuthBloc>(),
            ),
          ],
          child: GameDetailPage(gameId: gameId),
        ),
      ),
    );
  }

  void _navigateToRatedGames() {
    // TODO: Implement navigation to full popular games list
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Popular games list coming soon!')),
    );
  }

  void _navigateToUpcomingGames() {
    // TODO: Implement navigation to full upcoming games list
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Upcoming games list coming soon!')),
    );
  }

  void _navigateToRecommendations() {
    // TODO: Implement navigation to full recommendations list
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Recommendations list coming soon!')),
    );
  }

  void _navigateToWishlist() {
    // TODO: Implement navigation to full recommendations list
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Wishlist list coming soon!')),
    );
  }


  // Füge diese Methode zu deiner GrovePageState Klasse hinzu:

  Widget _buildTopThreeSection() {
    return BlocBuilder<GameBloc, GameState>(
      builder: (context, state) {
        return _buildGameSection(
          title: 'My Top 3',
          subtitle: 'Your personal favorites',
          icon: Icons.star, // oder Icons.emoji_events für einen Pokal
          showViewAll: false, // Da es nur 3 Games sind, kein "View All" nötig
          child: _buildTopThreeContent(state),
        );
      },
    );
  }

  Widget _buildTopThreeContent(GameState state) {
    if (state is GrovePageLoading) {
      return _buildHorizontalGameListSkeleton();
    } else if (state is GrovePageLoaded) {
      if (state.userTopThree.isEmpty) {
        return _buildEmptyTopThreeSection();
      }
      return _buildTopThreeGameList(state.userTopThree);
    } else if (state is GameError) {
      return _buildErrorSection('Failed to load top games', () {
        if (_currentUserId != null) {
          _gameBloc.add(LoadGrovePageDataEvent(userId:_currentUserId!));
        }
      });
    }
    return _buildHorizontalGameListSkeleton();
  }

  Widget _buildTopThreeGameList(List<Game> games) {
    return SizedBox(
      height: 140, // Etwas höher für die Ranking-Nummern
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingMedium,
        ),
        itemCount: games.length,
        itemBuilder: (context, index) {
          final game = games[index];
          return Container(
            width: 100,
            margin: const EdgeInsets.only(right: AppConstants.paddingSmall),
            child: Column(
              children: [
                // Ranking Badge
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: _getRankingColor(index),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                // Game Card
                Expanded(
                  child: GestureDetector(
                    onTap: () => _navigateToGameDetail(game.id),
                    child: Card(
                      clipBehavior: Clip.antiAlias,
                      child: game.coverUrl != null
                          ? CachedNetworkImage(
                        imageUrl: game.coverUrl!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Theme.of(context).colorScheme.surfaceVariant,
                          child: const Icon(Icons.games),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Theme.of(context).colorScheme.surfaceVariant,
                          child: const Icon(Icons.games),
                        ),
                      )
                          : Container(
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        child: const Icon(Icons.games),
                      ),
                    ),
                  ),
                ),
                // Game Title
                const SizedBox(height: 4),
                Text(
                  game.name,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Color _getRankingColor(int index) {
    switch (index) {
      case 0: return Colors.amber; // Gold für Platz 1
      case 1: return Colors.grey[400]!; // Silber für Platz 2
      case 2: return Colors.brown[400]!; // Bronze für Platz 3
      default: return Colors.black;
    }
  }

  Widget _buildEmptyTopThreeSection() {
    return Container(
      height: 120,
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingMedium,
      ),
      child: Card(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.star_border,
                size: 32,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 8),
              Text(
                'Choose your top 3 favorite games',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                'Tap the star icon on game pages',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
