import 'dart:async';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:animated_emoji/emoji.dart';
import 'package:animated_emoji/emojis.g.dart';
import 'package:auth_service/auth.dart';
import 'package:clay_containers/clay_containers.dart';
import 'package:country_picker/country_picker.dart';
import 'package:countup/countup.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamer_grove/model/firebase/firebaseUser.dart';
import 'package:gamer_grove/model/singleton/sinlgleton.dart';
import 'package:gamer_grove/repository/firebase/firebase.dart';
import 'package:get_it/get_it.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';
import 'package:profile_view/profile_view.dart';
import 'package:vitality/vitality.dart';
import 'package:widget_circular_animator/widget_circular_animator.dart';

import '../../features/loginRegistration/login/bloc/login_bloc.dart';
import '../../features/loginRegistration/login_registration_page.dart';
import '../../model/views/theme_screen.dart';
import '../../model/widgets/ThemeButton.dart';
import '../../repository/igdb/IGDBApiService.dart';
import '../../utils/ThemManager.dart';
import '../igdb_models/game.dart';
import '../widgets/gameListPreview.dart';

class OtherUserProfileScreen extends StatefulWidget {
  final FirebaseUserModel userModel;
  final Color colorPalette;

  const OtherUserProfileScreen(
      {super.key, required this.userModel, required this.colorPalette});

  @override
  _OtherUserProfileScreenState createState() => _OtherUserProfileScreenState();
}

class _OtherUserProfileScreenState extends State<OtherUserProfileScreen> {
  List<Game> recommendedResponse = [];
  List<Game> wishlistResponse = [];
  List<Game> ratedResponse = [];

  final apiService = IGDBApiService();

  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async {
    await Future.wait(
        [getRecommendedIGDBData(), getWishlistIGDBData(), getRatedIGDBData()]);
  }

  String getRecommendedBody() {
    final recommendedGameKeys = getRecommendedGameKeys(widget.userModel.games);
    final gameIds = recommendedGameKeys.map((key) => 'id = $key').toList();
    final gamesJoin = gameIds.join("|");
    String gamesString = 'w $gamesJoin;';

    String body1 =
        'fields name, cover.*, first_release_date, follows, category, url, hypes, status, total_rating, total_rating_count, version_title; $gamesString l 50;';
    return body1;
  }

  List<String> getRecommendedGameKeys(Map<String, dynamic> games) {
    final recommendedGames =
        games.entries.where((entry) => entry.value['recommended'] == true);
    return recommendedGames.map((entry) => entry.key).toList();
  }

  Future<void> getRecommendedIGDBData() async {
    if (getRecommendedGameKeys(widget.userModel.games).isNotEmpty) {
      try {
        final response3 = await apiService.getIGDBData(
            IGDBAPIEndpointsEnum.games, getRecommendedBody());

        setState(() {
          recommendedResponse = apiService.parseResponseToGame(response3);
        });
      } catch (e, stackTrace) {
        print('Error: $e');
        print('Stack Trace: $stackTrace');
      }
    }
  }

  String getWishlistBody() {
    final recommendedGameKeys = getWishlistGameKeys(widget.userModel.games);
    final gameIds = recommendedGameKeys.map((key) => 'id = $key').toList();
    final gamesJoin = gameIds.join("|");
    String gamesString = 'w $gamesJoin;';

    String body1 =
        'fields name, cover.*, first_release_date, follows, category, url, hypes, status, total_rating, total_rating_count, version_title; $gamesString l 50;';
    return body1;
  }

  List<String> getWishlistGameKeys(Map<String, dynamic> games) {
    final recommendedGames =
        games.entries.where((entry) => entry.value['wishlist'] == true);
    return recommendedGames.map((entry) => entry.key).toList();
  }

  Future<void> getWishlistIGDBData() async {
    if (getWishlistGameKeys(widget.userModel.games).isNotEmpty) {
      try {
        final response3 = await apiService.getIGDBData(
            IGDBAPIEndpointsEnum.games, getWishlistBody());

        setState(() {
          wishlistResponse = apiService.parseResponseToGame(response3);
        });
      } catch (e, stackTrace) {
        print('Error: $e');
        print('Stack Trace: $stackTrace');
      }
    }
  }

  String getRatedBody() {
    final recommendedGameKeys = getRatedGameKeys(widget.userModel.games);
    final gameIds = recommendedGameKeys.map((key) => 'id = $key').toList();
    final gamesJoin = gameIds.join("|");
    String gamesString = 'w $gamesJoin;';

    String body1 =
        'fields name, cover.*, first_release_date, follows, category, url, hypes, status, total_rating, total_rating_count, version_title; $gamesString l 50;';
    return body1;
  }

  List<String> getRatedGameKeys(Map<String, dynamic> games) {
    final recommendedGames =
        games.entries.where((entry) => entry.value['rating'] > 0);
    return recommendedGames.map((entry) => entry.key).toList();
  }

  Future<void> getRatedIGDBData() async {
    if (getRatedGameKeys(widget.userModel.games).isNotEmpty) {
      try {
        final response3 = await apiService.getIGDBData(
            IGDBAPIEndpointsEnum.games, getRatedBody());

        setState(() {
          ratedResponse = apiService.parseResponseToGame(response3);
        });
      } catch (e, stackTrace) {
        print('Error: $e');
        print('Stack Trace: $stackTrace');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQueryWidth = MediaQuery.of(context).size.width;
    final mediaQueryHeight = MediaQuery.of(context).size.height;

    final bannerScaleHeight = mediaQueryHeight * 0.3;
    return Scaffold(
      body: Stack(
        children: [
          Vitality.randomly(
            background: Theme.of(context).colorScheme.background,
            maxOpacity: 0.8,
            minOpacity: 0.3,
            itemsCount: 80,
            enableXMovements: false,
            whenOutOfScreenMode: WhenOutOfScreenMode.Teleport,
            maxSpeed: 0.1,
            maxSize: 30,
            minSpeed: 0.1,
            randomItemsColors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary,
              Theme.of(context).colorScheme.tertiary,
              Theme.of(context).colorScheme.onPrimary
            ],
            randomItemsBehaviours: [
              ItemBehaviour(
                  shape: ShapeType.Icon, icon: CupertinoIcons.gamecontroller_fill),
              ItemBehaviour(shape: ShapeType.Icon, icon: CupertinoIcons.gamecontroller),
              ItemBehaviour(shape: ShapeType.Icon, icon: CupertinoIcons.person_2_fill),
              ItemBehaviour(
                  shape: ShapeType.Icon, icon: CupertinoIcons.person_2),
              ItemBehaviour(
                  shape: ShapeType.Icon,
                  icon: Icons.gamepad),
              ItemBehaviour(
                  shape: ShapeType.Icon, icon: Icons.gamepad_outlined),
              ItemBehaviour(shape: ShapeType.StrokeCircle),
            ],
          ),
          SingleChildScrollView(
            child: Stack(
              children: [
                Container(
                  height: mediaQueryHeight * .74,
                  width: mediaQueryWidth,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment(0.0, 1),
                      // Start at the middle left
                      end: Alignment(0.0, 0.1),
                      // End a little above two thirds of the height
                      colors: [
                        Theme.of(context).colorScheme.background,
                        widget.colorPalette,
                      ],
                      stops: [
                        0.67,
                        1.0
                      ], // Stop the gradient at approximately two thirds of the height
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 38.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      WidgetCircularAnimator(
                        outerColor: widget.colorPalette.onColor,
                        innerColor: widget.colorPalette.lighten(20),
                        outerAnimation: Curves.linear,
                        child: ProfileView(
                          circle: false,
                          borderRadius: 90,
                          image: NetworkImage(
                            widget.userModel.profileUrl,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        widget.userModel.username,
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: widget.colorPalette.onColor),
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  FittedBox(
                                    child: Text(
                                      'Followers', // Anzahl der Follower einfügen
                                      style: TextStyle(
                                          color: widget.colorPalette.onColor, fontWeight: FontWeight.bold,),
                                    ),
                                  ),
                                  Countup(
                                    begin: 0,
                                    end:  widget.userModel.followers.length.toDouble(),
                                    duration: Duration(seconds: 3),
                                    separator: '.',
                                    style:  TextStyle(
                                        color: widget.colorPalette.onColor),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                children: [
                                  FittedBox(
                                    child: Text(
                                      'Following',
                                      // Anzahl der Abonnements einfügen
                                      style: TextStyle(
                                          color: widget.colorPalette.onColor, fontWeight: FontWeight.bold,),
                                    ),
                                  ),
                                  Countup(
                                    begin: 0,
                                    end:  widget.userModel.following.length.toDouble(),
                                    duration: Duration(seconds: 3),
                                    separator: '.',
                                    style:  TextStyle(
                                        color: widget.colorPalette.onColor),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                children: [
                                  FittedBox(
                                    child: Text(
                                      'Rated',
                                      // Anzahl der bewerteten Spiele einfügen
                                      style: TextStyle(
                                          color: widget.colorPalette.onColor,fontWeight: FontWeight.bold,),
                                    ),
                                  ),
                                  Countup(
                                    begin: 0,
                                    end: getRatedGameKeys(widget.userModel.games)
                                        .length.toDouble(),
                                    duration: Duration(seconds: 3),
                                    separator: '.',
                                    style:  TextStyle(
                                        color: widget.colorPalette.onColor),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                children: [
                                  FittedBox(
                                    child: Text(
                                      'Recommended',
                                      // Anzahl der bewerteten Spiele einfügen
                                      style: TextStyle(
                                          color: widget.colorPalette.onColor,fontWeight: FontWeight.bold,),
                                    ),
                                  ),
                                  Countup(
                                    begin: 0,
                                    end: getRecommendedGameKeys(widget.userModel.games)
                                        .length.toDouble(),
                                    duration: Duration(seconds: 3),
                                    separator: '.',
                                    style:  TextStyle(
                                        color: widget.colorPalette.onColor),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          SizedBox(height: 28),
                          if (getRecommendedGameKeys(widget.userModel.games)
                                  .isEmpty &&
                              getWishlistGameKeys(widget.userModel.games).isEmpty &&
                              getRatedGameKeys(widget.userModel.games).isEmpty)
                            const Padding(
                              padding:
                                  EdgeInsets.only(top: 140, left: 20, right: 20),
                              child: Center(
                                child: GlassContainer(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      AnimatedEmoji(
                                        AnimatedEmojis.sleep,
                                        size: 64,
                                      ),
                                      FittedBox(
                                          child: Text('Nothing to see here yet...',
                                              style: TextStyle(
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.bold)))
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          GameListView(
                            headline: 'Recommended Games',
                            games: recommendedResponse,
                            isPagination: true,
                            body: getRecommendedBody(),
                            showLimit: 10,
                            isAggregated: false,
                            otherUserModel: widget.userModel,
                          ),
                          GameListView(
                            headline: 'Wishlist Games',
                            games: wishlistResponse,
                            isPagination: true,
                            body: getWishlistBody(),
                            showLimit: 10,
                            isAggregated: false,
                            otherUserModel: widget.userModel,
                          ),
                          GameListView(
                            headline: 'Rated Games',
                            games: ratedResponse,
                            isPagination: true,
                            body: getRatedBody(),
                            showLimit: 10,
                            isAggregated: false,
                            otherUserModel: widget.userModel,
                          ),
                          SizedBox(height: 14),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
