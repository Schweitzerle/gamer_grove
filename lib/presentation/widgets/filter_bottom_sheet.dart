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
import 'dart:ui';
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
  int? _maxTotalRatingCount;

  late double _minUserRating;
  late double _maxUserRating;
  int? _minUserRatingCount;
  int? _maxUserRatingCount;

  late double _minAggregatedRating;
  late double _maxAggregatedRating;
  int? _minAggregatedRatingCount;
  int? _maxAggregatedRatingCount;

  int? _minFollows;
  int? _maxFollows;
  int? _minHypes;
  int? _maxHypes;

  DateTime? _releaseDateFrom;
  DateTime? _releaseDateTo;
  DateTime? _singleReleaseDate;
  String? _dateOperator; // 'before', 'after', 'on'

  late GameSortBy _sortBy;
  late SortOrder _sortOrder;

  // Selected values - Dynamic (storing IDs like the prefetched ones)
  late List<int> _selectedCompanyIds;
  late List<int> _selectedGameEngineIds;
  late List<int> _selectedFranchiseIds;
  late List<int> _selectedCollectionIds;
  late List<int> _selectedThemeIds;
  late List<int> _selectedAgeRatingIds;
  late List<int> _selectedKeywordIds;
  late List<int> _selectedLanguageIds;
  late List<int> _selectedPlatformIds;

  // ID to name mappings for displaying chips
  final Map<int, String> _companyNames = {};
  final Map<int, String> _gameEngineNames = {};
  final Map<int, String> _franchiseNames = {};
  final Map<int, String> _collectionNames = {};
  final Map<int, String> _themeNames = {};
  final Map<int, String> _ageRatingNames = {};
  final Map<int, String> _keywordNames = {};
  final Map<int, String> _languageNames = {};
  final Map<int, String> _platformNames = {};

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
    _maxTotalRatingCount = null;

    _minUserRating = _filters.minUserRating ?? 0.0;
    _maxUserRating = _filters.maxUserRating ?? 10.0;
    _minUserRatingCount = _filters.minUserRatingCount;
    _maxUserRatingCount = null;

    _minAggregatedRating = _filters.minAggregatedRating ?? 0.0;
    _maxAggregatedRating = _filters.maxAggregatedRating ?? 100.0;
    _minAggregatedRatingCount = _filters.minAggregatedRatingCount;
    _maxAggregatedRatingCount = null;

    // Initialize popularity filters
    _minFollows = null;
    _maxFollows = null;
    _minHypes = _filters.minHypes;
    _maxHypes = null;

    // Initialize date filters
    // Detect if this is a single date filter stored as a range
    if (_filters.releaseDateFrom != null && _filters.releaseDateTo != null) {
      final fromDate = _filters.releaseDateFrom!;
      final toDate = _filters.releaseDateTo!;

      // Check if it's an "on" filter (same day with end of day time)
      if (fromDate.year == toDate.year &&
          fromDate.month == toDate.month &&
          fromDate.day == toDate.day &&
          toDate.hour == 23 && toDate.minute == 59) {
        // This is a single date "on" filter
        _singleReleaseDate = fromDate;
        _dateOperator = 'on';
        _releaseDateFrom = null;
        _releaseDateTo = null;
      } else {
        // It's a real date range
        _releaseDateFrom = fromDate;
        _releaseDateTo = toDate;
        _singleReleaseDate = null;
        _dateOperator = null;
      }
    } else if (_filters.releaseDateFrom != null && _filters.releaseDateTo == null) {
      // Only fromDate - this is an "after" filter
      _singleReleaseDate = _filters.releaseDateFrom;
      _dateOperator = 'after';
      _releaseDateFrom = null;
      _releaseDateTo = null;
    } else if (_filters.releaseDateFrom == null && _filters.releaseDateTo != null) {
      // Only toDate - this is a "before" filter
      _singleReleaseDate = _filters.releaseDateTo;
      _dateOperator = 'before';
      _releaseDateFrom = null;
      _releaseDateTo = null;
    } else {
      // No date filter
      _releaseDateFrom = null;
      _releaseDateTo = null;
      _singleReleaseDate = null;
      _dateOperator = null;
    }

    // Initialize dynamic filter IDs
    _selectedPlatformIds = List.from(_filters.platformIds);
    _selectedThemeIds = List.from(_filters.themesIds);
    _selectedCompanyIds = List.from(_filters.companyIds);
    _selectedGameEngineIds = List.from(_filters.gameEngineIds);
    _selectedFranchiseIds = List.from(_filters.franchiseIds);
    _selectedCollectionIds = List.from(_filters.collectionIds);
    _selectedAgeRatingIds = List.from(_filters.ageRatingIds);
    _selectedKeywordIds = List.from(_filters.keywordIds);
    _selectedLanguageIds = List.from(_filters.languageSupportIds);

    // Initialize name mappings from filters
    _platformNames.addAll(_filters.platformNames);
    _themeNames.addAll(_filters.themeNames);
    _companyNames.addAll(_filters.companyNames);
    _gameEngineNames.addAll(_filters.gameEngineNames);
    _franchiseNames.addAll(_filters.franchiseNames);
    _collectionNames.addAll(_filters.collectionNames);
    _ageRatingNames.addAll(_filters.ageRatingNames);
    _keywordNames.addAll(_filters.keywordNames);
    _languageNames.addAll(_filters.languageNames);

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
      child: Stack(
        children: [
          // Main content
          Column(
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
                isScrollable: false,
                tabAlignment: TabAlignment.fill,
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
            ],
          ),

          // Glassmorphism Floating Action Button
          Positioned(
            right: 16,
            bottom: 16,
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
                      onTap: _applyFilters,
                      borderRadius: BorderRadius.circular(28),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: theme.colorScheme.onPrimaryContainer,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Apply Filters',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.bold,
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
          ),
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
          _buildDynamicSearchSection<Platform>(
            title: 'Platforms',
            icon: Icons.devices,
            hint: 'Search platforms...',
            controller: _platformSearchController,
            searchResults: _platformSearchResults,
            selectedIds: _selectedPlatformIds,
            nameMap: _platformNames,
            isLoading: _isSearchingPlatforms,
            onSearch: _searchPlatforms,
            onAdd: (id, name) {
              setState(() {
                _selectedPlatformIds.add(id);
                _platformNames[id] = name;
              });
            },
            onRemove: (id) {
              setState(() {
                _selectedPlatformIds.remove(id);
                _platformNames.remove(id);
              });
            },
            itemBuilder: (item) => Text(item.name),
            getId: (item) => item.id,
            getLabel: (item) => item.name,
            getImageUrl: (item) => item.logoUrl,
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
          _buildTotalRatingExpansionTile(),
          const SizedBox(height: AppConstants.paddingSmall),
          _buildUserRatingExpansionTile(),
          const SizedBox(height: AppConstants.paddingSmall),
          _buildCriticRatingExpansionTile(),
          const SizedBox(height: AppConstants.paddingSmall),
          _buildHypesExpansionTile(),
          const SizedBox(height: AppConstants.paddingSmall),
          _buildFollowsExpansionTile(),
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
          _buildDynamicSearchSection<gg_theme.Theme>(
            title: 'Themes',
            icon: Icons.palette,
            hint: 'Search themes...',
            controller: _themeSearchController,
            searchResults: _themeSearchResults,
            selectedIds: _selectedThemeIds,
            nameMap: _themeNames,
            isLoading: _isSearchingThemes,
            onSearch: _searchThemes,
            onAdd: (id, name) {
              setState(() {
                _selectedThemeIds.add(id);
                _themeNames[id] = name;
              });
            },
            onRemove: (id) {
              setState(() {
                _selectedThemeIds.remove(id);
                _themeNames.remove(id);
              });
            },
            itemBuilder: (item) => Text(item.name),
            getId: (item) => item.id,
            getLabel: (item) => item.name,
          ),
          _buildDynamicSearchSection<Keyword>(
            title: 'Keywords',
            icon: Icons.label,
            hint: 'Search keywords...',
            controller: _keywordSearchController,
            searchResults: _keywordSearchResults,
            selectedIds: _selectedKeywordIds,
            nameMap: _keywordNames,
            isLoading: _isSearchingKeywords,
            onSearch: _searchKeywords,
            onAdd: (id, name) {
              setState(() {
                _selectedKeywordIds.add(id);
                _keywordNames[id] = name;
              });
            },
            onRemove: (id) {
              setState(() {
                _selectedKeywordIds.remove(id);
                _keywordNames.remove(id);
              });
            },
            itemBuilder: (item) => Text(item.name),
            getId: (item) => item.id,
            getLabel: (item) => item.name,
          ),
          _buildDynamicSearchSection<Company>(
            title: 'Companies',
            icon: Icons.business,
            hint: 'Search developers & publishers...',
            controller: _companySearchController,
            searchResults: _companySearchResults,
            selectedIds: _selectedCompanyIds,
            nameMap: _companyNames,
            isLoading: _isSearchingCompanies,
            onSearch: _searchCompanies,
            onAdd: (id, name) {
              setState(() {
                _selectedCompanyIds.add(id);
                _companyNames[id] = name;
              });
            },
            onRemove: (id) {
              setState(() {
                _selectedCompanyIds.remove(id);
                _companyNames.remove(id);
              });
            },
            itemBuilder: (item) => Text(item.name),
            getId: (item) => item.id,
            getLabel: (item) => item.name,
            getImageUrl: (item) => item.logoUrl,
          ),
          _buildDynamicSearchSection<Franchise>(
            title: 'Franchises',
            icon: Icons.auto_stories,
            hint: 'Search franchises...',
            controller: _franchiseSearchController,
            searchResults: _franchiseSearchResults,
            selectedIds: _selectedFranchiseIds,
            nameMap: _franchiseNames,
            isLoading: _isSearchingFranchises,
            onSearch: _searchFranchises,
            onAdd: (id, name) {
              setState(() {
                _selectedFranchiseIds.add(id);
                _franchiseNames[id] = name;
              });
            },
            onRemove: (id) {
              setState(() {
                _selectedFranchiseIds.remove(id);
                _franchiseNames.remove(id);
              });
            },
            itemBuilder: (item) => Text(item.name),
            getId: (item) => item.id,
            getLabel: (item) => item.name,
          ),
          _buildDynamicSearchSection<Collection>(
            title: 'Collections',
            icon: Icons.collections_bookmark,
            hint: 'Search collections...',
            controller: _collectionSearchController,
            searchResults: _collectionSearchResults,
            selectedIds: _selectedCollectionIds,
            nameMap: _collectionNames,
            isLoading: _isSearchingCollections,
            onSearch: _searchCollections,
            onAdd: (id, name) {
              setState(() {
                _selectedCollectionIds.add(id);
                _collectionNames[id] = name;
              });
            },
            onRemove: (id) {
              setState(() {
                _selectedCollectionIds.remove(id);
                _collectionNames.remove(id);
              });
            },
            itemBuilder: (item) => Text(item.name),
            getId: (item) => item.id,
            getLabel: (item) => item.name,
          ),
          _buildDynamicSearchSection<GameEngine>(
            title: 'Game Engines',
            icon: Icons.settings_suggest,
            hint: 'Search game engines...',
            controller: _engineSearchController,
            searchResults: _engineSearchResults,
            selectedIds: _selectedGameEngineIds,
            nameMap: _gameEngineNames,
            isLoading: _isSearchingEngines,
            onSearch: _searchGameEngines,
            onAdd: (id, name) {
              setState(() {
                _selectedGameEngineIds.add(id);
                _gameEngineNames[id] = name;
              });
            },
            onRemove: (id) {
              setState(() {
                _selectedGameEngineIds.remove(id);
                _gameEngineNames.remove(id);
              });
            },
            itemBuilder: (item) => Text(item.name),
            getId: (item) => item.id,
            getLabel: (item) => item.name,
            getImageUrl: (item) => item.logoUrl,
          ),
          _buildDynamicSearchSection<AgeRating>(
            title: 'Age Ratings',
            icon: Icons.verified_user,
            hint: 'Search age ratings...',
            controller: _ageRatingSearchController,
            searchResults: _ageRatingSearchResults,
            selectedIds: _selectedAgeRatingIds,
            nameMap: _ageRatingNames,
            isLoading: _isSearchingAgeRatings,
            onSearch: _searchAgeRatings,
            onAdd: (id, name) {
              setState(() {
                _selectedAgeRatingIds.add(id);
                _ageRatingNames[id] = name;
              });
            },
            onRemove: (id) {
              setState(() {
                _selectedAgeRatingIds.remove(id);
                _ageRatingNames.remove(id);
              });
            },
            itemBuilder: (item) => Text(item.displayName),
            getId: (item) => item.id,
            getLabel: (item) => item.displayName,
          ),
          _buildDynamicSearchSection<Language>(
            title: 'Languages',
            icon: Icons.language,
            hint: 'Search languages...',
            controller: _languagesSearchController,
            searchResults: _languageSearchResults,
            selectedIds: _selectedLanguageIds,
            nameMap: _languageNames,
            isLoading: _isSearchingLanguages,
            onSearch: _searchLanguages,
            onAdd: (id, name) {
              setState(() {
                _selectedLanguageIds.add(id);
                _languageNames[id] = name;
              });
            },
            onRemove: (id) {
              setState(() {
                _selectedLanguageIds.remove(id);
                _languageNames.remove(id);
              });
            },
            itemBuilder: (item) => Text(item.displayName),
            getId: (item) => item.id,
            getLabel: (item) => item.displayName,
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

  Widget _buildLoadingCard({
    required String title,
    required IconData icon,
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
              children: [
                Icon(icon, size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.paddingLarge),
                child: Column(
                  children: [
                    SizedBox(
                      width: 32,
                      height: 32,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingMedium),
                    Text(
                      'Loading $title...',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
  }) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppConstants.paddingMedium,
              AppConstants.paddingMedium,
              AppConstants.paddingMedium,
              0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(icon,
                        size: 20, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    if (selectedIds.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${selectedIds.length}',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (selectedIds.isNotEmpty)
                  TextButton.icon(
                    onPressed: () {
                      setState(() => selectedIds.clear());
                      HapticFeedback.lightImpact();
                    },
                    icon: const Icon(Icons.clear, size: 16),
                    label: const Text('Clear'),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
              ],
            ),
          ),

          // Horizontal scrollable chips (bleeding into edges)
          SizedBox(
            height: 56,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingMedium,
                vertical: 8,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final id = getId(item);
                final isSelected = selectedIds.contains(id);
                return Padding(
                  padding: EdgeInsets.only(
                    right: index < items.length - 1 ? 8 : 0,
                  ),
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
          ),
        ],
      ),
    );
  }

  // ==========================================
  // SECTION BUILDERS
  // ==========================================

  Widget _buildGenresSection() {
    if (widget.availableGenres.isEmpty) {
      return _buildLoadingCard(
        title: 'Genres',
        icon: Icons.bookmarks,
      );
    }
    return _buildChipGridSection(
      title: 'Genres',
      icon: Icons.bookmarks,
      items: widget.availableGenres,
      selectedIds: _selectedGenres,
      getLabel: (genre) => genre.name,
      getId: (genre) => genre.id,
    );
  }

  Widget _buildGameTypeSection() {
    if (widget.availableGameTypes.isEmpty) {
      return _buildLoadingCard(
        title: 'Game Types',
        icon: Icons.category,
      );
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
      return _buildLoadingCard(
        title: 'Game Status',
        icon: Icons.info_outline,
      );
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

  Widget _buildTotalRatingExpansionTile() {
    final theme = Theme.of(context);
    final hasActiveFilters = _minTotalRating > 0 ||
        _maxTotalRating < 10 ||
        _minTotalRatingCount != null ||
        _maxTotalRatingCount != null;

    return Card(
      elevation: 2,
      child: ExpansionTile(
        leading: Icon(Icons.star, color: theme.colorScheme.primary),
        title: Row(
          children: [
            const Text('Total Rating'),
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
            child: _buildRatingSection(),
          ),
        ],
      ),
    );
  }

  Widget _buildUserRatingExpansionTile() {
    final theme = Theme.of(context);
    final hasActiveFilters = _minUserRating > 0 ||
        _maxUserRating < 10 ||
        _minUserRatingCount != null ||
        _maxUserRatingCount != null;

    return Card(
      elevation: 2,
      child: ExpansionTile(
        leading: Icon(Icons.person, color: theme.colorScheme.primary),
        title: Row(
          children: [
            const Text('User Rating (IGDB)'),
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
            child: _buildUserRatingSection(),
          ),
        ],
      ),
    );
  }

  Widget _buildCriticRatingExpansionTile() {
    final theme = Theme.of(context);
    final hasActiveFilters = _minAggregatedRating > 0 ||
        _maxAggregatedRating < 100 ||
        _minAggregatedRatingCount != null ||
        _maxAggregatedRatingCount != null;

    return Card(
      elevation: 2,
      child: ExpansionTile(
        leading: Icon(Icons.rate_review, color: theme.colorScheme.primary),
        title: Row(
          children: [
            const Text('Critic Rating'),
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
            child: _buildAggregatedRatingSection(),
          ),
        ],
      ),
    );
  }

  Widget _buildHypesExpansionTile() {
    final theme = Theme.of(context);
    final hasActiveFilters = _minHypes != null || _maxHypes != null;

    return Card(
      elevation: 2,
      child: ExpansionTile(
        leading: Icon(Icons.whatshot, color: theme.colorScheme.primary),
        title: Row(
          children: [
            const Text('Hypes'),
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
            child: _buildHypesSection(),
          ),
        ],
      ),
    );
  }

  Widget _buildFollowsExpansionTile() {
    final theme = Theme.of(context);
    final hasActiveFilters = _minFollows != null || _maxFollows != null;

    return Card(
      elevation: 2,
      child: ExpansionTile(
        leading: Icon(Icons.people, color: theme.colorScheme.primary),
        title: Row(
          children: [
            const Text('Follows'),
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
            child: _buildFollowsSection(),
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
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Min. Count',
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
                    _minTotalRatingCount =
                        value.isEmpty ? null : int.tryParse(value);
                  });
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Max. Count',
                  hintText: 'e.g., 1000',
                  border: const OutlineInputBorder(),
                  suffixIcon: _maxTotalRatingCount != null
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() => _maxTotalRatingCount = null);
                          },
                        )
                      : null,
                ),
                keyboardType: TextInputType.number,
                controller: TextEditingController(
                  text: _maxTotalRatingCount?.toString() ?? '',
                )..selection = TextSelection.collapsed(
                    offset: _maxTotalRatingCount?.toString().length ?? 0,
                  ),
                onChanged: (value) {
                  setState(() {
                    _maxTotalRatingCount =
                        value.isEmpty ? null : int.tryParse(value);
                  });
                },
              ),
            ),
          ],
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
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Min. Count',
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
                    _minUserRatingCount =
                        value.isEmpty ? null : int.tryParse(value);
                  });
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Max. Count',
                  hintText: 'e.g., 500',
                  border: const OutlineInputBorder(),
                  suffixIcon: _maxUserRatingCount != null
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() => _maxUserRatingCount = null);
                          },
                        )
                      : null,
                ),
                keyboardType: TextInputType.number,
                controller: TextEditingController(
                  text: _maxUserRatingCount?.toString() ?? '',
                )..selection = TextSelection.collapsed(
                    offset: _maxUserRatingCount?.toString().length ?? 0,
                  ),
                onChanged: (value) {
                  setState(() {
                    _maxUserRatingCount =
                        value.isEmpty ? null : int.tryParse(value);
                  });
                },
              ),
            ),
          ],
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
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Min. Count',
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
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Max. Count',
                  hintText: 'e.g., 100',
                  border: const OutlineInputBorder(),
                  suffixIcon: _maxAggregatedRatingCount != null
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() => _maxAggregatedRatingCount = null);
                          },
                        )
                      : null,
                ),
                keyboardType: TextInputType.number,
                controller: TextEditingController(
                  text: _maxAggregatedRatingCount?.toString() ?? '',
                )..selection = TextSelection.collapsed(
                    offset: _maxAggregatedRatingCount?.toString().length ?? 0,
                  ),
                onChanged: (value) {
                  setState(() {
                    _maxAggregatedRatingCount =
                        value.isEmpty ? null : int.tryParse(value);
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHypesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'For unreleased or upcoming games',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: AppConstants.paddingMedium),
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Min. Hypes',
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
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Max. Hypes',
                  hintText: 'e.g., 10000',
                  border: const OutlineInputBorder(),
                  suffixIcon: _maxHypes != null
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() => _maxHypes = null);
                          },
                        )
                      : null,
                ),
                keyboardType: TextInputType.number,
                controller: TextEditingController(
                  text: _maxHypes?.toString() ?? '',
                )..selection = TextSelection.collapsed(
                    offset: _maxHypes?.toString().length ?? 0,
                  ),
                onChanged: (value) {
                  setState(() {
                    _maxHypes = value.isEmpty ? null : int.tryParse(value);
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFollowsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Users following this game',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: AppConstants.paddingMedium),
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Min. Follows',
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
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Max. Follows',
                  hintText: 'e.g., 50000',
                  border: const OutlineInputBorder(),
                  suffixIcon: _maxFollows != null
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() => _maxFollows = null);
                          },
                        )
                      : null,
                ),
                keyboardType: TextInputType.number,
                controller: TextEditingController(
                  text: _maxFollows?.toString() ?? '',
                )..selection = TextSelection.collapsed(
                    offset: _maxFollows?.toString().length ?? 0,
                  ),
                onChanged: (value) {
                  setState(() {
                    _maxFollows = value.isEmpty ? null : int.tryParse(value);
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildReleaseYearSection() {
    final theme = Theme.of(context);
    final hasDateFilter = _releaseDateFrom != null ||
        _releaseDateTo != null ||
        _singleReleaseDate != null;

    String getDateFilterText() {
      if (_singleReleaseDate != null && _dateOperator != null) {
        final dateStr = _formatDate(_singleReleaseDate!);
        switch (_dateOperator) {
          case 'before':
            return 'Before $dateStr';
          case 'after':
            return 'After $dateStr';
          case 'on':
            return 'On $dateStr';
          default:
            return dateStr;
        }
      } else if (_releaseDateFrom != null && _releaseDateTo != null) {
        return '${_formatDate(_releaseDateFrom!)} - ${_formatDate(_releaseDateTo!)}';
      } else if (_releaseDateFrom != null) {
        return 'From ${_formatDate(_releaseDateFrom!)}';
      } else if (_releaseDateTo != null) {
        return 'Until ${_formatDate(_releaseDateTo!)}';
      }
      return 'Tap to select date';
    }

    return _buildFilterCard(
      title: 'Release Date',
      icon: Icons.calendar_today,
      activeCount: hasDateFilter ? 1 : null,
      onClear: hasDateFilter
          ? () {
              setState(() {
                _releaseDateFrom = null;
                _releaseDateTo = null;
                _singleReleaseDate = null;
                _dateOperator = null;
              });
              HapticFeedback.lightImpact();
            }
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => _showDateFilterDialog(),
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
                      getDateFilterText(),
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
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (_singleReleaseDate != null && _dateOperator != null)
                  _buildDateChip(
                    label:
                        '${_getOperatorSymbol(_dateOperator!)} ${_formatDate(_singleReleaseDate!)}',
                    onRemove: () {
                      setState(() {
                        _singleReleaseDate = null;
                        _dateOperator = null;
                      });
                      HapticFeedback.lightImpact();
                    },
                  ),
                if (_releaseDateFrom != null && _singleReleaseDate == null)
                  _buildDateChip(
                    label: 'From: ${_formatDate(_releaseDateFrom!)}',
                    onRemove: () {
                      setState(() => _releaseDateFrom = null);
                      HapticFeedback.lightImpact();
                    },
                  ),
                if (_releaseDateTo != null && _singleReleaseDate == null)
                  _buildDateChip(
                    label: 'To: ${_formatDate(_releaseDateTo!)}',
                    onRemove: () {
                      setState(() => _releaseDateTo = null);
                      HapticFeedback.lightImpact();
                    },
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year}';
  }

  String _getOperatorSymbol(String operator) {
    switch (operator) {
      case 'before':
        return '<';
      case 'after':
        return '>';
      case 'on':
        return '=';
      default:
        return '';
    }
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

  Future<void> _showDateFilterDialog() async {
    await showDialog<void>(
      context: context,
      builder: (context) => DateFilterDialog(
        initialDateFrom: _releaseDateFrom,
        initialDateTo: _releaseDateTo,
        initialSingleDate: _singleReleaseDate,
        initialOperator: _dateOperator,
        onApply: (dateFrom, dateTo, singleDate, operator) {
          setState(() {
            if (singleDate != null && operator != null) {
              // Single date mode
              _singleReleaseDate = singleDate;
              _dateOperator = operator;
              _releaseDateFrom = null;
              _releaseDateTo = null;
            } else {
              // Range mode
              _releaseDateFrom = dateFrom;
              _releaseDateTo = dateTo;
              _singleReleaseDate = null;
              _dateOperator = null;
            }
          });
          HapticFeedback.lightImpact();
        },
      ),
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
    required List<int> selectedIds,
    required Map<int, String> nameMap,
    required bool isLoading,
    required void Function(String) onSearch,
    required void Function(int id, String name) onAdd,
    required void Function(int) onRemove,
    required Widget Function(T) itemBuilder,
    required int Function(T) getId,
    required String Function(T) getLabel,
    String? Function(T)? getImageUrl, // Optional image URL getter
  }) {
    final theme = Theme.of(context);

    return _buildFilterCard(
      title: title,
      icon: icon,
      activeCount: selectedIds.length,
      onClear: selectedIds.isEmpty
          ? null
          : () {
              setState(() {
                selectedIds.clear();
                nameMap.clear();
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
                    final itemId = getId(item);
                    final isSelected = selectedIds.contains(itemId);

                    // Get image URL if available
                    final imageUrl = getImageUrl?.call(item);

                    // Build placeholder widget for consistency
                    Widget buildPlaceholder() {
                      return Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color:
                              theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Icon(
                          icon,
                          size: 20,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      );
                    }

                    // If getImageUrl is provided, always show a leading widget
                    // (either image or placeholder)
                    Widget? leadingWidget;
                    if (getImageUrl != null) {
                      if (imageUrl != null && imageUrl.isNotEmpty) {
                        // Show image with placeholder fallback
                        leadingWidget = ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.network(
                            imageUrl,
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return buildPlaceholder();
                            },
                          ),
                        );
                      } else {
                        // Show placeholder for items without image
                        leadingWidget = buildPlaceholder();
                      }
                    }

                    return ListTile(
                      leading: leadingWidget,
                      title: itemBuilder(item),
                      trailing: isSelected
                          ? Icon(Icons.check_circle,
                              color: theme.colorScheme.primary)
                          : Icon(Icons.add_circle_outline,
                              color: theme.colorScheme.primary),
                      onTap: () {
                        if (isSelected) {
                          onRemove(itemId);
                        } else {
                          onAdd(itemId, getLabel(item));
                        }
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],

          // Selected Items as Chips
          if (selectedIds.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: selectedIds.map((id) {
                // Try to get name from map first, then from search results
                String name;
                if (nameMap.containsKey(id)) {
                  name = nameMap[id]!;
                } else {
                  final item = searchResults.cast<T?>().firstWhere(
                        (item) => item != null && getId(item) == id,
                        orElse: () => null,
                      );
                  name = item != null ? getLabel(item) : 'ID: $id';
                }

                return Chip(
                  label: Text(name),
                  onDeleted: () => onRemove(id),
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

      _selectedThemeIds.clear();
      _selectedCompanyIds.clear();
      _selectedGameEngineIds.clear();
      _selectedFranchiseIds.clear();
      _selectedCollectionIds.clear();
      _selectedAgeRatingIds.clear();
      _selectedKeywordIds.clear();
      _selectedLanguageIds.clear();
      _selectedPlatformIds.clear();

      // Clear name mappings
      _platformNames.clear();
      _themeNames.clear();
      _companyNames.clear();
      _gameEngineNames.clear();
      _franchiseNames.clear();
      _collectionNames.clear();
      _ageRatingNames.clear();
      _keywordNames.clear();
      _languageNames.clear();

      // Clear rating filters
      _minTotalRating = 0.0;
      _maxTotalRating = 10.0;
      _minTotalRatingCount = null;
      _maxTotalRatingCount = null;

      _minUserRating = 0.0;
      _maxUserRating = 10.0;
      _minUserRatingCount = null;
      _maxUserRatingCount = null;

      _minAggregatedRating = 0.0;
      _maxAggregatedRating = 100.0;
      _minAggregatedRatingCount = null;
      _maxAggregatedRatingCount = null;

      // Clear popularity filters
      _minFollows = null;
      _maxFollows = null;
      _minHypes = null;
      _maxHypes = null;

      // Clear date filters
      _releaseDateFrom = null;
      _releaseDateTo = null;
      _singleReleaseDate = null;
      _dateOperator = null;

      _sortBy = GameSortBy.relevance;
      _sortOrder = SortOrder.descending;
    });
    HapticFeedback.mediumImpact();
  }

  void _applyFilters() {
    final newFilters = _filters.copyWith(
      genreIds: _selectedGenres,
      gameModesIds: _selectedGameModes,
      playerPerspectiveIds: _selectedPlayerPerspectives,
      gameStatusIds: _selectedGameStatuses,
      gameTypeIds: _selectedGameTypes,
      companyIds: _selectedCompanyIds,
      gameEngineIds: _selectedGameEngineIds,
      franchiseIds: _selectedFranchiseIds,
      collectionIds: _selectedCollectionIds,
      themesIds: _selectedThemeIds,
      platformIds: _selectedPlatformIds,
      ageRatingIds: _selectedAgeRatingIds,
      keywordIds: _selectedKeywordIds,
      languageIds: _selectedLanguageIds,
      // Name mappings
      platformNames: _platformNames.isEmpty ? {} : Map.from(_platformNames),
      companyNames: _companyNames.isEmpty ? {} : Map.from(_companyNames),
      gameEngineNames:
          _gameEngineNames.isEmpty ? {} : Map.from(_gameEngineNames),
      franchiseNames: _franchiseNames.isEmpty ? {} : Map.from(_franchiseNames),
      collectionNames:
          _collectionNames.isEmpty ? {} : Map.from(_collectionNames),
      themeNames: _themeNames.isEmpty ? {} : Map.from(_themeNames),
      ageRatingNames: _ageRatingNames.isEmpty ? {} : Map.from(_ageRatingNames),
      keywordNames: _keywordNames.isEmpty ? {} : Map.from(_keywordNames),
      languageNames: _languageNames.isEmpty ? {} : Map.from(_languageNames),
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
      // Date filters - handle both single date and range
      releaseDateFrom: _singleReleaseDate != null && _dateOperator == 'after'
          ? _singleReleaseDate
          : _singleReleaseDate != null && _dateOperator == 'on'
              ? _singleReleaseDate
              : _releaseDateFrom,
      releaseDateTo: _singleReleaseDate != null && _dateOperator == 'before'
          ? _singleReleaseDate
          : _singleReleaseDate != null && _dateOperator == 'on'
              ? DateTime(_singleReleaseDate!.year, _singleReleaseDate!.month,
                  _singleReleaseDate!.day, 23, 59, 59)
              : _releaseDateTo,
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

    if (_selectedThemeIds.isNotEmpty) count++;
    if (_selectedCompanyIds.isNotEmpty) count++;
    if (_selectedGameEngineIds.isNotEmpty) count++;
    if (_selectedFranchiseIds.isNotEmpty) count++;
    if (_selectedCollectionIds.isNotEmpty) count++;
    if (_selectedPlatformIds.isNotEmpty) count++;
    if (_selectedAgeRatingIds.isNotEmpty) count++;
    if (_selectedKeywordIds.isNotEmpty) count++;
    if (_selectedLanguageIds.isNotEmpty) count++;

    // Rating filters
    if (_minTotalRating > 0 ||
        _maxTotalRating < 10 ||
        _minTotalRatingCount != null ||
        _maxTotalRatingCount != null) count++;
    if (_minUserRating > 0 ||
        _maxUserRating < 10 ||
        _minUserRatingCount != null ||
        _maxUserRatingCount != null) count++;
    if (_minAggregatedRating > 0 ||
        _maxAggregatedRating < 100 ||
        _minAggregatedRatingCount != null ||
        _maxAggregatedRatingCount != null) count++;

    // Popularity filters
    if (_minHypes != null || _maxHypes != null) count++;
    if (_minFollows != null || _maxFollows != null) count++;

    // Date filters
    if (_releaseDateFrom != null ||
        _releaseDateTo != null ||
        _singleReleaseDate != null) count++;
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
    }
  }
}

// ==========================================
// DATE FILTER DIALOG
// ==========================================

class DateFilterDialog extends StatefulWidget {
  final DateTime? initialDateFrom;
  final DateTime? initialDateTo;
  final DateTime? initialSingleDate;
  final String? initialOperator;
  final void Function(DateTime?, DateTime?, DateTime?, String?) onApply;

  const DateFilterDialog({
    super.key,
    this.initialDateFrom,
    this.initialDateTo,
    this.initialSingleDate,
    this.initialOperator,
    required this.onApply,
  });

  @override
  State<DateFilterDialog> createState() => _DateFilterDialogState();
}

class _DateFilterDialogState extends State<DateFilterDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime? _dateFrom;
  DateTime? _dateTo;
  DateTime? _singleDate;
  String _operator = 'after'; // 'before', 'after', 'on'

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialSingleDate != null ? 1 : 0,
    );
    _dateFrom = widget.initialDateFrom;
    _dateTo = widget.initialDateTo;
    _singleDate = widget.initialSingleDate;
    _operator = widget.initialOperator ?? 'after';
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, color: theme.colorScheme.primary),
                  const SizedBox(width: 12),
                  Text(
                    'Release Date Filter',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Tabs
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Date Range', icon: Icon(Icons.date_range, size: 20)),
                Tab(text: 'Single Date', icon: Icon(Icons.event, size: 20)),
              ],
            ),

            // Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildRangeTab(),
                  _buildSingleDateTab(),
                ],
              ),
            ),

            // Buttons
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  TextButton(
                    onPressed: () {
                      widget.onApply(null, null, null, null);
                      Navigator.pop(context);
                    },
                    child: const Text('Clear'),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () {
                      if (_tabController.index == 0) {
                        // Range mode
                        widget.onApply(_dateFrom, _dateTo, null, null);
                      } else {
                        // Single date mode
                        widget.onApply(null, null, _singleDate, _operator);
                      }
                      Navigator.pop(context);
                    },
                    child: const Text('Apply'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRangeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select a date range',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          _buildDateButton(
            label: 'From Date',
            date: _dateFrom,
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _dateFrom ?? DateTime.now(),
                firstDate: DateTime(1970),
                lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
              );
              if (picked != null) {
                setState(() => _dateFrom = picked);
              }
            },
            onClear: () => setState(() => _dateFrom = null),
          ),
          const SizedBox(height: 12),
          _buildDateButton(
            label: 'To Date',
            date: _dateTo,
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _dateTo ?? DateTime.now(),
                firstDate: DateTime(1970),
                lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
              );
              if (picked != null) {
                setState(() => _dateTo = picked);
              }
            },
            onClear: () => setState(() => _dateTo = null),
          ),
        ],
      ),
    );
  }

  Widget _buildSingleDateTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select a date and operator',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          _buildDateButton(
            label: 'Date',
            date: _singleDate,
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _singleDate ?? DateTime.now(),
                firstDate: DateTime(1970),
                lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
              );
              if (picked != null) {
                setState(() => _singleDate = picked);
              }
            },
            onClear: () => setState(() => _singleDate = null),
          ),
          const SizedBox(height: 16),
          Text(
            'Operator',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(
                value: 'before',
                label: Text('Before'),
                icon: Icon(Icons.arrow_back, size: 16),
              ),
              ButtonSegment(
                value: 'on',
                label: Text('On'),
                icon: Icon(Icons.circle, size: 16),
              ),
              ButtonSegment(
                value: 'after',
                label: Text('After'),
                icon: Icon(Icons.arrow_forward, size: 16),
              ),
            ],
            selected: {_operator},
            onSelectionChanged: (Set<String> newSelection) {
              setState(() => _operator = newSelection.first);
            },
          ),
          if (_singleDate != null) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 20,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _getOperatorDescription(),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDateButton({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
    required VoidCallback onClear,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: theme.colorScheme.outline),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  date != null
                      ? '${date.day}.${date.month}.${date.year}'
                      : 'Select date',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: date != null
                        ? theme.colorScheme.onSurface
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Row(
                  children: [
                    if (date != null)
                      IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: onClear,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    const SizedBox(width: 8),
                    Icon(Icons.calendar_today,
                        color: theme.colorScheme.primary),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _getOperatorDescription() {
    if (_singleDate == null) return '';
    final dateStr =
        '${_singleDate!.day}.${_singleDate!.month}.${_singleDate!.year}';
    switch (_operator) {
      case 'before':
        return 'Shows games released before $dateStr';
      case 'after':
        return 'Shows games released after $dateStr';
      case 'on':
        return 'Shows games released on $dateStr';
      default:
        return '';
    }
  }
}

