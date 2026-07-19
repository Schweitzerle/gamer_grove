// lib/presentation/widgets/filter/date_filter_dialog.dart
import 'package:flutter/material.dart';

// ==========================================
// DATE FILTER DIALOG
// ==========================================

class DateFilterDialog extends StatefulWidget {
  const DateFilterDialog({
    required this.onApply,
    super.key,
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
                    Icon(
                      Icons.calendar_today,
                      color: theme.colorScheme.primary,
                    ),
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
