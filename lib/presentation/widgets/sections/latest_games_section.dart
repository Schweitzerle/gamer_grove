// lib/presentation/widgets/upcoming_games_section.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gamer_grove/core/utils/navigations.dart';
import 'package:gamer_grove/presentation/blocs/game/game_bloc.dart';
import 'package:gamer_grove/presentation/widgets/sections/base_game_section.dart';

class LatestGamesSection extends BaseGameSection {
  const LatestGamesSection({
    super.key,
    super.currentUserId,
    super.gameBloc,
  });

  @override
  String get title => 'New releases';

  @override
  String get subtitle => 'Freshly released games to discover';

  @override
  IconData get icon => FontAwesomeIcons.newspaper;

  @override
  void onViewAllPressed(BuildContext context) {
    Navigations.navigateToLatestReleases(context);
  }

  @override
  Widget buildSectionContent(BuildContext context, GameState state) {
    if (state is LatestGamesLoading || state is HomePageLoading) {
      return buildHorizontalGameListSkeleton();
    } else if (state is LatestGamesLoaded) {
      if (state.games.isEmpty) {
        return buildEmptySection('No Latest games found', Icons.schedule, context);
      }
      return buildHorizontalGameList(state.games);
    } else if (state is HomePageLoaded) {
      if (state.latestGames.isEmpty) {
        return buildEmptySection('No Latest games found', Icons.schedule, context);
      }
      return buildHorizontalGameList(state.latestGames);
    } else if (state is GameError) {
      return buildErrorSection('Failed to load Latest games', context);
    }
    return buildHorizontalGameListSkeleton();
  }

  @override
  void onRetryAction() {
    if (gameBloc != null) {
      gameBloc!.add(const LoadLatestGamesEvent(limit: 10));
    }
  }
}