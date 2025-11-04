// lib/presentation/widgets/rated_section.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/navigations.dart';
import '../../../domain/entities/game/game.dart';
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
    // 🆕 State vom GameBloc abrufen
    final gameBloc = context.read<GameBloc>();
    final currentState = gameBloc.state;

    List<Game> ratedGames = [];

    // Games aus dem aktuellen State extrahieren
    if (currentState is UserRatedLoaded) {
      ratedGames = currentState.games;
    } else if (currentState is GrovePageLoaded) {
      ratedGames = currentState.userRated;
    }

    // Navigation mit den gefundenen Games
    if (ratedGames.isNotEmpty) {
      Navigations.navigateToRatedGames(context, ratedGames);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Loading rated games...')),
      );
      if (currentUserId != null && this.gameBloc != null) {
        this.gameBloc!.add(LoadUserRatedEvent(currentUserId!));
      }
    }
  }

  @override
  Widget buildSectionContent(BuildContext context, GameState state) {
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
