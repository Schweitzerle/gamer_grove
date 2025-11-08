// lib/presentation/widgets/rated_section.dart
import 'package:flutter/material.dart';
import '../../../core/utils/navigations.dart';
import '../../blocs/game/game_bloc.dart';
import 'base_game_section.dart';

class RatedSection extends BaseGameSection {
  final String? username;

  const RatedSection({
    super.key,
    super.currentUserId,
    super.gameBloc,
    this.username,
  });

  @override
  String get title => username != null ? "$username's Rated" : 'My Rated';

  @override
  String get subtitle =>
      username != null ? 'Games $username has rated' : 'Games you have rated';

  @override
  IconData get icon => Icons.numbers;

  @override
  void onViewAllPressed(BuildContext context) {
    final userId = currentUserId;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in.')),
      );
      return;
    }
    // Directly navigate to the dedicated page
    Navigations.navigateToUserRatedGames(context);
  }

  @override
  Widget buildSectionContent(BuildContext context, GameState state) {
    // The BlocListener is removed, and we just build the content.
    return _buildContent(context, state);
  }

  Widget _buildContent(BuildContext context, GameState state) {
    if (state is UserRatedLoading || state is GrovePageLoading) {
      return buildHorizontalGameListSkeleton();
    } else if (state is UserRatedLoaded) {
      if (state.games.isEmpty) {
        return buildEmptySection(
            'Your ratings are empty', Icons.star_border, context);
      }
      return buildHorizontalGameList(state.games.take(10).toList());
    } else if (state is GrovePageLoaded) {
      if (state.userRated.isEmpty) {
        return buildEmptySection(
            'Your ratings are empty', Icons.star_border, context);
      }
      return buildHorizontalGameList(state.userRated.take(10).toList());
    } else if (state is GameError) {
      return buildErrorSection('Failed to load rated games', context);
    }
    return buildHorizontalGameListSkeleton();
  }

  @override
  void onRetryAction() {
    if (currentUserId != null && gameBloc != null) {
      gameBloc!.add(LoadUserRatedEvent(currentUserId!));
    }
  }
}
