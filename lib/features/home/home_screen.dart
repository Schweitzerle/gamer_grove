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
  List<Game> gamesResponse1 = [];
  List<Game> gamesResponse2 = [];
  List<Game> gamesResponse3 = [];
  List<Game> gamesResponse4 = [];
  List<Event> latestEventResponse = [];
  List<Event> upcomingEventResponse = [];
  final apiService = IGDBApiService();
  final getIt = GetIt.instance;
  final Random rand = Random();
  List<Game> recommendedResponse = [];
  late FirebaseUserModel userFollowing = FirebaseUserModel(uuid: '', name: '', username: '', email: '', games: {}, following: {}, followers: {}, profileUrl: '');

  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async {
    await Future.wait([
      getIGDBDataLatestEvents(),
      getIGDBDataUpcomingEvents(),
      getIGDBDataMostFollowed(),
      getIGDBDataCriticsRatingDesc(),
      getIGDBDataTopRated(),
      getIGDBDataNewestGames(),
      getRecommendedIGDBData()
    ]);
  }

  Future<void> _parseFollowers() async {
    final currentUser = getIt<FirebaseUserModel>();
    List<FirebaseUserModel> followers = [];
    for (var value in currentUser.following.values) {
      FirebaseUserModel firebaseUserModel =
          await FirebaseService().getSingleUserData(value);
      followers.add(firebaseUserModel);
    }
    setState(() {
      if (followers.isNotEmpty) {
        followers.shuffle();
        userFollowing = followers.first;
      }
    });
  }

  String getRecommendedBody() {
    final recommendedGameKeys = getRecommendedGameKeys(userFollowing.games);
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
    await _parseFollowers();
    final currentUser = userFollowing;
    if (getRecommendedGameKeys(currentUser.games).isNotEmpty) {
      try {
        final response3 = await apiService.getIGDBData(
            IGDBAPIEndpointsEnum.games, getRecommendedBody());

        setState(() {
          recommendedResponse = apiService.parseResponseToGame(response3);
          print('Recc: ${recommendedResponse.length}');
        });
      } catch (e, stackTrace) {
        print('Error: $e');
        print('Stack Trace: $stackTrace');
      }
    }
  }

  String getBodyStringMostFollowedGames() {
    const body3 =
        'fields name, cover.*, first_release_date, follows, category, url, hypes, status, total_rating, total_rating_count, version_title; s follows desc; w follows != null; l 20;';
    return body3;
  }

  String getBodyCritcsRatingDesc() {
    const body4 =
        'fields name, cover.*, first_release_date, follows, category, url, hypes, status, total_rating, total_rating_count, version_title; s aggregated_rating desc; w aggregated_rating != null & aggregated_rating_count >= 10; l 20;';
    return body4;
  }

  String getBodyTopRatedGames() {
    const body1 =
        'fields name, cover.*, first_release_date, follows, category, url, hypes, status, total_rating, total_rating_count, version_title; s total_rating desc; w total_rating != null & total_rating_count >= 10; l 20;';
    return body1;
  }

  String getBodyNewestGames() {
    final int unixTimestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final body2 =
        'fields name, cover.*, first_release_date, follows, category, url, hypes, status, total_rating, total_rating_count, version_title; s first_release_date desc; w first_release_date != null & first_release_date <= $unixTimestamp; l 20;';
    return body2;
  }

  String getBodyLatestEvents() {
    final int unixTimestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final body3 =
        'fields checksum, created_at, description, end_time, event_logo.*, event_networks.*, games.*, games.cover.*, games.artworks.*, live_stream_url, name, slug, start_time, time_zone, updated_at, videos.*; s start_time desc; w start_time != null & start_time <= $unixTimestamp; l 20;';
    return body3;
  }

  String getBodyUpcomingEvents() {
    final int unixTimestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final body3 =
        'fields checksum, created_at, description, end_time, event_logo.*, event_networks.*, games.*, games.cover.*, games.artworks.*, live_stream_url, name, slug, start_time, time_zone, updated_at, videos.*; s start_time asc; w start_time != null & start_time >= $unixTimestamp; l 20;';
    return body3;
  }

  Future<void> getIGDBDataMostFollowed() async {
    try {
      final response3 = await apiService.getIGDBData(
          IGDBAPIEndpointsEnum.games, getBodyStringMostFollowedGames());

      setState(() {
        gamesResponse3 = apiService.parseResponseToGame(response3);
      });
    } catch (e, stackTrace) {
      print('Error: $e');
      print('Stack Trace: $stackTrace');
    }
  }

  Future<void> getIGDBDataCriticsRatingDesc() async {
    try {
      final response4 = await apiService.getIGDBData(
          IGDBAPIEndpointsEnum.games, getBodyCritcsRatingDesc());

      setState(() {
        gamesResponse4 = apiService.parseResponseToGame(response4);
      });
    } catch (e, stackTrace) {
      print('Error: $e');
      print('Stack Trace: $stackTrace');
    }
  }

  Future<void> getIGDBDataTopRated() async {
    try {
      final response1 = await apiService.getIGDBData(
          IGDBAPIEndpointsEnum.games, getBodyTopRatedGames());

      setState(() {
        gamesResponse1 = apiService.parseResponseToGame(response1);
      });
    } catch (e, stackTrace) {
      print('Error: $e');
      print('Stack Trace: $stackTrace');
    }
  }

  Future<void> getIGDBDataNewestGames() async {
    try {
      final response2 = await apiService.getIGDBData(
          IGDBAPIEndpointsEnum.games, getBodyNewestGames());

      setState(() {
        gamesResponse2 = apiService.parseResponseToGame(response2);
      });
    } catch (e, stackTrace) {
      print('Error: $e');
      print('Stack Trace: $stackTrace');
    }
  }

  Future<void> getIGDBDataLatestEvents() async {
    try {
      final response4 = await apiService.getIGDBData(
          IGDBAPIEndpointsEnum.events, getBodyLatestEvents());

      setState(() {
        latestEventResponse = apiService.parseResponseToEvent(response4);
      });
    } catch (e, stackTrace) {
      print('Error: $e');
      print('Stack Trace: $stackTrace');
    }
  }

  Future<void> getIGDBDataUpcomingEvents() async {
    try {
      final response4 = await apiService.getIGDBData(
          IGDBAPIEndpointsEnum.events, getBodyUpcomingEvents());

      setState(() {
        upcomingEventResponse = apiService.parseResponseToEvent(response4);
      });
    } catch (e, stackTrace) {
      print('Error: $e');
      print('Stack Trace: $stackTrace');
    }
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 40),
                ),

                EventListView(
                    headline: 'Latest Events', events: latestEventResponse),
                EventListView(
                    headline: 'Upcoming Events', events: upcomingEventResponse),
                if (userFollowing.games.isNotEmpty)
                  if (getRecommendedGameKeys(userFollowing.games).isNotEmpty)
                    RecommendedCarouselSlider(
                      games: recommendedResponse,
                      otherUserModel: userFollowing,
                    ),GameListView(
                  headline: 'Most Followed Games',
                  games: gamesResponse3,
                  isPagination: true,
                  body: getBodyStringMostFollowedGames(),
                  showLimit: 10,
                  isAggregated: false,
                ),
                GameListView(
                  headline: 'Critics Choices',
                  games: gamesResponse4,
                  isPagination: true,
                  body: getBodyCritcsRatingDesc(),
                  showLimit: 10,
                  isAggregated: true,
                ),
                GameListView(
                  headline: 'Top Rated Games',
                  games: gamesResponse1,
                  isPagination: true,
                  body: getBodyTopRatedGames(),
                  showLimit: 10,
                  isAggregated: false,
                ),
                GameListView(
                  headline: 'Newest Games',
                  games: gamesResponse2,
                  isPagination: true,
                  body: getBodyNewestGames(),
                  showLimit: 10,
                  isAggregated: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
