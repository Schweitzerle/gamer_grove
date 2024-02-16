import 'dart:math';

import 'package:clay_containers/widgets/clay_container.dart';
import 'package:flutter/material.dart';
import 'package:gamer_grove/model/igdb_models/collection.dart';
import 'package:gamer_grove/model/widgets/gamePreview.dart';

import '../igdb_models/game.dart';
import '../views/gameGridView.dart';

class CollectionView extends StatelessWidget {
  final Collection collection;
  final Color colorPalette;
  const CollectionView({Key? key, required this.collection, required this.colorPalette}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mediaWidth = MediaQuery.of(context).size.width;
    final mediaHeight = MediaQuery.of(context).size.height;

    final List<Game> randGames = collection.games!.toList()..shuffle();
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
              selectedGames.length,
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
