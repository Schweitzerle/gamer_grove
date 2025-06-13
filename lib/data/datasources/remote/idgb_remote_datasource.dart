// data/datasources/remote/igdb_remote_datasource.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_constants.dart';
import '../../../core/errors/exceptions.dart';
import '../../models/game_model.dart';

abstract class IGDBRemoteDataSource {
  Future<List<GameModel>> searchGames(String query, int limit, int offset);
  Future<GameModel> getGameDetails(int gameId);
  Future<List<GameModel>> getPopularGames(int limit, int offset);
  Future<List<GameModel>> getUpcomingGames(int limit, int offset);
  Future<List<GameModel>> getGamesByIds(List<int> gameIds);
}

class IGDBRemoteDataSourceImpl implements IGDBRemoteDataSource {
  final http.Client client;
  String? _accessToken;
  DateTime? _tokenExpiry;

  IGDBRemoteDataSourceImpl({required this.client});

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
        print('❌ IGDB: Token refresh failed with status ${response.statusCode}');
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
  Future<List<GameModel>> searchGames(String query, int limit, int offset) async {
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
      final url = '${ApiConstants.igdbBaseUrl}$endpoint';

      print('📡 IGDB: Making request to $url');
      print('📋 IGDB: Headers: $headers');
      print('📝 IGDB: Body: ${body.trim()}');

      final response = await client.post(
        Uri.parse(url),
        headers: headers,
        body: body.trim(),
      ).timeout(
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

          final games = jsonList.map((json) {
            try {
              return GameModel.fromJson(json);
            } catch (e) {
              print('⚠️ IGDB: Failed to parse game: $e');
              print('🔍 IGDB: Problematic JSON: $json');
              return null;
            }
          }).where((game) => game != null).cast<GameModel>().toList();

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
}