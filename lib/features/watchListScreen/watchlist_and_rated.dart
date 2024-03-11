import 'package:animated_emoji/emoji.dart';
import 'package:animated_emoji/emojis.g.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:textura/textura.dart';

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
        'fields name, cover.*, first_release_date, follows, category, url, hypes, status, total_rating, total_rating_count, version_title; s total_rating desc; $gamesString l 50;';
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
        'fields name, cover.*, first_release_date, follows, category, url, hypes, status, total_rating, total_rating_count, version_title; s total_rating desc; $gamesString l 50;';
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
        'fields name, cover.*, first_release_date, follows, category, url, hypes, status, total_rating, total_rating_count, version_title; s total_rating desc; $gamesString l 50;';
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
    return Scaffold(
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            Container(
              height: 100,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xff563232),
                borderRadius: BorderRadius.only(bottomRight: Radius.circular(14), bottomLeft: Radius.circular(14))
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 14.0, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Library',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                        )),
                    AnimatedEmoji(
                      AnimatedEmojis.nerdFace,
                      animate: true,
                      repeat: false,
                      size: 64,
                    ),
                  ],
                ),
              ),
            ),
            GameListView(
              headline: 'Recommended Games',
              games: recommendedResponse,
              isPagination: false,
              body: '',
              showLimit: 10,
              isAggregated: false,
            ),
            GameListView(
              headline: 'Wishlist Games',
              games: wishlistResponse,
              isPagination: true,
              body: '',
              showLimit: 10,
              isAggregated: false,
            ),
            GameListView(
              headline: 'Rated Games',
              games: ratedResponse,
              isPagination: false,
              body: '',
              showLimit: 10,
              isAggregated: false,
            ),
          ],
        ),
      ),
    );
  }
}
