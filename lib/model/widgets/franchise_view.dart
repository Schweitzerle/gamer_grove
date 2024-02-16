import 'package:clay_containers/widgets/clay_container.dart';
import 'package:flutter/material.dart';
import 'package:gamer_grove/features/home/home_screen.dart';
import 'package:gamer_grove/model/igdb_models/collection.dart';
import 'package:gamer_grove/model/igdb_models/franchise.dart';
import 'package:gamer_grove/model/widgets/gamePreview.dart';

import '../igdb_models/game.dart';
import '../views/gameGridView.dart';

class FranchiseView extends StatelessWidget {
  final Franchise franchise;
  final Color colorPalette;
  const FranchiseView({Key? key, required this.franchise, required this.colorPalette}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mediaWidth = MediaQuery.of(context).size.width;
    final mediaHeight = MediaQuery.of(context).size.height;

    final List<Game> randGames = franchise.games!.toList()..shuffle();
    final List<Game> selectedGames = randGames.take(5).toList();

    return ClayContainer(
      spread: 2,
      depth: 60,
      borderRadius: 14,
      color: colorPalette.withOpacity(.5),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          children: [
            // Game previews
            ...List.generate(
              franchise.games!.length > 5 ? 5 : franchise.games!.length,
                  (index) {
                final topOffset = index == 0 ? 0.0 : (mediaHeight * .015) * index;
                final rightOffset = index == 0 ? 0.0 : (mediaWidth * .12) * index;
                return Positioned(
                  top: topOffset,
                  left: rightOffset,
                  child: SizedBox(
                    width: mediaWidth * .28,
                    height: mediaHeight * .2,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: GamePreviewView(
                        game: selectedGames[index],
                        isCover: true,
                        buildContext: context,
                      ),
                    ),
                  ),
                );
              },
            ),
            // ClayContainer for the "Collection" text
          ],
        ),
      ),
    );
  }
}
