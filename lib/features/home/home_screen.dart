import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamer_grove/model/igdb_models/game.dart';
import 'package:gamer_grove/model/singleton/sinlgleton.dart';
import 'package:gamer_grove/model/views/gameListPreview.dart';
import 'package:gamer_grove/repository/igdb/IGDBApiService.dart';
import 'package:redacted/redacted.dart';

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
  final apiService = IGDBApiService();

  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async {
    await Future.wait([getIGDBDataMostFollowed(), getIGDBDataCriticsRatingDesc(), getIGDBDataTopRated(), getIGDBDataNewestGames()]);
  }

  String getBodyStringMostFollowedGames() {
    const body3 =
        'fields name, cover.*, age_ratings.*, aggregated_rating, aggregated_rating_count, alternative_names.*, artworks.*, bundles.*, category, checksum, collection.*, collections.*, created_at, dlcs.*, expanded_games.*, expansions.*, external_games.*, first_release_date, follows, forks.*, franchise.*, franchises.*, game_engines.*, game_localizations.*, game_modes.*, genres.*, hypes, involved_companies.*, keywords.*, language_supports.*, multiplayer_modes.*, name, parent_game.*, platforms.*, player_perspectives.*, ports, rating, rating_count, release_dates.*, remakes.*, remasters.*, screenshots.*, similar_games, slug, standalone_expansions.*, status, storyline, summary, tags, themes.*, total_rating, total_rating_count, updated_at, url, version_parent.*, version_title, videos.*, websites.*; s follows desc; w follows != null; l 20;';
    return body3;
  }

  String getBodyCritcsRatingDesc() {
    const body4 =
        'fields name, cover.*, age_ratings.*, aggregated_rating, aggregated_rating_count, alternative_names.*, artworks.*, bundles.*, category, checksum, collection.*, collections.*, created_at, dlcs.*, expanded_games.*, expansions.*, external_games.*, first_release_date, follows, forks.*, franchise.*, franchises.*, game_engines.*, game_localizations.*, game_modes.*, genres.*, hypes, involved_companies.*, keywords.*, language_supports.*, multiplayer_modes.*, name, parent_game.*, platforms.*, player_perspectives.*, ports, rating, rating_count, release_dates.*, remakes.*, remasters.*, screenshots.*, similar_games, slug, standalone_expansions.*, status, storyline, summary, tags, themes.*, total_rating, total_rating_count, updated_at, url, version_parent.*, version_title, videos.*, websites.*; s aggregated_rating desc; w aggregated_rating != null & aggregated_rating_count >= 10; l 20;';
    return body4;
  }

  String getBodyTopRatedGames() {
    const body1 =
        'fields name, cover.*, age_ratings.*, aggregated_rating, aggregated_rating_count, alternative_names.*, artworks.*, bundles.*, category, checksum, collection.*, collections.*, created_at, dlcs.*, expanded_games.*, expansions.*, external_games.*, first_release_date, follows, forks.*, franchise.*, franchises.*, game_engines.*, game_localizations.*, game_modes.*, genres.*, hypes, involved_companies.*, keywords.*, language_supports.*, multiplayer_modes.*, name, parent_game.*, platforms.*, player_perspectives.*, ports, rating, rating_count, release_dates.*, remakes.*, remasters.*, screenshots.*, similar_games, slug, standalone_expansions.*, status, storyline, summary, tags, themes.*, total_rating, total_rating_count, updated_at, url, version_parent.*, version_title, videos.*, websites.*; s total_rating desc; w total_rating != null & total_rating_count >= 10; l 20;';
    return body1;
  }

  String getBodyNewestGames() {
    final int unixTimestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final body2 =
        'fields name, cover.*, age_ratings.*, aggregated_rating, aggregated_rating_count, alternative_names.*, artworks.*, bundles.*, category, checksum, collection.*, collections.*, created_at, dlcs.*, expanded_games.*, expansions.*, external_games.*, first_release_date, follows, forks.*, franchise.*, franchises.*, game_engines.*, game_localizations.*, game_modes.*, genres.*, hypes, involved_companies.*, keywords.*, language_supports.*, multiplayer_modes.*, name, parent_game.*, platforms.*, player_perspectives.*, ports, rating, rating_count, release_dates.*, remakes.*, remasters.*, screenshots.*, similar_games, slug, standalone_expansions.*, status, storyline, summary, tags, themes.*, total_rating, total_rating_count, updated_at, url, version_parent.*, version_title, videos.*, websites.*; s first_release_date desc; w first_release_date != null & first_release_date <= $unixTimestamp;';
    return body2;
  }

  Future<void> getIGDBDataMostFollowed() async {
    try {
      final response3 = await apiService.getIGDBData(
          IGDBAPIEndpointsEnum.games, getBodyStringMostFollowedGames());

      setState(() {
        gamesResponse3 = response3;
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
        gamesResponse4 = response4;
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
        gamesResponse1 = response1;
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
        gamesResponse2 = response2;
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 40),
            ),
            GameListView(
              headline: 'Meist Gefolgten Spiele',
              games: gamesResponse3,
              isPagination: true,
              body: getBodyStringMostFollowedGames(),
            ),
            GameListView(
              headline: 'Von der Kritik Gelobte Spiele',
              games: gamesResponse4, isPagination: true, body: getBodyCritcsRatingDesc(),
            ),
            GameListView(
              headline: 'Top Bewertete Spiele',
              games: gamesResponse1, isPagination: true, body: getBodyTopRatedGames(),
            ),
            GameListView(
              headline: 'Neuste Spiele',
              games: gamesResponse2, isPagination: true, body: getBodyNewestGames(),
            ),

            // Padding at the bottom for the desired margin
            Padding(
              padding: EdgeInsets.only(bottom: 80),
            ),
          ],
        ),
      ),
    );
  }
}
