import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../injection_container.dart';
import '../../presentation/blocs/auth/auth_bloc.dart';
import '../../presentation/blocs/game/game_bloc.dart';
import '../../presentation/pages/game_detail/game_detail_page.dart';
import '../../presentation/pages/test/igdb_test_page.dart';
import '../../presentation/pages/test/supabase_test_page.dart';
// 🆕 NEW: Import Local All Games Screen
import '../../presentation/pages/all_games/local_all_games_screen.dart';
import '../../domain/entities/game/game.dart';
import '../../domain/entities/franchise.dart';
import '../../domain/entities/collection/collection.dart';

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
}