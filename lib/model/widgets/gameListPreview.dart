import 'package:clay_containers/widgets/clay_container.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gamer_grove/model/widgets/gamePreview.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';
import 'package:loading_indicator/loading_indicator.dart';
import '../firebase/firebaseUser.dart';
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
  final bool isAggregated;
  FirebaseUserModel? otherUserModel;

  GameListView({
    required this.headline,
    required this.games,
    required this.isPagination,
    required this.body, required this.showLimit, this.color, required this.isAggregated, this.otherUserModel
  });

  @override
  State<StatefulWidget> createState() => GameListViewState();
}

class GameListViewState extends State<GameListView> {
  @override
  Widget build(BuildContext context) {
    final mediaQueryHeight = MediaQuery.of(context).size.height;
    final mediaQueryWidth = MediaQuery.of(context).size.width;

    final coverScaleHeight = mediaQueryHeight / 3.1;

    Color? backgroundColor = widget.color ?? Theme.of(context).cardColor;
    final luminance = backgroundColor.computeLuminance();
    const targetLuminance = 0.5;
    final adjustedIconColor = luminance > targetLuminance ? Colors.black : Colors.white;

    return widget.games != null && widget.games!.isNotEmpty
        ? Container(
      margin: EdgeInsets.only(bottom: mediaQueryHeight * 0.01),
    child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ClayContainer(
                  depth: 60,
                  spread: 2,
                  customBorderRadius: BorderRadius.circular(12),
                  color: backgroundColor,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
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
                              widget.headline, widget.body, widget.isAggregated, widget.otherUserModel))
                          : Navigator.of(context).push(
                          AllGamesGridScreen.route(
                              widget.games!, context, widget.headline, widget.otherUserModel));
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(5),
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
          AspectRatio(
            aspectRatio: 16 /9,
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
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: GamePreviewView(
                    game: game,
                    isCover: false,
                    buildContext: context, needsRating: true, isClickable: true, otherUserModel: widget.otherUserModel, showRatedItem: true,
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
