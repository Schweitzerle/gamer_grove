import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:marquee/marquee.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../igdb_models/game.dart';
import '../singleton/sinlgleton.dart';
import '../views/gameDetailScreen.dart';

class GamePreviewView extends StatefulWidget {

  final Game game;
  final bool isCover;

  GamePreviewView({
    required this.game, required this.isCover,
  });

  @override
  _GamePreviewViewState createState() => _GamePreviewViewState();
}

class _GamePreviewViewState extends State<GamePreviewView> {
  Color colorpalette = Singleton.thirdTabColor;
  Color lightColor = Singleton.secondTabColor;
  Color darkColor = Singleton.fourthTabColor;
  bool isColorLoaded = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initialize();
  }

  Future<void> initialize() async {
    await Future.wait([getColorPalette()]);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  Future<void> getColorPalette() async {
    if (widget.game.cover!.url != null) {
      final PaletteGenerator paletteGenerator =
      await PaletteGenerator.fromImageProvider(
        NetworkImage('${widget.game.cover!.url}'),
        size: Size(100, 150), // Adjust the image size as needed
        maximumColorCount: 10, // Adjust the maximum color count as needed
      );
      setState(() {
        colorpalette =
            paletteGenerator.dominantColor?.color ?? Singleton.thirdTabColor;
        lightColor = paletteGenerator.lightVibrantColor?.color ?? colorpalette;
        darkColor = paletteGenerator.darkVibrantColor?.color ?? colorpalette;
        isColorLoaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQueryHeight = MediaQuery.of(context).size.height;
    final mediaQueryWidth = MediaQuery.of(context).size.width;

    final coverScaleWidth = mediaQueryWidth / 2.2;
    final coverScaleHeight = mediaQueryHeight / 2.3;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          GameDetailScreen.route(widget.game),
        );

      },
      child: Stack(
        children: [
          Container(
            height: coverScaleHeight,
            width: coverScaleWidth,
            decoration: widget.game.cover?.url != null
                ? BoxDecoration(
              boxShadow: [
                BoxShadow(
                    color: widget.isCover ? lightColor : Colors.transparent,
                    offset: Offset(4.0, 4.0),
                    blurRadius: 15.0,
                    spreadRadius: 1.0),
                BoxShadow(
                    color: widget.isCover ? lightColor : Colors.transparent,
                    offset: Offset(-4.0, -4.0),
                    blurRadius: 15.0,
                    spreadRadius: 1.0),
              ],
              borderRadius: BorderRadius.circular(20),
              image: DecorationImage(
                image: NetworkImage(
                  '${widget.game.cover?.url}',
                ),
                fit: BoxFit.cover,
              ),
            )
                : BoxDecoration(
              color: Singleton.thirdTabColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.only(
                left: 8,
                right: 8,
                bottom: 8,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black,
                  ],
                ),
                borderRadius: BorderRadius.all(
                  Radius.circular(20),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  CircularPercentIndicator(
                    radius: mediaQueryWidth * 0.07,
                    lineWidth: 8.0,
                    animation: true,
                    animationDuration: 1000,
                    percent: widget.game.totalRating != null
                        ? Singleton.parseDouble(widget.game.totalRating!) / 100
                        : 0,
                    center: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${widget.game.totalRating != null ? widget.game.totalRating!.toStringAsFixed(0) : 0}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    circularStrokeCap: CircularStrokeCap.round,
                    backgroundColor: Colors.transparent,
                    progressColor: Singleton.getCircleColor(
                      Singleton.parseDouble(widget.game.totalRating),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Marquee(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      fadingEdgeEndFraction: 0.9,
                      fadingEdgeStartFraction: 0.1,
                      blankSpace: 200,
                      pauseAfterRound: Duration(seconds: 4),
                      text: '${widget.game.name}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

}
