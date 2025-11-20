// lib/presentation/pages/event/widgets/event_filter_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gamer_grove/core/constants/app_constants.dart';
import 'package:gamer_grove/domain/entities/search/event_search_filters.dart';

class EventFilterBottomSheet extends StatefulWidget {

  const EventFilterBottomSheet({
    required this.currentFilters, super.key,
  });
  final EventSearchFilters currentFilters;

  @override
  State<EventFilterBottomSheet> createState() => _EventFilterBottomSheetState();

  static Future<EventSearchFilters?> show({
    required BuildContext context,
    required EventSearchFilters currentFilters,
  }) {
    return showModalBottomSheet<EventSearchFilters>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EventFilterBottomSheet(
        currentFilters: currentFilters,
      ),
    );
  }
}

class _EventFilterBottomSheetState extends State<EventFilterBottomSheet>
    with SingleTickerProviderStateMixin {
  late EventSearchFilters _workingFilters;
  late TabController _tabController;

  // Event time filters (single date dialog like release date)
  DateTime? _eventTimeFrom;
  DateTime? _eventTimeTo;
  DateTime? _singleEventTime;
  String? _eventTimeOperator; // 'before', 'after', 'on'

  @override
  void initState() {
    super.initState();
    _workingFilters = widget.currentFilters;
    _tabController = TabController(length: 2, vsync: this);

    // Initialize date filters from current filters
    _eventTimeFrom = widget.currentFilters.startTimeFrom;
    _eventTimeTo = widget.currentFilters.startTimeTo;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    // Build filters from selections
    DateTime? finalStartTimeFrom;
    DateTime? finalStartTimeTo;

    // Handle single date with operator
    if (_singleEventTime != null && _eventTimeOperator != null) {
      switch (_eventTimeOperator) {
        case 'before':
          // Events starting before this date
          finalStartTimeTo = _singleEventTime;
        case 'after':
          // Events starting after this date
          finalStartTimeFrom = _singleEventTime;
        case 'on':
          // Events starting on this exact day
          finalStartTimeFrom = DateTime(
            _singleEventTime!.year,
            _singleEventTime!.month,
            _singleEventTime!.day,
          );
          finalStartTimeTo = DateTime(
            _singleEventTime!.year,
            _singleEventTime!.month,
            _singleEventTime!.day,
            23,
            59,
            59,
          );
      }
    } else {
      // Use range filters
      finalStartTimeFrom = _eventTimeFrom;
      finalStartTimeTo = _eventTimeTo;
    }

    final filters = EventSearchFilters(
      startTimeFrom: finalStartTimeFrom,
      startTimeTo: finalStartTimeTo,
      sortBy: _workingFilters.sortBy,
      sortOrder: _workingFilters.sortOrder,
    );

    Navigator.of(context).pop(filters);
  }

  void _resetFilters() {
    setState(() {
      _eventTimeFrom = null;
      _eventTimeTo = null;
      _singleEventTime = null;
      _eventTimeOperator = null;
      _workingFilters = const EventSearchFilters();
    });
    HapticFeedback.lightImpact();
  }

  int _getActiveFilterCount() {
    var count = 0;
    if (_eventTimeFrom != null || _eventTimeTo != null || _singleEventTime != null) {
      count++;
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.85,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppConstants.borderRadius * 2),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          _buildHeader(theme),

          // Tabs
          _buildTabs(theme),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTimeTab(),
                _buildSortTab(),
              ],
            ),
          ),

          // Bottom Actions
          _buildBottomActions(theme),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    final filterCount = _getActiveFilterCount();

    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outlineVariant,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.tune_rounded,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: AppConstants.paddingSmall),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Event Filters',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (filterCount > 0)
                  Text(
                    '$filterCount active filter${filterCount > 1 ? 's' : ''}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
              ],
            ),
          ),
          if (filterCount > 0)
            TextButton(
              onPressed: _resetFilters,
              child: const Text('Reset'),
            ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outlineVariant,
          ),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(text: 'Time', icon: Icon(Icons.access_time, size: 20)),
          Tab(text: 'Sort', icon: Icon(Icons.sort, size: 20)),
        ],
      ),
    );
  }

  Widget _buildTimeTab() {
    final hasDateFilter = _eventTimeFrom != null ||
        _eventTimeTo != null ||
        _singleEventTime != null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Event Time'),
          const SizedBox(height: AppConstants.paddingSmall),
          Text(
            'Filter events by their scheduled time',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          InkWell(
            onTap: _showEventTimeFilterDialog,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
                ),
                borderRadius: BorderRadius.circular(12),
                color: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest
                    .withOpacity(0.3),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      _getEventTimeFilterText(),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: hasDateFilter
                                ? Theme.of(context).colorScheme.onSurface
                                : Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ),
                  Icon(
                    Icons.calendar_month,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getEventTimeFilterText() {
    if (_eventTimeFrom != null && _eventTimeTo != null) {
      return 'Between ${_formatDate(_eventTimeFrom!)} and ${_formatDate(_eventTimeTo!)}';
    } else if (_eventTimeFrom != null) {
      return 'From ${_formatDate(_eventTimeFrom!)}';
    } else if (_eventTimeTo != null) {
      return 'Until ${_formatDate(_eventTimeTo!)}';
    } else if (_singleEventTime != null && _eventTimeOperator != null) {
      var operator = '';
      switch (_eventTimeOperator) {
        case 'before':
          operator = 'Before';
        case 'after':
          operator = 'After';
        case 'on':
          operator = 'On';
      }
      return '$operator ${_formatDate(_singleEventTime!)}';
    }
    return 'Select event time';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showEventTimeFilterDialog() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => EventTimeFilterDialog(
        initialDateFrom: _eventTimeFrom,
        initialDateTo: _eventTimeTo,
        initialSingleDate: _singleEventTime,
        initialOperator: _eventTimeOperator,
        onApply: (from, to, single, operator) {
          setState(() {
            _eventTimeFrom = from;
            _eventTimeTo = to;
            _singleEventTime = single;
            _eventTimeOperator = operator;
          });
        },
      ),
    );
  }

  Widget _buildSortTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Sort By'),
          const SizedBox(height: AppConstants.paddingSmall),
          _buildSortOption(
            'Relevance',
            EventSortBy.relevance,
            Icons.star_outline,
          ),
          _buildSortOption(
            'Start Time',
            EventSortBy.startTime,
            Icons.schedule,
          ),
          _buildSortOption(
            'End Time',
            EventSortBy.endTime,
            Icons.event_busy,
          ),
          _buildSortOption(
            'Name',
            EventSortBy.name,
            Icons.sort_by_alpha,
          ),
          const SizedBox(height: AppConstants.paddingLarge),
          _buildSectionTitle('Sort Order'),
          const SizedBox(height: AppConstants.paddingSmall),
          _buildSortOrderOption(
            'Ascending',
            EventSortOrder.ascending,
            Icons.arrow_upward,
          ),
          _buildSortOrderOption(
            'Descending',
            EventSortOrder.descending,
            Icons.arrow_downward,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildSortOption(String label, EventSortBy sortBy, IconData icon) {
    final isSelected = _workingFilters.sortBy == sortBy;
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? theme.colorScheme.primary : null,
      ),
      title: Text(label),
      trailing: isSelected
          ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
          : null,
      selected: isSelected,
      onTap: () {
        setState(() {
          _workingFilters = _workingFilters.copyWith(sortBy: sortBy);
        });
      },
    );
  }

  Widget _buildSortOrderOption(
    String label,
    EventSortOrder sortOrder,
    IconData icon,
  ) {
    final isSelected = _workingFilters.sortOrder == sortOrder;
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? theme.colorScheme.primary : null,
      ),
      title: Text(label),
      trailing: isSelected
          ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
          : null,
      selected: isSelected,
      onTap: () {
        setState(() {
          _workingFilters = _workingFilters.copyWith(sortOrder: sortOrder);
        });
      },
    );
  }

  Widget _buildBottomActions(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outlineVariant,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: AppConstants.paddingMedium),
            Expanded(
              flex: 2,
              child: FilledButton(
                onPressed: _applyFilters,
                child: Text(
                  _getActiveFilterCount() > 0
                      ? 'Apply ${_getActiveFilterCount()} Filter${_getActiveFilterCount() > 1 ? 's' : ''}'
                      : 'Apply Filters',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// EVENT TIME FILTER DIALOG (like Release Date)
// ==========================================

class EventTimeFilterDialog extends StatefulWidget {

  const EventTimeFilterDialog({
    required this.onApply, super.key,
    this.initialDateFrom,
    this.initialDateTo,
    this.initialSingleDate,
    this.initialOperator,
  });
  final DateTime? initialDateFrom;
  final DateTime? initialDateTo;
  final DateTime? initialSingleDate;
  final String? initialOperator;
  final void Function(DateTime?, DateTime?, DateTime?, String?) onApply;

  @override
  State<EventTimeFilterDialog> createState() => _EventTimeFilterDialogState();
}

class _EventTimeFilterDialogState extends State<EventTimeFilterDialog>
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
                    'Event Time Filter',
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
                lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
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
                lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
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
            'Select a single date with operator',
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
                lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
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
              ButtonSegment(value: 'before', label: Text('Before')),
              ButtonSegment(value: 'on', label: Text('On')),
              ButtonSegment(value: 'after', label: Text('After')),
            ],
            selected: {_operator},
            onSelectionChanged: (Set<String> newSelection) {
              setState(() {
                _operator = newSelection.first;
              });
            },
          ),
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.outline,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    date != null
                        ? '${date.day}/${date.month}/${date.year}'
                        : 'Not set',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
            if (date != null)
              IconButton(
                icon: const Icon(Icons.clear),
                onPressed: onClear,
              ),
          ],
        ),
      ),
    );
  }
}
