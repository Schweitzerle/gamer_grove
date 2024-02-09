import 'package:clay_containers/widgets/clay_container.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gamer_grove/model/widgets/gamePreview.dart';
import 'package:get/get_utils/get_utils.dart';
import '../igdb_models/game.dart';

class GameListView extends StatefulWidget {
  final String headline;
  final List<Game>? games;

  GameListView({
    required this.headline,
    required this.games,
  });

  @override
  State<StatefulWidget> createState() => GameListViewState();
}

class GameListViewState extends State<GameListView> {
  @override
  Widget build(BuildContext context) {
    final mediaQueryHeight = MediaQuery.of(context).size.height;
    final mediaQueryWidth = MediaQuery.of(context).size.width;
    return  widget.games != null && widget.games!.isNotEmpty ?
    Container(
        margin: EdgeInsets.only(
          top: mediaQueryHeight * 0.02,
        ),
        height: mediaQueryHeight / 3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: ClayContainer(
                depth: 60,
                spread: 2,
                customBorderRadius: BorderRadius.circular(12),
                color: Theme.of(context).cardColor,
                child: Padding(
                  padding: EdgeInsets.all(5),
                  child: Text(
                    widget.headline,
                    textAlign: TextAlign.left,
                    style:  TextStyle(fontSize: 18, color: Theme.of(context).cardTheme.surfaceTintColor),
                  ),
                ),
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
                itemCount: widget.games!.length,
                itemBuilder: (context, index) {
                  if (index >= widget.games!.length) {
                    return null; // or a placeholder widget
                  }

                  Game game = widget.games![index];

                  return Container(
                    width: mediaQueryWidth * .41,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GamePreviewView(
                        game: game,
                        isCover: false,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        )) : Container();
  }
}
