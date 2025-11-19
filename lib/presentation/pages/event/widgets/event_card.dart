// ==================================================
// EVENT CARD WIDGET - MODERN ENHANCED UI
// ==================================================

// lib/presentation/widgets/event_card.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
      elevation: 4,
      shadowColor: _getEventStatusColor().withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: compact ? 140 : 220,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.surfaceContainerHighest,
                Theme.of(context).colorScheme.surfaceContainer,
              ],
            ),
          ),
          child: Stack(
            children: [
              // Background Image with Overlay
              if (event.hasLogoObject)
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.08,
                    child: CachedImageWidget(
                      imageUrl: event.eventLogo!.bestUrl,
                    ),
                  ),
                ),

              // Main Content
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with Date
                  _buildModernHeader(context),

                  // Content
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      child: _buildEventContent(context),
                    ),
                  ),

                  // Footer with Duration
                  if (!compact) _buildModernFooter(context),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Modern Header with Date Badge
  Widget _buildModernHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 8, bottom: 4, left: 16, right: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Event Logo
          if (event.hasLogoObject) _buildRoundedLogo(context),
          if (event.hasLogoObject) const SizedBox(width: 12),

          // Title
          Expanded(
            child: _buildEventTitle(context),
          ),

          const SizedBox(width: 8),

          // Status Badge (klein, neben Date)
          _buildCompactStatusBadge(context),

          const SizedBox(width: 8),

          // Date Badge
          _buildDateBadge(context),
        ],
      ),
    );
  }

  Widget _buildRoundedLogo(BuildContext context) {
    return Container(
      width: compact ? 40 : 56,
      height: compact ? 40 : 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: _getEventStatusColor().withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CachedImageWidget(
          imageUrl: event.eventLogo!.bestUrl,
        ),
      ),
    );
  }

  // Kompakter Status Badge (klein, passt neben Date Badge)
  Widget _buildCompactStatusBadge(BuildContext context) {
    if (event.isLive) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withValues(alpha: 0.4),
              blurRadius: 4,
              spreadRadius: 0.5,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 4,
              height: 4,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 3),
            const Text(
              'LIVE',
              style: TextStyle(
                color: Colors.white,
                fontSize: 8,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      );
    }

    // Für andere Status: Mini Icon Badge
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: _getEventStatusColor().withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: _getEventStatusColor().withValues(alpha: 0.3),
        ),
      ),
      child: Icon(
        _getEventIcon(),
        size: 14,
        color: _getEventStatusColor(),
      ),
    );
  }

  Widget _buildDateBadge(BuildContext context) {
    if (event.startTime == null) {
      return _buildDateBadgeContent(
        context,
        day: '?',
        month: 'TBA',
        isActive: false,
      );
    }

    final date = event.startTime!;
    final day = DateFormat('dd').format(date);
    final month = DateFormat('MMM').format(date).toUpperCase();

    return _buildDateBadgeContent(
      context,
      day: day,
      month: month,
      isActive: event.isLive || event.isUpcoming,
    );
  }

  Widget _buildDateBadgeContent(
    BuildContext context, {
    required String day,
    required String month,
    required bool isActive,
  }) {
    return Container(
      width: compact ? 56 : 64,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isActive
              ? [
                  _getEventStatusColor().withValues(alpha: 0.9),
                  _getEventStatusColor(),
                ]
              : [
                  Colors.grey.shade600,
                  Colors.grey.shade700,
                ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            day,
            style: TextStyle(
              fontSize: compact ? 20 : 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            month,
            style: TextStyle(
              fontSize: compact ? 9 : 11,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.9),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventContent(BuildContext context) {
    if (compact) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Description - nimmt den verfügbaren Platz
        if (event.hasDescription)
          Expanded(
            child: _buildModernDescription(context),
          )
        else
          // Fallback wenn keine Description vorhanden
          const SizedBox(
            height: 0,
          ),

        // Optional: Stream Badge falls vorhanden
        if (event.hasLiveStream) ...[
          const SizedBox(height: 8),
          _buildStreamBadge(context),
        ],
      ],
    );
  }

  Widget _buildStreamBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.purple.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: Colors.purple.withValues(alpha: 0.3),
        ),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.play_circle_filled,
            size: 12,
            color: Colors.purple,
          ),
          SizedBox(width: 4),
          Text(
            'Stream Available',
            style: TextStyle(
              color: Colors.purple,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventTitle(BuildContext context) {
    return Text(
      event.name,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildModernDescription(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: SingleChildScrollView(
        child: Text(
          event.description!,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                height: 1.5,
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurface,
              ),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  // Modern Footer with Timing and Info
  Widget _buildModernFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withValues(alpha: 0.3),
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Info Chips Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Timing Row (jetzt im Footer)
              _buildCompactTimingRow(context),

              const SizedBox(width: 8),

              // Games Count
              if (showGamesCount && event.hasGameObjects) ...[
                _buildFooterChip(
                  context,
                  icon: Icons.videogame_asset,
                  label: '${event.games.length}',
                  color: Colors.blue,
                ),
                const SizedBox(width: 8),
              ],

              // Videos Count
              if (event.hasVideos) ...[
                _buildFooterChip(
                  context,
                  icon: Icons.play_circle_outline,
                  label: '${event.videoCount}',
                  color: Colors.purple,
                ),
                const SizedBox(width: 8),
              ],

              const Spacer(),

              // Duration Badge
              if (event.duration != null) _buildDurationBadge(context),
            ],
          ),
        ],
      ),
    );
  }

  // Kompakte Timing Row für Footer
  Widget _buildCompactTimingRow(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.access_time_rounded,
            size: 16,
            color: _getEventStatusColor(),
          ),
          const SizedBox(width: 8),
          Text(
            _formatEventTime(),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildFooterChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDurationBadge(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _getEventStatusColor().withValues(alpha: 0.2),
                _getEventStatusColor().withValues(alpha: 0.15),
              ],
            ),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _getEventStatusColor().withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.timer_outlined,
                size: 14,
                color: _getEventStatusColor(),
              ),
              const SizedBox(width: 4),
              Text(
                _formatDuration(event.duration!),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: _getEventStatusColor(),
                ),
              ),
            ],
          ),
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

    if (event.isLive && event.endTime != null) {
      final timeLeft = event.timeUntilEnd!;
      return 'Live now • ${_formatDuration(timeLeft)} remaining';
    } else if (event.isUpcoming) {
      final timeUntil = event.timeUntilStart!;
      if (timeUntil.inDays > 0) {
        return 'Starts in ${_formatDuration(timeUntil)}';
      } else if (timeUntil.inHours > 0) {
        return 'Starts in ${timeUntil.inHours}h ${timeUntil.inMinutes % 60}m';
      } else {
        return 'Starts in ${timeUntil.inMinutes}m';
      }
    } else if (event.hasEnded) {
      return 'Ended ${DateFormatter.formatTimeAgo(event.startTime!)}';
    } else {
      return DateFormatter.formatEventTimeCompact(event.startTime!);
    }
  }

  String _formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      final hours = duration.inHours % 24;
      if (hours > 0) {
        return '${duration.inDays}d ${hours}h';
      }
      return '${duration.inDays} day${duration.inDays > 1 ? 's' : ''}';
    } else if (duration.inHours > 0) {
      final minutes = duration.inMinutes % 60;
      if (minutes > 0) {
        return '${duration.inHours}h ${minutes}m';
      }
      return '${duration.inHours} hour${duration.inHours > 1 ? 's' : ''}';
    } else {
      return '${duration.inMinutes} min';
    }
  }
}
