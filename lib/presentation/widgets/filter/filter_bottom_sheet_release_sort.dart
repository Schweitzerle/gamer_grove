// setState is legitimately used here: these are State methods split into
// same-library extensions. The analyzer cannot see through the extension.
// ignore_for_file: invalid_use_of_protected_member
part of '../filter_bottom_sheet.dart';

extension _FilterBottomSheetReleaseSort on _FilterBottomSheetState {
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
            onTap: _showDateFilterDialog,
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

  Widget _buildDateChip({
    required String label,
    required VoidCallback onRemove,
  }) {
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
}
