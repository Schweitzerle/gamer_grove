import 'package:bottom_bar_matu/utils/app_utils.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:clay_containers/clay_containers.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gamer_grove/model/widgets/circular_rating_widget.dart';
import 'package:gamer_grove/model/widgets/ratingDialog.dart';
import 'package:get_it/get_it.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:marquee/marquee.dart';

import '../../repository/firebase/firebase.dart';
import '../firebase/firebaseUser.dart';
import '../igdb_models/game.dart';
import '../singleton/sinlgleton.dart';
import '../views/gameDetailScreen.dart';

class GamePreviewView extends StatefulWidget {
  final Game game;
  final bool isCover;
  final BuildContext buildContext;
  final bool needsRating;

  GamePreviewView({
    required this.game,
    required this.isCover,
    required this.buildContext, required this.needsRating,
  });

  @override
  _GamePreviewViewState createState() => _GamePreviewViewState();
}

class _GamePreviewViewState extends State<GamePreviewView> {
  late Color colorpalette;
  late Color lightColor;
  late Color darkColor;
  late GameModel gameModel;
  final getIt = GetIt.instance;
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
    await Future.wait([getColorPalette(), getGameModel()]);
  }

  @override
  Widget build(BuildContext context) {
    final mediaQueryHeight = MediaQuery.of(context).size.height;
    final mediaQueryWidth = MediaQuery.of(context).size.width;

    final coverScaleHeight = mediaQueryHeight / 3.1;
    final coverScaleWidth = coverScaleHeight * 0.69;

    final luminance = colorpalette.computeLuminance();
    final targetLuminance = 0.5;
    final adjustedTextColor =
    luminance > targetLuminance ? Colors.black : Colors.white;

    return InkWell(
      onTap: () {
        Navigator.of(context).push(GameDetailScreen.route(widget.game, context, gameModel));
      },
      onLongPress: () {
        showDialog(
            context: context,
            barrierColor: colorpalette.withOpacity(.8),
            builder: (BuildContext context) {
              return CustomRatingDialog(colorPalette: colorpalette, adjustedTextColor: adjustedTextColor, gameModel: gameModel,);
            }
        );
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
                errorWidget: (context, url, error) => GlassContainer(
                 color: lightColor,
                  child: Icon(FontAwesomeIcons.gamepad),
                ),
                fit: BoxFit.fill,
              ),
            ),
            Container(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                if(gameModel.wishlist) Icon(FontAwesomeIcons.solidBookmark,),
                if(gameModel.recommended) Icon(FontAwesomeIcons.thumbsUp,),
                if(gameModel.rating > 0) CircularRatingWidget(ratingValue: gameModel.rating.toDouble() * 10,),
              ],),
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
                    if(widget.needsRating)Expanded(child: CircularRatingWidget(ratingValue: widget.game.totalRating,)),
                    if(widget.needsRating)SizedBox(width: 8),
                    Expanded(
                      flex: 2,
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
    if (widget.game.cover != null && widget.game.cover!.url != null) {
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

  Future<void> getGameModel() async {
    final currentUser = getIt<FirebaseUserModel>();
    Map<String, dynamic> games = currentUser.games.values.firstWhereOrNull((game) => game['id'] == widget.game.id.toString()) ?? GameModel(id: widget.game.id.toString(), wishlist: false, recommended: false, rating: 0.0).toJson();
    GameModel game = GameModel.fromMap(games);
    setState(() {
      gameModel = game;
    });
  }

}
