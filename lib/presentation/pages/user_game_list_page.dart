import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamer_grove/core/constants/app_constants.dart';
import 'package:gamer_grove/core/utils/navigations.dart';
import 'package:gamer_grove/domain/entities/game/game.dart';
import 'package:gamer_grove/injection_container.dart';
import 'package:gamer_grove/presentation/blocs/game/game_bloc.dart';
import 'package:gamer_grove/presentation/widgets/game_card.dart';
import 'package:loading_indicator/loading_indicator.dart';

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
  }

  void _loadInitialData() {
    switch (widget.type) {
      case GameListType.rated:
        context.read<GameBloc>().add(LoadAllUserRatedPaginated(widget.userId));
      case GameListType.wishlist:
        context
            .read<GameBloc>()
            .add(LoadAllUserWishlistPaginated(widget.userId));
      case GameListType.recommended:
        context
            .read<GameBloc>()
            .add(LoadAllUserRecommendedPaginated(widget.userId));
    }
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
                SnackBar(
                  content: const Text(
                    'Sorting and filtering only applies to already loaded games. '
                    'Scroll down to load more games.',
                  ),
                  duration: const Duration(seconds: 4),
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
                if (state is AllUserRatedPaginatedError ||
                    state is AllUserWishlistPaginatedError ||
                    state is AllUserRecommendedPaginatedError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state is AllUserRatedPaginatedError
                          ? state.message
                          : state is AllUserWishlistPaginatedError
                              ? state.message
                              : (state as AllUserRecommendedPaginatedError)
                                  .message),
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is AllUserRatedPaginatedLoading ||
                    state is AllUserWishlistPaginatedLoading ||
                    state is AllUserRecommendedPaginatedLoading) {
                  return const Center(
                    child: LoadingIndicator(
                      indicatorType: Indicator.pacman,
                    ),
                  );
                }

                List<Game>? games;
                var hasReachedMax = false;

                if (state is AllUserRatedPaginatedLoaded) {
                  games = state.games;
                  hasReachedMax = state.hasReachedMax;
                } else if (state is AllUserWishlistPaginatedLoaded) {
                  games = state.games;
                  hasReachedMax = state.hasReachedMax;
                } else if (state is AllUserRecommendedPaginatedLoaded) {
                  games = state.games;
                  hasReachedMax = state.hasReachedMax;
                }

                if (games == null) {
                  return const Center(
                    child: Text('Something went wrong.'),
                  );
                }

                // Apply local filtering and sorting
                final filteredAndSortedGames = _applyFilterAndSort(games);

                if (filteredAndSortedGames.isEmpty) {
                  return _buildEmptyState();
                }

                return _isGridView
                    ? _buildGridView(filteredAndSortedGames, hasReachedMax)
                    : _buildListView(filteredAndSortedGames, hasReachedMax);
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
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
        ),
        onChanged: (query) {
          setState(() {
            _searchQuery = query;
          });
        },
      ),
    );
  }

  Widget _buildGamesCount() {
    return BlocBuilder<GameBloc, GameState>(
      builder: (context, state) {
        List<Game>? allGames;
        if (state is AllUserRatedPaginatedLoaded) {
          allGames = state.games;
        } else if (state is AllUserWishlistPaginatedLoaded) {
          allGames = state.games;
        } else if (state is AllUserRecommendedPaginatedLoaded) {
          allGames = state.games;
        }

        if (allGames == null) return const SizedBox.shrink();

        final filteredCount = _applyFilterAndSort(allGames).length;

        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingMedium,
            vertical: AppConstants.paddingSmall,
          ),
          child: Row(
            children: [
              Text(
                '$filteredCount of ${allGames.length} games',
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
      },
    );
  }

  Widget _buildGridView(List<Game> games, bool hasReachedMax) {
    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: AppConstants.paddingMedium,
        mainAxisSpacing: AppConstants.paddingMedium,
      ),
      itemCount: hasReachedMax ? games.length : games.length + 1,
      itemBuilder: (context, index) {
        if (index >= games.length) {
          return const LoadingIndicator(
            indicatorType: Indicator.pacman,
          );
        }
        final game = games[index];
        return GameCard(
          game: game,
          onTap: () => Navigations.navigateToGameDetail(game.id, context),
        );
      },
    );
  }

  Widget _buildListView(List<Game> games, bool hasReachedMax) {
    return ListView.separated(
      controller: _scrollController,
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      itemCount: hasReachedMax ? games.length : games.length + 1,
      separatorBuilder: (context, index) =>
          const SizedBox(height: AppConstants.paddingSmall),
      itemBuilder: (context, index) {
        if (index >= games.length) {
          return const LoadingIndicator(
            indicatorType: Indicator.pacman,
          );
        }
        final game = games[index];
        return GameCard(
          game: game,
          onTap: () => Navigations.navigateToGameDetail(game.id, context),
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
      case SortCategory.totalRating:
        result.sort((a, b) {
          final aRating = a.totalRating ?? 0;
          final bRating = b.totalRating ?? 0;
          return _sortDirection == SortDirection.ascending
              ? aRating.compareTo(bRating)
              : bRating.compareTo(aRating);
        });
      case SortCategory.igdbUserRating:
        result.sort((a, b) {
          final aRating = a.rating ?? 0;
          final bRating = b.rating ?? 0;
          return _sortDirection == SortDirection.ascending
              ? aRating.compareTo(bRating)
              : bRating.compareTo(aRating);
        });
      case SortCategory.aggregatedRating:
        result.sort((a, b) {
          final aRating = a.aggregatedRating ?? 0;
          final bRating = b.aggregatedRating ?? 0;
          return _sortDirection == SortDirection.ascending
              ? aRating.compareTo(bRating)
              : bRating.compareTo(aRating);
        });
      case SortCategory.userRating:
        result.sort((a, b) {
          final aRating = a.userRating ?? 0;
          final bRating = b.userRating ?? 0;
          return _sortDirection == SortDirection.ascending
              ? aRating.compareTo(bRating)
              : bRating.compareTo(aRating);
        });
      case SortCategory.totalRatingCount:
        result.sort((a, b) {
          final aRating = a.totalRatingCount ?? 0;
          final bRating = b.totalRatingCount ?? 0;
          return _sortDirection == SortDirection.ascending
              ? aRating.compareTo(bRating)
              : bRating.compareTo(aRating);
        });
      case SortCategory.igdbUserRatingCount:
        result.sort((a, b) {
          final aRating = a.ratingCount ?? 0;
          final bRating = b.ratingCount ?? 0;
          return _sortDirection == SortDirection.ascending
              ? aRating.compareTo(bRating)
              : bRating.compareTo(aRating);
        });
      case SortCategory.aggregatedRatingCount:
        result.sort((a, b) {
          final aRating = a.aggregatedRatingCount ?? 0;
          final bRating = b.aggregatedRatingCount ?? 0;
          return _sortDirection == SortDirection.ascending
              ? aRating.compareTo(bRating)
              : bRating.compareTo(aRating);
        });
      case SortCategory.hypes:
        result.sort((a, b) {
          final aHypes = a.hypes ?? 0;
          final bHypes = b.hypes ?? 0;
          return _sortDirection == SortDirection.ascending
              ? aHypes.compareTo(bHypes)
              : bHypes.compareTo(aHypes);
        });
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
      if (isSelected) {
        // Toggle direction if already selected
        setState(() {
          _sortDirection = isAscending
              ? SortDirection.descending
              : SortDirection.ascending;
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
      Navigator.of(context).pop();
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
      switch (widget.type) {
        case GameListType.rated:
          context
              .read<GameBloc>()
              .add(LoadMoreUserRatedPaginated(widget.userId));
        case GameListType.wishlist:
          context
              .read<GameBloc>()
              .add(LoadMoreUserWishlistPaginated(widget.userId));
        case GameListType.recommended:
          context
              .read<GameBloc>()
              .add(LoadMoreUserRecommendedPaginated(widget.userId));
      }
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }
}
