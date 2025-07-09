// ==================================================
// EVENTS SECTION FOR GAME DETAILS SCREEN
// ==================================================

// lib/presentation/widgets/sections/events_section.dart
import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/navigations.dart';
import '../../../domain/entities/event/event.dart';
import '../../../domain/entities/game/game.dart';
import '../../pages/event/widgets/event_card.dart';
import '../custom_shimmer.dart';

class EventsSection extends StatelessWidget {
  final Game game;
  final String? currentUserId;
  final bool showViewAll;
  final int maxDisplayedEvents;

  const EventsSection({
    super.key,
    required this.game,
    this.currentUserId,
    this.showViewAll = true,
    this.maxDisplayedEvents = 6,
  });

  @override
  Widget build(BuildContext context) {
    if (game.events.isEmpty) {
      return const SizedBox.shrink();
    }

    final eventsToShow = game.events.take(maxDisplayedEvents).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingMedium,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.event,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Gaming Events',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _buildSubtitle(),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (showViewAll && game.events.length > maxDisplayedEvents)
                  TextButton(
                    onPressed: () => _navigateToAllEvents(context),
                    child: const Text('View All'),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.paddingSmall),

          // Events List
          SizedBox(
            height: 180,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingMedium,
              ),
              scrollDirection: Axis.horizontal,
              itemCount: eventsToShow.length,
              itemBuilder: (context, index) {
                final event = eventsToShow[index];
                return Container(
                  width: 280,
                  margin: EdgeInsets.only(
                    right: index < eventsToShow.length - 1
                        ? AppConstants.paddingSmall
                        : 0,
                  ),
                  child: EventCard(
                    event: event,
                    onTap: () => _navigateToEventDetails(context, event),
                    showStatus: true,
                    showGamesCount: true,
                  ),
                );
              },
            ),
          ),

          // Event Status Summary
          if (game.events.length > 1)
            Padding(
              padding: const EdgeInsets.only(
                top: AppConstants.paddingSmall,
                left: AppConstants.paddingMedium,
                right: AppConstants.paddingMedium,
              ),
              child: _buildEventStatusSummary(context),
            ),
        ],
      ),
    );
  }

  String _buildSubtitle() {
    final totalEvents = game.events.length;
    final liveEvents = game.events.where((e) => e.isLive).length;
    final upcomingEvents = game.events.where((e) => e.isUpcoming).length;

    if (liveEvents > 0) {
      return '$liveEvents live • $totalEvents total events';
    } else if (upcomingEvents > 0) {
      return '$upcomingEvents upcoming • $totalEvents total events';
    } else {
      return '$totalEvents gaming events';
    }
  }

  Widget _buildEventStatusSummary(BuildContext context) {
    final liveCount = game.events.where((e) => e.isLive).length;
    final upcomingCount = game.events.where((e) => e.isUpcoming).length;
    final pastCount = game.events.where((e) => e.hasEnded).length;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          if (liveCount > 0) ...[
            _buildStatusChip(
              context,
              'Live',
              liveCount.toString(),
              Colors.red,
              Icons.circle,
            ),
            const SizedBox(width: 8),
          ],
          if (upcomingCount > 0) ...[
            _buildStatusChip(
              context,
              'Upcoming',
              upcomingCount.toString(),
              Colors.orange,
              Icons.schedule,
            ),
            const SizedBox(width: 8),
          ],
          if (pastCount > 0)
            _buildStatusChip(
              context,
              'Past',
              pastCount.toString(),
              Colors.grey,
              Icons.history,
            ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(
      BuildContext context,
      String label,
      String count,
      Color color,
      IconData icon,
      ) {
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
            '$count $label',
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

  void _navigateToAllEvents(BuildContext context) {
    Navigations.navigateToAllEvents(
      context,
      game: game,
      events: game.events,
    );
  }

  void _navigateToEventDetails(BuildContext context, Event event) {
    Navigations.navigateToEventDetails(
      context,
      eventId: event.id,
      game: game,
    );
  }
}

// ==================================================
// EVENTS LOADING SECTION (für Shimmer)
// ==================================================

class EventsLoadingSection extends StatelessWidget {
  const EventsLoadingSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Loading
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingMedium,
            ),
            child: Row(
              children: [
                CustomShimmer(
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomShimmer(
                        child: Container(
                          height: 20,
                          width: 120,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      CustomShimmer(
                        child: Container(
                          height: 14,
                          width: 160,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.paddingSmall),

          // Events Cards Loading
          SizedBox(
            height: 180,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingMedium,
              ),
              scrollDirection: Axis.horizontal,
              itemCount: 3,
              itemBuilder: (context, index) {
                return Container(
                  width: 280,
                  margin: EdgeInsets.only(
                    right: index < 2 ? AppConstants.paddingSmall : 0,
                  ),
                  child: Card(
                    child: CustomShimmer(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}