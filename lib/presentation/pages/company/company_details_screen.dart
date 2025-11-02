// ==================================================
// COMPANY DETAIL SCREEN
// ==================================================

// lib/presentation/pages/company/company_details_screen.dart
import 'package:flutter/material.dart';
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
              imageUrl: widget.company.logoUrl!,
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

            // Company Information Accordion
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingMedium),
              child: _buildCompanyInformationAccordion(),
            ),

            const SizedBox(height: 16),

            // Parent Company Section
            if (widget.company.hasParent)
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.paddingMedium),
                child: _buildParentCompanySection(),
              ),

            if (widget.company.hasParent) const SizedBox(height: 16),

            // Websites Section (only non-official websites)
            if (_getNonOfficialWebsites().isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.paddingMedium),
                child: _buildWebsitesSection(),
              ),

            if (_getNonOfficialWebsites().isNotEmpty)
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

  Widget _buildCompanyInformationAccordion() {
    return Card(
      elevation: 2,
      child: Column(
        children: [
          // Company Description Accordion
          if (widget.company.hasDescription)
            AccordionTile(
              title: 'Company Description',
              icon: Icons.description,
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.paddingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.company.description!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            height: 1.5,
                          ),
                    ),
                    if (_getOfficialWebsiteUrl() != null) ...[
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: () => _launchUrl(_getOfficialWebsiteUrl()!),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: _getCompanyAccentColor().withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _getCompanyAccentColor().withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.open_in_new,
                                size: 16,
                                color: _getCompanyAccentColor(),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Official Company Website',
                                style: TextStyle(
                                  color: _getCompanyAccentColor(),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

          // Company Details Accordion
          AccordionTile(
            title: 'Company Details',
            icon: Icons.info_outline,
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              child: Column(
                children: [
                  _buildDetailRow(
                      'Company Name', widget.company.name, Icons.business),
                  if (widget.company.slug != null)
                    _buildDetailRow('Slug', widget.company.slug!, Icons.link),
                  if (widget.company.hasFoundingDate)
                    _buildDetailRow(
                      'Founded',
                      _formatDate(widget.company.startDate!),
                      Icons.calendar_today,
                    ),
                  if (widget.company.country != null)
                    _buildDetailRow(
                      'Country',
                      'Country Code: ${widget.company.country}',
                      Icons.flag,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebsitesSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.link,
                  size: 18,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Websites & Links',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _getNonOfficialWebsites().map((website) {
                return _buildWebsiteChip(website);
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWebsiteChip(Website website) {
    final typeName = _formatWebsiteTypeName(website.type.type);
    final icon = _getWebsiteIcon(website.type.type);
    final color = _getWebsiteColor(website.type.type);

    return InkWell(
      onTap: () => _launchUrl(website.url),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              typeName,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.open_in_new, size: 12, color: color),
          ],
        ),
      ),
    );
  }

  String _formatWebsiteTypeName(String type) {
    switch (type.toLowerCase()) {
      case 'official':
        return 'Official Website';
      case 'twitter':
        return 'Twitter';
      case 'facebook':
        return 'Facebook';
      case 'instagram':
        return 'Instagram';
      case 'youtube':
        return 'YouTube';
      case 'twitch':
        return 'Twitch';
      case 'reddit':
        return 'Reddit';
      case 'discord':
        return 'Discord';
      case 'steam':
        return 'Steam';
      case 'wikipedia':
        return 'Wikipedia';
      case 'wikia':
        return 'Wikia';
      case 'itch':
        return 'Itch.io';
      case 'epicgames':
        return 'Epic Games';
      case 'gog':
        return 'GOG';
      default:
        return type.toUpperCase();
    }
  }

  IconData _getWebsiteIcon(String type) {
    switch (type.toLowerCase()) {
      case 'official':
        return Icons.home;
      case 'twitter':
        return Icons.send;
      case 'facebook':
        return Icons.facebook;
      case 'instagram':
        return Icons.camera_alt;
      case 'youtube':
        return Icons.play_circle;
      case 'twitch':
        return Icons.tv;
      case 'reddit':
        return Icons.forum;
      case 'discord':
        return Icons.chat;
      case 'steam':
        return Icons.games;
      case 'wikipedia':
      case 'wikia':
        return Icons.book;
      default:
        return Icons.link;
    }
  }

  Color _getWebsiteColor(String type) {
    switch (type.toLowerCase()) {
      case 'twitter':
        return Colors.blue;
      case 'facebook':
        return Colors.indigo;
      case 'instagram':
        return Colors.pink;
      case 'youtube':
        return Colors.red;
      case 'twitch':
        return Colors.purple;
      case 'reddit':
        return Colors.orange;
      case 'discord':
        return Colors.blueAccent;
      case 'steam':
        return Colors.blueGrey;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  Widget _buildTabView(BuildContext context, SeriesItem item) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Series Info Header
            Row(
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
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
      padding: EdgeInsets.zero,
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

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year}';
  }

  String? _getOfficialWebsiteUrl() {
    if (widget.company.websites == null || widget.company.websites!.isEmpty) {
      return null;
    }

    // Find official website - only return if it's actually official
    try {
      final officialWebsite =
          widget.company.websites!.cast<Website>().firstWhere(
                (website) => website.type.type.toLowerCase() == 'official',
              );
      return officialWebsite.url;
    } catch (e) {
      // No official website found
      return null;
    }
  }

  List<Website> _getNonOfficialWebsites() {
    if (widget.company.websites == null || widget.company.websites!.isEmpty) {
      return [];
    }

    // Return all websites that are NOT official
    return widget.company.websites!
        .where((website) => website.type.type.toLowerCase() != 'official')
        .toList();
  }

  Widget _buildParentCompanySection() {
    final parent = widget.company.parentCompany!;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.business_center,
                  size: 18,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Parent Company',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Material(
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
                    color:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context)
                          .colorScheme
                          .outline
                          .withOpacity(0.2),
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
                                  color:
                                      _getCompanyAccentColor().withOpacity(0.1),
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
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
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
