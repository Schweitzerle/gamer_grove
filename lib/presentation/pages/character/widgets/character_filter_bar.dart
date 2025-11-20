// lib/presentation/pages/characters/widgets/characters_filter_bar.dart
import 'package:flutter/material.dart';
import 'package:gamer_grove/presentation/pages/character/character_screen.dart';

class CharactersFilterBar extends StatelessWidget {

  const CharactersFilterBar({
    required this.searchController, required this.currentSort, required this.viewMode, required this.showOnlyWithImages, required this.showOnlyWithDescriptions, required this.onSearchChanged, required this.onSortChanged, required this.onViewModeChanged, required this.onShowImagesChanged, required this.onShowDescriptionsChanged, super.key,
  });
  final TextEditingController searchController;
  final CharacterSortBy currentSort;
  final CharacterViewMode viewMode;
  final bool showOnlyWithImages;
  final bool showOnlyWithDescriptions;
  final void Function(String) onSearchChanged;
  final void Function(CharacterSortBy) onSortChanged;
  final void Function(CharacterViewMode) onViewModeChanged;
  final void Function(bool) onShowImagesChanged;
  final void Function(bool) onShowDescriptionsChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
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
          _buildSearchAndViewToggle(context),
          const SizedBox(height: 12),
          _buildFiltersAndSort(context),
        ],
      ),
    );
  }

  Widget _buildSearchAndViewToggle(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'Search characters...',
              prefixIcon: const Icon(Icons.search, color: Colors.purple),
              suffixIcon: searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        searchController.clear();
                        onSearchChanged('');
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.purple, width: 2),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            onChanged: onSearchChanged,
          ),
        ),
        const SizedBox(width: 12),
        _buildViewModeToggle(context),
      ],
    );
  }

  Widget _buildViewModeToggle(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildViewModeButton(
            context,
            icon: Icons.grid_view,
            mode: CharacterViewMode.grid,
            isSelected: viewMode == CharacterViewMode.grid,
          ),
          Container(
            width: 1,
            height: 32,
            color: Colors.grey.shade300,
          ),
          _buildViewModeButton(
            context,
            icon: Icons.list,
            mode: CharacterViewMode.list,
            isSelected: viewMode == CharacterViewMode.list,
          ),
        ],
      ),
    );
  }

  Widget _buildViewModeButton(
    BuildContext context, {
    required IconData icon,
    required CharacterViewMode mode,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => onViewModeChanged(mode),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.purple : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Icon(
          icon,
          size: 20,
          color: isSelected ? Colors.white : Colors.grey.shade600,
        ),
      ),
    );
  }

  Widget _buildFiltersAndSort(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildSortButton(context),
                const SizedBox(width: 8),
                _buildFilterChip(
                  context,
                  label: 'With Images',
                  isActive: showOnlyWithImages,
                  onTap: () => onShowImagesChanged(!showOnlyWithImages),
                  icon: Icons.image,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  context,
                  label: 'With Descriptions',
                  isActive: showOnlyWithDescriptions,
                  onTap: () =>
                      onShowDescriptionsChanged(!showOnlyWithDescriptions),
                  icon: Icons.description,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSortButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _showSortOptions(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.purple.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.purple.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.sort, size: 16, color: Colors.purple),
            const SizedBox(width: 4),
            Text(
              _getSortDisplayText(),
              style: const TextStyle(
                color: Colors.purple,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down,
                size: 16, color: Colors.purple,),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context, {
    required String label,
    required bool isActive,
    required VoidCallback onTap,
    required IconData icon,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.purple : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? Colors.purple : Colors.grey.shade300,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isActive ? Colors.white : Colors.grey.shade600,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.grey.shade600,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSortOptions(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Sort Characters',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSortOption(
              context,
              'Name (A-Z)',
              CharacterSortBy.nameAZ,
              Icons.sort_by_alpha,
            ),
            _buildSortOption(
              context,
              'Name (Z-A)',
              CharacterSortBy.nameZA,
              Icons.sort_by_alpha,
            ),
            _buildSortOption(
              context,
              'Most Descriptions First',
              CharacterSortBy.mostDescriptions,
              Icons.description,
            ),
            _buildSortOption(
              context,
              'Least Descriptions First',
              CharacterSortBy.leastDescriptions,
              Icons.description_outlined,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(
    BuildContext context,
    String title,
    CharacterSortBy sortBy,
    IconData icon,
  ) {
    final isSelected = currentSort == sortBy;

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? Colors.purple : Colors.grey.shade600,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Colors.purple : null,
        ),
      ),
      trailing:
          isSelected ? const Icon(Icons.check, color: Colors.purple) : null,
      onTap: () {
        onSortChanged(sortBy);
        Navigator.of(context).pop();
      },
    );
  }

  String _getSortDisplayText() {
    switch (currentSort) {
      case CharacterSortBy.nameAZ:
        return 'A-Z';
      case CharacterSortBy.nameZA:
        return 'Z-A';
      case CharacterSortBy.mostDescriptions:
        return 'Most Desc';
      case CharacterSortBy.leastDescriptions:
        return 'Least Desc';
    }
  }
}
