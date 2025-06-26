// lib/presentation/widgets/recommendations_section.dart
import 'package:flutter/material.dart';
import '../../../core/utils/navigations.dart';
import '../../blocs/game/game_bloc.dart';
import '../sections/base_game_section.dart';

class RecommendationsSection extends BaseGameSection {
  const RecommendationsSection({
    super.key,
    super.currentUserId,
    super.gameBloc,
  });

  @override
  String get title => 'Recommended for You';

  @override
  String get subtitle => 'Games you might enjoy';

  @override
  IconData get icon => Icons.recommend;

  @override
  void onViewAllPressed(BuildContext context) {
    Navigations.navigateToRecommendations(context);
  }

  @override
  Widget buildSectionContent(BuildContext context, GameState state) {
    if (state is UserRecommendationsLoading || state is GrovePageLoading) {
      return buildHorizontalGameListSkeleton();
    } else if (state is UserRecommendationsLoaded) {
      if (state.games.isEmpty) {
        return buildEmptySection('No recommendations yet', Icons.lightbulb_outline, context);
      }
      return buildHorizontalGameList(state.games.take(10).toList());
    } else if (state is GrovePageLoaded) {
      if (state.userRecommendations.isEmpty) {
        return buildEmptySection('No recommendations yet', Icons.lightbulb_outline, context);
      }
      return buildHorizontalGameList(state.userRecommendations.take(10).toList());
    } else if (state is HomePageLoaded && state.userRecommendations != null) {
      // Backup für HomePageLoaded (falls irgendwo noch verwendet)
      if (state.userRecommendations!.isEmpty) {
        return buildEmptySection('No recommendations yet', Icons.lightbulb_outline, context);
      }
      return buildHorizontalGameList(state.userRecommendations!.take(10).toList());
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