import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamer_grove/core/constants/app_constants.dart';
import 'package:gamer_grove/core/utils/navigations.dart';
import 'package:gamer_grove/domain/entities/game/game.dart';
import 'package:gamer_grove/injection_container.dart';
import 'package:gamer_grove/presentation/blocs/auth/auth_bloc.dart';
import 'package:gamer_grove/presentation/blocs/auth/auth_state.dart';
import 'package:gamer_grove/presentation/blocs/game/game_bloc.dart';
import 'package:gamer_grove/presentation/widgets/game_card.dart';
import 'package:gamer_grove/presentation/widgets/game_list_shimmer.dart';

/// Type of game list to display
enum GameListType {
  /// User's rated games
  rated,

  /// User's wishlisted games
  wishlist,

  /// User's recommended games
  recommended,
}

/// Sort category for game list
enum SortCategory {
  name,
  userRating,
  totalRating,
  igdbUserRating,
  aggregatedRating,
  totalRatingCount,
  aggregatedRatingCount,
  igdbUserRatingCount,
  hypes,
  releaseDate,
}

/// Sort direction
enum SortDirection { ascending, descending }

/// Page that displays a user's game list with filtering and sorting
class UserGameListPage extends StatefulWidget {
  /// Creates a user game list page
  const UserGameListPage({
    required this.userId,
    required this.type,
    super.key,
  });

  /// The user ID whose games to display
  final String userId;

  /// The type of game list to display
  final GameListType type;

  /// Creates a route to the user game list page
  static Route<void> route(String userId, GameListType type) {
    return MaterialPageRoute<void>(
      builder: (_) => BlocProvider(
        create: (context) => sl<GameBloc>(),
        child: UserGameListPage(userId: userId, type: type),
      ),
    );
  }

  @override
  _UserGameListPageState createState() => _UserGameListPageState();
}

class _UserGameListPageState extends State<UserGameListPage> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

  // new state variables
  List<Game> _allGames = [];
  List<Game> _filteredAndSortedGames = [];
  List<Game> _displayedGames = [];
  final int _gamesPerAPICall = 20;
  bool _isLoadingMore = false;

  // Filter & Sort state
  String _searchQuery = '';
  SortCategory _sortCategory = SortCategory.name;
  SortDirection _sortDirection = SortDirection.ascending;
  bool _isGridView = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _scrollController.addListener(_onScroll);
    _searchController.addListener(() {
      if (_searchQuery != _searchController.text) {
        setState(() {
          _searchQuery = _searchController.text;
          _resetAndApplyFilters();
        });
      }
    });
  }

  void _loadInitialData() {
    switch (widget.type) {
      case GameListType.rated:
        context.read<GameBloc>().add(LoadAllUserRatedEvent(widget.userId));
        break;
      case GameListType.wishlist:
        context.read<GameBloc>().add(LoadAllUserWishlistEvent(widget.userId));
        break;
      case GameListType.recommended:
        context
            .read<GameBloc>()
            .add(LoadAllUserRecommendationsEvent(widget.userId));
        break;
    }
  }

  void _resetAndApplyFilters() {
    setState(() {
      _filteredAndSortedGames = _applyFilterAndSort(_allGames);
      _displayedGames = _filteredAndSortedGames.take(_gamesPerAPICall).toList();
    });
  }

  String get _title {
    switch (widget.type) {
      case GameListType.rated:
        return 'My Rated Games';
      case GameListType.wishlist:
        return 'My Wishlist';
      case GameListType.recommended:
        return 'My Recommendations';
    }
  }

  String get _emptyMessage {
    switch (widget.type) {
      case GameListType.rated:
        return 'You have not rated any games yet.';
      case GameListType.wishlist:
        return 'You have not wishlisted any games yet.';
      case GameListType.recommended:
        return 'You have not recommended any games yet.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                      'All your games are loaded. Filtering and sorting is done locally.'),
                  duration: Duration(seconds: 4),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            tooltip: 'Info: Local sorting & filtering',
          ),
          IconButton(
            icon: Icon(_isGridView ? Icons.list : Icons.grid_view),
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
            tooltip: _isGridView ? 'List view' : 'Grid view',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildGamesCount(),
          Expanded(
            child: BlocConsumer<GameBloc, GameState>(
              listener: (context, state) {
                if (state is GameError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                    ),
                  );
                } else if (state is AllUserRatedLoaded) {
                  _allGames = state.games;
                  _resetAndApplyFilters();
                } else if (state is AllUserWishlistedLoaded) {
                  _allGames = state.games;
                  _resetAndApplyFilters();
                } else if (state is AllUserRecommendationsLoaded) {
                  _allGames = state.games;
                  _resetAndApplyFilters();
                }
              },
              builder: (context, state) {
                if (state is UserRatedLoading ||
                    state is UserWishlistLoading ||
                    state is UserRecommendationsLoading) {
                  return const GameListShimmer();
                }

                if (_allGames.isEmpty) {
                  return _buildEmptyState();
                }

                if (_filteredAndSortedGames.isEmpty &&
                    _searchQuery.isNotEmpty) {
                  return _buildEmptyState();
                }

                return _isGridView
                    ? _buildGridView(_displayedGames)
                    : _buildListView(_displayedGames);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(AppConstants.paddingMedium),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search games...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
        ),
      ),
    );
  }

  Widget _buildGamesCount() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingMedium,
        vertical: AppConstants.paddingSmall,
      ),
      child: Row(
        children: [
          Text(
            'Showing ${_displayedGames.length} of '
            '${_filteredAndSortedGames.length} games',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: _showSortDialog,
            icon: const Icon(Icons.sort, size: 16),
            label: Text(_getCurrentSortName()),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridView(List<Game> games) {
    final bool hasMore = games.length < _filteredAndSortedGames.length;
    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: AppConstants.paddingMedium,
        mainAxisSpacing: AppConstants.paddingMedium,
      ),
      itemCount: games.length + (hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= games.length) {
          return const Center(child: GameCardShimmer());
        }
        final game = games[index];

        // Get logged-in user ID
        final authState = context.read<AuthBloc>().state;
        final loggedInUserId = authState is AuthAuthenticated ? authState.user.id : null;

        // Only show other user states if viewing a different user's profile
        final isDifferentUser = widget.userId != loggedInUserId;

        return GameCard(
          game: game,
          onTap: () => Navigations.navigateToGameDetail(game.id, context),
          // Pass other user's states only if viewing different user
          otherUserId: isDifferentUser ? widget.userId : null,
          otherUserRating: isDifferentUser ? game.userRating : null,
          otherUserIsWishlisted: isDifferentUser ? game.isWishlisted : null,
          otherUserIsRecommended: isDifferentUser ? game.isRecommended : null,
          otherUserIsInTopThree: isDifferentUser ? game.isInTopThree : null,
          otherUserTopThreePosition: isDifferentUser ? game.topThreePosition : null,
        );
      },
    );
  }

  Widget _buildListView(List<Game> games) {
    final bool hasMore = games.length < _filteredAndSortedGames.length;
    return ListView.separated(
      controller: _scrollController,
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      itemCount: games.length + (hasMore ? 1 : 0),
      separatorBuilder: (context, index) =>
          const SizedBox(height: AppConstants.paddingSmall),
      itemBuilder: (context, index) {
        if (index >= games.length) {
          return const Center(child: GameCardShimmer());
        }
        final game = games[index];

        // Get logged-in user ID
        final authState = context.read<AuthBloc>().state;
        final loggedInUserId = authState is AuthAuthenticated ? authState.user.id : null;

        // Only show other user states if viewing a different user's profile
        final isDifferentUser = widget.userId != loggedInUserId;

        return GameCard(
          game: game,
          onTap: () => Navigations.navigateToGameDetail(game.id, context),
          // Pass other user's states only if viewing different user
          otherUserId: isDifferentUser ? widget.userId : null,
          otherUserRating: isDifferentUser ? game.userRating : null,
          otherUserIsWishlisted: isDifferentUser ? game.isWishlisted : null,
          otherUserIsRecommended: isDifferentUser ? game.isRecommended : null,
          otherUserIsInTopThree: isDifferentUser ? game.isInTopThree : null,
          otherUserTopThreePosition: isDifferentUser ? game.topThreePosition : null,
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.games,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty ? 'No games found' : _emptyMessage,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          if (_searchQuery.isNotEmpty)
            Text(
              'Try adjusting your search.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
        ],
      ),
    );
  }

  List<Game> _applyFilterAndSort(List<Game> games) {
    var result = List<Game>.from(games);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      result = result
          .where(
            (game) =>
                game.name.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }

    // Apply sorting
    switch (_sortCategory) {
      case SortCategory.name:
        result.sort((a, b) => _sortDirection == SortDirection.ascending
            ? a.name.compareTo(b.name)
            : b.name.compareTo(a.name));
        break;
      case SortCategory.totalRating:
        result.sort((a, b) {
          final aRating = a.totalRating ?? 0;
          final bRating = b.totalRating ?? 0;
          return _sortDirection == SortDirection.ascending
              ? aRating.compareTo(bRating)
              : bRating.compareTo(aRating);
        });
        break;
      case SortCategory.igdbUserRating:
        result.sort((a, b) {
          final aRating = a.rating ?? 0;
          final bRating = b.rating ?? 0;
          return _sortDirection == SortDirection.ascending
              ? aRating.compareTo(bRating)
              : bRating.compareTo(aRating);
        });
        break;
      case SortCategory.aggregatedRating:
        result.sort((a, b) {
          final aRating = a.aggregatedRating ?? 0;
          final bRating = b.aggregatedRating ?? 0;
          return _sortDirection == SortDirection.ascending
              ? aRating.compareTo(bRating)
              : bRating.compareTo(aRating);
        });
        break;
      case SortCategory.userRating:
        result.sort((a, b) {
          final aRating = a.userRating ?? 0;
          final bRating = b.userRating ?? 0;
          return _sortDirection == SortDirection.ascending
              ? aRating.compareTo(bRating)
              : bRating.compareTo(aRating);
        });
        break;
      case SortCategory.totalRatingCount:
        result.sort((a, b) {
          final aRating = a.totalRatingCount ?? 0;
          final bRating = b.totalRatingCount ?? 0;
          return _sortDirection == SortDirection.ascending
              ? aRating.compareTo(bRating)
              : bRating.compareTo(aRating);
        });
        break;
      case SortCategory.igdbUserRatingCount:
        result.sort((a, b) {
          final aRating = a.ratingCount ?? 0;
          final bRating = b.ratingCount ?? 0;
          return _sortDirection == SortDirection.ascending
              ? aRating.compareTo(bRating)
              : bRating.compareTo(aRating);
        });
        break;
      case SortCategory.aggregatedRatingCount:
        result.sort((a, b) {
          final aRating = a.aggregatedRatingCount ?? 0;
          final bRating = b.aggregatedRatingCount ?? 0;
          return _sortDirection == SortDirection.ascending
              ? aRating.compareTo(bRating)
              : bRating.compareTo(aRating);
        });
        break;
      case SortCategory.hypes:
        result.sort((a, b) {
          final aHypes = a.hypes ?? 0;
          final bHypes = b.hypes ?? 0;
          return _sortDirection == SortDirection.ascending
              ? aHypes.compareTo(bHypes)
              : bHypes.compareTo(aHypes);
        });
        break;
      case SortCategory.releaseDate:
        result.sort((a, b) {
          if (a.firstReleaseDate == null && b.firstReleaseDate == null) {
            return 0;
          }
          if (a.firstReleaseDate == null) return 1;
          if (b.firstReleaseDate == null) return -1;
          return _sortDirection == SortDirection.ascending
              ? a.firstReleaseDate!.compareTo(b.firstReleaseDate!)
              : b.firstReleaseDate!.compareTo(a.firstReleaseDate!);
        });
        break;
    }

    return result;
  }

  String _getCurrentSortName() {
    switch (_sortCategory) {
      case SortCategory.name:
        return _sortDirection == SortDirection.ascending
            ? 'Name A-Z'
            : 'Name Z-A';
      case SortCategory.totalRating:
        return _sortDirection == SortDirection.ascending
            ? 'Total Rating Low-High'
            : 'Total Rating High-Low';
      case SortCategory.igdbUserRating:
        return _sortDirection == SortDirection.ascending
            ? 'IGDB User Rating Low-High'
            : 'IGDB User Rating High-Low';
      case SortCategory.aggregatedRating:
        return _sortDirection == SortDirection.ascending
            ? 'Critics Rating Low-High'
            : 'Critics Rating High-Low';
      case SortCategory.userRating:
        return _sortDirection == SortDirection.ascending
            ? 'Your Rating Low-High'
            : 'Your Rating High-Low';
      case SortCategory.totalRatingCount:
        return _sortDirection == SortDirection.ascending
            ? 'Total Rating Count Low-High'
            : 'Total Rating Count High-Low';
      case SortCategory.igdbUserRatingCount:
        return _sortDirection == SortDirection.ascending
            ? 'IGDB User Rating Count Low-High'
            : 'IGDB User Rating Count High-Low';
      case SortCategory.aggregatedRatingCount:
        return _sortDirection == SortDirection.ascending
            ? 'Critics Rating Count Low-High'
            : 'Critics Rating Count High-Low';
      case SortCategory.hypes:
        return _sortDirection == SortDirection.ascending
            ? 'Hypes Low-High'
            : 'Hypes High-Low';
      case SortCategory.releaseDate:
        return _sortDirection == SortDirection.ascending
            ? 'Release Date Old-New'
            : 'Release Date New-Old';
    }
  }

  Future<void> _showSortDialog() async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sort by'),
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSortListTile(
                category: SortCategory.name,
                title: 'Name',
                ascText: 'A-Z',
                descText: 'Z-A',
              ),
              _buildSortListTile(
                category: SortCategory.totalRating,
                title: 'Total Rating',
                ascText: 'Low-High',
                descText: 'High-Low',
              ),
              _buildSortListTile(
                category: SortCategory.igdbUserRating,
                title: 'IGDB User Rating',
                ascText: 'Low-High',
                descText: 'High-Low',
              ),
              _buildSortListTile(
                category: SortCategory.aggregatedRating,
                title: 'Critics Rating',
                ascText: 'Low-High',
                descText: 'High-Low',
              ),
              if (widget.type == GameListType.rated)
                _buildSortListTile(
                  category: SortCategory.userRating,
                  title: 'Your Rating',
                  ascText: 'Low-High',
                  descText: 'High-Low',
                ),
              _buildSortListTile(
                category: SortCategory.totalRatingCount,
                title: 'Total Rating Count',
                ascText: 'Low-High',
                descText: 'High-Low',
              ),
              _buildSortListTile(
                category: SortCategory.igdbUserRatingCount,
                title: 'IGDB User Rating Count',
                ascText: 'Low-High',
                descText: 'High-Low',
              ),
              _buildSortListTile(
                category: SortCategory.aggregatedRatingCount,
                title: 'Critics Rating Count',
                ascText: 'Low-High',
                descText: 'High-Low',
              ),
              _buildSortListTile(
                category: SortCategory.hypes,
                title: 'Hypes',
                ascText: 'Low-High',
                descText: 'High-Low',
              ),
              _buildSortListTile(
                category: SortCategory.releaseDate,
                title: 'Release Date',
                ascText: 'Old-New',
                descText: 'New-Old',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildSortListTile({
    required SortCategory category,
    required String title,
    required String ascText,
    required String descText,
  }) {
    final isSelected = _sortCategory == category;
    final isAscending = _sortDirection == SortDirection.ascending;

    void handleTap() {
      Navigator.of(context).pop();
      if (isSelected) {
        // Toggle direction if already selected
        setState(() {
          _sortDirection =
              isAscending ? SortDirection.descending : SortDirection.ascending;
        });
      } else {
        // Set category and default direction
        final newDirection = (category == SortCategory.name)
            ? SortDirection.ascending // Name default A-Z
            : SortDirection.descending; // Rating/Date default High/New
        setState(() {
          _sortCategory = category;
          _sortDirection = newDirection;
        });
      }
      _resetAndApplyFilters();
    }

    return ListTile(
      title: Text(title),
      leading: Radio<SortCategory>(
        value: category,
        groupValue: _sortCategory,
        onChanged: (SortCategory? value) {
          handleTap();
        },
      ),
      trailing: isSelected
          ? TextButton.icon(
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              icon: Icon(
                isAscending ? Icons.arrow_upward : Icons.arrow_downward,
                size: 16,
              ),
              label: Text(
                isAscending ? ascText : descText,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              onPressed: handleTap,
            )
          : null,
      onTap: handleTap,
    );
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      _loadMoreGames();
    }
  }

  void _loadMoreGames() {
    if (_isLoadingMore ||
        _displayedGames.length >= _filteredAndSortedGames.length) {
      return;
    }

    setState(() {
      _isLoadingMore = true;
    });

    // Simulate network delay for a better UX
    Future.delayed(const Duration(milliseconds: 500), () {
      final nextGames = _filteredAndSortedGames
          .skip(_displayedGames.length)
          .take(_gamesPerAPICall)
          .toList();
      setState(() {
        _displayedGames.addAll(nextGames);
        _isLoadingMore = false;
      });
    });
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }
}
