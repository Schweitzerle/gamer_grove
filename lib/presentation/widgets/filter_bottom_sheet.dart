// ==========================================
// 2. VOLLSTÄNDIGES FILTER BOTTOM SHEET
// ==========================================

// lib/presentation/widgets/filter_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../../core/constants/app_constants.dart';
import '../../domain/entities/genre.dart';
import '../../domain/entities/platform/platform.dart';
import '../../domain/entities/company/company.dart';
import '../../domain/entities/game/game_engine.dart';
import '../../domain/entities/franchise.dart';
import '../../domain/entities/collection/collection.dart';
import '../../domain/entities/search/search_filters.dart';
import '../../domain/entities/game/game_sort_options.dart';
import '../../domain/entities/game/game_mode.dart';
import '../../domain/entities/player_perspective.dart';

class FilterBottomSheet extends StatefulWidget {
  final SearchFilters currentFilters;
  final List<Genre> availableGenres;
  final List<Platform> availablePlatforms;
  final List<dynamic> availableThemes; // Theme entity
  final List<GameMode> availableGameModes;
  final List<PlayerPerspective> availablePlayerPerspectives;

  // Callback functions for dynamic search
  final Future<List<Company>> Function(String query)? onSearchCompanies;
  final Future<List<GameEngine>> Function(String query)? onSearchGameEngines;
  final Future<List<Franchise>> Function(String query)? onSearchFranchises;
  final Future<List<Collection>> Function(String query)? onSearchCollections;

  const FilterBottomSheet({
    super.key,
    required this.currentFilters,
    required this.availableGenres,
    required this.availablePlatforms,
    this.availableThemes = const [],
    this.availableGameModes = const [],
    this.availablePlayerPerspectives = const [],
    this.onSearchCompanies,
    this.onSearchGameEngines,
    this.onSearchFranchises,
    this.onSearchCollections,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();

  static Future<SearchFilters?> show({
    required BuildContext context,
    required SearchFilters currentFilters,
    required List<Genre> availableGenres,
    required List<Platform> availablePlatforms,
    List<dynamic> availableThemes = const [],
    List<GameMode> availableGameModes = const [],
    List<PlayerPerspective> availablePlayerPerspectives = const [],
    Future<List<Company>> Function(String query)? onSearchCompanies,
    Future<List<GameEngine>> Function(String query)? onSearchGameEngines,
    Future<List<Franchise>> Function(String query)? onSearchFranchises,
    Future<List<Collection>> Function(String query)? onSearchCollections,
  }) {
    return showModalBottomSheet<SearchFilters>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheet(
        currentFilters: currentFilters,
        availableGenres: availableGenres,
        availablePlatforms: availablePlatforms,
        availableThemes: availableThemes,
        availableGameModes: availableGameModes,
        availablePlayerPerspectives: availablePlayerPerspectives,
        onSearchCompanies: onSearchCompanies,
        onSearchGameEngines: onSearchGameEngines,
        onSearchFranchises: onSearchFranchises,
        onSearchCollections: onSearchCollections,
      ),
    );
  }
}

class _FilterBottomSheetState extends State<FilterBottomSheet>
    with SingleTickerProviderStateMixin {
  late SearchFilters _filters;
  late TabController _tabController;

  // Selected values - Basic
  late List<int> _selectedGenres;
  late List<int> _selectedPlatforms;
  late double _minRating;
  late double _maxRating;
  int? _startYear;
  int? _endYear;
  late GameSortBy _sortBy;
  late SortOrder _sortOrder;

  // Selected values - Advanced
  late List<int> _selectedThemes;
  late List<int> _selectedGameModes;
  late List<int> _selectedPlayerPerspectives;

  // Selected values - Dynamic
  final List<Company> _selectedCompanies = [];
  final List<GameEngine> _selectedGameEngines = [];
  final List<Franchise> _selectedFranchises = [];
  final List<Collection> _selectedCollections = [];

  // Search controllers
  final TextEditingController _companySearchController =
      TextEditingController();
  final TextEditingController _engineSearchController = TextEditingController();
  final TextEditingController _franchiseSearchController =
      TextEditingController();
  final TextEditingController _collectionSearchController =
      TextEditingController();

  // Search results
  List<Company> _companySearchResults = [];
  List<GameEngine> _engineSearchResults = [];
  List<Franchise> _franchiseSearchResults = [];
  List<Collection> _collectionSearchResults = [];

  // Loading states
  bool _isSearchingCompanies = false;
  bool _isSearchingEngines = false;
  bool _isSearchingFranchises = false;
  bool _isSearchingCollections = false;

  // Debounce timers
  Timer? _companyDebounce;
  Timer? _engineDebounce;
  Timer? _franchiseDebounce;
  Timer? _collectionDebounce;

  @override
  void initState() {
    super.initState();
    _filters = widget.currentFilters;
    _tabController = TabController(length: 3, vsync: this);

    // Initialize basic filters
    _selectedGenres = List.from(_filters.genreIds);
    _selectedPlatforms = List.from(_filters.platformIds);
    _minRating = _filters.minRating ?? 0.0;
    _maxRating = _filters.maxRating ?? 10.0;
    _startYear = _filters.releaseDateFrom?.year;
    _endYear = _filters.releaseDateTo?.year;
    _sortBy = _filters.sortBy;
    _sortOrder = _filters.sortOrder;

    // Initialize advanced filters
    _selectedThemes = List.from(_filters.themesIds);
    _selectedGameModes = List.from(_filters.gameModesIds);
    _selectedPlayerPerspectives = List.from(_filters.playerPerspectiveIds);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _companySearchController.dispose();
    _engineSearchController.dispose();
    _franchiseSearchController.dispose();
    _collectionSearchController.dispose();
    _companyDebounce?.cancel();
    _engineDebounce?.cancel();
    _franchiseDebounce?.cancel();
    _collectionDebounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filters & Sorting',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    if (_filters.hasFilters)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${_getActiveFilterCount()} active',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: _clearAllFilters,
                      icon: const Icon(Icons.clear_all, size: 18),
                      label: const Text('Clear'),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Tab Bar
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Basic', icon: Icon(Icons.tune, size: 20)),
              Tab(text: 'Advanced', icon: Icon(Icons.filter_alt, size: 20)),
              Tab(text: 'Sort', icon: Icon(Icons.sort, size: 20)),
            ],
          ),

          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildBasicFiltersTab(),
                _buildAdvancedFiltersTab(),
                _buildSortingTab(),
              ],
            ),
          ),

          // Apply Button
          _buildApplyButton(),
        ],
      ),
    );
  }

  // ==========================================
  // BASIC FILTERS TAB
  // ==========================================

  Widget _buildBasicFiltersTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGenresSection(),
          const SizedBox(height: AppConstants.paddingLarge),
          _buildPlatformsSection(),
          const SizedBox(height: AppConstants.paddingLarge),
          _buildRatingSection(),
          const SizedBox(height: AppConstants.paddingLarge),
          _buildReleaseYearSection(),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  // ==========================================
  // ADVANCED FILTERS TAB
  // ==========================================

  Widget _buildAdvancedFiltersTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.availableThemes.isNotEmpty) ...[
            _buildThemesSection(),
            const SizedBox(height: AppConstants.paddingLarge),
          ],
          if (widget.availableGameModes.isNotEmpty) ...[
            _buildGameModesSection(),
            const SizedBox(height: AppConstants.paddingLarge),
          ],
          if (widget.availablePlayerPerspectives.isNotEmpty) ...[
            _buildPlayerPerspectivesSection(),
            const SizedBox(height: AppConstants.paddingLarge),
          ],
          _buildDynamicSearchSection(
            title: 'Companies',
            icon: Icons.business,
            hint: 'Search developers & publishers...',
            controller: _companySearchController,
            searchResults: _companySearchResults,
            selectedItems: _selectedCompanies,
            isLoading: _isSearchingCompanies,
            onSearch: _searchCompanies,
            onAdd: (company) {
              setState(() {
                _selectedCompanies.add(company);
                _companySearchResults.clear();
                _companySearchController.clear();
              });
            },
            onRemove: (company) {
              setState(() {
                _selectedCompanies.remove(company);
              });
            },
            itemBuilder: (item) => Text((item as Company).name),
          ),
          const SizedBox(height: AppConstants.paddingLarge),
          _buildDynamicSearchSection(
            title: 'Game Engines',
            icon: Icons.settings_suggest,
            hint: 'Search game engines...',
            controller: _engineSearchController,
            searchResults: _engineSearchResults,
            selectedItems: _selectedGameEngines,
            isLoading: _isSearchingEngines,
            onSearch: _searchGameEngines,
            onAdd: (engine) {
              setState(() {
                _selectedGameEngines.add(engine);
                _engineSearchResults.clear();
                _engineSearchController.clear();
              });
            },
            onRemove: (engine) {
              setState(() {
                _selectedGameEngines.remove(engine);
              });
            },
            itemBuilder: (item) => Text((item as GameEngine).name),
          ),
          const SizedBox(height: AppConstants.paddingLarge),
          _buildDynamicSearchSection(
            title: 'Franchises',
            icon: Icons.auto_stories,
            hint: 'Search franchises...',
            controller: _franchiseSearchController,
            searchResults: _franchiseSearchResults,
            selectedItems: _selectedFranchises,
            isLoading: _isSearchingFranchises,
            onSearch: _searchFranchises,
            onAdd: (franchise) {
              setState(() {
                _selectedFranchises.add(franchise);
                _franchiseSearchResults.clear();
                _franchiseSearchController.clear();
              });
            },
            onRemove: (franchise) {
              setState(() {
                _selectedFranchises.remove(franchise);
              });
            },
            itemBuilder: (item) => Text((item as Franchise).name),
          ),
          const SizedBox(height: AppConstants.paddingLarge),
          _buildDynamicSearchSection(
            title: 'Collections',
            icon: Icons.collections_bookmark,
            hint: 'Search collections...',
            controller: _collectionSearchController,
            searchResults: _collectionSearchResults,
            selectedItems: _selectedCollections,
            isLoading: _isSearchingCollections,
            onSearch: _searchCollections,
            onAdd: (collection) {
              setState(() {
                _selectedCollections.add(collection);
                _collectionSearchResults.clear();
                _collectionSearchController.clear();
              });
            },
            onRemove: (collection) {
              setState(() {
                _selectedCollections.remove(collection);
              });
            },
            itemBuilder: (item) => Text((item as Collection).name),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  // ==========================================
  // SORTING TAB
  // ==========================================

  Widget _buildSortingTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSortSection(),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  // ==========================================
  // SECTION BUILDERS
  // ==========================================

  Widget _buildGenresSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionTitle('Genres', Icons.bookmarks),
            if (_selectedGenres.isNotEmpty)
              TextButton(
                onPressed: () {
                  setState(() => _selectedGenres.clear());
                  HapticFeedback.lightImpact();
                },
                child: Text('Clear (${_selectedGenres.length})'),
              ),
          ],
        ),
        const SizedBox(height: AppConstants.paddingSmall),
        if (widget.availableGenres.isEmpty)
          const Center(child: CircularProgressIndicator())
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.availableGenres.map((genre) {
              final isSelected = _selectedGenres.contains(genre.id);
              return FilterChip(
                label: Text(genre.name),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedGenres.add(genre.id);
                    } else {
                      _selectedGenres.remove(genre.id);
                    }
                  });
                  HapticFeedback.lightImpact();
                },
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildPlatformsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionTitle('Platforms', Icons.devices),
            if (_selectedPlatforms.isNotEmpty)
              TextButton(
                onPressed: () {
                  setState(() => _selectedPlatforms.clear());
                  HapticFeedback.lightImpact();
                },
                child: Text('Clear (${_selectedPlatforms.length})'),
              ),
          ],
        ),
        const SizedBox(height: AppConstants.paddingSmall),
        if (widget.availablePlatforms.isEmpty)
          const Center(child: CircularProgressIndicator())
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.availablePlatforms.map((platform) {
              final isSelected = _selectedPlatforms.contains(platform.id);
              return FilterChip(
                label: Text(platform.name),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedPlatforms.add(platform.id);
                    } else {
                      _selectedPlatforms.remove(platform.id);
                    }
                  });
                  HapticFeedback.lightImpact();
                },
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildThemesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionTitle('Themes', Icons.palette),
            if (_selectedThemes.isNotEmpty)
              TextButton(
                onPressed: () {
                  setState(() => _selectedThemes.clear());
                  HapticFeedback.lightImpact();
                },
                child: Text('Clear (${_selectedThemes.length})'),
              ),
          ],
        ),
        const SizedBox(height: AppConstants.paddingSmall),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.availableThemes.map((theme) {
            final themeId = theme.id as int;
            final themeName = theme.name as String;
            final isSelected = _selectedThemes.contains(themeId);
            return FilterChip(
              label: Text(themeName),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedThemes.add(themeId);
                  } else {
                    _selectedThemes.remove(themeId);
                  }
                });
                HapticFeedback.lightImpact();
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildGameModesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionTitle('Game Modes', Icons.sports_esports),
            if (_selectedGameModes.isNotEmpty)
              TextButton(
                onPressed: () {
                  setState(() => _selectedGameModes.clear());
                  HapticFeedback.lightImpact();
                },
                child: Text('Clear (${_selectedGameModes.length})'),
              ),
          ],
        ),
        const SizedBox(height: AppConstants.paddingSmall),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.availableGameModes.map((mode) {
            final isSelected = _selectedGameModes.contains(mode.id);
            return FilterChip(
              label: Text(mode.name),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedGameModes.add(mode.id);
                  } else {
                    _selectedGameModes.remove(mode.id);
                  }
                });
                HapticFeedback.lightImpact();
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPlayerPerspectivesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionTitle('Perspectives', Icons.remove_red_eye),
            if (_selectedPlayerPerspectives.isNotEmpty)
              TextButton(
                onPressed: () {
                  setState(() => _selectedPlayerPerspectives.clear());
                  HapticFeedback.lightImpact();
                },
                child: Text('Clear (${_selectedPlayerPerspectives.length})'),
              ),
          ],
        ),
        const SizedBox(height: AppConstants.paddingSmall),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.availablePlayerPerspectives.map((perspective) {
            final isSelected =
                _selectedPlayerPerspectives.contains(perspective.id);
            return FilterChip(
              label: Text(perspective.name),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedPlayerPerspectives.add(perspective.id);
                  } else {
                    _selectedPlayerPerspectives.remove(perspective.id);
                  }
                });
                HapticFeedback.lightImpact();
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRatingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionTitle('Rating', Icons.star),
            Text(
              '${_minRating.toStringAsFixed(1)} - ${_maxRating.toStringAsFixed(1)}',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.paddingSmall),
        RangeSlider(
          values: RangeValues(_minRating, _maxRating),
          min: 0,
          max: 10,
          divisions: 20,
          labels: RangeLabels(
            _minRating.toStringAsFixed(1),
            _maxRating.toStringAsFixed(1),
          ),
          onChanged: (RangeValues values) {
            setState(() {
              _minRating = values.start;
              _maxRating = values.end;
            });
          },
          onChangeEnd: (_) => HapticFeedback.lightImpact(),
        ),
      ],
    );
  }

  Widget _buildReleaseYearSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionTitle('Release Year', Icons.calendar_today),
            if (_startYear != null || _endYear != null)
              TextButton(
                onPressed: () {
                  setState(() {
                    _startYear = null;
                    _endYear = null;
                  });
                  HapticFeedback.lightImpact();
                },
                child: const Text('Clear'),
              ),
          ],
        ),
        const SizedBox(height: AppConstants.paddingSmall),
        Row(
          children: [
            Expanded(
              child: _buildYearDropdown(
                label: 'From',
                value: _startYear,
                onChanged: (year) => setState(() => _startYear = year),
              ),
            ),
            const SizedBox(width: AppConstants.paddingMedium),
            Expanded(
              child: _buildYearDropdown(
                label: 'To',
                value: _endYear,
                onChanged: (year) => setState(() => _endYear = year),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSortSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Sort By', Icons.sort),
        const SizedBox(height: AppConstants.paddingSmall),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: GameSortBy.values.map((sort) {
            final isSelected = _sortBy == sort;
            return FilterChip(
              label: Text(_getSortLabel(sort)),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() => _sortBy = sort);
                  HapticFeedback.lightImpact();
                }
              },
              avatar: Icon(_getSortIcon(sort), size: 18),
            );
          }).toList(),
        ),
        const SizedBox(height: AppConstants.paddingLarge),
        _buildSectionTitle('Order', Icons.swap_vert),
        const SizedBox(height: AppConstants.paddingSmall),
        SegmentedButton<SortOrder>(
          segments: const [
            ButtonSegment(
              value: SortOrder.ascending,
              label: Text('Ascending'),
              icon: Icon(Icons.arrow_upward, size: 16),
            ),
            ButtonSegment(
              value: SortOrder.descending,
              label: Text('Descending'),
              icon: Icon(Icons.arrow_downward, size: 16),
            ),
          ],
          selected: {_sortOrder},
          onSelectionChanged: (Set<SortOrder> newSelection) {
            setState(() => _sortOrder = newSelection.first);
            HapticFeedback.lightImpact();
          },
        ),
      ],
    );
  }

  // ==========================================
  // DYNAMIC SEARCH SECTION
  // ==========================================

  Widget _buildDynamicSearchSection<T>({
    required String title,
    required IconData icon,
    required String hint,
    required TextEditingController controller,
    required List<T> searchResults,
    required List<T> selectedItems,
    required bool isLoading,
    required Function(String) onSearch,
    required Function(T) onAdd,
    required Function(T) onRemove,
    required Widget Function(T) itemBuilder,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(title, icon),
        const SizedBox(height: AppConstants.paddingSmall),

        // Search Input
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon),
            suffixIcon: isLoading
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          controller.clear();
                          onSearch('');
                        },
                      )
                    : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onChanged: (value) => onSearch(value),
        ),

        // Search Results
        if (searchResults.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.outline,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: searchResults.length,
              itemBuilder: (context, index) {
                final item = searchResults[index];
                return ListTile(
                  title: itemBuilder(item),
                  trailing: const Icon(Icons.add),
                  onTap: () => onAdd(item),
                );
              },
            ),
          ),
        ],

        // Selected Items
        if (selectedItems.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: selectedItems.map((item) {
              return Chip(
                label: itemBuilder(item),
                onDeleted: () => onRemove(item),
                deleteIcon: const Icon(Icons.close, size: 18),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  // ==========================================
  // HELPER METHODS
  // ==========================================

  Widget _buildSectionTitle(String title, [IconData? icon]) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(
            icon,
            size: 18,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
        ],
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  Widget _buildYearDropdown({
    required String label,
    required int? value,
    required ValueChanged<int?> onChanged,
  }) {
    final currentYear = DateTime.now().year;
    final years = List.generate(
      currentYear - 1970 + 2,
      (index) => currentYear + 1 - index,
    );

    return DropdownButtonFormField<int>(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
      ),
      value: value,
      items: [
        const DropdownMenuItem<int>(
          value: null,
          child: Text('Any'),
        ),
        ...years.map((year) => DropdownMenuItem<int>(
              value: year,
              child: Text(year.toString()),
            )),
      ],
      onChanged: onChanged,
    );
  }

  Widget _buildApplyButton() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _applyFilters,
            icon: const Icon(Icons.check),
            label: const Text('Apply Filters'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // SEARCH DEBOUNCE METHODS
  // ==========================================

  void _searchCompanies(String query) {
    if (widget.onSearchCompanies == null) return;

    _companyDebounce?.cancel();
    if (query.isEmpty) {
      setState(() => _companySearchResults.clear());
      return;
    }

    setState(() => _isSearchingCompanies = true);

    _companyDebounce = Timer(const Duration(milliseconds: 500), () async {
      try {
        final results = await widget.onSearchCompanies!(query);
        if (mounted) {
          setState(() {
            _companySearchResults = results;
            _isSearchingCompanies = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isSearchingCompanies = false);
        }
      }
    });
  }

  void _searchGameEngines(String query) {
    if (widget.onSearchGameEngines == null) return;

    _engineDebounce?.cancel();
    if (query.isEmpty) {
      setState(() => _engineSearchResults.clear());
      return;
    }

    setState(() => _isSearchingEngines = true);

    _engineDebounce = Timer(const Duration(milliseconds: 500), () async {
      try {
        final results = await widget.onSearchGameEngines!(query);
        if (mounted) {
          setState(() {
            _engineSearchResults = results;
            _isSearchingEngines = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isSearchingEngines = false);
        }
      }
    });
  }

  void _searchFranchises(String query) {
    if (widget.onSearchFranchises == null) return;

    _franchiseDebounce?.cancel();
    if (query.isEmpty) {
      setState(() => _franchiseSearchResults.clear());
      return;
    }

    setState(() => _isSearchingFranchises = true);

    _franchiseDebounce = Timer(const Duration(milliseconds: 500), () async {
      try {
        final results = await widget.onSearchFranchises!(query);
        if (mounted) {
          setState(() {
            _franchiseSearchResults = results;
            _isSearchingFranchises = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isSearchingFranchises = false);
        }
      }
    });
  }

  void _searchCollections(String query) {
    if (widget.onSearchCollections == null) return;

    _collectionDebounce?.cancel();
    if (query.isEmpty) {
      setState(() => _collectionSearchResults.clear());
      return;
    }

    setState(() => _isSearchingCollections = true);

    _collectionDebounce = Timer(const Duration(milliseconds: 500), () async {
      try {
        final results = await widget.onSearchCollections!(query);
        if (mounted) {
          setState(() {
            _collectionSearchResults = results;
            _isSearchingCollections = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isSearchingCollections = false);
        }
      }
    });
  }

  // ==========================================
  // ACTIONS
  // ==========================================

  void _clearAllFilters() {
    setState(() {
      _selectedGenres.clear();
      _selectedPlatforms.clear();
      _minRating = 0.0;
      _maxRating = 10.0;
      _startYear = null;
      _endYear = null;
      _selectedThemes.clear();
      _selectedGameModes.clear();
      _selectedPlayerPerspectives.clear();
      _selectedCompanies.clear();
      _selectedGameEngines.clear();
      _selectedFranchises.clear();
      _selectedCollections.clear();
      _sortBy = GameSortBy.relevance;
      _sortOrder = SortOrder.descending;
    });
    HapticFeedback.mediumImpact();
  }

  void _applyFilters() {
    final newFilters = _filters.copyWith(
      genreIds: _selectedGenres.isEmpty ? null : _selectedGenres,
      platformIds: _selectedPlatforms.isEmpty ? null : _selectedPlatforms,
      minRating: _minRating > 0 ? _minRating : null,
      maxRating: _maxRating < 10 ? _maxRating : null,
      releaseDateFrom: _startYear != null ? DateTime(_startYear!) : null,
      releaseDateTo: _endYear != null ? DateTime(_endYear!, 12, 31) : null,
      themesIds: _selectedThemes.isEmpty ? null : _selectedThemes,
      gameModesIds: _selectedGameModes.isEmpty ? null : _selectedGameModes,
      playerPerspectiveIds: _selectedPlayerPerspectives.isEmpty
          ? null
          : _selectedPlayerPerspectives,
      companyIds: _selectedCompanies.isEmpty
          ? null
          : _selectedCompanies.map((c) => c.id).toList(),
      gameEngineIds: _selectedGameEngines.isEmpty
          ? null
          : _selectedGameEngines.map((e) => e.id).toList(),
      franchiseIds: _selectedFranchises.isEmpty
          ? null
          : _selectedFranchises.map((f) => f.id).toList(),
      collectionIds: _selectedCollections.isEmpty
          ? null
          : _selectedCollections.map((c) => c.id).toList(),
      sortBy: _sortBy,
      sortOrder: _sortOrder,
    );

    HapticFeedback.mediumImpact();
    Navigator.pop(context, newFilters);
  }

  int _getActiveFilterCount() {
    int count = 0;
    if (_selectedGenres.isNotEmpty) count++;
    if (_selectedPlatforms.isNotEmpty) count++;
    if (_minRating > 0 || _maxRating < 10) count++;
    if (_startYear != null || _endYear != null) count++;
    if (_selectedThemes.isNotEmpty) count++;
    if (_selectedGameModes.isNotEmpty) count++;
    if (_selectedPlayerPerspectives.isNotEmpty) count++;
    if (_selectedCompanies.isNotEmpty) count++;
    if (_selectedGameEngines.isNotEmpty) count++;
    if (_selectedFranchises.isNotEmpty) count++;
    if (_selectedCollections.isNotEmpty) count++;
    return count;
  }

  String _getSortLabel(GameSortBy sort) {
    switch (sort) {
      case GameSortBy.relevance:
        return 'Relevance';
      case GameSortBy.popularity:
        return 'Popularity';
      case GameSortBy.rating:
        return 'Rating';
      case GameSortBy.ratingCount:
        return 'Rating Count';
      case GameSortBy.releaseDate:
        return 'Release Date';
      case GameSortBy.name:
        return 'Name';
      case GameSortBy.aggregatedRating:
        return 'Aggregated Rating';
      case GameSortBy.userRating:
        return 'User Rating';
      case GameSortBy.addedDate:
        return 'Added Date';
      case GameSortBy.lastPlayed:
        return 'Last Played';
      case GameSortBy.userRatingDate:
        return 'User Rating Date';
    }
  }

  IconData _getSortIcon(GameSortBy sort) {
    switch (sort) {
      case GameSortBy.relevance:
        return Icons.search;
      case GameSortBy.popularity:
        return Icons.trending_up;
      case GameSortBy.rating:
        return Icons.star;
      case GameSortBy.ratingCount:
        return Icons.stars;
      case GameSortBy.releaseDate:
        return Icons.calendar_today;
      case GameSortBy.name:
        return Icons.sort_by_alpha;
      case GameSortBy.aggregatedRating:
        return Icons.star_border;
      case GameSortBy.userRating:
        return Icons.person;
      case GameSortBy.addedDate:
        return Icons.add_circle_outline;
      case GameSortBy.lastPlayed:
        return Icons.play_circle_outline;
      case GameSortBy.userRatingDate:
        return Icons.date_range;
    }
  }
}
