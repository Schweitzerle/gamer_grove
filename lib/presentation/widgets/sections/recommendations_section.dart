// lib/presentation/widgets/recommendations_section.dart
import 'package:flutter/material.dart';
import 'package:gamer_grove/core/utils/navigations.dart';
import 'package:gamer_grove/presentation/blocs/game/game_bloc.dart';
import 'package:gamer_grove/presentation/widgets/sections/base_game_section.dart';

class RecommendationsSection extends BaseGameSection {

  const RecommendationsSection({
    super.key,
    super.currentUserId,
    super.gameBloc,
    this.username,
  });
  final String? username;

  @override
  String get title =>
      username != null ? 'Recommended by $username' : 'Recommended by You';

  @override
  String get subtitle =>
      username != null ? 'Games $username loves' : 'Games you love';

  @override
  IconData get icon => Icons.recommend;

  @override
  void onViewAllPressed(BuildContext context) {
    final userId = currentUserId;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in.')),
      );
      return;
    }
    // Directly navigate to the dedicated page with the user's ID
    Navigations.navigateToUserRecommendedGames(context, userId: userId);
  }

  @override
  Widget buildSectionContent(BuildContext context, GameState state) {
    // The BlocListener is removed, and we just build the content.
    return _buildContent(context, state);
  }

  Widget _buildContent(BuildContext context, GameState state) {
    if (state is UserRecommendationsLoading || state is GrovePageLoading) {
      return buildHorizontalGameListSkeleton();
    } else if (state is UserRecommendationsLoaded) {
      if (state.games.isEmpty) {
        return buildEmptySection(
            'No recommendations yet', Icons.lightbulb_outline, context,);
      }
      return buildHorizontalGameList(state.games.take(10).toList());
    } else if (state is GrovePageLoaded) {
      if (state.userRecommendations.isEmpty) {
        return buildEmptySection(
            'No recommendations yet', Icons.lightbulb_outline, context,);
      }
      return buildHorizontalGameList(
          state.userRecommendations.take(10).toList(),);
    } else if (state is GameError) {
      return buildErrorSection('Failed to load recommendations', context);
    }
    return buildHorizontalGameListSkeleton();
  }

  @override
  void onRetryAction() {
    if (currentUserId != null && gameBloc != null) {
      gameBloc!.add(LoadUserRecommendationsEvent(currentUserId!));
    }
  }
}
