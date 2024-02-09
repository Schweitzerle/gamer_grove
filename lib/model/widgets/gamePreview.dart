import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:clay_containers/clay_containers.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:marquee/marquee.dart';

import '../igdb_models/game.dart';
import '../singleton/sinlgleton.dart';
import '../views/gameDetailScreen.dart';

class GamePreviewView extends StatefulWidget {
  final Game game;
  final bool isCover;
  final BuildContext buildContext;

  GamePreviewView({
    required this.game,
    required this.isCover,
    required this.buildContext,
  });

  @override
  _GamePreviewViewState createState() => _GamePreviewViewState();
}

class _GamePreviewViewState extends State<GamePreviewView> {
  late Color colorpalette;
  late Color lightColor;
  late Color darkColor;
  bool isColorLoaded = false;

  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async {
    setState(() {
      colorpalette = Theme.of(widget.buildContext).colorScheme.inversePrimary;
      lightColor = Theme.of(widget.buildContext).colorScheme.primary;
      darkColor = Theme.of(widget.buildContext).colorScheme.background;
    });
    await Future.wait([getColorPalette()]);
  }

  @override
  Widget build(BuildContext context) {
    final mediaQueryHeight = MediaQuery.of(context).size.height;
    final mediaQueryWidth = MediaQuery.of(context).size.width;

    final coverScaleWidth = mediaQueryWidth / 2.2;
    final coverScaleHeight = mediaQueryHeight / 2.3;

    return InkWell(
      onTap: () {
        Navigator.of(context).push(GameDetailScreen.route(widget.game, context));
      },
      child: ClayContainer(
        height: coverScaleHeight,
        width: coverScaleWidth,
        color: darkColor,
        spread: 2,
        depth: 60,
        borderRadius: 14,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14.0),
              child: CachedNetworkImage(
                imageUrl: '${widget.game.cover?.url}',
                placeholder: (context, url) => Container(
                  color: Theme.of(context).colorScheme.tertiaryContainer,
                ),
                errorWidget: (context, url, error) => const Icon(Icons.error),
                fit: BoxFit.cover,
              ),
            ),
            Container(
              padding: const EdgeInsets.only(
                left: 8,
                right: 8,
                bottom: 8,
              ),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black,
                  ],
                ),
                borderRadius: BorderRadius.circular(8),
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
          ],
        ),
      ),
    );
  }

  Future<void> getColorPalette() async {
    if (widget.game.cover!.url != null) {
      final PaletteGenerator paletteGenerator =
          await PaletteGenerator.fromImageProvider(
        NetworkImage('${widget.game.cover!.url}'),
        size: Size(100, 150),
        maximumColorCount: 10,
      );
      setState(() {
        colorpalette = paletteGenerator.dominantColor?.color ??
            Theme.of(widget.buildContext).colorScheme.inversePrimary;
        lightColor = paletteGenerator.lightVibrantColor?.color ??
            Theme.of(widget.buildContext).colorScheme.primary;
        darkColor = paletteGenerator.darkVibrantColor?.color ??
            Theme.of(widget.buildContext).colorScheme.background;
        isColorLoaded = true;
      });
    }
  }
}
