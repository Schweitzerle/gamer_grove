import 'package:flutter/material.dart';
import 'package:gamer_grove/core/constants/app_constants.dart';
import 'package:gamer_grove/core/theme/gg_contrast.dart';
import 'package:gamer_grove/core/utils/navigations.dart';
import 'package:gamer_grove/domain/entities/game/game.dart';
import 'package:gamer_grove/presentation/widgets/game_card.dart';
import 'package:gamer_grove/presentation/widgets/sections/related_games/related_games_tab.dart';

/// A collapsible group of related games, shown as tabs over rows of covers.
///
/// The detail page has three of these — additional content, versions and
/// remakes, similar and related — and they were three copies of this widget,
/// ~450 lines each, differing only in a title, an icon, an accent, and which
/// games went into the tabs.
class RelatedGamesAccordion extends StatefulWidget {
  const RelatedGamesAccordion({
    required this.title,
    required this.icon,
    required this.accent,
    required this.tabs,
    required this.gameName,
    super.key,
  });

  final String title;
  final IconData icon;

  /// The group's colour, lifted per surface before it is ever drawn.
  final Color accent;

  final List<RelatedGamesTab> tabs;

  /// Prefixes the title of the generic "View All" list.
  final String gameName;

  /// How tall the row of covers is.
  static const _rowHeight = 320.0;

  /// How many covers fit before "View All" earns its place.
  static const _previewCount = 5;

  @override
  State<RelatedGamesAccordion> createState() => _RelatedGamesAccordionState();
}

class _RelatedGamesAccordionState extends State<RelatedGamesAccordion> {
  bool _isExpanded = false;

  /// Whether the body has ever been opened.
  ///
  /// `AnimatedAlign` clips its child, it does not skip building it, so a
  /// collapsed accordion was still building every cover it holds — up to
  /// twenty per group, sixty across the three on a game's page, none of them
  /// visible. The body is mounted on the first tap and then kept, so closing
  /// it still animates.
  bool _hasOpened = false;

  @override
  Widget build(BuildContext context) {
    if (widget.tabs.isEmpty) return const SizedBox.shrink();

    final scheme = Theme.of(context).colorScheme;
    final accent = widget.accent.legibleOn(scheme.surface, minimum: 4.5);
    final total =
        widget.tabs.fold<int>(0, (sum, tab) => sum + tab.games.length);

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingMedium,
        vertical: AppConstants.paddingMedium,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isExpanded
              ? scheme.primary.withValues(alpha: 0.3)
              : scheme.outline.withValues(alpha: 0.2),
          width: _isExpanded ? 1.5 : 1,
        ),
        color: _isExpanded
            ? scheme.primaryContainer.withValues(alpha: 0.05)
            : scheme.surface,
      ),
      child: Column(
        children: [
          _AccordionHeader(
            title: widget.title,
            icon: widget.icon,
            accent: accent,
            tabs: widget.tabs,
            totalGames: total,
            isExpanded: _isExpanded,
            onTap: () => setState(() {
              _isExpanded = !_isExpanded;
              _hasOpened |= _isExpanded;
            }),
          ),
          ClipRect(
            child: AnimatedAlign(
              alignment: Alignment.topCenter,
              heightFactor: _isExpanded ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              child: !_hasOpened
                  ? const SizedBox.shrink()
                  : DecoratedBox(
                      decoration: BoxDecoration(
                        color: scheme.surface.withValues(alpha: 0.5),
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(12),
                        ),
                      ),
                      child: DefaultTabController(
                        length: widget.tabs.length,
                        child: Column(
                          children: [
                            _TabBar(tabs: widget.tabs),
                            SizedBox(
                              height: RelatedGamesAccordion._rowHeight,
                              child: TabBarView(
                                children: [
                                  for (final tab in widget.tabs)
                                    _TabContents(
                                      tab: tab,
                                      gameName: widget.gameName,
                                    ),
                                ],
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
    );
  }
}

class _AccordionHeader extends StatelessWidget {
  const _AccordionHeader({
    required this.title,
    required this.icon,
    required this.accent,
    required this.tabs,
    required this.totalGames,
    required this.isExpanded,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final Color accent;
  final List<RelatedGamesTab> tabs;
  final int totalGames;
  final bool isExpanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Semantics(
          button: true,
          expanded: isExpanded,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: isExpanded
                ? BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        scheme.primaryContainer.withValues(alpha: 0.1),
                        scheme.primaryContainer.withValues(alpha: 0.05),
                      ],
                    ),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                  )
                : null,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: isExpanded ? 0.15 : 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: accent, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isExpanded ? scheme.primary : null,
                                ),
                      ),
                      if (!isExpanded) ...[
                        const SizedBox(height: 4),
                        _CollapsedPreview(
                          tabs: tabs,
                          totalGames: totalGames,
                          accent: accent,
                        ),
                      ],
                    ],
                  ),
                ),
                AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    color: isExpanded
                        ? scheme.primary
                        : scheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// What the group holds, for someone who has not opened it.
class _CollapsedPreview extends StatelessWidget {
  const _CollapsedPreview({
    required this.tabs,
    required this.totalGames,
    required this.accent,
  });

  final List<RelatedGamesTab> tabs;
  final int totalGames;
  final Color accent;

  /// Beyond this the line stops naming tabs and starts counting them.
  static const _namedTabs = 2;

  @override
  Widget build(BuildContext context) {
    final names = [for (final tab in tabs) '${tab.emoji} ${tab.label}'];
    final summary = names.length <= _namedTabs
        ? names.join(' • ')
        : '${names.take(_namedTabs).join(' • ')} • +${names.length - _namedTabs}';

    return Row(
      children: [
        Expanded(
          child: Text(
            summary,
            style: TextStyle(
              fontSize: 11,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.7),
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
            color: accent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '$totalGames items',
            style: TextStyle(
              fontSize: 10,
              color: accent,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _TabBar extends StatelessWidget {
  const _TabBar({required this.tabs});

  final List<RelatedGamesTab> tabs;

  /// More than this and the bar scrolls rather than squeezing.
  static const _fixedTabLimit = 3;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: scheme.outline.withValues(alpha: 0.2)),
        ),
      ),
      child: TabBar(
        isScrollable: tabs.length > _fixedTabLimit,
        labelColor: scheme.primary,
        unselectedLabelColor: scheme.onSurfaceVariant,
        indicatorColor: scheme.primary,
        tabs: [
          for (final tab in tabs)
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    tab.icon,
                    size: 16,
                    // An icon only has to clear the non-text bar.
                    color: tab.accent.legibleOn(scheme.surface),
                  ),
                  const SizedBox(width: 6),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(tab.label, maxLines: 1),
                      Text(
                        '(${tab.games.length})',
                        style: TextStyle(
                          fontSize: 10,
                          color: tab.accent
                              .legibleOn(scheme.surface, minimum: 4.5),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _TabContents extends StatelessWidget {
  const _TabContents({required this.tab, required this.gameName});

  final RelatedGamesTab tab;
  final String gameName;

  void _viewAll(BuildContext context) {
    final destination = tab.onViewAll;
    if (destination != null) {
      destination(context);
      return;
    }
    Navigations.navigateToLocalAllGames(
      context,
      title: '$gameName ${tab.heading}',
      subtitle: tab.blurb,
      games: tab.games,
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final accent = tab.accent.legibleOn(scheme.surface, minimum: 4.5);
    final shown = tab.games.take(RelatedGamesAccordion._previewCount).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: AppConstants.paddingMedium,
            right: AppConstants.paddingMedium,
            top: AppConstants.paddingSmall,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(tab.icon, color: accent, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tab.heading,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    FittedBox(
                      child: Text(
                        tab.blurb,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: accent,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              if (tab.games.length > shown.length)
                TextButton.icon(
                  onPressed: () => _viewAll(context),
                  icon: Icon(Icons.arrow_forward, size: 16, color: accent),
                  label: Text('View All', style: TextStyle(color: accent)),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppConstants.paddingMedium),
        Expanded(child: _GameRow(games: shown)),
        const SizedBox(height: AppConstants.paddingMedium),
      ],
    );
  }
}

class _GameRow extends StatelessWidget {
  const _GameRow({required this.games});

  final List<Game> games;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.only(left: AppConstants.paddingMedium),
      itemCount: games.length,
      itemBuilder: (context, index) {
        final game = games[index];
        return Container(
          width: 160,
          margin: const EdgeInsets.only(right: AppConstants.paddingMedium),
          child: GameCard(
            game: game,
            onTap: () => Navigations.navigateToGameDetail(game.id, context),
          ),
        );
      },
    );
  }
}
