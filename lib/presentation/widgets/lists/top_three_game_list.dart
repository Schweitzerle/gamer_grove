import 'package:flutter/cupertino.dart';
import 'package:gamer_grove/core/constants/app_constants.dart';
import 'package:gamer_grove/domain/entities/game/game.dart';
import 'package:gamer_grove/presentation/widgets/gameItems/top_three_game_item.dart';

class TopThreeGameList extends StatelessWidget {

  const TopThreeGameList({
    required this.games, super.key,
  });
  final List<Game> games;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
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


