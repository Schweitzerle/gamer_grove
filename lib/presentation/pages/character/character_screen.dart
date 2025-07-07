// lib/presentation/pages/characters/characters_screen.dart
import 'package:flutter/material.dart';
import 'package:gamer_grove/presentation/pages/character/widgets/character_filter_bar.dart';
import '../../../domain/entities/character/character.dart';
import 'character_detail_screen.dart';
import 'widgets/character_card.dart';

enum CharacterSortBy {
  nameAZ,
  nameZA,
  mostDescriptions,
  leastDescriptions,
}

enum CharacterViewMode {
  grid,
  list,
}

class CharactersScreen extends StatefulWidget {
  final List<Character> characters;
  final String gameTitle;
  final Character? initialCharacter;

  const CharactersScreen({
    super.key,
    required this.characters,
    required this.gameTitle,
    this.initialCharacter,
  });

  @override
  State<CharactersScreen> createState() => _CharactersScreenState();
}

class _CharactersScreenState extends State<CharactersScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Character> _filteredCharacters = [];
  CharacterSortBy _currentSort = CharacterSortBy.nameAZ;
  CharacterViewMode _viewMode = CharacterViewMode.grid;
  bool _showOnlyWithImages = false;
  bool _showOnlyWithDescriptions = false;
  Character? _selectedCharacter;

  @override
  void initState() {
    super.initState();
    _filteredCharacters = List.from(widget.characters);
    _selectedCharacter = widget.initialCharacter;
    _applyFiltersAndSort();

    // Scroll to initial character if provided
    if (widget.initialCharacter != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToCharacter(widget.initialCharacter!);
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          CharactersFilterBar(
            searchController: _searchController,
            currentSort: _currentSort,
            viewMode: _viewMode,
            showOnlyWithImages: _showOnlyWithImages,
            showOnlyWithDescriptions: _showOnlyWithDescriptions,
            onSearchChanged: _onSearchChanged,
            onSortChanged: _onSortChanged,
            onViewModeChanged: _onViewModeChanged,
            onShowImagesChanged: _onShowImagesChanged,
            onShowDescriptionsChanged: _onShowDescriptionsChanged,
          ),
          Expanded(
            child: _buildCharactersList(),
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
          const Text('Characters'),
          Text(
            widget.gameTitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
      actions: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: Colors.purple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            '${_filteredCharacters.length} characters',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.purple,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCharactersList() {
    if (_filteredCharacters.isEmpty) {
      return _buildEmptyState();
    }

    return _viewMode == CharacterViewMode.grid
        ? _buildGridView()
        : _buildListView();
  }

  Widget _buildGridView() {
    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _filteredCharacters.length,
      itemBuilder: (context, index) {
        final character = _filteredCharacters[index];
        return CharacterCard(
          character: character,
          isSelected: character.id == _selectedCharacter?.id,
          onTap: () => _onCharacterTapped(character),
        );
      },
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _filteredCharacters.length,
      itemBuilder: (context, index) {
        final character = _filteredCharacters[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Card(
            elevation: character.id == _selectedCharacter?.id ? 4 : 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: character.id == _selectedCharacter?.id
                  ? const BorderSide(color: Colors.purple, width: 2)
                  : BorderSide.none,
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: _buildListItemImage(character),
              title: Text(
                character.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: character.description != null
                  ? Text(
                character.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              )
                  : const Text(
                'No description available',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
              onTap: () => _onCharacterTapped(character),
            ),
          ),
        );
      },
    );
  }

  Widget _buildListItemImage(Character character) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.purple.withOpacity(0.1),
      ),
      child: character.imageUrl != null
          ? ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          character.imageUrl!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Icon(
            Icons.person,
            color: Colors.purple.withOpacity(0.6),
          ),
        ),
      )
          : Icon(
        Icons.person,
        color: Colors.purple.withOpacity(0.6),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No characters found',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filters',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 24),
          TextButton.icon(
            onPressed: _clearAllFilters,
            icon: const Icon(Icons.clear_all),
            label: const Text('Clear all filters'),
          ),
        ],
      ),
    );
  }

  void _showCharacterDetails(Character character) {
    // 🆕 UPDATED: Navigate to full CharacterDetailScreen instead of bottom sheet
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CharacterDetailScreen(
          character: character,
          // TODO: Pass games data if available
          characterGames: null,
        ),
      ),
    );
  }

// 🔄 UPDATE the existing _onCharacterTapped method:
  void _onCharacterTapped(Character character) {
    setState(() {
      _selectedCharacter = character;
    });

    // 🆕 UPDATED: Navigate to CharacterDetailScreen instead of bottom sheet
    _showCharacterDetails(character);
  }

  void _scrollToCharacter(Character character) {
    final index = _filteredCharacters.indexWhere((c) => c.id == character.id);
    if (index != -1) {
      if (_viewMode == CharacterViewMode.grid) {
        // For grid view, calculate approximate position
        final itemHeight = (MediaQuery.of(context).size.width - 44) / 2 * (1 / 0.75) + 12;
        final row = index ~/ 2;
        final position = row * itemHeight;

        _scrollController.animateTo(
          position,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      } else {
        // For list view
        final position = index * 84.0; // Approximate height of list item
        _scrollController.animateTo(
          position,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  void _onSearchChanged(String query) {
    _applyFiltersAndSort();
  }

  void _onSortChanged(CharacterSortBy sort) {
    setState(() {
      _currentSort = sort;
    });
    _applyFiltersAndSort();
  }

  void _onViewModeChanged(CharacterViewMode mode) {
    setState(() {
      _viewMode = mode;
    });
  }

  void _onShowImagesChanged(bool value) {
    setState(() {
      _showOnlyWithImages = value;
    });
    _applyFiltersAndSort();
  }

  void _onShowDescriptionsChanged(bool value) {
    setState(() {
      _showOnlyWithDescriptions = value;
    });
    _applyFiltersAndSort();
  }

  void _applyFiltersAndSort() {
    setState(() {
      _filteredCharacters = widget.characters.where((character) {
        // Search filter
        final query = _searchController.text.toLowerCase();
        if (query.isNotEmpty && !character.name.toLowerCase().contains(query)) {
          return false;
        }

        // Image filter
        if (_showOnlyWithImages && character.imageUrl == null) {
          return false;
        }

        // Description filter
        if (_showOnlyWithDescriptions && character.description == null) {
          return false;
        }

        return true;
      }).toList();

      // Apply sorting
      switch (_currentSort) {
        case CharacterSortBy.nameAZ:
          _filteredCharacters.sort((a, b) => a.name.compareTo(b.name));
          break;
        case CharacterSortBy.nameZA:
          _filteredCharacters.sort((a, b) => b.name.compareTo(a.name));
          break;
        case CharacterSortBy.mostDescriptions:
          _filteredCharacters.sort((a, b) {
            final aHasDesc = a.description != null ? 1 : 0;
            final bHasDesc = b.description != null ? 1 : 0;
            return bHasDesc.compareTo(aHasDesc);
          });
          break;
        case CharacterSortBy.leastDescriptions:
          _filteredCharacters.sort((a, b) {
            final aHasDesc = a.description != null ? 1 : 0;
            final bHasDesc = b.description != null ? 1 : 0;
            return aHasDesc.compareTo(bHasDesc);
          });
          break;
      }
    });
  }

  void _clearAllFilters() {
    setState(() {
      _searchController.clear();
      _showOnlyWithImages = false;
      _showOnlyWithDescriptions = false;
      _currentSort = CharacterSortBy.nameAZ;
    });
    _applyFiltersAndSort();
  }
}