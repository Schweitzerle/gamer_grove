// lib/presentation/widgets/popular_games_section.dart
import 'package:flutter/material.dart';
import 'package:gamer_grove/core/utils/navigations.dart';
import 'package:gamer_grove/presentation/blocs/game/game_bloc.dart';
import 'package:gamer_grove/presentation/widgets/sections/base_game_section.dart';

class PopularGamesSection extends BaseGameSection {
  const PopularGamesSection({
    super.key,
    super.currentUserId,
    super.gameBloc,
  });

  @override
  String get title => 'Popular Right Now';

  @override
  String get subtitle => 'Trending games everyone is playing';

  @override
  IconData get icon => Icons.trending_up;

  @override
  void onViewAllPressed(BuildContext context) {
    Navigations.navigateToPopularGames(context);
  }

  @override
  Widget buildSectionContent(BuildContext context, GameState state) {
    if (state is PopularGamesLoading || state is HomePageLoading) {
      return buildHorizontalGameListSkeleton();
    } else if (state is PopularGamesLoaded) {
      if (state.games.isEmpty) {
        return buildEmptySection('No popular games found', Icons.trending_up, context);
      }
      return buildHorizontalGameList(state.games);
    } else if (state is HomePageLoaded) {
      if (state.popularGames.isEmpty) {
        return buildEmptySection('No popular games found', Icons.trending_up, context);
      }
      return buildHorizontalGameList(state.popularGames);
    } else if (state is GameError) {
      return buildErrorSection('Failed to load popular games', context);
    }
    return buildHorizontalGameListSkeleton();
  }

  @override
  void onRetryAction() {
    if (gameBloc != null) {
      gameBloc!.add(const LoadPopularGamesEvent(limit: 10));
    }
  }
}