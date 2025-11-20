import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamer_grove/domain/entities/character/character.dart';
import 'package:gamer_grove/domain/entities/event/event.dart';
import 'package:gamer_grove/domain/entities/game/game.dart';
import 'package:gamer_grove/domain/entities/game/game_sort_options.dart';
import 'package:gamer_grove/domain/entities/search/search_filters.dart';
import 'package:gamer_grove/injection_container.dart';
import 'package:gamer_grove/presentation/blocs/auth/auth_bloc.dart';
import 'package:gamer_grove/presentation/blocs/auth/auth_state.dart';
import 'package:gamer_grove/presentation/blocs/character/character_bloc.dart';
import 'package:gamer_grove/presentation/blocs/company/company_bloc.dart';
import 'package:gamer_grove/presentation/blocs/event/event_bloc.dart';
import 'package:gamer_grove/presentation/blocs/event/event_event.dart';
import 'package:gamer_grove/presentation/blocs/game/game_bloc.dart';
import 'package:gamer_grove/presentation/blocs/game_engine/game_engine_bloc.dart';
import 'package:gamer_grove/presentation/blocs/platform/platform_bloc.dart';
import 'package:gamer_grove/presentation/pages/all_games/local_all_games_screen.dart';
import 'package:gamer_grove/presentation/pages/character/character_detail_page.dart';
import 'package:gamer_grove/presentation/pages/company/company_detail_page.dart';
import 'package:gamer_grove/presentation/pages/event/event_detail_page.dart';
import 'package:gamer_grove/presentation/pages/event/event_details_screen.dart';
import 'package:gamer_grove/presentation/pages/event/widgets/all_events_screen.dart';
import 'package:gamer_grove/presentation/pages/gameEngine/game_engine_detail_page.dart';
import 'package:gamer_grove/presentation/pages/game_detail/game_detail_page.dart';
import 'package:gamer_grove/presentation/pages/platform/platform_detail_page.dart';
import 'package:gamer_grove/presentation/pages/search/search_page.dart';
import 'package:gamer_grove/presentation/pages/user_game_list_page.dart';
import 'package:gamer_grove/presentation/widgets/sections/franchise_collection_section.dart';
import 'package:url_launcher/url_launcher.dart';

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
    required List<Game> games, String? subtitle,
    bool showFilters = true,
    bool showSearch = true,
    bool blurRated = false,
    bool showViewToggle = true,
    Future<List<Game>> Function(int offset)? loadMore,
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
          loadMore: loadMore,
        ),
      ),
    );
  }

  /// Navigate to all games in a franchise
  static Future<void> navigateToFranchiseGames(
    BuildContext context, {
    required int franchiseId,
    required String franchiseName,
  }) async {
    // Navigate to Search Screen with franchise filter pre-applied
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => SearchPage(
          initialFilters: SearchFilters(
            franchiseIds: [franchiseId],
            franchiseNames: {franchiseId: franchiseName},
          ),
          initialTitle: franchiseName,
        ),
      ),
    );
  }

  /// Navigate to all games in a collection
  static Future<void> navigateToCollectionGames(
    BuildContext context, {
    required int collectionId,
    required String collectionName,
  }) async {
    // Navigate to Search Screen with collection filter pre-applied
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => SearchPage(
          initialFilters: SearchFilters(
            collectionIds: [collectionId],
            collectionNames: {collectionId: collectionName},
          ),
          initialTitle: collectionName,
        ),
      ),
    );
  }

  /// Navigate to all games by a company (developer or publisher)
  static Future<void> navigateToCompanyGames(
    BuildContext context, {
    required int companyId,
    required String companyName,
    bool? isDeveloper,
    bool? isPublisher,
  }) async {
    // Navigate to Search Screen with company filter pre-applied
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => SearchPage(
          initialFilters: SearchFilters(
            companyIds: [companyId],
            companyNames: {companyId: companyName},
            isDeveloper: isDeveloper,
            isPublisher: isPublisher,
          ),
          initialTitle: companyName,
        ),
      ),
    );
  }

  static void navigateToEventGames(
      BuildContext context, SeriesItem item, Event event,) {
    Navigations.navigateToLocalAllGames(
      context,
      title: item.title,
      subtitle: 'Games featured at this event',
      games: event.games,
    );
  }

  static void navigateToCharacterGames(
      BuildContext context, SeriesItem item, Character character,) {
    Navigations.navigateToLocalAllGames(
      context,
      title: item.title,
      subtitle: 'Games ${character.name} is a part of',
      games: character.games ?? [],
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
      showFilters: false, // Simpler version for similar games
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
      showFilters: false,
    );
  }

  /// Navigate to user's wishlist page.
  static void navigateToUserWishlist(BuildContext context, {String? userId}) {
    final targetUserId = userId ?? _getCurrentUserId(context);
    if (targetUserId == null) {
      // Optional: Show a message or prompt to log in
      return;
    }
    Navigator.of(context).push(
      UserGameListPage.route(targetUserId, GameListType.wishlist),
    );
  }

  /// Navigate to user's rated games page.
  static void navigateToUserRatedGames(BuildContext context, {String? userId}) {
    final targetUserId = userId ?? _getCurrentUserId(context);
    if (targetUserId == null) {
      // Optional: Show a message or prompt to log in
      return;
    }
    Navigator.of(context).push(
      UserGameListPage.route(targetUserId, GameListType.rated),
    );
  }

  /// Navigate to user's recommended games page.
  static void navigateToUserRecommendedGames(
    BuildContext context, {
    String? userId,
  }) {
    final targetUserId = userId ?? _getCurrentUserId(context);
    if (targetUserId == null) {
      // Optional: Show a message or prompt to log in
      return;
    }
    Navigator.of(context).push(
      UserGameListPage.route(targetUserId, GameListType.recommended),
    );
  }

  // ==========================================
  // 🔄 API-BASED METHODS (für später - fetchen neue Daten)
  // ==========================================
  // Diese Methoden bleiben als TODOs für API-basierte Screens

  static void navigateToPopularGames(BuildContext context) {
    // Popular = Games with hype (what people are talking about/expecting)
    // Filtered to ±6 months from today to show currently trending games
    final now = DateTime.now();
    final sixMonthsAgo = DateTime(now.year, now.month - 6, now.day);
    final sixMonthsFromNow = DateTime(now.year, now.month + 6, now.day);

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => SearchPage(
          initialFilters: SearchFilters(
            minHypes: 5,
            releaseDateFrom: sixMonthsAgo,
            releaseDateTo: sixMonthsFromNow,
            sortBy: GameSortBy.popularity,
          ),
          initialTitle: 'Popular Right Now',
        ),
      ),
    );
  }

  static void navigateToTopRatedGames(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => const SearchPage(
          initialFilters: SearchFilters(
            minTotalRatingCount: 50,
            sortBy: GameSortBy.rating,
          ),
          initialTitle: 'Top Rated',
        ),
      ),
    );
  }

  static void navigateToUpcomingGames(BuildContext context) {
    final now = DateTime.now();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => SearchPage(
          initialFilters: SearchFilters(
            releaseDateFrom: now,
            sortBy: GameSortBy.releaseDate,
            sortOrder: SortOrder.ascending,
          ),
          initialTitle: 'Coming Soon',
        ),
      ),
    );
  }

  static void navigateToLatestReleases(BuildContext context) {
    final now = DateTime.now();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => SearchPage(
          initialFilters: SearchFilters(
            releaseDateTo: now,
            sortBy: GameSortBy.releaseDate,
          ),
          initialTitle: 'New Releases',
        ),
      ),
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
      BuildContext context, int collectionId,) {
    // TODO: Implement collection detail screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Collection detail screen coming soon!')),
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
        ),
      ),
    );
  }

  /// Navigate to all events screen (generic)
  static void navigateToAllEventsGeneric(
    BuildContext context, {
    required String title,
    required List<Event> events, String? subtitle,
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
                ),),
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
      {Character? character,}) {

    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) {
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

  static void navigateToCompanyDetails(
    BuildContext context, {
    required int companyId,
    Game? game,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) {
                return sl<CompanyBloc>();
              },
            ),
            // Include AuthBloc if needed for user-specific data
            BlocProvider.value(
              value: context.read<AuthBloc>(),
            ),
          ],
          child: CompanyDetailPage(
            companyId: companyId,
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
            content: Text('No live stream available for this event'),),
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
          content: Text('Event notifications settings coming soon!'),),
    );
  }

  static Future<void> navigateToGameEngineGames(
    BuildContext context, {
    required int gameEngineId,
    required String gameEngineName,
  }) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => SearchPage(
          initialFilters: SearchFilters(
            gameEngineIds: [gameEngineId],
            gameEngineNames: {gameEngineId: gameEngineName},
          ),
          initialTitle: gameEngineName,
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

  // ==========================================
  // GENRE, THEME, KEYWORD NAVIGATION
  // ==========================================

  static Future<void> navigateToGenreGames(
    BuildContext context, {
    required int genreId,
    required String genreName,
  }) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => SearchPage(
          initialFilters: SearchFilters(
            genreIds: [genreId],
          ),
          initialTitle: genreName,
        ),
      ),
    );
  }

  static Future<void> navigateToThemeGames(
    BuildContext context, {
    required int themeId,
    required String themeName,
  }) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => SearchPage(
          initialFilters: SearchFilters(
            themesIds: [themeId],
            themeNames: {themeId: themeName},
          ),
          initialTitle: themeName,
        ),
      ),
    );
  }

  static Future<void> navigateToKeywordGames(
    BuildContext context, {
    required int keywordId,
    required String keywordName,
  }) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => SearchPage(
          initialFilters: SearchFilters(
            keywordIds: [keywordId],
            keywordNames: {keywordId: keywordName},
          ),
          initialTitle: keywordName,
        ),
      ),
    );
  }

  // ==========================================
  // GAME FEATURES NAVIGATION
  // ==========================================

  static Future<void> navigateToGameModeGames(
    BuildContext context, {
    required int gameModeId,
    required String gameModeName,
  }) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => SearchPage(
          initialFilters: SearchFilters(
            gameModesIds: [gameModeId],
          ),
          initialTitle: gameModeName,
        ),
      ),
    );
  }

  static Future<void> navigateToPlayerPerspectiveGames(
    BuildContext context, {
    required int perspectiveId,
    required String perspectiveName,
  }) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => SearchPage(
          initialFilters: SearchFilters(
            playerPerspectiveIds: [perspectiveId],
          ),
          initialTitle: perspectiveName,
        ),
      ),
    );
  }

  static Future<void> navigateToAgeRatingGames(
    BuildContext context, {
    required int ageRatingId,
    required String ageRatingName,
  }) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => SearchPage(
          initialFilters: SearchFilters(
            ageRatingCategoryIds: [ageRatingId],
            ageRatingNames: {ageRatingId: ageRatingName},
          ),
          initialTitle: ageRatingName,
        ),
      ),
    );
  }
}
