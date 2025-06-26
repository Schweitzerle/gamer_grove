// lib/presentation/widgets/top_three_section_content.dart
import 'package:flutter/material.dart';
import 'package:gamer_grove/presentation/widgets/lists/top_three_game_list.dart';
import '../../blocs/game/game_bloc.dart';
import '../error/error_section_widget.dart';
import '../skeletons/horizontal_game_list_skeleton.dart';
import '../sections/empty_top_three_section.dart';

class TopThreeSectionContent extends StatelessWidget {
  final GameState state;
  final String? currentUserId;
  final GameBloc? gameBloc;

  const TopThreeSectionContent({
    super.key,
    required this.state,
    this.currentUserId,
    this.gameBloc,
  });

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
            gameBloc!.add(LoadGrovePageDataEvent(userId: currentUserId!));
          }
        },
      );
    }
    return const HorizontalGameListSkeleton();
  }
}