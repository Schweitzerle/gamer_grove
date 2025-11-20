// lib/presentation/widgets/upcoming_games_section.dart
import 'package:flutter/material.dart';
import 'package:gamer_grove/core/utils/navigations.dart';
import 'package:gamer_grove/presentation/blocs/game/game_bloc.dart';
import 'package:gamer_grove/presentation/widgets/sections/base_game_section.dart';

class UpcomingGamesSection extends BaseGameSection {
  const UpcomingGamesSection({
    super.key,
    super.currentUserId,
    super.gameBloc,
  });

  @override
  String get title => 'Coming Soon';

  @override
  String get subtitle => 'Exciting games to look forward to';

  @override
  IconData get icon => Icons.upcoming;

  @override
  void onViewAllPressed(BuildContext context) {
    Navigations.navigateToUpcomingGames(context);
  }

  @override
  Widget buildSectionContent(BuildContext context, GameState state) {
    if (state is UpcomingGamesLoading || state is HomePageLoading) {
      return buildHorizontalGameListSkeleton();
    } else if (state is UpcomingGamesLoaded) {
      if (state.games.isEmpty) {
        return buildEmptySection('No upcoming games found', Icons.schedule, context);
      }
      return buildHorizontalGameList(state.games);
    } else if (state is HomePageLoaded) {
      if (state.upcomingGames.isEmpty) {
        return buildEmptySection('No upcoming games found', Icons.schedule, context);
      }
      return buildHorizontalGameList(state.upcomingGames);
    } else if (state is GameError) {
      return buildErrorSection('Failed to load upcoming games', context);
    }
    return buildHorizontalGameListSkeleton();
  }

  @override
  void onRetryAction() {
    if (gameBloc != null) {
      gameBloc!.add(const LoadUpcomingGamesEvent(limit: 10));
    }
  }
}