import 'package:clay_containers/widgets/clay_container.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gamer_grove/model/views/characterGridView.dart';
import 'package:gamer_grove/model/widgets/character_view.dart';
import 'package:gamer_grove/model/widgets/gamePreview.dart';
import 'package:get/get_utils/get_utils.dart';
import '../igdb_models/character.dart';
import '../igdb_models/game.dart';
import '../views/gameGridPaginationView.dart';
import '../views/gameGridView.dart';

class CharacterListView extends StatefulWidget {
  final String headline;
  final List<Character>? character;
  final int showLimit;
  final Color color;

  CharacterListView({
    required this.headline,
    required this.character, required this.showLimit, required this.color,
  });

  @override
  State<StatefulWidget> createState() => CharacterListViewState();
}

class CharacterListViewState extends State<CharacterListView> {
  @override
  Widget build(BuildContext context) {
    final mediaQueryHeight = MediaQuery.of(context).size.height;
    final mediaQueryWidth = MediaQuery.of(context).size.width;
    return widget.character != null && widget.character!.isNotEmpty
        ?  Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: widget.color.withOpacity(.5),
        ),
            margin: EdgeInsets.only(
              top: mediaQueryHeight * 0.02,
                bottom: 8
            ),
            height: mediaQueryHeight / 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, left: 8, right: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ClayContainer(
                        depth: 60,
                        spread: 2,
                        customBorderRadius: BorderRadius.circular(12),
                        color: Theme.of(context).cardColor,
                        child: Padding(
                          padding: EdgeInsets.all(5),
                          child: Text(
                            widget.headline,
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontSize: 18,
                                color: Theme.of(context)
                                    .cardTheme
                                    .surfaceTintColor),
                          ),
                        ),
                      ),
                      if (widget.character!.length > widget.showLimit)
                        ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                                  AllCharacterGridScreen.route(
                                      widget.character!, context, widget.headline));
                          ;
                        },
                        child: Padding(
                          padding: EdgeInsets.all(5),
                          child: Text(
                            'All',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 18,
                                color: Theme.of(context)
                                    .cardTheme
                                    .surfaceTintColor),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: mediaQueryHeight * 0.01,
                ),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: widget.character!.length < widget.showLimit ? widget.character!.length : widget.showLimit,
                    itemBuilder: (context, index) {
                      if (index >= widget.character!.length) {
                        return null; // or a placeholder widget
                      }
                      Character character = widget.character![index];
                      return Container(
                        width: mediaQueryWidth * .41,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CharacterView(
                            character: character,
                            buildContext: context,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ))
        : Padding(
            padding: EdgeInsets.all(35),
            child: ClayContainer(
              depth: 60,
              spread: 2,
              customBorderRadius: BorderRadius.circular(14),
              color: Theme.of(context).cardColor,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: FittedBox(
                    child: Text(
                      'No data for ${widget.headline} availale',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontSize: 18,
                          color: Theme.of(context).cardTheme.surfaceTintColor),
                    ),
                  ),
                ),
              ),
            ),
          );
  }
}
