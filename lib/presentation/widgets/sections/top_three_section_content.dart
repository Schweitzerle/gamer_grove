// lib/presentation/widgets/top_three_section_content.dart
import 'package:flutter/material.dart';
import 'package:gamer_grove/presentation/blocs/game/game_bloc.dart';
import 'package:gamer_grove/presentation/widgets/error/error_section_widget.dart';
import 'package:gamer_grove/presentation/widgets/lists/top_three_game_list.dart';
import 'package:gamer_grove/presentation/widgets/sections/empty_top_three_section.dart';
import 'package:gamer_grove/presentation/widgets/skeletons/horizontal_game_list_skeleton.dart';

class TopThreeSectionContent extends StatelessWidget {

  const TopThreeSectionContent({
    required this.state, super.key,
    this.currentUserId,
    this.gameBloc,
  });
  final GameState state;
  final String? currentUserId;
  final GameBloc? gameBloc;

  @override
  Widget build(BuildContext context) {
    if (state is GrovePageLoading) {
      return const HorizontalGameListSkeleton();
    } else if (state is GrovePageLoaded) {
      final groveState = state as GrovePageLoaded;
      if (groveState.userTopThree.isEmpty) {
        return const EmptyTopThreeSection();
      }
      return TopThreeGameList(games: groveState.userTopThree);
    } else if (state is GameError) {
      return ErrorSectionWidget(
        message: 'Failed to load top games',
        onRetry: () {
          if (currentUserId != null && gameBloc != null) {
            gameBloc!.add(LoadGrovePageDataEvent(userId: currentUserId));
          }
        },
      );
    }
    return const HorizontalGameListSkeleton();
  }
}