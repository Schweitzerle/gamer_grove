// setState is legitimately used here: these are State methods split into
// same-library extensions. The analyzer cannot see through the extension.
// ignore_for_file: invalid_use_of_protected_member
part of '../filter_bottom_sheet.dart';

extension _FilterBottomSheetSearch on _FilterBottomSheetState {
  // ==========================================
  // DYNAMIC SEARCH SECTION
  // ==========================================

  Widget _buildDynamicSearchSection<T>({
    required String title,
    required IconData icon,
    required String hint,
    required TextEditingController controller,
    required List<T> searchResults,
    required List<int> selectedIds,
    required Map<int, String> nameMap,
    required bool isLoading,
    required void Function(String) onSearch,
    required void Function(int id, String name) onAdd,
    required void Function(int) onRemove,
    required Widget Function(T) itemBuilder,
    required int Function(T) getId,
    required String Function(T) getLabel,
    String? Function(T)? getImageUrl, // Optional image URL getter
  }) {
    final theme = Theme.of(context);

    return _buildFilterCard(
      title: title,
      icon: icon,
      activeCount: selectedIds.length,
      onClear: selectedIds.isEmpty
          ? null
          : () {
              setState(() {
                selectedIds.clear();
                nameMap.clear();
                controller.clear();
                onSearch('');
              });
            },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Input
          TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: Icon(icon),
              suffixIcon: isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : controller.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            controller.clear();
                            onSearch('');
                          },
                        )
                      : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor:
                  theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
            ),
            onChanged: (value) => onSearch(value),
          ),

          // Search Results
          if (searchResults.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              constraints: const BoxConstraints(maxHeight: 200),
              decoration: BoxDecoration(
                border: Border.all(
                  color: theme.colorScheme.outline.withOpacity(0.5),
                ),
                borderRadius: BorderRadius.circular(12),
                color: theme.colorScheme.surface,
              ),
              child: Material(
                color: Colors.transparent,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: searchResults.length,
                  itemBuilder: (context, index) {
                    final item = searchResults[index];
                    final itemId = getId(item);
                    final isSelected = selectedIds.contains(itemId);

                    // Get image URL if available
                    final imageUrl = getImageUrl?.call(item);

                    // Build placeholder widget for consistency
                    Widget buildPlaceholder() {
                      return Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Icon(
                          icon,
                          size: 20,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      );
                    }

                    // If getImageUrl is provided, always show a leading widget
                    // (either image or placeholder)
                    Widget? leadingWidget;
                    if (getImageUrl != null) {
                      if (imageUrl != null && imageUrl.isNotEmpty) {
                        // Show image with placeholder fallback
                        leadingWidget = ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.network(
                            imageUrl,
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return buildPlaceholder();
                            },
                          ),
                        );
                      } else {
                        // Show placeholder for items without image
                        leadingWidget = buildPlaceholder();
                      }
                    }

                    return ListTile(
                      leading: leadingWidget,
                      title: itemBuilder(item),
                      trailing: isSelected
                          ? Icon(
                              Icons.check_circle,
                              color: theme.colorScheme.primary,
                            )
                          : Icon(
                              Icons.add_circle_outline,
                              color: theme.colorScheme.primary,
                            ),
                      onTap: () {
                        if (isSelected) {
                          onRemove(itemId);
                        } else {
                          onAdd(itemId, getLabel(item));
                        }
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],

          // Selected Items as Chips
          if (selectedIds.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: selectedIds.map((id) {
                // Try to get name from map first, then from search results
                String name;
                if (nameMap.containsKey(id)) {
                  name = nameMap[id]!;
                } else {
                  final item = searchResults.cast<T?>().firstWhere(
                        (item) => item != null && getId(item) == id,
                        orElse: () => null,
                      );
                  name = item != null ? getLabel(item) : 'ID: $id';
                }

                return Chip(
                  label: Text(name),
                  onDeleted: () => onRemove(id),
                  deleteIcon: const Icon(Icons.close, size: 18),
                  backgroundColor: theme.colorScheme.secondaryContainer,
                  labelStyle: TextStyle(
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  // ==========================================
  // HELPER METHODS
  // ==========================================

  Widget _buildSectionTitle(String title, [IconData? icon]) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(
            icon,
            size: 18,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
        ],
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  // ==========================================
  // SEARCH DEBOUNCE METHODS
  // ==========================================

  void _searchCompanies(String query) {
    if (widget.onSearchCompanies == null) return;

    _companyDebounce?.cancel();
    if (query.isEmpty) {
      setState(() => _companySearchResults.clear());
      return;
    }

    setState(() => _isSearchingCompanies = true);

    _companyDebounce = Timer(const Duration(milliseconds: 500), () async {
      try {
        final results = await widget.onSearchCompanies!(query);
        if (mounted) {
          setState(() {
            _companySearchResults = results;
            _isSearchingCompanies = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isSearchingCompanies = false);
        }
      }
    });
  }

  void _searchGameEngines(String query) {
    if (widget.onSearchGameEngines == null) return;

    _engineDebounce?.cancel();
    if (query.isEmpty) {
      setState(() => _engineSearchResults.clear());
      return;
    }

    setState(() => _isSearchingEngines = true);

    _engineDebounce = Timer(const Duration(milliseconds: 500), () async {
      try {
        final results = await widget.onSearchGameEngines!(query);
        if (mounted) {
          setState(() {
            _engineSearchResults = results;
            _isSearchingEngines = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isSearchingEngines = false);
        }
      }
    });
  }

  void _searchFranchises(String query) {
    if (widget.onSearchFranchises == null) return;

    _franchiseDebounce?.cancel();
    if (query.isEmpty) {
      setState(() => _franchiseSearchResults.clear());
      return;
    }

    setState(() => _isSearchingFranchises = true);

    _franchiseDebounce = Timer(const Duration(milliseconds: 500), () async {
      try {
        final results = await widget.onSearchFranchises!(query);
        if (mounted) {
          setState(() {
            _franchiseSearchResults = results;
            _isSearchingFranchises = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isSearchingFranchises = false);
        }
      }
    });
  }

  void _searchCollections(String query) {
    if (widget.onSearchCollections == null) return;

    _collectionDebounce?.cancel();
    if (query.isEmpty) {
      setState(() => _collectionSearchResults.clear());
      return;
    }

    setState(() => _isSearchingCollections = true);

    _collectionDebounce = Timer(const Duration(milliseconds: 500), () async {
      try {
        final results = await widget.onSearchCollections!(query);
        if (mounted) {
          setState(() {
            _collectionSearchResults = results;
            _isSearchingCollections = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isSearchingCollections = false);
        }
      }
    });
  }

  void _searchKeywords(String query) {
    if (widget.onSearchKeywords == null) return;

    _keywordDebounce?.cancel();
    if (query.isEmpty) {
      setState(() => _keywordSearchResults.clear());
      return;
    }

    setState(() => _isSearchingKeywords = true);

    _keywordDebounce = Timer(const Duration(milliseconds: 500), () async {
      try {
        final results = await widget.onSearchKeywords!(query);
        if (mounted) {
          setState(() {
            _keywordSearchResults = results;
            _isSearchingKeywords = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isSearchingKeywords = false);
        }
      }
    });
  }

  void _searchLanguages(String query) {
    if (widget.onSearchLanguages == null) return;

    _languageDebounce?.cancel();
    if (query.isEmpty) {
      setState(() => _languageSearchResults.clear());
      return;
    }

    setState(() => _isSearchingLanguages = true);

    _languageDebounce = Timer(const Duration(milliseconds: 500), () async {
      try {
        final results = await widget.onSearchLanguages!(query);
        if (mounted) {
          setState(() {
            _languageSearchResults = results;
            _isSearchingLanguages = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isSearchingLanguages = false);
        }
      }
    });
  }

  void _searchAgeRatings(String query) {
    if (widget.onSearchAgeRatings == null) return;

    _ageRatingDebounce?.cancel();
    if (query.isEmpty) {
      setState(() => _ageRatingSearchResults.clear());
      return;
    }

    setState(() => _isSearchingAgeRatings = true);

    _ageRatingDebounce = Timer(const Duration(milliseconds: 500), () async {
      try {
        final results = await widget.onSearchAgeRatings!(query);
        if (mounted) {
          setState(() {
            _ageRatingSearchResults = results;
            _isSearchingAgeRatings = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isSearchingAgeRatings = false);
        }
      }
    });
  }

  void _searchThemes(String query) {
    if (widget.onSearchThemes == null) return;

    _themeDebounce?.cancel();
    if (query.isEmpty) {
      setState(() => _themeSearchResults.clear());
      return;
    }

    setState(() => _isSearchingThemes = true);

    _themeDebounce = Timer(const Duration(milliseconds: 500), () async {
      try {
        final results = await widget.onSearchThemes!(query);
        if (mounted) {
          setState(() {
            _themeSearchResults = results;
            _isSearchingThemes = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isSearchingThemes = false);
        }
      }
    });
  }

  void _searchPlatforms(String query) {
    if (widget.onSearchPlatforms == null) return;

    _platformDebounce?.cancel();
    if (query.isEmpty) {
      setState(() => _platformSearchResults.clear());
      return;
    }

    setState(() => _isSearchingPlatforms = true);

    _platformDebounce = Timer(const Duration(milliseconds: 500), () async {
      try {
        final results = await widget.onSearchPlatforms!(query);
        if (mounted) {
          setState(() {
            _platformSearchResults = results;
            _isSearchingPlatforms = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isSearchingPlatforms = false);
        }
      }
    });
  }
}
