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
    };
  }

  Future<void> _ensureValidToken() async {
    if (_accessToken == null ||
        _tokenExpiry == null ||
        DateTime.now().isAfter(_tokenExpiry!)) {
      await _refreshToken();
    }
  }

  Future<void> _refreshToken() async {
    try {
      final response = await client.post(
        Uri.parse('https://id.twitch.tv/oauth2/token'),
        body: {
          'client_id': ApiConstants.igdbClientId,
          'client_secret': ApiConstants.igdbClientSecret,
          'grant_type': 'client_credentials',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _accessToken = data['access_token'];
        final expiresIn = data['expires_in'] as int;
        _tokenExpiry = DateTime.now().add(Duration(seconds: expiresIn - 60));
      } else {
        throw ServerException(
          message: 'Failed to refresh token',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      throw ServerException(message: 'Token refresh failed: $e');
    }
  }

  @override
  Future<List<GameModel>> searchGames(String query, int limit, int offset) async {
    final body = '''
      search "$query";
      fields id, name, summary, storyline, total_rating, total_rating_count, 
             cover.url, screenshots.url, artworks.url, first_release_date,
             genres.*, platforms.*, game_modes.*, themes.*, follows, hypes;
      limit $limit;
      offset $offset;
    ''';

    return _makeRequest(IGDBEndpoints.games, body);
  }

  @override
  Future<GameModel> getGameDetails(int gameId) async {
    final body = '''
      where id = $gameId;
      fields id, name, summary, storyline, total_rating, total_rating_count,
             cover.url, screenshots.url, artworks.url, first_release_date,
             genres.*, platforms.*, game_modes.*, themes.*, follows, hypes,
             involved_companies.company.name, websites.*, videos.*;
      limit 1;
    ''';

    final games = await _makeRequest(IGDBEndpoints.games, body);
    if (games.isEmpty) {
      throw ServerException(message: 'Game not found');
    }
    return games.first;
  }

  @override
  Future<List<GameModel>> getPopularGames(int limit, int offset) async {
    final body = '''
      fields id, name, summary, total_rating, total_rating_count,
             cover.url, first_release_date, genres.name, platforms.abbreviation;
      where total_rating_count > 50;
      sort total_rating desc;
      limit $limit;
      offset $offset;
    ''';

    return _makeRequest(IGDBEndpoints.games, body);
  }

  @override
  Future<List<GameModel>> getUpcomingGames(int limit, int offset) async {
    final currentTimestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final body = '''
      fields id, name, summary, cover.url, first_release_date,
             genres.name, platforms.abbreviation, hypes;
      where first_release_date > $currentTimestamp & hypes != null;
      sort hypes desc;
      limit $limit;
      offset $offset;
    ''';

    return _makeRequest(IGDBEndpoints.games, body);
  }

  @override
  Future<List<GameModel>> getGamesByIds(List<int> gameIds) async {
    if (gameIds.isEmpty) return [];

    final idsString = gameIds.join(',');
    final body = '''
      where id = ($idsString);
      fields id, name, summary, total_rating, total_rating_count,
             cover.url, first_release_date, genres.name, platforms.abbreviation;
      limit ${gameIds.length};
    ''';

    return _makeRequest(IGDBEndpoints.games, body);
  }

  Future<List<GameModel>> _makeRequest(String endpoint, String body) async {
    try {
      final response = await client.post(
        Uri.parse('${ApiConstants.igdbBaseUrl}$endpoint'),
        headers: await _headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => GameModel.fromJson(json)).toList();
      } else {
        throw ServerException(
          message: 'Request failed',
          statusCode: response.statusCode,
        );
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: 'Unexpected error: $e');
    }
  }
}

