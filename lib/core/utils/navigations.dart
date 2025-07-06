import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../injection_container.dart';
import '../../presentation/blocs/auth/auth_bloc.dart';
import '../../presentation/blocs/game/game_bloc.dart';
import '../../presentation/pages/game_detail/game_detail_page.dart';
import '../../presentation/pages/test/igdb_test_page.dart';
import '../../presentation/pages/test/supabase_test_page.dart';

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

  static void navigateToRatedGames(BuildContext context) {
    // TODO: Implement navigation to full popular games list
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Popular games list coming soon!')),
    );
  }

  static void navigateToTopRatedGames(BuildContext context) {
    // TODO: Implement navigation to full popular games list
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Popular games list coming soon!')),
    );
  }


  static void navigateToUpcomingGames(BuildContext context) {
    // TODO: Implement navigation to full upcoming games list
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Upcoming games list coming soon!')),
    );
  }

  static void navigateToLatestReleases(BuildContext context) {
    // TODO: Implement navigation to full upcoming games list
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Latest games list coming soon!')),
    );
  }

  static void navigateToRecommendations(BuildContext context) {
    // TODO: Implement navigation to full recommendations list
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Recommendations list coming soon!')),
    );
  }

  static void navigateToWishlist(BuildContext context) {
    // TODO: Implement navigation to full recommendations list
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Wishlist list coming soon!')),
    );
  }

  static void navigateToSearch(BuildContext context) {
    // TODO: Implement navigation to full recommendations list
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Wishlist list coming soon!')),
    );
  }

  static void navigateToPopularGames(BuildContext context) {
    // TODO: Implement navigation to full popular games list
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Popular games list coming soon!')),
    );
  }

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