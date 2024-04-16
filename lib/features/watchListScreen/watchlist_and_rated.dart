import 'package:animated_emoji/emoji.dart';
import 'package:animated_emoji/emojis.g.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gamer_grove/model/widgets/shimmerGameItem.dart';
import 'package:gamer_grove/model/widgets/topThreeUserGamesWidgetView.dart';
import 'package:get_it/get_it.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:textura/textura.dart';
import 'package:vitality/vitality.dart';

import '../../model/firebase/firebaseUser.dart';
import '../../model/igdb_models/game.dart';
import '../../model/singleton/sinlgleton.dart';
import '../../model/widgets/gameListPreview.dart';
import '../../model/widgets/topThreeUserGamesWidget.dart';
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
  final apiService = IGDBApiService();

  @override
  void initState() {
    super.initState();
  }

  Future<List<Game>> getIGDBData() async {
    final currentUser = getIt<FirebaseUserModel>();
    if (getGameKeys(currentUser.games).isNotEmpty) {
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

    final recommendedGameKeys = getGameKeys(currentUser.games);
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

  String getRecommendedBody() {
    final currentUser = getIt<FirebaseUserModel>();
    final recommendedGameKeys = getRecommendedGameKeys(currentUser.games);
    final gameIds = recommendedGameKeys.map((key) => 'id = $key').toList();
    final gamesJoin = gameIds.join("|");
    String gamesString = 'w $gamesJoin;';

    String body1 =
        'fields name, cover.*, first_release_date, follows, category, url, hypes, status, total_rating, total_rating_count, version_title; $gamesString l 20;';
    return body1;
  }

  List<String> getRecommendedGameKeys(Map<String, dynamic> games) {
    final recommendedGames =
    games.entries.where((entry) => entry.value['recommended'] == true);
    return recommendedGames.map((entry) => entry.key).toList();
  }

  String getWishlistBody() {
    final currentUser = getIt<FirebaseUserModel>();
    final recommendedGameKeys = getWishlistGameKeys(currentUser.games);
    final gameIds = recommendedGameKeys.map((key) => 'id = $key').toList();
    final gamesJoin = gameIds.join("|");
    String gamesString = 'w $gamesJoin;';

    String body1 =
        'fields name, cover.*, first_release_date, follows, category, url, hypes, status, total_rating, total_rating_count, version_title; $gamesString l 20;';
    return body1;
  }

  List<String> getWishlistGameKeys(Map<String, dynamic> games) {
    final recommendedGames =
    games.entries.where((entry) => entry.value['wishlist'] == true);
    return recommendedGames.map((entry) => entry.key).toList();
  }

  String getRatedBody() {
    final currentUser = getIt<FirebaseUserModel>();
    final recommendedGameKeys = getRatedGameKeys(currentUser.games);
    final gameIds = recommendedGameKeys.map((key) => 'id = $key').toList();
    final gamesJoin = gameIds.join("|");
    String gamesString = 'w $gamesJoin;';

    String body1 =
        'fields name, cover.*, first_release_date, follows, category, url, hypes, status, total_rating, total_rating_count, version_title; $gamesString l 20;';
    return body1;
  }

  List<String> getRatedGameKeys(Map<String, dynamic> games) {
    final recommendedGames =
    games.entries.where((entry) => entry.value['rating'] > 0);
    return recommendedGames.map((entry) => entry.key).toList();
  }



  @override
  Widget build(BuildContext context) {
    final currentUser = getIt<FirebaseUserModel>();
    return Scaffold(
      body: Stack(children: [
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
                shape: ShapeType.Icon, icon: CupertinoIcons.bookmark),
            ItemBehaviour(
                shape: ShapeType.Icon, icon: CupertinoIcons.bookmark_fill),
            ItemBehaviour(
                shape: ShapeType.Icon, icon: CupertinoIcons.hand_thumbsup),
            ItemBehaviour(
                shape: ShapeType.Icon,
                icon: CupertinoIcons.hand_thumbsup_fill),
            ItemBehaviour(shape: ShapeType.Icon, icon: Icons.score_outlined),
            ItemBehaviour(shape: ShapeType.Icon, icon: Icons.score_rounded),
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
                      child: Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: GlassContainer(
                          blur: 12,
                          shadowStrength: 4,
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(14),
                          shadowColor: Theme.of(context).primaryColor,
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: FittedBox(
                              child: Text(
                                '${currentUser.name}`s Library',
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onBackground,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 14,
                    ),
                    if (getRecommendedGameKeys(currentUser.games)
                        .isEmpty &&
                        getWishlistGameKeys(currentUser.games)
                            .isEmpty &&
                        getRatedGameKeys(currentUser.games).isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(
                            top: 140, left: 20, right: 20),
                        child: Center(
                          child: GlassContainer(
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment:
                                CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  AnimatedEmoji(
                                    AnimatedEmojis.cursing,
                                    size: 64,
                                  ),
                                  FittedBox(
                                      child: Text(
                                          'Nothing to see here yet...',
                                          style: TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold)))
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    FutureBuilder<List<Game>>(
                        future: getIGDBData(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            List<Game> recommendedData = [];
                            List<Game> wishlistData = [];
                            List<Game> ratedData = [];
                            for (var game in snapshot.data!){
                              if (game.gameModel.recommended == true) {
                                recommendedData.add(game);
                              }
                              if (game.gameModel.wishlist == true) {
                                wishlistData.add(game);
                              }
                              if (game.gameModel.rating > 0) {
                                ratedData.add(game);
                              }
                            }
                            return Column(
                              children: [
                                TopThreeUserGamesWidgetView(user: currentUser, isLoggedInUserData: true,),
                                const SizedBox(
                                  height: 14,
                                ),
                                if (ratedData.isNotEmpty)
                                  GameListView(
                                    headline: 'Rated Games',
                                    games: ratedData,
                                    isPagination: true,
                                    body: getRatedBody(),
                                    showLimit: 10,
                                    isAggregated: false,
                                  ),
                                if (recommendedData.isNotEmpty)
                                  GameListView(
                                    headline: 'Recommended Games',
                                    games: recommendedData,
                                    isPagination: true,
                                    body: getRecommendedBody(),
                                    showLimit: 10,
                                    isAggregated: false,
                                  ),
                                if (wishlistData.isNotEmpty)
                                  GameListView(
                                    headline: 'Wishlist Games',
                                    games: wishlistData,
                                    isPagination: true,
                                    body: getWishlistBody(),
                                    showLimit: 10,
                                    isAggregated: false,
                                  ),
                              ],
                            );
                          } else if (snapshot.hasError) {
                            return Center(
                              child: Text('Error: ${snapshot.error}'),
                            );
                          }
                          // Display a loading indicator while fetching data
                          return ShimmerItem.buildShimmerWishlistScreenItem(context);
                        }),

                  ],
                );
              }),
            )
          ]),
        ),
      ]),
    );
  }
}
