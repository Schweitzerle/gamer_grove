import 'package:flutter/cupertino.dart';
import 'package:gamer_grove/presentation/widgets/gameItems/top_three_game_item.dart';

import '../../../core/constants/app_constants.dart';
import '../../../domain/entities/game/game.dart';

class TopThreeGameList extends StatelessWidget {
  final List<Game> games;

  const TopThreeGameList({
    super.key,
    required this.games,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingMedium,
        ),
        itemCount: games.length,
        itemBuilder: (context, index) {
          return TopThreeGameItem(
            game: games[index],
            index: index,
          );
        },
      ),
    );
  }
}


