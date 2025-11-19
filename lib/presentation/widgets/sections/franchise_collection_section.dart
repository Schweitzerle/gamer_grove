// lib/presentation/pages/game_detail/widgets/franchise_collections_section.dart
import 'package:flutter/material.dart';
import 'package:gamer_grove/presentation/widgets/game_card.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/navigations.dart';
import '../../../../domain/entities/game/game.dart';
import '../../../../domain/entities/franchise.dart';
import '../../../../domain/entities/collection/collection.dart';

class FranchiseCollectionsSection extends StatefulWidget {
  final Game game;

  const FranchiseCollectionsSection({
    super.key,
    required this.game,
  });

  @override
  State<FranchiseCollectionsSection> createState() =>
      _FranchiseCollectionsSectionState();
}

class _FranchiseCollectionsSectionState
    extends State<FranchiseCollectionsSection> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    // Collect all series data
    final seriesItems = <SeriesItem>[];

    // Add Main Franchise first (if exists)
    if (widget.game.mainFranchise != null &&
        widget.game.mainFranchise!.hasGames) {
      seriesItems.add(SeriesItem(
        type: SeriesType.mainFranchise,
        title: widget.game.mainFranchise!.name,
        games: _getFranchiseGames(widget.game.mainFranchise!),
        totalCount: widget.game.mainFranchise!.gameCount,
        franchise: widget.game.mainFranchise,
        accentColor: Colors.orange,
        icon: Icons.stars,
      ));
    }

    // Add Other Franchises
    for (final franchise in widget.game.franchises) {
      if (franchise.hasGames) {
        seriesItems.add(SeriesItem(
          type: SeriesType.franchise,
          title: franchise.name,
          games: _getFranchiseGames(franchise),
          totalCount: franchise.gameCount,
          franchise: franchise,
          accentColor: Colors.orange,
          icon: Icons.account_tree,
        ));
      }
    }

    // Add Collections
    for (final collection in widget.game.collections) {
      if (collection.hasGames) {
        seriesItems.add(SeriesItem(
          type: SeriesType.collection,
          title: collection.name,
          games: _getCollectionGames(collection),
          totalCount: collection.gameCount,
          collection: collection,
          accentColor: Colors.blue,
          icon: Icons.collections,
        ));
      }
    }

    if (seriesItems.isEmpty) {
      return const SizedBox.shrink();
    }

    // Calculate totals for preview
    final totalGames =
        seriesItems.fold<int>(0, (sum, item) => sum + item.totalCount);

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingMedium,
        vertical: AppConstants.paddingMedium,
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _isExpanded
                ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
                : Theme.of(context).colorScheme.outline.withOpacity(0.2),
            width: _isExpanded ? 1.5 : 1,
          ),
          color: _isExpanded
              ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.05)
              : Theme.of(context).colorScheme.surface,
        ),
        child: Column(
          children: [
            // Accordion Header (clickable)
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => setState(() => _isExpanded = !_isExpanded),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: _isExpanded
                      ? BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(context)
                                  .colorScheme
                                  .primaryContainer
                                  .withOpacity(0.1),
                              Theme.of(context)
                                  .colorScheme
                                  .primaryContainer
                                  .withOpacity(0.05),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                        )
                      : null,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _isExpanded
                              ? Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.15)
                              : Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: _isExpanded
                              ? [
                                  BoxShadow(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Icon(
                          Icons.account_tree,
                          color: Theme.of(context).colorScheme.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Part of Series',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: _isExpanded
                                        ? Theme.of(context).colorScheme.primary
                                        : null,
                                  ),
                            ),
                            if (!_isExpanded) ...[
                              const SizedBox(height: 4),
                              _buildPreview(context, seriesItems, totalGames),
                            ],
                          ],
                        ),
                      ),
                      AnimatedRotation(
                        turns: _isExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          Icons.keyboard_arrow_down,
                          color: _isExpanded
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Accordion Content (expandable)
            ClipRect(
              child: AnimatedAlign(
                alignment: Alignment.topCenter,
                heightFactor: _isExpanded ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                child: Container(
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.surface.withOpacity(0.5),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                  ),
                  child: DefaultTabController(
                    length: seriesItems.length,
                    child: Column(
                      children: [
                        // Tab Bar
                        Container(
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Theme.of(context)
                                    .colorScheme
                                    .outline
                                    .withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                          ),
                          child: TabBar(
                            isScrollable: seriesItems.length > 3,
                            tabs: seriesItems
                                .map((item) => _buildTab(context, item))
                                .toList(),
                            labelColor: Theme.of(context).colorScheme.primary,
                            unselectedLabelColor:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                            indicatorColor:
                                Theme.of(context).colorScheme.primary,
                            indicatorWeight: 2,
                            labelStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                            unselectedLabelStyle: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),

                        // Tab Views
                        SizedBox(
                          height: 320,
                          child: TabBarView(
                            children: seriesItems
                                .map((item) => _buildTabView(context, item))
                                .toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Preview widget for collapsed state
  Widget _buildPreview(
      BuildContext context, List<SeriesItem> seriesItems, int totalGames) {
    // Show tab names as preview
    final tabNames = seriesItems.map((item) {
      final icon = item.type == SeriesType.collection ? '📁' : '🎮';
      return '$icon ${item.title}';
    }).toList();

    String previewText;
    if (tabNames.length <= 2) {
      previewText = tabNames.join(' • ');
    } else {
      previewText = '${tabNames.take(2).join(' • ')} • +${tabNames.length - 2}';
    }

    return Row(
      children: [
        Expanded(
          child: Text(
            previewText,
            style: TextStyle(
              fontSize: 11,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '$totalGames games',
            style: TextStyle(
              fontSize: 10,
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTab(BuildContext context, SeriesItem item) {
    return Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            item.icon,
            size: 16,
            color: item.accentColor,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              item.title,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabView(BuildContext context, SeriesItem item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Series Info Header
        Padding(
          padding: const EdgeInsets.only(
              left: AppConstants.paddingMedium,
              right: AppConstants.paddingMedium,
              top: AppConstants.paddingSmall),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: item.accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  item.icon,
                  color: item.accentColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: item.type == SeriesType.mainFranchise
                                ? FontWeight.bold
                                : FontWeight.w600,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    FittedBox(
                      child: Text(
                        '${item.type?.displayName} • ${item.totalCount} games',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: item.accentColor,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              // View All Button
              if (item.totalCount > 5)
                TextButton.icon(
                  onPressed: () => _navigateToSeries(context, item),
                  icon: Icon(Icons.arrow_forward,
                      size: 16, color: item.accentColor),
                  label: Text(
                    'View All',
                    style: TextStyle(color: item.accentColor),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: AppConstants.paddingMedium),

        // Games List (normale Größe wieder!)
        Expanded(
          child: item.games.isNotEmpty
              ? _buildGamesList(item.games)
              : _buildNoGamesPlaceholder(context),
        ),
        const SizedBox(height: AppConstants.paddingMedium),
      ],
    );
  }

  Widget _buildGamesList(List<Game> games) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.only(
        left: AppConstants.paddingMedium,
      ),
      itemCount: games.length,
      itemBuilder: (context, index) {
        final game = games[index];
        return Container(
          width: 160, // Zurück zur normalen Größe! 🎉
          margin: const EdgeInsets.only(right: AppConstants.paddingMedium),
          child: GameCard(
            game: game,
            onTap: () => Navigations.navigateToGameDetail(game.id, context),
          ),
        );
      },
    );
  }

  Widget _buildNoGamesPlaceholder(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.games,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              'Games loading...',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods to get games from franchises/collections
  List<Game> _getFranchiseGames(Franchise franchise) {
    if (franchise.games == null) return [];
    return franchise.games!.take(10).toList();
  }

  List<Game> _getCollectionGames(Collection collection) {
    if (collection.games == null) return [];
    return collection.games!.take(10).toList();
  }

  // Navigation methods
  void _navigateToSeries(BuildContext context, SeriesItem item) {
    if (item.franchise != null) {
      Navigations.navigateToFranchiseGames(context,
          franchiseId: item.franchise!.id, franchiseName: item.franchise!.name);
    } else if (item.collection != null) {
      Navigations.navigateToCollectionGames(context,
          collectionId: item.collection!.id,
          collectionName: item.collection!.name);
    } else if (item.companyId != null && item.companyName != null) {
      Navigations.navigateToCompanyGames(
        context,
        companyId: item.companyId!,
        companyName: item.companyName!,
        isDeveloper: item.isDeveloper,
        isPublisher: item.isPublisher,
      );
    }
  }
}

// Helper classes
enum SeriesType {
  mainFranchise,
  franchise,
  collection,
  eventGames;

  String get displayName {
    switch (this) {
      case SeriesType.mainFranchise:
        return 'Main Franchise';
      case SeriesType.franchise:
        return 'Franchise';
      case SeriesType.collection:
        return 'Collection';
      case SeriesType.eventGames:
        return 'Event Games';
    }
  }
}

class SeriesItem {
  final SeriesType? type;
  final String title;
  final List<Game> games;
  final int totalCount;
  final Color accentColor;
  final IconData icon;
  final Franchise? franchise;
  final Collection? collection;
  final int? companyId;
  final String? companyName;
  final bool? isDeveloper;
  final bool? isPublisher;

  SeriesItem({
    this.type,
    required this.title,
    required this.games,
    required this.totalCount,
    required this.accentColor,
    required this.icon,
    this.franchise,
    this.collection,
    this.companyId,
    this.companyName,
    this.isDeveloper,
    this.isPublisher,
  });
}
