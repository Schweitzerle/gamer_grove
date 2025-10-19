// ==================================================
// PLATFORM PAGINATED GAMES SCREEN
// ==================================================

// lib/presentation/pages/platform/platform_paginated_games_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamer_grove/domain/entities/game/game_sort_options.dart';
import 'package:gamer_grove/presentation/blocs/platform/platform_bloc.dart';
import 'package:gamer_grove/presentation/blocs/platform/platform_event.dart';
import 'package:gamer_grove/presentation/blocs/platform/platform_state.dart';
import 'package:gamer_grove/presentation/widgets/game_card.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/navigations.dart';

class PlatformPaginatedGamesScreen extends StatefulWidget {
  final int platformId;
  final String platformName;
  final String? userId;

  const PlatformPaginatedGamesScreen({
    super.key,
    required this.platformId,
    required this.platformName,
    this.userId,
  });

  @override
  State<PlatformPaginatedGamesScreen> createState() =>
      _PlatformPaginatedGamesScreenState();
}

class _PlatformPaginatedGamesScreenState
    extends State<PlatformPaginatedGamesScreen> {
  late ScrollController _scrollController;
  late TextEditingController _searchController;
  bool _isGridView = true;
  String _searchQuery = '';

  // Available sort options (nur IGDB-basierte Sortierungen)
  static const List<GameSortBy> _availableSortOptions = [
    GameSortBy.name,
    GameSortBy.ratingCount,
    GameSortBy.rating,
    GameSortBy.releaseDate,
    GameSortBy.aggregatedRating,
  ];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _searchController = TextEditingController();
    _scrollController.addListener(_onScroll);

    // Load initial data
    context.read<PlatformBloc>().add(LoadPlatformGamesEvent(
          platformId: widget.platformId,
          platformName: widget.platformName,
          userId: widget.userId,
        ));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isNearBottom) {
      context.read<PlatformBloc>().add(const LoadMorePlatformGamesEvent());
    }
  }

  bool get _isNearBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: _buildAppBar(),
      body: BlocBuilder<PlatformBloc, PlatformState>(
        builder: (context, state) {
          if (state is PlatformGamesLoading) {
            return _buildLoadingState();
          } else if (state is PlatformGamesLoaded) {
            return _buildLoadedState(state);
          } else if (state is PlatformGamesError) {
            return _buildErrorState(state);
          }
          return _buildLoadingState();
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.platformName,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          BlocBuilder<PlatformBloc, PlatformState>(
            builder: (context, state) {
              if (state is PlatformGamesLoaded) {
                return Text(
                  '${state.games.length} games',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      actions: [
        // View Toggle
        IconButton(
          icon: Icon(_isGridView ? Icons.list : Icons.grid_view),
          onPressed: () {
            setState(() {
              _isGridView = !_isGridView;
            });
          },
          tooltip: _isGridView ? 'List view' : 'Grid view',
        ),
        // Sort Button
        IconButton(
          icon: const Icon(Icons.sort),
          onPressed: _showSortDialog,
          tooltip: 'Sort',
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Loading games...',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(PlatformGamesError state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading games',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              state.message,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.read<PlatformBloc>().add(LoadPlatformGamesEvent(
                      platformId: widget.platformId,
                      platformName: widget.platformName,
                      userId: widget.userId,
                      refresh: true,
                    ));
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadedState(PlatformGamesLoaded state) {
    if (state.games.isEmpty) {
      return _buildEmptyState();
    }

    // Filter games based on search query
    final filteredGames = _searchQuery.isEmpty
        ? state.games
        : state.games.where((game) {
            return game.name.toLowerCase().contains(_searchQuery.toLowerCase());
          }).toList();

    return Column(
      children: [
        // Search Bar
        _buildSearchBar(),
        // Sort Info Bar
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingMedium,
            vertical: AppConstants.paddingSmall,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              ),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.sort,
                size: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Text(
                'Sorted by ${state.sortBy.displayName} (${state.sortOrder.displayName})',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const Spacer(),
              if (_searchQuery.isNotEmpty)
                Text(
                  '${filteredGames.length} of ${state.games.length}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
            ],
          ),
        ),
        // Games List/Grid
        Expanded(
          child: filteredGames.isEmpty
              ? _buildNoSearchResults()
              : (_isGridView
                  ? _buildGridView(state.copyWith(games: filteredGames))
                  : _buildListView(state.copyWith(games: filteredGames))),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
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
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  Widget _buildNoSearchResults() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No games found',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'No games match "$_searchQuery"',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _searchQuery = '';
                });
              },
              icon: const Icon(Icons.clear),
              label: const Text('Clear search'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridView(PlatformGamesLoaded state) {
    // Don't show "load more" when searching
    final showLoadMore = state.hasMore && _searchQuery.isEmpty;

    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: AppConstants.paddingMedium,
        mainAxisSpacing: AppConstants.paddingMedium,
      ),
      itemCount: state.games.length + (showLoadMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= state.games.length) {
          return _buildLoadingIndicator(state.isLoadingMore);
        }
        final game = state.games[index];
        return GameCard(
          game: game,
          onTap: () => Navigations.navigateToGameDetail(game.id, context),
        );
      },
    );
  }

  Widget _buildListView(PlatformGamesLoaded state) {
    // Don't show "load more" when searching
    final showLoadMore = state.hasMore && _searchQuery.isEmpty;

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      itemCount: state.games.length + (showLoadMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= state.games.length) {
          return _buildLoadingIndicator(state.isLoadingMore);
        }
        final game = state.games[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppConstants.paddingSmall),
          child: GameCard(
            game: game,
            onTap: () => Navigations.navigateToGameDetail(game.id, context),
          ),
        );
      },
    );
  }

  Widget _buildLoadingIndicator(bool isLoading) {
    if (!isLoading) return const SizedBox.shrink();

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 8),
            Text(
              'Loading more games...',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.videogame_asset,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No games found',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'No games available for ${widget.platformName}',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showSortDialog() {
    final currentState = context.read<PlatformBloc>().state;
    if (currentState is! PlatformGamesLoaded) return;

    // Ensure current sortBy is in available options
    final GameSortBy initialSortBy =
        _availableSortOptions.contains(currentState.sortBy)
            ? currentState.sortBy
            : GameSortBy.ratingCount;
    final SortOrder initialOrder = currentState.sortOrder;

    showDialog<void>(
      context: context,
      builder: (dialogContext) => _SortDialog(
        initialSortBy: initialSortBy,
        initialOrder: initialOrder,
        onApply: (sortBy, order) {
          context.read<PlatformBloc>().add(
                ChangePlatformSortEvent(
                  sortBy: sortBy,
                  sortOrder: order,
                ),
              );
        },
      ),
    );
  }
}

// Separate StatefulWidget for the dialog
class _SortDialog extends StatefulWidget {
  final GameSortBy initialSortBy;
  final SortOrder initialOrder;
  final void Function(GameSortBy, SortOrder) onApply;

  const _SortDialog({
    required this.initialSortBy,
    required this.initialOrder,
    required this.onApply,
  });

  @override
  State<_SortDialog> createState() => _SortDialogState();
}

class _SortDialogState extends State<_SortDialog> {
  late GameSortBy selectedSortBy;
  late SortOrder selectedOrder;

  static const List<GameSortBy> _availableSortOptions = [
    GameSortBy.name,
    GameSortBy.ratingCount,
    GameSortBy.rating,
    GameSortBy.releaseDate,
    GameSortBy.aggregatedRating,
  ];

  @override
  void initState() {
    super.initState();
    selectedSortBy = widget.initialSortBy;
    selectedOrder = widget.initialOrder;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.sort,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          const Text('Sort Games'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sort By Label
          Text(
            'Sort By',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
          const SizedBox(height: 12),
          // Sort By Dropdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.outline,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<GameSortBy>(
                value: selectedSortBy,
                isExpanded: true,
                items: _availableSortOptions.map((sortBy) {
                  return DropdownMenuItem(
                    value: sortBy,
                    child: Text(sortBy.displayName),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedSortBy = value;
                    });
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Sort Order Label
          Text(
            'Order',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
          const SizedBox(height: 12),
          // Sort Order Segmented Button Style
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.outline,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        selectedOrder = SortOrder.ascending;
                      });
                    },
                    borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(8),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: selectedOrder == SortOrder.ascending
                            ? Theme.of(context).colorScheme.primaryContainer
                            : Colors.transparent,
                        borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(8),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.arrow_upward,
                            size: 18,
                            color: selectedOrder == SortOrder.ascending
                                ? Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer
                                : Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Ascending',
                            style: TextStyle(
                              color: selectedOrder == SortOrder.ascending
                                  ? Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer
                                  : Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                              fontWeight: selectedOrder == SortOrder.ascending
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Theme.of(context).colorScheme.outline,
                ),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        selectedOrder = SortOrder.descending;
                      });
                    },
                    borderRadius: const BorderRadius.horizontal(
                      right: Radius.circular(8),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: selectedOrder == SortOrder.descending
                            ? Theme.of(context).colorScheme.primaryContainer
                            : Colors.transparent,
                        borderRadius: const BorderRadius.horizontal(
                          right: Radius.circular(8),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.arrow_downward,
                            size: 18,
                            color: selectedOrder == SortOrder.descending
                                ? Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer
                                : Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Descending',
                            style: TextStyle(
                              color: selectedOrder == SortOrder.descending
                                  ? Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer
                                  : Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                              fontWeight: selectedOrder == SortOrder.descending
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Preview Text
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest
                  .withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _getPreviewText(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          onPressed: () {
            Navigator.pop(context);
            widget.onApply(selectedSortBy, selectedOrder);
          },
          icon: const Icon(Icons.check),
          label: const Text('Apply'),
        ),
      ],
    );
  }

  String _getPreviewText() {
    final isAscending = selectedOrder == SortOrder.ascending;
    switch (selectedSortBy) {
      case GameSortBy.name:
        return isAscending ? 'A → Z' : 'Z → A';
      case GameSortBy.ratingCount:
        return isAscending
            ? 'Least rated → Most rated'
            : 'Most rated → Least rated';
      case GameSortBy.rating:
        return isAscending
            ? 'Lowest rating → Highest rating'
            : 'Highest rating → Lowest rating';
      case GameSortBy.releaseDate:
        return isAscending ? 'Oldest → Newest' : 'Newest → Oldest';
      case GameSortBy.aggregatedRating:
        return isAscending
            ? 'Lowest critic score → Highest critic score'
            : 'Highest critic score → Lowest critic score';
      default:
        return '${selectedSortBy.displayName} (${selectedOrder.displayName})';
    }
  }
}
