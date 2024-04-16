import 'package:bottom_bar_matu/utils/app_utils.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:clay_containers/clay_containers.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gamer_grove/model/widgets/circular_rating_widget.dart';
import 'package:gamer_grove/model/widgets/ratingDialog.dart';
import 'package:get_it/get_it.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:marquee/marquee.dart';
import 'package:provider/provider.dart';
import 'package:snappable_thanos/snappable_thanos.dart';

import '../../repository/firebase/firebase.dart';
import '../firebase/firebaseUser.dart';
import '../firebase/gameModel.dart';
import '../igdb_models/game.dart';
import '../singleton/sinlgleton.dart';
import '../views/gameDetailScreen.dart';

class GamePreviewView extends StatefulWidget {
  final Game game;
  final bool isCover;
  final BuildContext buildContext;
  final bool needsRating;
  final bool isClickable;
  FirebaseUserModel? otherUserModel;

  GamePreviewView(
      {required this.game,
      required this.isCover,
      required this.buildContext,
      required this.needsRating,
      required this.isClickable,
      this.otherUserModel});

  @override
  _GamePreviewViewState createState() => _GamePreviewViewState();
}

class _GamePreviewViewState extends State<GamePreviewView> {
  late Color colorPalette;
  late Color lightColor;
  late Color darkColor;
  late GameModel otherModel;
  final getIt = GetIt.instance;
  bool isColorLoaded = false;

  @override
  void initState() {
    super.initState();
    initialize();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> initialize() async {
    setState(() {
      colorPalette = Theme.of(widget.buildContext).colorScheme.inversePrimary;
      lightColor = Theme.of(widget.buildContext).colorScheme.primary;
      darkColor = Theme.of(widget.buildContext).colorScheme.background;
    });
    await Future.wait(
        [getColorPalette(), getGameModelOtherUser()]);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: widget.game.gameModel,
      child: Consumer<GameModel>(
        builder: (context, gameModel, child) {
          final mediaQueryHeight = MediaQuery.of(context).size.height;
          final mediaQueryWidth = MediaQuery.of(context).size.width;
          final coverScaleHeight = mediaQueryHeight / 3.1;
          final coverScaleWidth = coverScaleHeight * 0.69;
          final luminance = colorPalette.computeLuminance();
          final targetLuminance = 0.5;
          final adjustedTextColor =
              luminance > targetLuminance ? Colors.black : Colors.white;

          return Padding(
            padding: const EdgeInsets.all(4.0),
            child: InkWell(
              onTap: () {
                if (widget.isClickable) {
                  Navigator.of(context).push(
                      GameDetailScreen.route(widget.game, context, colorPalette, lightColor));
                }
              },
              onLongPress: () {
                if (widget.isClickable) {
                  showDialog(
                      context: context,
                      barrierColor: colorPalette.withOpacity(.8),
                      builder: (BuildContext context) {
                        return CustomRatingDialog(
                          colorPalette: colorPalette,
                          adjustedTextColor: adjustedTextColor,
                          game: widget.game,
                        );
                      });
                }
              },
              child: ClayContainer(
                height: coverScaleHeight,
                width: coverScaleWidth,
                color: colorPalette,
                spread: 2,
                depth: 60,
                borderRadius: 14,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14.0),
                      child: Hero(
                        tag: widget.game.id,
                        child: CachedNetworkImage(
                          imageUrl: '${widget.game.cover?.url}',
                          placeholder: (context, url) => Container(
                            color:
                                Theme.of(context).colorScheme.tertiaryContainer,
                          ),
                          errorWidget: (context, url, error) => GlassContainer(
                            color: colorPalette.onColor,
                            child: Icon(FontAwesomeIcons.gamepad),
                          ),
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                    if (widget.otherUserModel != null)
                      Positioned(
                          left: 0,
                          top: 0,
                          child:  GlassContainer(
                            blur: 12,
                            shadowStrength: 4,
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(14),
                            shadowColor: colorPalette,
                            color: colorPalette.onColor.withOpacity(.1),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 2.0, vertical: 4),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Row(
                                    children: [
                                      const SizedBox(
                                        width: 2,
                                      ),
                                      Animate(
                                        autoPlay: true,
                                        delay: const Duration(seconds: 1),
                                        effects: const [
                                          FadeEffect(),
                                          ScaleEffect(),
                                          SlideEffect(),
                                          MoveEffect(begin: Offset(40, 0))
                                        ],
                                        child: Center(
                                          child: CircleAvatar(
                                            radius: 12,
                                            foregroundImage: NetworkImage(
                                              widget.otherUserModel!.profileUrl,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 2,
                                      ),
                                    ],
                                  ),
                                  if (otherModel.rating > 0)
                                    Row(
                                    children: [
                                      const SizedBox(
                                        width: 2,
                                      ),
                                      Animate(
                                        autoPlay: true,
                                        delay: const Duration(seconds: 1),
                                        effects: const [
                                          FadeEffect(),
                                          ScaleEffect(),
                                          SlideEffect(),
                                          MoveEffect(begin: Offset(40, 0))
                                        ],
                                        child: Center(
                                          child: CircularRatingWidget(
                                            ratingValue:
                                            otherModel.rating.toDouble() * 10,
                                            radiusMultiplicator: .03,
                                            fontSize: 8,
                                            lineWidth: 2,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 2,
                                      ),
                                    ],
                                  ),
                                  if (otherModel.recommended)
                                    Row(
                                      children: [
                                        const SizedBox(
                                          width: 2,
                                        ),
                                        Animate(
                                          autoPlay: true,
                                          delay: const Duration(seconds: 1),
                                          effects: const [
                                            FadeEffect(),
                                            ScaleEffect(),
                                            SlideEffect(),
                                            MoveEffect(begin: Offset(40, 0))
                                          ],
                                          child: const Center(
                                            child: Icon(FontAwesomeIcons.thumbsUp,
                                              color: Colors.deepOrange, size: 18,),
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 2,
                                        ),
                                      ],
                                    ),
                                  if (otherModel.wishlist)
                                    Row(
                                      children: [
                                        const SizedBox(
                                          width: 2,
                                        ),
                                        Animate(
                                          autoPlay: true,
                                          delay: const Duration(seconds: 1),
                                          effects: const [
                                            FadeEffect(),
                                            ScaleEffect(),
                                            SlideEffect(),
                                            MoveEffect(begin: Offset(80, 0))
                                          ],
                                          child: const Center(
                                            child: Icon(
                                              FontAwesomeIcons.solidBookmark,
                                              color: Colors.blueAccent, size: 18,),
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 2,
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          )),
                    Consumer<GameModel>(builder: (context, gameModel, child) {
                      if (widget.needsRating) {
                        if (gameModel.wishlist ||
                            gameModel.recommended ||
                            gameModel.rating > 0) {
                          return Positioned(
                            top: 0,
                            right: 0,
                            child: GlassContainer(
                              blur: 12,
                              shadowStrength: 4,
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.circular(14),
                              shadowColor: colorPalette,
                              color: colorPalette.onColor.withOpacity(.1),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 4.0, vertical: 2),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Consumer<GameModel>(
                                      builder: (context, gameModel, child) {
                                        if (gameModel.rating > 0) {
                                          return Column(
                                            children: [
                                              const SizedBox(
                                                height: 2,
                                              ),
                                              Animate(
                                                autoPlay: true,
                                                delay: const Duration(seconds: 1),
                                                effects: const [
                                                  FadeEffect(),
                                                  ScaleEffect(),
                                                  SlideEffect(),
                                                  MoveEffect(begin: Offset(40, 0))
                                                ],
                                                child: Center(
                                                  child: CircularRatingWidget(
                                                    ratingValue: gameModel.rating
                                                        .toDouble() *
                                                        10,
                                                    radiusMultiplicator: .04,
                                                    fontSize: 10,
                                                    lineWidth: 4,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 2,
                                              ),
                                            ],
                                          );
                                        } else {
                                          return Container(); // or any placeholder widget
                                        }
                                      },
                                    ),
                                    Consumer<GameModel>(
                                      builder: (context, gameModel, child) {
                                        if (gameModel.wishlist) {
                                          return Column(
                                            children: [
                                              const SizedBox(
                                                height: 2,
                                              ),
                                              Animate(
                                                autoPlay: true,
                                                delay: const Duration(seconds: 1),
                                                effects: const [
                                                  FadeEffect(),
                                                  ScaleEffect(),
                                                  SlideEffect(),
                                                  MoveEffect(begin: Offset(80, 0))
                                                ],
                                                child: const Center(
                                                  child: Icon(
                                                      FontAwesomeIcons
                                                          .solidBookmark,
                                                      color: Colors.blueAccent, size: 22,),
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 2,
                                              ),
                                            ],
                                          );
                                        } else {
                                          return Container(); // or any placeholder widget
                                        }
                                      },
                                    ),
                                    Consumer<GameModel>(
                                      builder: (context, gameModel, child) {
                                        if (gameModel.recommended) {
                                          return Column(
                                            children: [
                                              const SizedBox(
                                                height: 2,
                                              ),
                                              Animate(
                                                autoPlay: true,
                                                delay: const Duration(seconds: 1),
                                                effects: const [
                                                  FadeEffect(),
                                                  ScaleEffect(),
                                                  SlideEffect(),
                                                  MoveEffect(begin: Offset(40, 0))
                                                ],
                                                child: const Center(
                                                  child: Icon(
                                                      FontAwesomeIcons.thumbsUp,
                                                      color: Colors.deepOrange, size: 22,),
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 2,
                                              ),
                                            ],
                                          );
                                        } else {
                                          return Container(); // or any placeholder widget
                                        }
                                      },
                                    ),

                                  ],
                                ),
                              ),
                            ),
                          );
                        } else {
                          return Container();
                        }
                      } else {
                        return Container();
                      }
                    }),
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
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (widget.needsRating)
                            Expanded(
                                child: CircularRatingWidget(
                              ratingValue: widget.game.totalRating ?? 0,
                              radiusMultiplicator: .07,
                              fontSize: 18,
                              lineWidth: 6,
                            )),
                          if (widget.needsRating) SizedBox(width: 8),
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
            ),
          );
        },
      ),
    );
  }

  Future<void> getColorPalette() async {
    if (widget.game.cover != null && widget.game.cover!.url != null) {
      final PaletteGenerator paletteGenerator =
          await PaletteGenerator.fromImageProvider(
        NetworkImage('${widget.game.cover!.url}'),
        size: const Size(100, 150),
        maximumColorCount: 10,
      );
      setState(() {
        colorPalette = paletteGenerator.dominantColor?.color ??
            Theme.of(widget.buildContext).colorScheme.inversePrimary;
        lightColor = paletteGenerator.lightVibrantColor?.color ??
            Theme.of(widget.buildContext).colorScheme.primary;
        darkColor = paletteGenerator.darkVibrantColor?.color ??
            Theme.of(widget.buildContext).colorScheme.background;
        isColorLoaded = true;
      });
    }
  }


  Future<void> getGameModelOtherUser() async {
    if (widget.otherUserModel != null) {
      final currentUser = widget.otherUserModel!;
      Map<String, dynamic> games = currentUser.games.values.firstWhereOrNull(
              (game) => game['id'] == widget.game.id.toString()) ??
          GameModel(
                  id: widget.game.id.toString(),
                  wishlist: false,
                  recommended: false,
                  rating: 0.0)
              .toJson();
      GameModel game = GameModel.fromMap(games);
      setState(() {
        otherModel = game;
      });
    }
  }
}
