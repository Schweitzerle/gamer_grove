// ==================================================
// COMPANY DETAIL SCREEN
// ==================================================

// lib/presentation/pages/company/company_details_screen.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gamer_grove/core/utils/image_utils.dart';
import 'package:gamer_grove/domain/entities/company/company.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/cached_image_widget.dart';
import '../../../domain/entities/game/game.dart';
import '../../../domain/entities/website/website.dart';
import '../../widgets/accordion_tile.dart';
import '../../widgets/game_card.dart';
import '../../../core/utils/navigations.dart';
import '../../widgets/sections/franchise_collection_section.dart';

class CompanyDetailScreen extends StatefulWidget {
  final Company company;
  final List<Game> games;

  const CompanyDetailScreen({
    super.key,
    required this.company,
    required this.games,
  });

  @override
  State<CompanyDetailScreen> createState() => _CompanyDetailScreenState();
}

class _CompanyDetailScreenState extends State<CompanyDetailScreen> {
  late ScrollController _scrollController;
  bool _isHeaderCollapsed = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    _logCompanyData();
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

  SeriesItem _createDevelopedGamesSeriesItem() {
    final developedGames = widget.company.developedGames ?? [];
    return SeriesItem(
      type: null,
      title: 'Developed Games',
      games: developedGames.take(10).toList(),
      totalCount: developedGames.length,
      accentColor: Colors.blue,
      icon: Icons.code,
      franchise: null,
      collection: null,
      companyId: widget.company.id,
      companyName: widget.company.name,
      isDeveloper: true,
      isPublisher: null,
    );
  }

  SeriesItem _createPublishedGamesSeriesItem() {
    final publishedGames = widget.company.publishedGames ?? [];
    return SeriesItem(
      type: null,
      title: 'Published Games',
      games: publishedGames.take(10).toList(),
      totalCount: publishedGames.length,
      accentColor: Colors.green,
      icon: Icons.library_books,
      franchise: null,
      collection: null,
      companyId: widget.company.id,
      companyName: widget.company.name,
      isDeveloper: null,
      isPublisher: true,
    );
  }

  Color _getCompanyAccentColor() {
    // Different colors based on company type or name
    if (widget.company.isDeveloperAndPublisher) {
      return Colors.purple;
    } else if (widget.company.isDeveloper) {
      return Colors.blue;
    } else if (widget.company.isPublisher) {
      return Colors.green;
    }
    return Theme.of(context).colorScheme.primary;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Company Hero Section
          _buildSliverAppBar(),
          // Company Content
          _buildCompanyContent(),
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
            // Floating Company Card
            _buildFloatingCompanyCard(),
          ],
        ),
        title: _isHeaderCollapsed
            ? Text(
                widget.company.name,
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
      tag: 'company_hero_${widget.company.id}',
      child: widget.company.hasLogo && widget.company.logoUrl != null
          ? CachedImageWidget(
              imageUrl: ImageUtils.getLargeImageUrl(
                widget.company.logoUrl,
              ),
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
            _getCompanyAccentColor().withOpacity(0.8),
            _getCompanyAccentColor().withOpacity(0.6),
            _getCompanyAccentColor().withOpacity(0.4),
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

  Widget _buildFloatingCompanyCard() {
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
                  // Company Avatar
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: _getCompanyAccentColor().withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: widget.company.hasLogo &&
                              widget.company.logoUrl != null
                          ? CachedImageWidget(
                              imageUrl: widget.company.logoUrl!,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              color: _getCompanyAccentColor().withOpacity(0.1),
                              child: Icon(
                                Icons.business,
                                color: _getCompanyAccentColor(),
                                size: 30,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Company Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Company Name
                        Text(
                          widget.company.name,
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 4),

                        // Company Info Chips
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            if (widget.company.isDeveloper)
                              _buildInfoChip(
                                'Developer',
                                Colors.blue,
                                Icons.code,
                              ),
                            if (widget.company.isPublisher)
                              _buildInfoChip(
                                'Publisher',
                                Colors.green,
                                Icons.publish,
                              ),
                            if (widget.company.totalGamesCount > 0)
                              _buildInfoChip(
                                '${widget.company.totalGamesCount} ${widget.company.totalGamesCount == 1 ? 'Game' : 'Games'}',
                                Colors.orange,
                                Icons.videogame_asset,
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

  Widget _buildCompanyContent() {
    return SliverToBoxAdapter(
      child: Container(
        color: Theme.of(context).colorScheme.surface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
                height: AppConstants.paddingLarge), // Space for floating card

            // Combined Company Information Accordion
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingMedium),
              child: _buildCombinedCompanyAccordion(),
            ),

            const SizedBox(height: 16),

            // Developed Games Section
            if (widget.company.isDeveloper &&
                (widget.company.developedGames?.isNotEmpty ?? false))
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.paddingMedium),
                child:
                    _buildTabView(context, _createDevelopedGamesSeriesItem()),
              ),

            if (widget.company.isDeveloper &&
                (widget.company.developedGames?.isNotEmpty ?? false))
              const SizedBox(height: 16),

            // Published Games Section
            if (widget.company.isPublisher &&
                (widget.company.publishedGames?.isNotEmpty ?? false))
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.paddingMedium),
                child:
                    _buildTabView(context, _createPublishedGamesSeriesItem()),
              ),

            const SizedBox(height: 20), // Bottom spacing
          ],
        ),
      ),
    );
  }

  Widget _buildCombinedCompanyAccordion() {
    // Count total accordion items to determine isFirst/isLast
    int accordionCount = 0;
    if (widget.company.hasDescription) accordionCount++;
    accordionCount++; // Company Details always present
    if (widget.company.hasParent) accordionCount++;
    if (_hasAnyLinks()) accordionCount++; // Combined links section

    int currentIndex = 0;

    return Card(
      elevation: 2,
      child: Column(
        children: [
          // Company Description Accordion (enhanced)
          if (widget.company.hasDescription) ...[
            AccordionTile(
              title: 'Company Description',
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
                            _getCompanyAccentColor().withOpacity(0.05),
                            _getCompanyAccentColor().withOpacity(0.08),
                            _getCompanyAccentColor().withOpacity(0.10),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _getCompanyAccentColor().withOpacity(0.2),
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
                                      _getCompanyAccentColor().withOpacity(0.3),
                                ),
                                const SizedBox(height: 8),
                                // Description text
                                Text(
                                  widget.company.description!,
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
                                    color: _getCompanyAccentColor()
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
                          color: _getCompanyAccentColor().withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.swipe_vertical,
                              size: 12,
                              color: _getCompanyAccentColor().withOpacity(0.6),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Scroll',
                              style: TextStyle(
                                fontSize: 10,
                                color:
                                    _getCompanyAccentColor().withOpacity(0.6),
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

          // Company Details Accordion (enhanced)
          AccordionTile(
            title: 'Company Details',
            icon: Icons.info_outline,
            isFirst: !widget.company.hasDescription,
            isLast: !widget.company.hasParent && !_hasAnyLinks(),
            child: Container(
              margin: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingMedium,
                vertical: AppConstants.paddingSmall,
              ),
              child: Column(
                children: [
                  _buildEnhancedDetailCard(
                    'Company Name',
                    widget.company.name,
                    Icons.business,
                    _getCompanyAccentColor(),
                  ),
                  if (widget.company.slug != null) ...[
                    const SizedBox(height: 8),
                    _buildEnhancedDetailCard(
                      'Slug',
                      widget.company.slug!,
                      Icons.link,
                      Colors.blue,
                    ),
                  ],
                  if (widget.company.hasFoundingDate) ...[
                    const SizedBox(height: 8),
                    _buildEnhancedDetailCard(
                      'Founded',
                      _formatDate(widget.company.startDate!),
                      Icons.calendar_today,
                      Colors.purple,
                    ),
                  ],
                  if (widget.company.country != null) ...[
                    const SizedBox(height: 8),
                    _buildEnhancedDetailCard(
                      'Country',
                      'Code: ${widget.company.country}',
                      Icons.flag,
                      Colors.orange,
                    ),
                  ],
                  if (widget.company.totalGamesCount > 0) ...[
                    const SizedBox(height: 8),
                    _buildEnhancedDetailCard(
                      'Total Games',
                      '${widget.company.totalGamesCount} games',
                      Icons.videogame_asset,
                      Colors.green,
                    ),
                  ],
                  const SizedBox(height: 4),
                ],
              ),
            ),
          ),

          // Parent Company Accordion
          if (widget.company.hasParent) ...[
            Builder(
              builder: (context) {
                currentIndex++;
                return const SizedBox.shrink();
              },
            ),
            AccordionTile(
              title: 'Parent Company',
              icon: Icons.business_center,
              isFirst: currentIndex == 0,
              isLast: !_hasAnyLinks(),
              child: _buildParentCompanyContent(),
            ),
          ],

          // Combined Links Accordion (Websites + IGDB URL)
          if (_hasAnyLinks()) ...[
            Builder(
              builder: (context) {
                currentIndex++;
                return const SizedBox.shrink();
              },
            ),
            AccordionTile(
              title: 'External Links',
              icon: Icons.link,
              isFirst: currentIndex == 0,
              isLast: true,
              child: _buildCombinedLinksContent(),
            ),
          ],
        ],
      ),
    );
  }

  bool _hasAnyLinks() {
    return (widget.company.websites != null &&
            widget.company.websites!.isNotEmpty) ||
        widget.company.url != null;
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

  Widget _buildCombinedLinksContent() {
    final websites = widget.company.websites ?? [];
    final hasIgdbUrl = widget.company.url != null;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingMedium,
        vertical: AppConstants.paddingSmall,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Websites Section (Social Media, Official Sites, etc.)
          if (websites.isNotEmpty) ...[
            Row(
              children: [
                Icon(
                  Icons.public,
                  size: 18,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Official & Social Links',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${websites.length}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Horizontal Website Cards
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                itemCount: websites.length,
                itemBuilder: (context, index) {
                  final website = websites[index];
                  return Padding(
                    padding: EdgeInsets.only(
                      right: index < websites.length - 1 ? 12 : 0,
                    ),
                    child: _buildWebsiteCard(website),
                  );
                },
              ),
            ),
          ],

          // IGDB URL Section
          if (hasIgdbUrl) ...[
            if (websites.isNotEmpty) const SizedBox(height: 20),
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 18,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Database Links',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // IGDB Card
            SizedBox(
              height: 100,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                children: [
                  _buildIgdbCard(),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWebsiteCard(Website website) {
    final websiteColor = _getWebsiteColorByType(website.type.type);
    final websiteName = _getWebsiteNameByType(website.type.type);

    return Container(
      width: 90,
      decoration: BoxDecoration(
        color: websiteColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: websiteColor.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _launchUrl(website.url),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Website Icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: websiteColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _getWebsiteIconWidget(website.type.type),
                ),

                const SizedBox(height: 6),

                // Website Name
                Text(
                  websiteName,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: websiteColor,
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

  Widget _buildIgdbCard() {
    const igdbColor = Color(0xFF9146FF);

    return Container(
      width: 90,
      decoration: BoxDecoration(
        color: igdbColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: igdbColor.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _launchUrl(widget.company.url!),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // IGDB Icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: igdbColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    FontAwesomeIcons.database,
                    color: igdbColor,
                    size: 20,
                  ),
                ),

                const SizedBox(height: 6),

                // IGDB Name
                Text(
                  'IGDB',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: igdbColor,
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

  String _getWebsiteNameByType(String type) {
    switch (type.toLowerCase()) {
      case 'official website':
      case 'official':
        return 'Official';
      case 'community wiki':
      case 'wikia':
        return 'Wiki';
      case 'wikipedia':
        return 'Wikipedia';
      case 'facebook':
        return 'Facebook';
      case 'twitter':
        return 'Twitter';
      case 'twitch':
        return 'Twitch';
      case 'instagram':
        return 'Instagram';
      case 'youtube':
        return 'YouTube';
      case 'subreddit':
      case 'reddit':
        return 'Reddit';
      case 'discord':
        return 'Discord';
      case 'steam':
        return 'Steam';
      case 'epic':
      case 'epicgames':
        return 'Epic';
      case 'gog':
        return 'GOG';
      case 'itch':
        return 'itch.io';
      case 'app store (iphone)':
      case 'app store (ipad)':
      case 'iphone':
      case 'ipad':
        return 'App Store';
      case 'google play':
      case 'android':
        return 'Google Play';
      case 'bluesky':
        return 'Bluesky';
      case 'xbox':
        return 'Xbox';
      case 'playstation':
        return 'PlayStation';
      case 'nintendo':
        return 'Nintendo';
      case 'meta':
        return 'Meta';
      default:
        return type;
    }
  }

  Widget _getWebsiteIconWidget(String type) {
    IconData iconData;
    Color iconColor;

    switch (type.toLowerCase()) {
      case 'official website':
      case 'official':
        iconData = Icons.public;
        iconColor = const Color(0xFF07355A);
      case 'community wiki':
      case 'wikia':
        iconData = FontAwesomeIcons.wikipediaW;
        iconColor = const Color(0xFF939598);
      case 'wikipedia':
        iconData = FontAwesomeIcons.wikipediaW;
        iconColor = const Color(0xFFc7c8ca);
      case 'facebook':
        iconData = FontAwesomeIcons.facebook;
        iconColor = const Color(0xFF1877f2);
      case 'twitter':
        iconData = FontAwesomeIcons.twitter;
        iconColor = const Color(0xFF1da1f2);
      case 'twitch':
        iconData = FontAwesomeIcons.twitch;
        iconColor = const Color(0xFF9146ff);
      case 'instagram':
        iconData = FontAwesomeIcons.instagram;
        iconColor = const Color(0xFFc13584);
      case 'youtube':
        iconData = FontAwesomeIcons.youtube;
        iconColor = const Color(0xFFff0000);
      case 'app store (iphone)':
      case 'app store (ipad)':
      case 'iphone':
      case 'ipad':
        iconData = FontAwesomeIcons.apple;
        iconColor = const Color(0xFF000000);
      case 'google play':
      case 'android':
        iconData = FontAwesomeIcons.android;
        iconColor = const Color(0xFFa4c639);
      case 'steam':
        iconData = FontAwesomeIcons.steam;
        iconColor = const Color(0xFF00adee);
      case 'subreddit':
      case 'reddit':
        iconData = FontAwesomeIcons.reddit;
        iconColor = const Color(0xFFff4500);
      case 'itch':
        iconData = FontAwesomeIcons.itchIo;
        iconColor = const Color(0xFFfa5c5c);
      case 'epic':
      case 'epicgames':
        iconData = FontAwesomeIcons.earlybirds;
        iconColor = const Color(0xFF242424);
      case 'gog':
        iconData = FontAwesomeIcons.galacticRepublic;
        iconColor = const Color(0xFF7cb4dc);
      case 'discord':
        iconData = FontAwesomeIcons.discord;
        iconColor = const Color(0xFF5865f2);
      case 'bluesky':
        iconData = FontAwesomeIcons.cloud;
        iconColor = const Color(0xFF0085FF);
      case 'xbox':
        iconData = FontAwesomeIcons.xbox;
        iconColor = const Color(0xFF107C10);
      case 'playstation':
        iconData = FontAwesomeIcons.playstation;
        iconColor = const Color(0xFF0070D1);
      case 'nintendo':
        iconData = FontAwesomeIcons.gamepad;
        iconColor = const Color(0xFFE60012);
      case 'meta':
        iconData = FontAwesomeIcons.meta;
        iconColor = const Color(0xFF0668E1);
      default:
        iconData = Icons.link;
        iconColor = const Color(0xFF07355A);
    }

    return Icon(iconData, color: iconColor, size: 20);
  }

  Color _getWebsiteColorByType(String type) {
    switch (type.toLowerCase()) {
      case 'official website':
      case 'official':
        return Colors.blue;
      case 'community wiki':
      case 'wikia':
      case 'wikipedia':
        return Colors.orange;
      case 'facebook':
        return const Color(0xFF1877F2);
      case 'twitter':
        return Colors.black;
      case 'instagram':
        return const Color(0xFFE4405F);
      case 'youtube':
        return const Color(0xFFFF0000);
      case 'twitch':
        return const Color(0xFF9146FF);
      case 'subreddit':
      case 'reddit':
        return const Color(0xFFFF4500);
      case 'discord':
        return const Color(0xFF5865F2);
      case 'steam':
        return const Color(0xFF1B2838);
      case 'epic':
      case 'epicgames':
        return const Color(0xFF0078F2);
      case 'gog':
        return const Color(0xFF8A2BE2);
      case 'itch':
        return const Color(0xFFFA5C5C);
      case 'app store (iphone)':
      case 'app store (ipad)':
      case 'iphone':
      case 'ipad':
        return const Color(0xFF007AFF);
      case 'google play':
      case 'android':
        return const Color(0xFF3DDC84);
      case 'bluesky':
        return const Color(0xFF0085FF);
      case 'xbox':
        return const Color(0xFF107C10);
      case 'playstation':
        return const Color(0xFF0070D1);
      case 'nintendo':
        return const Color(0xFFE60012);
      case 'meta':
        return const Color(0xFF0668E1);
      default:
        return Colors.blue;
    }
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
              padding: const EdgeInsets.only(
                  left: AppConstants.paddingSmall,
                  right: AppConstants.paddingSmall,
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
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${item.totalCount} ${item.totalCount == 1 ? 'game' : 'games'}',
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
    Navigations.navigateToCompanyGames(
      context,
      companyId: widget.company.id,
      companyName: widget.company.name,
      isDeveloper: item.isDeveloper,
      isPublisher: item.isPublisher,
    );
  }

  Widget _buildGamesList(List<Game> games) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.only(
          left: AppConstants.paddingSmall, bottom: AppConstants.paddingSmall),
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
              'This company has no games in our database',
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

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year}';
  }

  Widget _buildParentCompanyContent() {
    final parent = widget.company.parentCompany!;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingMedium,
        vertical: AppConstants.paddingSmall,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigations.navigateToCompanyDetails(
              context,
              companyId: parent.id,
            );
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: _getCompanyAccentColor().withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: parent.hasLogo && parent.logoUrl != null
                        ? CachedImageWidget(
                            imageUrl: parent.logoUrl!,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            color: _getCompanyAccentColor().withOpacity(0.1),
                            child: Icon(
                              Icons.business,
                              color: _getCompanyAccentColor(),
                              size: 24,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        parent.name,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (parent.hasDescription) ...[
                        const SizedBox(height: 4),
                        Text(
                          parent.description!,
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
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

  void _logCompanyData() {
    print('\n=== 🏢 COMPANY DETAIL SCREEN LOADED ===');
    print('🎯 Company: ${widget.company.name} (ID: ${widget.company.id})');
    print('🎮 Games: ${widget.games.length}');
    print('💼 Developer: ${widget.company.isDeveloper}');
    print('📦 Publisher: ${widget.company.isPublisher}');
    print('🏢 Has Parent: ${widget.company.hasParent}');
    if (widget.company.hasParent) {
      print('   Parent: ${widget.company.parentCompany!.name}');
    }
    print('🌐 Websites: ${widget.company.websites?.length ?? 0}');
    print('🖼️ Logo: ${widget.company.hasLogo ? 'Available' : 'Fallback'}');
    print(
        '📄 Description: ${widget.company.hasDescription ? 'Available' : 'None'}');
    print('🔗 URL: ${widget.company.url ?? 'None'}');
    print('🏳️ Country: ${widget.company.country ?? 'Unknown'}');
    print(
        '📅 Founded: ${widget.company.hasFoundingDate ? _formatDate(widget.company.startDate!) : 'Unknown'}');
    print('🔑 Slug: ${widget.company.slug ?? 'None'}');
    print('=== END COMPANY DETAIL LOG ===\n');
  }
}
