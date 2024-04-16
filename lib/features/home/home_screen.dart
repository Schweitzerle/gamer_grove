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
import 'package:gamer_grove/model/widgets/shimmerGameItem.dart';
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
        ${await getBodyStringRecommendationUsedGames()}
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
          id: '',
          name: '',
          username: '',
          email: '',
          games: {},
          following: {},
          followers: {},
          profileUrl: '',
          firstTopGame: {},
          secondTopGame: {},
          thirdTopGame: {});
    }
  }

  Future<List<Game>> getIGDBRecommendedUserData() async {
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
        'fields name, cover.*, artworks.*, first_release_date, follows, category, url, hypes, status, total_rating, total_rating_count, version_title, themes.*, genres.*, game_modes.*, platforms.*, player_perspectives.*; $gamesString l 500;';
    return body1;
  }

  List<String> getGameKeys(Map<String, dynamic> games) {
    return games.keys.toList();
  }

  Future<String> getBodyStringRecommendationUsedGames() async {
    final innerBody = await getInnerBodyStringRecommendationsUserGames();
    final body3 =
        'query games "Recommended Games for User" {$innerBody};';
    return body3;
  }

  Future<String> getInnerBodyStringRecommendationsUserGames() async {
    final userGames = await getIGDBRecommendedUserData();
    userGames.removeWhere((element) => element.gameModel.rating < 7.5);
    final themes = extractMostCommonThemeIds(userGames);
    final genres = extractMostCommonGenreIds(userGames);
    final platforms = extractMostCommonPlatformIds(userGames);
    final playerPerspectives = extractMostCommonPlayerPerspectiveIds(userGames);
    final gameModes = extractMostCommonGameModesIds(userGames);
    String filterString = '';

    if (themes.isNotEmpty || genres.isNotEmpty || gameModes.isNotEmpty || playerPerspectives.isNotEmpty || platforms.isNotEmpty) {
      filterString = 'w $themes $genres $playerPerspectives $gameModes  $platforms;';
    }

    final body3 =
        'fields name, cover.*, artworks.*, first_release_date, follows, category, url, hypes, status, total_rating, total_rating_count, version_title; s total_rating_count desc; $filterString l 20;';
    return body3;
  }

  String extractMostCommonThemeIds(List<Game> userGames) {
    final Map<int, int> themeIdCount = {};

    for (var game in userGames) {
      if (game.themes != null) {
        for (var theme in game.themes!) {
          themeIdCount[theme.id] = (themeIdCount[theme.id] ?? 0) + 1;
        }
      }
    }
    final sortedIds = themeIdCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final topSortedIds = sortedIds.take(1).map((entry) => entry.key).toList();

    if (topSortedIds.isEmpty) {
      return "";
    }

    final result = 'themes = (${topSortedIds.join(', ')}) &';
    return result;
  }

  String extractMostCommonGenreIds(List<Game> userGames) {
    final Map<int, int> genreIDCount = {};

    for (var game in userGames) {
      if (game.genres != null) {
        for (var genre in game.genres!) {
          genreIDCount[genre.id] = (genreIDCount[genre.id] ?? 0) + 1;
        }
      }
    }
    final sortedIds = genreIDCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final topSortedIds = sortedIds.take(1).map((entry) => entry.key).toList();

    if (topSortedIds.isEmpty) {
      return "";
    }

    final result = 'genres = (${topSortedIds.join(', ')}) &';
    return result;
  }

  String extractMostCommonGameModesIds(List<Game> userGames) {
    final Map<int, int> gameModesIDCount = {};

    for (var game in userGames) {
      if (game.gameModes != null) {
        for (var gameMode in game.gameModes!) {
          gameModesIDCount[gameMode.id] = (gameModesIDCount[gameMode.id] ?? 0) + 1;
        }
      }
    }
    final sortedIds = gameModesIDCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final topSortedIds = sortedIds.take(1).map((entry) => entry.key).toList();

    if (topSortedIds.isEmpty) {
      return "";
    }

    final result = 'game_modes = (${topSortedIds.join(', ')}) &';
    return result;
  }

  String extractMostCommonPlayerPerspectiveIds(List<Game> userGames) {
    final Map<int, int> playerPerspectivesIdCount = {};

    for (var game in userGames) {
      if (game.playerPerspectives != null) {
        for (var playerPerspective in game.playerPerspectives!) {
          playerPerspectivesIdCount[playerPerspective.id] = (playerPerspectivesIdCount[playerPerspective.id] ?? 0) + 1;
        }
      }
    }
    final sortedIds = playerPerspectivesIdCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final topSortedIds = sortedIds.take(1).map((entry) => entry.key).toList();

    if (topSortedIds.isEmpty) {
      return "";
    }

    final result = 'player_perspectives = (${topSortedIds.join(', ')}) &';
    return result;
  }

  String extractMostCommonPlatformIds(List<Game> userGames) {
    final Map<int, int> platformsIDCount = {};

    for (var game in userGames) {
      if (game.platforms != null) {
        for (var platform in game.platforms!) {
          platformsIDCount[platform.id] = (platformsIDCount[platform.id] ?? 0) + 1;
        }
      }
    }
    final sortedIds = platformsIDCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final topSortedIds = sortedIds.take(1).map((entry) => entry.key).toList();

    if (topSortedIds.isEmpty) {
      return "";
    }

    final result = 'platforms = (${topSortedIds.join(', ')})';
    return result;
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
        'query games "User Recommendation" { fields name, cover.*, artworks.*, first_release_date, follows, category, url, hypes, status, total_rating, total_rating_count, version_title; $gamesString l 50;};';
    return body1;
  }

  List<String> getRecommendedGameKeys(Map<String, dynamic> games) {
    final recommendedGames =
    games.entries.where((entry) => entry.value['recommended'] == true);
    return recommendedGames.map((entry) => entry.key).toList();
  }

  String getBodyStringMostFollowedGames() {
    final body3 =
        'query games "Most Followed Games" {${getInnerBodyStringMostFollowedGames()}};';
    return body3;
  }

  String getInnerBodyStringMostFollowedGames() {
    const body3 =
        'fields name, cover.*, artworks.*, first_release_date, follows, category, url, hypes, status, total_rating, total_rating_count, version_title; s follows desc; w follows != null; l 20;';
    return body3;
  }

  String getBodyCriticsRatingDesc() {
    final body4 =
        'query games "Critics Choices" {${getInnerBodyCriticsRatingDesc()}};';
    return body4;
  }

  String getInnerBodyCriticsRatingDesc() {
    const body4 =
        'fields name, cover.*, artworks.*, first_release_date, follows, category, url, hypes, status, total_rating, total_rating_count, version_title; s aggregated_rating desc; w aggregated_rating != null & aggregated_rating_count >= 10; l 20;';
    return body4;
  }

  String getBodyTopRatedGames() {
    final body1 =
        'query games "Top Rated Games" {${getInnerBodyTopRatedGames()}};';
    return body1;
  }

  String getInnerBodyTopRatedGames() {
    const body1 =
        'fields name, cover.*, artworks.*, first_release_date, follows, category, url, hypes, status, total_rating, total_rating_count, version_title; s total_rating desc; w total_rating != null & total_rating_count >= 40; l 20;';
    return body1;
  }

  String getBodyNewestGames() {
    final body2 =
        'query games "Newest Games" {${getInnerBodyNewestGames()}};';
    return body2;
  }

  String getInnerBodyNewestGames() {
    final int unixTimestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final body2 =
        'fields name, cover.*, artworks.*, first_release_date, follows, category, url, hypes, status, total_rating, total_rating_count, version_title; s first_release_date desc; w total_rating_count > 1 & first_release_date != null & first_release_date <= $unixTimestamp; l 20;';
    return body2;
  }

  String getBodyHypedGames() {
    final body2 =
        'query games "Hyped Games" {${getInnerBodyHypedGames()}};';
    return body2;
  }

  String getInnerBodyHypedGames() {
    final int unixTimestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final int futureUnixTimestamp =
        DateTime.now().add(const Duration(days: 365)).millisecondsSinceEpoch ~/
            1000;
    final body2 =
        'fields name, cover.*, artworks.*, first_release_date, follows, category, url, hypes, status, total_rating, total_rating_count, version_title; s hypes desc; w hypes != null & hypes > 1 & first_release_date >= $unixTimestamp & first_release_date <= $futureUnixTimestamp; l 20;';
    return body2;
  }

  String getBodyLatestEvents() {
    final body3 =
        'query events "Latest Events" {${getInnerBodyLatestEvents()}};';
    return body3;
  }

  String getInnerBodyLatestEvents() {
    final int unixTimestamp =
        DateTime.now().add(const Duration(days: 30)).millisecondsSinceEpoch ~/
            1000;
    final body3 =
        'fields checksum, created_at, description, end_time, event_logo.*, event_networks.*, games.*, games.cover.*, games.artworks.*, live_stream_url, name, slug, start_time, time_zone, updated_at, videos.*; s start_time desc; w start_time != null & start_time <= $unixTimestamp; l 20;';
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
                    List<Game> recommendationsUserGames = [];

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

                    final recommendationsUserResponse = response.firstWhere(
                            (item) => item['name'] == 'Recommended Games for User',
                        orElse: () => null);
                    if (recommendationsUserResponse != null) {
                      recommendationsUserGames = apiService.parseResponseToGame(
                          recommendationsUserResponse['result']);
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
                            body: getInnerBodyTopRatedGames(),
                            showLimit: 10,
                            isAggregated: false,
                          ),
                        if (criticsChoices.isNotEmpty)
                          GameListView(
                            headline: 'Critics Choices',
                            games: criticsChoices,
                            isPagination: true,
                            body: getInnerBodyCriticsRatingDesc(),
                            showLimit: 10,
                            isAggregated: true,
                          ),
                        if (recommendationsUserGames.isNotEmpty)
                          FutureBuilder<String>(
                            future: getInnerBodyStringRecommendationsUserGames(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return Container();
                              } else if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              } else {
                                final body = snapshot.data!;
                                return GameListView(
                                  headline: 'Recommended for you',
                                  games: recommendationsUserGames,
                                  isPagination: true,
                                  body: body,
                                  showLimit: 10,
                                  isAggregated: false,
                                );
                              }
                            },
                          ),
                        if (mostFollowedGames.isNotEmpty)
                          GameListView(
                            headline: 'Most Followed Games',
                            games: mostFollowedGames,
                            isPagination: true,
                            body: getInnerBodyStringMostFollowedGames(),
                            showLimit: 10,
                            isAggregated: false,
                          ),
                        if (newestGames.isNotEmpty)
                          GameListView(
                            headline: 'Newest Games',
                            games: newestGames,
                            isPagination: true,
                            body: getInnerBodyNewestGames(),
                            showLimit: 10,
                            isAggregated: false,
                          ),
                        if (hypedGames.isNotEmpty)
                          GameListView(
                            headline: 'Hyped Games',
                            games: hypedGames,
                            isPagination: true,
                            body: getInnerBodyHypedGames(),
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
                  return ShimmerItem.buildShimmerHomeScreenItem(context);
                })
                : Container(),
          ),
        ],
      ),
    );
  }
}