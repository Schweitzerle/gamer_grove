// presentation/pages/home/home_page.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_constants.dart';
import '../../../injection_container.dart';
import '../../../domain/entities/game.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/game/game_bloc.dart';
import '../../widgets/game_card.dart';
import '../search/search_page.dart';
import '../test/igdb_test_page.dart';
import '../test/supabase_test_page.dart';
import '../game_detail/game_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomeContent(),
    const SearchPage(),
    const _WishlistContent(),
    const _ProfileContent(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search),
            label: 'Search',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_outline),
            selectedIcon: Icon(Icons.favorite),
            label: 'Wishlist',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
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

    // Load popular and upcoming games
    _gameBloc.add(const LoadPopularGamesEvent(limit: 10));
    _gameBloc.add(const LoadUpcomingGamesEvent(limit: 10));

    // Load user-specific data if logged in
    if (_currentUserId != null) {
      _gameBloc.add(LoadUserWishlistEvent(_currentUserId!));
      _gameBloc.add(LoadUserRecommendationsEvent(_currentUserId!));
    }
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
                actions: [
                  // Debug buttons only in development
                  if (kDebugMode) ...[
                    IconButton(
                      icon: const Icon(Icons.storage),
                      tooltip: 'Supabase Test',
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const SupabaseTestPage(),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.bug_report),
                      tooltip: 'IGDB API Test',
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const IGDBTestPage(),
                          ),
                        );
                      },
                    ),
                  ],
                ],
              ),

              // Header Section
              SliverToBoxAdapter(
                child: _buildHeaderSection(),
              ),

              // Popular Games Section
              SliverToBoxAdapter(
                child: _buildPopularGamesSection(),
              ),

              // Upcoming Games Section
              SliverToBoxAdapter(
                child: _buildUpcomingGamesSection(),
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

  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, authState) {
              if (authState is Authenticated) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back, ${authState.user.username}!',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingSmall),
                    Text(
                      'Discover your next favorite game',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                );
              } else {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Discover Amazing Games',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingSmall),
                    Text(
                      'Find, rate, and track your gaming journey',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                );
              }
            },
          ),
          const SizedBox(height: AppConstants.paddingLarge),

          // Quick Actions
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _navigateToSearch(),
                  icon: const Icon(Icons.search),
                  label: const Text('Search Games'),
                ),
              ),
              const SizedBox(width: AppConstants.paddingMedium),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _navigateToWishlist(),
                  icon: const Icon(Icons.favorite_outline),
                  label: const Text('My Wishlist'),
                ),
              ),
            ],
          ),

          // Debug Actions (only in development)
          if (kDebugMode) ...[
            const SizedBox(height: AppConstants.paddingMedium),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _navigateToSupabaseTest(),
                    icon: const Icon(Icons.storage),
                    label: const Text('Test Supabase'),
                  ),
                ),
                const SizedBox(width: AppConstants.paddingMedium),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _navigateToIGDBTest(),
                    icon: const Icon(Icons.bug_report),
                    label: const Text('Test IGDB'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPopularGamesSection() {
    return BlocBuilder<GameBloc, GameState>(
      builder: (context, state) {
        return _buildGameSection(
          title: 'Popular Right Now',
          subtitle: 'Trending games everyone is playing',
          icon: Icons.trending_up,
          showViewAll: true,
          onViewAll: () => _navigateToPopularGames(),
          child: _buildPopularGamesContent(state),
        );
      },
    );
  }

  Widget _buildPopularGamesContent(GameState state) {
    if (state is PopularGamesLoading) {
      return _buildHorizontalGameListSkeleton();
    } else if (state is PopularGamesLoaded) {
      if (state.games.isEmpty) {
        return _buildEmptySection('No popular games found');
      }
      return _buildHorizontalGameList(state.games);
    } else if (state is GameError) {
      return _buildErrorSection('Failed to load popular games', () {
        _gameBloc.add(const LoadPopularGamesEvent(limit: 10));
      });
    }
    return _buildHorizontalGameListSkeleton();
  }

  Widget _buildUpcomingGamesSection() {
    return BlocBuilder<GameBloc, GameState>(
      builder: (context, state) {
        return _buildGameSection(
          title: 'Coming Soon',
          subtitle: 'Exciting games to look forward to',
          icon: Icons.upcoming,
          showViewAll: true,
          onViewAll: () => _navigateToUpcomingGames(),
          child: _buildUpcomingGamesContent(state),
        );
      },
    );
  }

  Widget _buildUpcomingGamesContent(GameState state) {
    if (state is UpcomingGamesLoading) {
      return _buildHorizontalGameListSkeleton();
    } else if (state is UpcomingGamesLoaded) {
      if (state.games.isEmpty) {
        return _buildEmptySection('No upcoming games found');
      }
      return _buildHorizontalGameList(state.games);
    } else if (state is GameError) {
      return _buildErrorSection('Failed to load upcoming games', () {
        _gameBloc.add(const LoadUpcomingGamesEvent(limit: 10));
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
    if (state is UserWishlistLoading) {
      return _buildHorizontalGameListSkeleton();
    } else if (state is UserWishlistLoaded) {
      if (state.games.isEmpty) {
        return _buildEmptySection('Your wishlist is empty');
      }
      return _buildHorizontalGameList(state.games.take(10).toList());
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
    if (state is UserRecommendationsLoading) {
      return _buildHorizontalGameListSkeleton();
    } else if (state is UserRecommendationsLoaded) {
      if (state.games.isEmpty) {
        return _buildEmptySection('No recommendations yet');
      }
      return _buildHorizontalGameList(state.games.take(10).toList());
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
              onWishlistTap: () => _toggleWishlist(game.id),
              showPlatforms: false,
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

  // Navigation methods
  void _navigateToSearch() {
    // Navigate to search tab or push search page
    // You can implement tab switching or push a new page
  }

  void _navigateToWishlist() {
    // Navigate to wishlist tab
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

  void _navigateToPopularGames() {
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

  void _toggleWishlist(int gameId) {
    if (_currentUserId != null) {
      _gameBloc.add(ToggleWishlistEvent(
        gameId: gameId,
        userId: _currentUserId!,
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to add to wishlist')),
      );
    }
  }

  void _navigateToSupabaseTest() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SupabaseTestPage(),
      ),
    );
  }

  void _navigateToIGDBTest() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const IGDBTestPage(),
      ),
    );
  }
}

class _WishlistContent extends StatelessWidget {
  const _WishlistContent();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Wishlist Page - Coming Soon'),
      ),
    );
  }
}

class _ProfileContent extends StatelessWidget {
  const _ProfileContent();

  @override
  Widget build(BuildContext context) {
    final user = context.select((AuthBloc bloc) {
      final state = bloc.state;
      return state is Authenticated ? state.user : null;
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthBloc>().add(SignOutRequested());
            },
          ),
        ],
      ),
      body: user != null
          ? Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(
                user.username[0].toUpperCase(),
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user.username,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              user.email,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),

            // Debug info
            if (kDebugMode) ...[
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Debug Info',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text('User ID: ${user.id}'),
                      Text('Created: ${user.createdAt}'),
                      Text('Wishlisted Games: ${user.wishlistGameIds.length}'),
                      Text('Rated Games: ${user.gameRatings.length}'),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const IGDBTestPage(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.api),
                        label: const Text('Test IGDB API'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      )
          : const Center(
        child: Text('Not logged in'),
      ),
    );
  }
}