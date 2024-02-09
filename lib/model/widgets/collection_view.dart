import 'package:flutter/material.dart';
import 'package:gamer_grove/model/widgets/gamePreview.dart';

import '../igdb_models/game.dart';

class CollectionView extends StatelessWidget {
  final List<Game> games;

  const CollectionView({Key? key, required this.games}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Theme.of(context).cardColor,borderRadius: BorderRadius.circular(14)),
      child: Stack(
        children: List.generate(
          games.length > 5 ? 5 : games.length, // Show at most 5 games
              (index) {
            final topOffset = index == 0 ? 0.0 : (MediaQuery.of(context).size.height * .03)* index;
            final rightOffset = index == 0 ? 0.0 : (MediaQuery.of(context).size.width * .07)* index;
            return Positioned(
              top: topOffset, // Adjust the top position for each game to create offset
              right: rightOffset, // Adjust the left position for each game to create offset
              child: Transform.scale(
                alignment: Alignment.topRight,
                scale: 0.6, // Scale down the size of the GamePreviewView
                child: GamePreviewView(
                  game: games[index],
                  isCover: true,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
