import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../domain/entities/event/event.dart';
import '../../injection_container.dart';
import '../../presentation/blocs/auth/auth_bloc.dart';
import '../../presentation/blocs/event/event_bloc.dart';
import '../../presentation/blocs/event/event_event.dart';
import '../../presentation/blocs/game/game_bloc.dart';
import '../../presentation/pages/event/event_detail_page.dart';
import '../../presentation/pages/event/event_details_screen.dart';
import '../../presentation/pages/event/widgets/all_events_screen.dart';
import '../../presentation/pages/game_detail/game_detail_page.dart';
import '../../presentation/pages/test/igdb_test_page.dart';
import '../../presentation/pages/test/supabase_test_page.dart';
// 🆕 NEW: Import Local All Games Screen
import '../../presentation/pages/all_games/local_all_games_screen.dart';
import '../../domain/entities/game/game.dart';
import '../../domain/entities/franchise.dart';
import '../../domain/entities/collection/collection.dart';
import '../constants/app_constants.dart';

class Navigations {
  static void navigateToGameDetail(int gameId, BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => sl<GameBloc>(),
            ),
            BlocProvider.value(
              value: context.read<AuthBloc>(),
            ),
          ],
          child: GameDetailPage(gameId: gameId),
        ),
      ),
    );
  }

  // ==========================================
  // 🆕 LOCAL ALL GAMES METHODS (mit bereits gefetchten Daten)
  // ==========================================

  /// Generic method for local all games screen
  static void navigateToLocalAllGames(
      BuildContext context, {
        required String title,
        String? subtitle,
        required List<Game> games,
        bool showFilters = true,
        bool showSearch = true,
        bool blurRated = false,
        bool showViewToggle = true,
      }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LocalAllGamesScreen(
          title: title,
          subtitle: subtitle,
          games: games,
          showFilters: showFilters,
          showSearch: showSearch,
          blurRated: blurRated,
          showViewToggle: showViewToggle,
        ),
      ),
    );
  }

  /// Navigate to all games in a franchise
  static void navigateToFranchiseGames(
      BuildContext context,
      Franchise franchise,
      ) {
    final games = franchise.games ?? [];
    navigateToLocalAllGames(
      context,
      title: franchise.name,
      subtitle: franchise == franchise ? 'Main Franchise' : 'Franchise',
      games: games,
      blurRated: true, // Show rating status for franchises
      showFilters: true,
    );
  }

  /// Navigate to all games in a collection
  static void navigateToCollectionGames(
      BuildContext context,
      Collection collection,
      ) {
    final games = collection.games ?? [];
    navigateToLocalAllGames(
      context,
      title: collection.name,
      subtitle: 'Collection',
      games: games,
      blurRated: true, // Show rating status for collections
      showFilters: true,
    );
  }

  /// Navigate to similar games list
  static void navigateToSimilarGames(
      BuildContext context,
      String gameName,
      List<Game> similarGames,
      ) {
    navigateToLocalAllGames(
      context,
      title: 'Similar to $gameName',
      subtitle: '${similarGames.length} similar games',
      games: similarGames,
      blurRated: true,
      showFilters: false, // Simpler version for similar games
      showSearch: true,
    );
  }

  /// Navigate to game DLCs list
  static void navigateToGameDLCs(
      BuildContext context,
      String gameName,
      List<Game> dlcs,
      ) {
    navigateToLocalAllGames(
      context,
      title: '$gameName DLCs',
      subtitle: '${dlcs.length} downloadable content',
      games: dlcs,
      blurRated: true,
      showFilters: false,
    );
  }

  /// Navigate to game expansions list
  static void navigateToGameExpansions(
      BuildContext context,
      String gameName,
      List<Game> expansions,
      ) {
    navigateToLocalAllGames(
      context,
      title: '$gameName Expansions',
      subtitle: '${expansions.length} expansions',
      games: expansions,
      blurRated: true,
      showFilters: false,
    );
  }

  /// Navigate to user's wishlist (local data)
  static void navigateToUserWishlist(
      BuildContext context,
      List<Game> wishlistGames,
      ) {
    navigateToLocalAllGames(
      context,
      title: 'My Wishlist',
      subtitle: '${wishlistGames.length} games',
      games: wishlistGames,
      blurRated: true, // Highlight which wishlist games are already rated
      showFilters: true,
    );
  }

  /// Navigate to user's rated games (local data)
  static void navigateToUserRatedGames(
      BuildContext context,
      List<Game> ratedGames,
      ) {
    navigateToLocalAllGames(
      context,
      title: 'My Rated Games',
      subtitle: '${ratedGames.length} games rated',
      games: ratedGames,
      blurRated: false, // All are rated, so no need to blur
      showFilters: true,
    );
  }

  /// Navigate to user's recommended games (local data)
  static void navigateToUserRecommendedGames(
      BuildContext context,
      List<Game> recommendedGames,
      ) {
    navigateToLocalAllGames(
      context,
      title: 'My Recommendations',
      subtitle: '${recommendedGames.length} games recommended',
      games: recommendedGames,
      blurRated: true, // Show which recommendations are already rated
      showFilters: true,
    );
  }

  // ==========================================
  // 🔄 API-BASED METHODS (für später - fetchen neue Daten)
  // ==========================================
  // Diese Methoden bleiben als TODOs für API-basierte Screens

  static void navigateToPopularGames(BuildContext context) {
    // TODO: Implement API-based popular games screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Popular games list coming soon!')),
    );
  }

  static void navigateToRatedGames(BuildContext context) {
    // TODO: Implement API-based rated games screen (öffentliche Listen)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Top rated games list coming soon!')),
    );
  }

  static void navigateToTopRatedGames(BuildContext context) {
    // TODO: Implement API-based top rated games screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Top rated games list coming soon!')),
    );
  }

  static void navigateToUpcomingGames(BuildContext context) {
    // TODO: Implement API-based upcoming games screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Upcoming games list coming soon!')),
    );
  }

  static void navigateToLatestReleases(BuildContext context) {
    // TODO: Implement API-based latest releases screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Latest games list coming soon!')),
    );
  }

  static void navigateToRecommendations(BuildContext context) {
    // TODO: Implement API-based global recommendations screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Global recommendations list coming soon!')),
    );
  }


  static void navigateToSearch(BuildContext context) {
    // TODO: Implement API-based search results screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Search screen coming soon!')),
    );
  }

  // ==========================================
  // 🎮 FRANCHISE & COLLECTION DETAIL SCREENS (für später)
  // ==========================================

  static void navigateToFranchiseDetail(BuildContext context, int franchiseId) {
    // TODO: Implement franchise detail screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Franchise detail screen coming soon!')),
    );
  }

  static void navigateToCollectionDetail(BuildContext context, int collectionId) {
    // TODO: Implement collection detail screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Collection detail screen coming soon!')),
    );
  }

  // ==========================================
  // 🧪 TEST SCREENS
  // ==========================================

  static void navigateToSupabaseTest(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SupabaseTestPage(),
      ),
    );
  }

  static void navigateToIGDBTest(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const IGDBTestPage(),
      ),
    );
  }

  static void navigateToAllEvents(
      BuildContext context, {
        required Game game,
        required List<Event> events,
        String? customTitle,
        String? customSubtitle,
      }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AllEventsScreen(
          title: customTitle ?? '${game.name} Events',
          subtitle: customSubtitle ?? '${events.length} gaming events',
          events: events,
          game: game,
          showFilters: true,
          showSearch: true,
        ),
      ),
    );
  }

  /// Navigate to all events screen (generic)
  static void navigateToAllEventsGeneric(
      BuildContext context, {
        required String title,
        String? subtitle,
        required List<Event> events,
        Game? game,
        bool showFilters = true,
        bool showSearch = true,
      }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AllEventsScreen(
          title: title,
          subtitle: subtitle,
          events: events,
          game: game,
          showFilters: showFilters,
          showSearch: showSearch,
        ),
      ),
    );
  }

  /// Navigate to event details screen
  static void navigateToEventDetails(
      BuildContext context, {
        required int eventId,
        Game? game,
      }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => sl<EventBloc>()
                ..add(GetEventDetailsEvent(eventId: eventId)),
            ),
            BlocProvider.value(
              value: context.read<AuthBloc>(),
            ),
          ],
          child: EventDetailPage(
            eventId: eventId,
            game: game,
          ),
        ),
      ),
    );
  }

  /// Navigate to event details screen with event object
  static void navigateToEventDetailsWithEvent(
      BuildContext context, {
        required Event event,
        List<Game>? featuredGames,
      }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EventDetailScreen(
          event: event,
          featuredGames: featuredGames,
          showGames: true,
        ),
      ),
    );
  }

  /*
  /// Navigate to current/live events screen
  static void navigateToCurrentEvents(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => sl<EventBloc>()
                ..add(const GetCurrentEventsEvent()),
            ),
            BlocProvider.value(
              value: context.read<AuthBloc>(),
            ),
          ],
          child: const CurrentEventsPage(),
        ),
      ),
    );
  }

  /// Navigate to upcoming events screen
  static void navigateToUpcomingEvents(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => sl<EventBloc>()
                ..add(const GetUpcomingEventsEvent()),
            ),
            BlocProvider.value(
              value: context.read<AuthBloc>(),
            ),
          ],
          child: const UpcomingEventsPage(),
        ),
      ),
    );
  }

  /// Navigate to events by date range
  static void navigateToEventsByDateRange(
      BuildContext context, {
        DateTime? startDate,
        DateTime? endDate,
        String? title,
      }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => sl<EventBloc>()
                ..add(GetEventsByDateRangeEvent(
                  startDate: startDate,
                  endDate: endDate,
                )),
            ),
            BlocProvider.value(
              value: context.read<AuthBloc>(),
            ),
          ],
          child: EventsByDateRangePage(
            startDate: startDate,
            endDate: endDate,
            title: title,
          ),
        ),
      ),
    );
  }

  /// Navigate to events search screen
  static void navigateToEventsSearch(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => sl<EventBloc>(),
            ),
            BlocProvider.value(
              value: context.read<AuthBloc>(),
            ),
          ],
          child: const EventsSearchPage(),
        ),
      ),
    );
  }

   */

  // ==========================================
  // 🎪 EVENT-SPECIFIC GAME NAVIGATION
  // ==========================================

  /// Navigate to games featured at an event
  static void navigateToEventGames(
      BuildContext context, {
        required Event event,
        required List<Game> games,
      }) {
    navigateToLocalAllGames(
      context,
      title: '${event.name} Games',
      subtitle: 'Games featured at this event',
      games: games,
      showFilters: true,
      showSearch: true,
      blurRated: true,
    );
  }

  /// Navigate to all games that have events
  static void navigateToGamesWithEvents(BuildContext context) {
    // TODO: Implement games with events screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Games with events list coming soon!')),
    );
  }

  // ==========================================
  // 🔗 EXTERNAL EVENT LINKS
  // ==========================================

  /// Open event live stream
  static Future<void> openEventLiveStream(
      BuildContext context,
      Event event,
      ) async {
    if (!event.hasLiveStream) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No live stream available for this event')),
      );
      return;
    }

    try {
      final uri = Uri.parse(event.liveStreamUrl!);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        throw Exception('Could not launch ${event.liveStreamUrl}');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open live stream: $e')),
        );
      }
    }
  }

  /// Share event
  static void shareEvent(BuildContext context, Event event) {
    // TODO: Implement event sharing with proper deep links
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sharing "${event.name}" coming soon!')),
    );
  }

  // ==========================================
  // 🎪 EVENT UTILITY METHODS
  // ==========================================

  /// Show event quick actions bottom sheet
  static void showEventQuickActions(
      BuildContext context,
      Event event, {
        List<Game>? featuredGames,
      }) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => EventQuickActionsSheet(
        event: event,
        featuredGames: featuredGames,
      ),
    );
  }

  /// Show event filter options
  static void showEventFilterOptions(
      BuildContext context, {
        required Function(EventStatusFilter) onFilterChanged,
        required EventStatusFilter currentFilter,
      }) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => EventFilterSheet(
        onFilterChanged: onFilterChanged,
        currentFilter: currentFilter,
      ),
    );
  }

  // ==========================================
  // 🎪 BULK EVENT OPERATIONS (for later)
  // ==========================================

  /// Navigate to event calendar view
  static void navigateToEventCalendar(BuildContext context) {
    // TODO: Implement event calendar view
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Event calendar coming soon!')),
    );
  }

  /// Navigate to event notifications settings
  static void navigateToEventNotifications(BuildContext context) {
    // TODO: Implement event notifications settings
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Event notifications settings coming soon!')),
    );
  }
}




// ==================================================
// EVENT QUICK ACTIONS SHEET
// ==================================================

class EventQuickActionsSheet extends StatelessWidget {
  final Event event;
  final List<Game>? featuredGames;

  const EventQuickActionsSheet({
    super.key,
    required this.event,
    this.featuredGames,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            event.name,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppConstants.paddingMedium),

          // View Details
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('View Details'),
            onTap: () {
              Navigator.pop(context);
              Navigations.navigateToEventDetailsWithEvent(
                context,
                event: event,
                featuredGames: featuredGames,
              );
            },
          ),

          // Live Stream (if available)
          if (event.hasLiveStream)
            ListTile(
              leading: const Icon(Icons.live_tv, color: Colors.red),
              title: Text(event.isLive ? 'Watch Live' : 'View Stream'),
              subtitle: event.isLive ? const Text('Currently live') : null,
              onTap: () {
                Navigator.pop(context);
                Navigations.openEventLiveStream(context, event);
              },
            ),

          // Featured Games (if available)
          if (featuredGames != null && featuredGames!.isNotEmpty)
            ListTile(
              leading: const Icon(Icons.videogame_asset),
              title: const Text('Featured Games'),
              subtitle: Text('${featuredGames!.length} games'),
              onTap: () {
                Navigator.pop(context);
                Navigations.navigateToEventGames(
                  context,
                  event: event,
                  games: featuredGames!,
                );
              },
            ),

          // Share Event
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text('Share Event'),
            onTap: () {
              Navigator.pop(context);
              Navigations.shareEvent(context, event);
            },
          ),
        ],
      ),
    );
  }
}

// ==================================================
// EVENT FILTER SHEET
// ==================================================

class EventFilterSheet extends StatelessWidget {
  final Function(EventStatusFilter) onFilterChanged;
  final EventStatusFilter currentFilter;

  const EventFilterSheet({
    super.key,
    required this.onFilterChanged,
    required this.currentFilter,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filter Events',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppConstants.paddingMedium),

          ...EventStatusFilter.values.map((filter) {
            final isSelected = currentFilter == filter;
            return ListTile(
              leading: Icon(
                _getFilterIcon(filter),
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : null,
              ),
              title: Text(
                _getFilterLabel(filter),
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.w600 : null,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
              ),
              trailing: isSelected
                  ? Icon(
                Icons.check,
                color: Theme.of(context).colorScheme.primary,
              )
                  : null,
              onTap: () {
                onFilterChanged(filter);
                Navigator.pop(context);
                HapticFeedback.lightImpact();
              },
            );
          }).toList(),
        ],
      ),
    );
  }

  String _getFilterLabel(EventStatusFilter filter) {
    switch (filter) {
      case EventStatusFilter.all:
        return 'All Events';
      case EventStatusFilter.live:
        return 'Live Events';
      case EventStatusFilter.upcoming:
        return 'Upcoming Events';
      case EventStatusFilter.past:
        return 'Past Events';
    }
  }

  IconData _getFilterIcon(EventStatusFilter filter) {
    switch (filter) {
      case EventStatusFilter.all:
        return Icons.event;
      case EventStatusFilter.live:
        return Icons.circle;
      case EventStatusFilter.upcoming:
        return Icons.schedule;
      case EventStatusFilter.past:
        return Icons.history;
    }
  }
}