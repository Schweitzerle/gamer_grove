// ==================================================
// EVENT DETAILS SCREEN - IMPROVED UI CONSISTENCY
// ==================================================

// lib/presentation/pages/event_detail/event_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/navigations.dart';
import '../../../core/utils/image_utils.dart';
import '../../../core/widgets/cached_image_widget.dart';
import '../../../domain/entities/event/event.dart';
import '../../../domain/entities/game/game.dart';
import '../../widgets/game_card.dart';
import '../../widgets/accordion_tile.dart';

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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Event Hero Section
          _buildEventHero(),

          // Event Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Event Info Card
                  _buildEventInfoCard(),

                  const SizedBox(height: AppConstants.paddingMedium),

                  // Featured Games (now with actual Game objects!)
                  if (widget.event.hasGameObjects)
                    _buildFeaturedGamesCard(context),

                  const SizedBox(height: 16),

                  // Event Networks (now with actual EventNetwork objects!)
                  if (widget.event.hasNetworkObjects)
                    _buildEventNetworksCard(context),

                  // Featured Games Section
                  if (widget.showGames &&
                      widget.featuredGames != null &&
                      widget.featuredGames!.isNotEmpty)
                    _buildFeaturedGamesCard(context),

                  const SizedBox(height: AppConstants.paddingMedium),

                  // Event Details Accordion
                  _buildEventDetailsAccordion(),
                ],
              ),
            ),
          ),

          // Bottom spacing
          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
    );
  }

  Widget _buildEventHero() {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: _getEventStatusColor(),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.share, color: Colors.white),
          onPressed: _shareEvent,
        ),
        if (widget.event.hasLiveStream)
          IconButton(
            icon: const Icon(Icons.live_tv, color: Colors.white),
            onPressed: _openLiveStream,
          ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                _getEventStatusColor().withOpacity(0.8),
                _getEventStatusColor().withOpacity(0.6),
              ],
            ),
          ),
          child: Stack(
            children: [
              // Event Logo Background (if available)
              if (widget.event.hasLogo)
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.1,
                    child: CachedImageWidget(
                      imageUrl: widget.event.eventLogo!.bestUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

              // Background Pattern
              Positioned.fill(
                child: CustomPaint(
                  painter: EventHeroPainter(
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),

              // Content
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status Badge
                    _buildStatusBadge(),

                    const SizedBox(height: 12),

                    // Event Logo (if available)
                    if (widget.event.eventLogoId != null)
                      Container(
                        width: 80,
                        height: 80,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
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
                      ),

                    // Event Name
                    Text(
                      widget.event.name,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            offset: const Offset(0, 2),
                            blurRadius: 4,
                            color: Colors.black.withOpacity(0.5),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Event Timing
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _formatEventTime(),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEventInfoCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getEventStatusColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.info_outline,
                    color: _getEventStatusColor(),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Event Information',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppConstants.paddingMedium),

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

            // Live Stream
            if (widget.event.hasLiveStream)
              Column(
                children: [
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _openLiveStream,
                      icon: const Icon(Icons.live_tv),
                      label: Text(widget.event.isLive ? 'Watch Live' : 'View Stream'),
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
    );
  }


  Widget _buildEventDetailsAccordion() {
    return Card(
      elevation: 2,
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerLowest,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  'Event Details',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

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

                    // TODO: Add actual event networks when available
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

          if (widget.event.hasVideos)
            AccordionTile(
              title: 'Videos & Trailers',
              icon: Icons.play_circle_outline,
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.paddingMedium),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.play_circle_outline),
                      title: const Text('Event Videos'),
                      subtitle: Text('${widget.event.videoCount} videos available'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        // TODO: Navigate to event videos
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Event videos coming soon!')),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

          // Technical Details
          AccordionTile(
            title: 'Technical Details',
            icon: Icons.settings,
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              child: Column(
                children: [
                  _buildTechnicalRow('Event ID', widget.event.id.toString()),
                  if (widget.event.slug != null)
                    _buildTechnicalRow('Slug', widget.event.slug!),
                  if (widget.event.checksum.isNotEmpty)
                    _buildTechnicalRow('Checksum', widget.event.checksum),
                  if (widget.event.createdAt != null)
                    _buildTechnicalRow(
                      'Created',
                      DateFormatter.formatEventDateTime(widget.event.createdAt!),
                    ),
                  if (widget.event.updatedAt != null)
                    _buildTechnicalRow(
                      'Updated',
                      DateFormatter.formatEventDateTime(widget.event.updatedAt!),
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
            color: statusColor ?? Theme.of(context).colorScheme.onSurfaceVariant,
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

  Widget _buildTechnicalRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.event.isLive) ...[
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            _getEventStatusText(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
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

  void _shareEvent() {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sharing "${widget.event.name}" coming soon!')),
    );
  }

  void _openLiveStream() {
    if (widget.event.hasLiveStream) {
      _launchUrl(widget.event.liveStreamUrl!);
    }
  }

  void _showAllGames() {
    if (widget.featuredGames != null) {
      Navigations.navigateToLocalAllGames(
        context,
        title: '${widget.event.name} Games',
        subtitle: 'Games featured at this event',
        games: widget.featuredGames!,
        showFilters: true,
      );
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

  Widget _buildFeaturedGamesCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Featured Games',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${widget.event.games.length} games featured at this event',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),

            // Horizontal Game List
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: widget.event.games.length,
                itemBuilder: (context, index) {
                  final game = widget.event.games[index];
                  return Container(
                    width: 140,
                    margin: const EdgeInsets.only(right: 12),
                    child: GameCard(
                      game: game,
                      onTap: () => Navigations.navigateToGameDetail(game.id, context),
                    ),
                  );
                },
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
            }).toList(),
          ],
        ),
      ),
    );
  }
}

// ==================================================
// CUSTOM PAINTER FOR EVENT HERO BACKGROUND
// ==================================================

class EventHeroPainter extends CustomPainter {
  final Color color;

  EventHeroPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Create geometric pattern
    for (double x = 0; x < size.width; x += 40) {
      for (double y = 0; y < size.height; y += 40) {
        canvas.drawCircle(
          Offset(x, y),
          2,
          paint..color = color.withOpacity(0.4),
        );
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
