// lib/presentation/pages/all_games/local_all_games_screen.dart
import 'package:flutter/material.dart';
import 'package:gamer_grove/presentation/widgets/game_card.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/navigations.dart';
import '../../../domain/entities/game/game.dart';
import '../../../domain/entities/genre.dart';
import '../../../domain/entities/platform/platform.dart';

class LocalAllGamesScreen extends StatefulWidget {
  final String title;
  final String? subtitle;
  final List<Game> games;
  final bool showFilters;
  final bool showSearch;
  final bool blurRated; // 🆕 NEW: Blur rated games feature
  final bool showViewToggle;

  const LocalAllGamesScreen({
    super.key,
    required this.title,
    this.subtitle,
    required this.games,
    this.showFilters = true,
    this.showSearch = true,
    this.blurRated = false, // Default: no blur
    this.showViewToggle = true,
  });

  @override
  State<LocalAllGamesScreen> createState() => _LocalAllGamesScreenState();
}

class _LocalAllGamesScreenState extends State<LocalAllGamesScreen> {
  // State variables
  List<Game> _filteredGames = [];
  String _searchQuery = '';
  bool _isGridView = true;
  bool _blurRatedGames = true; // 🆕 NEW: Toggle for blur feature

  // Filter states
  List<Genre> _selectedGenres = [];
  List<Platform> _selectedPlatforms = [];
  int? _selectedMinYear;
  int? _selectedMaxYear;
  RatingFilter _ratingFilter = RatingFilter.all;

  // Sort states
  SortOption _sortOption = SortOption.nameAZ;

  @override
  void initState() {
    super.initState();
    _filteredGames = List.from(widget.games);
    _blurRatedGames = false; // 🔧 FIX: Always start with blur OFF
    _applyFiltersAndSort();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
        actions: [
          // Blur Toggle (nur zeigen wenn blurRated Feature aktiviert ist)
          if (widget.blurRated)
            IconButton(
              icon: Icon(_blurRatedGames ? Icons.blur_off : Icons.blur_on),
              onPressed: () {
                setState(() {
                  _blurRatedGames = !_blurRatedGames;
                });
              },
              tooltip: _blurRatedGames ? 'Hide Rating Status' : 'Show Rating Status',
            ),

          // View Toggle
          if (widget.showViewToggle)
            IconButton(
              icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
              onPressed: () {
                setState(() {
                  _isGridView = !_isGridView;
                });
              },
              tooltip: _isGridView ? 'List View' : 'Grid View',
            ),

          // Filter/Sort Menu
          if (widget.showFilters)
            PopupMenuButton<String>(
              icon: const Icon(Icons.tune),
              tooltip: 'Filter & Sort',
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'filter',
                  child: Row(
                    children: [
                      Icon(Icons.filter_alt, size: 18),
                      SizedBox(width: 8),
                      Text('Filters'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'sort',
                  child: Row(
                    children: [
                      Icon(Icons.sort, size: 18),
                      SizedBox(width: 8),
                      Text('Sort'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'reset',
                  child: Row(
                    children: [
                      Icon(Icons.clear, size: 18),
                      SizedBox(width: 8),
                      Text('Reset All'),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                switch (value) {
                  case 'filter':
                    _showFilterDialog();
                    break;
                  case 'sort':
                    _showSortDialog();
                    break;
                  case 'reset':
                    _resetFilters();
                    break;
                }
              },
            ),
        ],
      ),

      body: Column(
        children: [
          // Search Bar
          if (widget.showSearch)
            _buildSearchBar(),

          // Stats Bar
          _buildStatsBar(),

          // Games Grid/List
          Expanded(
            child: _filteredGames.isEmpty
                ? _buildEmptyState()
                : _buildGamesList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search games...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value.toLowerCase();
            _applyFiltersAndSort();
          });
        },
      ),
    );
  }

  Widget _buildStatsBar() {
    final ratedCount = _filteredGames.where((game) => _isGameRated(game)).length;
    final unratedCount = _filteredGames.length - ratedCount;

    return Container(
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
          Text(
            '${_filteredGames.length} games',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),

          if (widget.blurRated) ...[
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$ratedCount rated',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.green[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$unratedCount to rate',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.orange[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],

          const Spacer(),

          // Active Filter Indicators
          if (_hasActiveFilters())
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.filter_alt,
                    size: 14,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Filtered',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGamesList() {
    if (_isGridView) {
      return GridView.builder(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _getCrossAxisCount(),
          crossAxisSpacing: AppConstants.paddingSmall,
          mainAxisSpacing: AppConstants.paddingSmall,
          childAspectRatio: 0.7, // Same as GameCard aspect ratio
        ),
        itemCount: _filteredGames.length,
        itemBuilder: (context, index) {
          final game = _filteredGames[index];
          return _buildGameItem(game);
        },
      );
    } else {
      return ListView.builder(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        itemCount: _filteredGames.length,
        itemBuilder: (context, index) {
          final game = _filteredGames[index];
          return Container(
            height: 120,
            margin: const EdgeInsets.only(bottom: AppConstants.paddingSmall),
            child: _buildGameItem(game, isListView: true),
          );
        },
      );
    }
  }

  Widget _buildGameItem(Game game, {bool isListView = false}) {
    // 🎯 Simple: Use GameCard's built-in blur feature with toggle
    return GameCard(
      game: game,
      onTap: () => Navigations.navigateToGameDetail(game.id, context),
      blurRated: widget.blurRated && _blurRatedGames, // Only blur if both widget setting and toggle are enabled
    );
  }

  Widget _buildEmptyState() {
    return Center(
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
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters or search',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _resetFilters,
            icon: const Icon(Icons.clear),
            label: const Text('Reset Filters'),
          ),
        ],
      ),
    );
  }

  // Helper methods
  bool _isGameRated(Game game) {
    return game.userRating != null && game.userRating! > 0;
  }

  int _getCrossAxisCount() {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 4;
    if (width > 800) return 3;
    return 2;
  }

  bool _hasActiveFilters() {
    return _selectedGenres.isNotEmpty ||
        _selectedPlatforms.isNotEmpty ||
        _selectedMinYear != null ||
        _selectedMaxYear != null ||
        _ratingFilter != RatingFilter.all ||
        _searchQuery.isNotEmpty;
  }

  void _applyFiltersAndSort() {
    List<Game> filtered = List.from(widget.games);

    // Apply search
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((game) {
        return game.name.toLowerCase().contains(_searchQuery) ||
            game.summary?.toLowerCase().contains(_searchQuery) == true;
      }).toList();
    }

    // Apply genre filter
    if (_selectedGenres.isNotEmpty) {
      filtered = filtered.where((game) {
        return game.genres.any((genre) =>
            _selectedGenres.any((selected) => selected.id == genre.id)
        );
      }).toList();
    }

    // Apply platform filter
    if (_selectedPlatforms.isNotEmpty) {
      filtered = filtered.where((game) {
        return game.platforms.any((platform) =>
            _selectedPlatforms.any((selected) => selected.id == platform.id)
        );
      }).toList();
    }

    // Apply year filter
    if (_selectedMinYear != null || _selectedMaxYear != null) {
      filtered = filtered.where((game) {
        if (game.firstReleaseDate == null) return false;
        final year = game.firstReleaseDate!.year;
        if (_selectedMinYear != null && year < _selectedMinYear!) return false;
        if (_selectedMaxYear != null && year > _selectedMaxYear!) return false;
        return true;
      }).toList();
    }

    // Apply rating filter
    switch (_ratingFilter) {
      case RatingFilter.rated:
        filtered = filtered.where((game) => _isGameRated(game)).toList();
        break;
      case RatingFilter.unrated:
        filtered = filtered.where((game) => !_isGameRated(game)).toList();
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
      case SortOption.releaseDateNewest:
        filtered.sort((a, b) {
          if (a.firstReleaseDate == null && b.firstReleaseDate == null) return 0;
          if (a.firstReleaseDate == null) return 1;
          if (b.firstReleaseDate == null) return -1;
          return b.firstReleaseDate!.compareTo(a.firstReleaseDate!);
        });
        break;
      case SortOption.releaseDateOldest:
        filtered.sort((a, b) {
          if (a.firstReleaseDate == null && b.firstReleaseDate == null) return 0;
          if (a.firstReleaseDate == null) return 1;
          if (b.firstReleaseDate == null) return -1;
          return a.firstReleaseDate!.compareTo(b.firstReleaseDate!);
        });
        break;
      case SortOption.ratingHighest:
        filtered.sort((a, b) {
          final aRating = a.totalRating ?? 0;
          final bRating = b.totalRating ?? 0;
          return bRating.compareTo(aRating);
        });
        break;
      case SortOption.ratingLowest:
        filtered.sort((a, b) {
          final aRating = a.totalRating ?? 0;
          final bRating = b.totalRating ?? 0;
          return aRating.compareTo(bRating);
        });
        break;
      case SortOption.userRatingHighest:
        filtered.sort((a, b) {
          final aRating = a.userRating ?? 0;
          final bRating = b.userRating ?? 0;
          return bRating.compareTo(aRating);
        });
        break;
    }

    setState(() {
      _filteredGames = filtered;
    });
  }

  void _resetFilters() {
    setState(() {
      _searchQuery = '';
      _selectedGenres.clear();
      _selectedPlatforms.clear();
      _selectedMinYear = null;
      _selectedMaxYear = null;
      _ratingFilter = RatingFilter.all;
      _sortOption = SortOption.nameAZ;
      _applyFiltersAndSort();
    });
  }

  void _showFilterDialog() {
    // TODO: Implement filter dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filters'),
        content: const Text('Filter dialog coming soon...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sort Options'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: SortOption.values.map((option) {
            return RadioListTile<SortOption>(
              title: Text(option.displayName),
              value: option,
              groupValue: _sortOption,
              onChanged: (value) {
                setState(() {
                  _sortOption = value!;
                  _applyFiltersAndSort();
                });
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}

// Enums
enum RatingFilter {
  all,
  rated,
  unrated;

  String get displayName {
    switch (this) {
      case RatingFilter.all:
        return 'All Games';
      case RatingFilter.rated:
        return 'Rated Only';
      case RatingFilter.unrated:
        return 'Unrated Only';
    }
  }
}

enum SortOption {
  nameAZ,
  nameZA,
  releaseDateNewest,
  releaseDateOldest,
  ratingHighest,
  ratingLowest,
  userRatingHighest;

  String get displayName {
    switch (this) {
      case SortOption.nameAZ:
        return 'Name (A-Z)';
      case SortOption.nameZA:
        return 'Name (Z-A)';
      case SortOption.releaseDateNewest:
        return 'Release Date (Newest)';
      case SortOption.releaseDateOldest:
        return 'Release Date (Oldest)';
      case SortOption.ratingHighest:
        return 'Rating (Highest)';
      case SortOption.ratingLowest:
        return 'Rating (Lowest)';
      case SortOption.userRatingHighest:
        return 'My Rating (Highest)';
    }
  }
}