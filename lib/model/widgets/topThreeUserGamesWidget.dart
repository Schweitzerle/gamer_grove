import 'dart:ui';

import 'package:clay_containers/widgets/clay_container.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gamer_grove/model/widgets/gamePreview.dart';
import 'package:gamer_grove/model/widgets/shimmerGameItem.dart';
import 'package:get_it/get_it.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';
import 'package:provider/provider.dart';
import 'package:toasty_box/toast_enums.dart';
import 'package:toasty_box/toast_service.dart';

import '../../repository/igdb/IGDBApiService.dart';
import '../firebase/firebaseUser.dart';
import '../igdb_models/game.dart';
import 'gameListPreview.dart';

class TopThreeUserGamesWidget extends StatefulWidget {
  final Game game;

  const TopThreeUserGamesWidget({super.key, required this.game});

  @override
  State<TopThreeUserGamesWidget> createState() =>
      _TopThreeUserGamesWidgetState();
}

class _TopThreeUserGamesWidgetState extends State<TopThreeUserGamesWidget> {
  final getIt = GetIt.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final apiService = IGDBApiService();
  static const bottomColor = Color(0xFF87868c);
  static const middleColor = Color(0xFFA48111);
  static const topColor = Color(0xFF6B0000);

  Future<List<Game>> getIGDBData() async {
    final currentUser = getIt<FirebaseUserModel>();
    if (getGameKeys(currentUser.firstTopGame).isNotEmpty ||
        getGameKeys(currentUser.secondTopGame).isNotEmpty ||
        getGameKeys(currentUser.thirdTopGame).isNotEmpty) {
      try {
        final response3 =
            await apiService.getIGDBData(IGDBAPIEndpointsEnum.games, getBody());

        return apiService.parseResponseToGame(response3);
      } catch (e, stackTrace) {
        print('Error: $e');
        print('Stack Trace: $stackTrace');
        return []; // Return empty list on error
      }
    } else {
      return []; // Return empty list if no games in wishlist
    }
  }

  String getBody() {
    final currentUser = getIt<FirebaseUserModel>();
    final recommendedGameKeys = [];
    recommendedGameKeys.addAll(getGameKeys(currentUser.firstTopGame));
    recommendedGameKeys.addAll(getGameKeys(currentUser.secondTopGame));
    recommendedGameKeys.addAll(getGameKeys(currentUser.thirdTopGame));

    final gameIds = recommendedGameKeys.map((key) => 'id = $key').toList();
    final gamesJoin = gameIds.join("|");
    String gamesString = 'w $gamesJoin;';

    String body1 =
        'fields name, cover.*, artworks.*, first_release_date, follows, category, url, hypes, status, total_rating, total_rating_count, version_title; $gamesString l 500;';
    return body1;
  }

  List<String> getGameKeys(Map<String, dynamic> games) {
    return games.keys.toList();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = getIt<FirebaseUserModel>();
    final mediaQueryHeight = MediaQuery.of(context).size.height;
    Color color = Theme.of(context).primaryColor;
    return ChangeNotifierProvider.value(
      value: currentUser,
      child: Consumer<FirebaseUserModel>(
          builder: (context, firebaseUserModel, child) {
        return FutureBuilder<List<Game>>(
            future: getIGDBData(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                List<Game> topThreeGames = snapshot.data!;
                Game? firstGame = currentUser.firstTopGame.isNotEmpty
                    ? topThreeGames
                        .where((element) => currentUser.firstTopGame
                            .containsKey(element.id.toString()))
                        .singleOrNull
                    : null;
                Game? secondGame = currentUser.secondTopGame.isNotEmpty
                    ? topThreeGames
                        .where((element) => currentUser.secondTopGame
                            .containsKey(element.id.toString()))
                        .singleOrNull
                    : null;
                Game? thirdGame = currentUser.thirdTopGame.isNotEmpty
                    ? topThreeGames
                        .where((element) => currentUser.thirdTopGame
                            .containsKey(element.id.toString()))
                        .singleOrNull
                    : null;
                return Column(
                  children: [
                    GlassContainer(
                      blur: 12,
                      shadowStrength: 4,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(14),
                      shadowColor: Theme.of(context).colorScheme.inversePrimary,
                      color: Theme.of(context)
                          .colorScheme
                          .inversePrimary
                          .withOpacity(.3),
                      child: const Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 4.0, vertical: 4),
                        child: Text('Your Top Three Games',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            )),
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Row(
                      children: [
                        Expanded(
                            flex: 5,
                            child: AspectRatio(
                                aspectRatio: 9 / 13,
                                child: secondGame != null
                                    ? Stack(children: [
                                        Padding(
                                          padding: const EdgeInsets.all(2.0),
                                          child: GlassContainer(
                                            color: middleColor.withOpacity(.3),
                                            blur: 12,
                                            shadowStrength: 2,
                                            shape: BoxShape.rectangle,
                                            borderRadius:
                                            BorderRadius.circular(14),
                                            shadowColor: middleColor.lighten(20),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(2.0),
                                              child: GamePreviewView(
                                                  game: secondGame,
                                                  isCover: false,
                                                  buildContext: context,
                                                  needsRating: false,
                                                  isClickable: false, showRatedItem: true,),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          right: 2,
                                          bottom: 2,
                                          child: GlassContainer(
                                            blur: 12,
                                            shadowStrength: 4,
                                            shape: BoxShape.rectangle,
                                            borderRadius:
                                                BorderRadius.circular(14),
                                            shadowColor: middleColor,
                                            color: middleColor.onColor
                                                .withOpacity(.1),
                                            child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 2.0,
                                                        vertical: 4),
                                                child: Column(children: [
                                                  GestureDetector(
                                                      onTap: () {
                                                        _updateSecondTopGameInDatabase(
                                                            context,
                                                            middleColor,
                                                            widget.game);
                                                      },
                                                      child: const Icon(
                                                        Icons
                                                            .change_circle_outlined,
                                                        color: Colors.yellow,
                                                      )),
                                                  const SizedBox(
                                                    height: 4,
                                                  ),
                                                  GestureDetector(
                                                      onTap: () {
                                                        _deleteSecondTopGameInDatabase(
                                                            context,
                                                            middleColor,
                                                            widget.game);
                                                      },
                                                      child: const Icon(
                                                        CupertinoIcons.delete,
                                                        color: Colors.red,
                                                      )),
                                                ])),
                                          ),
                                        ),
                                      ])
                                    : topGamesPlaceholder(middleColor))),
                        Expanded(
                            flex: 6,
                            child: AspectRatio(
                                aspectRatio: 9 / 13,
                                child: firstGame != null
                                    ? Stack(children: [
                                        Padding(
                                          padding: const EdgeInsets.all(2.0),
                                          child: GlassContainer(
                                            color: topColor.withOpacity(.3),
                                            blur: 12,
                                            shadowStrength: 2,
                                            shape: BoxShape.rectangle,
                                            borderRadius:
                                                BorderRadius.circular(14),
                                            shadowColor: topColor.lighten(20),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(2.0),
                                              child: GamePreviewView(
                                                  game: firstGame,
                                                  isCover: false,
                                                  buildContext: context,
                                                  needsRating: false,
                                                  isClickable: false, showRatedItem: true,),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          right: 2,
                                          bottom: 2,
                                          child: GlassContainer(
                                            blur: 12,
                                            shadowStrength: 4,
                                            shape: BoxShape.rectangle,
                                            borderRadius:
                                                BorderRadius.circular(14),
                                            shadowColor: topColor,
                                            color: topColor.onColor
                                                .withOpacity(.1),
                                            child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 2.0,
                                                        vertical: 4),
                                                child: Column(children: [
                                                  GestureDetector(
                                                      onTap: () {
                                                        _updateFirstTopGameInDatabase(
                                                            context,
                                                            topColor,
                                                            widget.game);
                                                      },
                                                      child: const Icon(
                                                        Icons
                                                            .change_circle_outlined,
                                                        color: Colors.yellow,
                                                      )),
                                                  const SizedBox(
                                                    height: 4,
                                                  ),
                                                  GestureDetector(
                                                      onTap: () {
                                                        _deleteFirstTopGameInDatabase(
                                                            context,
                                                            topColor,
                                                            widget.game);
                                                      },
                                                      child: const Icon(
                                                        CupertinoIcons.delete,
                                                        color: Colors.red,
                                                      )),
                                                ])),
                                          ),
                                        ),
                                      ])
                                    : topGamesPlaceholder(topColor))),
                        Expanded(
                            flex: 4,
                            child: AspectRatio(
                              aspectRatio: 9 / 13,
                              child: thirdGame != null
                                  ? Stack(children: [
                                      Padding(
                                        padding: const EdgeInsets.all(2.0),
                                        child: GlassContainer(
                                          color: bottomColor.withOpacity(.3),
                                          blur: 12,
                                          shadowStrength: 2,
                                          shape: BoxShape.rectangle,
                                          borderRadius:
                                          BorderRadius.circular(14),
                                          shadowColor: bottomColor.lighten(20),
                                          child: Padding(
                                            padding: const EdgeInsets.all(2.0),
                                            child: GamePreviewView(
                                                game: thirdGame,
                                                isCover: false,
                                                buildContext: context,
                                                needsRating: false,
                                                isClickable: false, showRatedItem: true,),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        right: 2,
                                        bottom: 2,
                                        child: GlassContainer(
                                          blur: 12,
                                          shadowStrength: 4,
                                          shape: BoxShape.rectangle,
                                          borderRadius:
                                              BorderRadius.circular(14),
                                          shadowColor: bottomColor,
                                          color: bottomColor.onColor
                                              .withOpacity(.1),
                                          child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 2.0,
                                                      vertical: 4),
                                              child: Column(children: [
                                                GestureDetector(
                                                    onTap: () {
                                                      _updateThirdTopGameInDatabase(
                                                          context,
                                                          bottomColor,
                                                          widget.game);
                                                    },
                                                    child: const Icon(
                                                      Icons
                                                          .change_circle_outlined,
                                                      color: Colors.yellow,
                                                    )),
                                                const SizedBox(
                                                  height: 4,
                                                ),
                                                GestureDetector(
                                                    onTap: () {
                                                      _deleteThirdTopGameInDatabase(
                                                          context,
                                                          bottomColor,
                                                          widget.game);
                                                    },
                                                    child: const Icon(
                                                      CupertinoIcons.delete,
                                                      color: Colors.red,
                                                    )),
                                              ])),
                                        ),
                                      ),
                                    ])
                                  : topGamesPlaceholder(bottomColor),
                            )),
                      ],
                    ),
                  ],
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              }
              // Display a loading indicator while fetching data
              return Column(
                children: [
                  GlassContainer(
                    blur: 12,
                    shadowStrength: 4,
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(14),
                    shadowColor: Theme.of(context).colorScheme.inversePrimary,
                    color: Theme.of(context)
                        .colorScheme
                        .inversePrimary
                        .withOpacity(.3),
                    child: const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 4.0, vertical: 4),
                      child: Text('Your Top Three Games',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          )),
                    ),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Row(
                    children: [
                      Expanded(
                          flex: 5,
                          child: ShimmerGlassContainerGame(
                            needsRating: false, color: color,
                          )),
                      Expanded(
                          flex: 6,
                          child: ShimmerGlassContainerGame(
                            needsRating: false, color: color,
                          )),
                      Expanded(
                          flex: 4,
                          child: ShimmerGlassContainerGame(
                            needsRating: false, color: color,
                          )),
                    ],
                  ),
                ],
              );
            });
      }),
    );
  }

  Future<void> _updateFirstTopGameInDatabase(
      BuildContext context, Color color, Game game) async {
    final currentUser = getIt<FirebaseUserModel>();
    final userId = _auth.currentUser!.uid;
    final userDoc = FirebaseFirestore.instance.collection('Users').doc(userId);

    currentUser.updateFirstTopGame(
        game.gameModel, context, topColor, widget.game);
    await userDoc.update({'firstTopGame': currentUser.firstTopGame});
  }

  Future<void> _deleteFirstTopGameInDatabase(
      BuildContext context, Color color, Game game) async {
    final currentUser = getIt<FirebaseUserModel>();
    final userId = _auth.currentUser!.uid;
    final userDoc = FirebaseFirestore.instance.collection('Users').doc(userId);

    currentUser.deleteFirstTopGame(context, topColor, widget.game);
    await userDoc.update({'firstTopGame': currentUser.firstTopGame});
  }

  Future<void> _updateSecondTopGameInDatabase(
      BuildContext context, Color color, Game game) async {
    final currentUser = getIt<FirebaseUserModel>();
    final userId = _auth.currentUser!.uid;
    final userDoc = FirebaseFirestore.instance.collection('Users').doc(userId);

    currentUser.updateSecondTopGame(
        game.gameModel, context, middleColor, widget.game);
    await userDoc.update({'secondTopGame': currentUser.secondTopGame});
  }

  Future<void> _deleteSecondTopGameInDatabase(
      BuildContext context, Color color, Game game) async {
    final currentUser = getIt<FirebaseUserModel>();
    final userId = _auth.currentUser!.uid;
    final userDoc = FirebaseFirestore.instance.collection('Users').doc(userId);

    currentUser.deleteSecondTopGame(context, middleColor, widget.game);
    await userDoc.update({'secondTopGame': currentUser.secondTopGame});
  }

  Future<void> _updateThirdTopGameInDatabase(
      BuildContext context, Color color, Game game) async {
    final currentUser = getIt<FirebaseUserModel>();
    final userId = _auth.currentUser!.uid;
    final userDoc = FirebaseFirestore.instance.collection('Users').doc(userId);

    currentUser.updateThirdTopGame(
        game.gameModel, context, bottomColor, widget.game);
    await userDoc.update({'thirdTopGame': currentUser.thirdTopGame});
  }

  Future<void> _deleteThirdTopGameInDatabase(
      BuildContext context, Color color, Game game) async {
    final currentUser = getIt<FirebaseUserModel>();
    final userId = _auth.currentUser!.uid;
    final userDoc = FirebaseFirestore.instance.collection('Users').doc(userId);

    currentUser.deleteThirdTopGame(context, bottomColor, widget.game);
    await userDoc.update({'thirdTopGame': currentUser.thirdTopGame});
  }

  Widget topGamesPlaceholder(Color color) {
    final mediaQueryHeight = MediaQuery.of(context).size.height;
    final coverScaleHeight = mediaQueryHeight / 3.1;
    final coverScaleWidth = coverScaleHeight * 0.69;
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: GestureDetector(
        onTap: () {
          switch (color) {
            case middleColor:
              _updateSecondTopGameInDatabase(context, color, widget.game);
              break;
            case topColor:
              _updateFirstTopGameInDatabase(context, color, widget.game);
              break;
            case bottomColor:
              _updateThirdTopGameInDatabase(context, color, widget.game);
              break;
            default:
              break;
          }
        },
        child: AspectRatio(
          aspectRatio: 9 / 13,
          child: GlassContainer(
            color: color.withOpacity(.3),
            blur: 12,
            shadowStrength: 2,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(14),
            shadowColor: color.lighten(20),
            child: Center(
              child: GlassContainer(
                blur: 12,
                shadowStrength: 2,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(14),
                shadowColor: color.lighten(20),
                child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      CupertinoIcons.add_circled,
                      color: color.onColor,
                    )),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
