import 'package:flutter/material.dart';
import 'package:clay_containers/clay_containers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:gamer_grove/model/igdb_models/character.dart';
import 'package:gamer_grove/model/igdb_models/game_engine.dart';
import 'package:marquee/marquee.dart';
import 'package:palette_generator/palette_generator.dart';

class CharacterView extends StatefulWidget {
  final Character character;
  final BuildContext buildContext;

  const CharacterView({Key? key, required this.character, required this.buildContext}) : super(key: key);

  @override
  _CharacterViewState createState() => _CharacterViewState();
}

class _CharacterViewState extends State<CharacterView> {
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
        //TODO: Charcterscreen Navigator.of(context).push(GameDetailScreen.route(widget.game, context));
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
                imageUrl: '${widget.character.mugShotID?.url}',
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
                  Expanded(
                    child: Marquee(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      fadingEdgeEndFraction: 0.9,
                      fadingEdgeStartFraction: 0.1,
                      blankSpace: 200,
                      pauseAfterRound: Duration(seconds: 4),
                      text: '${widget.character.name}',
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
    if (widget.character.mugShotID != null && widget.character.mugShotID!.url != null) {
      final PaletteGenerator paletteGenerator =
      await PaletteGenerator.fromImageProvider(
        NetworkImage('${widget.character.mugShotID!.url}'),
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
