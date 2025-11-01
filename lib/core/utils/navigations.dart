import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamer_grove/presentation/blocs/game_engine/game_engine_bloc.dart';
import 'package:gamer_grove/presentation/blocs/platform/platform_bloc.dart';
import 'package:gamer_grove/presentation/pages/gameEngine/game_engine_detail_page.dart';
import 'package:gamer_grove/presentation/pages/gameEngine/game_engine_paginated_games_screen.dart';
import 'package:gamer_grove/presentation/pages/platform/platform_detail_page.dart';
import 'package:gamer_grove/presentation/pages/search/search_page.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../domain/entities/character/character.dart';
import '../../domain/entities/search/search_filters.dart';
import '../../domain/entities/event/event.dart';
import '../../injection_container.dart';
import '../../presentation/blocs/auth/auth_bloc.dart';
import '../../presentation/blocs/auth/auth_state.dart';
import '../../presentation/blocs/character/character_bloc.dart';
import '../../presentation/blocs/event/event_bloc.dart';
import '../../presentation/blocs/event/event_event.dart';
import '../../presentation/blocs/game/game_bloc.dart';
import '../../presentation/pages/character/character_detail_page.dart';
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
import '../../presentation/widgets/sections/franchise_collection_section.dart';

class Navigations {
  static void navigateToGameDetail(int gameId, BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
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

  /// Generic method for enriched all games screen (replaces LocalAllGamesScreen)
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
    final userId = _getCurrentUserId(context);

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => EnrichedAllGamesScreen(
          title: title,
          subtitle: subtitle,
          games: games, // Alle Games werden enriched
          userId: userId,
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
      subtitle: 'Franchise • ${games.length} games',
      games: games, // ✅ Einfach alle Games übergeben
      blurRated: false,
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
      subtitle: 'Collection • ${games.length} games',
      games: games, // ✅ Einfach alle Games übergeben
      blurRated: false,
      showFilters: true,
    );
  }

  static void navigateToEventGames(
      BuildContext context, SeriesItem item, Event event) {
    Navigations.navigateToLocalAllGames(
      context,
      title: item.title,
      subtitle: 'Games featured at this event',
      games: event.games,
      showFilters: true,
      blurRated: false,
    );
  }

  static void navigateToCharacterGames(
      BuildContext context, SeriesItem item, Character character) {
    Navigations.navigateToLocalAllGames(
      context,
      title: item.title,
      subtitle: 'Games ${character.name} is a part of',
      games: character.games ?? [],
      showFilters: true,
      blurRated: false,
    );
  }

  static String? _getCurrentUserId(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    return authState is AuthAuthenticated ? authState.user.id : null;
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
      blurRated: false,
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
      blurRated: false,
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
      blurRated: false,
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
      blurRated: false, // Highlight which wishlist games are already rated
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
      blurRated: false, // Show which recommendations are already rated
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

  static void navigateToRatedGames(
    BuildContext context,
    List<Game> ratedGames,
  ) {
    navigateToLocalAllGames(
      context,
      title: 'My Rated Games',
      subtitle: '${ratedGames.length} games',
      games: ratedGames,
      blurRated: false, // Highlight which wishlist games are already rated
      showFilters: true,
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

  static void navigateToRecommendations(
    BuildContext context,
    List<Game> recommendedGames,
  ) {
    navigateToLocalAllGames(
      context,
      title: 'My Recommendations',
      subtitle: '${recommendedGames.length} games',
      games: recommendedGames,
      blurRated: false, // Highlight which recommended games are already rated
      showFilters: true,
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
      const SnackBar(content: Text('Franchise detail screen coming soon!')),
    );
  }

  static void navigateToCollectionDetail(
      BuildContext context, int collectionId) {
    // TODO: Implement collection detail screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Collection detail screen coming soon!')),
    );
  }

  // ==========================================
  // 🧪 TEST SCREENS
  // ==========================================

  static void navigateToSupabaseTest(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => const SupabaseTestPage(),
      ),
    );
  }

  static void navigateToIGDBTest(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
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
      MaterialPageRoute<void>(
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
      MaterialPageRoute<void>(
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

  // Ersetze die Navigation mit User-aware Events:
  static void navigateToEventDetails(
    BuildContext context, {
    required int eventId,
    Game? game,
  }) {
    // Get current user
    final authState = context.read<AuthBloc>().state;
    String? userId;
    if (authState is AuthAuthenticated) {
      userId = authState.user.id;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => sl<EventBloc>()
                ..add(GetCompleteEventDetailsWithUserDataEvent(
                  eventId: eventId,
                  userId: userId, // 🎯 User ID mitgeben!
                )),
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

  static void navigateToCharacterDetail(BuildContext context, int characterId,
      {Character? character}) {
    print('🎭 Navigation: Opening character detail for ID: $characterId');
    print('🎭 Navigation: Pre-loaded character: ${character?.name ?? "none"}');

    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) {
                print(
                    '🎭 Navigation: Creating CharacterBloc for ID: $characterId');
                return sl<CharacterBloc>();
              },
            ),
            // Include AuthBloc if needed for user-specific data
            BlocProvider.value(
              value: context.read<AuthBloc>(),
            ),
          ],
          child: CharacterDetailPage(
            characterId: characterId,
            character: character,
          ),
        ),
      ),
    );
  }

  static void navigateToPlatformDetails(
    BuildContext context, {
    required int platformId,
    Game? game,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) {
                print(
                    '🎭 Navigation: Creating PlatformBloc for ID: $platformId');
                return sl<PlatformBloc>();
              },
            ),
            // Include AuthBloc if needed for user-specific data
            BlocProvider.value(
              value: context.read<AuthBloc>(),
            ),
          ],
          child: PlatformDetailPage(
            platformId: platformId,
          ),
        ),
      ),
    );
  }

  static void navigateToGameEngineDetails(
    BuildContext context, {
    required int gameEngineId,
    Game? game,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) {
                print(
                    '🎭 Navigation: Creating GameEngineBloc for ID: $gameEngineId');
                return sl<GameEngineBloc>();
              },
            ),
            // Include AuthBloc if needed for user-specific data
            BlocProvider.value(
              value: context.read<AuthBloc>(),
            ),
          ],
          child: GameEngineDetailPage(
            gameEngineId: gameEngineId,
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
      MaterialPageRoute<void>(
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
        const SnackBar(
            content: Text('No live stream available for this event')),
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
      const SnackBar(
          content: Text('Event notifications settings coming soon!')),
    );
  }

  static void navigateToGameEngineGames(
    BuildContext context, {
    required int gameEngineId,
    required String gameEngineName,
  }) {
    // Get current user
    final authState = context.read<AuthBloc>().state;
    String? userId;
    if (authState is AuthAuthenticated) {
      userId = authState.user.id;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => BlocProvider<GameEngineBloc>(
          create: (context) => sl<GameEngineBloc>(),
          child: GameEnginePaginatedGamesScreen(
            gameEngineId: gameEngineId,
            gameEngineName: gameEngineName,
            userId: userId,
          ),
        ),
      ),
    );
  }

  static Future<void> navigateToPlatformGames(
    BuildContext context, {
    required int platformId,
    required String platformName,
  }) async {
    // Navigate to Search Screen with platform filter pre-applied
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => SearchPage(
          initialFilters: SearchFilters(
            platformIds: [platformId],
            platformNames: {platformId: platformName},
          ),
          initialTitle: platformName,
        ),
      ),
    );
  }
}
