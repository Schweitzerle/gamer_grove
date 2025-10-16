// ==================================================
// EVENT DETAILS SCREEN - IMPROVED UI CONSISTENCY
// ==================================================

// lib/presentation/pages/event_detail/event_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/navigations.dart';
import '../../../core/widgets/cached_image_widget.dart';
import '../../../domain/entities/event/event.dart';
import '../../../domain/entities/game/game.dart';
import '../../widgets/game_card.dart';
import '../../widgets/accordion_tile.dart';
import '../../widgets/sections/franchise_collection_section.dart';
import '../game_detail/widgets/enhanced_media_gallery.dart';

class EventDetailScreen extends StatefulWidget {
  final Event event;
  final List<Game>? featuredGames;
  final bool showGames;

  const EventDetailScreen({
    super.key,
    required this.event,
    this.featuredGames,
    this.showGames = true,
  });

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  late ScrollController _scrollController;
  bool _isHeaderCollapsed = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
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

  SeriesItem _createEventGamesSeriesItem() {
    return SeriesItem(
      type: SeriesType.eventGames,
      title: '${widget.event.name} - Featured Games',
      games: _getEventGames(widget.event),
      totalCount: widget.event.games.length,
      accentColor: _getEventStatusColor(),
      icon: Icons.videogame_asset,
      franchise: null,
      collection: null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Event Hero Section (genau wie GameDetailScreen)
          _buildSliverAppBar(),
          // Event Content (genau wie GameDetailScreen)
          _buildEventContent(),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 350,
      // Gleiche Höhe wie GameDetailScreen
      pinned: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        // Live Stream Button nur wenn verfügbar
        if (widget.event.hasLiveStream)
          IconButton(
            icon: const Icon(Icons.live_tv),
            onPressed: _openLiveStream,
          ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // 1. Hero Image (genau wie GameDetailScreen)
            _buildHeroImage(),
            // 2. Gradient Overlays (genau wie GameDetailScreen)
            _buildGradientOverlays(),
            // 3. Floating Info Card (genau wie GameDetailScreen)
            _buildFloatingEventCard(),
          ],
        ),
        title: _isHeaderCollapsed
            ? Text(
                widget.event.name,
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
      tag: 'event_hero_${widget.event.id}',
      child: Container(
        decoration: BoxDecoration(
          // Fallback Gradient wenn kein Event Logo
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _getEventStatusColor().withOpacity(0.8),
              _getEventStatusColor().withOpacity(0.6),
            ],
          ),
        ),
        child: widget.event.hasLogo
            ? CachedImageWidget(
                imageUrl: widget.event.eventLogo!.bestUrl,
                fit: BoxFit.cover,
                placeholder: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        _getEventStatusColor().withOpacity(0.8),
                        _getEventStatusColor().withOpacity(0.6),
                      ],
                    ),
                  ),
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildGradientOverlays() {
    return Stack(
      children: [
        // Horizontaler Gradient (links-rechts) - genau wie GameDetailScreen
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
        // Vertikaler Gradient (oben-unten) - genau wie GameDetailScreen
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

  Widget _buildFloatingEventCard() {
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
              // Header Row mit Event Info
              Row(
                children: [
                  // Event Logo/Icon
                  if (widget.event.hasLogo)
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedImageWidget(
                          imageUrl: widget.event.eventLogo!.bestUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                  else
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: _getEventStatusColor().withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.event,
                        color: _getEventStatusColor(),
                        size: 30,
                      ),
                    ),

                  const SizedBox(width: 16),

                  // Event Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Event Name
                        Text(
                          widget.event.name,
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 4),

                        // Status Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getEventStatusColor().withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _getEventStatusText(),
                            style: TextStyle(
                              color: _getEventStatusColor(),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Live Stream Button
                  if (widget.event.hasLiveStream)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.live_tv,
                              color: Colors.white, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            widget.event.isLive ? 'LIVE' : 'STREAM',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 12),

              // Event Timing und Info
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _formatEventTime(),
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: _getEventStatusColor(),
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            if (widget.event.hasGames) ...[
                              Icon(
                                Icons.videogame_asset,
                                size: 16,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${widget.event.gameCount} games',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                              ),
                            ],
                            if (widget.event.hasGames && widget.event.hasVideos)
                              const SizedBox(width: 12),
                            if (widget.event.hasVideos) ...[
                              Icon(
                                Icons.play_circle_outline,
                                size: 16,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${widget.event.videoCount} videos',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                              ),
                            ],
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

  Widget _buildEventContent() {
    return SliverToBoxAdapter(
      child: Container(
        color: Theme.of(context).colorScheme.surface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppConstants.paddingLarge),
            // Space for floating card

            // Event Information Accordion
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingMedium),
              child: _buildEventInfoAccordion(),
            ),

            const SizedBox(height: 16),

            // Event Details Accordion (ohne Technical Details)
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingMedium),
              child: _buildEventDetailsAccordion(),
            ),

            const SizedBox(height: 16),

            // Featured Games (unchanged!)
            if (widget.event.hasGameObjects)
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.paddingMedium),
                child: _buildTabView(context, _createEventGamesSeriesItem()),
              ),

            // Event Networks (unchanged!)
            if (widget.event.hasNetworkObjects)
              Column(
                children: [
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.paddingMedium),
                    child: _buildEventNetworksCard(context),
                  ),
                ],
              ),

            if (widget.event.hasVideos)
              _buildEnhancedMediaGallery(widget.event),

            const SizedBox(height: 20),
            // Bottom spacing
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedMediaGallery(Event? event) {
    return EnhancedMediaGallery(event: event);
  }

  List<Game> _getEventGames(Event event) {
    if (event.games.isEmpty) return [];
    return event.games.take(10).toList();
  }

  Widget _buildEventInfoAccordion() {
    return Card(
      elevation: 2,
      child: AccordionTile(
        title: 'Event Information',
        icon: Icons.info_outline,
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Event Status
              _buildInfoRow(
                Icons.flag,
                'Status',
                _getEventStatusText(),
                statusColor: _getEventStatusColor(),
              ),

              // Start Time
              if (widget.event.startTime != null)
                _buildInfoRow(
                  Icons.schedule,
                  'Start Time',
                  DateFormatter.formatEventDateTime(widget.event.startTime!),
                ),

              // End Time
              if (widget.event.endTime != null)
                _buildInfoRow(
                  Icons.schedule_send,
                  'End Time',
                  DateFormatter.formatEventDateTime(widget.event.endTime!),
                ),

              // Duration
              if (widget.event.duration != null)
                _buildInfoRow(
                  Icons.timer,
                  'Duration',
                  _formatDuration(widget.event.duration!),
                ),

              // Timezone
              if (widget.event.timeZone != null)
                _buildInfoRow(
                  Icons.public,
                  'Timezone',
                  widget.event.timeZone!,
                ),

              // Games Count
              if (widget.event.hasGames)
                _buildInfoRow(
                  Icons.videogame_asset,
                  'Featured Games',
                  '${widget.event.gameCount} games',
                ),

              // Videos Count
              if (widget.event.hasVideos)
                _buildInfoRow(
                  Icons.play_circle_outline,
                  'Videos',
                  '${widget.event.videoCount} videos',
                ),

              // Live Stream Button (if available)
              if (widget.event.hasLiveStream)
                Column(
                  children: [
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _openLiveStream,
                        icon: const Icon(Icons.live_tv),
                        label: Text(
                            widget.event.isLive ? 'Watch Live' : 'View Stream'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
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

  Widget _buildEventDetailsAccordion() {
    return Card(
      elevation: 2,
      child: Column(
        children: [
          // Accordion Items
          if (widget.event.hasDescription)
            AccordionTile(
              title: 'Description',
              icon: Icons.description,
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.paddingMedium),
                child: Text(
                  widget.event.description!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        height: 1.5,
                      ),
                ),
              ),
            ),

          if (widget.event.hasNetworks)
            AccordionTile(
              title: 'Links & Networks',
              icon: Icons.link,
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.paddingMedium),
                child: Column(
                  children: [
                    if (widget.event.hasLiveStream)
                      _buildNetworkLink(
                        'Live Stream',
                        widget.event.liveStreamUrl!,
                        Icons.live_tv,
                        Colors.red,
                      ),
                    _buildNetworkLink(
                      'Event Information',
                      'https://example.com/event/${widget.event.slug ?? widget.event.id}',
                      Icons.web,
                      Colors.blue,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    Color? statusColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color:
                statusColor ?? Theme.of(context).colorScheme.onSurfaceVariant,
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
                        color: statusColor,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNetworkLink(
    String label,
    String url,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          url,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 12,
          ),
        ),
        trailing: const Icon(Icons.open_in_new),
        onTap: () => _launchUrl(url),
      ),
    );
  }

  Color _getEventStatusColor() {
    if (widget.event.isLive) return Colors.red;
    if (widget.event.isUpcoming) return Colors.orange;
    if (widget.event.hasEnded) return Colors.grey;
    return Colors.blue;
  }

  String _getEventStatusText() {
    if (widget.event.isLive) return 'LIVE NOW';
    if (widget.event.isUpcoming) return 'UPCOMING';
    if (widget.event.hasEnded) return 'PAST EVENT';
    return 'TBA';
  }

  String _formatEventTime() {
    if (widget.event.startTime == null) return 'Time TBA';

    if (widget.event.isLive && widget.event.endTime != null) {
      final timeLeft = widget.event.timeUntilEnd!;
      return 'Live • ${_formatDuration(timeLeft)} remaining';
    } else if (widget.event.isUpcoming) {
      final timeUntil = widget.event.timeUntilStart!;
      return 'Starts in ${_formatDuration(timeUntil)}';
    } else if (widget.event.hasEnded) {
      return 'Ended ${DateFormatter.formatTimeAgo(widget.event.endTime ?? widget.event.startTime!)}';
    } else {
      return DateFormatter.formatEventDate(widget.event.startTime!);
    }
  }

  String _formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}d ${duration.inHours % 24}h';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else {
      return '${duration.inMinutes}m';
    }
  }

  void _openLiveStream() {
    if (widget.event.hasLiveStream) {
      _launchUrl(widget.event.liveStreamUrl!);
    }
  }

  Future<void> _launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        throw Exception('Could not launch $url');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open $url')),
        );
      }
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
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                              fontWeight: item.type == SeriesType.mainFranchise
                                  ? FontWeight.bold
                                  : FontWeight.w600,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${item.type?.displayName} • ${item.totalCount} games',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: item.accentColor,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ],
                  ),
                ),
                // View All Button
                if (item.totalCount > 10)
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

            // Games List (unverändert!)
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
    Navigations.navigateToEventGames(context, item, widget.event);
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

  Widget _buildEventNetworksCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Event Links & Networks',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            // Event Networks List
            ...widget.event.eventNetworks.map((network) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: network.platformColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      network.platformIcon,
                      color: network.platformColor,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    network.platformName,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    network.url,
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: const Icon(Icons.open_in_new),
                  onTap: () => _launchUrl(network.url),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
