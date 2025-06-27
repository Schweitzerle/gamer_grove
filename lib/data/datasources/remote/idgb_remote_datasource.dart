// data/datasources/remote/igdb_remote_datasource.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_constants.dart';
import '../../../core/errors/exceptions.dart';
import '../../../domain/entities/game.dart';
import '../../models/age_rating_model.dart';
import '../../models/collection_model.dart';
import '../../models/company_model.dart';
import '../../models/external_game_model.dart';
import '../../models/franchise_model.dart';
import '../../models/game_engine_model.dart';
import '../../models/game_model.dart';
import '../../models/game_video_model.dart';
import '../../models/keyword_model.dart';
import '../../models/language_support_model.dart';
import '../../models/multiplayer_mode_model.dart';
import '../../models/player_perspective_model.dart';
import '../../models/website_model.dart';

abstract class IGDBRemoteDataSource {

  // EXISTING METHODS
  Future<List<GameModel>> searchGames(String query, int limit, int offset);

  Future<GameModel> getGameDetails(int gameId);

  Future<List<GameModel>> getPopularGames(int limit, int offset);

  Future<List<GameModel>> getUpcomingGames(int limit, int offset);

  Future<List<GameModel>> getGamesByIds(List<int> gameIds);

  // NEW METHODS FOR EXTENDED API
  Future<List<CompanyModel>> getCompanies({List<int>? ids, String? search});

  Future<List<WebsiteModel>> getWebsites(List<int> gameIds);

  Future<List<GameVideoModel>> getGameVideos(List<int> gameIds);

  Future<List<AgeRatingModel>> getAgeRatings(List<int> gameIds);

  Future<List<GameEngineModel>> getGameEngines(
      {List<int>? ids, String? search});

  Future<List<KeywordModel>> getKeywords({List<int>? ids, String? search});

  Future<List<MultiplayerModeModel>> getMultiplayerModes(List<int> gameIds);

  Future<List<PlayerPerspectiveModel>> getPlayerPerspectives({List<int>? ids});

  Future<List<FranchiseModel>> getFranchises({List<int>? ids, String? search});

  Future<List<CollectionModel>> getCollections(
      {List<int>? ids, String? search});

  Future<List<ExternalGameModel>> getExternalGames(List<int> gameIds);

  Future<List<LanguageSupportModel>> getLanguageSupports(List<int> gameIds);

  Future<List<String>> getAlternativeNames(List<int> gameIds);

  Future<List<GameModel>> getSimilarGames(int gameId);

  Future<List<GameModel>> getGameDLCs(int gameId);

  Future<List<GameModel>> getGameExpansions(int gameId);

  // COMPREHENSIVE GAME DETAILS
  Future<GameModel> getCompleteGameDetails(int gameId);
}

class IGDBRemoteDataSourceImpl implements IGDBRemoteDataSource {
  final http.Client client;
  String? _accessToken;
  DateTime? _tokenExpiry;

  IGDBRemoteDataSourceImpl({required this.client});

  static const String _completeGameFields = '''
  id, name, summary, storyline, slug, url, checksum, created_at, updated_at,
  total_rating, total_rating_count, rating, rating_count, 
  aggregated_rating, aggregated_rating_count,
  first_release_date, game_status, game_type, version_title, version_parent,
  cover.url, cover.image_id,
  screenshots.url, screenshots.image_id,
  artworks.url, artworks.image_id,
  videos.video_id, videos.name,
  genres.id, genres.name, genres.slug,
  platforms.id, platforms.name, platforms.abbreviation, platforms.slug,
  game_modes.id, game_modes.name, game_modes.slug,
  themes.id, themes.name, themes.slug,
  keywords.id, keywords.name, keywords.slug,
  player_perspectives.id, player_perspectives.name, player_perspectives.slug,
  tags,
  involved_companies.id, involved_companies.company.id, involved_companies.company.name, 
  involved_companies.company.logo.url, involved_companies.developer, 
  involved_companies.publisher, involved_companies.porting, involved_companies.supporting,
  game_engines.id, game_engines.name, game_engines.logo.url, game_engines.url,
  websites.id, websites.url, websites.category, websites.trusted,
  external_games.id, external_games.uid, external_games.url, external_games.category,
  age_ratings.id, age_ratings.organization, age_ratings.rating_category, 
  age_ratings.synopsis, age_ratings.rating_cover_url,
  multiplayer_modes.id, multiplayer_modes.campaigncoop, multiplayer_modes.dropin, 
  multiplayer_modes.lancoop, multiplayer_modes.offlinecoop, multiplayer_modes.offlinecoopmax,
  multiplayer_modes.offlinemax, multiplayer_modes.onlinecoop, multiplayer_modes.onlinecoopmax,
  multiplayer_modes.onlinemax, multiplayer_modes.platform, multiplayer_modes.splitscreen,
  multiplayer_modes.splitscreenonline,
  language_supports.id, language_supports.language, language_supports.language_support_type,
  game_localizations.id, game_localizations.name, game_localizations.region,
  franchise.id, franchise.name, franchise.slug, franchise.url,
  franchises.id, franchises.name, franchises.slug, franchises.url,
  collections.id, collections.name, collections.slug, collections.url,
  similar_games.id, similar_games.name, similar_games.cover.url, similar_games.total_rating,
  dlcs.id, dlcs.name, dlcs.cover.url, dlcs.first_release_date,
  expansions.id, expansions.name, expansions.cover.url, expansions.first_release_date,
  standalone_expansions.id, standalone_expansions.name, standalone_expansions.cover.url,
  bundles.id, bundles.name, bundles.cover.url,
  expanded_games.id, expanded_games.name, expanded_games.cover.url,
  forks.id, forks.name, forks.cover.url,
  ports.id, ports.name, ports.cover.url,
  remakes.id, remakes.name, remakes.cover.url,
  remasters.id, remasters.name, remasters.cover.url,
  parent_game.id, parent_game.name, parent_game.cover.url,
  alternative_names.id, alternative_names.name, alternative_names.comment,
  release_dates.id, release_dates.date, release_dates.platform.name, 
  release_dates.region, release_dates.human,
  hypes
''';

  Future<Map<String, String>> get _headers async {
    await _ensureValidToken();
    return {
      'Client-ID': ApiConstants.igdbClientId,
      'Authorization': 'Bearer $_accessToken',
      'Content-Type': 'text/plain',
      'Accept': 'application/json',
    };
  }

  Future<void> _ensureValidToken() async {
    if (_accessToken == null ||
        _tokenExpiry == null ||
        DateTime.now().isAfter(_tokenExpiry!)) {
      print('🔑 IGDB: Refreshing access token...');
      await _refreshToken();
    }
  }

  Future<void> _refreshToken() async {
    try {
      print('🔄 IGDB: Requesting new token from Twitch...');
      final response = await client.post(
        Uri.parse('https://id.twitch.tv/oauth2/token'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'client_id': ApiConstants.igdbClientId,
          'client_secret': ApiConstants.igdbClientSecret,
          'grant_type': 'client_credentials',
        },
      );

      print('🔑 IGDB: Token response status: ${response.statusCode}');
      print('🔑 IGDB: Token response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _accessToken = data['access_token'];
        final expiresIn = data['expires_in'] as int;
        _tokenExpiry = DateTime.now().add(Duration(seconds: expiresIn - 60));

        print('✅ IGDB: Token refreshed successfully');
        print('📅 IGDB: Token expires at: $_tokenExpiry');
      } else {
        print(
            '❌ IGDB: Token refresh failed with status ${response.statusCode}');
        throw ServerException(
          message: 'Failed to refresh token: ${response.body}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print('💥 IGDB: Token refresh error: $e');
      throw ServerException(message: 'Token refresh failed: $e');
    }
  }

  @override
  Future<List<GameModel>> searchGames(
      String query, int limit, int offset) async {
    try {
      print('🔍 IGDB: Searching games with query: "$query"');

      final body = '''
        search "$query";
        fields id, name, summary, storyline, total_rating, total_rating_count, 
               cover.url, screenshots.url, artworks.url, first_release_date,
               genres.name, platforms.name, platforms.abbreviation, 
               game_modes.name, themes.name, follows, hypes;
        where version_parent = null & category = 0;
        limit $limit;
        offset $offset;
      ''';

      print('📤 IGDB: Request body: $body');
      return await _makeRequest(IGDBEndpoints.games, body);
    } catch (e) {
      print('💥 IGDB: Search games error: $e');
      rethrow;
    }
  }

  @override
  Future<GameModel> getGameDetails(int gameId) async {
    try {
      print('🎮 IGDB: Getting game details for ID: $gameId');

      final body = '''
        where id = $gameId;
        fields id, name, summary, storyline, total_rating, total_rating_count,
               cover.url, screenshots.url, artworks.url, first_release_date,
               genres.name, platforms.name, platforms.abbreviation,
               game_modes.name, themes.name, follows, hypes,
               involved_companies.company.name, websites.url, videos.video_id,
               similar_games.name, similar_games.cover.url;
        limit 1;
      ''';

      final games = await _makeRequest(IGDBEndpoints.games, body);
      if (games.isEmpty) {
        throw ServerException(message: 'Game not found');
      }
      return games.first;
    } catch (e) {
      print('💥 IGDB: Get game details error: $e');
      rethrow;
    }
  }

  @override
  Future<List<GameModel>> getPopularGames(int limit, int offset) async {
    try {
      print('🔥 IGDB: Getting popular games...');

      final body = '''
        fields id, name, summary, total_rating, total_rating_count,
               cover.url, first_release_date, genres.name, platforms.abbreviation;
        where total_rating_count > 50 & category = 0 & version_parent = null;
        sort total_rating desc;
        limit $limit;
        offset $offset;
      ''';

      return await _makeRequest(IGDBEndpoints.games, body);
    } catch (e) {
      print('💥 IGDB: Get popular games error: $e');
      rethrow;
    }
  }

  @override
  Future<List<GameModel>> getUpcomingGames(int limit, int offset) async {
    try {
      print('🚀 IGDB: Getting upcoming games...');

      final currentTimestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final body = '''
        fields id, name, summary, cover.url, first_release_date,
               genres.name, platforms.abbreviation, hypes;
        where first_release_date > $currentTimestamp & category = 0 & version_parent = null;
        sort first_release_date asc;
        limit $limit;
        offset $offset;
      ''';

      return await _makeRequest(IGDBEndpoints.games, body);
    } catch (e) {
      print('💥 IGDB: Get upcoming games error: $e');
      rethrow;
    }
  }

  @override
  Future<List<GameModel>> getGamesByIds(List<int> gameIds) async {
    if (gameIds.isEmpty) return [];

    try {
      print('🎯 IGDB: Getting games by IDs: $gameIds');

      final idsString = gameIds.join(',');
      final body = '''
        where id = ($idsString);
        fields id, name, summary, total_rating, total_rating_count,
               cover.url, first_release_date, genres.name, platforms.abbreviation;
        limit ${gameIds.length};
      ''';

      return await _makeRequest(IGDBEndpoints.games, body);
    } catch (e) {
      print('💥 IGDB: Get games by IDs error: $e');
      rethrow;
    }
  }

  Future<List<GameModel>> _makeRequest(String endpoint, String body) async {
    try {
      final headers = await _headers;
      final url = '${ApiConstants.igdbBaseUrl}/$endpoint';

      print('📡 IGDB: Making request to $url');
      print('📋 IGDB: Headers: $headers');
      print('📝 IGDB: Body: ${body.trim()}');

      final response = await client
          .post(
        Uri.parse(url),
        headers: headers,
        body: body.trim(),
      )
          .timeout(
        ApiConstants.connectionTimeout,
        onTimeout: () {
          throw ServerException(message: 'Request timeout');
        },
      );

      print('📨 IGDB: Response status: ${response.statusCode}');
      print('📄 IGDB: Response body length: ${response.body.length}');

      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          print('⚠️ IGDB: Empty response body');
          return [];
        }

        try {
          final List<dynamic> jsonList = json.decode(response.body);
          print('✅ IGDB: Successfully parsed ${jsonList.length} games');

          final games = jsonList
              .map((json) {
                try {
                  return GameModel.fromJson(json);
                } catch (e) {
                  print('⚠️ IGDB: Failed to parse game: $e');
                  print('🔍 IGDB: Problematic JSON: $json');
                  return null;
                }
              })
              .where((game) => game != null)
              .cast<GameModel>()
              .toList();

          print('🎮 IGDB: Successfully converted ${games.length} games');
          return games;
        } catch (e) {
          print('💥 IGDB: JSON parsing error: $e');
          print('📄 IGDB: Response body: ${response.body}');
          throw ServerException(message: 'Failed to parse response: $e');
        }
      } else {
        print('❌ IGDB: Request failed with status ${response.statusCode}');
        print('📄 IGDB: Error response: ${response.body}');

        String errorMessage = 'Request failed';
        if (response.statusCode == 401) {
          errorMessage = 'Authentication failed. Please check API credentials.';
        } else if (response.statusCode == 429) {
          errorMessage = 'Rate limit exceeded. Please try again later.';
        } else if (response.statusCode >= 500) {
          errorMessage = 'IGDB server error. Please try again later.';
        } else {
          errorMessage = 'Request failed with status ${response.statusCode}';
        }

        throw ServerException(
          message: errorMessage,
          statusCode: response.statusCode,
        );
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      print('💥 IGDB: Unexpected error: $e');
      throw ServerException(message: 'Unexpected error: $e');
    }
  }

  @override
  Future<GameModel> getCompleteGameDetails(int gameId) async {
    try {
      print('🎮 IGDB: Getting COMPLETE game details for ID: $gameId');

      final body = '''
  where id = $gameId;
  fields id, name, summary, storyline, slug, url, checksum, created_at, updated_at,
  total_rating, total_rating_count, rating, rating_count, 
  aggregated_rating, aggregated_rating_count,
  first_release_date, game_status, game_type, version_title, version_parent,
  cover.url, cover.image_id,
  screenshots.url, screenshots.image_id,
  artworks.url, artworks.image_id,
  videos.video_id, videos.name,
  genres.id, genres.name, genres.slug,
  platforms.id, platforms.name, platforms.abbreviation, platforms.slug,
  game_modes.id, game_modes.name, game_modes.slug,
  themes.id, themes.name, themes.slug,
  keywords.id, keywords.name, keywords.slug,
  player_perspectives.id, player_perspectives.name, player_perspectives.slug,
  tags,
  involved_companies.id, involved_companies.company.id, involved_companies.company.name, 
  involved_companies.company.logo.url, involved_companies.developer, 
  involved_companies.publisher, involved_companies.porting, involved_companies.supporting,
  game_engines.id, game_engines.name, game_engines.logo.url, game_engines.url,
  websites.id, websites.url, websites.category, websites.trusted,
  external_games.id, external_games.uid, external_games.url, external_games.category,
  age_ratings.id, age_ratings.organization, age_ratings.rating_category, 
  age_ratings.synopsis, age_ratings.rating_cover_url,
  multiplayer_modes.id, multiplayer_modes.campaigncoop, multiplayer_modes.dropin, 
  multiplayer_modes.lancoop, multiplayer_modes.offlinecoop, multiplayer_modes.offlinecoopmax,
  multiplayer_modes.offlinemax, multiplayer_modes.onlinecoop, multiplayer_modes.onlinecoopmax,
  multiplayer_modes.onlinemax, multiplayer_modes.platform, multiplayer_modes.splitscreen,
  multiplayer_modes.splitscreenonline,
  language_supports.id, language_supports.language, language_supports.language_support_type,
  game_localizations.id, game_localizations.name, game_localizations.region,
  franchise.id, franchise.name, franchise.slug, franchise.url,
  franchises.id, franchises.name, franchises.slug, franchises.url,
  collections.id, collections.name, collections.slug, collections.url,
  similar_games.id, similar_games.name, similar_games.cover.url, similar_games.total_rating,
  dlcs.id, dlcs.name, dlcs.cover.url, dlcs.first_release_date,
  expansions.id, expansions.name, expansions.cover.url, expansions.first_release_date,
  standalone_expansions.id, standalone_expansions.name, standalone_expansions.cover.url,
  bundles.id, bundles.name, bundles.cover.url,
  expanded_games.id, expanded_games.name, expanded_games.cover.url,
  forks.id, forks.name, forks.cover.url,
  ports.id, ports.name, ports.cover.url,
  remakes.id, remakes.name, remakes.cover.url,
  remasters.id, remasters.name, remasters.cover.url,
  parent_game.id, parent_game.name, parent_game.cover.url,
  alternative_names.id, alternative_names.name, alternative_names.comment,
  release_dates.id, release_dates.date, release_dates.platform.name, 
  release_dates.region, release_dates.human,
  hypes;
  limit 1;
''';

      final games = await _makeRequest(IGDBEndpoints.games, body);
      if (games.isEmpty) {
        throw ServerException(message: 'Game not found');
      }
      return games.first;
    } catch (e) {
      print('💥 IGDB: Get complete game details error: $e');
      rethrow;
    }
  }

  @override
  Future<List<CompanyModel>> getCompanies(
      {List<int>? ids, String? search}) async {
    try {
      String body;
      if (ids != null && ids.isNotEmpty) {
        final idsString = ids.join(',');
        body = '''
          where id = ($idsString);
          fields id, name, description, logo.url, country, url,
                 start_date, alternative_names.name;
          limit ${ids.length};
        ''';
      } else if (search != null) {
        body = '''
          search "$search";
          fields id, name, description, logo.url, country, url,
                 start_date, alternative_names.name;
          limit 50;
        ''';
      } else {
        body = '''
          fields id, name, description, logo.url, country, url,
                 start_date, alternative_names.name;
          limit 100;
        ''';
      }

      final response = await _makeRequestRaw(IGDBEndpoints.companies, body);
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => CompanyModel.fromJson(json)).toList();
    } catch (e) {
      print('💥 IGDB: Get companies error: $e');
      rethrow;
    }
  }

  @override
  Future<List<WebsiteModel>> getWebsites(List<int> gameIds) async {
    try {
      final idsString = gameIds.join(',');
      final body = '''
        where game = ($idsString);
        fields id, url, category, title;
        limit 500;
      ''';

      final response = await _makeRequestRaw(IGDBEndpoints.websites, body);
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => WebsiteModel.fromJson(json)).toList();
    } catch (e) {
      print('💥 IGDB: Get websites error: $e');
      return [];
    }
  }

  @override
  Future<List<GameVideoModel>> getGameVideos(List<int> gameIds) async {
    try {
      final idsString = gameIds.join(',');
      final body = '''
        where game = ($idsString);
        fields id, video_id, name, description;
        limit 100;
      ''';

      final response = await _makeRequestRaw(IGDBEndpoints.videos, body);
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => GameVideoModel.fromJson(json)).toList();
    } catch (e) {
      print('💥 IGDB: Get game videos error: $e');
      return [];
    }
  }


  @override
  Future<List<GameModel>> getSimilarGames(int gameId) async {
    try {
      // First get the main game to find similar games
      final body = '''
        where id = $gameId;
        fields similar_games.*;
        limit 1;
      ''';

      final mainGames = await _makeRequest(IGDBEndpoints.games, body);
      if (mainGames.isEmpty) return [];

      // Extract similar game IDs and fetch their details
      final similarIds =
          _extractSimilarGameIds(mainGames.first as Map<String, dynamic>);
      if (similarIds.isEmpty) return [];

      return getGamesByIds(similarIds);
    } catch (e) {
      print('💥 IGDB: Get similar games error: $e');
      return [];
    }
  }

  @override
  Future<List<GameModel>> getGameDLCs(int gameId) async {
    try {
      final body = '''
        where parent_game = $gameId & category = 1;
        fields id, name, summary, cover.url, first_release_date,
               genres.name, platforms.abbreviation, total_rating;
        limit 50;
      ''';

      return await _makeRequest(IGDBEndpoints.games, body);
    } catch (e) {
      print('💥 IGDB: Get game DLCs error: $e');
      return [];
    }
  }

  @override
  Future<List<GameModel>> getGameExpansions(int gameId) async {
    try {
      final body = '''
        where parent_game = $gameId & category = 2;
        fields id, name, summary, cover.url, first_release_date,
               genres.name, platforms.abbreviation, total_rating;
        limit 50;
      ''';

      return await _makeRequest(IGDBEndpoints.games, body);
    } catch (e) {
      print('💥 IGDB: Get game expansions error: $e');
      return [];
    }
  }

  @override
  Future<List<String>> getAlternativeNames(List<int> gameIds) async {
    try {
      final idsString = gameIds.join(',');
      final body = '''
        where game = ($idsString);
        fields name, comment;
        limit 200;
      ''';

      final response =
          await _makeRequestRaw(IGDBEndpoints.alternativeNames, body);
      final List<dynamic> data = json.decode(response.body);
      return data
          .where((item) => item['name'] != null)
          .map((item) => item['name'].toString())
          .toList();
    } catch (e) {
      print('💥 IGDB: Get alternative names error: $e');
      return [];
    }
  }

  // Helper method for raw requests that return different data structures
  Future<http.Response> _makeRequestRaw(String endpoint, String body) async {
    try {
      final headers = await _headers;
      final url = '${ApiConstants.igdbBaseUrl}$endpoint';

      print('📡 IGDB: Making raw request to $endpoint');
      print('📤 IGDB: Request body: $body');

      final response = await client.post(
        Uri.parse(url),
        headers: headers,
        body: body,
      );

      print('📬 IGDB: Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return response;
      } else {
        print('❌ IGDB: Error response: ${response.body}');
        throw ServerException(
          message: 'IGDB API error: ${response.body}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print('💥 IGDB: Raw request error: $e');
      rethrow;
    }
  }


  // Add implementations for other missing methods...
  @override
  Future<List<GameEngineModel>> getGameEngines(
      {List<int>? ids, String? search}) async {
    // Implementation similar to getCompanies
    throw UnimplementedError('getGameEngines not yet implemented');
  }

  @override
  Future<List<KeywordModel>> getKeywords(
      {List<int>? ids, String? search}) async {
    // Implementation similar to getCompanies
    throw UnimplementedError('getKeywords not yet implemented');
  }

  @override
  Future<List<MultiplayerModeModel>> getMultiplayerModes(
      List<int> gameIds) async {
    // Implementation similar to getWebsites
    throw UnimplementedError('getMultiplayerModes not yet implemented');
  }

  @override
  Future<List<PlayerPerspectiveModel>> getPlayerPerspectives(
      {List<int>? ids}) async {
    // Implementation similar to getCompanies
    throw UnimplementedError('getPlayerPerspectives not yet implemented');
  }

  @override
  Future<List<FranchiseModel>> getFranchises(
      {List<int>? ids, String? search}) async {
    // Implementation similar to getCompanies
    throw UnimplementedError('getFranchises not yet implemented');
  }

  @override
  Future<List<CollectionModel>> getCollections(
      {List<int>? ids, String? search}) async {
    // Implementation similar to getCompanies
    throw UnimplementedError('getCollections not yet implemented');
  }

  @override
  Future<List<ExternalGameModel>> getExternalGames(List<int> gameIds) async {
    // Implementation similar to getWebsites
    throw UnimplementedError('getExternalGames not yet implemented');
  }

  @override
  Future<List<LanguageSupportModel>> getLanguageSupports(
      List<int> gameIds) async {
    // Implementation similar to getWebsites
    throw UnimplementedError('getLanguageSupports not yet implemented');
  }


  Future<List<GameModel>> getGameBundles(int gameId) async {
    try {
      final body = '''
      where bundles = ($gameId);
      fields $_completeGameFields;
      limit 50;
    ''';

      return await _makeRequest(IGDBEndpoints.games, body);
    } catch (e) {
      print('💥 IGDB: Get game bundles error: $e');
      return [];
    }
  }

  Future<List<GameModel>> getGamePorts(int gameId) async {
    try {
      final body = '''
      where ports = ($gameId);
      fields $_completeGameFields;
      limit 50;
    ''';

      return await _makeRequest(IGDBEndpoints.games, body);
    } catch (e) {
      print('💥 IGDB: Get game ports error: $e');
      return [];
    }
  }

  Future<List<GameModel>> getGameRemakes(int gameId) async {
    try {
      final body = '''
      where remakes = ($gameId);
      fields $_completeGameFields;
      limit 50;
    ''';

      return await _makeRequest(IGDBEndpoints.games, body);
    } catch (e) {
      print('💥 IGDB: Get game remakes error: $e');
      return [];
    }
  }

  Future<List<GameModel>> getGameRemasters(int gameId) async {
    try {
      final body = '''
      where remasters = ($gameId);
      fields $_completeGameFields;
      limit 50;
    ''';

      return await _makeRequest(IGDBEndpoints.games, body);
    } catch (e) {
      print('💥 IGDB: Get game remasters error: $e');
      return [];
    }
  }

// ===== ERWEITERTE FILTER METHODEN =====

  Future<List<GameModel>> getGamesByType(GameType gameType, {int limit = 50, int offset = 0}) async {
    try {
      final typeId = _gameTypeToId(gameType);
      final body = '''
      where game_type = $typeId;
      fields $_completeGameFields;
      sort total_rating desc;
      limit $limit;
      offset $offset;
    ''';

      return await _makeRequest(IGDBEndpoints.games, body);
    } catch (e) {
      print('💥 IGDB: Get games by type error: $e');
      return [];
    }
  }

  Future<List<GameModel>> getGamesByStatus(GameStatus gameStatus, {int limit = 50, int offset = 0}) async {
    try {
      final statusId = _gameStatusToId(gameStatus);
      final body = '''
      where game_status = $statusId;
      fields $_completeGameFields;
      sort first_release_date desc;
      limit $limit;
      offset $offset;
    ''';

      return await _makeRequest(IGDBEndpoints.games, body);
    } catch (e) {
      print('💥 IGDB: Get games by status error: $e');
      return [];
    }
  }

  Future<List<GameModel>> getGamesByGenre(int genreId, {int limit = 50, int offset = 0}) async {
    try {
      final body = '''
      where genres = ($genreId) & game_type = 0;
      fields $_completeGameFields;
      sort total_rating desc;
      limit $limit;
      offset $offset;
    ''';

      return await _makeRequest(IGDBEndpoints.games, body);
    } catch (e) {
      print('💥 IGDB: Get games by genre error: $e');
      return [];
    }
  }

  Future<List<GameModel>> getGamesByPlatform(int platformId, {int limit = 50, int offset = 0}) async {
    try {
      final body = '''
      where platforms = ($platformId) & game_type = 0;
      fields $_completeGameFields;
      sort total_rating desc;
      limit $limit;
      offset $offset;
    ''';

      return await _makeRequest(IGDBEndpoints.games, body);
    } catch (e) {
      print('💥 IGDB: Get games by platform error: $e');
      return [];
    }
  }

  Future<List<GameModel>> getGamesByDateRange(DateTime startDate, DateTime endDate, {int limit = 50, int offset = 0}) async {
    try {
      final startTimestamp = startDate.millisecondsSinceEpoch ~/ 1000;
      final endTimestamp = endDate.millisecondsSinceEpoch ~/ 1000;

      final body = '''
      where first_release_date >= $startTimestamp & first_release_date <= $endTimestamp & game_type = 0;
      fields $_completeGameFields;
      sort first_release_date desc;
      limit $limit;
      offset $offset;
    ''';

      return await _makeRequest(IGDBEndpoints.games, body);
    } catch (e) {
      print('💥 IGDB: Get games by date range error: $e');
      return [];
    }
  }

// ===== ENUM CONVERSION HELPERS =====

  int _gameTypeToId(GameType gameType) {
    switch (gameType) {
      case GameType.mainGame: return 0;
      case GameType.dlcAddon: return 1;
      case GameType.expansion: return 2;
      case GameType.bundle: return 3;
      case GameType.standaloneExpansion: return 4;
      case GameType.mod: return 5;
      case GameType.episode: return 6;
      case GameType.season: return 7;
      case GameType.remake: return 8;
      case GameType.remaster: return 9;
      case GameType.expandedGame: return 10;
      case GameType.port: return 11;
      case GameType.fork: return 12;
      case GameType.pack: return 13;
      case GameType.update: return 14;
      default: return 0;
    }
  }

  int _gameStatusToId(GameStatus gameStatus) {
    switch (gameStatus) {
      case GameStatus.released: return 0;
      case GameStatus.alpha: return 2;
      case GameStatus.beta: return 3;
      case GameStatus.earlyAccess: return 4;
      case GameStatus.offline: return 5;
      case GameStatus.cancelled: return 6;
      case GameStatus.rumored: return 7;
      case GameStatus.delisted: return 8;
      default: return 0;
    }
  }

// ===== ERWEITERTE AGE RATINGS =====

  @override
  Future<List<AgeRatingModel>> getAgeRatings(List<int> gameIds) async {
    try {
      final idsString = gameIds.join(',');
      final body = '''
      where game = ($idsString);
      fields id, organization, rating_category, synopsis, rating_cover_url,
             rating_content_descriptions, content_descriptions;
      limit 100;
    ''';

      final response = await _makeRequestRaw(IGDBEndpoints.ageRatings, body);
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => AgeRatingModel.fromJson(json)).toList();
    } catch (e) {
      print('💥 IGDB: Get age ratings error: $e');
      return [];
    }
  }

// ===== HELPER METHODS =====

  List<int> _extractSimilarGameIds(Map<String, dynamic> gameData) {
    final similar = gameData['similar_games'];
    if (similar is List) {
      return similar
          .where((item) => item is Map && item['id'] is int)
          .map((item) => item['id'] as int)
          .take(10)
          .toList();
    }
    return [];
  }
}
