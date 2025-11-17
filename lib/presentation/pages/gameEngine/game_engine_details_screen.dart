// ==================================================
// GAME ENGINE DETAIL SCREEN (ÜBERARBEITET)
// ==================================================

// lib/presentation/pages/game_engine_detail/game_engine_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:gamer_grove/domain/entities/game/game_engine.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/cached_image_widget.dart';
import '../../../domain/entities/game/game.dart';
import '../../widgets/accordion_tile.dart';
import '../../widgets/game_card.dart';
import '../../../core/utils/navigations.dart';
import '../../widgets/sections/franchise_collection_section.dart';
import '../../widgets/sections/platform_section.dart';
import '../game_detail/widgets/company_section.dart';

class GameEngineDetailScreen extends StatefulWidget {
  final GameEngine gameEngine;
  final List<Game> games;

  const GameEngineDetailScreen({
    super.key,
    required this.gameEngine,
    required this.games,
  });

  @override
  State<GameEngineDetailScreen> createState() => _GameEngineDetailScreenState();
}

class _GameEngineDetailScreenState extends State<GameEngineDetailScreen> {
  late ScrollController _scrollController;
  bool _isHeaderCollapsed = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    _logGameEngineData();
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

  SeriesItem _createGameEngineGamesSeriesItem() {
    return SeriesItem(
      type: null,
      title: '${widget.gameEngine.name} - Games Built',
      games: _getEngineGames(),
      totalCount: widget.games.length,
      accentColor: _getEngineAccentColor(),
      icon: Icons.precision_manufacturing,
      franchise: null,
      collection: null,
    );
  }

  Color _getEngineAccentColor() {
    // Verschiedene Farben basierend auf Engine-Name
    final engineName = widget.gameEngine.name.toLowerCase();
    if (engineName.contains('unity')) {
      return Colors.black;
    } else if (engineName.contains('unreal')) {
      return Colors.blue;
    } else if (engineName.contains('godot')) {
      return Colors.green;
    } else if (engineName.contains('cryengine') || engineName.contains('cry')) {
      return Colors.red;
    } else if (engineName.contains('source')) {
      return Colors.orange;
    }
    return Theme.of(context).colorScheme.primary;
  }

  List<Game> _getEngineGames() {
    if (widget.games.isEmpty) return [];
    return widget.games.take(10).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Game Engine Hero Section
          _buildSliverAppBar(),
          // Game Engine Content
          _buildGameEngineContent(),
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
            // Floating Game Engine Card
            _buildFloatingGameEngineCard(),
          ],
        ),
        title: _isHeaderCollapsed
            ? Text(
                widget.gameEngine.name,
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
      tag: 'game_engine_hero_${widget.gameEngine.id}',
      child: widget.gameEngine.hasLogo && widget.gameEngine.logoUrl != null
          ? CachedImageWidget(
              imageUrl: widget.gameEngine.logoUrl!,
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
            _getEngineAccentColor().withOpacity(0.8),
            _getEngineAccentColor().withOpacity(0.6),
            _getEngineAccentColor().withOpacity(0.4),
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

  Widget _buildFloatingGameEngineCard() {
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
                  // Game Engine Avatar
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: _getEngineAccentColor().withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: widget.gameEngine.hasLogo &&
                              widget.gameEngine.logoUrl != null
                          ? CachedImageWidget(
                              imageUrl: widget.gameEngine.logoUrl!,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              color: _getEngineAccentColor().withOpacity(0.1),
                              child: Icon(
                                Icons.precision_manufacturing,
                                color: _getEngineAccentColor(),
                                size: 30,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Game Engine Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Engine Name
                        Text(
                          widget.gameEngine.name,
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 4),

                        // Engine Info Chips
                        Row(
                          children: [
                            if (widget.gameEngine.hasCompanies)
                              _buildInfoChip(
                                '${widget.gameEngine.companyCount} ${widget.gameEngine.companyCount == 1 ? 'Company' : 'Companies'}',
                                Colors.blue,
                                Icons.business,
                              ),
                            if (widget.gameEngine.hasCompanies &&
                                widget.gameEngine.hasPlatforms)
                              const SizedBox(width: 8),
                            if (widget.gameEngine.hasPlatforms)
                              _buildInfoChip(
                                '${widget.gameEngine.platformCount} ${widget.gameEngine.platformCount == 1 ? 'Platform' : 'Platforms'}',
                                Colors.green,
                                Icons.devices,
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

  Widget _buildGameEngineContent() {
    return SliverToBoxAdapter(
      child: Container(
        color: Theme.of(context).colorScheme.surface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
                height: AppConstants.paddingLarge), // Space for floating card

            // Combined Game Engine Information Accordion
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingMedium),
              child: _buildCombinedGameEngineAccordion(),
            ),

            const SizedBox(height: 16),

            // Companies Section
            Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.paddingMedium),
                child: GenericCompanySection(
                  companies: widget.gameEngine.companies,
                  title: 'Companies Using This Engine',
                  showRoles: false,
                )),

            const SizedBox(height: 16),

            // Platforms Section
            if (widget.gameEngine.hasPlatforms)
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.paddingMedium),
                child: Card(
                  elevation: 2,
                  child: GenericPlatformSection(
                    platforms: widget.gameEngine.platforms,
                    title: 'Supported Platforms',
                    showReleaseTimeline: false,
                    showFirstReleaseInfo: false,
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // Game Engine Games Section
            if (widget.games.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.paddingMedium),
                child:
                    _buildTabView(context, _createGameEngineGamesSeriesItem()),
              ),

            const SizedBox(height: 20), // Bottom spacing
          ],
        ),
      ),
    );
  }

  Widget _buildCombinedGameEngineAccordion() {
    // Count total accordion items to determine isFirst/isLast
    int accordionCount = 0;
    if (widget.gameEngine.hasDescription) accordionCount++;
    accordionCount++; // Engine Details always present
    if (widget.gameEngine.hasUrl) accordionCount++;

    int currentIndex = 0;

    return Card(
      elevation: 2,
      child: Column(
        children: [
          // Engine Description Accordion (enhanced)
          if (widget.gameEngine.hasDescription) ...[
            AccordionTile(
              title: 'Engine Description',
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
                            _getEngineAccentColor().withOpacity(0.05),
                            _getEngineAccentColor().withOpacity(0.08),
                            _getEngineAccentColor().withOpacity(0.10),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _getEngineAccentColor().withOpacity(0.2),
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
                                  color:
                                      _getEngineAccentColor().withOpacity(0.3),
                                ),
                                const SizedBox(height: 8),
                                // Description text
                                Text(
                                  widget.gameEngine.description!,
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
                                    color: _getEngineAccentColor()
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
                          color: _getEngineAccentColor().withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.swipe_vertical,
                              size: 12,
                              color: _getEngineAccentColor().withOpacity(0.6),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Scroll',
                              style: TextStyle(
                                fontSize: 10,
                                color: _getEngineAccentColor().withOpacity(0.6),
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

          // Engine Details Accordion
          AccordionTile(
            title: 'Engine Details',
            icon: Icons.info_outline,
            isFirst: !widget.gameEngine.hasDescription,
            isLast: !widget.gameEngine.hasUrl,
            child: Container(
              margin: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingMedium,
                vertical: AppConstants.paddingSmall,
              ),
              child: Column(
                children: [
                  _buildEnhancedDetailCard(
                    'Engine Name',
                    widget.gameEngine.name,
                    Icons.precision_manufacturing,
                    _getEngineAccentColor(),
                  ),
                  if (widget.gameEngine.slug != null) ...[
                    const SizedBox(height: 8),
                    _buildEnhancedDetailCard(
                      'Slug',
                      widget.gameEngine.slug!,
                      Icons.link,
                      Colors.blue,
                    ),
                  ],
                  if (widget.gameEngine.hasCompanies) ...[
                    const SizedBox(height: 8),
                    _buildEnhancedDetailCard(
                      'Companies',
                      '${widget.gameEngine.companyCount} using this engine',
                      Icons.business,
                      Colors.purple,
                    ),
                  ],
                  if (widget.gameEngine.hasPlatforms) ...[
                    const SizedBox(height: 8),
                    _buildEnhancedDetailCard(
                      'Platforms',
                      '${widget.gameEngine.platformCount} supported',
                      Icons.devices,
                      Colors.green,
                    ),
                  ],
                  if (widget.games.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _buildEnhancedDetailCard(
                      'Games Built',
                      '${widget.games.length} games',
                      Icons.videogame_asset,
                      Colors.orange,
                    ),
                  ],
                  const SizedBox(height: 4),
                ],
              ),
            ),
          ),

          // Links Accordion
          if (widget.gameEngine.hasUrl) ...[
            Builder(
              builder: (context) {
                currentIndex++;
                return const SizedBox.shrink();
              },
            ),
            AccordionTile(
              title: 'Links',
              icon: Icons.link,
              isFirst: false,
              isLast: true,
              child: Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingMedium,
                  vertical: AppConstants.paddingSmall,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest
                        .withOpacity(0.5),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _getEngineAccentColor().withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _getEngineAccentColor().withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.open_in_new,
                        color: _getEngineAccentColor(),
                        size: 20,
                      ),
                    ),
                    title: const Text(
                      'IGDB Engine Website',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      widget.gameEngine.url!,
                      style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: const Icon(Icons.open_in_new, size: 20),
                    onTap: () => _launchUrl(widget.gameEngine.url!),
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

  Widget _buildTabView(BuildContext context, SeriesItem item) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
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
                          item.type?.displayName ?? '',
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
    Navigations.navigateToGameEngineGames(
      context,
      gameEngineId: widget.gameEngine.id,
      gameEngineName: widget.gameEngine.name,
    );
  }

  Widget _buildGamesList(List<Game> games) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: AppConstants.paddingSmall),
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

  Future<void> _launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      print('Error launching URL: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open $url')),
        );
      }
    }
  }

  void _logGameEngineData() {
    print('\n=== ⚙️ GAME ENGINE DETAIL SCREEN LOADED ===');
    print('🎯 Engine: ${widget.gameEngine.name} (ID: ${widget.gameEngine.id})');
    print('🏢 Companies: ${widget.gameEngine.companyCount} using this engine');
    print('🎮 Platforms: ${widget.gameEngine.platformCount} supported');
    print('🎲 Games: ${widget.games.length} built with this engine');
    print(
        '🖼️ Logo: ${widget.gameEngine.hasLogo && widget.gameEngine.logoUrl != null ? 'Available' : 'Fallback'}');
    print(
        '📄 Description: ${widget.gameEngine.hasDescription ? 'Available' : 'None'}');
    print(
        '🔗 URL: ${widget.gameEngine.hasUrl ? widget.gameEngine.url : 'None'}');
    print('🔑 Slug: ${widget.gameEngine.slug ?? 'None'}');
    print('=== END GAME ENGINE DETAIL LOG ===\n');
  }
}
