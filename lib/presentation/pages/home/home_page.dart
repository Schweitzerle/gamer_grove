// presentation/pages/home/home_page.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_constants.dart';
import '../../../injection_container.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/game/game_bloc.dart';
import '../../widgets/game_card.dart';
import '../../widgets/game_list_shimmer.dart';
import '../search/search_page.dart';
import '../game_detail/game_detail_page.dart';
import '../test/igdb_test_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  late PageController _pageController;

  final List<Widget> _pages = [
    const HomeContent(),
    const SearchPage(),
    const WishlistContent(),
    const ProfileContent(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNavigationTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: AppConstants.mediumAnimation,
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onNavigationTap,
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
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _gameBloc = sl<GameBloc>();
    // Load popular games on home page
    _loadPopularGames();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _gameBloc.close();
    super.dispose();
  }

  void _loadPopularGames() {
    // Load popular games using dedicated event
    _gameBloc.add(const LoadPopularGamesEvent(limit: 6));
  }

  @override
  Widget build(BuildContext context) {
    final user = context.select((AuthBloc bloc) {
      final state = bloc.state;
      return state is Authenticated ? state.user : null;
    });

    return BlocProvider.value(
      value: _gameBloc,
      child: Scaffold(
        body: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // App Bar
            SliverAppBar(
              expandedHeight: 120,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'Gamer Grove',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.primaryContainer,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),
              actions: [
                // Debug button only in development
                if (kDebugMode)
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
            ),

            // Welcome Section
            if (user != null)
              SliverToBoxAdapter(
                child: _buildWelcomeSection(context, user),
              ),

            // Quick Actions
            SliverToBoxAdapter(
              child: _buildQuickActions(context),
            ),

            // Popular Games Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.paddingMedium),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Popular Games',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // Navigate to search with popular filter
                        _navigateToSearch();
                      },
                      child: const Text('See All'),
                    ),
                  ],
                ),
              ),
            ),

            // Games Grid
            BlocBuilder<GameBloc, GameState>(
              builder: (context, state) {
                if (state is PopularGamesLoading) {
                  return const SliverToBoxAdapter(
                    child: SizedBox(
                      height: 400,
                      child: GameListShimmer(),
                    ),
                  );
                } else if (state is PopularGamesLoaded) {
                  return _buildGamesGrid(state.games.take(6).toList());
                } else if (state is GameError) {
                  return SliverToBoxAdapter(
                    child: _buildErrorWidget(context, state.message),
                  );
                }
                return const SliverToBoxAdapter(
                  child: SizedBox(height: 400),
                );
              },
            ),

            // Footer
            SliverToBoxAdapter(
              child: _buildFooter(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context, user) {
    return Container(
      margin: const EdgeInsets.all(AppConstants.paddingMedium),
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primaryContainer,
            Theme.of(context).colorScheme.secondaryContainer,
          ],
        ),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 30,
            backgroundColor: Theme.of(context).colorScheme.primary,
            backgroundImage: user.hasAvatar ? NetworkImage(user.avatarUrl!) : null,
            child: !user.hasAvatar
                ? Text(
              user.initials,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            )
                : null,
          ),

          const SizedBox(width: AppConstants.paddingMedium),

          // Welcome Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back,',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  user.username,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (user.totalGamesRated > 0)
                  Text(
                    'You\'ve rated ${user.totalGamesRated} games',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppConstants.paddingSmall),
          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  context,
                  icon: Icons.search,
                  title: 'Search Games',
                  subtitle: 'Find your next favorite',
                  onTap: _navigateToSearch,
                ),
              ),
              const SizedBox(width: AppConstants.paddingSmall),
              Expanded(
                child: _buildActionCard(
                  context,
                  icon: Icons.favorite,
                  title: 'My Wishlist',
                  subtitle: 'Games you want to play',
                  onTap: _navigateToWishlist,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingMedium),
        ],
      ),
    );
  }

  Widget _buildActionCard(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String subtitle,
        required VoidCallback onTap,
      }) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          child: Column(
            children: [
              Icon(
                icon,
                size: 32,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: AppConstants.paddingSmall),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGamesGrid(List games) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: AppConstants.gridCrossAxisCount,
          childAspectRatio: AppConstants.gridChildAspectRatio,
          crossAxisSpacing: AppConstants.gridSpacing,
          mainAxisSpacing: AppConstants.gridSpacing,
        ),
        delegate: SliverChildBuilderDelegate(
              (context, index) {
            final game = games[index];
            return GameCard(
              game: game,
              onTap: () => _navigateToGameDetail(game.id),
              onWishlistTap: () => _toggleWishlist(game.id),
            );
          },
          childCount: games.length,
        ),
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context, String message) {
    return Container(
      height: 200,
      margin: const EdgeInsets.all(AppConstants.paddingMedium),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: AppConstants.paddingSmall),
              Text(
                'Failed to load games',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                message,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.paddingMedium),
              ElevatedButton.icon(
                onPressed: _loadPopularGames,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      child: Column(
        children: [
          const Divider(),
          const SizedBox(height: AppConstants.paddingMedium),
          Text(
            'Gamer Grove v${AppConstants.appVersion}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            'Powered by IGDB',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToSearch() {
    // Change to search tab
    final homeState = context.findAncestorStateOfType<_HomePageState>();
    homeState?._onNavigationTap(1);
  }

  void _navigateToWishlist() {
    // Change to wishlist tab
    final homeState = context.findAncestorStateOfType<_HomePageState>();
    homeState?._onNavigationTap(2);
  }

  void _navigateToGameDetail(int gameId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => GameDetailPage(gameId: gameId),
      ),
    );
  }

  void _toggleWishlist(int gameId) {
    // TODO: Implement wishlist toggle with current user
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Wishlist feature will be implemented next!'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

class WishlistContent extends StatelessWidget {
  const WishlistContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Wishlist'),
        centerTitle: true,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_outline,
              size: 80,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Your Wishlist is Empty',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'Add games you want to play to your wishlist',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileContent extends StatelessWidget {
  const ProfileContent({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.select((AuthBloc bloc) {
      final state = bloc.state;
      return state is Authenticated ? state.user : null;
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
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
          ? SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          children: [
            // Profile Header
            _buildProfileHeader(context, user),
            const SizedBox(height: AppConstants.paddingLarge),

            // Stats Cards
            _buildStatsCards(context, user),
            const SizedBox(height: AppConstants.paddingLarge),

            // Actions
            _buildActionsList(context),

            // Debug info
            if (kDebugMode) ...[
              const SizedBox(height: AppConstants.paddingLarge),
              _buildDebugInfo(context, user),
            ],
          ],
        ),
      )
          : const Center(
        child: Text('Not logged in'),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          children: [
            // Avatar
            CircleAvatar(
              radius: 50,
              backgroundColor: Theme.of(context).colorScheme.primary,
              backgroundImage: user.hasAvatar ? NetworkImage(user.avatarUrl!) : null,
              child: !user.hasAvatar
                  ? Text(
                user.initials,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              )
                  : null,
            ),
            const SizedBox(height: AppConstants.paddingMedium),

            // User Info
            Text(
              user.username,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            Text(
              user.email,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            if (user.hasBio) ...[
              const SizedBox(height: AppConstants.paddingSmall),
              Text(
                user.bio!,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
            if (user.hasCountry) ...[
              const SizedBox(height: AppConstants.paddingSmall),
              Text(
                user.country!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCards(BuildContext context, user) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            'Games Rated',
            user.totalGamesRated.toString(),
            Icons.star,
          ),
        ),
        const SizedBox(width: AppConstants.paddingSmall),
        Expanded(
          child: _buildStatCard(
            context,
            'Wishlist',
            user.wishlistCount.toString(),
            Icons.favorite,
          ),
        ),
        const SizedBox(width: AppConstants.paddingSmall),
        Expanded(
          child: _buildStatCard(
            context,
            'Following',
            user.followingCount.toString(),
            Icons.people,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String label, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          children: [
            Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsList(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit Profile'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Navigate to edit profile
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Edit Profile - Coming Soon!')),
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Navigate to settings
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings - Coming Soon!')),
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Help & Support'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Navigate to help
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Help & Support - Coming Soon!')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDebugInfo(BuildContext context, user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Debug Info',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            Text('User ID: ${user.id}'),
            Text('Created: ${user.createdAt}'),
            Text('Recommended Games: ${user.recommendedCount}'),
            Text('Average Rating: ${user.averageRating.toStringAsFixed(1)}'),
            const SizedBox(height: AppConstants.paddingMedium),
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
    );
  }
}