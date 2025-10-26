// ==========================================
// 2. VOLLSTÄNDIGES FILTER BOTTOM SHEET
// ==========================================

// lib/presentation/widgets/filter_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gamer_grove/domain/entities/ageRating/age_rating.dart';
import 'package:gamer_grove/domain/entities/game/game_status.dart';
import 'package:gamer_grove/domain/entities/game/game_type.dart';
import 'package:gamer_grove/domain/entities/keyword.dart';
import 'package:gamer_grove/domain/entities/language/language.dart';
import 'package:gamer_grove/domain/entities/theme.dart' as gg_theme;
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
  final List<GameMode> availableGameModes;
  final List<PlayerPerspective> availablePlayerPerspectives;
  final List<GameType> availableGameTypes;
  final List<GameStatus> availableGameStatuses;

  // Callback functions for dynamic search
  final Future<List<Company>> Function(String query)? onSearchCompanies;
  final Future<List<GameEngine>> Function(String query)? onSearchGameEngines;
  final Future<List<Franchise>> Function(String query)? onSearchFranchises;
  final Future<List<Collection>> Function(String query)? onSearchCollections;
  final Future<List<Keyword>> Function(String query)? onSearchKeywords;
  final Future<List<Language>> Function(String query)? onSearchLanguages;
  final Future<List<Platform>> Function(String query)? onSearchPlatforms;
  final Future<List<gg_theme.Theme>> Function(String query)? onSearchThemes;
  final Future<List<AgeRating>> Function(String query)? onSearchAgeRatings;
  const FilterBottomSheet({
    super.key,
    required this.currentFilters,
    required this.availableGenres,
    required this.availableGameTypes,
    required this.availableGameStatuses,
    required this.availableGameModes,
    required this.availablePlayerPerspectives,
    this.onSearchCompanies,
    this.onSearchGameEngines,
    this.onSearchFranchises,
    this.onSearchCollections,
    this.onSearchKeywords,
    this.onSearchLanguages,
    this.onSearchPlatforms,
    this.onSearchThemes,
    this.onSearchAgeRatings,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();

  static Future<SearchFilters?> show({
    required BuildContext context,
    required SearchFilters currentFilters,
    required List<Genre> availableGenres,
    required List<PlayerPerspective> availablePlayerPerspectives,
    required List<GameType> availableGameTypes,
    required List<GameMode> availableGameModes,
    required List<GameStatus> availableGameStatuses,
    Future<List<Company>> Function(String query)? onSearchCompanies,
    Future<List<GameEngine>> Function(String query)? onSearchGameEngines,
    Future<List<Franchise>> Function(String query)? onSearchFranchises,
    Future<List<Collection>> Function(String query)? onSearchCollections,
    Future<List<Keyword>> Function(String query)? onSearchKeywords,
    Future<List<Language>> Function(String query)? onSearchLanguages,
    Future<List<Platform>> Function(String query)? onSearchPlatforms,
    Future<List<gg_theme.Theme>> Function(String query)? onSearchThemes,
    Future<List<AgeRating>> Function(String query)? onSearchAgeRatings,
  }) {
    return showModalBottomSheet<SearchFilters>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheet(
        currentFilters: currentFilters,
        availableGenres: availableGenres,
        availableGameModes: availableGameModes,
        availablePlayerPerspectives: availablePlayerPerspectives,
        availableGameTypes: availableGameTypes,
        availableGameStatuses: availableGameStatuses,
        onSearchCompanies: onSearchCompanies,
        onSearchGameEngines: onSearchGameEngines,
        onSearchFranchises: onSearchFranchises,
        onSearchCollections: onSearchCollections,
        onSearchKeywords: onSearchKeywords,
        onSearchLanguages: onSearchLanguages,
        onSearchPlatforms: onSearchPlatforms,
        onSearchThemes: onSearchThemes,
        onSearchAgeRatings: onSearchAgeRatings,
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
  late List<int> _selectedGameTypes;
  late List<int> _selectedGameModes;
  late List<int> _selectedGameStatuses;
  late List<int> _selectedPlayerPerspectives;

  late double _minTotalRating;
  late double _maxTotalRating;
  int? _minTotalRatingCount;

  late double _minUserRating;
  late double _maxUserRating;
  int? _minUserRatingCount;

  late double _minAggregatedRating;
  late double _maxAggregatedRating;
  int? _minAggregatedRatingCount;

  int? _minFollows;
  int? _minHypes;

  int? _startYear;
  int? _endYear;
  late GameSortBy _sortBy;
  late SortOrder _sortOrder;

  // Selected values - Dynamic
  final List<Company> _selectedCompanies = [];
  final List<GameEngine> _selectedGameEngines = [];
  final List<Franchise> _selectedFranchises = [];
  final List<Collection> _selectedCollections = [];
  final List<gg_theme.Theme> _selectedThemes = [];
  final List<AgeRating> _selectedAgeRatings = [];
  final List<Keyword> _selectedKeywords = [];
  final List<Language> _selectedLanguages = [];
  final List<Platform> _selectedPlatforms = [];

  // Search controllers
  final TextEditingController _companySearchController =
      TextEditingController();
  final TextEditingController _engineSearchController = TextEditingController();
  final TextEditingController _franchiseSearchController =
      TextEditingController();
  final TextEditingController _collectionSearchController =
      TextEditingController();
  final TextEditingController _platformSearchController =
      TextEditingController();
  final TextEditingController _themeSearchController = TextEditingController();
  final TextEditingController _ageRatingSearchController =
      TextEditingController();
  final TextEditingController _keywordSearchController =
      TextEditingController();
  final TextEditingController _languagesSearchController =
      TextEditingController();

  // Search results
  List<Company> _companySearchResults = [];
  List<GameEngine> _engineSearchResults = [];
  List<Franchise> _franchiseSearchResults = [];
  List<Collection> _collectionSearchResults = [];
  List<Platform> _platformSearchResults = [];
  List<gg_theme.Theme> _themeSearchResults = [];
  List<AgeRating> _ageRatingSearchResults = [];
  List<Keyword> _keywordSearchResults = [];
  List<Language> _languageSearchResults = [];

  // Loading states
  bool _isSearchingCompanies = false;
  bool _isSearchingEngines = false;
  bool _isSearchingFranchises = false;
  bool _isSearchingCollections = false;
  bool _isSearchingPlatforms = false;
  bool _isSearchingThemes = false;
  bool _isSearchingAgeRatings = false;
  bool _isSearchingKeywords = false;
  bool _isSearchingLanguages = false;

  // Debounce timers
  Timer? _companyDebounce;
  Timer? _engineDebounce;
  Timer? _franchiseDebounce;
  Timer? _collectionDebounce;
  Timer? _platformDebounce;
  Timer? _themeDebounce;
  Timer? _ageRatingDebounce;
  Timer? _keywordDebounce;
  Timer? _languageDebounce;

  @override
  void initState() {
    super.initState();
    _filters = widget.currentFilters;
    _tabController = TabController(length: 4, vsync: this);

    // Initialize basic filters
    _selectedGenres = List.from(_filters.genreIds);
    _selectedGameModes = List.from(_filters.gameModesIds);
    _selectedPlayerPerspectives = List.from(_filters.playerPerspectiveIds);
    _selectedGameStatuses = List.from(_filters.gameStatusIds);
    _selectedGameTypes = List.from(_filters.gameTypeIds);

    // Initialize rating filters
    _minTotalRating = _filters.minTotalRating ?? 0.0;
    _maxTotalRating = _filters.maxTotalRating ?? 10.0;
    _minTotalRatingCount = _filters.minTotalRatingCount;

    _minUserRating = _filters.minUserRating ?? 0.0;
    _maxUserRating = _filters.maxUserRating ?? 10.0;
    _minUserRatingCount = _filters.minUserRatingCount;

    _minAggregatedRating = _filters.minAggregatedRating ?? 0.0;
    _maxAggregatedRating = _filters.maxAggregatedRating ?? 100.0;
    _minAggregatedRatingCount = _filters.minAggregatedRatingCount;

    // Initialize popularity filters
    _minFollows = null;
    _minHypes = _filters.minHypes;

    _startYear = _filters.releaseDateFrom?.year;
    _endYear = _filters.releaseDateTo?.year;
    _sortBy = _filters.sortBy;
    _sortOrder = _filters.sortOrder;
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
    _platformDebounce?.cancel();
    _themeDebounce?.cancel();
    _ageRatingDebounce?.cancel();
    _keywordDebounce?.cancel();
    _languageDebounce?.cancel();
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
            isScrollable: true,
            tabs: const [
              Tab(text: 'Game', icon: Icon(Icons.videogame_asset, size: 20)),
              Tab(text: 'Quality', icon: Icon(Icons.stars, size: 20)),
              Tab(text: 'Meta', icon: Icon(Icons.more_horiz, size: 20)),
              Tab(text: 'Sort', icon: Icon(Icons.sort, size: 20)),
            ],
          ),

          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildGamePropertiesTab(),
                _buildQualityTab(),
                _buildMetaTab(),
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
  // GAME PROPERTIES TAB
  // ==========================================

  Widget _buildGamePropertiesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGenresSection(),
          _buildDynamicSearchSection(
            title: 'Platforms',
            icon: Icons.devices,
            hint: 'Search platforms...',
            controller: _platformSearchController,
            searchResults: _platformSearchResults,
            selectedItems: _selectedPlatforms,
            isLoading: _isSearchingPlatforms,
            onSearch: _searchPlatforms,
            onAdd: (platform) {
              setState(() {
                _selectedPlatforms.add(platform);
                _platformSearchResults.clear();
                _platformSearchController.clear();
              });
            },
            onRemove: (platform) {
              setState(() {
                _selectedPlatforms.remove(platform);
              });
            },
            itemBuilder: (item) => Text((item).name),
          ),
          _buildGameModesSection(),
          _buildGameTypeSection(),
          _buildGameStatusSection(),
          _buildPlayerPerspectivesSection(),
          _buildReleaseYearSection(),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  // ==========================================
  // QUALITY & POPULARITY TAB
  // ==========================================

  Widget _buildQualityTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRatingsExpansionTile(),
          const SizedBox(height: AppConstants.paddingMedium),
          _buildPopularityExpansionTile(),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  // ==========================================
  // META & CONTENT TAB
  // ==========================================

  Widget _buildMetaTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDynamicSearchSection(
            title: 'Themes',
            icon: Icons.palette,
            hint: 'Search themes...',
            controller: _themeSearchController,
            searchResults: _themeSearchResults,
            selectedItems: _selectedThemes,
            isLoading: _isSearchingThemes,
            onSearch: _searchThemes,
            onAdd: (theme) {
              setState(() {
                _selectedThemes.add(theme);
                _themeSearchResults.clear();
                _themeSearchController.clear();
              });
            },
            onRemove: (theme) {
              setState(() {
                _selectedThemes.remove(theme);
              });
            },
            itemBuilder: (item) => Text((item).name),
          ),
          _buildDynamicSearchSection(
            title: 'Keywords',
            icon: Icons.label,
            hint: 'Search keywords...',
            controller: _keywordSearchController,
            searchResults: _keywordSearchResults,
            selectedItems: _selectedKeywords,
            isLoading: _isSearchingKeywords,
            onSearch: _searchKeywords,
            onAdd: (keyword) {
              setState(() {
                _selectedKeywords.add(keyword);
                _keywordSearchResults.clear();
                _keywordSearchController.clear();
              });
            },
            onRemove: (keyword) {
              setState(() {
                _selectedKeywords.remove(keyword);
              });
            },
            itemBuilder: (item) => Text((item).name),
          ),
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
            itemBuilder: (item) => Text((item).name),
          ),
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
            itemBuilder: (item) => Text((item).name),
          ),
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
            itemBuilder: (item) => Text((item).name),
          ),
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
            itemBuilder: (item) => Text((item).name),
          ),
          _buildDynamicSearchSection(
            title: 'Age Ratings',
            icon: Icons.verified_user,
            hint: 'Search age ratings...',
            controller: _ageRatingSearchController,
            searchResults: _ageRatingSearchResults,
            selectedItems: _selectedAgeRatings,
            isLoading: _isSearchingAgeRatings,
            onSearch: _searchAgeRatings,
            onAdd: (ageRating) {
              setState(() {
                _selectedAgeRatings.add(ageRating);
                _ageRatingSearchResults.clear();
                _ageRatingSearchController.clear();
              });
            },
            onRemove: (ageRating) {
              setState(() {
                _selectedAgeRatings.remove(ageRating);
              });
            },
            itemBuilder: (item) => Text((item).displayName),
          ),
          _buildDynamicSearchSection(
            title: 'Languages',
            icon: Icons.language,
            hint: 'Search languages...',
            controller: _languagesSearchController,
            searchResults: _languageSearchResults,
            selectedItems: _selectedLanguages,
            isLoading: _isSearchingLanguages,
            onSearch: _searchLanguages,
            onAdd: (language) {
              setState(() {
                _selectedLanguages.add(language);
                _languageSearchResults.clear();
                _languagesSearchController.clear();
              });
            },
            onRemove: (language) {
              setState(() {
                _selectedLanguages.remove(language);
              });
            },
            itemBuilder: (item) => Text((item).displayName),
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
  // REUSABLE COMPONENTS
  // ==========================================

  Widget _buildFilterCard({
    required String title,
    required IconData icon,
    required Widget child,
    VoidCallback? onClear,
    int? activeCount,
  }) {
    final theme = Theme.of(context);
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 20, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (activeCount != null && activeCount > 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$activeCount',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (onClear != null && activeCount != null && activeCount > 0)
                  TextButton.icon(
                    onPressed: onClear,
                    icon: const Icon(Icons.clear, size: 16),
                    label: const Text('Clear'),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildChipGridSection({
    required String title,
    required IconData icon,
    required List<dynamic> items,
    required List<int> selectedIds,
    required String Function(dynamic) getLabel,
    required int Function(dynamic) getId,
    bool isHorizontalScroll = false,
  }) {
    return _buildFilterCard(
      title: title,
      icon: icon,
      activeCount: selectedIds.length,
      onClear: selectedIds.isEmpty
          ? null
          : () {
              setState(() => selectedIds.clear());
              HapticFeedback.lightImpact();
            },
      child: isHorizontalScroll
          ? SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final id = getId(item);
                  final isSelected = selectedIds.contains(id);
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(getLabel(item)),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            selectedIds.add(id);
                          } else {
                            selectedIds.remove(id);
                          }
                        });
                        HapticFeedback.lightImpact();
                      },
                    ),
                  );
                },
              ),
            )
          : Wrap(
              spacing: 8,
              runSpacing: 8,
              children: items.map((item) {
                final id = getId(item);
                final isSelected = selectedIds.contains(id);
                return FilterChip(
                  label: Text(getLabel(item)),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        selectedIds.add(id);
                      } else {
                        selectedIds.remove(id);
                      }
                    });
                    HapticFeedback.lightImpact();
                  },
                );
              }).toList(),
            ),
    );
  }

  // ==========================================
  // SECTION BUILDERS
  // ==========================================

  Widget _buildGenresSection() {
    if (widget.availableGenres.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    return _buildChipGridSection(
      title: 'Genres',
      icon: Icons.bookmarks,
      items: widget.availableGenres,
      selectedIds: _selectedGenres,
      getLabel: (genre) => genre.name,
      getId: (genre) => genre.id,
      isHorizontalScroll: true, // Horizontal scroll for better space usage
    );
  }

  Widget _buildGameTypeSection() {
    if (widget.availableGameTypes.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    return _buildChipGridSection(
      title: 'Game Types',
      icon: Icons.category,
      items: widget.availableGameTypes,
      selectedIds: _selectedGameTypes,
      getLabel: (type) => type.type,
      getId: (type) => type.id,
    );
  }

  Widget _buildGameStatusSection() {
    if (widget.availableGameStatuses.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    return _buildChipGridSection(
      title: 'Game Status',
      icon: Icons.info_outline,
      items: widget.availableGameStatuses,
      selectedIds: _selectedGameStatuses,
      getLabel: (status) => status.status,
      getId: (status) => status.id,
    );
  }

  Widget _buildGameModesSection() {
    return _buildChipGridSection(
      title: 'Game Modes',
      icon: Icons.sports_esports,
      items: widget.availableGameModes,
      selectedIds: _selectedGameModes,
      getLabel: (mode) => mode.name,
      getId: (mode) => mode.id,
    );
  }

  Widget _buildPlayerPerspectivesSection() {
    return _buildChipGridSection(
      title: 'Player Perspectives',
      icon: Icons.remove_red_eye,
      items: widget.availablePlayerPerspectives,
      selectedIds: _selectedPlayerPerspectives,
      getLabel: (perspective) => perspective.name,
      getId: (perspective) => perspective.id,
    );
  }

  // ==========================================
  // EXPANSION TILES FOR QUALITY TAB
  // ==========================================

  Widget _buildRatingsExpansionTile() {
    final theme = Theme.of(context);
    final hasActiveFilters = (_minTotalRating > 0 ||
            _maxTotalRating < 10 ||
            _minTotalRatingCount != null) ||
        (_minUserRating > 0 ||
            _maxUserRating < 10 ||
            _minUserRatingCount != null) ||
        (_minAggregatedRating > 0 ||
            _maxAggregatedRating < 100 ||
            _minAggregatedRatingCount != null);

    return Card(
      elevation: 2,
      child: ExpansionTile(
        leading: Icon(Icons.star, color: theme.colorScheme.primary),
        title: Row(
          children: [
            const Text('Rating Filters'),
            if (hasActiveFilters) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Active',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildRatingSection(),
                const SizedBox(height: AppConstants.paddingLarge),
                _buildUserRatingSection(),
                const SizedBox(height: AppConstants.paddingLarge),
                _buildAggregatedRatingSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopularityExpansionTile() {
    final theme = Theme.of(context);
    final hasActiveFilters = _minHypes != null || _minFollows != null;

    return Card(
      elevation: 2,
      child: ExpansionTile(
        leading: Icon(Icons.trending_up, color: theme.colorScheme.primary),
        title: Row(
          children: [
            const Text('Popularity & Hype'),
            if (hasActiveFilters) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Active',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            child: _buildPopularitySection(),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionTitle('Total Rating', Icons.star),
            Text(
              '${_minTotalRating.toStringAsFixed(1)} - ${_maxTotalRating.toStringAsFixed(1)}',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.paddingSmall),
        RangeSlider(
          values: RangeValues(_minTotalRating, _maxTotalRating),
          min: 0,
          max: 10,
          divisions: 20,
          labels: RangeLabels(
            _minTotalRating.toStringAsFixed(1),
            _maxTotalRating.toStringAsFixed(1),
          ),
          onChanged: (RangeValues values) {
            setState(() {
              _minTotalRating = values.start;
              _maxTotalRating = values.end;
            });
          },
          onChangeEnd: (_) => HapticFeedback.lightImpact(),
        ),
        const SizedBox(height: 8),
        TextField(
          decoration: InputDecoration(
            labelText: 'Min. Rating Count',
            hintText: 'e.g., 100',
            border: const OutlineInputBorder(),
            suffixIcon: _minTotalRatingCount != null
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      setState(() => _minTotalRatingCount = null);
                    },
                  )
                : null,
          ),
          keyboardType: TextInputType.number,
          controller: TextEditingController(
            text: _minTotalRatingCount?.toString() ?? '',
          )..selection = TextSelection.collapsed(
              offset: _minTotalRatingCount?.toString().length ?? 0,
            ),
          onChanged: (value) {
            setState(() {
              _minTotalRatingCount = value.isEmpty ? null : int.tryParse(value);
            });
          },
        ),
      ],
    );
  }

  Widget _buildUserRatingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionTitle('User Rating (IGDB)', Icons.person),
            Text(
              '${_minUserRating.toStringAsFixed(1)} - ${_maxUserRating.toStringAsFixed(1)}',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.paddingSmall),
        RangeSlider(
          values: RangeValues(_minUserRating, _maxUserRating),
          min: 0,
          max: 10,
          divisions: 20,
          labels: RangeLabels(
            _minUserRating.toStringAsFixed(1),
            _maxUserRating.toStringAsFixed(1),
          ),
          onChanged: (RangeValues values) {
            setState(() {
              _minUserRating = values.start;
              _maxUserRating = values.end;
            });
          },
          onChangeEnd: (_) => HapticFeedback.lightImpact(),
        ),
        const SizedBox(height: 8),
        TextField(
          decoration: InputDecoration(
            labelText: 'Min. User Rating Count',
            hintText: 'e.g., 50',
            border: const OutlineInputBorder(),
            suffixIcon: _minUserRatingCount != null
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      setState(() => _minUserRatingCount = null);
                    },
                  )
                : null,
          ),
          keyboardType: TextInputType.number,
          controller: TextEditingController(
            text: _minUserRatingCount?.toString() ?? '',
          )..selection = TextSelection.collapsed(
              offset: _minUserRatingCount?.toString().length ?? 0,
            ),
          onChanged: (value) {
            setState(() {
              _minUserRatingCount = value.isEmpty ? null : int.tryParse(value);
            });
          },
        ),
      ],
    );
  }

  Widget _buildAggregatedRatingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionTitle('Critic Rating', Icons.rate_review),
            Text(
              '${_minAggregatedRating.toStringAsFixed(0)} - ${_maxAggregatedRating.toStringAsFixed(0)}',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.paddingSmall),
        RangeSlider(
          values: RangeValues(_minAggregatedRating, _maxAggregatedRating),
          min: 0,
          max: 100,
          divisions: 20,
          labels: RangeLabels(
            _minAggregatedRating.toStringAsFixed(0),
            _maxAggregatedRating.toStringAsFixed(0),
          ),
          onChanged: (RangeValues values) {
            setState(() {
              _minAggregatedRating = values.start;
              _maxAggregatedRating = values.end;
            });
          },
          onChangeEnd: (_) => HapticFeedback.lightImpact(),
        ),
        const SizedBox(height: 8),
        TextField(
          decoration: InputDecoration(
            labelText: 'Min. Critic Rating Count',
            hintText: 'e.g., 10',
            border: const OutlineInputBorder(),
            suffixIcon: _minAggregatedRatingCount != null
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      setState(() => _minAggregatedRatingCount = null);
                    },
                  )
                : null,
          ),
          keyboardType: TextInputType.number,
          controller: TextEditingController(
            text: _minAggregatedRatingCount?.toString() ?? '',
          )..selection = TextSelection.collapsed(
              offset: _minAggregatedRatingCount?.toString().length ?? 0,
            ),
          onChanged: (value) {
            setState(() {
              _minAggregatedRatingCount =
                  value.isEmpty ? null : int.tryParse(value);
            });
          },
        ),
      ],
    );
  }

  Widget _buildPopularitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Hypes', Icons.whatshot),
        Text(
          'For unreleased or upcoming games',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: AppConstants.paddingSmall),
        TextField(
          decoration: InputDecoration(
            labelText: 'Minimum Hypes',
            hintText: 'e.g., 100',
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.whatshot),
            suffixIcon: _minHypes != null
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      setState(() => _minHypes = null);
                    },
                  )
                : null,
          ),
          keyboardType: TextInputType.number,
          controller: TextEditingController(
            text: _minHypes?.toString() ?? '',
          )..selection = TextSelection.collapsed(
              offset: _minHypes?.toString().length ?? 0,
            ),
          onChanged: (value) {
            setState(() {
              _minHypes = value.isEmpty ? null : int.tryParse(value);
            });
          },
        ),
        const SizedBox(height: AppConstants.paddingLarge),
        _buildSectionTitle('Follows', Icons.people),
        Text(
          'Users following this game',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: AppConstants.paddingSmall),
        TextField(
          decoration: InputDecoration(
            labelText: 'Minimum Follows',
            hintText: 'e.g., 500',
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.people),
            suffixIcon: _minFollows != null
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      setState(() => _minFollows = null);
                    },
                  )
                : null,
          ),
          keyboardType: TextInputType.number,
          controller: TextEditingController(
            text: _minFollows?.toString() ?? '',
          )..selection = TextSelection.collapsed(
              offset: _minFollows?.toString().length ?? 0,
            ),
          onChanged: (value) {
            setState(() {
              _minFollows = value.isEmpty ? null : int.tryParse(value);
            });
          },
        ),
      ],
    );
  }

  Widget _buildReleaseYearSection() {
    final theme = Theme.of(context);
    final hasDateFilter = _startYear != null || _endYear != null;

    String getDateRangeText() {
      if (_startYear != null && _endYear != null) {
        return 'From $_startYear to $_endYear';
      } else if (_startYear != null) {
        return 'From $_startYear';
      } else if (_endYear != null) {
        return 'Until $_endYear';
      }
      return 'Tap to select date range';
    }

    return _buildFilterCard(
      title: 'Release Date',
      icon: Icons.calendar_today,
      activeCount: hasDateFilter ? 1 : null,
      onClear: hasDateFilter
          ? () {
              setState(() {
                _startYear = null;
                _endYear = null;
              });
              HapticFeedback.lightImpact();
            }
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => _showDateRangePicker(),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: theme.colorScheme.outline.withOpacity(0.5),
                ),
                borderRadius: BorderRadius.circular(12),
                color:
                    theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      getDateRangeText(),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: hasDateFilter
                            ? theme.colorScheme.onSurface
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.calendar_month,
                    color: theme.colorScheme.primary,
                  ),
                ],
              ),
            ),
          ),
          if (hasDateFilter) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                if (_startYear != null)
                  Expanded(
                    child: _buildDateChip(
                      label: 'From: $_startYear',
                      onRemove: () {
                        setState(() => _startYear = null);
                        HapticFeedback.lightImpact();
                      },
                    ),
                  ),
                if (_startYear != null && _endYear != null)
                  const SizedBox(width: 8),
                if (_endYear != null)
                  Expanded(
                    child: _buildDateChip(
                      label: 'To: $_endYear',
                      onRemove: () {
                        setState(() => _endYear = null);
                        HapticFeedback.lightImpact();
                      },
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDateChip(
      {required String label, required VoidCallback onRemove}) {
    final theme = Theme.of(context);
    return Chip(
      label: Text(label),
      onDeleted: onRemove,
      deleteIcon: const Icon(Icons.close, size: 18),
      backgroundColor: theme.colorScheme.secondaryContainer,
      labelStyle: TextStyle(
        color: theme.colorScheme.onSecondaryContainer,
      ),
    );
  }

  Future<void> _showDateRangePicker() async {
    final now = DateTime.now();
    final firstDate = DateTime(1970);
    final lastDate = DateTime(now.year + 2);

    final picked = await showDateRangePicker(
      context: context,
      firstDate: firstDate,
      lastDate: lastDate,
      initialDateRange: _startYear != null && _endYear != null
          ? DateTimeRange(
              start: DateTime(_startYear!),
              end: DateTime(_endYear!, 12, 31),
            )
          : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startYear = picked.start.year;
        _endYear = picked.end.year;
      });
      HapticFeedback.lightImpact();
    }
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
    required void Function(String) onSearch,
    required void Function(T) onAdd,
    required void Function(T) onRemove,
    required Widget Function(T) itemBuilder,
  }) {
    final theme = Theme.of(context);

    return _buildFilterCard(
      title: title,
      icon: icon,
      activeCount: selectedItems.length,
      onClear: selectedItems.isEmpty
          ? null
          : () {
              setState(() {
                selectedItems.clear();
                controller.clear();
                onSearch('');
              });
            },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
              filled: true,
              fillColor:
                  theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
            ),
            onChanged: (value) => onSearch(value),
          ),

          // Search Results
          if (searchResults.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              constraints: const BoxConstraints(maxHeight: 200),
              decoration: BoxDecoration(
                border: Border.all(
                  color: theme.colorScheme.outline.withOpacity(0.5),
                ),
                borderRadius: BorderRadius.circular(12),
                color: theme.colorScheme.surface,
              ),
              child: Material(
                color: Colors.transparent,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: searchResults.length,
                  itemBuilder: (context, index) {
                    final item = searchResults[index];
                    return ListTile(
                      title: itemBuilder(item),
                      trailing: Icon(Icons.add_circle_outline,
                          color: theme.colorScheme.primary),
                      onTap: () => onAdd(item),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],

          // Selected Items
          if (selectedItems.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: selectedItems.map((item) {
                return Chip(
                  label: itemBuilder(item),
                  onDeleted: () => onRemove(item),
                  deleteIcon: const Icon(Icons.close, size: 18),
                  backgroundColor: theme.colorScheme.secondaryContainer,
                  labelStyle: TextStyle(
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
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

  void _searchKeywords(String query) {
    if (widget.onSearchKeywords == null) return;

    _keywordDebounce?.cancel();
    if (query.isEmpty) {
      setState(() => _keywordSearchResults.clear());
      return;
    }

    setState(() => _isSearchingKeywords = true);

    _keywordDebounce = Timer(const Duration(milliseconds: 500), () async {
      try {
        final results = await widget.onSearchKeywords!(query);
        if (mounted) {
          setState(() {
            _keywordSearchResults = results;
            _isSearchingKeywords = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isSearchingKeywords = false);
        }
      }
    });
  }

  void _searchLanguages(String query) {
    if (widget.onSearchLanguages == null) return;

    _languageDebounce?.cancel();
    if (query.isEmpty) {
      setState(() => _languageSearchResults.clear());
      return;
    }

    setState(() => _isSearchingLanguages = true);

    _languageDebounce = Timer(const Duration(milliseconds: 500), () async {
      try {
        final results = await widget.onSearchLanguages!(query);
        if (mounted) {
          setState(() {
            _languageSearchResults = results;
            _isSearchingLanguages = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isSearchingLanguages = false);
        }
      }
    });
  }

  void _searchAgeRatings(String query) {
    if (widget.onSearchAgeRatings == null) return;

    _ageRatingDebounce?.cancel();
    if (query.isEmpty) {
      setState(() => _ageRatingSearchResults.clear());
      return;
    }

    setState(() => _isSearchingAgeRatings = true);

    _ageRatingDebounce = Timer(const Duration(milliseconds: 500), () async {
      try {
        final results = await widget.onSearchAgeRatings!(query);
        if (mounted) {
          setState(() {
            _ageRatingSearchResults = results;
            _isSearchingAgeRatings = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isSearchingAgeRatings = false);
        }
      }
    });
  }

  void _searchThemes(String query) {
    if (widget.onSearchThemes == null) return;

    _themeDebounce?.cancel();
    if (query.isEmpty) {
      setState(() => _themeSearchResults.clear());
      return;
    }

    setState(() => _isSearchingThemes = true);

    _themeDebounce = Timer(const Duration(milliseconds: 500), () async {
      try {
        final results = await widget.onSearchThemes!(query);
        if (mounted) {
          setState(() {
            _themeSearchResults = results;
            _isSearchingThemes = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isSearchingThemes = false);
        }
      }
    });
  }

  void _searchPlatforms(String query) {
    if (widget.onSearchPlatforms == null) return;

    _platformDebounce?.cancel();
    if (query.isEmpty) {
      setState(() => _platformSearchResults.clear());
      return;
    }

    setState(() => _isSearchingPlatforms = true);

    _platformDebounce = Timer(const Duration(milliseconds: 500), () async {
      try {
        final results = await widget.onSearchPlatforms!(query);
        if (mounted) {
          setState(() {
            _platformSearchResults = results;
            _isSearchingPlatforms = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isSearchingPlatforms = false);
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
      _selectedGameModes.clear();
      _selectedPlayerPerspectives.clear();
      _selectedGameStatuses.clear();
      _selectedGameTypes.clear();

      _selectedThemes.clear();
      _selectedCompanies.clear();
      _selectedGameEngines.clear();
      _selectedFranchises.clear();
      _selectedCollections.clear();
      _selectedThemes.clear();
      _selectedAgeRatings.clear();
      _selectedKeywords.clear();
      _selectedLanguages.clear();

      _selectedPlatforms.clear();

      // Clear rating filters
      _minTotalRating = 0.0;
      _maxTotalRating = 10.0;
      _minTotalRatingCount = null;

      _minUserRating = 0.0;
      _maxUserRating = 10.0;
      _minUserRatingCount = null;

      _minAggregatedRating = 0.0;
      _maxAggregatedRating = 100.0;
      _minAggregatedRatingCount = null;

      // Clear popularity filters
      _minFollows = null;
      _minHypes = null;

      _startYear = null;
      _endYear = null;

      _sortBy = GameSortBy.relevance;
      _sortOrder = SortOrder.descending;
    });
    HapticFeedback.mediumImpact();
  }

  void _applyFilters() {
    final newFilters = _filters.copyWith(
      genreIds: _selectedGenres.isEmpty ? null : _selectedGenres,
      gameModesIds: _selectedGameModes.isEmpty ? null : _selectedGameModes,
      playerPerspectiveIds: _selectedPlayerPerspectives.isEmpty
          ? null
          : _selectedPlayerPerspectives,
      gameStatusIds:
          _selectedGameStatuses.isEmpty ? null : _selectedGameStatuses,
      gameTypeIds: _selectedGameTypes.isEmpty ? null : _selectedGameTypes,
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
      themesIds: _selectedThemes.isEmpty
          ? null
          : _selectedThemes.map((c) => c.id).toList(),
      platformIds: _selectedPlatforms.isEmpty
          ? null
          : _selectedPlatforms.map((p) => p.id).toList(),
      ageRatingIds: _selectedAgeRatings.isEmpty
          ? null
          : _selectedAgeRatings.map((a) => a.id).toList(),
      keywordIds: _selectedKeywords.isEmpty
          ? null
          : _selectedKeywords.map((k) => k.id).toList(),
      languageIds: _selectedLanguages.isEmpty
          ? null
          : _selectedLanguages.map((l) => l.id).toList(),
      // Rating filters
      minTotalRating: _minTotalRating > 0 ? _minTotalRating : null,
      maxTotalRating: _maxTotalRating < 10 ? _maxTotalRating : null,
      minTotalRatingCount: _minTotalRatingCount,
      minUserRating: _minUserRating > 0 ? _minUserRating : null,
      maxUserRating: _maxUserRating < 10 ? _maxUserRating : null,
      minUserRatingCount: _minUserRatingCount,
      minAggregatedRating:
          _minAggregatedRating > 0 ? _minAggregatedRating : null,
      maxAggregatedRating:
          _maxAggregatedRating < 100 ? _maxAggregatedRating : null,
      minAggregatedRatingCount: _minAggregatedRatingCount,
      // Popularity filters
      minHypes: _minHypes,
      releaseDateFrom: _startYear != null ? DateTime(_startYear!) : null,
      releaseDateTo: _endYear != null ? DateTime(_endYear!, 12, 31) : null,
      sortBy: _sortBy,
      sortOrder: _sortOrder,
    );

    HapticFeedback.mediumImpact();
    Navigator.pop(context, newFilters);
  }

  int _getActiveFilterCount() {
    int count = 0;
    if (_selectedGenres.isNotEmpty) count++;
    if (_selectedGameModes.isNotEmpty) count++;
    if (_selectedPlayerPerspectives.isNotEmpty) count++;
    if (_selectedGameStatuses.isNotEmpty) count++;
    if (_selectedGameTypes.isNotEmpty) count++;

    if (_selectedThemes.isNotEmpty) count++;
    if (_selectedCompanies.isNotEmpty) count++;
    if (_selectedGameEngines.isNotEmpty) count++;
    if (_selectedFranchises.isNotEmpty) count++;
    if (_selectedCollections.isNotEmpty) count++;
    if (_selectedPlatforms.isNotEmpty) count++;
    if (_selectedAgeRatings.isNotEmpty) count++;
    if (_selectedKeywords.isNotEmpty) count++;
    if (_selectedLanguages.isNotEmpty) count++;

    // Rating filters
    if (_minTotalRating > 0 ||
        _maxTotalRating < 10 ||
        _minTotalRatingCount != null) count++;
    if (_minUserRating > 0 ||
        _maxUserRating < 10 ||
        _minUserRatingCount != null) count++;
    if (_minAggregatedRating > 0 ||
        _maxAggregatedRating < 100 ||
        _minAggregatedRatingCount != null) count++;

    // Popularity filters
    if (_minHypes != null) count++;
    if (_minFollows != null) count++;

    if (_startYear != null || _endYear != null) count++;
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
