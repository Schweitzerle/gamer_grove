import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamer_grove/model/igdb_models/game.dart';
import 'package:gamer_grove/model/singleton/sinlgleton.dart';
import 'package:gamer_grove/model/widgets/event_list.dart';
import 'package:gamer_grove/model/widgets/gameListPreview.dart';
import 'package:gamer_grove/repository/igdb/IGDBApiService.dart';
import 'package:redacted/redacted.dart';

import '../../model/igdb_models/event.dart';
import '../../model/widgets/gamePreview.dart';

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

  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async {
    await Future.wait([getIGDBDataLatestEvents(), getIGDBDataUpcomingEvents(), getIGDBDataMostFollowed(), getIGDBDataCriticsRatingDesc(), getIGDBDataTopRated(), getIGDBDataNewestGames()]);
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
      final response4 =
          await apiService.getIGDBData(IGDBAPIEndpointsEnum.games, getBodyCritcsRatingDesc());

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
      final response1 =
          await apiService.getIGDBData(IGDBAPIEndpointsEnum.games, getBodyTopRatedGames());

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
      final response2 =
          await apiService.getIGDBData(IGDBAPIEndpointsEnum.games, getBodyNewestGames());

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
      final response4 =
      await apiService.getIGDBData(IGDBAPIEndpointsEnum.events, getBodyLatestEvents());

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
      final response4 =
      await apiService.getIGDBData(IGDBAPIEndpointsEnum.events, getBodyUpcomingEvents());

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
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 40),
            ),
            EventListView(headline: 'Latest Events', events: latestEventResponse),
            EventListView(headline: 'Upcoming Events', events: upcomingEventResponse),
            GameListView(
              headline: 'Most Followed Games',
              games: gamesResponse3,
              isPagination: true,
              body: getBodyStringMostFollowedGames(), showLimit: 10, isAggregated: false,
            ),
            GameListView(
              headline: 'Critics Choices',
              games: gamesResponse4, isPagination: true, body: getBodyCritcsRatingDesc(), showLimit: 10, isAggregated: true,
            ),
            GameListView(
              headline: 'Top Rated Games',
              games: gamesResponse1, isPagination: true, body: getBodyTopRatedGames(), showLimit: 10, isAggregated: false,
            ),
            GameListView(
              headline: 'Newest Games',
              games: gamesResponse2, isPagination: true, body: getBodyNewestGames(), showLimit: 10, isAggregated: false,
            ),

          ],
        ),
      ),
    );
  }
}
