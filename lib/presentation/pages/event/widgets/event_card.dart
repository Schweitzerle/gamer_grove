// ==================================================
// EVENT CARD WIDGET - IMPROVED WITH LOGOS
// ==================================================

// lib/presentation/widgets/event_card.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/image_utils.dart';
import '../../../../core/widgets/cached_image_widget.dart';
import '../../../../domain/entities/event/event.dart';

class EventCard extends StatelessWidget {
  final Event event;
  final VoidCallback? onTap;
  final bool showStatus;
  final bool showGamesCount;
  final bool showFullDescription;
  final bool showNetworks;
  final bool compact;

  const EventCard({
    super.key,
    required this.event,
    this.onTap,
    this.showStatus = true,
    this.showGamesCount = false,
    this.showFullDescription = false,
    this.showNetworks = true,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event Image/Header
            _buildEventHeader(context),

            // Event Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildEventTitle(context),
                    const SizedBox(height: 8),
                    _buildEventTiming(context),

                    if (!compact) ...[
                      if (event.hasDescription) ...[
                        const SizedBox(height: 8),
                        _buildEventDescription(context),
                      ],

                      const Spacer(),

                      _buildEventInfo(context),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventTitle(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            event.name,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            maxLines: compact ? 1 : 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (event.hasLiveStream)
          Container(
            margin: const EdgeInsets.only(left: 8),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.red.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.live_tv, size: 8, color: Colors.red),
                const SizedBox(width: 2),
                Text(
                  'LIVE',
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildEventTiming(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.schedule,
            size: 14,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              _formatEventTime(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventDescription(BuildContext context) {
    final maxLines = showFullDescription ? null : 2;

    return Text(
      event.description!,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        height: 1.3,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      maxLines: maxLines,
      overflow: showFullDescription ? null : TextOverflow.ellipsis,
    );
  }

  Widget _buildBottomInfo(BuildContext context) {
    return Row(
      children: [
        if (showGamesCount && event.hasGames) ...[
          Icon(
            Icons.videogame_asset,
            size: 14,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 4),
          Text(
            '${event.gameCount} games',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],

        if (event.hasVideos) ...[
          if (showGamesCount && event.hasGames)
            const SizedBox(width: 12),
          Icon(
            Icons.play_circle_outline,
            size: 14,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 4),
          Text(
            '${event.videoCount} videos',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],

        const Spacer(),

        // Duration if available
        if (event.duration != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              _formatDuration(event.duration!),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCompactInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timing
        Text(
          _formatEventTime(),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),

        if (showGamesCount && event.hasGames) ...[
          const SizedBox(height: 2),
          Row(
            children: [
              Icon(
                Icons.videogame_asset,
                size: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                '${event.gameCount} games',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildLiveIndicator(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            'LIVE',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    String status;
    if (event.isUpcoming) {
      status = 'Upcoming';
    } else if (event.hasEnded) {
      status = 'Past';
    } else {
      status = 'TBA';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
        ),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  Color _getEventStatusColor() {
    if (event.isLive) return Colors.red;
    if (event.isUpcoming) return Colors.orange;
    if (event.hasEnded) return Colors.grey;
    return Colors.blue;
  }

  IconData _getEventIcon() {
    if (event.isLive) return Icons.circle;
    if (event.isUpcoming) return Icons.schedule;
    if (event.hasEnded) return Icons.history;
    return Icons.event;
  }

  String _formatEventTime() {
    if (event.startTime == null) return 'Time TBA';

    final now = DateTime.now();
    final startTime = event.startTime!;

    if (event.isLive && event.endTime != null) {
      final timeLeft = event.timeUntilEnd!;
      return 'Live • ${_formatDuration(timeLeft)} left';
    } else if (event.isUpcoming) {
      final timeUntil = event.timeUntilStart!;
      return 'Starts in ${_formatDuration(timeUntil)}';
    } else if (event.hasEnded) {
      return 'Ended ${DateFormatter.formatTimeAgo(startTime)}';
    } else {
      return DateFormatter.formatEventTimeCompact(startTime);
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

  Widget _buildEventHeader(BuildContext context) {
    return Container(
      height: compact ? 60 : 80,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getEventStatusColor().withOpacity(0.8),
            _getEventStatusColor().withOpacity(0.6),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Event Logo Background (if available)
          if (event.hasLogoObject)
            Positioned.fill(
              child: Opacity(
                opacity: 0.15,
                child: CachedImageWidget(
                  imageUrl: event.eventLogo!.bestUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),

          // Content
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Event Logo
                _buildEventLogo(context),

                const SizedBox(width: 12),

                // Live Indicator
                if (event.isLive && showStatus)
                  _buildLiveIndicator(context),

                const Spacer(),

                // Status Badge
                if (showStatus && !event.isLive)
                  _buildStatusBadge(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventLogo(BuildContext context) {
    if (event.hasLogoObject) {
      return Container(
        width: compact ? 32 : 40,
        height: compact ? 32 : 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: CachedImageWidget(
            imageUrl: event.eventLogo!.bestUrl,
            fit: BoxFit.cover,
          ),
        ),
      );
    } else {
      return Container(
        width: compact ? 32 : 40,
        height: compact ? 32 : 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.event,
          color: Colors.white,
          size: compact ? 16 : 20,
        ),
      );
    }
  }

  Widget _buildEventInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Featured Games
        if (showGamesCount && event.hasGameObjects)
          _buildInfoChip(
            context,
            Icons.videogame_asset,
            '${event.games.length} games',
            Colors.blue,
          ),

        // Event Networks
        if (showNetworks && event.hasNetworkObjects) ...[
          const SizedBox(height: 4),
          _buildNetworkChips(context),
        ],
      ],
    );
  }

  Widget _buildNetworkChips(BuildContext context) {
    final networks = event.eventNetworks.take(3).toList();

    return Wrap(
      spacing: 4,
      children: networks.map((network) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: network.platformColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: network.platformColor.withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                network.platformIcon,
                size: 10,
                color: network.platformColor,
              ),
              const SizedBox(width: 2),
              Text(
                network.platformName,
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w600,
                  color: network.platformColor,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildInfoChip(BuildContext context, IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
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
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ==================================================
// CUSTOM PAINTER FOR EVENT HEADER BACKGROUND
// ==================================================

class EventHeaderPainter extends CustomPainter {
  final Color color;

  EventHeaderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();

    // Create subtle geometric pattern
    for (double x = 0; x < size.width; x += 25) {
      for (double y = 0; y < size.height; y += 25) {
        canvas.drawCircle(
          Offset(x, y),
          1.5,
          paint..color = color.withOpacity(0.4),
        );
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
