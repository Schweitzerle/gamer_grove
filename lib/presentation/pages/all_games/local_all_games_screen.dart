// lib/presentation/pages/all_games/enriched_all_games_screen.dart
import 'package:flutter/material.dart';
import 'package:gamer_grove/core/services/game_enrichment_service.dart';
import 'package:gamer_grove/presentation/widgets/game_card.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/navigations.dart';
import '../../../domain/entities/game/game.dart';
import '../../../domain/entities/genre.dart';
import '../../../domain/entities/platform/platform.dart';
import '../../../injection_container.dart';

enum SortOption {
  nameAZ,
  nameZA,
  ratingHigh,
  ratingLow,
  releaseDateNew,
  releaseDateOld,
}

enum RatingFilter {
  all,
  rated,
  unrated,
  highRated, // > 7.0
}

class EnrichedAllGamesScreen extends StatefulWidget {
  final String title;
  final String? subtitle;
  final List<Game> games; // Alle Games (non-enriched)
  final String? userId;
  final bool showFilters;
  final bool showSearch;
  final bool blurRated;
  final bool showViewToggle;

  const EnrichedAllGamesScreen({
    super.key,
    required this.title,
    this.subtitle,
    required this.games,
    this.userId,
    this.showFilters = true,
    this.showSearch = true,
    this.blurRated = false,
    this.showViewToggle = true,
  });

  @override
  State<EnrichedAllGamesScreen> createState() => _EnrichedAllGamesScreenState();
}

class _EnrichedAllGamesScreenState extends State<EnrichedAllGamesScreen> {
  // Controllers
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  // State variables
  List<Game> _allGames = [];
  List<Game> _filteredGames = [];
  String _searchQuery = '';
  bool _isGridView = true;
  bool _blurRatedGames = false;

  // Filter states
  final List<Genre> _selectedGenres = [];
  final List<Platform> _selectedPlatforms = [];
  int? _selectedMinYear;
  int? _selectedMaxYear;
  final RatingFilter _ratingFilter = RatingFilter.all;
  SortOption _sortOption = SortOption.nameAZ;

  // Enrichment progress
  bool _isEnriching = false;
  int _enrichmentProgress = 0;
  int _totalGames = 0;
  String _enrichmentStatus = '';

  @override
  void initState() {
    super.initState();
    _blurRatedGames = widget.blurRated;
    _totalGames = widget.games.length;

    if (widget.userId != null && widget.games.isNotEmpty) {
      _enrichAllGames();
    } else {
      // No user or no games - use games as-is
      _allGames = List.from(widget.games);
      _applyFiltersAndSort();
    }
  }

  Future<void> _enrichAllGames() async {
    setState(() {
      _isEnriching = true;
      _enrichmentProgress = 0;
      _enrichmentStatus = 'Loading game data...';
    });

    try {
      final enrichmentService = sl<GameEnrichmentService>();

      final enrichedGames = await enrichmentService.enrichGames(
        widget.games,
        widget.userId!,
      );

      setState(() {
        _allGames = enrichedGames;
        _isEnriching = false;
        _enrichmentProgress = _totalGames;
      });

      _applyFiltersAndSort();
    } catch (e) {
      setState(() {
        _allGames = List.from(widget.games);
        _isEnriching = false;
        _enrichmentStatus = 'Error loading data';
      });

      _applyFiltersAndSort();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error enriching games: $e')),
        );
      }
    }
  }

  void _applyFiltersAndSort() {
    List<Game> filtered = List.from(_allGames);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((game) =>
              game.name.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    // Apply genre filter
    if (_selectedGenres.isNotEmpty) {
      filtered = filtered
          .where((game) =>
              game.genres.any((genre) => _selectedGenres.contains(genre)))
          .toList();
    }

    // Apply platform filter
    if (_selectedPlatforms.isNotEmpty) {
      filtered = filtered
          .where((game) => game.platforms
              .any((platform) => _selectedPlatforms.contains(platform)))
          .toList();
    }

    // Apply year filter
    if (_selectedMinYear != null || _selectedMaxYear != null) {
      filtered = filtered.where((game) {
        if (game.firstReleaseDate == null) return false;
        final year = game.firstReleaseDate!.year;
        return (_selectedMinYear == null || year >= _selectedMinYear!) &&
            (_selectedMaxYear == null || year <= _selectedMaxYear!);
      }).toList();
    }

    // Apply rating filter
    switch (_ratingFilter) {
      case RatingFilter.rated:
        filtered = filtered.where((game) => game.userRating != null).toList();
        break;
      case RatingFilter.unrated:
        filtered = filtered.where((game) => game.userRating == null).toList();
        break;
      case RatingFilter.highRated:
        filtered = filtered
            .where((game) => game.userRating != null && game.userRating! >= 7.0)
            .toList();
        break;
      case RatingFilter.all:
        break;
    }

    // Apply sorting
    switch (_sortOption) {
      case SortOption.nameAZ:
        filtered.sort((a, b) => a.name.compareTo(b.name));
        break;
      case SortOption.nameZA:
        filtered.sort((a, b) => b.name.compareTo(a.name));
        break;
      case SortOption.ratingHigh:
        filtered.sort((a, b) {
          final aRating = a.aggregatedRating ?? 0;
          final bRating = b.aggregatedRating ?? 0;
          return bRating.compareTo(aRating);
        });
        break;
      case SortOption.ratingLow:
        filtered.sort((a, b) {
          final aRating = a.aggregatedRating ?? 0;
          final bRating = b.aggregatedRating ?? 0;
          return aRating.compareTo(bRating);
        });
        break;
      case SortOption.releaseDateNew:
        filtered.sort((a, b) {
          if (a.firstReleaseDate == null && b.firstReleaseDate == null) {
            return 0;
          }
          if (a.firstReleaseDate == null) return 1;
          if (b.firstReleaseDate == null) return -1;
          return b.firstReleaseDate!.compareTo(a.firstReleaseDate!);
        });
        break;
      case SortOption.releaseDateOld:
        filtered.sort((a, b) {
          if (a.firstReleaseDate == null && b.firstReleaseDate == null) {
            return 0;
          }
          if (a.firstReleaseDate == null) return 1;
          if (b.firstReleaseDate == null) return -1;
          return a.firstReleaseDate!.compareTo(b.firstReleaseDate!);
        });
        break;
    }

    setState(() {
      _filteredGames = filtered;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _isEnriching ? _buildEnrichmentProgress() : _buildGamesList(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          if (widget.subtitle != null)
            Text(
              widget.subtitle!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
        ],
      ),
      actions: _isEnriching
          ? []
          : [
              // Blur Toggle
              if (widget.blurRated)
                IconButton(
                  icon: Icon(_blurRatedGames ? Icons.blur_off : Icons.blur_on),
                  onPressed: () {
                    setState(() {
                      _blurRatedGames = !_blurRatedGames;
                    });
                  },
                  tooltip: _blurRatedGames ? 'Show ratings' : 'Blur ratings',
                ),

              // View Toggle
              if (widget.showViewToggle)
                IconButton(
                  icon: Icon(_isGridView ? Icons.list : Icons.grid_view),
                  onPressed: () {
                    setState(() {
                      _isGridView = !_isGridView;
                    });
                  },
                  tooltip: _isGridView ? 'List view' : 'Grid view',
                ),

              // Filters
              if (widget.showFilters)
                IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: _showFiltersDialog,
                  tooltip: 'Filters',
                ),
            ],
    );
  }

  Widget _buildEnrichmentProgress() {
    final double progress =
        _totalGames > 0 ? _enrichmentProgress / _totalGames : 0.0;

    return Padding(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Circular progress indicator
          SizedBox(
            width: 120,
            height: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 8,
                    backgroundColor:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${(_enrichmentProgress / _totalGames * 100).toInt()}%',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                    ),
                    Text(
                      '$_enrichmentProgress/$_totalGames',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Status text
          Text(
            _enrichmentStatus,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
          ),

          const SizedBox(height: 12),

          // Secondary info
          Text(
            'Loading your personal game data...',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),

          const SizedBox(height: 24),

          // Linear progress bar
          Container(
            width: double.infinity,
            height: 8,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGamesList() {
    return Column(
      children: [
        // Search bar
        if (widget.showSearch) _buildSearchBar(),

        // Games count
        _buildGamesCount(),

        // Games list/grid
        Expanded(
          child: _filteredGames.isEmpty
              ? _buildEmptyState()
              : _isGridView
                  ? _buildGridView()
                  : _buildListView(),
        ),
      ],
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
                    _applyFiltersAndSort();
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
          _applyFiltersAndSort();
        },
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
            '${_filteredGames.length} of ${_allGames.length} games',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const Spacer(),
          if (widget.showFilters)
            TextButton.icon(
              onPressed: _showSortDialog,
              icon: const Icon(Icons.sort, size: 16),
              label: Text(_getSortOptionName(_sortOption)),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: AppConstants.paddingMedium,
        mainAxisSpacing: AppConstants.paddingMedium,
      ),
      itemCount: _filteredGames.length,
      itemBuilder: (context, index) {
        final game = _filteredGames[index];
        return GameCard(
          game: game,
          blurRated: _blurRatedGames && game.userRating != null,
          onTap: () => Navigations.navigateToGameDetail(game.id, context),
        );
      },
    );
  }

  Widget _buildListView() {
    return ListView.separated(
      controller: _scrollController,
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      itemCount: _filteredGames.length,
      separatorBuilder: (context, index) =>
          const SizedBox(height: AppConstants.paddingSmall),
      itemBuilder: (context, index) {
        final game = _filteredGames[index];
        return GameCard(
          game: game,
          blurRated: _blurRatedGames && game.userRating != null,
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
            'No games found',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters or search terms.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }

  void _showFiltersDialog() {
    // TODO: Implement filters dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Filters dialog - TODO')),
    );
  }

  Future<void> _showSortDialog() async {
    await showDialog<void>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Sort by'),
        children: SortOption.values
            .map(
              (option) => SimpleDialogOption(
                onPressed: () {
                  setState(() {
                    _sortOption = option;
                  });
                  Navigator.of(context).pop();
                  _applyFiltersAndSort();
                },
                child: Text(_getSortOptionName(option)),
              ),
            )
            .toList(),
      ),
    );
  }

  String _getSortOptionName(SortOption option) {
    switch (option) {
      case SortOption.nameAZ:
        return 'Name A-Z';
      case SortOption.nameZA:
        return 'Name Z-A';
      case SortOption.ratingHigh:
        return 'Rating High-Low';
      case SortOption.ratingLow:
        return 'Rating Low-High';
      case SortOption.releaseDateNew:
        return 'Release Date New-Old';
      case SortOption.releaseDateOld:
        return 'Release Date Old-New';
    }
  }
}
