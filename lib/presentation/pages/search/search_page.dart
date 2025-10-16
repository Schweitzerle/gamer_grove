// presentation/pages/search/search_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamer_grove/core/utils/navigations.dart';
import '../../../injection_container.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/input_validator.dart';
import '../../../domain/entities/search/search_filters.dart';
import '../../../domain/entities/company/company.dart';
import '../../../domain/entities/game/game_engine.dart';
import '../../../domain/entities/franchise.dart';
import '../../../domain/entities/collection/collection.dart';
import '../../../domain/entities/genre.dart';
import '../../../domain/entities/platform/platform.dart';
import '../../../domain/entities/game/game_mode.dart';
import '../../../domain/entities/player_perspective.dart';
import '../../blocs/game/game_bloc.dart';
import '../../blocs/game/game_extensions.dart'; // For SearchGamesWithFiltersEvent
import '../../widgets/game_card.dart';
import '../../widgets/game_list_shimmer.dart';
import '../../widgets/filter_bottom_sheet.dart';
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

  // Filters
  SearchFilters _currentFilters = const SearchFilters();

  // Available filter options (loaded once)
  List<Genre> _availableGenres = [];
  List<Platform> _availablePlatforms = [];
  List<dynamic> _availableThemes = [];
  List<GameMode> _availableGameModes = [];
  List<PlayerPerspective> _availablePlayerPerspectives = [];

  @override
  void initState() {
    super.initState();
    _gameBloc = sl<GameBloc>();
    _scrollController.addListener(_onScroll);
    _loadRecentSearches();
    _loadFilterOptions();
  }

  Future<void> _loadFilterOptions() async {
    try {
      // TODO: Load genres, platforms, themes, game modes, and player perspectives
      // from the repository. For now, we'll leave them empty and they'll be loaded
      // when the filter sheet is opened if needed.

      // Example:
      // final genresResult = await gameRepository.getAllGenres();
      // genresResult.fold(
      //   (failure) => print('Failed to load genres'),
      //   (genres) => setState(() => _availableGenres = genres),
      // );
    } catch (e) {
      // Handle error silently for now
    }
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
    if (query.trim().isEmpty && !_currentFilters.hasFilters) return;

    final validation = InputValidator.validateSearchQuery(query);
    if (validation != null && query.trim().isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(validation)),
      );
      return;
    }

    if (query.trim().isNotEmpty) {
      _addToRecentSearches(query.trim());
    }

    setState(() {
      _showRecentSearches = false;
    });

    // Use SearchGamesWithFiltersEvent if filters are active
    if (_currentFilters.hasFilters || query.trim().isNotEmpty) {
      _gameBloc.add(SearchGamesWithFiltersEvent(
        query: query.trim(),
        filters: _currentFilters,
      ));
    } else {
      _gameBloc.add(SearchGamesEvent(query.trim()));
    }
  }

  // Dynamic search callbacks for filter bottom sheet
  Future<List<Company>> _searchCompanies(String query) async {
    // TODO: Implement company search using repository
    return [];
  }

  Future<List<GameEngine>> _searchGameEngines(String query) async {
    // TODO: Implement game engine search using repository
    return [];
  }

  Future<List<Franchise>> _searchFranchises(String query) async {
    // TODO: Implement franchise search using repository
    return [];
  }

  Future<List<Collection>> _searchCollections(String query) async {
    // TODO: Implement collection search using repository
    return [];
  }

  void _clearSearch() {
    _searchController.clear();
    _gameBloc.add(ClearSearchEvent());
    setState(() {
      _showRecentSearches = true;
      _currentFilters = const SearchFilters(); // Also reset filters
    });
  }

  int _getActiveFilterCount() {
    int count = 0;
    if (_currentFilters.genreIds.isNotEmpty) count++;
    if (_currentFilters.platformIds.isNotEmpty) count++;
    if (_currentFilters.minRating != null || _currentFilters.maxRating != null)
      count++;
    if (_currentFilters.releaseDateFrom != null ||
        _currentFilters.releaseDateTo != null) count++;
    if (_currentFilters.themesIds.isNotEmpty) count++;
    if (_currentFilters.gameModesIds.isNotEmpty) count++;
    if (_currentFilters.playerPerspectiveIds.isNotEmpty) count++;
    if (_currentFilters.companyIds.isNotEmpty) count++;
    if (_currentFilters.gameEngineIds.isNotEmpty) count++;
    if (_currentFilters.franchiseIds.isNotEmpty) count++;
    if (_currentFilters.collectionIds.isNotEmpty) count++;
    return count;
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
                  : Stack(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.tune_rounded),
                          onPressed: _showFilters,
                        ),
                        if (_currentFilters.hasFilters)
                          Positioned(
                            right: 8,
                            top: 8,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              child: Center(
                                child: Text(
                                  '${_getActiveFilterCount()}',
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
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

          // Active Filters Display
          if (_currentFilters.hasFilters)
            Padding(
              padding: const EdgeInsets.only(top: AppConstants.paddingSmall),
              child: Row(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          Chip(
                            label: Text('${_getActiveFilterCount()} filters'),
                            avatar: const Icon(Icons.filter_alt, size: 16),
                            onDeleted: () {
                              setState(() {
                                _currentFilters = const SearchFilters();
                              });
                              _performSearch(_searchController.text);
                            },
                            deleteIcon: const Icon(Icons.close, size: 16),
                          ),
                          const SizedBox(width: 8),
                          TextButton.icon(
                            onPressed: _showFilters,
                            icon: const Icon(Icons.edit, size: 16),
                            label: const Text('Edit Filters'),
                            style: TextButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                            ),
                          ),
                        ],
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

  void _showFilters() async {
    final result = await FilterBottomSheet.show(
      context: context,
      currentFilters: _currentFilters,
      availableGenres: _availableGenres,
      availablePlatforms: _availablePlatforms,
      availableThemes: _availableThemes,
      availableGameModes: _availableGameModes,
      availablePlayerPerspectives: _availablePlayerPerspectives,
      onSearchCompanies: _searchCompanies,
      onSearchGameEngines: _searchGameEngines,
      onSearchFranchises: _searchFranchises,
      onSearchCollections: _searchCollections,
    );

    if (result != null) {
      setState(() {
        _currentFilters = result;
      });

      // Trigger search with new filters
      _performSearch(_searchController.text);
    }
  }
}
