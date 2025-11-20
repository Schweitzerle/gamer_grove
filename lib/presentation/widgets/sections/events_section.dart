// ==================================================
// EVENTS SECTION FOR GAME DETAILS SCREEN
// ==================================================

// lib/presentation/widgets/sections/events_section.dart
import 'package:flutter/material.dart';
import 'package:gamer_grove/core/constants/app_constants.dart';
import 'package:gamer_grove/core/utils/navigations.dart';
import 'package:gamer_grove/domain/entities/event/event.dart';
import 'package:gamer_grove/domain/entities/game/game.dart';
import 'package:gamer_grove/presentation/pages/event/widgets/event_card.dart';
import 'package:gamer_grove/presentation/widgets/custom_shimmer.dart';

class EventsSection extends StatelessWidget {

  const EventsSection({
    required this.game, super.key,
    this.currentUserId,
    this.showViewAll = true,
    this.maxDisplayedEvents = 6,
  });
  final Game game;
  final String? currentUserId;
  final bool showViewAll;
  final int maxDisplayedEvents;

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
                    showGamesCount: true,
                  ),
                );
              },
            ),
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