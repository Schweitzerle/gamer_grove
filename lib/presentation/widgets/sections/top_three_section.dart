// lib/presentation/widgets/top_three_section.dart
import 'package:flutter/material.dart';
import 'package:gamer_grove/presentation/widgets/lists/top_three_game_list.dart';
import '../../blocs/game/game_bloc.dart';
import 'base_game_section.dart';
import 'empty_top_three_section.dart';


class TopThreeSection extends BaseGameSection {
  const TopThreeSection({
    super.key,
    super.currentUserId,
    super.gameBloc,
  });

  @override
  String get title => 'My Top 3';

  @override
  String get subtitle => 'Your personal favorites';

  @override
  IconData get icon => Icons.star;

  @override
  bool get showViewAll => false; // Da es nur 3 Games sind, kein "View All" nötig

  @override
  void onViewAllPressed(BuildContext context) {
    // Nicht verwendet, da showViewAll = false
  }

  @override
  Widget buildSectionContent(BuildContext context, GameState state) {
    if (state is GrovePageLoading) {
      return buildHorizontalGameListSkeleton();
    } else if (state is GrovePageLoaded) {
      if (state.userTopThree.isEmpty) {
        return const EmptyTopThreeSection();
      }
      return TopThreeGameList(games: state.userTopThree);
    } else if (state is GameError) {
      return buildErrorSection('Failed to load top games', context);
    }
    return buildHorizontalGameListSkeleton();
  }

  @override
  void onRetryAction() {
    if (currentUserId != null && gameBloc != null) {
      gameBloc!.add(LoadGrovePageDataEvent(userId: currentUserId!));
    }
  }
}