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

// Die alte SortOption wird durch zwei neue Enums ersetzt,
// um Kategorie und Richtung zu trennen.
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
  releaseDate
}

enum SortDirection { ascending, descending }

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
  // State für Sortierung angepasst
  SortCategory _sortCategory = SortCategory.name;
  SortDirection _sortDirection = SortDirection.ascending;

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
    final enrichmentService = sl<GameEnrichmentService>();

    setState(() {
      _isEnriching = true;
    });

    final enrichedGames = await enrichmentService.enrichGames(
      widget.games,
      widget.userId!,
    );

    setState(() {
      _allGames = enrichedGames;
      _isEnriching = false;
    });

    _applyFiltersAndSort();
  }

  //TODO: maybe implement filtering with dynamic data from api like in search screen and then use it for local filtering of the games
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

    // Apply sorting - Logik angepasst an _sortCategory und _sortDirection
    switch (_sortCategory) {
      case SortCategory.name:
        filtered.sort((a, b) => _sortDirection == SortDirection.ascending
            ? a.name.compareTo(b.name)
            : b.name.compareTo(a.name));
        break;
      case SortCategory.totalRating:
        filtered.sort((a, b) {
          final aRating = a.totalRating ?? 0;
          final bRating = b.totalRating ?? 0;
          return _sortDirection == SortDirection.ascending
              ? aRating.compareTo(bRating) // Low to High
              : bRating.compareTo(aRating); // High to Low
        });
        break;
      case SortCategory.igdbUserRating:
        filtered.sort((a, b) {
          final aRating = a.rating ?? 0;
          final bRating = b.rating ?? 0;
          return _sortDirection == SortDirection.ascending
              ? aRating.compareTo(bRating) // Low to High
              : bRating.compareTo(aRating); // High to Low
        });
        break;
      case SortCategory.aggregatedRating:
        filtered.sort((a, b) {
          final aRating = a.aggregatedRating ?? 0;
          final bRating = b.aggregatedRating ?? 0;
          return _sortDirection == SortDirection.ascending
              ? aRating.compareTo(bRating) // Low to High
              : bRating.compareTo(aRating); // High to Low
        });
        break;
      case SortCategory.userRating:
        filtered.sort((a, b) {
          final aRating = a.userRating ?? 0;
          final bRating = b.userRating ?? 0;
          return _sortDirection == SortDirection.ascending
              ? aRating.compareTo(bRating) // Low to High
              : bRating.compareTo(aRating); // High to Low
        });
        break;
      case SortCategory.totalRatingCount:
        filtered.sort((a, b) {
          final aRating = a.totalRatingCount ?? 0;
          final bRating = b.totalRatingCount ?? 0;
          return _sortDirection == SortDirection.ascending
              ? aRating.compareTo(bRating) // Low to High
              : bRating.compareTo(aRating); // High to Low
        });
        break;
      case SortCategory.igdbUserRatingCount:
        filtered.sort((a, b) {
          final aRating = a.ratingCount ?? 0;
          final bRating = b.ratingCount ?? 0;
          return _sortDirection == SortDirection.ascending
              ? aRating.compareTo(bRating) // Low to High
              : bRating.compareTo(aRating); // High to Low
        });
        break;
      case SortCategory.aggregatedRatingCount:
        filtered.sort((a, b) {
          final aRating = a.aggregatedRatingCount ?? 0;
          final bRating = b.aggregatedRatingCount ?? 0;
          return _sortDirection == SortDirection.ascending
              ? aRating.compareTo(bRating) // Low to High
              : bRating.compareTo(aRating); // High to Low
        });
        break;
      case SortCategory.hypes:
        filtered.sort((a, b) {
          final aHypes = a.hypes ?? 0;
          final bHypes = b.hypes ?? 0;
          return _sortDirection == SortDirection.ascending
              ? aHypes.compareTo(bHypes) // Low to High
              : bHypes.compareTo(aHypes); // High to Low
        });
        break;
      case SortCategory.releaseDate:
        filtered.sort((a, b) {
          if (a.firstReleaseDate == null && b.firstReleaseDate == null) {
            return 0;
          }
          if (a.firstReleaseDate == null) return 1;
          if (b.firstReleaseDate == null) return -1;
          return _sortDirection == SortDirection.ascending
              ? a.firstReleaseDate!.compareTo(b.firstReleaseDate!) // Old to New
              : b.firstReleaseDate!
                  .compareTo(a.firstReleaseDate!); // New to Old
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
              // Label nutzt jetzt die neue Helper-Methode
              label: Text(_getCurrentSortName()),
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

  // --- NEUER SORTIERDIALOG ---
  Future<void> _showSortDialog() async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sort by'),
        contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSortListTile(
                context: context,
                category: SortCategory.name,
                title: 'Name',
                ascText: 'A-Z',
                descText: 'Z-A',
              ),
              _buildSortListTile(
                context: context,
                category: SortCategory.totalRating,
                title: 'Total Rating',
                ascText: 'Low-High',
                descText: 'High-Low',
              ),
              _buildSortListTile(
                context: context,
                category: SortCategory.igdbUserRating,
                title: 'IGDB User Rating',
                ascText: 'Low-High',
                descText: 'High-Low',
              ),
              _buildSortListTile(
                context: context,
                category: SortCategory.aggregatedRating,
                title: 'Critics Rating',
                ascText: 'Low-High',
                descText: 'High-Low',
              ),
              _buildSortListTile(
                context: context,
                category: SortCategory.userRating,
                title: 'Your Rating',
                ascText: 'Low-High',
                descText: 'High-Low',
              ),
              _buildSortListTile(
                context: context,
                category: SortCategory.totalRatingCount,
                title: 'Total Rating Count',
                ascText: 'Low-High',
                descText: 'High-Low',
              ),
              _buildSortListTile(
                context: context,
                category: SortCategory.igdbUserRatingCount,
                title: 'IGDB User Rating Count',
                ascText: 'Low-High',
                descText: 'High-Low',
              ),
              _buildSortListTile(
                context: context,
                category: SortCategory.aggregatedRating,
                title: 'Critics Rating Count',
                ascText: 'Low-High',
                descText: 'High-Low',
              ),
              _buildSortListTile(
                context: context,
                category: SortCategory.hypes,
                title: 'Hypes',
                ascText: 'Low-High',
                descText: 'High-Low',
              ),
              _buildSortListTile(
                context: context,
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

  // --- NEUES HELPER WIDGET für den Dialog ---
  Widget _buildSortListTile({
    required BuildContext context,
    required SortCategory category,
    required String title,
    required String ascText,
    required String descText,
  }) {
    final bool isSelected = _sortCategory == category;
    final bool isAscending = _sortDirection == SortDirection.ascending;

    // Diese Funktion steuert die Auswahl und das Umschalten
    void handleTap() {
      if (isSelected) {
        // Wenn bereits ausgewählt, nur die Richtung umschalten
        setState(() {
          _sortDirection =
              isAscending ? SortDirection.descending : SortDirection.ascending;
        });
      } else {
        // Wenn nicht ausgewählt, Kategorie setzen und Standardrichtung festlegen
        final newDirection = (category == SortCategory.name)
            ? SortDirection.ascending // Name default A-Z
            : SortDirection.descending; // Rating/Date default High/New
        setState(() {
          _sortCategory = category;
          _sortDirection = newDirection;
        });
      }
      Navigator.of(context).pop();
      _applyFiltersAndSort();
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
              onPressed: handleTap, // Richtung umschalten
            )
          : null,
      onTap: handleTap, // Kategorie auswählen oder Richtung umschalten
    );
  }

  // --- NEUE HELPER METHODE für den Sortiernamen ---
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
            ? 'Aggregated Rating Low-High'
            : 'Aggregated Rating High-Low';
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
            ? 'Aggregated Rating Count Low-High'
            : 'Aggregated Rating Count High-Low';
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

  // Alte _getSortOptionName Methode wird entfernt
}
