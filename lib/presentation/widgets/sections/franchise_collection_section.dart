// lib/presentation/pages/game_detail/widgets/franchise_collections_section.dart
import 'package:flutter/material.dart';
import 'package:gamer_grove/presentation/widgets/game_card.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/navigations.dart';
import '../../../../domain/entities/game/game.dart';
import '../../../../domain/entities/franchise.dart';
import '../../../../domain/entities/collection/collection.dart';

class FranchiseCollectionsSection extends StatelessWidget {
  final Game game;

  const FranchiseCollectionsSection({
    super.key,
    required this.game,
  });

  @override
  Widget build(BuildContext context) {
    // Collect all series data
    final seriesItems = <SeriesItem>[];

    // Add Main Franchise first (if exists)
    if (game.mainFranchise != null && game.mainFranchise!.hasGames) {
      seriesItems.add(SeriesItem(
        type: SeriesType.mainFranchise,
        title: game.mainFranchise!.name,
        games: _getFranchiseGames(game.mainFranchise!),
        totalCount: game.mainFranchise!.gameCount,
        franchise: game.mainFranchise,
        accentColor: Colors.orange,
        icon: Icons.stars,
      ));
    }

    // Add Other Franchises
    for (final franchise in game.franchises) {
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
    for (final collection in game.collections) {
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

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingMedium,
        vertical: AppConstants.paddingMedium,
      ),
      child: Card(
        elevation: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Header
            _buildSectionHeader(context),

            // Individual Tabs for each Series
            DefaultTabController(
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
                      isScrollable: seriesItems.length >
                          3, // Scrollable if more than 3 tabs
                      tabs: seriesItems
                          .map((item) => _buildTab(context, item))
                          .toList(),
                      labelColor: Theme.of(context).colorScheme.primary,
                      unselectedLabelColor:
                          Theme.of(context).colorScheme.onSurfaceVariant,
                      indicatorColor: Theme.of(context).colorScheme.primary,
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
                    height:
                        320, // Etwas mehr Platz für Header + normale GameCard
                    child: TabBarView(
                      children: seriesItems
                          .map((item) => _buildTabView(context, item))
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.account_tree,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Part of Series',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
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
