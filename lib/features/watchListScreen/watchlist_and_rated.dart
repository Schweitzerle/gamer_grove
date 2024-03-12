import 'package:animated_emoji/emoji.dart';
import 'package:animated_emoji/emojis.g.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';
import 'package:provider/provider.dart';
import 'package:textura/textura.dart';
import 'package:vitality/vitality.dart';

import '../../model/firebase/firebaseUser.dart';
import '../../model/igdb_models/game.dart';
import '../../model/singleton/sinlgleton.dart';
import '../../model/widgets/gameListPreview.dart';
import '../../repository/igdb/IGDBApiService.dart';

class WatchlistScreen extends StatefulWidget {
  static Route route() {
    return MaterialPageRoute(
      builder: (context) => WatchlistScreen(),
    );
  }

  @override
  _WatchlistScreenState createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen>
    with SingleTickerProviderStateMixin {
  final getIt = GetIt.instance;
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
    final currentUser = getIt<FirebaseUserModel>();

    final recommendedGameKeys = getRecommendedGameKeys(currentUser.games);
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
    final currentUser = getIt<FirebaseUserModel>();
    if (getRecommendedGameKeys(currentUser.games).isNotEmpty) {
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
    final currentUser = getIt<FirebaseUserModel>();

    final recommendedGameKeys = getWishlistGameKeys(currentUser.games);
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
    final currentUser = getIt<FirebaseUserModel>();
    if (getWishlistGameKeys(currentUser.games).isNotEmpty) {
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
    final currentUser = getIt<FirebaseUserModel>();

    final recommendedGameKeys = getRatedGameKeys(currentUser.games);
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
    final currentUser = getIt<FirebaseUserModel>();
    if (getRatedGameKeys(currentUser.games).isNotEmpty) {
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
    final currentUser = getIt<FirebaseUserModel>();
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(14),
                bottomLeft: Radius.circular(14))),
        child: Stack(children: [
          Vitality.randomly(
            background: Theme.of(context).colorScheme.background,
            maxOpacity: 0.8,
            minOpacity: 0.3,
            itemsCount: 80,
            enableXMovements: false,
            whenOutOfScreenMode: WhenOutOfScreenMode.Teleport,
            maxSpeed: 0,
            maxSize: 30,
            minSpeed: 0,
            randomItemsColors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary,
              Theme.of(context).colorScheme.tertiary,
              Theme.of(context).colorScheme.onPrimary
            ],
            randomItemsBehaviours: [
              ItemBehaviour(
                  shape: ShapeType.Icon, icon: Icons.videogame_asset_outlined),
              ItemBehaviour(shape: ShapeType.Icon, icon: Icons.videogame_asset),
              ItemBehaviour(shape: ShapeType.Icon, icon: Icons.gamepad),
              ItemBehaviour(
                  shape: ShapeType.Icon, icon: Icons.gamepad_outlined),
              ItemBehaviour(
                  shape: ShapeType.Icon,
                  icon: CupertinoIcons.gamecontroller_fill),
              ItemBehaviour(
                  shape: ShapeType.Icon, icon: CupertinoIcons.gamecontroller),
              ItemBehaviour(shape: ShapeType.StrokeCircle),
            ],
          ),
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Stack(children: [
              ChangeNotifierProvider.value(
                value: currentUser,
                child: Consumer<FirebaseUserModel>(
                    builder: (context, firebaseUserModel, child) {
                  return Column(
                    children: [
                      const SizedBox(
                        height: 42,
                      ),
                      Center(
                        child: GlassContainer(
                          blur: 12,
                          shadowStrength: 4,
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(14),
                          shadowColor: Theme.of(context).primaryColor,
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              '${currentUser.name}`s Library',
                              style: TextStyle(
                                color:
                                    Theme.of(context).colorScheme.onBackground,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 14,
                      ),
                      Consumer<FirebaseUserModel>(
                          builder: (context, firebaseUserModel, child) {
                        if (getRecommendedGameKeys(firebaseUserModel.games)
                            .isNotEmpty) {
                          if (recommendedResponse.length != getRecommendedGameKeys(firebaseUserModel.games).length) {
                            Future.wait([getRecommendedIGDBData()]);
                            }
                          return GameListView(
                            headline: 'Recommended Games',
                            games: recommendedResponse,
                            isPagination: false,
                            body: '',
                            showLimit: 10,
                            isAggregated: false,
                          );
                        } else {
                          return Container();
                        }
                      }),
                      Consumer<FirebaseUserModel>(
                          builder: (context, firebaseUserModel, child) {
                        if (getWishlistGameKeys(firebaseUserModel.games)
                            .isNotEmpty) {
                          if (wishlistResponse.length != getWishlistGameKeys(firebaseUserModel.games).length) {
                            Future.wait([getWishlistIGDBData()]);
                          }
                          return GameListView(
                            headline: 'Wishlist Games',
                            games: wishlistResponse,
                            isPagination: true,
                            body: '',
                            showLimit: 10,
                            isAggregated: false,
                          );
                        } else {
                          return Container();
                        }
                      }),
                      Consumer<FirebaseUserModel>(
                          builder: (context, firebaseUserModel, child) {
                        if (getRatedGameKeys(firebaseUserModel.games)
                            .isNotEmpty) {
                          if(ratedResponse.length != getRatedGameKeys(firebaseUserModel.games).length) {
                            Future.wait([getRatedIGDBData()]);
                          }
                          return GameListView(
                            headline: 'Rated Games',
                            games: ratedResponse,
                            isPagination: false,
                            body: '',
                            showLimit: 10,
                            isAggregated: false,
                          );
                        } else {
                          return Container();
                        }
                      }),
                    ],
                  );
                }),
              )
            ]),
          ),
        ]),
      ),
    );
  }
}
