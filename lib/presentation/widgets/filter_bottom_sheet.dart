// ==========================================
// 2. VOLLSTÄNDIGES FILTER BOTTOM SHEET
// ==========================================

import 'dart:async';
import 'dart:ui';

// lib/presentation/widgets/filter_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gamer_grove/core/constants/app_constants.dart';
import 'package:gamer_grove/core/entitlements/pro_feature.dart';
import 'package:gamer_grove/presentation/widgets/pro/pro_gate.dart';
import 'package:gamer_grove/presentation/widgets/pro/pro_locked_view.dart';
import 'package:gamer_grove/domain/entities/ageRating/age_rating_category.dart';
import 'package:gamer_grove/domain/entities/collection/collection.dart';
import 'package:gamer_grove/domain/entities/company/company.dart';
import 'package:gamer_grove/domain/entities/franchise.dart';
import 'package:gamer_grove/domain/entities/game/game_engine.dart';
import 'package:gamer_grove/domain/entities/game/game_mode.dart';
import 'package:gamer_grove/domain/entities/game/game_sort_options.dart';
import 'package:gamer_grove/domain/entities/game/game_status.dart';
import 'package:gamer_grove/domain/entities/game/game_type.dart';
import 'package:gamer_grove/domain/entities/genre.dart';
import 'package:gamer_grove/domain/entities/keyword.dart';
import 'package:gamer_grove/domain/entities/language/language.dart';
import 'package:gamer_grove/domain/entities/platform/platform.dart';
import 'package:gamer_grove/domain/entities/player_perspective.dart';
import 'package:gamer_grove/domain/entities/search/search_filters.dart';
import 'package:gamer_grove/domain/entities/theme.dart' as gg_theme;
import 'package:gamer_grove/presentation/widgets/filter/date_filter_dialog.dart';

part 'filter/filter_bottom_sheet_tabs.dart';
part 'filter/filter_bottom_sheet_sections.dart';
part 'filter/filter_bottom_sheet_ratings.dart';
part 'filter/filter_bottom_sheet_release_sort.dart';
part 'filter/filter_bottom_sheet_search.dart';
part 'filter/filter_bottom_sheet_actions.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({
    required this.currentFilters,
    required this.availableGenres,
    required this.availableGameTypes,
    required this.availableGameStatuses,
    required this.availableGameModes,
    required this.availablePlayerPerspectives,
    super.key,
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
  final Future<List<gg_theme.IGDBTheme>> Function(String query)? onSearchThemes;
  final Future<List<AgeRatingCategory>> Function(String query)?
      onSearchAgeRatings;

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
    Future<List<gg_theme.IGDBTheme>> Function(String query)? onSearchThemes,
    Future<List<AgeRatingCategory>> Function(String query)? onSearchAgeRatings,
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
  List<gg_theme.IGDBTheme> _themeSearchResults = [];
  List<AgeRatingCategory> _ageRatingSearchResults = [];
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
          toDate.hour == 23 &&
          toDate.minute == 59) {
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
    } else if (_filters.releaseDateFrom != null &&
        _filters.releaseDateTo == null) {
      // Only fromDate - this is an "after" filter
      _singleReleaseDate = _filters.releaseDateFrom;
      _dateOperator = 'after';
      _releaseDateFrom = null;
      _releaseDateTo = null;
    } else if (_filters.releaseDateFrom == null &&
        _filters.releaseDateTo != null) {
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
    _selectedAgeRatingIds = List.from(_filters.ageRatingCategoryIds);
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

  // ==========================================
  // FILTER COUNT HELPERS
  // ==========================================

  int _getGameTabFilterCount() {
    var count = 0;

    // Genres
    if (_selectedGenres.isNotEmpty) count++;
    // Platforms
    if (_selectedPlatformIds.isNotEmpty) count++;
    // Game Modes
    if (_selectedGameModes.isNotEmpty) count++;
    // Game Types
    if (_selectedGameTypes.isNotEmpty) count++;
    // Game Status
    if (_selectedGameStatuses.isNotEmpty) count++;
    // Player Perspectives
    if (_selectedPlayerPerspectives.isNotEmpty) count++;
    // Release Year
    if (_releaseDateFrom != null ||
        _releaseDateTo != null ||
        _singleReleaseDate != null) count++;

    return count;
  }

  int _getQualityTabFilterCount() {
    var count = 0;

    // Total Rating
    if (_minTotalRating > 0.0 ||
        _maxTotalRating < 10.0 ||
        _minTotalRatingCount != null) count++;
    // User Rating
    if (_minUserRating > 0.0 ||
        _maxUserRating < 10.0 ||
        _minUserRatingCount != null) count++;
    // Aggregated Rating (Critic)
    if (_minAggregatedRating > 0.0 ||
        _maxAggregatedRating < 100.0 ||
        _minAggregatedRatingCount != null) count++;
    // Hypes
    if (_minHypes != null || _maxHypes != null) count++;
    // Follows
    if (_minFollows != null || _maxFollows != null) count++;

    return count;
  }

  int _getMetaTabFilterCount() {
    var count = 0;

    // Themes
    if (_selectedThemeIds.isNotEmpty) count++;
    // Keywords
    if (_selectedKeywordIds.isNotEmpty) count++;
    // Companies
    if (_selectedCompanyIds.isNotEmpty) count++;
    // Franchises
    if (_selectedFranchiseIds.isNotEmpty) count++;
    // Collections
    if (_selectedCollectionIds.isNotEmpty) count++;
    // Game Engines
    if (_selectedGameEngineIds.isNotEmpty) count++;
    // Age Ratings
    if (_selectedAgeRatingIds.isNotEmpty) count++;
    // Languages
    if (_selectedLanguageIds.isNotEmpty) count++;

    return count;
  }

  Widget _buildTabWithBadge({
    required String text,
    required IconData icon,
    required int count,
  }) {
    return Tab(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20),
              const SizedBox(height: 4),
              Text(text),
            ],
          ),
          if (count > 0)
            Positioned(
              right: -8,
              top: -4,
              child: Container(
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(
                  minWidth: 18,
                  minHeight: 18,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    count.toString(),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
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
                tabAlignment: TabAlignment.fill,
                tabs: [
                  _buildTabWithBadge(
                    text: 'Game',
                    icon: Icons.videogame_asset,
                    count: _getGameTabFilterCount(),
                  ),
                  _buildTabWithBadge(
                    text: 'Quality',
                    icon: Icons.stars,
                    count: _getQualityTabFilterCount(),
                  ),
                  _buildTabWithBadge(
                    text: 'Meta',
                    icon: Icons.more_horiz,
                    count: _getMetaTabFilterCount(),
                  ),
                  const Tab(text: 'Sort', icon: Icon(Icons.sort, size: 20)),
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
}
