import 'dart:math';

import 'package:clay_containers/widgets/clay_container.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:gamer_grove/model/igdb_models/collection.dart';
import 'package:gamer_grove/model/widgets/gamePreview.dart';

import '../igdb_models/game.dart';
import '../views/gameGridView.dart';

class CollectionStaggeredView extends StatelessWidget {
  final Game game;
  final Color colorPalette;
  final Color headerBorderColor;
  final Color adjustedTextColor;

  const CollectionStaggeredView(
      {super.key, required this.game, required this.colorPalette, required this.headerBorderColor, required this.adjustedTextColor});

  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.all(8), child:
    StaggeredGrid.count(
      crossAxisCount: 4,
      mainAxisSpacing: 4,
      crossAxisSpacing: 8,
      children: [
        if (game.collection != null &&
            game.collection!.games != null)
          StaggeredGridTile.count(
              crossAxisCellCount: 3,
              mainAxisCellCount: 2,
              child:  CollectionView(
                collection: game.collection!,
                color: colorPalette,
              )),
        if (game.collection != null &&
            game.collection!.games != null)
          StaggeredGridTile.count(
            crossAxisCellCount: 1,
            mainAxisCellCount: 1,
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(
                    AllGamesGridScreen.route(
                        game.collection!.games!,
                        context,
                        game.collection!.name!, null));
              },
              child: ClayContainer(
                spread: 2,
                depth: 60,
                borderRadius: 14,
                color: headerBorderColor,
                parentColor: headerBorderColor.lighten(40),
                child: Padding(
                  padding: EdgeInsets.all(4),
                  child: FittedBox(
                    child: Row(
                      children: [
                        Text(
                          'Collection',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: adjustedTextColor
                          ),
                        ),
                        Icon(Icons.navigate_next_rounded)
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        if (game.collection != null &&
            game.collection!.games != null)
          StaggeredGridTile.count(
              crossAxisCellCount: 1,
              mainAxisCellCount: 1,
              child: Container()),
      ],
    ),
      );
  }

}



class CollectionView extends StatelessWidget {
  final Collection collection;
  final Color color;
  const CollectionView({Key? key, required this.collection, required this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mediaWidth = MediaQuery.of(context).size.width;
    final mediaHeight = MediaQuery.of(context).size.height;

    final List<Game> randGames = collection.games!.toList()..shuffle();
    final List<Game> selectedGames = randGames.take(5).toList();
    final containerBackgroundColor = color.darken(20);
    final headerBorderColor = color;
    final contentBackgroundColor = color.darken(10).withOpacity(.8);


    final coverScaleHeight = mediaHeight / 3.1;
    final coverScaleWidth = coverScaleHeight * 0.69;


    return ClayContainer(
      spread: 2,
      depth: 60,
      borderRadius: 14,
      color: containerBackgroundColor,
      parentColor: headerBorderColor.lighten(40),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          children: [
            // Game previews
            ...List.generate(
              selectedGames.length,
                  (index) {
                    final topOffset = index == 0 ? 0.0 : (mediaHeight * .012) * index;
                    final rightOffset = index == 0 ? 0.0 : (mediaWidth * .11) * index;
                    return Positioned(
                      top: topOffset,
                      left: rightOffset,
                      child: SizedBox(
                        width: coverScaleWidth * .56,
                        height: coverScaleHeight * .56,
                        child: GamePreviewView(
                          game: selectedGames[index],
                          isCover: true,
                          buildContext: context, needsRating: false, isClickable: true,
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
