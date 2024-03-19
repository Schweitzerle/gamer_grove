import 'dart:convert';
import 'package:bottom_bar_matu/utils/app_utils.dart';
import 'package:gamer_grove/model/igdb_models/character.dart';
import 'package:gamer_grove/model/igdb_models/company.dart';
import 'package:gamer_grove/model/igdb_models/event.dart';
import 'package:gamer_grove/model/igdb_models/game.dart';
import 'package:gamer_grove/model/igdb_models/game_engine.dart';
import 'package:gamer_grove/model/igdb_models/game_mode.dart';
import 'package:gamer_grove/model/igdb_models/genre.dart';
import 'package:gamer_grove/model/igdb_models/platform.dart';
import 'package:gamer_grove/model/igdb_models/player_perspectiverequest_path.dart';
import 'package:gamer_grove/model/igdb_models/theme.dart';
import 'package:gamer_grove/repository/igdb/AppTokenService.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;

import '../../model/firebase/firebaseUser.dart';
import '../../model/firebase/gameModel.dart';

class IGDBApiService {
  final String clientId = 'lbesf37nfwly4czho4wp8vqbzhexu8';
  final String accessToken = AppTokenService.token;
  final String baseUrl = "https://api.igdb.com/v4";

  Future<List<dynamic>> _postRequest(String endpoint, String body) async {
    final response = await http.post(
      Uri.parse('$baseUrl/$endpoint'), // Ensure that the URI is constructed correctly
      headers: {
        'Client-ID': clientId,
        'Authorization': 'Bearer $accessToken',
      },
      body: body,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load data: ${response.statusCode}');
    }
  }


  Future<List<dynamic>> getIGDBData(IGDBAPIEndpointsEnum igdbapiEndpointsEnum, String postBody) async {
    return await _postRequest(igdbapiEndpointsEnum.name, postBody);
  }

  List<Game> parseResponseToGame(List<dynamic> response) {
    if (response.isNotEmpty && response[0] is Map<String, dynamic>) {
      // Check if the response is not empty and is a list of maps
      return response.map<Game>((json) => Game.fromJson(json, getGameModel(json['id']))).toList();
    } else {
      return <Game>[]; // Return an empty list if there's no valid response
    }
  }

  static GameModel getGameModel(int id) {
    final getIt = GetIt.instance;
    final currentUser = getIt<FirebaseUserModel>();
    Map<String, dynamic> games =
        currentUser.games.values.firstWhereOrNull((game) => game['id'] == id.toString()) ??
            GameModel(id: id.toString(), wishlist: false, recommended: false, rating: 0.0)
                .toJson();
    return GameModel.fromMap(games);
  }


  List<Company> parseResponseToCompany(List<dynamic> response) {
    if (response.isNotEmpty && response[0] is Map<String, dynamic>) {
      // Check if the response is not empty and is a list of maps
      return response.map<Company>((json) => Company.fromJson(json)).toList();
    } else {
      return <Company>[]; // Return an empty list if there's no valid response
    }
  }

  List<GameEngine> parseResponseToGameEngine(List<dynamic> response) {
    if (response.isNotEmpty && response[0] is Map<String, dynamic>) {
      // Check if the response is not empty and is a list of maps
      return response.map<GameEngine>((json) => GameEngine.fromJson(json)).toList();
    } else {
      return <GameEngine>[]; // Return an empty list if there's no valid response
    }
  }

  List<Character> parseResponseToCharacter(List<dynamic> response) {
    if (response.isNotEmpty && response[0] is Map<String, dynamic>) {
      // Check if the response is not empty and is a list of maps
      return response.map<Character>((json) => Character.fromJson(json)).toList();
    } else {
      return <Character>[]; // Return an empty list if there's no valid response
    }
  }

  List<Event> parseResponseToEvent(List<dynamic> response) {
    if (response.isNotEmpty && response[0] is Map<String, dynamic>) {
      // Check if the response is not empty and is a list of maps
      return response.map<Event>((json) => Event.fromJson(json)).toList();
    } else {
      return <Event>[]; // Return an empty list if there's no valid response
    }
  }

  List<Genre> parseResponseToGenres(List<dynamic> response) {
    if (response.isNotEmpty && response[0] is Map<String, dynamic>) {
      // Check if the response is not empty and is a list of maps
      return response.map<Genre>((json) => Genre.fromJson(json)).toList();
    } else {
      return <Genre>[]; // Return an empty list if there's no valid response
    }
  }

  List<GameMode> parseResponseToGameModes(List<dynamic> response) {
    if (response.isNotEmpty && response[0] is Map<String, dynamic>) {
      // Check if the response is not empty and is a list of maps
      return response.map<GameMode>((json) => GameMode.fromJson(json)).toList();
    } else {
      return <GameMode>[]; // Return an empty list if there's no valid response
    }
  }

  List<PlatformIGDB> parseResponseToPlatforms(List<dynamic> response) {
    if (response.isNotEmpty && response[0] is Map<String, dynamic>) {
      // Check if the response is not empty and is a list of maps
      return response.map<PlatformIGDB>((json) => PlatformIGDB.fromJson(json)).toList();
    } else {
      return <PlatformIGDB>[]; // Return an empty list if there's no valid response
    }
  }

  List<PlayerPerspective> parseResponseToPlayerPerspectives(List<dynamic> response) {
    if (response.isNotEmpty && response[0] is Map<String, dynamic>) {
      // Check if the response is not empty and is a list of maps
      return response.map<PlayerPerspective>((json) => PlayerPerspective.fromJson(json)).toList();
    } else {
      return <PlayerPerspective>[]; // Return an empty list if there's no valid response
    }
  }

  List<ThemeIDGB> parseResponseToThemes(List<dynamic> response) {
    if (response.isNotEmpty && response[0] is Map<String, dynamic>) {
      // Check if the response is not empty and is a list of maps
      return response.map<ThemeIDGB>((json) => ThemeIDGB.fromJson(json)).toList();
    } else {
      return <ThemeIDGB>[]; // Return an empty list if there's no valid response
    }
  }

}

enum IGDBAPIEndpointsEnum {
  age_ratings,
  age_rating_content_descriptions,
  alternative_names,
  artworks,
  characters,
  character_mug_shots,
  collections,
  collection_memberships,
  collection_membership_types,
  collection_relations,
  collection_relation_types,
  collection_types,
  companies,
  company_logos,
  company_websites,
  covers,
  events,
  event_logos,
  event_networks,
  franchises,
  games,
  game_engines,
  game_engine_logos,
  external_games,
  game_versions,
  game_modes,
  game_version_features,
  game_version_feature_values,
  genres,
  involved_companies,
  game_videos,
  keywords,
  languages,
  game_localizations,
  language_support_types,
  multiplayer_modes,
  multiquery,
  language_supports,
  network_types,
  platform_families,
  platform_logos,
  platform_versions,
  platform_version_companies,
  platforms,
  platform_version_release_dates,
  platform_websites,
  player_perspectives,
  regions,
  release_dates,
  release_date_statuses,
  screenshots,
  search,
  themes,
  websites,
}

