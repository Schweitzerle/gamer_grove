// presentation/pages/event/event_search_page.dart
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamer_grove/core/utils/navigations.dart';
import 'package:gamer_grove/domain/entities/search/event_search_filters.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../injection_container.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/storage_constants.dart';
import '../../../core/utils/input_validator.dart';
import '../../blocs/event/event_bloc.dart';
import '../../blocs/event/event_event.dart';
import '../../blocs/event/event_state.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import 'widgets/event_card.dart';
import 'widgets/event_filter_bottom_sheet.dart';
import '../../widgets/custom_shimmer.dart';
import '../../../core/widgets/error_widget.dart';

class EventSearchPage extends StatefulWidget {
  final EventSearchFilters? initialFilters;
  final String? initialTitle;

  const EventSearchPage({
    super.key,
    this.initialFilters,
    this.initialTitle,
  });

  @override
  State<EventSearchPage> createState() => _EventSearchPageState();
}

class _EventSearchPageState extends State<EventSearchPage> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  late EventBloc _eventBloc;

  // Recent searches
  List<String> _recentSearches = [];
  bool _showRecentSearches = true;

  // Filters
  late EventSearchFilters _currentFilters;
  bool _isLoadingFilterOptions = false;

  @override
  void initState() {
    super.initState();
    _currentFilters = widget.initialFilters ?? const EventSearchFilters();
    _eventBloc = sl<EventBloc>();
    _scrollController.addListener(_onScroll);
    _loadRecentSearches();

    // Get current user ID from AuthBloc
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {}

    // Load filter options first, then trigger search if we have initial filters
    _loadFilterOptions();
  }

  Future<void> _loadFilterOptions() async {
    setState(() => _isLoadingFilterOptions = true);

    try {
      // For now, event networks will be loaded dynamically when needed
      // We don't have a getAllEventNetworks method yet
      setState(() => _isLoadingFilterOptions = false);

      // If we have initial filters, trigger search automatically AFTER filters are loaded
      if (widget.initialFilters != null && widget.initialFilters!.hasFilters) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _performSearch('');
        });
      }
    } catch (e) {
      setState(() => _isLoadingFilterOptions = false);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _eventBloc.close();
    super.dispose();
  }

  void _onScroll() {
    final currentState = _eventBloc.state;
    if (_isBottom &&
        currentState is EventSearchLoaded &&
        !currentState.isLoadingMore) {
      _eventBloc.add(const LoadMoreEventsEvent());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  Future<void> _loadRecentSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recentSearchesJson =
          prefs.getString(StorageConstants.recentEventSearchesKey);

      if (recentSearchesJson != null) {
        final List<dynamic> decoded = jsonDecode(recentSearchesJson);
        setState(() {
          _recentSearches = decoded.map((e) => e.toString()).toList();
        });
      }
    } on Exception {
      // If there's an error loading, just keep the empty list
    }
  }

  Future<void> _addToRecentSearches(String query) async {
    if (query.trim().isEmpty) return;

    setState(() {
      _recentSearches.remove(query);
      _recentSearches.insert(0, query);
      if (_recentSearches.length > 10) {
        _recentSearches = _recentSearches.take(10).toList();
      }
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(_recentSearches);
      await prefs.setString(
        StorageConstants.recentEventSearchesKey,
        jsonString,
      );
    } on Exception {}
  }

  void _performSearch(String query) {
    // If both query and filters are empty, show initial view
    if (query.trim().isEmpty && !_currentFilters.hasFilters) {
      setState(() {
        _showRecentSearches = true;
      });
      _eventBloc.add(ClearEventSearchEvent());
      return;
    }

    final validation = InputValidator.validateSearchQuery(query);
    if (validation != null && query.trim().isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(validation)),
      );
      return;
    }

    if (query.trim().isNotEmpty) {
      _addToRecentSearches(query.trim());
    }

    setState(() {
      _showRecentSearches = false;
    });

    // Use SearchEventsWithFiltersEvent if filters are active
    if (_currentFilters.hasFilters || query.trim().isNotEmpty) {
      _eventBloc.add(SearchEventsWithFiltersEvent(
        query: query.trim(),
        filters: _currentFilters,
      ));
    } else {
      _eventBloc.add(SearchEventsEvent(query: query.trim()));
    }
  }

  void _clearSearch() {
    _searchController.clear();
    _eventBloc.add(const ClearEventSearchEvent());
    setState(() {
      _showRecentSearches = true;
      _currentFilters = const EventSearchFilters(); // Also reset filters
    });
  }

  int _getActiveFilterCount() {
    int count = 0;
    if (_currentFilters.startTimeFrom != null ||
        _currentFilters.startTimeTo != null) {
      count++;
    }
    if (_currentFilters.eventNetworkIds.isNotEmpty) count++;
    return count;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _eventBloc,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.initialTitle ?? 'Search Events'),
        ),
        body: Stack(
          children: [
            SafeArea(
              child: Column(
                children: [
                  _buildSearchHeader(),
                  Expanded(
                    child: BlocConsumer<EventBloc, EventState>(
                      listener: (context, state) {
                        if (state is EventError) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(state.message),
                              backgroundColor:
                                  Theme.of(context).colorScheme.error,
                              action: SnackBarAction(
                                label: 'Retry',
                                onPressed: () {
                                  if (_searchController.text.isNotEmpty) {
                                    _performSearch(_searchController.text);
                                  }
                                },
                              ),
                            ),
                          );
                        }
                      },
                      builder: (context, state) {
                        if (_showRecentSearches && state is EventInitial) {
                          return _buildInitialView();
                        } else if (state is EventSearchLoading &&
                            state.events.isEmpty) {
                          return _buildLoadingView();
                        } else if (state is EventSearchLoaded) {
                          return _buildSearchResults(state);
                        } else if (state is EventError &&
                            state.events.isEmpty) {
                          return CustomErrorWidget(
                            message: state.message,
                            onRetry: () {
                              if (_searchController.text.isNotEmpty) {
                                _performSearch(_searchController.text);
                              }
                            },
                          );
                        }
                        return _buildInitialView();
                      },
                    ),
                  ),
                ],
              ),
            ),
            // Glassmorphism Filter FAB
            _buildFilterFAB(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchHeader() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Main Search Bar
          TextField(
            controller: _searchController,
            onSubmitted: _performSearch,
            onChanged: (value) {
              // Show recent searches when field becomes empty
              if (value.isEmpty && !_showRecentSearches) {
                setState(() {
                  _showRecentSearches = true;
                });
                _eventBloc.add(const ClearEventSearchEvent());
              }
            },
            decoration: InputDecoration(
              hintText: 'Search for events...',
              prefixIcon: Icon(
                Icons.search_rounded,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded),
                      onPressed: _clearSearch,
                    )
                  : null,
              filled: true,
              fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                ),
              ),
            ),
          ),

          // Search Stats (when showing results) and Active Filters
          BlocBuilder<EventBloc, EventState>(
            builder: (context, state) {
              if (state is EventSearchLoaded && state.events.isNotEmpty) {
                return Padding(
                  padding:
                      const EdgeInsets.only(top: AppConstants.paddingSmall),
                  child: Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Text(
                              'Found ${state.events.length} events',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                            ),
                            if (!state.hasReachedMax) ...[
                              const Text(' • '),
                              Text(
                                'Scroll for more',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (state.isLoadingMore)
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      if (_currentFilters.hasFilters)
                        Chip(
                          visualDensity: VisualDensity.compact,
                          label: Text(
                            '${_getActiveFilterCount()} filters',
                          ),
                          avatar: const Icon(Icons.filter_alt, size: 16),
                          onDeleted: () {
                            setState(() {
                              _currentFilters = const EventSearchFilters();
                              // If search text is also empty, show initial view
                              if (_searchController.text.trim().isEmpty) {
                                _showRecentSearches = true;
                              }
                            });
                            _performSearch(_searchController.text);
                          },
                          deleteIcon: const Icon(Icons.close, size: 16),
                        ),
                    ],
                  ),
                );
              }
              // Show filters even when no results
              if (_currentFilters.hasFilters) {
                return Padding(
                  padding:
                      const EdgeInsets.only(top: AppConstants.paddingSmall),
                  child: Row(
                    children: [
                      Chip(
                        visualDensity: VisualDensity.compact,
                        label: Text(
                          '${_getActiveFilterCount()} filters',
                        ),
                        avatar: const Icon(Icons.filter_alt, size: 16),
                        onDeleted: () {
                          setState(() {
                            _currentFilters = const EventSearchFilters();
                            // If search text is also empty, show initial view
                            if (_searchController.text.trim().isEmpty) {
                              _showRecentSearches = true;
                            }
                          });
                          _performSearch(_searchController.text);
                        },
                        deleteIcon: const Icon(Icons.close, size: 16),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInitialView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Section
          Center(
            child: Column(
              children: [
                Icon(
                  Icons.event_available,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                ),
                const SizedBox(height: AppConstants.paddingMedium),
                Text(
                  'Discover Gaming Events',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: AppConstants.paddingSmall),
                Text(
                  'Search for gaming events and discover upcoming conferences',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: AppConstants.paddingXLarge),

          // Recent Searches
          if (_recentSearches.isNotEmpty) ...[
            Text(
              'Recent Searches',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _recentSearches
                  .map((search) => _buildSearchChip(search))
                  .toList(),
            ),
            const SizedBox(height: AppConstants.paddingLarge),
          ],

          // Popular Searches
          Text(
            'Popular Event Searches',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppConstants.paddingSmall),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              'E3',
              'Gamescom',
              'The Game Awards',
              'PAX',
              'Tokyo Game Show',
            ].map((search) => _buildPopularSearchChip(search)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchChip(String search) {
    return InputChip(
      label: Text(search),
      avatar: const Icon(Icons.history, size: 18),
      onPressed: () {
        _searchController.text = search;
        _performSearch(search);
      },
      onDeleted: () => _removeFromRecentSearches(search),
      deleteIcon: const Icon(Icons.close, size: 18),
    );
  }

  Future<void> _removeFromRecentSearches(String search) async {
    setState(() {
      _recentSearches.remove(search);
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(_recentSearches);
      await prefs.setString(
        StorageConstants.recentEventSearchesKey,
        jsonString,
      );
    } on Exception {}
  }

  Widget _buildPopularSearchChip(String search) {
    return ActionChip(
      label: Text(search),
      avatar: const Icon(Icons.trending_up, size: 18),
      onPressed: () {
        _searchController.text = search;
        _performSearch(search);
      },
    );
  }

  Widget _buildLoadingView() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
          child: CustomShimmer(
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchResults(EventSearchLoaded state) {
    if (state.events.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 80,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            Text(
              'No events found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            Text(
              'Try searching for something else or check your spelling',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.paddingLarge),
            OutlinedButton.icon(
              onPressed: _clearSearch,
              icon: const Icon(Icons.refresh),
              label: const Text('Start New Search'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        if (_searchController.text.isNotEmpty) {
          _eventBloc.add(SearchEventsEvent(query: _searchController.text));
        }
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        itemCount: state.hasReachedMax
            ? state.events.length
            : state.events.length + 1, // Extra item for loading indicator
        itemBuilder: (context, index) {
          if (index >= state.events.length) {
            return Padding(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              child: Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            );
          }

          final event = state.events[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
            child: EventCard(
              event: event,
              onTap: () => Navigations.navigateToEventDetails(
                context,
                eventId: event.id,
              ),
              showStatus: true,
              showGamesCount: true,
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterFAB(BuildContext context) {
    final theme = Theme.of(context);

    return Positioned(
      right: 16,
      bottom: 16,
      child: SafeArea(
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
                  onTap: _isLoadingFilterOptions ? null : _showFilters,
                  borderRadius: BorderRadius.circular(28),
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: _isLoadingFilterOptions
                            ? SizedBox(
                                width: 28,
                                height: 28,
                                child: LoadingIndicator(
                                  indicatorType: Indicator.pacman,
                                  colors: [theme.colorScheme.primary],
                                  strokeWidth: 2,
                                ),
                              )
                            : Icon(
                                Icons.tune_rounded,
                                color: theme.colorScheme.onPrimaryContainer,
                                size: 28,
                              ),
                      ),
                      if (!_isLoadingFilterOptions &&
                          _currentFilters.hasFilters)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 20,
                              minHeight: 20,
                            ),
                            child: Center(
                              child: Text(
                                '${_getActiveFilterCount()}',
                                style: TextStyle(
                                  color: theme.colorScheme.onPrimary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
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
    );
  }

  Future<void> _showFilters() async {
    final result = await EventFilterBottomSheet.show(
      context: context,
      currentFilters: _currentFilters,
    );

    if (result != null) {
      setState(() {
        _currentFilters = result;
      });
      _performSearch(_searchController.text);
    }
  }
}
