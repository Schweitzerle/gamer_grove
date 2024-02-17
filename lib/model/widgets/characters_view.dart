import 'dart:math';

import 'package:clay_containers/widgets/clay_container.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:gamer_grove/model/igdb_models/character.dart';
import 'package:gamer_grove/model/igdb_models/collection.dart';
import 'package:gamer_grove/model/views/characterGridView.dart';
import 'package:gamer_grove/model/widgets/character_view.dart';
import 'package:gamer_grove/model/widgets/gamePreview.dart';

import '../igdb_models/game.dart';
import '../views/gameGridView.dart';

class CharactersStaggeredView extends StatelessWidget {
  final List<Character> characters;
  final Color colorPalette;
  final Color headerBorderColor;
  final Color adjustedTextColor;

  const CharactersStaggeredView(
      {super.key, required this.characters, required this.colorPalette, required this.headerBorderColor, required this.adjustedTextColor});

  @override
  Widget build(BuildContext context) {
    return Padding(padding: EdgeInsets.all(8), child:
    StaggeredGrid.count(
      crossAxisCount: 4,
      mainAxisSpacing: 4,
      crossAxisSpacing: 8,
      children: [
        if (characters.isNotEmpty)
          StaggeredGridTile.count(
              crossAxisCellCount: 3,
              mainAxisCellCount: 2,
              child: CharactersPreviewView(
                collection: characters,
                color: colorPalette,
              )
          ),
        if (characters.isNotEmpty)
          StaggeredGridTile.count(
            crossAxisCellCount: 1,
            mainAxisCellCount: 1,
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(
                    AllCharacterGridScreen.route(
                        characters,
                        context,
                        'Characters'));
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
                          'Characters',
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
        if (characters.isNotEmpty)
          StaggeredGridTile.count(
              crossAxisCellCount: 1,
              mainAxisCellCount: 1,
              child: Container()),
      ],
    ),
      );
  }

}



class CharactersPreviewView extends StatelessWidget {
  final List<Character> collection;
  final Color color;
  const CharactersPreviewView({Key? key, required this.collection, required this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mediaWidth = MediaQuery.of(context).size.width;
    final mediaHeight = MediaQuery.of(context).size.height;

    final List<Character> randCharacters = collection.toList()..shuffle();
    final List<Character> selectedCharacters = randCharacters.take(5).toList();
    final containerBackgroundColor = color.darken(20);
    final headerBorderColor = color;
    final contentBackgroundColor = color.darken(10).withOpacity(.8);


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
              selectedCharacters.length,
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
                      child: CharacterView(
                        character: selectedCharacters[index],
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
