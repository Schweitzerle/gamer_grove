// ==========================================
// GROUPED RELATED GAMES SECTIONS
// ==========================================

// 1. CONTENT & DLCS SECTION
// lib/presentation/pages/game_detail/widgets/content_dlc_section.dart
import 'package:flutter/material.dart';
import 'package:gamer_grove/presentation/widgets/game_card.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/navigations.dart';
import '../../../../domain/entities/game/game.dart';

class ContentDLCSection extends StatelessWidget {
  final Game game;

  const ContentDLCSection({
    super.key,
    required this.game,
  });

  @override
  Widget build(BuildContext context) {
    final contentTabs = _buildContentTabs();

    if (contentTabs.isEmpty) {
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
            _buildSectionHeader(context),
            DefaultTabController(
              length: contentTabs.length,
              child: Column(
                children: [
                  _buildTabBar(context, contentTabs),
                  SizedBox(
                    height: 380,
                    child: TabBarView(
                      children: contentTabs.map((tab) => _buildTabView(context, tab)).toList(),
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
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.extension,
              color: Colors.green,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Additional Content',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  List<ContentTab> _buildContentTabs() {
    final tabs = <ContentTab>[];

    // DLCs Tab
    if (game.dlcs.isNotEmpty) {
      tabs.add(ContentTab(
        type: ContentType.dlc,
        title: 'DLCs',
        games: game.dlcs,
        icon: Icons.download,
        color: Colors.green,
      ));
    }

    // Expansions Tab
    if (game.expansions.isNotEmpty) {
      tabs.add(ContentTab(
        type: ContentType.expansion,
        title: 'Expansions',
        games: game.expansions,
        icon: Icons.expand_more,
        color: Colors.teal,
      ));
    }

    // Standalone Expansions Tab
    if (game.standaloneExpansions.isNotEmpty) {
      tabs.add(ContentTab(
        type: ContentType.standaloneExpansion,
        title: 'Standalone',
        games: game.standaloneExpansions,
        icon: Icons.launch,
        color: Colors.indigo,
      ));
    }

    // Bundles Tab
    if (game.bundles.isNotEmpty) {
      tabs.add(ContentTab(
        type: ContentType.bundle,
        title: 'Bundles',
        games: game.bundles,
        icon: Icons.inventory,
        color: Colors.orange,
      ));
    }

    return tabs;
  }

  Widget _buildTabBar(BuildContext context, List<ContentTab> tabs) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: TabBar(
        isScrollable: tabs.length > 3,
        tabs: tabs.map((tab) => Tab(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(tab.icon, size: 16, color: tab.color),
              const SizedBox(width: 6),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(tab.title, maxLines: 1),
                  Text('(${tab.games.length})',
                      style: TextStyle(fontSize: 10, color: tab.color)),
                ],
              ),
            ],
          ),
        )).toList(),
        labelColor: Theme.of(context).colorScheme.primary,
        unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
        indicatorColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildTabView(BuildContext context, ContentTab tab) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTabHeader(context, tab),
          const SizedBox(height: AppConstants.paddingMedium),
          Expanded(child: _buildGamesList(tab.games)),
        ],
      ),
    );
  }

  Widget _buildTabHeader(BuildContext context, ContentTab tab) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: tab.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(tab.icon, color: tab.color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tab.displayTitle,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                tab.subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: tab.color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        if (tab.games.length > 5)
          TextButton.icon(
            onPressed: () => _navigateToContent(context, tab),
            icon: Icon(Icons.arrow_forward, size: 16, color: tab.color),
            label: Text('View All', style: TextStyle(color: tab.color)),
          ),
      ],
    );
  }

  Widget _buildGamesList(List<Game> games) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.zero,
      itemCount: games.take(5).length,
      itemBuilder: (context, index) {
        final game = games[index];
        return Container(
          width: 160,
          margin: const EdgeInsets.only(right: AppConstants.paddingSmall),
          child: GameCard(
            game: game,
            onTap: () => Navigations.navigateToGameDetail(game.id, context),
            blurRated: true,
          ),
        );
      },
    );
  }

  void _navigateToContent(BuildContext context, ContentTab tab) {
    switch (tab.type) {
      case ContentType.dlc:
        Navigations.navigateToGameDLCs(context, game.name, tab.games);
        break;
      case ContentType.expansion:
        Navigations.navigateToGameExpansions(context, game.name, tab.games);
        break;
      default:
        Navigations.navigateToLocalAllGames(
          context,
          title: '${game.name} ${tab.displayTitle}',
          subtitle: tab.subtitle,
          games: tab.games,
          blurRated: true,
        );
        break;
    }
  }
}

// ==========================================
// 2. VERSIONS & REMAKES SECTION
// ==========================================

class VersionsRemakesSection extends StatelessWidget {
  final Game game;

  const VersionsRemakesSection({
    super.key,
    required this.game,
  });

  @override
  Widget build(BuildContext context) {
    final versionTabs = _buildVersionTabs();

    if (versionTabs.isEmpty) {
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
            _buildSectionHeader(context),
            DefaultTabController(
              length: versionTabs.length,
              child: Column(
                children: [
                  _buildTabBar(context, versionTabs),
                  SizedBox(
                    height: 380,
                    child: TabBarView(
                      children: versionTabs.map((tab) => _buildTabView(context, tab)).toList(),
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
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.auto_fix_high,
              color: Colors.blue,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Versions & Remakes',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  List<VersionTab> _buildVersionTabs() {
    final tabs = <VersionTab>[];

    // Remakes Tab
    if (game.remakes.isNotEmpty) {
      tabs.add(VersionTab(
        type: VersionType.remake,
        title: 'Remakes',
        games: game.remakes,
        icon: Icons.refresh,
        color: Colors.teal,
      ));
    }

    // Remasters Tab
    if (game.remasters.isNotEmpty) {
      tabs.add(VersionTab(
        type: VersionType.remaster,
        title: 'Remasters',
        games: game.remasters,
        icon: Icons.auto_fix_high,
        color: Colors.cyan,
      ));
    }

    // Ports Tab
    if (game.ports.isNotEmpty) {
      tabs.add(VersionTab(
        type: VersionType.port,
        title: 'Ports',
        games: game.ports,
        icon: Icons.devices,
        color: Colors.brown,
      ));
    }

    // Expanded Games Tab
    if (game.expandedGames.isNotEmpty) {
      tabs.add(VersionTab(
        type: VersionType.expandedGame,
        title: 'Expanded',
        games: game.expandedGames,
        icon: Icons.zoom_out_map,
        color: Colors.deepOrange,
      ));
    }

    // Version Parent (falls aktuelles Spiel eine Version ist)
    if (game.versionParent != null) {
      tabs.add(VersionTab(
        type: VersionType.versionParent,
        title: 'Original',
        games: [game.versionParent!],
        icon: Icons.source,
        color: Colors.indigo,
      ));
    }

    return tabs;
  }

  // Similar implementation like ContentDLCSection...
  Widget _buildTabBar(BuildContext context, List<VersionTab> tabs) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: TabBar(
        isScrollable: tabs.length > 3,
        tabs: tabs.map((tab) => Tab(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(tab.icon, size: 16, color: tab.color),
              const SizedBox(width: 6),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(tab.title, maxLines: 1),
                  Text('(${tab.games.length})',
                      style: TextStyle(fontSize: 10, color: tab.color)),
                ],
              ),
            ],
          ),
        )).toList(),
        labelColor: Theme.of(context).colorScheme.primary,
        unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
        indicatorColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildTabView(BuildContext context, VersionTab tab) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTabHeader(context, tab),
          const SizedBox(height: AppConstants.paddingMedium),
          Expanded(child: _buildGamesList(tab.games)),
        ],
      ),
    );
  }

  Widget _buildTabHeader(BuildContext context, VersionTab tab) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: tab.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(tab.icon, color: tab.color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tab.displayTitle,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                tab.subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: tab.color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        if (tab.games.length > 5)
          TextButton.icon(
            onPressed: () => _navigateToVersions(context, tab),
            icon: Icon(Icons.arrow_forward, size: 16, color: tab.color),
            label: Text('View All', style: TextStyle(color: tab.color)),
          ),
      ],
    );
  }

  Widget _buildGamesList(List<Game> games) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.zero,
      itemCount: games.take(5).length,
      itemBuilder: (context, index) {
        final game = games[index];
        return Container(
          width: 160,
          margin: const EdgeInsets.only(right: AppConstants.paddingSmall),
          child: GameCard(
            game: game,
            onTap: () => Navigations.navigateToGameDetail(game.id, context),
            blurRated: true,
          ),
        );
      },
    );
  }

  void _navigateToVersions(BuildContext context, VersionTab tab) {
    Navigations.navigateToLocalAllGames(
      context,
      title: '${game.name} ${tab.displayTitle}',
      subtitle: tab.subtitle,
      games: tab.games,
      blurRated: true,
    );
  }
}

// ==========================================
// 3. SIMILAR & RELATED SECTION
// ==========================================

class SimilarRelatedSection extends StatelessWidget {
  final Game game;

  const SimilarRelatedSection({
    super.key,
    required this.game,
  });

  @override
  Widget build(BuildContext context) {
    final relatedTabs = _buildRelatedTabs();

    if (relatedTabs.isEmpty) {
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
            _buildSectionHeader(context),
            DefaultTabController(
              length: relatedTabs.length,
              child: Column(
                children: [
                  _buildTabBar(context, relatedTabs),
                  SizedBox(
                    height: 380,
                    child: TabBarView(
                      children: relatedTabs.map((tab) => _buildTabView(context, tab)).toList(),
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
              color: Colors.purple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.lightbulb_outline,
              color: Colors.purple,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Similar & Related',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  List<RelatedTab> _buildRelatedTabs() {
    final tabs = <RelatedTab>[];

    // Similar Games Tab (most important)
    if (game.similarGames.isNotEmpty) {
      tabs.add(RelatedTab(
        type: RelatedType.similar,
        title: 'Similar',
        games: game.similarGames,
        icon: Icons.lightbulb_outline,
        color: Colors.blue,
      ));
    }

    // Forks Tab
    if (game.forks.isNotEmpty) {
      tabs.add(RelatedTab(
        type: RelatedType.fork,
        title: 'Forks',
        games: game.forks,
        icon: Icons.call_split,
        color: Colors.red,
      ));
    }

    // Parent Game (falls aktuelles Spiel ein DLC/Expansion ist)
    if (game.parentGame != null) {
      tabs.add(RelatedTab(
        type: RelatedType.parentGame,
        title: 'Main Game',
        games: [game.parentGame!],
        icon: Icons.home,
        color: Colors.green,
      ));
    }

    return tabs;
  }

  // Similar implementation...
  Widget _buildTabBar(BuildContext context, List<RelatedTab> tabs) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: TabBar(
        isScrollable: tabs.length > 3,
        tabs: tabs.map((tab) => Tab(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(tab.icon, size: 16, color: tab.color),
              const SizedBox(width: 6),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(tab.title, maxLines: 1),
                  Text('(${tab.games.length})',
                      style: TextStyle(fontSize: 10, color: tab.color)),
                ],
              ),
            ],
          ),
        )).toList(),
        labelColor: Theme.of(context).colorScheme.primary,
        unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
        indicatorColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildTabView(BuildContext context, RelatedTab tab) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTabHeader(context, tab),
          const SizedBox(height: AppConstants.paddingMedium),
          Expanded(child: _buildGamesList(tab.games)),
        ],
      ),
    );
  }

  Widget _buildTabHeader(BuildContext context, RelatedTab tab) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: tab.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(tab.icon, color: tab.color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tab.displayTitle,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                tab.subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: tab.color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        if (tab.games.length > 5)
          TextButton.icon(
            onPressed: () => _navigateToRelated(context, tab),
            icon: Icon(Icons.arrow_forward, size: 16, color: tab.color),
            label: Text('View All', style: TextStyle(color: tab.color)),
          ),
      ],
    );
  }

  Widget _buildGamesList(List<Game> games) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.zero,
      itemCount: games.take(5).length,
      itemBuilder: (context, index) {
        final game = games[index];
        return Container(
          width: 160,
          margin: const EdgeInsets.only(right: AppConstants.paddingSmall),
          child: GameCard(
            game: game,
            onTap: () => Navigations.navigateToGameDetail(game.id, context),
            blurRated: true,
          ),
        );
      },
    );
  }

  void _navigateToRelated(BuildContext context, RelatedTab tab) {
    if (tab.type == RelatedType.similar) {
      Navigations.navigateToSimilarGames(context, game.name, tab.games);
    } else {
      Navigations.navigateToLocalAllGames(
        context,
        title: '${game.name} ${tab.displayTitle}',
        subtitle: tab.subtitle,
        games: tab.games,
        blurRated: true,
      );
    }
  }
}

// ==========================================
// HELPER CLASSES
// ==========================================

enum ContentType { dlc, expansion, standaloneExpansion, bundle }
enum VersionType { remake, remaster, port, expandedGame, versionParent }
enum RelatedType { similar, fork, parentGame }

class ContentTab {
  final ContentType type;
  final String title;
  final List<Game> games;
  final IconData icon;
  final Color color;

  ContentTab({
    required this.type,
    required this.title,
    required this.games,
    required this.icon,
    required this.color,
  });

  String get displayTitle {
    switch (type) {
      case ContentType.dlc: return 'Downloadable Content';
      case ContentType.expansion: return 'Expansions';
      case ContentType.standaloneExpansion: return 'Standalone Expansions';
      case ContentType.bundle: return 'Game Bundles';
    }
  }

  String get subtitle {
    switch (type) {
      case ContentType.dlc: return 'Additional content • ${games.length} DLCs';
      case ContentType.expansion: return 'Game expansions • ${games.length} expansions';
      case ContentType.standaloneExpansion: return 'Standalone content • ${games.length} games';
      case ContentType.bundle: return 'Game collections • ${games.length} bundles';
    }
  }
}

class VersionTab {
  final VersionType type;
  final String title;
  final List<Game> games;
  final IconData icon;
  final Color color;

  VersionTab({
    required this.type,
    required this.title,
    required this.games,
    required this.icon,
    required this.color,
  });

  String get displayTitle {
    switch (type) {
      case VersionType.remake: return 'Remakes';
      case VersionType.remaster: return 'Remasters';
      case VersionType.port: return 'Platform Ports';
      case VersionType.expandedGame: return 'Expanded Games';
      case VersionType.versionParent: return 'Original Version';
    }
  }

  String get subtitle {
    switch (type) {
      case VersionType.remake: return 'Remade versions • ${games.length} remakes';
      case VersionType.remaster: return 'Enhanced versions • ${games.length} remasters';
      case VersionType.port: return 'Platform versions • ${games.length} ports';
      case VersionType.expandedGame: return 'Enhanced editions • ${games.length} games';
      case VersionType.versionParent: return 'Original version • ${games.length} game';
    }
  }
}

class RelatedTab {
  final RelatedType type;
  final String title;
  final List<Game> games;
  final IconData icon;
  final Color color;

  RelatedTab({
    required this.type,
    required this.title,
    required this.games,
    required this.icon,
    required this.color,
  });

  String get displayTitle {
    switch (type) {
      case RelatedType.similar: return 'Similar Games';
      case RelatedType.fork: return 'Game Forks';
      case RelatedType.parentGame: return 'Main Game';
    }
  }

  String get subtitle {
    switch (type) {
      case RelatedType.similar: return 'Games you might like • ${games.length} games';
      case RelatedType.fork: return 'Alternative versions • ${games.length} forks';
      case RelatedType.parentGame: return 'Base game • ${games.length} game';
    }
  }
}