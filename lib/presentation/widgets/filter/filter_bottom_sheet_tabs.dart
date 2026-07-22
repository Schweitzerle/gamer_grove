// setState is legitimately used here: these are State methods split into
// same-library extensions. The analyzer cannot see through the extension.
// ignore_for_file: invalid_use_of_protected_member
part of '../filter_bottom_sheet.dart';

extension _FilterBottomSheetTabs on _FilterBottomSheetState {
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
    return ProGate(
      feature: ProFeature.advancedFilters,
      lockedBuilder: (context) => const ProLockedView(
        title: 'Advanced filters',
        description: 'Filter by themes, keywords, companies, franchises, '
            'engines, age ratings & languages with GamerGrove Pro.',
        source: 'filters_meta',
        icon: Icons.tune,
      ),
      builder: (context) => _buildMetaTabContent(),
    );
  }

  Widget _buildMetaTabContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDynamicSearchSection<gg_theme.IGDBTheme>(
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
          _buildDynamicSearchSection<AgeRatingCategory>(
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
            itemBuilder: (item) =>
                Text('${item.rating} (${item.organization?.name})'),
            getId: (item) => item.id,
            getLabel: (item) => item.rating,
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
}
