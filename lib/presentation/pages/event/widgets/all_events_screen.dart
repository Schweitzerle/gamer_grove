// ==================================================
// ALL EVENTS SCREEN WITH FILTERING & SORTING
// ==================================================

// lib/presentation/pages/all_events/all_events_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gamer_grove/core/constants/app_constants.dart';
import 'package:gamer_grove/domain/entities/event/event.dart';
import 'package:gamer_grove/domain/entities/game/game.dart';
import 'package:gamer_grove/presentation/pages/event/widgets/event_card.dart';

enum EventSortOption {
  nameAZ,
  nameZA,
  dateNewest,
  dateOldest,
  status,
  gamesCount,
}

enum EventStatusFilter {
  all,
  live,
  upcoming,
  past,
}

class AllEventsScreen extends StatefulWidget {

  const AllEventsScreen({
    required this.title, required this.events, super.key,
    this.subtitle,
    this.game,
    this.showFilters = true,
    this.showSearch = true,
  });
  final String title;
  final String? subtitle;
  final List<Event> events;
  final Game? game; // Optional - für Kontext
  final bool showFilters;
  final bool showSearch;

  @override
  State<AllEventsScreen> createState() => _AllEventsScreenState();
}

class _AllEventsScreenState extends State<AllEventsScreen> {
  late List<Event> _filteredEvents;
  EventSortOption _currentSort = EventSortOption.dateNewest;
  EventStatusFilter _statusFilter = EventStatusFilter.all;
  String _searchQuery = '';
  bool _isGridView = false;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredEvents = List.from(widget.events);
    _applyFiltersAndSort();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Search & Filters
          if (widget.showSearch || widget.showFilters) _buildSearchAndFilters(),

          // Events Count & Sort
          _buildEventsHeader(),

          // Events List/Grid
          Expanded(
            child: _buildEventsList(),
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
        if (widget.showFilters)
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
              HapticFeedback.lightImpact();
            },
          ),
        IconButton(
          icon: const Icon(Icons.sort),
          onPressed: _showSortBottomSheet,
        ),
      ],
    );
  }

  Widget _buildSearchAndFilters() {
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
          // Search Bar
          if (widget.showSearch)
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search events...',
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
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainerLowest,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
                _applyFiltersAndSort();
              },
            ),

          if (widget.showSearch && widget.showFilters)
            const SizedBox(height: AppConstants.paddingSmall),

          // Status Filter Chips
          if (widget.showFilters)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: EventStatusFilter.values.map((filter) {
                  final isSelected = _statusFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(_getFilterLabel(filter)),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _statusFilter = filter;
                        });
                        _applyFiltersAndSort();
                        HapticFeedback.lightImpact();
                      },
                      avatar: Icon(
                        _getFilterIcon(filter),
                        size: 16,
                        color: isSelected
                            ? Theme.of(context).colorScheme.onSecondaryContainer
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEventsHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingMedium,
        vertical: AppConstants.paddingSmall,
      ),
      child: Row(
        children: [
          Icon(
            Icons.event,
            size: 16,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 6),
          Text(
            '${_filteredEvents.length} events',
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
  }

  Widget _buildEventsList() {
    if (_filteredEvents.isEmpty) {
      return _buildEmptyState();
    }

    if (_isGridView) {
      return _buildEventsGrid();
    } else {
      return _buildEventsListView();
    }
  }

  Widget _buildEventsListView() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      itemCount: _filteredEvents.length,
      itemBuilder: (context, index) {
        final event = _filteredEvents[index];
        return Container(
          height: 200,
          margin: const EdgeInsets.only(bottom: AppConstants.paddingSmall),
          child: EventCard(
            event: event,
            onTap: () => _navigateToEventDetails(event),
            showGamesCount: true,
          ),
        );
      },
    );
  }

  Widget _buildEventsGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: AppConstants.paddingSmall,
        mainAxisSpacing: AppConstants.paddingSmall,
      ),
      itemCount: _filteredEvents.length,
      itemBuilder: (context, index) {
        final event = _filteredEvents[index];
        return EventCard(
          event: event,
          onTap: () => _navigateToEventDetails(event),
          showGamesCount: true,
          compact: true,
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
            Icons.event_busy,
            size: 64,
            color:
                Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No events found',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty
                ? 'Try adjusting your search or filters'
                : 'No events match the current filters',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant
                      .withOpacity(0.7),
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          if (_searchQuery.isNotEmpty || _statusFilter != EventStatusFilter.all)
            ElevatedButton.icon(
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _searchQuery = '';
                  _statusFilter = EventStatusFilter.all;
                });
                _applyFiltersAndSort();
              },
              icon: const Icon(Icons.clear_all),
              label: const Text('Clear Filters'),
            ),
        ],
      ),
    );
  }

  void _applyFiltersAndSort() {
    setState(() {
      _filteredEvents = widget.events.where((event) {
        // Search filter
        final matchesSearch = _searchQuery.isEmpty ||
            event.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (event.description
                    ?.toLowerCase()
                    .contains(_searchQuery.toLowerCase()) ??
                false);

        // Status filter
        final matchesStatus = _statusFilter == EventStatusFilter.all ||
            (_statusFilter == EventStatusFilter.live && event.isLive) ||
            (_statusFilter == EventStatusFilter.upcoming && event.isUpcoming) ||
            (_statusFilter == EventStatusFilter.past && event.hasEnded);

        return matchesSearch && matchesStatus;
      }).toList();

      // Sort
      _filteredEvents.sort((a, b) {
        switch (_currentSort) {
          case EventSortOption.nameAZ:
            return a.name.compareTo(b.name);
          case EventSortOption.nameZA:
            return b.name.compareTo(a.name);
          case EventSortOption.dateNewest:
            if (a.startTime == null && b.startTime == null) return 0;
            if (a.startTime == null) return 1;
            if (b.startTime == null) return -1;
            return b.startTime!.compareTo(a.startTime!);
          case EventSortOption.dateOldest:
            if (a.startTime == null && b.startTime == null) return 0;
            if (a.startTime == null) return 1;
            if (b.startTime == null) return -1;
            return a.startTime!.compareTo(b.startTime!);
          case EventSortOption.status:
            return _getStatusPriority(a) - _getStatusPriority(b);
          case EventSortOption.gamesCount:
            return b.gameCount.compareTo(a.gameCount);
        }
      });
    });
  }

  int _getStatusPriority(Event event) {
    if (event.isLive) return 0;
    if (event.isUpcoming) return 1;
    return 2; // past
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
              'Sort Events',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            ...EventSortOption.values.map((option) {
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
                  _applyFiltersAndSort();
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

  void _navigateToEventDetails(Event event) {
    // TODO: Navigate to event details screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Event details for "${event.name}" coming soon!')),
    );
  }

  String _getFilterLabel(EventStatusFilter filter) {
    switch (filter) {
      case EventStatusFilter.all:
        return 'All';
      case EventStatusFilter.live:
        return 'Live';
      case EventStatusFilter.upcoming:
        return 'Upcoming';
      case EventStatusFilter.past:
        return 'Past';
    }
  }

  IconData _getFilterIcon(EventStatusFilter filter) {
    switch (filter) {
      case EventStatusFilter.all:
        return Icons.event;
      case EventStatusFilter.live:
        return Icons.circle;
      case EventStatusFilter.upcoming:
        return Icons.schedule;
      case EventStatusFilter.past:
        return Icons.history;
    }
  }

  String _getSortLabel(EventSortOption sort) {
    switch (sort) {
      case EventSortOption.nameAZ:
        return 'Name A-Z';
      case EventSortOption.nameZA:
        return 'Name Z-A';
      case EventSortOption.dateNewest:
        return 'Newest First';
      case EventSortOption.dateOldest:
        return 'Oldest First';
      case EventSortOption.status:
        return 'By Status';
      case EventSortOption.gamesCount:
        return 'Games Count';
    }
  }

  IconData _getSortIcon(EventSortOption sort) {
    switch (sort) {
      case EventSortOption.nameAZ:
        return Icons.sort_by_alpha;
      case EventSortOption.nameZA:
        return Icons.sort_by_alpha;
      case EventSortOption.dateNewest:
        return Icons.schedule;
      case EventSortOption.dateOldest:
        return Icons.history;
      case EventSortOption.status:
        return Icons.flag;
      case EventSortOption.gamesCount:
        return Icons.videogame_asset;
    }
  }
}
