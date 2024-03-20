import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamer_grove/model/igdb_models/game.dart';
import 'package:gamer_grove/model/singleton/sinlgleton.dart';
import 'package:gamer_grove/model/widgets/event_list.dart';
import 'package:gamer_grove/model/widgets/gameListPreview.dart';
import 'package:gamer_grove/model/widgets/recommendedCarousel.dart';
import 'package:gamer_grove/repository/igdb/IGDBApiService.dart';
import 'package:get_it/get_it.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:redacted/redacted.dart';
import 'package:vitality/vitality.dart';

import '../../model/firebase/firebaseUser.dart';
import '../../model/igdb_models/event.dart';
import '../../model/widgets/gamePreview.dart';
import '../../repository/firebase/firebase.dart';

class HomeScreen extends StatefulWidget {
  static Route route() {
    return MaterialPageRoute(
      builder: (context) => HomeScreen(),
    );
  }

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final apiService = IGDBApiService();
  final getIt = GetIt.instance;
  final Random rand = Random();
  late FirebaseUserModel randomUser;
  bool _dataLoaded = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    await _parseFollowers();
    setState(() {
      _dataLoaded = true;
    });
  }

  Future<List<dynamic>> getIGDBData() async {
    final apiService = IGDBApiService();
    try {
      final body = '''
        ${await getRecommendedBody()}
        ${getBodyStringMostFollowedGames()}
        ${getBodyCriticsRatingDesc()}
        ${getBodyTopRatedGames()}
        ${getBodyNewestGames()}
        ${getBodyLatestEvents()}
        ${getBodyHypedGames()}
    ''';
      final List<dynamic> response = await apiService.getIGDBData(
        IGDBAPIEndpointsEnum.multiquery,
        body,
      );
      return response;
    } catch (e, stackTrace) {
      print('Error: $e');
      print('Stack Trace: $stackTrace');
    }
    return [];
  }

  Future<void> _parseFollowers() async {
    final currentUser = getIt<FirebaseUserModel>();
    List<FirebaseUserModel> followers = [];
    for (var value in currentUser.following.values) {
      FirebaseUserModel firebaseUserModel =
          await FirebaseService().getSingleUserData(value);
      followers.add(firebaseUserModel);
    }
    if (followers.isNotEmpty) {
      followers.shuffle();
      setState(() {
        randomUser = followers.first;
      });
    } else {
      randomUser = FirebaseUserModel(
          uuid: '',
          name: '',
          username: '',
          email: '',
          games: {},
          following: {},
          followers: {},
          profileUrl: '');
    }
  }

  Future<String> getRecommendedBody() async {
    final recommendedGameKeys = getRecommendedGameKeys(randomUser.games);
    if (recommendedGameKeys.isEmpty) {
      return '';
    }
    final gameIds = recommendedGameKeys.map((key) => 'id = $key').toList();
    final gamesJoin = gameIds.join("|");
    String gamesString = 'w $gamesJoin;';
    String body1 =
        'query games "User Recommendation" { fields name, cover.*, first_release_date, follows, category, url, hypes, status, total_rating, total_rating_count, version_title; $gamesString l 50;};';
    return body1;
  }

  List<String> getRecommendedGameKeys(Map<String, dynamic> games) {
    final recommendedGames =
        games.entries.where((entry) => entry.value['recommended'] == true);
    return recommendedGames.map((entry) => entry.key).toList();
  }

  String getBodyStringMostFollowedGames() {
    const body3 =
        'query games "Most Followed Games" {fields name, cover.*, first_release_date, follows, category, url, hypes, status, total_rating, total_rating_count, version_title; s follows desc; w follows != null; l 20;};';
    return body3;
  }

  String getBodyCriticsRatingDesc() {
    const body4 =
        'query games "Critics Choices" {fields name, cover.*, first_release_date, follows, category, url, hypes, status, total_rating, total_rating_count, version_title; s aggregated_rating desc; w aggregated_rating != null & aggregated_rating_count >= 10; l 20;};';
    return body4;
  }

  String getBodyTopRatedGames() {
    const body1 =
        'query games "Top Rated Games" {fields name, cover.*, first_release_date, follows, category, url, hypes, status, total_rating, total_rating_count, version_title; s total_rating desc; w total_rating != null & total_rating_count >= 40; l 20;};';
    return body1;
  }

  String getBodyNewestGames() {
    final int unixTimestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final body2 =
        'query games "Newest Games" {fields name, cover.*, first_release_date, follows, category, url, hypes, status, total_rating, total_rating_count, version_title; s first_release_date desc; w total_rating_count > 1 & first_release_date != null & first_release_date <= $unixTimestamp; l 20;};';
    return body2;
  }

  String getBodyHypedGames() {
    final int unixTimestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final int futureUnixTimestamp =
        DateTime.now().add(const Duration(days: 365)).millisecondsSinceEpoch ~/
            1000;
    print(futureUnixTimestamp);
    final body2 =
        'query games "Hyped Games" {fields name, cover.*, first_release_date, follows, category, url, hypes, status, total_rating, total_rating_count, version_title; s hypes desc; w hypes != null & hypes > 1 & first_release_date >= $unixTimestamp & first_release_date <= $futureUnixTimestamp; l 20;};';
    return body2;
  }

  String getBodyLatestEvents() {
    final int unixTimestamp =
        DateTime.now().add(const Duration(days: 30)).millisecondsSinceEpoch ~/
            1000;
    final body3 =
        'query events "Latest Events" {fields checksum, created_at, description, end_time, event_logo.*, event_networks.*, games.*, games.cover.*, games.artworks.*, live_stream_url, name, slug, start_time, time_zone, updated_at, videos.*; s start_time desc; w start_time != null & start_time <= $unixTimestamp; l 20;};';
    return body3;
  }

  @override
  Widget build(BuildContext context) {
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
            child: _dataLoaded == true
                ? FutureBuilder<List<dynamic>>(
                    future: getIGDBData(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final response = snapshot.data!;
                        List<Game> recommendedGames = [];
                        List<Game> topRatedGames = [];
                        List<Game> criticsChoices = [];
                        List<Game> mostFollowedGames = [];
                        List<Game> newestGames = [];
                        List<Game> hypedGames = [];
                        List<Event> latestEvents = [];

                        final userRecommendationsResponse = response.firstWhere(
                            (item) => item['name'] == 'User Recommendation',
                            orElse: () => null);
                        if (userRecommendationsResponse != null) {
                          recommendedGames = apiService.parseResponseToGame(
                              userRecommendationsResponse['result']);
                        }

                        final mostFollowedGamesResponse = response.firstWhere(
                            (item) => item['name'] == 'Most Followed Games',
                            orElse: () => null);
                        if (mostFollowedGamesResponse != null) {
                          mostFollowedGames = apiService.parseResponseToGame(
                              mostFollowedGamesResponse['result']);
                        }

                        final criticsChoicesResponse = response.firstWhere(
                            (item) => item['name'] == 'Critics Choices',
                            orElse: () => null);
                        if (criticsChoicesResponse != null) {
                          criticsChoices = apiService.parseResponseToGame(
                              criticsChoicesResponse['result']);
                        }

                        final topRatedGamesResponse = response.firstWhere(
                            (item) => item['name'] == 'Top Rated Games',
                            orElse: () => null);
                        if (topRatedGamesResponse != null) {
                          topRatedGames = apiService.parseResponseToGame(
                              topRatedGamesResponse['result']);
                        }

                        final newestGamesResponse = response.firstWhere(
                            (item) => item['name'] == 'Newest Games',
                            orElse: () => null);
                        if (newestGamesResponse != null) {
                          newestGames = apiService.parseResponseToGame(
                              newestGamesResponse['result']);
                        }

                        final hypedGamesResponse = response.firstWhere(
                            (item) => item['name'] == 'Hyped Games',
                            orElse: () => null);
                        if (hypedGamesResponse != null) {
                          hypedGames = apiService.parseResponseToGame(
                              hypedGamesResponse['result']);
                        }

                        final latestEventsResponse = response.firstWhere(
                            (item) => item['name'] == 'Latest Events',
                            orElse: () => null);
                        if (latestEventsResponse != null) {
                          latestEvents = apiService.parseResponseToEvent(
                              latestEventsResponse['result']);
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(top: 40),
                            ),
                            if (latestEvents.isNotEmpty)
                              EventListView(
                                  headline: 'Latest Events',
                                  events: latestEvents),
                            if (recommendedGames.isNotEmpty)
                              RecommendedCarouselSlider(
                                games: recommendedGames,
                                otherUserModel: randomUser,
                              ),
                            if (topRatedGames.isNotEmpty)
                              GameListView(
                                headline: 'Top Rated Games',
                                games: topRatedGames,
                                isPagination: true,
                                body: getBodyTopRatedGames(),
                                showLimit: 10,
                                isAggregated: false,
                              ),
                            if (criticsChoices.isNotEmpty)
                              GameListView(
                                headline: 'Critics Choices',
                                games: criticsChoices,
                                isPagination: true,
                                body: getBodyCriticsRatingDesc(),
                                showLimit: 10,
                                isAggregated: true,
                              ),
                            if (mostFollowedGames.isNotEmpty)
                              GameListView(
                                headline: 'Most Followed Games',
                                games: mostFollowedGames,
                                isPagination: true,
                                body: getBodyStringMostFollowedGames(),
                                showLimit: 10,
                                isAggregated: false,
                              ),
                            if (newestGames.isNotEmpty)
                              GameListView(
                                headline: 'Newest Games',
                                games: newestGames,
                                isPagination: true,
                                body: getBodyNewestGames(),
                                showLimit: 10,
                                isAggregated: false,
                              ),
                            if (hypedGames.isNotEmpty)
                              GameListView(
                                headline: 'Hyped Games',
                                games: hypedGames,
                                isPagination: true,
                                body: getBodyHypedGames(),
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
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.only(
                              top: MediaQuery.of(context).size.height * .34,
                              left: MediaQuery.of(context).size.width * .2,
                              right: MediaQuery.of(context).size.width * .2),
                          child: const LoadingIndicator(
                              indicatorType: Indicator.pacman),
                        ),
                      );
                    })
                : Container(),
          ),
        ],
      ),
    );
  }
}
