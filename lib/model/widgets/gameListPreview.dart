import 'package:clay_containers/widgets/clay_container.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gamer_grove/model/widgets/gamePreview.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:loading_indicator/loading_indicator.dart';
import '../igdb_models/game.dart';
import '../views/gameGridPaginationView.dart';
import '../views/gameGridView.dart';

class GameListView extends StatefulWidget {
  final String headline;
  final List<Game>? games;
  final bool isPagination;
  final String body;
  final int showLimit;
  Color? color;

  GameListView({
    required this.headline,
    required this.games,
    required this.isPagination,
    required this.body, required this.showLimit, this.color,
  });

  @override
  State<StatefulWidget> createState() => GameListViewState();
}

class GameListViewState extends State<GameListView> {
  @override
  Widget build(BuildContext context) {
    final mediaQueryHeight = MediaQuery.of(context).size.height;
    final mediaQueryWidth = MediaQuery.of(context).size.width;

    final coverScaleHeight = mediaQueryHeight / 3.2;

    Color? backgroundColor = widget.color ?? Theme.of(context).cardColor;
    final luminance = backgroundColor != null ? backgroundColor.computeLuminance() : 0;
    final targetLuminance = 0.5;
    final adjustedIconColor = luminance > targetLuminance ? Colors.black : Colors.white;

    return widget.games != null && widget.games!.isNotEmpty
        ? Container(
      margin: EdgeInsets.only(bottom: mediaQueryHeight * 0.01),
    child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ClayContainer(
                  depth: 60,
                  spread: 2,
                  customBorderRadius: BorderRadius.circular(12),
                  color: backgroundColor,
                  child: Padding(
                    padding: EdgeInsets.all(6),
                    child: FittedBox(
                      child: Text(
                        widget.headline,
                        textAlign: TextAlign.left,
                        style: TextStyle(color: adjustedIconColor),
                      ),
                    ),
                  ),
                ),
                if (widget.games!.length > widget.showLimit)
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                            (Set<MaterialState> states) {
                          return backgroundColor;
                        },
                      ),
                    ),
                    onPressed: () {
                      widget.isPagination
                          ? Navigator.of(context).push(
                          AllGamesGridPaginationScreen.route(
                              widget.headline, widget.body))
                          : Navigator.of(context).push(
                          AllGamesGridScreen.route(
                              widget.games!, context, widget.headline));
                    },
                    child: Padding(
                      padding: EdgeInsets.all(5),
                      child: FittedBox(
                        child: Text(
                          'All',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: adjustedIconColor),
                        ),
                      ),
                    ),
                  )
              ],
            ),
          ),
          Container(
            height: coverScaleHeight,
            child: ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: widget.games!.length < widget.showLimit
                  ? widget.games!.length
                  : widget.showLimit,
              itemBuilder: (context, index) {
                if (index >= widget.games!.length) {
                  return null; // or a placeholder widget
                }
                Game game = widget.games![index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GamePreviewView(
                    game: game,
                    isCover: false,
                    buildContext: context,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    )
       :Container();
  }
}
