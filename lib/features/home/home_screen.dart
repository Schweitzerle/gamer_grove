import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamer_grove/model/igdb_models/game.dart';
import 'package:gamer_grove/model/singleton/sinlgleton.dart';
import 'package:gamer_grove/model/views/gameListPreview.dart';
import 'package:gamer_grove/repository/igdb/IGDBApiService.dart';

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


  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async {
    await Future.wait([getIGDBData()]);
  }


  Future<void> getIGDBData() async {
    final apiService = IGDBApiService();
    try {
      final int unixTimestamp = DateTime
          .now()
          .millisecondsSinceEpoch ~/ 1000;

      const body1 = 'fields name, cover.*, age_ratings.*, aggregated_rating, aggregated_rating_count, alternative_names.*, artworks.*, bundles.*, category, checksum, collection.*, collections.*, created_at, dlcs.*, expanded_games.*, expansions.*, external_games.*, first_release_date, follows, forks.*, franchise.*, franchises.*, game_engines.*, game_localizations.*, game_modes.*, genres.*, hypes, involved_companies.*, keywords.*, language_supports.*, multiplayer_modes.*, name, parent_game.*, platforms.*, player_perspectives.*, ports, rating, rating_count, release_dates.*, remakes.*, remasters.*, screenshots.*, similar_games, slug, standalone_expansions.*, status, storyline, summary, tags, themes.*, total_rating, total_rating_count, updated_at, url, version_parent.*, version_title, videos.*, websites.*; s total_rating desc; w total_rating != null & total_rating_count >= 10; l 20;';
      final body2 = 'fields name, cover.*, age_ratings.*, aggregated_rating, aggregated_rating_count, alternative_names.*, artworks.*, bundles.*, category, checksum, collection.*, collections.*, created_at, dlcs.*, expanded_games.*, expansions.*, external_games.*, first_release_date, follows, forks.*, franchise.*, franchises.*, game_engines.*, game_localizations.*, game_modes.*, genres.*, hypes, involved_companies.*, keywords.*, language_supports.*, multiplayer_modes.*, name, parent_game.*, platforms.*, player_perspectives.*, ports, rating, rating_count, release_dates.*, remakes.*, remasters.*, screenshots.*, similar_games, slug, standalone_expansions.*, status, storyline, summary, tags, themes.*, total_rating, total_rating_count, updated_at, url, version_parent.*, version_title, videos.*, websites.*; s first_release_date desc; w first_release_date != null & first_release_date <= $unixTimestamp;';
      const body3 = 'fields name, cover.*, age_ratings.*, aggregated_rating, aggregated_rating_count, alternative_names.*, artworks.*, bundles.*, category, checksum, collection.*, collections.*, created_at, dlcs.*, expanded_games.*, expansions.*, external_games.*, first_release_date, follows, forks.*, franchise.*, franchises.*, game_engines.*, game_localizations.*, game_modes.*, genres.*, hypes, involved_companies.*, keywords.*, language_supports.*, multiplayer_modes.*, name, parent_game.*, platforms.*, player_perspectives.*, ports, rating, rating_count, release_dates.*, remakes.*, remasters.*, screenshots.*, similar_games, slug, standalone_expansions.*, status, storyline, summary, tags, themes.*, total_rating, total_rating_count, updated_at, url, version_parent.*, version_title, videos.*, websites.*; s follows desc; w follows != null; l 20;';
      const body4 = 'fields name, cover.*, age_ratings.*, aggregated_rating, aggregated_rating_count, alternative_names.*, artworks.*, bundles.*, category, checksum, collection.*, collections.*, created_at, dlcs.*, expanded_games.*, expansions.*, external_games.*, first_release_date, follows, forks.*, franchise.*, franchises.*, game_engines.*, game_localizations.*, game_modes.*, genres.*, hypes, involved_companies.*, keywords.*, language_supports.*, multiplayer_modes.*, name, parent_game.*, platforms.*, player_perspectives.*, ports, rating, rating_count, release_dates.*, remakes.*, remasters.*, screenshots.*, similar_games, slug, standalone_expansions.*, status, storyline, summary, tags, themes.*, total_rating, total_rating_count, updated_at, url, version_parent.*, version_title, videos.*, websites.*; s aggregated_rating desc; w aggregated_rating != null & aggregated_rating_count >= 10; l 20;';

      final response3 = await apiService.getIGDBData(
          IGDBAPIEndpointsEnum.games, body3);
      final response2 = await apiService.getIGDBData(
          IGDBAPIEndpointsEnum.games, body2);
      final response1 = await apiService.getIGDBData(
          IGDBAPIEndpointsEnum.games, body1);
      final response4 = await apiService.getIGDBData(
          IGDBAPIEndpointsEnum.games, body4);

      setState(() {
        gamesResponse3 = response3;
        gamesResponse2 = response2;
        gamesResponse1 = response1;
        gamesResponse4 = response4;
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
            ),
            GameListView(
              headline: 'Von der Kritik Gelobte Spiele',
              games: gamesResponse4,
            ),
            GameListView(
              headline: 'Top Bewertete Spiele',
              games: gamesResponse1,
            ),
            GameListView(
              headline: 'Neuste Spiele',
              games: gamesResponse2,
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