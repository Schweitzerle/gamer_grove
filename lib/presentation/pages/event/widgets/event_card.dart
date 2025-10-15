// ==================================================
// EVENT CARD WIDGET - RADICAL LAYOUT FIX
// ==================================================

// lib/presentation/widgets/event_card.dart
import 'package:flutter/material.dart';
import '../../../../core/utils/date_formatter.dart';
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
        child: Container(
          constraints: BoxConstraints(
            maxHeight:
                compact ? 120 : 180, // ✅ RADICAL FIX: Absolute max height
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Event Header - Fixed height
              _buildEventHeader(context),

              // Event Content - Flexible with overflow protection
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8), // ✅ Reduced padding
                  child: _buildEventContent(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEventContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Title - Always shown
        _buildEventTitle(context),

        const SizedBox(height: 4), // ✅ Minimal spacing

        // Timing - Always shown
        _buildEventTiming(context),

        // Conditional content based on available space
        if (!compact) ...[
          const SizedBox(height: 4),
          Expanded(
            // ✅ Use remaining space efficiently
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Description - only if space allows
                if (event.hasDescription)
                  Flexible(
                    child: _buildEventDescription(context),
                  ),

                // Push info to bottom
                const Spacer(),

                // Bottom info - minimal
                _buildMinimalEventInfo(context),
              ],
            ),
          ),
        ] else ...[
          // Compact mode - minimal additional info
          const SizedBox(height: 2),
          _buildCompactInfo(context),
        ],
      ],
    );
  }

  Widget _buildEventTitle(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            event.name,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  // ✅ Smaller title
                  fontWeight: FontWeight.w600,
                ),
            maxLines: 1, // ✅ Always single line
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (event.hasLiveStream)
          Container(
            margin: const EdgeInsets.only(left: 4),
            padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(3),
              border: Border.all(color: Colors.red.withOpacity(0.3)),
            ),
            child: const Text(
              'LIVE',
              style: TextStyle(
                fontSize: 7, // ✅ Very small
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEventTiming(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 6, vertical: 3), // ✅ Very compact
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.schedule,
            size: 10, // ✅ Very small icon
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              _formatEventTime(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: 10, // ✅ Small text
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
    return Text(
      event.description!,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            height: 1.2,
            fontSize: 9, // ✅ Very small text
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
      maxLines: 2, // ✅ Maximum 2 lines
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildMinimalEventInfo(BuildContext context) {
    final List<Widget> chips = [];

    // Only show most important info
    if (showGamesCount && event.hasGameObjects && event.games.isNotEmpty) {
      chips.add(_buildMiniChip(
        context,
        Icons.videogame_asset,
        '${event.games.length}',
        Colors.blue,
      ));
    }

    if (event.hasVideos) {
      chips.add(_buildMiniChip(
        context,
        Icons.play_circle_outline,
        '${event.videoCount}',
        Colors.purple,
      ));
    }

    if (chips.isEmpty) return const SizedBox(height: 12); // Maintain height

    return SizedBox(
      height: 16, // ✅ Fixed height
      child: Row(
        children: [
          ...chips,
          const Spacer(),
          if (event.duration != null)
            Text(
              _formatDuration(event.duration!),
              style: TextStyle(
                fontSize: 8,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCompactInfo(BuildContext context) {
    return SizedBox(
      height: 14, // ✅ Fixed minimal height
      child: Row(
        children: [
          Icon(
            _getEventIcon(),
            size: 10,
            color: _getEventStatusColor(),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              _getEventStatusText(),
              style: TextStyle(
                fontSize: 9,
                color: _getEventStatusColor(),
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (showGamesCount && event.hasGameObjects)
            Text(
              '${event.games.length}G',
              style: TextStyle(
                fontSize: 8,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMiniChip(
      BuildContext context, IconData icon, String text, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 4),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 8, color: color),
          const SizedBox(width: 2),
          Text(
            text,
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventHeader(BuildContext context) {
    return Container(
      height: compact ? 40 : 60, // ✅ Very compact headers
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
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              children: [
                // Event Logo
                _buildEventLogo(context),

                const SizedBox(width: 6),

                // Live Indicator
                if (event.isLive && showStatus) _buildLiveIndicator(context),

                const Spacer(),

                // Status Badge
                if (showStatus && !event.isLive) _buildStatusBadge(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventLogo(BuildContext context) {
    final size = compact ? 20.0 : 28.0; // ✅ Much smaller logos

    if (event.hasLogoObject) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: CachedImageWidget(
            imageUrl: event.eventLogo!.bestUrl,
            fit: BoxFit.cover,
          ),
        ),
      );
    } else {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(
          Icons.event,
          color: Colors.white,
          size: size * 0.6,
        ),
      );
    }
  }

  Widget _buildLiveIndicator(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 3,
            height: 3,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 2),
          const Text(
            'LIVE',
            style: TextStyle(
              color: Colors.white,
              fontSize: 7,
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
      status = 'Soon';
    } else if (event.hasEnded) {
      status = 'Past';
    } else {
      status = 'TBA';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
        ),
      ),
      child: Text(
        status,
        style: const TextStyle(
          fontSize: 7,
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

  String _getEventStatusText() {
    if (event.isLive) return 'LIVE NOW';
    if (event.isUpcoming) return 'UPCOMING';
    if (event.hasEnded) return 'ENDED';
    return 'TBA';
  }

  IconData _getEventIcon() {
    if (event.isLive) return Icons.circle;
    if (event.isUpcoming) return Icons.schedule;
    if (event.hasEnded) return Icons.history;
    return Icons.event;
  }

  String _formatEventTime() {
    if (event.startTime == null) return 'Time TBA';

    if (event.isLive && event.endTime != null) {
      final timeLeft = event.timeUntilEnd!;
      return 'Live • ${_formatDuration(timeLeft)} left';
    } else if (event.isUpcoming) {
      final timeUntil = event.timeUntilStart!;
      return 'In ${_formatDuration(timeUntil)}';
    } else if (event.hasEnded) {
      return 'Ended ${DateFormatter.formatTimeAgo(event.startTime!)}';
    } else {
      return DateFormatter.formatEventTimeCompact(event.startTime!);
    }
  }

  String _formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}d';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h';
    } else {
      return '${duration.inMinutes}m';
    }
  }
}
