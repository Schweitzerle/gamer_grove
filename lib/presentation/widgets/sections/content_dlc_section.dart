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

class ContentDLCSection extends StatefulWidget {
  final Game game;

  const ContentDLCSection({
    super.key,
    required this.game,
  });

  @override
  State<ContentDLCSection> createState() => _ContentDLCSectionState();
}

class _ContentDLCSectionState extends State<ContentDLCSection> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final contentTabs = _buildContentTabs();

    if (contentTabs.isEmpty) {
      return const SizedBox.shrink();
    }

    // Calculate totals for preview
    final totalGames =
        contentTabs.fold<int>(0, (sum, tab) => sum + tab.games.length);

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
                              ? Colors.green.withOpacity(0.15)
                              : Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: _isExpanded
                              ? [
                                  BoxShadow(
                                    color: Colors.green.withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: const Icon(
                          Icons.extension,
                          color: Colors.green,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Additional Content',
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
                              _buildPreview(context, contentTabs, totalGames),
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
                    length: contentTabs.length,
                    child: Column(
                      children: [
                        _buildTabBar(context, contentTabs),
                        SizedBox(
                          height: 320,
                          child: TabBarView(
                            children: contentTabs
                                .map((tab) => _buildTabView(context, tab))
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
      BuildContext context, List<ContentTab> contentTabs, int totalGames) {
    final tabNames = contentTabs.map((tab) {
      String icon;
      switch (tab.type) {
        case ContentType.dlc:
          icon = '⬇️';
          break;
        case ContentType.expansion:
          icon = '📦';
          break;
        case ContentType.standaloneExpansion:
          icon = '🚀';
          break;
        case ContentType.bundle:
          icon = '📋';
          break;
      }
      return '$icon ${tab.title}';
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
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '$totalGames items',
            style: const TextStyle(
              fontSize: 10,
              color: Colors.green,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  List<ContentTab> _buildContentTabs() {
    final tabs = <ContentTab>[];

    // DLCs Tab
    if (widget.game.dlcs.isNotEmpty) {
      tabs.add(ContentTab(
        type: ContentType.dlc,
        title: 'DLCs',
        games: widget.game.dlcs,
        icon: Icons.download,
        color: Colors.green,
      ));
    }

    // Expansions Tab
    if (widget.game.expansions.isNotEmpty) {
      tabs.add(ContentTab(
        type: ContentType.expansion,
        title: 'Expansions',
        games: widget.game.expansions,
        icon: Icons.expand_more,
        color: Colors.teal,
      ));
    }

    // Standalone Expansions Tab
    if (widget.game.standaloneExpansions.isNotEmpty) {
      tabs.add(ContentTab(
        type: ContentType.standaloneExpansion,
        title: 'Standalone',
        games: widget.game.standaloneExpansions,
        icon: Icons.launch,
        color: Colors.indigo,
      ));
    }

    // Bundles Tab
    if (widget.game.bundles.isNotEmpty) {
      tabs.add(ContentTab(
        type: ContentType.bundle,
        title: 'Bundles',
        games: widget.game.bundles,
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
        tabs: tabs
            .map((tab) => Tab(
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
                ))
            .toList(),
        labelColor: Theme.of(context).colorScheme.primary,
        unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
        indicatorColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildTabView(BuildContext context, ContentTab tab) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTabHeader(context, tab),
        const SizedBox(height: AppConstants.paddingMedium),
        Expanded(child: _buildGamesList(tab.games)),
        const SizedBox(height: AppConstants.paddingMedium),
      ],
    );
  }

  Widget _buildTabHeader(BuildContext context, ContentTab tab) {
    return Padding(
      padding: const EdgeInsets.only(
          left: AppConstants.paddingMedium,
          right: AppConstants.paddingMedium,
          top: AppConstants.paddingSmall),
      child: Row(
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
                FittedBox(
                  child: Text(
                    tab.subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: tab.color,
                          fontWeight: FontWeight.w500,
                        ),
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
      ),
    );
  }

  Widget _buildGamesList(List<Game> games) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.only(
        left: AppConstants.paddingMedium,
      ),
      itemCount: games.take(5).length,
      itemBuilder: (context, index) {
        final game = games[index];
        return Container(
          width: 160,
          margin: const EdgeInsets.only(right: AppConstants.paddingMedium),
          child: GameCard(
            game: game,
            onTap: () => Navigations.navigateToGameDetail(game.id, context),
            blurRated: false,
          ),
        );
      },
    );
  }

  void _navigateToContent(BuildContext context, ContentTab tab) {
    switch (tab.type) {
      case ContentType.dlc:
        Navigations.navigateToGameDLCs(context, widget.game.name, tab.games);
        break;
      case ContentType.expansion:
        Navigations.navigateToGameExpansions(
            context, widget.game.name, tab.games);
        break;
      default:
        Navigations.navigateToLocalAllGames(
          context,
          title: '${widget.game.name} ${tab.displayTitle}',
          subtitle: tab.subtitle,
          games: tab.games,
          blurRated: false,
        );
        break;
    }
  }
}

// ==========================================
// 2. VERSIONS & REMAKES SECTION
// ==========================================

class VersionsRemakesSection extends StatefulWidget {
  final Game game;

  const VersionsRemakesSection({
    super.key,
    required this.game,
  });

  @override
  State<VersionsRemakesSection> createState() => _VersionsRemakesSectionState();
}

class _VersionsRemakesSectionState extends State<VersionsRemakesSection> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final versionTabs = _buildVersionTabs();

    if (versionTabs.isEmpty) {
      return const SizedBox.shrink();
    }

    // Calculate totals for preview
    final totalGames =
        versionTabs.fold<int>(0, (sum, tab) => sum + tab.games.length);

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
                              ? Colors.blue.withOpacity(0.15)
                              : Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: _isExpanded
                              ? [
                                  BoxShadow(
                                    color: Colors.blue.withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: const Icon(
                          Icons.auto_fix_high,
                          color: Colors.blue,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Versions & Remakes',
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
                              _buildPreview(context, versionTabs, totalGames),
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
                    length: versionTabs.length,
                    child: Column(
                      children: [
                        _buildTabBar(context, versionTabs),
                        SizedBox(
                          height: 320,
                          child: TabBarView(
                            children: versionTabs
                                .map((tab) => _buildTabView(context, tab))
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
      BuildContext context, List<VersionTab> versionTabs, int totalGames) {
    final tabNames = versionTabs.map((tab) {
      String icon;
      switch (tab.type) {
        case VersionType.remake:
          icon = '🔄';
          break;
        case VersionType.remaster:
          icon = '✨';
          break;
        case VersionType.port:
          icon = '📱';
          break;
        case VersionType.expandedGame:
          icon = '🔍';
          break;
        case VersionType.versionParent:
          icon = '📜';
          break;
      }
      return '$icon ${tab.title}';
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
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '$totalGames versions',
            style: const TextStyle(
              fontSize: 10,
              color: Colors.blue,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  List<VersionTab> _buildVersionTabs() {
    final tabs = <VersionTab>[];

    // Remakes Tab
    if (widget.game.remakes.isNotEmpty) {
      tabs.add(VersionTab(
        type: VersionType.remake,
        title: 'Remakes',
        games: widget.game.remakes,
        icon: Icons.refresh,
        color: Colors.teal,
      ));
    }

    // Remasters Tab
    if (widget.game.remasters.isNotEmpty) {
      tabs.add(VersionTab(
        type: VersionType.remaster,
        title: 'Remasters',
        games: widget.game.remasters,
        icon: Icons.auto_fix_high,
        color: Colors.cyan,
      ));
    }

    // Ports Tab
    if (widget.game.ports.isNotEmpty) {
      tabs.add(VersionTab(
        type: VersionType.port,
        title: 'Ports',
        games: widget.game.ports,
        icon: Icons.devices,
        color: Colors.brown,
      ));
    }

    // Expanded Games Tab
    if (widget.game.expandedGames.isNotEmpty) {
      tabs.add(VersionTab(
        type: VersionType.expandedGame,
        title: 'Expanded',
        games: widget.game.expandedGames,
        icon: Icons.zoom_out_map,
        color: Colors.deepOrange,
      ));
    }

    // Version Parent (falls aktuelles Spiel eine Version ist)
    if (widget.game.versionParent != null) {
      tabs.add(VersionTab(
        type: VersionType.versionParent,
        title: 'Original',
        games: [widget.game.versionParent!],
        icon: Icons.source,
        color: Colors.indigo,
      ));
    }

    return tabs;
  }

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
        tabs: tabs
            .map((tab) => Tab(
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
                ))
            .toList(),
        labelColor: Theme.of(context).colorScheme.primary,
        unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
        indicatorColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildTabView(BuildContext context, VersionTab tab) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTabHeader(context, tab),
        const SizedBox(height: AppConstants.paddingMedium),
        Expanded(child: _buildGamesList(tab.games)),
        const SizedBox(height: AppConstants.paddingMedium),
      ],
    );
  }

  Widget _buildTabHeader(BuildContext context, VersionTab tab) {
    return Padding(
      padding: const EdgeInsets.only(
          left: AppConstants.paddingMedium,
          right: AppConstants.paddingMedium,
          top: AppConstants.paddingSmall),
      child: Row(
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
                FittedBox(
                  child: Text(
                    tab.subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: tab.color,
                          fontWeight: FontWeight.w500,
                        ),
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
      ),
    );
  }

  Widget _buildGamesList(List<Game> games) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.only(
        left: AppConstants.paddingMedium,
      ),
      itemCount: games.take(5).length,
      itemBuilder: (context, index) {
        final game = games[index];
        return Container(
          width: 160,
          margin: const EdgeInsets.only(right: AppConstants.paddingMedium),
          child: GameCard(
            game: game,
            onTap: () => Navigations.navigateToGameDetail(game.id, context),
            blurRated: false,
          ),
        );
      },
    );
  }

  void _navigateToVersions(BuildContext context, VersionTab tab) {
    Navigations.navigateToLocalAllGames(
      context,
      title: '${widget.game.name} ${tab.displayTitle}',
      subtitle: tab.subtitle,
      games: tab.games,
      blurRated: false,
    );
  }
}

// ==========================================
// 3. SIMILAR & RELATED SECTION
// ==========================================

class SimilarRelatedSection extends StatefulWidget {
  final Game game;

  const SimilarRelatedSection({
    super.key,
    required this.game,
  });

  @override
  State<SimilarRelatedSection> createState() => _SimilarRelatedSectionState();
}

class _SimilarRelatedSectionState extends State<SimilarRelatedSection> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final relatedTabs = _buildRelatedTabs();

    if (relatedTabs.isEmpty) {
      return const SizedBox.shrink();
    }

    // Calculate totals for preview
    final totalGames =
        relatedTabs.fold<int>(0, (sum, tab) => sum + tab.games.length);

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
                              ? Colors.purple.withOpacity(0.15)
                              : Colors.purple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: _isExpanded
                              ? [
                                  BoxShadow(
                                    color: Colors.purple.withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: const Icon(
                          Icons.lightbulb_outline,
                          color: Colors.purple,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Similar & Related',
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
                              _buildPreview(context, relatedTabs, totalGames),
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
                    length: relatedTabs.length,
                    child: Column(
                      children: [
                        _buildTabBar(context, relatedTabs),
                        SizedBox(
                          height: 320,
                          child: TabBarView(
                            children: relatedTabs
                                .map((tab) => _buildTabView(context, tab))
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
      BuildContext context, List<RelatedTab> relatedTabs, int totalGames) {
    final tabNames = relatedTabs.map((tab) {
      String icon;
      switch (tab.type) {
        case RelatedType.similar:
          icon = '💡';
          break;
        case RelatedType.fork:
          icon = '🔀';
          break;
        case RelatedType.parentGame:
          icon = '🏠';
          break;
      }
      return '$icon ${tab.title}';
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
            color: Colors.purple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '$totalGames games',
            style: const TextStyle(
              fontSize: 10,
              color: Colors.purple,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  List<RelatedTab> _buildRelatedTabs() {
    final tabs = <RelatedTab>[];

    // Similar Games Tab (most important)
    if (widget.game.similarGames.isNotEmpty) {
      tabs.add(RelatedTab(
        type: RelatedType.similar,
        title: 'Similar',
        games: widget.game.similarGames,
        icon: Icons.lightbulb_outline,
        color: Colors.blue,
      ));
    }

    // Forks Tab
    if (widget.game.forks.isNotEmpty) {
      tabs.add(RelatedTab(
        type: RelatedType.fork,
        title: 'Forks',
        games: widget.game.forks,
        icon: Icons.call_split,
        color: Colors.red,
      ));
    }

    // Parent Game (falls aktuelles Spiel ein DLC/Expansion ist)
    if (widget.game.parentGame != null) {
      tabs.add(RelatedTab(
        type: RelatedType.parentGame,
        title: 'Main Game',
        games: [widget.game.parentGame!],
        icon: Icons.home,
        color: Colors.green,
      ));
    }

    return tabs;
  }

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
        tabs: tabs
            .map((tab) => Tab(
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
                ))
            .toList(),
        labelColor: Theme.of(context).colorScheme.primary,
        unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
        indicatorColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildTabView(BuildContext context, RelatedTab tab) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTabHeader(context, tab),
        const SizedBox(height: AppConstants.paddingMedium),
        Expanded(child: _buildGamesList(tab.games)),
        const SizedBox(height: AppConstants.paddingMedium),
      ],
    );
  }

  Widget _buildTabHeader(BuildContext context, RelatedTab tab) {
    return Padding(
      padding: const EdgeInsets.only(
          left: AppConstants.paddingMedium,
          right: AppConstants.paddingMedium,
          top: AppConstants.paddingSmall),
      child: Row(
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
                FittedBox(
                  child: Text(
                    tab.subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: tab.color,
                          fontWeight: FontWeight.w500,
                        ),
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
      ),
    );
  }

  Widget _buildGamesList(List<Game> games) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.only(
        left: AppConstants.paddingMedium,
      ),
      itemCount: games.take(5).length,
      itemBuilder: (context, index) {
        final game = games[index];
        return Container(
          width: 160,
          margin: const EdgeInsets.only(right: AppConstants.paddingMedium),
          child: GameCard(
            game: game,
            onTap: () => Navigations.navigateToGameDetail(game.id, context),
            blurRated: false,
          ),
        );
      },
    );
  }

  void _navigateToRelated(BuildContext context, RelatedTab tab) {
    if (tab.type == RelatedType.similar) {
      Navigations.navigateToSimilarGames(context, widget.game.name, tab.games);
    } else {
      Navigations.navigateToLocalAllGames(
        context,
        title: '${widget.game.name} ${tab.displayTitle}',
        subtitle: tab.subtitle,
        games: tab.games,
        blurRated: false,
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
      case ContentType.dlc:
        return 'Downloadable Content';
      case ContentType.expansion:
        return 'Expansions';
      case ContentType.standaloneExpansion:
        return 'Standalone Expansions';
      case ContentType.bundle:
        return 'Game Bundles';
    }
  }

  String get subtitle {
    switch (type) {
      case ContentType.dlc:
        return 'Additional content • ${games.length} DLCs';
      case ContentType.expansion:
        return 'Game expansions • ${games.length} expansions';
      case ContentType.standaloneExpansion:
        return 'Standalone content • ${games.length} games';
      case ContentType.bundle:
        return 'Game collections • ${games.length} bundles';
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
      case VersionType.remake:
        return 'Remakes';
      case VersionType.remaster:
        return 'Remasters';
      case VersionType.port:
        return 'Platform Ports';
      case VersionType.expandedGame:
        return 'Expanded Games';
      case VersionType.versionParent:
        return 'Original Version';
    }
  }

  String get subtitle {
    switch (type) {
      case VersionType.remake:
        return 'Remade versions • ${games.length} remakes';
      case VersionType.remaster:
        return 'Enhanced versions • ${games.length} remasters';
      case VersionType.port:
        return 'Platform versions • ${games.length} ports';
      case VersionType.expandedGame:
        return 'Enhanced editions • ${games.length} games';
      case VersionType.versionParent:
        return 'Original version • ${games.length} game';
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
      case RelatedType.similar:
        return 'Similar Games';
      case RelatedType.fork:
        return 'Game Forks';
      case RelatedType.parentGame:
        return 'Main Game';
    }
  }

  String get subtitle {
    switch (type) {
      case RelatedType.similar:
        return 'Games you might like • ${games.length} games';
      case RelatedType.fork:
        return 'Alternative versions • ${games.length} forks';
      case RelatedType.parentGame:
        return 'Base game • ${games.length} game';
    }
  }
}
