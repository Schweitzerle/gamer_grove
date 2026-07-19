// setState is legitimately used here: these are State methods split into
// same-library extensions. The analyzer cannot see through the extension.
// ignore_for_file: invalid_use_of_protected_member
part of '../filter_bottom_sheet.dart';

extension _FilterBottomSheetActions on _FilterBottomSheetState {
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
              ? DateTime(
                  _singleReleaseDate!.year,
                  _singleReleaseDate!.month,
                  _singleReleaseDate!.day,
                  23,
                  59,
                  59,
                )
              : _releaseDateTo,
      sortBy: _sortBy,
      sortOrder: _sortOrder,
    );

    HapticFeedback.mediumImpact();
    Navigator.pop(context, newFilters);
  }

  int _getActiveFilterCount() {
    var count = 0;
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
        _maxTotalRatingCount != null) {
      count++;
    }
    if (_minUserRating > 0 ||
        _maxUserRating < 10 ||
        _minUserRatingCount != null ||
        _maxUserRatingCount != null) {
      count++;
    }
    if (_minAggregatedRating > 0 ||
        _maxAggregatedRating < 100 ||
        _minAggregatedRatingCount != null ||
        _maxAggregatedRatingCount != null) {
      count++;
    }

    // Popularity filters
    if (_minHypes != null || _maxHypes != null) count++;
    if (_minFollows != null || _maxFollows != null) count++;

    // Date filters
    if (_releaseDateFrom != null ||
        _releaseDateTo != null ||
        _singleReleaseDate != null) {
      count++;
    }
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
