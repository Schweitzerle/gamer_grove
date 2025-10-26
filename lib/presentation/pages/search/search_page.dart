// presentation/pages/search/search_page.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamer_grove/core/utils/navigations.dart';
import 'package:gamer_grove/domain/entities/ageRating/age_rating.dart';
import 'package:gamer_grove/domain/entities/collection/collection.dart';
import 'package:gamer_grove/domain/entities/game/game_status.dart';
import 'package:gamer_grove/domain/entities/game/game_type.dart';
import 'package:gamer_grove/domain/entities/keyword.dart';
import 'package:gamer_grove/domain/entities/language/language.dart';
import 'package:gamer_grove/domain/entities/theme.dart' as gg_theme;
import 'package:loading_indicator/loading_indicator.dart';
import '../../../injection_container.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/input_validator.dart';
import '../../../domain/entities/search/search_filters.dart';
import '../../../domain/entities/company/company.dart';
import '../../../domain/entities/game/game_engine.dart';
import '../../../domain/entities/franchise.dart';
import '../../../domain/entities/genre.dart';
import '../../../domain/entities/platform/platform.dart';
import '../../../domain/entities/game/game_mode.dart';
import '../../../domain/entities/player_perspective.dart';
import '../../../domain/repositories/game_repository.dart';
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
  bool _isLoadingFilterOptions = true;

  // Available filter options (loaded once)
  List<Genre> _availableGenres = [];
  List<GameMode> _availableGameModes = [];
  List<PlayerPerspective> _availablePlayerPerspectives = [];
  List<GameType> _availableGameTypes = [];
  List<GameStatus> _availableGameStatuses = [];

  @override
  void initState() {
    super.initState();
    _gameBloc = sl<GameBloc>();
    _scrollController.addListener(_onScroll);
    _loadRecentSearches();
    _loadFilterOptions();
  }

  Future<void> _loadFilterOptions() async {
    print('📦 SearchPage: Loading filter options...');
    try {
      final repository = sl<GameRepository>();

      // Load Genres
      print('📦 SearchPage: Loading genres...');
      final genresResult = await repository.getAllGenres();
      genresResult.fold(
        (failure) =>
            print('❌ SearchPage: Failed to load genres: ${failure.message}'),
        (genres) {
          setState(() => _availableGenres = genres);
          print('✅ SearchPage: Loaded ${genres.length} genres');
        },
      );

      // Load Player Perspectives
      print('📦 SearchPage: Loading player perspectives...');
      final playerPerspectivesResult =
          await repository.getAllPlayerPerspectives();
      playerPerspectivesResult.fold(
        (failure) => print(
            '❌ SearchPage: Failed to load player perspectives: ${failure.message}'),
        (perspectives) {
          setState(() => _availablePlayerPerspectives = perspectives);
          print(
              '✅ SearchPage: Loaded ${perspectives.length} player perspectives');
        },
      );

      // Load Game Types
      print('📦 SearchPage: Loading game types...');
      final gameTypesResult = await repository.getAllGameTypes();
      gameTypesResult.fold(
        (failure) => print(
            '❌ SearchPage: Failed to load game types: ${failure.message}'),
        (types) {
          setState(() => _availableGameTypes = types);
          print('✅ SearchPage: Loaded ${types.length} game types');
        },
      );

      // Load Game Statuses
      print('📦 SearchPage: Loading game statuses...');
      final gameStatusesResult = await repository.getAllGameStatuses();
      gameStatusesResult.fold(
        (failure) => print(
            '❌ SearchPage: Failed to load game statuses: ${failure.message}'),
        (statuses) {
          setState(() => _availableGameStatuses = statuses);
          print('✅ SearchPage: Loaded ${statuses.length} game statuses');
        },
      );

      // Load Game Modes
      print('📦 SearchPage: Loading game modes...');
      final gameModesResult = await repository.getAllGameModes();
      gameModesResult.fold(
        (failure) => print(
            '❌ SearchPage: Failed to load game modes: ${failure.message}'),
        (modes) {
          setState(() => _availableGameModes = modes);
          print('✅ SearchPage: Loaded ${modes.length} game modes');
        },
      );

      print('✅ SearchPage: All filter options loaded');
      setState(() => _isLoadingFilterOptions = false);
    } catch (e) {
      print('❌ SearchPage: Exception loading filter options: $e');
      setState(() => _isLoadingFilterOptions = false);
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
    // If both query and filters are empty, show initial view
    if (query.trim().isEmpty && !_currentFilters.hasFilters) {
      setState(() {
        _showRecentSearches = true;
      });
      _gameBloc.add(ClearSearchEvent());
      return;
    }

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
    print('🔍 SearchPage: Searching companies with query: "$query"');
    try {
      final result = await sl<GameRepository>().getCompanies(search: query);
      return result.fold(
        (failure) {
          print('❌ SearchPage: Failed to search companies: ${failure.message}');
          return <Company>[];
        },
        (companies) {
          print('✅ SearchPage: Found ${companies.length} companies');
          return companies;
        },
      );
    } catch (e) {
      print('❌ SearchPage: Exception searching companies: $e');
      return [];
    }
  }

  Future<List<GameEngine>> _searchGameEngines(String query) async {
    print('🔍 SearchPage: Searching game engines with query: "$query"');
    try {
      final result = await sl<GameRepository>().searchGameEngines(query);
      return result.fold(
        (failure) {
          print(
              '❌ SearchPage: Failed to search game engines: ${failure.message}');
          return <GameEngine>[];
        },
        (engines) {
          print('✅ SearchPage: Found ${engines.length} game engines');
          return engines;
        },
      );
    } catch (e) {
      print('❌ SearchPage: Exception searching game engines: $e');
      return [];
    }
  }

  Future<List<Franchise>> _searchFranchises(String query) async {
    print('🔍 SearchPage: Searching franchises with query: "$query"');
    try {
      final result = await sl<GameRepository>().searchFranchises(query);
      return result.fold(
        (failure) {
          print(
              '❌ SearchPage: Failed to search franchises: ${failure.message}');
          return <Franchise>[];
        },
        (franchises) {
          print('✅ SearchPage: Found ${franchises.length} franchises');
          return franchises;
        },
      );
    } catch (e) {
      print('❌ SearchPage: Exception searching franchises: $e');
      return [];
    }
  }

  Future<List<Collection>> _searchCollections(String query) async {
    print('🔍 SearchPage: Searching collections with query: "$query"');
    try {
      final result = await sl<GameRepository>().searchCollections(query);
      return result.fold(
        (failure) {
          print(
              '❌ SearchPage: Failed to search collections: ${failure.message}');
          return <Collection>[];
        },
        (collections) {
          print('✅ SearchPage: Found ${collections.length} collections');
          return collections;
        },
      );
    } catch (e) {
      print('❌ SearchPage: Exception searching collections: $e');
      return [];
    }
  }

  Future<List<Keyword>> _searchKeywords(String query) async {
    print('🔍 SearchPage: Searching keywords with query: "$query"');
    try {
      final result = await sl<GameRepository>().searchKeywords(query);
      return result.fold(
        (failure) {
          print('❌ SearchPage: Failed to search keywords: ${failure.message}');
          return <Keyword>[];
        },
        (keywords) {
          print('✅ SearchPage: Found ${keywords.length} keywords');
          return keywords;
        },
      );
    } catch (e) {
      print('❌ SearchPage: Exception searching keywords: $e');
      return [];
    }
  }

  Future<List<AgeRating>> _searchAgeRatings(String query) async {
    print('🔍 SearchPage: Searching age ratings with query: "$query"');
    try {
      final result = await sl<GameRepository>().searchAgeRatings(query);
      return result.fold(
        (failure) {
          print(
              '❌ SearchPage: Failed to search age ratings: ${failure.message}');
          return <AgeRating>[];
        },
        (ageRatings) {
          print('✅ SearchPage: Found ${ageRatings.length} age ratings');
          return ageRatings;
        },
      );
    } catch (e) {
      print('❌ SearchPage: Exception searching age ratings: $e');
      return [];
    }
  }

  Future<List<Language>> _searchLanguages(String query) async {
    print('🔍 SearchPage: Searching languages with query: "$query"');
    try {
      final result = await sl<GameRepository>().searchLanguages(query);
      return result.fold(
        (failure) {
          print('❌ SearchPage: Failed to search languages: ${failure.message}');
          return <Language>[];
        },
        (languages) {
          print('✅ SearchPage: Found ${languages.length} languages');
          return languages;
        },
      );
    } catch (e) {
      print('❌ SearchPage: Exception searching languages: $e');
      return [];
    }
  }

  Future<List<Platform>> _searchPlatforms(String query) async {
    print('🔍 SearchPage: Searching platforms with query: "$query"');
    try {
      final result = await sl<GameRepository>().searchPlatforms(query);
      return result.fold(
        (failure) {
          print('❌ SearchPage: Failed to search platforms: ${failure.message}');
          return <Platform>[];
        },
        (platforms) {
          print('✅ SearchPage: Found ${platforms.length} platforms');
          return platforms;
        },
      );
    } catch (e) {
      print('❌ SearchPage: Exception searching platforms: $e');
      return [];
    }
  }

  Future<List<gg_theme.Theme>> _searchThemes(String query) async {
    print('🔍 SearchPage: Searching themes with query: "$query"');
    try {
      final result = await sl<GameRepository>().searchThemes(query);
      return result.fold(
        (failure) {
          print('❌ SearchPage: Failed to search themes: ${failure.message}');
          return <gg_theme.Theme>[];
        },
        (themes) {
          print('✅ SearchPage: Found ${themes.length} themes');
          return themes;
        },
      );
    } catch (e) {
      print('❌ SearchPage: Exception searching themes: $e');
      return [];
    }
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
    if (_currentFilters.minTotalRating != null ||
        _currentFilters.maxTotalRating != null) count++;
    if (_currentFilters.minUserRating != null ||
        _currentFilters.maxUserRating != null) count++;
    if (_currentFilters.minAggregatedRating != null ||
        _currentFilters.maxAggregatedRating != null) count++;
    if (_currentFilters.releaseDateFrom != null ||
        _currentFilters.releaseDateTo != null) count++;
    if (_currentFilters.themesIds.isNotEmpty) count++;
    if (_currentFilters.gameModesIds.isNotEmpty) count++;
    if (_currentFilters.playerPerspectiveIds.isNotEmpty) count++;
    if (_currentFilters.companyIds.isNotEmpty) count++;
    if (_currentFilters.gameEngineIds.isNotEmpty) count++;
    if (_currentFilters.franchiseIds.isNotEmpty) count++;
    if (_currentFilters.collectionIds.isNotEmpty) count++;
    if (_currentFilters.keywordIds.isNotEmpty) count++;
    if (_currentFilters.gameTypeIds.isNotEmpty) count++;
    if (_currentFilters.gameStatusIds.isNotEmpty) count++;
    if (_currentFilters.ageRatingIds.isNotEmpty) count++;
    if (_currentFilters.languageSupportIds.isNotEmpty) count++;
    if (_currentFilters.multiplayerModeIds.isNotEmpty) count++;
    if (_currentFilters.hasMultiplayer != null) count++;
    if (_currentFilters.hasSinglePlayer != null) count++;
    if (_currentFilters.minHypes != null) count++;
    return count;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _gameBloc,
      child: Scaffold(
        body: Stack(
          children: [
            SafeArea(
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
                              backgroundColor:
                                  Theme.of(context).colorScheme.error,
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
            // Glassmorphism Filter FAB
            _buildFilterFAB(context),
          ],
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
                  : null,
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
                                // If search text is also empty, show initial view
                                if (_searchController.text.trim().isEmpty) {
                                  _showRecentSearches = true;
                                }
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

  Widget _buildFilterFAB(BuildContext context) {
    final theme = Theme.of(context);

    return Positioned(
      right: 16,
      bottom: 16,
      child: SafeArea(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.primaryContainer.withOpacity(0.7),
                    theme.colorScheme.secondaryContainer.withOpacity(0.5),
                  ],
                ),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: theme.colorScheme.outline.withOpacity(0.2),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 0,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _showFilters,
                  borderRadius: BorderRadius.circular(28),
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: !_isLoadingFilterOptions
                            ? SizedBox(
                                width: 28,
                                height: 28,
                                child: LoadingIndicator(
                                  indicatorType: Indicator.pacman,
                                  colors: [theme.colorScheme.primary],
                                  strokeWidth: 2,
                                ),
                              )
                            : Icon(
                                Icons.tune_rounded,
                                color: theme.colorScheme.onPrimaryContainer,
                                size: 28,
                              ),
                      ),
                      if (!_isLoadingFilterOptions &&
                          _currentFilters.hasFilters)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 20,
                              minHeight: 20,
                            ),
                            child: Center(
                              child: Text(
                                '${_getActiveFilterCount()}',
                                style: TextStyle(
                                  color: theme.colorScheme.onPrimary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showFilters() async {
    final result = await FilterBottomSheet.show(
      context: context,
      currentFilters: _currentFilters,
      availableGenres: _availableGenres,
      availableGameTypes: _availableGameTypes,
      availableGameModes: _availableGameModes,
      availablePlayerPerspectives: _availablePlayerPerspectives,
      availableGameStatuses: _availableGameStatuses,
      onSearchCompanies: _searchCompanies,
      onSearchGameEngines: _searchGameEngines,
      onSearchFranchises: _searchFranchises,
      onSearchCollections: _searchCollections,
      onSearchKeywords: _searchKeywords,
      onSearchLanguages: _searchLanguages,
      onSearchPlatforms: _searchPlatforms,
      onSearchAgeRatings: _searchAgeRatings,
      onSearchThemes: _searchThemes,
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
