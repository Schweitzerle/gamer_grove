// ==================================================
// ALL CHARACTERS SCREEN WITH FILTERING & SORTING
// ==================================================

// lib/presentation/pages/character/widgets/all_characters_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamer_grove/core/constants/app_constants.dart';
import 'package:gamer_grove/domain/entities/character/character.dart';
import 'package:gamer_grove/domain/entities/character/character_gender.dart';
import 'package:gamer_grove/domain/entities/character/character_species.dart';
import 'package:gamer_grove/domain/entities/search/character_search_filters.dart';
import 'package:gamer_grove/presentation/blocs/character/character_bloc.dart';
import 'package:gamer_grove/presentation/blocs/character/character_event.dart';
import 'package:gamer_grove/presentation/blocs/character/character_state.dart';
import 'package:gamer_grove/presentation/pages/character/widgets/character_card.dart';

enum CharacterSortOption {
  defaultSort, // No sorting, IGDB default order
  nameAZ,
  nameZA,
  gamesCount,
}

class AllCharactersScreen extends StatefulWidget {

  const AllCharactersScreen({
    super.key,
    this.title = 'All Characters',
    this.subtitle,
    this.initialCharacters,
    this.showFilters = true,
    this.showSearch = true,
  });
  final String title;
  final String? subtitle;
  final List<Character>? initialCharacters;
  final bool showFilters;
  final bool showSearch;

  @override
  State<AllCharactersScreen> createState() => _AllCharactersScreenState();
}

class _AllCharactersScreenState extends State<AllCharactersScreen> {
  CharacterSortOption _currentSort = CharacterSortOption.defaultSort;
  CharacterGenderEnum? _genderFilter;
  CharacterSpeciesEnum? _speciesFilter;
  String _searchQuery = '';
  bool _filtersExpanded = false;
  bool _hasImageFilter = true;

  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    // If no initial characters, load from API
    if (widget.initialCharacters == null) {
      _performSearch();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<CharacterBloc>().add(LoadMoreCharactersEvent());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  void _performSearch() {
    final filters = CharacterSearchFilters(
      gender: _genderFilter,
      species: _speciesFilter,
      hasMugShot: _hasImageFilter ? true : null,
      sortBy: _getSortBy(),
      sortOrder: _getSortOrder(),
    );

    context.read<CharacterBloc>().add(
          SearchCharactersWithFiltersEvent(
            query: _searchQuery,
            filters: filters,
          ),
        );
  }

  CharacterSortBy _getSortBy() {
    switch (_currentSort) {
      case CharacterSortOption.defaultSort:
        return CharacterSortBy.relevance;
      case CharacterSortOption.nameAZ:
      case CharacterSortOption.nameZA:
        return CharacterSortBy.name;
      case CharacterSortOption.gamesCount:
        return CharacterSortBy.gamesCount;
    }
  }

  CharacterSortOrder _getSortOrder() {
    switch (_currentSort) {
      case CharacterSortOption.defaultSort:
      case CharacterSortOption.nameAZ:
        return CharacterSortOrder.ascending;
      case CharacterSortOption.nameZA:
      case CharacterSortOption.gamesCount:
        return CharacterSortOrder.descending;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Search & Filters
          if (widget.showSearch || widget.showFilters) _buildSearchAndFilters(),

          // Characters Count & Sort
          _buildCharactersHeader(),

          // Characters List/Grid
          Expanded(
            child: widget.initialCharacters != null
                ? _buildStaticCharactersList(widget.initialCharacters!)
                : _buildBlocCharactersList(),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: const TextStyle(fontWeight: FontWeight.bold),
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
        IconButton(
          icon: const Icon(Icons.sort),
          onPressed: _showSortBottomSheet,
        ),
      ],
    );
  }

  Widget _buildSearchAndFilters() {
    final hasActiveFilters =
        _genderFilter != null || _speciesFilter != null || !_hasImageFilter;

    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: Column(
        children: [
          // Search Bar with Filter Toggle
          if (widget.showSearch)
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search characters...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                });
                                _performSearch();
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor:
                          Theme.of(context).colorScheme.surfaceContainerLowest,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    onSubmitted: (_) => _performSearch(),
                  ),
                ),
                if (widget.showFilters) ...[
                  const SizedBox(width: 8),
                  Badge(
                    isLabelVisible: hasActiveFilters,
                    child: IconButton(
                      icon: Icon(
                        _filtersExpanded
                            ? Icons.filter_list_off
                            : Icons.filter_list,
                        color: hasActiveFilters
                            ? Theme.of(context).colorScheme.primary
                            : null,
                      ),
                      onPressed: () {
                        setState(() {
                          _filtersExpanded = !_filtersExpanded;
                        });
                        HapticFeedback.lightImpact();
                      },
                    ),
                  ),
                ],
              ],
            ),

          // Collapsable Filter Chips
          if (widget.showFilters)
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: const EdgeInsets.only(top: AppConstants.paddingSmall),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Has Image Toggle & Clear Filters Row
                    Row(
                      children: [
                        // Has Image Toggle
                        Expanded(
                          child: SwitchListTile(
                            title: Text(
                              'With Image Only',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            value: _hasImageFilter,
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            onChanged: (value) {
                              setState(() => _hasImageFilter = value);
                              _performSearch();
                              HapticFeedback.lightImpact();
                            },
                          ),
                        ),
                        // Clear Filters Button
                        if (hasActiveFilters)
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                _genderFilter = null;
                                _speciesFilter = null;
                                _hasImageFilter = true;
                                _currentSort = CharacterSortOption.defaultSort;
                              });
                              _performSearch();
                              HapticFeedback.lightImpact();
                            },
                            icon: const Icon(Icons.clear_all, size: 18),
                            label: const Text('Clear'),
                            style: TextButton.styleFrom(
                              foregroundColor:
                                  Theme.of(context).colorScheme.error,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Gender Filter
                    Text(
                      'Gender',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 4),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip(
                            label: 'All',
                            isSelected: _genderFilter == null,
                            onSelected: () {
                              setState(() => _genderFilter = null);
                              _performSearch();
                            },
                          ),
                          ...CharacterGenderEnum.values
                              .where((g) => g != CharacterGenderEnum.unknown)
                              .map((gender) => _buildFilterChip(
                                    label: gender.displayName,
                                    isSelected: _genderFilter == gender,
                                    onSelected: () {
                                      setState(() => _genderFilter = gender);
                                      _performSearch();
                                    },
                                  ),),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Species Filter
                    Text(
                      'Species',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 4),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip(
                            label: 'All',
                            isSelected: _speciesFilter == null,
                            onSelected: () {
                              setState(() => _speciesFilter = null);
                              _performSearch();
                            },
                          ),
                          ...CharacterSpeciesEnum.values
                              .where((s) => s != CharacterSpeciesEnum.unknown)
                              .map((species) => _buildFilterChip(
                                    label: species.displayName,
                                    isSelected: _speciesFilter == species,
                                    onSelected: () {
                                      setState(() => _speciesFilter = species);
                                      _performSearch();
                                    },
                                  ),),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              crossFadeState: _filtersExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 200),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onSelected,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) {
          onSelected();
          HapticFeedback.lightImpact();
        },
      ),
    );
  }

  Widget _buildCharactersHeader() {
    return BlocBuilder<CharacterBloc, CharacterState>(
      builder: (context, state) {
        var count = 0;
        if (widget.initialCharacters != null) {
          count = widget.initialCharacters!.length;
        } else if (state is CharacterSearchLoaded) {
          count = state.characters.length;
        } else if (state is PopularCharactersLoaded) {
          count = state.characters.length;
        }

        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingMedium,
            vertical: AppConstants.paddingSmall,
          ),
          child: Row(
            children: [
              Icon(
                Icons.person,
                size: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                '$count characters',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const Spacer(),
              Text(
                _getSortLabel(_currentSort),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBlocCharactersList() {
    return BlocBuilder<CharacterBloc, CharacterState>(
      builder: (context, state) {
        if (state is CharacterLoading || state is CharacterSearchLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is CharacterError) {
          return _buildErrorState(state.message);
        }

        var characters = <Character>[];
        var isLoadingMore = false;

        if (state is CharacterSearchLoaded) {
          characters = state.characters;
          isLoadingMore = state.isLoadingMore;
        } else if (state is PopularCharactersLoaded) {
          characters = state.characters;
        }

        if (characters.isEmpty) {
          return _buildEmptyState();
        }

        return _buildCharactersContent(characters, isLoadingMore);
      },
    );
  }

  Widget _buildStaticCharactersList(List<Character> characters) {
    if (characters.isEmpty) {
      return _buildEmptyState();
    }
    return _buildCharactersContent(characters, false);
  }

  Widget _buildCharactersContent(
      List<Character> characters, bool isLoadingMore,) {
    return _buildCharactersGrid(characters, isLoadingMore);
  }

  Widget _buildCharactersGrid(List<Character> characters, bool isLoadingMore) {
    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.7,
        crossAxisSpacing: AppConstants.paddingSmall,
        mainAxisSpacing: AppConstants.paddingSmall,
      ),
      itemCount: characters.length + (isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= characters.length) {
          return const Center(child: CircularProgressIndicator());
        }
        final character = characters[index];
        return CharacterCard(character: character);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_off,
            size: 64,
            color:
                Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No characters found',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty
                ? 'Try adjusting your search or filters'
                : 'No characters match the current filters',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant
                      .withOpacity(0.7),
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          if (_searchQuery.isNotEmpty ||
              _genderFilter != null ||
              _speciesFilter != null ||
              !_hasImageFilter)
            ElevatedButton.icon(
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _searchQuery = '';
                  _genderFilter = null;
                  _speciesFilter = null;
                  _hasImageFilter = true;
                  _currentSort = CharacterSortOption.defaultSort;
                });
                _performSearch();
              },
              icon: const Icon(Icons.clear_all),
              label: const Text('Clear Filters'),
            ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Error loading characters',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _performSearch,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _showSortBottomSheet() {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sort Characters',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            ...CharacterSortOption.values.map((option) {
              final isSelected = _currentSort == option;
              return ListTile(
                leading: Icon(
                  _getSortIcon(option),
                  color:
                      isSelected ? Theme.of(context).colorScheme.primary : null,
                ),
                title: Text(
                  _getSortLabel(option),
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.w600 : null,
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                ),
                trailing: isSelected
                    ? Icon(
                        Icons.check,
                        color: Theme.of(context).colorScheme.primary,
                      )
                    : null,
                onTap: () {
                  setState(() {
                    _currentSort = option;
                  });
                  _performSearch();
                  Navigator.pop(context);
                  HapticFeedback.lightImpact();
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  String _getSortLabel(CharacterSortOption sort) {
    switch (sort) {
      case CharacterSortOption.defaultSort:
        return 'Default';
      case CharacterSortOption.nameAZ:
        return 'Name A-Z';
      case CharacterSortOption.nameZA:
        return 'Name Z-A';
      case CharacterSortOption.gamesCount:
        return 'Games Count';
    }
  }

  IconData _getSortIcon(CharacterSortOption sort) {
    switch (sort) {
      case CharacterSortOption.defaultSort:
        return Icons.auto_awesome;
      case CharacterSortOption.nameAZ:
      case CharacterSortOption.nameZA:
        return Icons.sort_by_alpha;
      case CharacterSortOption.gamesCount:
        return Icons.videogame_asset;
    }
  }
}
