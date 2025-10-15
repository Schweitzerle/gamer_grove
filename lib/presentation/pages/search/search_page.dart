// presentation/pages/search/search_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamer_grove/core/utils/navigations.dart';
import '../../../injection_container.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/input_validator.dart';
import '../../blocs/game/game_bloc.dart';
import '../../widgets/game_card.dart';
import '../../widgets/game_list_shimmer.dart';
import '../../../core/widgets/error_widget.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  late GameBloc _gameBloc;

  // Recent searches
  List<String> _recentSearches = [];
  bool _showRecentSearches = true;

  @override
  void initState() {
    super.initState();
    _gameBloc = sl<GameBloc>();
    _scrollController.addListener(_onScroll);
    _loadRecentSearches();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _gameBloc.close();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom && !_gameBloc.state.isLoadingMore) {
      _gameBloc.add(LoadMoreGamesEvent());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  void _loadRecentSearches() {
    // TODO: Load from SharedPreferences
    setState(() {
      _recentSearches = ['The Witcher', 'Cyberpunk', 'Mario', 'Zelda'];
    });
  }

  void _addToRecentSearches(String query) {
    if (query.trim().isEmpty) return;

    setState(() {
      _recentSearches.remove(query);
      _recentSearches.insert(0, query);
      if (_recentSearches.length > 10) {
        _recentSearches = _recentSearches.take(10).toList();
      }
    });

    // TODO: Save to SharedPreferences
  }

  void _performSearch(String query) {
    if (query.trim().isEmpty) return;

    final validation = InputValidator.validateSearchQuery(query);
    if (validation != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(validation)),
      );
      return;
    }

    _addToRecentSearches(query.trim());
    setState(() {
      _showRecentSearches = false;
    });

    _gameBloc.add(SearchGamesEvent(query.trim()));
  }

  void _clearSearch() {
    _searchController.clear();
    _gameBloc.add(ClearSearchEvent());
    setState(() {
      _showRecentSearches = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _gameBloc,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              _buildSearchHeader(),
              Expanded(
                child: BlocConsumer<GameBloc, GameState>(
                  listener: (context, state) {
                    if (state is GameError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.message),
                          backgroundColor: Theme.of(context).colorScheme.error,
                          action: SnackBarAction(
                            label: 'Retry',
                            onPressed: () {
                              if (_searchController.text.isNotEmpty) {
                                _performSearch(_searchController.text);
                              }
                            },
                          ),
                        ),
                      );
                    }
                  },
                  builder: (context, state) {
                    if (_showRecentSearches && state is GameInitial) {
                      return _buildInitialView();
                    } else if (state is GameSearchLoading &&
                        state.games.isEmpty) {
                      return const GameListShimmer();
                    } else if (state is GameSearchLoaded) {
                      return _buildSearchResults(state);
                    } else if (state is GameError && state.games.isEmpty) {
                      return CustomErrorWidget(
                        message: state.message,
                        onRetry: () {
                          if (_searchController.text.isNotEmpty) {
                            _performSearch(_searchController.text);
                          }
                        },
                      );
                    }
                    return _buildInitialView();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchHeader() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Main Search Bar
          TextField(
            controller: _searchController,
            onSubmitted: _performSearch,
            onChanged: (value) {
              // Show recent searches when field becomes empty
              if (value.isEmpty && !_showRecentSearches) {
                setState(() {
                  _showRecentSearches = true;
                });
                _gameBloc.add(ClearSearchEvent());
              }
            },
            decoration: InputDecoration(
              hintText: 'Search for games...',
              prefixIcon: Icon(
                Icons.search_rounded,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded),
                      onPressed: _clearSearch,
                    )
                  : IconButton(
                      icon: const Icon(Icons.tune_rounded),
                      onPressed: _showFilters,
                    ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                ),
              ),
            ),
          ),

          // Search Stats (when showing results)
          BlocBuilder<GameBloc, GameState>(
            builder: (context, state) {
              if (state is GameSearchLoaded && state.games.isNotEmpty) {
                return Padding(
                  padding:
                      const EdgeInsets.only(top: AppConstants.paddingSmall),
                  child: Row(
                    children: [
                      Text(
                        'Found ${state.games.length} games',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                      if (!state.hasReachedMax) ...[
                        const Text(' • '),
                        Text(
                          'Scroll for more',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                      ],
                      const Spacer(),
                      if (state.isLoadingMore)
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInitialView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Section
          Center(
            child: Column(
              children: [
                Icon(
                  Icons.search_rounded,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                ),
                const SizedBox(height: AppConstants.paddingMedium),
                Text(
                  'Discover Games',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: AppConstants.paddingSmall),
                Text(
                  'Search for your favorite games and discover new ones',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: AppConstants.paddingXLarge),

          // Recent Searches
          if (_recentSearches.isNotEmpty) ...[
            Text(
              'Recent Searches',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _recentSearches
                  .map((search) => _buildSearchChip(search))
                  .toList(),
            ),
            const SizedBox(height: AppConstants.paddingLarge),
          ],

          // Popular Searches
          Text(
            'Popular Searches',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppConstants.paddingSmall),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              'The Witcher 3',
              'Cyberpunk 2077',
              'Elden Ring',
              'God of War',
              'Red Dead Redemption',
            ].map((search) => _buildPopularSearchChip(search)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchChip(String search) {
    return InputChip(
      label: Text(search),
      avatar: const Icon(Icons.history, size: 18),
      onPressed: () {
        _searchController.text = search;
        _performSearch(search);
      },
      onDeleted: () {
        setState(() {
          _recentSearches.remove(search);
        });
        // TODO: Save updated recent searches to SharedPreferences
      },
      deleteIcon: const Icon(Icons.close, size: 18),
    );
  }

  Widget _buildPopularSearchChip(String search) {
    return ActionChip(
      label: Text(search),
      avatar: const Icon(Icons.trending_up, size: 18),
      onPressed: () {
        _searchController.text = search;
        _performSearch(search);
      },
    );
  }

  Widget _buildSearchResults(GameSearchLoaded state) {
    if (state.games.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 80,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            Text(
              'No games found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            Text(
              'Try searching for something else or check your spelling',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.paddingLarge),
            OutlinedButton.icon(
              onPressed: _clearSearch,
              icon: const Icon(Icons.refresh),
              label: const Text('Start New Search'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        if (_searchController.text.isNotEmpty) {
          _gameBloc.add(SearchGamesEvent(_searchController.text));
        }
      },
      child: GridView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: AppConstants.gridCrossAxisCount,
          childAspectRatio: AppConstants.gridChildAspectRatio,
          crossAxisSpacing: AppConstants.gridSpacing,
          mainAxisSpacing: AppConstants.gridSpacing,
        ),
        itemCount: state.hasReachedMax
            ? state.games.length
            : state.games.length + 2, // Extra items for loading indicators
        itemBuilder: (context, index) {
          if (index >= state.games.length) {
            return const GameCardShimmer();
          }

          final game = state.games[index];
          return GameCard(
            game: game,
            onTap: () => Navigations.navigateToGameDetail(game.id, context),
          );
        },
      ),
    );
  }

  void _showFilters() {
    // TODO: Implement filters
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Filters coming soon!'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
