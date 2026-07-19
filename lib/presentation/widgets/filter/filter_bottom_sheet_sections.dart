// setState is legitimately used here: these are State methods split into
// same-library extensions. The analyzer cannot see through the extension.
// ignore_for_file: invalid_use_of_protected_member
part of '../filter_bottom_sheet.dart';

extension _FilterBottomSheetSections on _FilterBottomSheetState {
  // ==========================================
  // REUSABLE COMPONENTS
  // ==========================================

  Widget _buildFilterCard({
    required String title,
    required IconData icon,
    required Widget child,
    VoidCallback? onClear,
    int? activeCount,
  }) {
    final theme = Theme.of(context);
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 20, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (activeCount != null && activeCount > 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$activeCount',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (onClear != null && activeCount != null && activeCount > 0)
                  TextButton.icon(
                    onPressed: onClear,
                    icon: const Icon(Icons.clear, size: 16),
                    label: const Text('Clear'),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingCard({
    required String title,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.paddingLarge),
                child: Column(
                  children: [
                    SizedBox(
                      width: 32,
                      height: 32,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingMedium),
                    Text(
                      'Loading $title...',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChipGridSection({
    required String title,
    required IconData icon,
    required List<dynamic> items,
    required List<int> selectedIds,
    required String Function(dynamic) getLabel,
    required int Function(dynamic) getId,
  }) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppConstants.paddingMedium,
              AppConstants.paddingMedium,
              AppConstants.paddingMedium,
              0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      icon,
                      size: 20,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    if (selectedIds.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${selectedIds.length}',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (selectedIds.isNotEmpty)
                  TextButton.icon(
                    onPressed: () {
                      setState(() => selectedIds.clear());
                      HapticFeedback.lightImpact();
                    },
                    icon: const Icon(Icons.clear, size: 16),
                    label: const Text('Clear'),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
              ],
            ),
          ),

          // Horizontal scrollable chips (bleeding into edges)
          SizedBox(
            height: 56,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingMedium,
                vertical: 8,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final id = getId(item);
                final isSelected = selectedIds.contains(id);
                return Padding(
                  padding: EdgeInsets.only(
                    right: index < items.length - 1 ? 8 : 0,
                  ),
                  child: FilterChip(
                    label: Text(getLabel(item)),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          selectedIds.add(id);
                        } else {
                          selectedIds.remove(id);
                        }
                      });
                      HapticFeedback.lightImpact();
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // SECTION BUILDERS
  // ==========================================

  Widget _buildGenresSection() {
    if (widget.availableGenres.isEmpty) {
      return _buildLoadingCard(
        title: 'Genres',
        icon: Icons.bookmarks,
      );
    }
    return _buildChipGridSection(
      title: 'Genres',
      icon: Icons.bookmarks,
      items: widget.availableGenres,
      selectedIds: _selectedGenres,
      getLabel: (genre) => genre.name,
      getId: (genre) => genre.id,
    );
  }

  Widget _buildGameTypeSection() {
    if (widget.availableGameTypes.isEmpty) {
      return _buildLoadingCard(
        title: 'Game Types',
        icon: Icons.category,
      );
    }
    return _buildChipGridSection(
      title: 'Game Types',
      icon: Icons.category,
      items: widget.availableGameTypes,
      selectedIds: _selectedGameTypes,
      getLabel: (type) => type.type,
      getId: (type) => type.id,
    );
  }

  Widget _buildGameStatusSection() {
    if (widget.availableGameStatuses.isEmpty) {
      return _buildLoadingCard(
        title: 'Game Status',
        icon: Icons.info_outline,
      );
    }
    return _buildChipGridSection(
      title: 'Game Status',
      icon: Icons.info_outline,
      items: widget.availableGameStatuses,
      selectedIds: _selectedGameStatuses,
      getLabel: (status) => status.status,
      getId: (status) => status.id,
    );
  }

  Widget _buildGameModesSection() {
    return _buildChipGridSection(
      title: 'Game Modes',
      icon: Icons.sports_esports,
      items: widget.availableGameModes,
      selectedIds: _selectedGameModes,
      getLabel: (mode) => mode.name,
      getId: (mode) => mode.id,
    );
  }

  Widget _buildPlayerPerspectivesSection() {
    return _buildChipGridSection(
      title: 'Player Perspectives',
      icon: Icons.remove_red_eye,
      items: widget.availablePlayerPerspectives,
      selectedIds: _selectedPlayerPerspectives,
      getLabel: (perspective) => perspective.name,
      getId: (perspective) => perspective.id,
    );
  }
}
