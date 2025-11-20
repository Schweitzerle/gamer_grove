// ==================================================
// PLATFORM DETAIL SCREEN (ÜBERARBEITET)
// ==================================================

// lib/presentation/pages/platform_detail/platform_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gamer_grove/domain/entities/platform/platform.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/cached_image_widget.dart';
import '../../../domain/entities/game/game.dart';
import '../../widgets/accordion_tile.dart';
import '../../widgets/game_card.dart';
import '../../../core/utils/navigations.dart';
import '../../widgets/sections/franchise_collection_section.dart';

class PlatformDetailScreen extends StatefulWidget {
  final Platform platform;
  final List<Game> games;

  const PlatformDetailScreen({
    super.key,
    required this.platform,
    required this.games,
  });

  @override
  State<PlatformDetailScreen> createState() => _PlatformDetailScreenState();
}

class _PlatformDetailScreenState extends State<PlatformDetailScreen> {
  late ScrollController _scrollController;
  bool _isHeaderCollapsed = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    _logPlatformData();
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      final isCollapsed = _scrollController.offset > 200;
      if (isCollapsed != _isHeaderCollapsed) {
        setState(() {
          _isHeaderCollapsed = isCollapsed;
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  SeriesItem _createPlatformGamesSeriesItem() {
    return SeriesItem(
      type: SeriesType.eventGames,
      title: '${widget.platform.name} - Games Library',
      games: _getPlatformGames(),
      totalCount: widget.games.length,
      accentColor: _getPlatformAccentColor(),
      icon: Icons.videogame_asset,
      franchise: null,
      collection: null,
    );
  }

  Color _getPlatformAccentColor() {
    // Verschiedene Farben basierend auf Platform-Kategorie oder Name
    final platformName = widget.platform.name.toLowerCase();
    if (platformName.contains('playstation') || platformName.contains('ps')) {
      return Colors.blue;
    } else if (platformName.contains('xbox')) {
      return Colors.green;
    } else if (platformName.contains('nintendo') ||
        platformName.contains('switch')) {
      return Colors.red;
    } else if (platformName.contains('pc') || platformName.contains('steam')) {
      return Colors.purple;
    }
    return Theme.of(context).colorScheme.primary;
  }

  List<Game> _getPlatformGames() {
    if (widget.games.isEmpty) return [];
    return widget.games.take(10).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Platform Hero Section
          _buildSliverAppBar(),
          // Platform Content
          _buildPlatformContent(),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 350,
      pinned: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Hero Image
            _buildHeroImage(),
            // Gradient Overlays
            _buildGradientOverlays(),
            // Floating Platform Card
            _buildFloatingPlatformCard(),
          ],
        ),
        title: _isHeaderCollapsed
            ? Text(
                widget.platform.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            : null,
      ),
    );
  }

  Widget _buildHeroImage() {
    return Hero(
      tag: 'platform_hero_${widget.platform.id}',
      child: widget.platform.hasLogo
          ? CachedImageWidget(
              imageUrl: widget.platform.logo!.logoMed2xUrl,
              fit: BoxFit.cover,
              placeholder: _buildFallbackHero(),
            )
          : _buildFallbackHero(),
    );
  }

  Widget _buildFallbackHero() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getPlatformAccentColor().withOpacity(0.8),
            _getPlatformAccentColor().withOpacity(0.6),
            _getPlatformAccentColor().withOpacity(0.4),
          ],
        ),
      ),
    );
  }

  Widget _buildGradientOverlays() {
    return Stack(
      children: [
        // Horizontal Gradient
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              stops: const [0.0, 0.05, 0.95, 1.0],
              colors: [
                Theme.of(context).colorScheme.surface,
                Theme.of(context).colorScheme.surface.withValues(alpha: .2),
                Theme.of(context).colorScheme.surface.withValues(alpha: .2),
                Theme.of(context).colorScheme.surface,
              ],
            ),
          ),
        ),
        // Vertical Gradient
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0.0, 0.05, 0.8, 1.0],
              colors: [
                Theme.of(context).colorScheme.surface,
                Theme.of(context).colorScheme.surface.withValues(alpha: .2),
                Theme.of(context).colorScheme.surface.withValues(alpha: .8),
                Theme.of(context).colorScheme.surface,
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingPlatformCard() {
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: Card(
        elevation: 8,
        shadowColor: Colors.black.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header Row
              Row(
                children: [
                  // Platform Avatar
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: _getPlatformAccentColor().withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: widget.platform.hasLogo
                          ? CachedImageWidget(
                              imageUrl: widget.platform.logo!.logoMed2xUrl,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              color: _getPlatformAccentColor().withOpacity(0.1),
                              child: Icon(
                                Icons.videogame_asset,
                                color: _getPlatformAccentColor(),
                                size: 30,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Platform Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Platform Name
                        Text(
                          widget.platform.name,
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 4),

                        // Platform Info Chips
                        Row(
                          children: [
                            if (widget.platform.abbreviation != null)
                              _buildInfoChip(
                                widget.platform.abbreviation!,
                                _getPlatformAccentColor(),
                                Icons.label,
                              ),
                            if (widget.platform.abbreviation != null &&
                                widget.platform.generation != null)
                              const SizedBox(width: 8),
                            if (widget.platform.generation != null)
                              _buildInfoChip(
                                'Gen ${widget.platform.generation}',
                                Colors.orange,
                                Icons.timeline,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(String text, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlatformContent() {
    return SliverToBoxAdapter(
      child: Container(
        color: Theme.of(context).colorScheme.surface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
                height: AppConstants.paddingLarge), // Space for floating card

            // Platform Information Accordion
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingMedium),
              child: _buildPlatformInformationAccordion(),
            ),

            const SizedBox(height: 16),

            // Platform Games Section - Always show, even if empty
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingMedium,
              ),
              child: _buildTabView(context, _createPlatformGamesSeriesItem()),
            ),

            const SizedBox(height: 20), // Bottom spacing
          ],
        ),
      ),
    );
  }

  Widget _buildPlatformInformationAccordion() {
    // Count total accordion items to determine isFirst/isLast
    int accordionCount = 0;
    if (widget.platform.summary != null) accordionCount++;
    accordionCount++; // Platform Details always present
    if (widget.platform.url != null) accordionCount++;

    int currentIndex = 0;

    return Card(
      elevation: 2,
      child: Column(
        children: [
          // Platform Description Accordion (enhanced)
          if (widget.platform.summary != null) ...[
            AccordionTile(
              title: 'Platform Description',
              icon: Icons.description,
              isFirst: currentIndex == 0,
              isLast: currentIndex == accordionCount - 1,
              child: Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingMedium,
                  vertical: AppConstants.paddingSmall,
                ),
                child: Stack(
                  children: [
                    // Main content container with gradient background
                    Container(
                      constraints: const BoxConstraints(
                        maxHeight: 200,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            _getPlatformAccentColor().withOpacity(0.05),
                            _getPlatformAccentColor().withOpacity(0.08),
                            _getPlatformAccentColor().withOpacity(0.10),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _getPlatformAccentColor().withOpacity(0.2),
                          width: 1.5,
                        ),
                      ),
                      child: Stack(
                        children: [
                          // Scrollable text
                          SingleChildScrollView(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Decorative quote icon
                                Icon(
                                  Icons.format_quote,
                                  size: 24,
                                  color: _getPlatformAccentColor()
                                      .withOpacity(0.3),
                                ),
                                const SizedBox(height: 8),
                                // Description text
                                Text(
                                  widget.platform.summary!,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        height: 1.6,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                        fontStyle: FontStyle.italic,
                                        letterSpacing: 0.2,
                                      ),
                                ),
                                const SizedBox(height: 8),
                                // Closing quote
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: Icon(
                                    Icons.format_quote,
                                    size: 24,
                                    color: _getPlatformAccentColor()
                                        .withOpacity(0.3),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Bottom fade effect
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            height: 40,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Theme.of(context)
                                        .colorScheme
                                        .surface
                                        .withOpacity(0.8),
                                  ],
                                ),
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(12),
                                  bottomRight: Radius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Scroll indicator hint
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getPlatformAccentColor().withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.swipe_vertical,
                              size: 12,
                              color: _getPlatformAccentColor().withOpacity(0.6),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Scroll',
                              style: TextStyle(
                                fontSize: 10,
                                color:
                                    _getPlatformAccentColor().withOpacity(0.6),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Builder(
              builder: (context) {
                currentIndex++;
                return const SizedBox.shrink();
              },
            ),
          ],

          // Platform Details Accordion (enhanced)
          AccordionTile(
            title: 'Platform Details',
            icon: Icons.info_outline,
            isFirst: widget.platform.summary == null,
            isLast: widget.platform.url == null,
            child: Container(
              margin: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingMedium,
                vertical: AppConstants.paddingSmall,
              ),
              child: Column(
                children: [
                  _buildEnhancedDetailCard(
                    'Platform Name',
                    widget.platform.name,
                    Icons.videogame_asset,
                    _getPlatformAccentColor(),
                  ),
                  if (widget.platform.alternativeName != null) ...[
                    const SizedBox(height: 8),
                    _buildEnhancedDetailCard(
                      'Alternative Name',
                      widget.platform.alternativeName!,
                      Icons.label_important,
                      Colors.orange,
                    ),
                  ],
                  if (widget.platform.abbreviation != null) ...[
                    const SizedBox(height: 8),
                    _buildEnhancedDetailCard(
                      'Abbreviation',
                      widget.platform.abbreviation!,
                      Icons.short_text,
                      Colors.blue,
                    ),
                  ],
                  if (widget.platform.generation != null) ...[
                    const SizedBox(height: 8),
                    _buildEnhancedDetailCard(
                      'Generation',
                      'Generation ${widget.platform.generation}',
                      Icons.timeline,
                      Colors.purple,
                    ),
                  ],
                  if (widget.platform.platformTypeId != null) ...[
                    const SizedBox(height: 8),
                    _buildEnhancedDetailCard(
                      'Platform Type',
                      _getPlatformTypeDisplay(),
                      Icons.category,
                      Colors.teal,
                    ),
                  ],
                  const SizedBox(height: 8),
                  _buildEnhancedDetailCard(
                    'Slug',
                    widget.platform.slug,
                    Icons.link,
                    Colors.grey,
                  ),
                  const SizedBox(height: 4),
                ],
              ),
            ),
          ),

          // Links Accordion
          if (widget.platform.url != null) ...[
            Builder(
              builder: (context) {
                currentIndex++;
                return const SizedBox.shrink();
              },
            ),
            AccordionTile(
              title: 'External Links',
              icon: Icons.link,
              isFirst: false,
              isLast: true,
              child: Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingMedium,
                  vertical: AppConstants.paddingSmall,
                ),
                child: SizedBox(
                  height: 100,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.zero,
                    children: [
                      _buildLinkCard(
                        'IGDB',
                        widget.platform.url!,
                        FontAwesomeIcons.database,
                        const Color(0xFF9146FF),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEnhancedDetailCard(
    String label,
    String value,
    IconData icon,
    Color accentColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withOpacity(0.5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: accentColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Icon with colored background
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 22,
              color: accentColor,
            ),
          ),
          const SizedBox(width: 12),
          // Label and Value
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                        fontSize: 11,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkCard(
    String name,
    String url,
    IconData icon,
    Color color,
  ) {
    return Container(
      width: 90,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _launchUrl(url),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 20,
                  ),
                ),
                const SizedBox(height: 6),
                // Name
                Text(
                  name,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabView(BuildContext context, SeriesItem item) {
    return Card(
      elevation: 2,
      child: Padding(
        padding:
            const EdgeInsets.symmetric(vertical: AppConstants.paddingSmall),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Series Info Header
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingSmall),
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
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight:
                                        item.type == SeriesType.mainFranchise
                                            ? FontWeight.bold
                                            : FontWeight.w600,
                                  ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          item.type?.displayName ?? 'Unknown',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: item.accentColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  // View All Button
                  if (item.totalCount >= 10)
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

            // Games List
            SizedBox(
              height: 280,
              child: item.games.isNotEmpty
                  ? _buildGamesList(item.games)
                  : _buildNoGamesPlaceholder(context),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToSeries(BuildContext context, SeriesItem item) {
    Navigations.navigateToPlatformGames(
      context,
      platformId: widget.platform.id,
      platformName: widget.platform.name,
    );
  }

  Widget _buildGamesList(List<Game> games) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.only(left: AppConstants.paddingSmall),
      itemCount: games.length,
      itemBuilder: (context, index) {
        final game = games[index];
        return Container(
          width: 160,
          margin: const EdgeInsets.only(right: AppConstants.paddingSmall),
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
              Icons.videogame_asset_off,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              'No games found',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'This platform has no games in our database',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _getPlatformTypeDisplay() {
    if (widget.platform.platformTypeId != null) {
      return 'Type ${widget.platform.platformTypeId}';
    }
    return 'Unknown Type';
  }

  Future<void> _launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open $url')),
        );
      }
    }
  }

  void _logPlatformData() {
    if (widget.games.isNotEmpty) {
      for (var i = 0; i < widget.games.length && i < 3; i++) {
      }
    } else {
    }
  }
}
