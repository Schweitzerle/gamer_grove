// lib/presentation/widgets/top_rated_games_section.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/utils/navigations.dart';
import '../../blocs/game/game_bloc.dart';
import '../sections/base_game_section.dart';

class TopRatedGamesSection extends BaseGameSection {
  const TopRatedGamesSection({
    super.key,
    super.currentUserId,
    super.gameBloc,
  });

  @override
  String get title => 'Top Rated';

  @override
  String get subtitle => 'Top games everyone loves';

  @override
  IconData get icon => FontAwesomeIcons.trophy;

  @override
  void onViewAllPressed(BuildContext context) {
    //TODO: Implement
    Navigations.navigateToTopRatedGames(context);
  }

  @override
  Widget buildSectionContent(BuildContext context, GameState state) {
    if (state is TopRatedGamesLoading || state is HomePageLoading) {
      return buildHorizontalGameListSkeleton();
    } else if (state is TopRatedGamesLoaded) {
      if (state.games.isEmpty) {
        return buildEmptySection('No top rated games found', Icons.trending_up, context);
      }
      return buildHorizontalGameList(state.games);
    } else if (state is HomePageLoaded) {
      if (state.topRatedGames.isEmpty) {
        return buildEmptySection('No top rated games found', Icons.trending_up, context);
      }
      return buildHorizontalGameList(state.topRatedGames);
    } else if (state is GameError) {
      return buildErrorSection('Failed to load top rated games', context);
    }
    return buildHorizontalGameListSkeleton();
  }

  @override
  void onRetryAction() {
    if (gameBloc != null) {
      gameBloc!.add(const LoadTopRatedGamesEvent(limit: 10));
    }
  }
}