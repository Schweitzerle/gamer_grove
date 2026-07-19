// setState is legitimately used here: these are State methods split into
// same-library extensions. The analyzer cannot see through the extension.
// ignore_for_file: invalid_use_of_protected_member
part of '../filter_bottom_sheet.dart';

extension _FilterBottomSheetRatings on _FilterBottomSheetState {
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
}
