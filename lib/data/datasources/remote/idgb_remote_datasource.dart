// data/datasources/remote/igdb_remote_datasource.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_constants.dart';
import '../../../core/errors/exceptions.dart';
import '../../../domain/entities/character/character.dart';
import '../../../domain/entities/externalGame/external_game.dart';
import '../../../domain/entities/game/game.dart';
import '../../../domain/entities/platform/platform.dart';
import '../../models/ageRating/age_rating_category_model.dart';
import '../../models/ageRating/age_rating_model.dart';
import '../../models/ageRating/age_rating_organization.dart';
import '../../models/alternative_name_model.dart';
import '../../models/character/character_gender_model.dart';
import '../../models/character/character_model.dart';
import '../../models/character/character_mug_shot_model.dart';
import '../../models/character/character_species_model.dart';
import '../../models/collection/collection_membership_model.dart';
import '../../models/collection/collection_relation_model.dart';
import '../../models/collection/collection_type_model.dart';
import '../../models/collection_model.dart';
import '../../models/company_model.dart';
import '../../models/externalGame/external_game_model.dart';
import '../../models/externalGame/external_game_source_model.dart';
import '../../models/franchise_model.dart';
import '../../models/game/game_engine_model.dart';
import '../../models/game/game_mode_model.dart';
import '../../models/game/game_model.dart';
import '../../models/game/game_release_format_entity.dart';
import '../../models/game/game_video_model.dart';
import '../../models/genre_model.dart';
import '../../models/keyword_model.dart';
import '../../models/language_support_model.dart';
import '../../models/multiplayer_mode_model.dart';
import '../../models/platform/paltform_type_model.dart';
import '../../models/platform/platform_family_model.dart';
import '../../models/platform/platform_logo_model.dart';
import '../../models/platform/platform_model.dart';
import '../../models/player_perspective_model.dart';
import '../../models/theme_model.dart';
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

  Future<List<AgeRatingOrganizationModel>> getAgeRatingOrganizations({List<int>? ids});
  Future<List<AgeRatingCategoryModel>> getAgeRatingCategories({
    List<int>? ids,
    int? organizationId,
  });
  Future<List<Map<String, dynamic>>> getCompleteAgeRatings(List<int> gameIds);

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

      final response = await _makeRequestRaw(IGDBEndpoints.gameVideos, body);
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

  // lib/data/datasources/remote/igdb_remote_datasource_impl.dart - Age Rating Methods
// Diese Methoden gehören in die IGDBRemoteDataSourceImpl Klasse

  @override
  Future<List<AgeRatingModel>> getAgeRatings(List<int> gameIds) async {
    try {
      final idsString = gameIds.join(',');
      final body = '''
        where game = ($idsString);
        fields id, checksum, content_descriptions, organization, 
               rating_category, rating_content_descriptions, 
               rating_cover_url, synopsis;
        limit 200;
      ''';

      final response = await _makeRequestRaw(IGDBEndpoints.ageRatings, body);
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => AgeRatingModel.fromJson(json)).toList();
    } catch (e) {
      print('💥 IGDB: Get age ratings error: $e');
      return [];
    }
  }

  // NEW METHOD: Get Age Rating Organizations
  Future<List<AgeRatingOrganizationModel>> getAgeRatingOrganizations({
    List<int>? ids,
  }) async {
    try {
      String body;
      if (ids != null && ids.isNotEmpty) {
        final idsString = ids.join(',');
        body = '''
          where id = ($idsString);
          fields id, checksum, created_at, name, updated_at;
          limit ${ids.length};
        ''';
      } else {
        body = '''
          fields id, checksum, created_at, name, updated_at;
          limit 100;
        ''';
      }

      final response = await _makeRequestRaw(IGDBEndpoints.ageRatingOrganizations, body);
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => AgeRatingOrganizationModel.fromJson(json)).toList();
    } catch (e) {
      print('💥 IGDB: Get age rating organizations error: $e');
      return [];
    }
  }

  // NEW METHOD: Get Age Rating Categories
  Future<List<AgeRatingCategoryModel>> getAgeRatingCategories({
    List<int>? ids,
    int? organizationId,
  }) async {
    try {
      String body;
      if (ids != null && ids.isNotEmpty) {
        final idsString = ids.join(',');
        body = '''
          where id = ($idsString);
          fields id, checksum, created_at, organization, rating, updated_at;
          limit ${ids.length};
        ''';
      } else if (organizationId != null) {
        body = '''
          where organization = $organizationId;
          fields id, checksum, created_at, organization, rating, updated_at;
          limit 100;
        ''';
      } else {
        body = '''
          fields id, checksum, created_at, organization, rating, updated_at;
          limit 100;
        ''';
      }

      final response = await _makeRequestRaw(IGDBEndpoints.ageRatingCategories, body);
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => AgeRatingCategoryModel.fromJson(json)).toList();
    } catch (e) {
      print('💥 IGDB: Get age rating categories error: $e');
      return [];
    }
  }

  // ENHANCED METHOD: Get Complete Age Ratings with Organizations and Categories
  Future<List<Map<String, dynamic>>> getCompleteAgeRatings(List<int> gameIds) async {
    try {
      // 1. Get age ratings
      final ageRatings = await getAgeRatings(gameIds);
      if (ageRatings.isEmpty) return [];

      // 2. Get all organization IDs
      final organizationIds = ageRatings
          .where((rating) => rating.organizationId != null)
          .map((rating) => rating.organizationId!)
          .toSet()
          .toList();

      // 3. Get all category IDs
      final categoryIds = ageRatings
          .where((rating) => rating.ratingCategoryId!= null)
          .map((rating) => rating.ratingCategoryId!)
          .toSet()
          .toList();

      // 4. Fetch organizations and categories
      final organizations = organizationIds.isNotEmpty
          ? await getAgeRatingOrganizations(ids: organizationIds)
          : <AgeRatingOrganizationModel>[];

      final categories = categoryIds.isNotEmpty
          ? await getAgeRatingCategories(ids: categoryIds)
          : <AgeRatingCategoryModel>[];

      // 5. Build complete data
      return ageRatings.map((rating) {
        final organization = organizations.firstWhere(
              (org) => org.id == rating.organizationId,
          orElse: () => const AgeRatingOrganizationModel(
              id: 0,
              checksum: '',
              name: 'Unknown'
          ),
        );

        final category = categories.firstWhere(
              (cat) => cat.id == rating.ratingCategoryId,
          orElse: () => const AgeRatingCategoryModel(
              id: 0,
              checksum: '',
              rating: 'Unknown'
          ),
        );

        return {
          'age_rating': rating,
          'organization': organization,
          'category': category,
        };
      }).toList();
    } catch (e) {
      print('💥 IGDB: Get complete age ratings error: $e');
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



  // lib/data/datasources/remote/igdb_remote_datasource_impl.dart - Alternative Names Methods
// Diese Methoden gehören in die IGDBRemoteDataSourceImpl Klasse

  // ENHANCED: Get Alternative Names with full data
  Future<List<AlternativeNameModel>> getAlternativeNamesDetailed(List<int> gameIds) async {
    try {
      final idsString = gameIds.join(',');
      final body = '''
        where game = ($idsString);
        fields id, checksum, comment, game, name, created_at, updated_at;
        limit 500;
      ''';

      final response = await _makeRequestRaw(IGDBEndpoints.alternativeNames, body);
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => AlternativeNameModel.fromJson(json)).toList();
    } catch (e) {
      print('💥 IGDB: Get alternative names detailed error: $e');
      return [];
    }
  }

  // ENHANCED: Search games by alternative names
  Future<List<GameModel>> searchGamesByAlternativeNames(String query) async {
    try {
      // First, search for alternative names
      final body = '''
        search "$query";
        fields id, game, name;
        limit 100;
      ''';

      final response = await _makeRequestRaw(IGDBEndpoints.alternativeNames, body);
      final List<dynamic> data = json.decode(response.body);

      // Extract game IDs from alternative names
      final gameIds = data
          .where((item) => item['game'] != null)
          .map((item) => item['game'] as int)
          .toSet()
          .toList();

      if (gameIds.isEmpty) return [];

      // Get the actual games
      return await getGamesByIds(gameIds);
    } catch (e) {
      print('💥 IGDB: Search games by alternative names error: $e');
      return [];
    }
  }

  // Method to get alternative names for specific games (keeps existing simple method)
  @override
  Future<List<String>> getAlternativeNames(List<int> gameIds) async {
    try {
      final alternativeNames = await getAlternativeNamesDetailed(gameIds);
      return alternativeNames.map((altName) => altName.name).toList();
    } catch (e) {
      print('💥 IGDB: Get alternative names error: $e');
      return [];
    }
  }

  // lib/data/datasources/remote/igdb_remote_datasource_impl.dart - Platform Methods
// Diese Methoden gehören in die IGDBRemoteDataSourceImpl Klasse

  // Get Platforms - essential for filters and game data
  Future<List<PlatformModel>> getPlatforms({
    List<int>? ids,
    String? search,
    PlatformCategoryEnum? category,
    bool includeFamilyInfo = false,
  }) async {
    try {
      String body;

      String fields = '''
        id, checksum, abbreviation, alternative_name, category, 
        generation, name, platform_family, platform_logo, 
        platform_type, slug, summary, url, versions, 
        websites, created_at, updated_at
      ''';

      if (includeFamilyInfo) {
        fields += ', platform_family.name, platform_logo.image_id';
      }

      if (ids != null && ids.isNotEmpty) {
        final idsString = ids.join(',');
        body = '''
          where id = ($idsString);
          fields $fields;
          limit ${ids.length};
        ''';
      } else if (search != null) {
        body = '''
          search "$search";
          fields $fields;
          limit 50;
        ''';
      } else if (category != null) {
        body = '''
          where category = ${category.value};
          fields $fields;
          sort name asc;
          limit 100;
        ''';
      } else {
        body = '''
          fields $fields;
          sort name asc;
          limit 200;
        ''';
      }

      final response = await _makeRequestRaw(IGDBEndpoints.platforms, body);
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => PlatformModel.fromJson(json)).toList();
    } catch (e) {
      print('💥 IGDB: Get platforms error: $e');
      return [];
    }
  }

  // Get platforms by category - very useful for filtering
  Future<List<PlatformModel>> getPlatformsByCategory(PlatformCategoryEnum category) async {
    return await getPlatforms(category: category);
  }

  // Get popular/main platforms - for quick access in filters
  Future<List<PlatformModel>> getPopularPlatforms() async {
    try {
      // Get most popular platforms by ID (these are well-known platform IDs)
      final popularIds = [
        6,    // PC (Microsoft Windows)
        48,   // PlayStation 4
        49,   // Xbox One
        167,  // PlayStation 5
        169,  // Xbox Series X/S
        130,  // Nintendo Switch
        37,   // Nintendo 3DS
        38,   // PlayStation Vita
        20,   // Nintendo DS
        21,   // Nintendo GameCube
        5,    // Nintendo Wii
        41,   // Wii U
        19,   // Super Nintendo Entertainment System
        18,   // Nintendo Entertainment System
      ];

      return await getPlatforms(ids: popularIds, includeFamilyInfo: true);
    } catch (e) {
      print('💥 IGDB: Get popular platforms error: $e');
      return [];
    }
  }

  // Get Platform Families
  Future<List<PlatformFamilyModel>> getPlatformFamilies({List<int>? ids}) async {
    try {
      String body;
      if (ids != null && ids.isNotEmpty) {
        final idsString = ids.join(',');
        body = '''
          where id = ($idsString);
          fields id, checksum, name, slug;
          limit ${ids.length};
        ''';
      } else {
        body = '''
          fields id, checksum, name, slug;
          sort name asc;
          limit 100;
        ''';
      }

      final response = await _makeRequestRaw(IGDBEndpoints.platformFamilies, body);
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => PlatformFamilyModel.fromJson(json)).toList();
    } catch (e) {
      print('💥 IGDB: Get platform families error: $e');
      return [];
    }
  }

  // Get Platform Types
  Future<List<PlatformTypeModel>> getPlatformTypes({List<int>? ids}) async {
    try {
      String body;
      if (ids != null && ids.isNotEmpty) {
        final idsString = ids.join(',');
        body = '''
          where id = ($idsString);
          fields id, checksum, name, created_at, updated_at;
          limit ${ids.length};
        ''';
      } else {
        body = '''
          fields id, checksum, name, created_at, updated_at;
          sort name asc;
          limit 100;
        ''';
      }

      final response = await _makeRequestRaw(IGDBEndpoints.platformTypes, body);
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => PlatformTypeModel.fromJson(json)).toList();
    } catch (e) {
      print('💥 IGDB: Get platform types error: $e');
      return [];
    }
  }

  // Get Platform Logos
  Future<List<PlatformLogoModel>> getPlatformLogos(List<int> logoIds) async {
    try {
      if (logoIds.isEmpty) return [];

      final idsString = logoIds.join(',');
      final body = '''
        where id = ($idsString);
        fields id, checksum, alpha_channel, animated, height, 
               image_id, url, width;
        limit ${logoIds.length};
      ''';

      final response = await _makeRequestRaw(IGDBEndpoints.platformLogos, body);
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => PlatformLogoModel.fromJson(json)).toList();
    } catch (e) {
      print('💥 IGDB: Get platform logos error: $e');
      return [];
    }
  }

  // Get complete platform data with related info
  Future<List<Map<String, dynamic>>> getCompletePlatformData({
    List<int>? platformIds,
    PlatformCategoryEnum? category,
  }) async {
    try {
      // 1. Get platforms
      final platforms = await getPlatforms(
        ids: platformIds,
        category: category,
        includeFamilyInfo: true,
      );

      if (platforms.isEmpty) return [];

      // 2. Get all family IDs
      final familyIds = platforms
          .where((platform) => platform.platformFamilyId != null)
          .map((platform) => platform.platformFamilyId!)
          .toSet()
          .toList();

      // 3. Get all logo IDs
      final logoIds = platforms
          .where((platform) => platform.platformLogoId != null)
          .map((platform) => platform.platformLogoId!)
          .toSet()
          .toList();

      // 4. Get all type IDs
      final typeIds = platforms
          .where((platform) => platform.platformTypeId != null)
          .map((platform) => platform.platformTypeId!)
          .toSet()
          .toList();

      // 5. Fetch related data
      final families = familyIds.isNotEmpty
          ? await getPlatformFamilies(ids: familyIds)
          : <PlatformFamilyModel>[];

      final logos = logoIds.isNotEmpty
          ? await getPlatformLogos(logoIds)
          : <PlatformLogoModel>[];

      final types = typeIds.isNotEmpty
          ? await getPlatformTypes(ids: typeIds)
          : <PlatformTypeModel>[];

      // 6. Combine data
      return platforms.map((platform) {
        final family = families.firstWhere(
              (f) => f.id == platform.platformFamilyId,
          orElse: () => const PlatformFamilyModel(
              id: 0,
              checksum: '',
              name: 'Unknown'
          ),
        );

        final logo = logos.firstWhere(
              (l) => l.id == platform.platformLogoId,
          orElse: () => const PlatformLogoModel(
              id: 0,
              checksum: '',
              imageId: '',
              height: 0,
              width: 0
          ),
        );

        final type = types.firstWhere(
              (t) => t.id == platform.platformTypeId,
          orElse: () => const PlatformTypeModel(
              id: 0,
              checksum: '',
              name: 'Unknown'
          ),
        );

        return {
          'platform': platform,
          'family': family,
          'logo': logo,
          'type': type,
        };
      }).toList();
    } catch (e) {
      print('💥 IGDB: Get complete platform data error: $e');
      return [];
    }
  }

  // lib/data/datasources/remote/igdb_remote_datasource_impl.dart - Genre Methods
// Diese Methoden gehören in die IGDBRemoteDataSourceImpl Klasse

  // Get Genres - essential for filters
  Future<List<GenreModel>> getGenres({
    List<int>? ids,
    String? search,
    int limit = 100,
  }) async {
    try {
      String body;

      const fields = '''
        id, checksum, name, slug, url, created_at, updated_at
      ''';

      if (ids != null && ids.isNotEmpty) {
        final idsString = ids.join(',');
        body = '''
          where id = ($idsString);
          fields $fields;
          limit ${ids.length};
        ''';
      } else if (search != null) {
        body = '''
          search "$search";
          fields $fields;
          limit $limit;
        ''';
      } else {
        body = '''
          fields $fields;
          sort name asc;
          limit $limit;
        ''';
      }

      final response = await _makeRequestRaw(IGDBEndpoints.genres, body);
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => GenreModel.fromJson(json)).toList();
    } catch (e) {
      print('💥 IGDB: Get genres error: $e');
      return [];
    }
  }

  // Get popular/main genres - for quick access in filters
  Future<List<GenreModel>> getPopularGenres() async {
    try {
      // Popular genre IDs based on common gaming genres
      final popularIds = [
        4,    // Fighting
        5,    // Shooter
        7,    // Music
        8,    // Platform
        9,    // Puzzle
        10,   // Racing
        11,   // Real Time Strategy (RTS)
        12,   // Role-playing (RPG)
        13,   // Simulator
        14,   // Sport
        15,   // Strategy
        16,   // Turn-based strategy (TBS)
        24,   // Tactical
        25,   // Hack and slash/Beat 'em up
        26,   // Quiz/Trivia
        30,   // Pinball
        31,   // Adventure
        32,   // Indie
        33,   // Arcade
        34,   // Visual Novel
        35,   // Card & Board Game
        36,   // MOBA
        37,   // Point-and-click
      ];

      return await getGenres(ids: popularIds);
    } catch (e) {
      print('💥 IGDB: Get popular genres error: $e');
      return [];
    }
  }

  // Get top gaming genres - most commonly used
  Future<List<GenreModel>> getTopGenres() async {
    try {
      // The most popular gaming genres that users filter by
      final topIds = [
        31,   // Adventure
        12,   // Role-playing (RPG)
        5,    // Shooter
        15,   // Strategy
        8,    // Platform
        9,    // Puzzle
        14,   // Sport
        10,   // Racing
        4,    // Fighting
        13,   // Simulator
        32,   // Indie
        11,   // Real Time Strategy (RTS)
      ];

      return await getGenres(ids: topIds);
    } catch (e) {
      print('💥 IGDB: Get top genres error: $e');
      return [];
    }
  }

  // Search genres by name
  Future<List<GenreModel>> searchGenres(String query) async {
    return await getGenres(search: query, limit: 50);
  }

  // Get all genres - for complete filter dropdown
  Future<List<GenreModel>> getAllGenres() async {
    return await getGenres(limit: 200);
  }

  // Get genres with game count (enhanced method)
  Future<List<Map<String, dynamic>>> getGenresWithGameCount({
    List<int>? genreIds,
    int limit = 50,
  }) async {
    try {
      // 1. Get genres
      final genres = genreIds != null
          ? await getGenres(ids: genreIds)
          : await getTopGenres();

      if (genres.isEmpty) return [];

      // 2. For each genre, get a count of games (simplified approach)
      List<Map<String, dynamic>> genresWithCount = [];

      for (final genre in genres.take(limit)) {
        try {
          // Get sample games for this genre to estimate popularity
          final sampleBody = '''
            where genres = [${genre.id}] & category = 0;
            fields id;
            limit 500;
          ''';

          final sampleResponse = await _makeRequestRaw(IGDBEndpoints.games, sampleBody);
          final sampleData = json.decode(sampleResponse.body) as List;

          genresWithCount.add({
            'genre': genre,
            'game_count': sampleData.length,
            'is_popular': sampleData.length >= 100,
          });
        } catch (e) {
          // If individual genre fails, add with unknown count
          genresWithCount.add({
            'genre': genre,
            'game_count': 0,
            'is_popular': false,
          });
        }
      }

      // Sort by game count (most popular first)
      genresWithCount.sort((a, b) =>
          (b['game_count'] as int).compareTo(a['game_count'] as int));

      return genresWithCount;
    } catch (e) {
      print('💥 IGDB: Get genres with game count error: $e');
      return [];
    }
  }

  // Helper method to get genre by name
  Future<GenreModel?> getGenreByName(String name) async {
    try {
      final genres = await searchGenres(name);
      return genres.isNotEmpty ? genres.first : null;
    } catch (e) {
      print('💥 IGDB: Get genre by name error: $e');
      return null;
    }
  }

  // lib/data/datasources/remote/igdb_remote_datasource_impl.dart - Theme & Game Mode Methods
// Diese Methoden gehören in die IGDBRemoteDataSourceImpl Klasse

  // THEME METHODS
  Future<List<ThemeModel>> getThemes({
    List<int>? ids,
    String? search,
    int limit = 100,
  }) async {
    try {
      String body;

      const fields = '''
        id, checksum, name, slug, url, created_at, updated_at
      ''';

      if (ids != null && ids.isNotEmpty) {
        final idsString = ids.join(',');
        body = '''
          where id = ($idsString);
          fields $fields;
          limit ${ids.length};
        ''';
      } else if (search != null) {
        body = '''
          search "$search";
          fields $fields;
          limit $limit;
        ''';
      } else {
        body = '''
          fields $fields;
          sort name asc;
          limit $limit;
        ''';
      }

      final response = await _makeRequestRaw(IGDBEndpoints.themes, body);
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => ThemeModel.fromJson(json)).toList();
    } catch (e) {
      print('💥 IGDB: Get themes error: $e');
      return [];
    }
  }

  // Get popular themes
  Future<List<ThemeModel>> getPopularThemes() async {
    try {
      // Popular theme IDs based on common game themes
      final popularIds = [
        1,    // Action
        17,   // Fantasy
        18,   // Science fiction
        19,   // Horror
        20,   // Thriller
        21,   // Survival
        22,   // Historical
        23,   // Stealth
        27,   // Romance
        28,   // Non-fiction
        31,   // Drama
        32,   // Mystery
        33,   // Sandbox
        34,   // Educational
        35,   // Kids
        38,   // Open world
        39,   // Warfare
        40,   // Party
        41,   // Erotic
        42,   // Comedy
        43,   // Business
        44,   // 4X (explore, expand, exploit, exterminate)
      ];

      return await getThemes(ids: popularIds);
    } catch (e) {
      print('💥 IGDB: Get popular themes error: $e');
      return [];
    }
  }

  // Search themes by name
  Future<List<ThemeModel>> searchThemes(String query) async {
    return await getThemes(search: query, limit: 50);
  }

  // Get all themes
  Future<List<ThemeModel>> getAllThemes() async {
    return await getThemes(limit: 200);
  }

  // GAME MODE METHODS
  Future<List<GameModeModel>> getGameModes({
    List<int>? ids,
    String? search,
    int limit = 50,
  }) async {
    try {
      String body;

      const fields = '''
        id, checksum, name, slug, url, created_at, updated_at
      ''';

      if (ids != null && ids.isNotEmpty) {
        final idsString = ids.join(',');
        body = '''
          where id = ($idsString);
          fields $fields;
          limit ${ids.length};
        ''';
      } else if (search != null) {
        body = '''
          search "$search";
          fields $fields;
          limit $limit;
        ''';
      } else {
        body = '''
          fields $fields;
          sort name asc;
          limit $limit;
        ''';
      }

      final response = await _makeRequestRaw(IGDBEndpoints.gameModes, body);
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => GameModeModel.fromJson(json)).toList();
    } catch (e) {
      print('💥 IGDB: Get game modes error: $e');
      return [];
    }
  }

  // Get popular game modes
  Future<List<GameModeModel>> getPopularGameModes() async {
    try {
      // Popular game mode IDs (most common ones)
      final popularIds = [
        1,    // Single player
        2,    // Multiplayer
        3,    // Co-operative
        4,    // Split screen
        5,    // Massively Multiplayer Online (MMO)
        6,    // Battle Royale
      ];

      return await getGameModes(ids: popularIds);
    } catch (e) {
      print('💥 IGDB: Get popular game modes error: $e');
      return [];
    }
  }

  // Search game modes by name
  Future<List<GameModeModel>> searchGameModes(String query) async {
    return await getGameModes(search: query, limit: 20);
  }

  // Get all game modes
  Future<List<GameModeModel>> getAllGameModes() async {
    return await getGameModes(limit: 50);
  }

  // Helper method to get theme by name
  Future<ThemeModel?> getThemeByName(String name) async {
    try {
      final themes = await searchThemes(name);
      return themes.isNotEmpty ? themes.first : null;
    } catch (e) {
      print('💥 IGDB: Get theme by name error: $e');
      return null;
    }
  }

  // Helper method to get game mode by name
  Future<GameModeModel?> getGameModeByName(String name) async {
    try {
      final gameModes = await searchGameModes(name);
      return gameModes.isNotEmpty ? gameModes.first : null;
    } catch (e) {
      print('💥 IGDB: Get game mode by name error: $e');
      return null;
    }
  }

  // lib/data/datasources/remote/igdb_remote_datasource_impl.dart - Keyword Methods
// Diese Methoden gehören in die IGDBRemoteDataSourceImpl Klasse

  // KEYWORD METHODS
  Future<List<KeywordModel>> getKeywords({
    List<int>? ids,
    String? search,
    int limit = 100,
  }) async {
    try {
      String body;

      const fields = '''
        id, checksum, name, slug, url, created_at, updated_at
      ''';

      if (ids != null && ids.isNotEmpty) {
        final idsString = ids.join(',');
        body = '''
          where id = ($idsString);
          fields $fields;
          limit ${ids.length};
        ''';
      } else if (search != null) {
        body = '''
          search "$search";
          fields $fields;
          limit $limit;
        ''';
      } else {
        body = '''
          fields $fields;
          sort name asc;
          limit $limit;
        ''';
      }

      final response = await _makeRequestRaw(IGDBEndpoints.keywords, body);
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => KeywordModel.fromJson(json)).toList();
    } catch (e) {
      print('💥 IGDB: Get keywords error: $e');
      return [];
    }
  }

  // Search keywords by name - very useful for dynamic search
  Future<List<KeywordModel>> searchKeywords(String query) async {
    return await getKeywords(search: query);
  }

  // Get trending/popular keywords based on common gaming terms
  Future<List<KeywordModel>> getTrendingKeywords() async {
    try {
      // Search for popular gaming keywords
      final popularTerms = [
        'open world',
        'battle royale',
        'multiplayer',
        'co-op',
        'rpg',
        'indie',
        'pixel art',
        'retro',
        'hardcore',
        'casual',
        'story rich',
        'atmospheric',
        'dark',
        'funny',
        'difficult',
        'exploration',
        'crafting',
        'survival',
        'building',
        'management',
      ];

      List<KeywordModel> trendingKeywords = [];

      // Search for each term and collect results
      for (final term in popularTerms.take(10)) { // Limit to avoid too many requests
        final keywords = await searchKeywords(term);
        if (keywords.isNotEmpty) {
          trendingKeywords.addAll(keywords.take(2)); // Take top 2 for each term
        }
      }

      // Remove duplicates based on ID
      final uniqueKeywords = <int, KeywordModel>{};
      for (final keyword in trendingKeywords) {
        uniqueKeywords[keyword.id] = keyword;
      }

      return uniqueKeywords.values.toList()..sort((a, b) => a.name.compareTo(b.name));
    } catch (e) {
      print('💥 IGDB: Get trending keywords error: $e');
      return [];
    }
  }

  // Get keywords for specific games - useful for game detail pages
  Future<List<KeywordModel>> getKeywordsForGames(List<int> gameIds) async {
    try {
      if (gameIds.isEmpty) return [];

      // First, get games with their keyword IDs
      final idsString = gameIds.join(',');
      final gamesBody = '''
        where id = ($idsString);
        fields keywords;
        limit ${gameIds.length};
      ''';

      final gamesResponse = await _makeRequestRaw(IGDBEndpoints.games, gamesBody);
      final List<dynamic> gamesData = json.decode(gamesResponse.body);

      // Extract all keyword IDs
      Set<int> keywordIds = {};
      for (final game in gamesData) {
        if (game['keywords'] is List) {
          for (final keywordData in game['keywords']) {
            if (keywordData is int) {
              keywordIds.add(keywordData);
            } else if (keywordData is Map && keywordData['id'] is int) {
              keywordIds.add(keywordData['id']);
            }
          }
        }
      }

      if (keywordIds.isEmpty) return [];

      // Get the actual keyword data
      return await getKeywords(ids: keywordIds.toList());
    } catch (e) {
      print('💥 IGDB: Get keywords for games error: $e');
      return [];
    }
  }

  // Find similar keywords - useful for suggestions
  Future<List<KeywordModel>> getSimilarKeywords(String keywordName) async {
    try {
      // Search for keywords that contain similar words
      final searchTerms = keywordName.toLowerCase().split(' ');
      Set<KeywordModel> similarKeywords = {};

      for (final term in searchTerms) {
        if (term.length >= 3) { // Only search for meaningful terms
          final keywords = await searchKeywords(term);
          similarKeywords.addAll(keywords);
        }
      }

      // Remove the exact match and return up to 10 similar ones
      final result = similarKeywords
          .where((k) => k.name.toLowerCase() != keywordName.toLowerCase())
          .take(10)
          .toList();

      result.sort((a, b) => a.name.compareTo(b.name));
      return result;
    } catch (e) {
      print('💥 IGDB: Get similar keywords error: $e');
      return [];
    }
  }

  // Get top keywords by category/theme
  Future<List<KeywordModel>> getKeywordsByCategory(String category) async {
    try {
      final categoryKeywords = <String, List<String>>{
        'gameplay': ['turn-based', 'real-time', 'point-and-click', 'hack-and-slash', 'tower-defense'],
        'setting': ['post-apocalyptic', 'medieval', 'cyberpunk', 'western', 'steampunk'],
        'mood': ['dark', 'atmospheric', 'funny', 'relaxing', 'intense'],
        'mechanics': ['crafting', 'building', 'exploration', 'management', 'survival'],
        'style': ['pixel-art', 'hand-drawn', '3d', 'retro', 'minimalist'],
      };

      final searchTerms = categoryKeywords[category.toLowerCase()] ?? [];
      if (searchTerms.isEmpty) return [];

      List<KeywordModel> categoryKeywords = [];
      for (final term in searchTerms) {
        final keywords = await searchKeywords(term);
        categoryKeywords.addAll(keywords.take(3)); // Take top 3 for each term
      }

      // Remove duplicates and sort
      final uniqueKeywords = <int, KeywordModel>{};
      for (final keyword in categoryKeywords) {
        uniqueKeywords[keyword.id] = keyword;
      }

      final result = uniqueKeywords.values.toList();
      result.sort((a, b) => a.name.compareTo(b.name));
      return result;
    } catch (e) {
      print('💥 IGDB: Get keywords by category error: $e');
      return [];
    }
  }

  // Helper method to get keyword by name
  Future<KeywordModel?> getKeywordByName(String name) async {
    try {
      final keywords = await searchKeywords(name);
      return keywords.isNotEmpty ? keywords.first : null;
    } catch (e) {
      print('💥 IGDB: Get keyword by name error: $e');
      return null;
    }
  }

  // Get random keywords for discovery
  Future<List<KeywordModel>> getRandomKeywords({int limit = 20}) async {
    try {
      // Get a broader set and then randomly select
      final allKeywords = await getKeywords(limit: limit * 3);
      if (allKeywords.isEmpty) return [];

      allKeywords.shuffle();
      return allKeywords.take(limit).toList();
    } catch (e) {
      print('💥 IGDB: Get random keywords error: $e');
      return [];
    }
  }

  // Advanced search: Get games by multiple keywords
  Future<List<GameModel>> searchGamesByKeywords(List<String> keywordNames) async {
    try {
      if (keywordNames.isEmpty) return [];

      // First, find the keyword IDs
      List<int> keywordIds = [];
      for (final keywordName in keywordNames) {
        final keyword = await getKeywordByName(keywordName);
        if (keyword != null) {
          keywordIds.add(keyword.id);
        }
      }

      if (keywordIds.isEmpty) return [];

      // Search for games that have any of these keywords
      final keywordFilter = keywordIds.join(',');
      final body = '''
        where keywords = [$keywordFilter] & category = 0;
        fields id, name, summary, cover.url, total_rating, 
               genres.name, platforms.abbreviation, keywords.name;
        sort total_rating desc;
        limit 50;
      ''';

      return await _makeRequest(IGDBEndpoints.games, body);
    } catch (e) {
      print('💥 IGDB: Search games by keywords error: $e');
      return [];
    }
  }

  // lib/data/datasources/remote/igdb_remote_datasource_impl.dart - Character Methods
// Diese Methoden gehören in die IGDBRemoteDataSourceImpl Klasse

  // CHARACTER METHODS
  Future<List<CharacterModel>> getCharacters({
    List<int>? ids,
    String? search,
    int limit = 50,
  }) async {
    try {
      String body;

      const fields = '''
        id, checksum, name, akas, character_gender, character_species,
        country_name, description, games, mug_shot, slug, url,
        created_at, updated_at, gender, species
      ''';

      if (ids != null && ids.isNotEmpty) {
        final idsString = ids.join(',');
        body = '''
          where id = ($idsString);
          fields $fields;
          limit ${ids.length};
        ''';
      } else if (search != null) {
        body = '''
          search "$search";
          fields $fields;
          limit $limit;
        ''';
      } else {
        body = '''
          fields $fields;
          sort name asc;
          limit $limit;
        ''';
      }

      final response = await _makeRequestRaw(IGDBEndpoints.characters, body);
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => CharacterModel.fromJson(json)).toList();
    } catch (e) {
      print('💥 IGDB: Get characters error: $e');
      return [];
    }
  }

  // Search characters by name
  Future<List<CharacterModel>> searchCharacters(String query) async {
    return await getCharacters(search: query, limit: 50);
  }

  // Get characters for specific games
  Future<List<CharacterModel>> getCharactersForGames(List<int> gameIds) async {
    try {
      if (gameIds.isEmpty) return [];

      final idsString = gameIds.join(',');
      final body = '''
        where games = [$idsString];
        fields id, checksum, name, akas, character_gender, character_species,
               country_name, description, games, mug_shot, slug, url,
               created_at, updated_at, gender, species;
        limit 100;
      ''';

      final response = await _makeRequestRaw(IGDBEndpoints.characters, body);
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => CharacterModel.fromJson(json)).toList();
    } catch (e) {
      print('💥 IGDB: Get characters for games error: $e');
      return [];
    }
  }

  // Get popular characters (those with the most games)
  Future<List<CharacterModel>> getPopularCharacters({int limit = 20}) async {
    try {
      // Get characters that appear in multiple games (popular ones)
      final body = '''
        where games != null;
        fields id, checksum, name, akas, character_gender, character_species,
               country_name, description, games, mug_shot, slug, url,
               created_at, updated_at, gender, species;
        sort name asc;
        limit $limit;
      ''';

      final response = await _makeRequestRaw(IGDBEndpoints.characters, body);
      final List<dynamic> data = json.decode(response.body);
      final characters = data.map((json) => CharacterModel.fromJson(json)).toList();

      // Sort by number of games (popularity indicator)
      characters.sort((a, b) => b.gameIds.length.compareTo(a.gameIds.length));
      return characters.take(limit).toList();
    } catch (e) {
      print('💥 IGDB: Get popular characters error: $e');
      return [];
    }
  }

  // Get characters by gender
  Future<List<CharacterModel>> getCharactersByGender(CharacterGenderEnum gender) async {
    try {
      final body = '''
        where gender = ${gender.value};
        fields id, checksum, name, akas, character_gender, character_species,
               country_name, description, games, mug_shot, slug, url,
               created_at, updated_at, gender, species;
        sort name asc;
        limit 100;
      ''';

      final response = await _makeRequestRaw(IGDBEndpoints.characters, body);
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => CharacterModel.fromJson(json)).toList();
    } catch (e) {
      print('💥 IGDB: Get characters by gender error: $e');
      return [];
    }
  }

  // Get characters by species
  Future<List<CharacterModel>> getCharactersBySpecies(CharacterSpeciesEnum species) async {
    try {
      final body = '''
        where species = ${species.value};
        fields id, checksum, name, akas, character_gender, character_species,
               country_name, description, games, mug_shot, slug, url,
               created_at, updated_at, gender, species;
        sort name asc;
        limit 100;
      ''';

      final response = await _makeRequestRaw(IGDBEndpoints.characters, body);
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => CharacterModel.fromJson(json)).toList();
    } catch (e) {
      print('💥 IGDB: Get characters by species error: $e');
      return [];
    }
  }

  // Get Character Genders
  Future<List<CharacterGenderModel>> getCharacterGenders({List<int>? ids}) async {
    try {
      String body;
      if (ids != null && ids.isNotEmpty) {
        final idsString = ids.join(',');
        body = '''
          where id = ($idsString);
          fields id, checksum, name, created_at, updated_at;
          limit ${ids.length};
        ''';
      } else {
        body = '''
          fields id, checksum, name, created_at, updated_at;
          sort name asc;
          limit 20;
        ''';
      }

      final response = await _makeRequestRaw(IGDBEndpoints.characterGenders, body);
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => CharacterGenderModel.fromJson(json)).toList();
    } catch (e) {
      print('💥 IGDB: Get character genders error: $e');
      return [];
    }
  }

  // Get Character Species
  Future<List<CharacterSpeciesModel>> getCharacterSpecies({List<int>? ids}) async {
    try {
      String body;
      if (ids != null && ids.isNotEmpty) {
        final idsString = ids.join(',');
        body = '''
          where id = ($idsString);
          fields id, checksum, name, created_at, updated_at;
          limit ${ids.length};
        ''';
      } else {
        body = '''
          fields id, checksum, name, created_at, updated_at;
          sort name asc;
          limit 20;
        ''';
      }

      final response = await _makeRequestRaw(IGDBEndpoints.characterSpecies, body);
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => CharacterSpeciesModel.fromJson(json)).toList();
    } catch (e) {
      print('💥 IGDB: Get character species error: $e');
      return [];
    }
  }

  // Get Character Mug Shots
  Future<List<CharacterMugShotModel>> getCharacterMugShots(List<int> mugShotIds) async {
    try {
      if (mugShotIds.isEmpty) return [];

      final idsString = mugShotIds.join(',');
      final body = '''
        where id = ($idsString);
        fields id, checksum, alpha_channel, animated, height, 
               image_id, url, width;
        limit ${mugShotIds.length};
      ''';

      final response = await _makeRequestRaw(IGDBEndpoints.characterMugShots, body);
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => CharacterMugShotModel.fromJson(json)).toList();
    } catch (e) {
      print('💥 IGDB: Get character mug shots error: $e');
      return [];
    }
  }

  // Get complete character data with related info
  Future<List<Map<String, dynamic>>> getCompleteCharacterData({
    List<int>? characterIds,
    String? search,
    int limit = 20,
  }) async {
    try {
      // 1. Get characters
      final characters = characterIds != null
          ? await getCharacters(ids: characterIds)
          : search != null
          ? await searchCharacters(search)
          : await getPopularCharacters(limit: limit);

      if (characters.isEmpty) return [];

      // 2. Get all gender IDs
      final genderIds = characters
          .where((char) => char.characterGenderId != null)
          .map((char) => char.characterGenderId!)
          .toSet()
          .toList();

      // 3. Get all species IDs
      final speciesIds = characters
          .where((char) => char.characterSpeciesId != null)
          .map((char) => char.characterSpeciesId!)
          .toSet()
          .toList();

      // 4. Get all mug shot IDs
      final mugShotIds = characters
          .where((char) => char.mugShotId != null)
          .map((char) => char.mugShotId!)
          .toSet()
          .toList();

      // 5. Fetch related data
      final genders = genderIds.isNotEmpty
          ? await getCharacterGenders(ids: genderIds)
          : <CharacterGenderModel>[];

      final species = speciesIds.isNotEmpty
          ? await getCharacterSpecies(ids: speciesIds)
          : <CharacterSpeciesModel>[];

      final mugShots = mugShotIds.isNotEmpty
          ? await getCharacterMugShots(mugShotIds)
          : <CharacterMugShotModel>[];

      // 6. Combine data
      return characters.map((character) {
        final gender = genders.firstWhere(
              (g) => g.id == character.characterGenderId,
          orElse: () => const CharacterGenderModel(
              id: 0,
              checksum: '',
              name: 'Unknown'
          ),
        );

        final characterSpecies = species.firstWhere(
              (s) => s.id == character.characterSpeciesId,
          orElse: () => const CharacterSpeciesModel(
              id: 0,
              checksum: '',
              name: 'Unknown'
          ),
        );

        final mugShot = mugShots.firstWhere(
              (m) => m.id == character.mugShotId,
          orElse: () => const CharacterMugShotModel(
              id: 0,
              checksum: '',
              imageId: '',
              height: 0,
              width: 0
          ),
        );

        return {
          'character': character,
          'gender': gender,
          'species': characterSpecies,
          'mug_shot': mugShot,
        };
      }).toList();
    } catch (e) {
      print('💥 IGDB: Get complete character data error: $e');
      return [];
    }
  }

  // Helper method to get character by name
  Future<CharacterModel?> getCharacterByName(String name) async {
    try {
      final characters = await searchCharacters(name);
      return characters.isNotEmpty ? characters.first : null;
    } catch (e) {
      print('💥 IGDB: Get character by name error: $e');
      return null;
    }
  }

  // Get random characters for discovery
  Future<List<CharacterModel>> getRandomCharacters({int limit = 10}) async {
    try {
      final allCharacters = await getCharacters(limit: limit * 3);
      if (allCharacters.isEmpty) return [];

      allCharacters.shuffle();
      return allCharacters.take(limit).toList();
    } catch (e) {
      print('💥 IGDB: Get random characters error: $e');
      return [];
    }
  }

  // lib/data/datasources/remote/igdb_remote_datasource_impl.dart - External Game Methods
// Diese Methoden gehören in die IGDBRemoteDataSourceImpl Klasse

  // EXTERNAL GAME METHODS
  Future<List<ExternalGameModel>> getExternalGames(List<int> gameIds) async {
    try {
      if (gameIds.isEmpty) return [];

      final idsString = gameIds.join(',');
      final body = '''
        where game = ($idsString);
        fields id, checksum, countries, external_game_source, game,
               game_release_format, name, platform, uid, url, year,
               created_at, updated_at, category, media;
        limit 500;
      ''';

      final response = await _makeRequestRaw(IGDBEndpoints.externalGames, body);
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => ExternalGameModel.fromJson(json)).toList();
    } catch (e) {
      print('💥 IGDB: Get external games error: $e');
      return [];
    }
  }

  // Get external games by store/platform
  Future<List<ExternalGameModel>> getExternalGamesByStore(
      ExternalGameCategoryEnum store, {
        int limit = 100,
      }) async {
    try {
      final body = '''
        where category = ${store.value};
        fields id, checksum, countries, external_game_source, game,
               game_release_format, name, platform, uid, url, year,
               created_at, updated_at, category, media;
        sort name asc;
        limit $limit;
      ''';

      final response = await _makeRequestRaw(IGDBEndpoints.externalGames, body);
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => ExternalGameModel.fromJson(json)).toList();
    } catch (e) {
      print('💥 IGDB: Get external games by store error: $e');
      return [];
    }
  }

  // Get store links for specific games - very useful!
  Future<Map<int, List<ExternalGameModel>>> getStoreLinksForGames(
      List<int> gameIds, {
        List<ExternalGameCategoryEnum>? preferredStores,
      }) async {
    try {
      final externalGames = await getExternalGames(gameIds);

      // Group by game ID
      final Map<int, List<ExternalGameModel>> gameStoreLinks = {};

      for (final externalGame in externalGames) {
        if (externalGame.gameId != null) {
          gameStoreLinks.putIfAbsent(externalGame.gameId!, () => []);
          gameStoreLinks[externalGame.gameId!]!.add(externalGame);
        }
      }

      // Filter and sort by preferred stores if specified
      if (preferredStores != null && preferredStores.isNotEmpty) {
        for (final gameId in gameStoreLinks.keys) {
          final links = gameStoreLinks[gameId]!;

          // Sort by preference
          links.sort((a, b) {
            final aIndex = a.categoryEnum != null
                ? preferredStores.indexOf(a.categoryEnum!)
                : -1;
            final bIndex = b.categoryEnum != null
                ? preferredStores.indexOf(b.categoryEnum!)
                : -1;

            if (aIndex == -1 && bIndex == -1) return 0;
            if (aIndex == -1) return 1;
            if (bIndex == -1) return -1;
            return aIndex.compareTo(bIndex);
          });
        }
      }

      return gameStoreLinks;
    } catch (e) {
      print('💥 IGDB: Get store links for games error: $e');
      return {};
    }
  }

  // Get main store links only (Steam, GOG, Epic, etc.)
  Future<List<ExternalGameModel>> getMainStoreLinks(List<int> gameIds) async {
    try {
      final allLinks = await getExternalGames(gameIds);
      return allLinks.where((link) => link.isMainStore).toList();
    } catch (e) {
      print('💥 IGDB: Get main store links error: $e');
      return [];
    }
  }

  // Get Steam links specifically
  Future<List<ExternalGameModel>> getSteamLinks(List<int> gameIds) async {
    try {
      final allLinks = await getExternalGames(gameIds);
      return allLinks
          .where((link) => link.categoryEnum == ExternalGameCategoryEnum.steam)
          .toList();
    } catch (e) {
      print('💥 IGDB: Get Steam links error: $e');
      return [];
    }
  }

  // Get digital vs physical distribution
  Future<Map<String, List<ExternalGameModel>>> getExternalGamesByMedia(
      List<int> gameIds
      ) async {
    try {
      final externalGames = await getExternalGames(gameIds);

      final Map<String, List<ExternalGameModel>> mediaGroups = {
        'digital': [],
        'physical': [],
        'unknown': [],
      };

      for (final game in externalGames) {
        if (game.isDigital) {
          mediaGroups['digital']!.add(game);
        } else if (game.isPhysical) {
          mediaGroups['physical']!.add(game);
        } else {
          mediaGroups['unknown']!.add(game);
        }
      }

      return mediaGroups;
    } catch (e) {
      print('💥 IGDB: Get external games by media error: $e');
      return {'digital': [], 'physical': [], 'unknown': []};
    }
  }

  // Get External Game Sources
  Future<List<ExternalGameSourceModel>> getExternalGameSources({
    List<int>? ids,
  }) async {
    try {
      String body;
      if (ids != null && ids.isNotEmpty) {
        final idsString = ids.join(',');
        body = '''
          where id = ($idsString);
          fields id, checksum, name, created_at, updated_at;
          limit ${ids.length};
        ''';
      } else {
        body = '''
          fields id, checksum, name, created_at, updated_at;
          sort name asc;
          limit 100;
        ''';
      }

      final response = await _makeRequestRaw(IGDBEndpoints.externalGameSources, body);
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => ExternalGameSourceModel.fromJson(json)).toList();
    } catch (e) {
      print('💥 IGDB: Get external game sources error: $e');
      return [];
    }
  }

  // Get Game Release Formats
  Future<List<GameReleaseFormatModel>> getGameReleaseFormats({
    List<int>? ids,
  }) async {
    try {
      String body;
      if (ids != null && ids.isNotEmpty) {
        final idsString = ids.join(',');
        body = '''
          where id = ($idsString);
          fields id, checksum, format, created_at, updated_at;
          limit ${ids.length};
        ''';
      } else {
        body = '''
          fields id, checksum, format, created_at, updated_at;
          sort format asc;
          limit 100;
        ''';
      }

      final response = await _makeRequestRaw(IGDBEndpoints.gameReleaseFormats, body);
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => GameReleaseFormatModel.fromJson(json)).toList();
    } catch (e) {
      print('💥 IGDB: Get game release formats error: $e');
      return [];
    }
  }

  // Get complete external game data with related info
  Future<List<Map<String, dynamic>>> getCompleteExternalGameData(
      List<int> gameIds
      ) async {
    try {
      // 1. Get external games
      final externalGames = await getExternalGames(gameIds);
      if (externalGames.isEmpty) return [];

      // 2. Get all source IDs
      final sourceIds = externalGames
          .where((eg) => eg.externalGameSourceId != null)
          .map((eg) => eg.externalGameSourceId!)
          .toSet()
          .toList();

      // 3. Get all release format IDs
      final formatIds = externalGames
          .where((eg) => eg.gameReleaseFormatId != null)
          .map((eg) => eg.gameReleaseFormatId!)
          .toSet()
          .toList();

      // 4. Fetch related data
      final sources = sourceIds.isNotEmpty
          ? await getExternalGameSources(ids: sourceIds)
          : <ExternalGameSourceModel>[];

      final formats = formatIds.isNotEmpty
          ? await getGameReleaseFormats(ids: formatIds)
          : <GameReleaseFormatModel>[];

      // 5. Combine data
      return externalGames.map((externalGame) {
        final source = sources.firstWhere(
              (s) => s.id == externalGame.externalGameSourceId,
          orElse: () => const ExternalGameSourceModel(
              id: 0,
              checksum: '',
              name: 'Unknown'
          ),
        );

        final format = formats.firstWhere(
              (f) => f.id == externalGame.gameReleaseFormatId,
          orElse: () => const GameReleaseFormatModel(
              id: 0,
              checksum: '',
              format: 'Unknown'
          ),
        );

        return {
          'external_game': externalGame,
          'source': source,
          'format': format,
        };
      }).toList();
    } catch (e) {
      print('💥 IGDB: Get complete external game data error: $e');
      return [];
    }
  }

  // Helper method to get best store link for a game
  Future<ExternalGameModel?> getBestStoreLink(
      int gameId, {
        List<ExternalGameCategoryEnum>? preferredStores,
      }) async {
    try {
      final storeLinks = await getStoreLinksForGames([gameId],
          preferredStores: preferredStores);

      final gameLinks = storeLinks[gameId];
      if (gameLinks == null || gameLinks.isEmpty) return null;

      // Return the first (most preferred) link
      return gameLinks.first;
    } catch (e) {
      print('💥 IGDB: Get best store link error: $e');
      return null;
    }
  }

  // Search external games by UID (useful for finding specific store entries)
  Future<List<ExternalGameModel>> searchExternalGamesByUid(String uid) async {
    try {
      final body = '''
        where uid ~ "*$uid*";
        fields id, checksum, countries, external_game_source, game,
               game_release_format, name, platform, uid, url, year,
               created_at, updated_at, category, media;
        limit 50;
      ''';

      final response = await _makeRequestRaw(IGDBEndpoints.externalGames, body);
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => ExternalGameModel.fromJson(json)).toList();
    } catch (e) {
      print('💥 IGDB: Search external games by UID error: $e');
      return [];
    }
  }

  // Get popular stores (based on number of games)
  Future<List<Map<String, dynamic>>> getPopularStores() async {
    try {
      final storeStats = <ExternalGameCategoryEnum, int>{};

      // Count games for each main store
      for (final store in ExternalGameCategoryEnum.values) {
        if (store.isMainStore) {
          final games = await getExternalGamesByStore(store, limit: 1000);
          storeStats[store] = games.length;
        }
      }

      // Sort by popularity
      final sortedStores = storeStats.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      return sortedStores.map((entry) => {
        'store': entry.key,
        'game_count': entry.value,
        'display_name': entry.key.displayName,
        'icon': entry.key.iconName,
      }).toList();
    } catch (e) {
      print('💥 IGDB: Get popular stores error: $e');
      return [];
    }
  }

  // lib/data/datasources/remote/igdb_remote_datasource_impl.dart - Collection Methods
// Diese Methoden gehören in die IGDBRemoteDataSourceImpl Klasse

  // COLLECTION METHODS
  Future<List<CollectionModel>> getCollections({
    List<int>? ids,
    String? search,
    int limit = 100,
  }) async {
    try {
      String body;

      const fields = '''
        id, checksum, name, slug, url, as_child_relations, 
        as_parent_relations, games, type, created_at, updated_at
      ''';

      if (ids != null && ids.isNotEmpty) {
        final idsString = ids.join(',');
        body = '''
          where id = ($idsString);
          fields $fields;
          limit ${ids.length};
        ''';
      } else if (search != null) {
        body = '''
          search "$search";
          fields $fields;
          limit $limit;
        ''';
      } else {
        body = '''
          fields $fields;
          sort name asc;
          limit $limit;
        ''';
      }

      final response = await _makeRequestRaw(IGDBEndpoints.collections, body);
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => CollectionModel.fromJson(json)).toList();
    } catch (e) {
      print('💥 IGDB: Get collections error: $e');
      return [];
    }
  }

  // Search collections by name
  Future<List<CollectionModel>> searchCollections(String query) async {
    return await getCollections(search: query, limit: 50);
  }

  // Get collections for specific games
  Future<List<CollectionModel>> getCollectionsForGames(List<int> gameIds) async {
    try {
      if (gameIds.isEmpty) return [];

      final idsString = gameIds.join(',');
      final body = '''
        where games = [$idsString];
        fields id, checksum, name, slug, url, as_child_relations, 
               as_parent_relations, games, type, created_at, updated_at;
        limit 200;
      ''';

      final response = await _makeRequestRaw(IGDBEndpoints.collections, body);
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => CollectionModel.fromJson(json)).toList();
    } catch (e) {
      print('💥 IGDB: Get collections for games error: $e');
      return [];
    }
  }

  // Get popular collections (those with the most games)
  Future<List<CollectionModel>> getPopularCollections({int limit = 20}) async {
    try {
      final collections = await getCollections(limit: limit * 2);

      // Sort by number of games (popularity indicator)
      collections.sort((a, b) => b.gameCount.compareTo(a.gameCount));
      return collections.take(limit).toList();
    } catch (e) {
      print('💥 IGDB: Get popular collections error: $e');
      return [];
    }
  }

  // Get collections by type
  Future<List<CollectionModel>> getCollectionsByType(int typeId) async {
    try {
      final body = '''
        where type = $typeId;
        fields id, checksum, name, slug, url, as_child_relations, 
               as_parent_relations, games, type, created_at, updated_at;
        sort name asc;
        limit 100;
      ''';

      final response = await _makeRequestRaw(IGDBEndpoints.collections, body);
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => CollectionModel.fromJson(json)).toList();
    } catch (e) {
      print('💥 IGDB: Get collections by type error: $e');
      return [];
    }
  }

  // Get parent collections (collections that have child relations)
  Future<List<CollectionModel>> getParentCollections({int limit = 50}) async {
    try {
      final body = '''
        where as_child_relations != null;
        fields id, checksum, name, slug, url, as_child_relations, 
               as_parent_relations, games, type, created_at, updated_at;
        sort name asc;
        limit $limit;
      ''';

      final response = await _makeRequestRaw(IGDBEndpoints.collections, body);
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => CollectionModel.fromJson(json)).toList();
    } catch (e) {
      print('💥 IGDB: Get parent collections error: $e');
      return [];
    }
  }

  // Get child collections for a parent collection
  Future<List<CollectionModel>> getChildCollections(int parentCollectionId) async {
    try {
      // First get the relations for this parent
      final relations = await getCollectionRelations(parentCollectionId: parentCollectionId);

      // Extract child collection IDs
      final childIds = relations
          .where((rel) => rel.childCollectionId != null)
          .map((rel) => rel.childCollectionId!)
          .toList();

      if (childIds.isEmpty) return [];

      // Get the actual child collections
      return await getCollections(ids: childIds);
    } catch (e) {
      print('💥 IGDB: Get child collections error: $e');
      return [];
    }
  }

  // COLLECTION TYPE METHODS
  Future<List<CollectionTypeModel>> getCollectionTypes({List<int>? ids}) async {
    try {
      String body;
      if (ids != null && ids.isNotEmpty) {
        final idsString = ids.join(',');
        body = '''
          where id = ($idsString);
          fields id, checksum, name, description, created_at, updated_at;
          limit ${ids.length};
        ''';
      } else {
        body = '''
          fields id, checksum, name, description, created_at, updated_at;
          sort name asc;
          limit 50;
        ''';
      }

      final response = await _makeRequestRaw(IGDBEndpoints.collectionTypes, body);
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => CollectionTypeModel.fromJson(json)).toList();
    } catch (e) {
      print('💥 IGDB: Get collection types error: $e');
      return [];
    }
  }

  // COLLECTION MEMBERSHIP METHODS
  Future<List<CollectionMembershipModel>> getCollectionMemberships({
    int? collectionId,
    int? gameId,
    List<int>? ids,
  }) async {
    try {
      String body;

      if (ids != null && ids.isNotEmpty) {
        final idsString = ids.join(',');
        body = '''
          where id = ($idsString);
          fields id, checksum, collection, game, type, created_at, updated_at;
          limit ${ids.length};
        ''';
      } else if (collectionId != null) {
        body = '''
          where collection = $collectionId;
          fields id, checksum, collection, game, type, created_at, updated_at;
          limit 500;
        ''';
      } else if (gameId != null) {
        body = '''
          where game = $gameId;
          fields id, checksum, collection, game, type, created_at, updated_at;
          limit 100;
        ''';
      } else {
        body = '''
          fields id, checksum, collection, game, type, created_at, updated_at;
          limit 100;
        ''';
      }

      final response = await _makeRequestRaw(IGDBEndpoints.collectionMemberships, body);
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => CollectionMembershipModel.fromJson(json)).toList();
    } catch (e) {
      print('💥 IGDB: Get collection memberships error: $e');
      return [];
    }
  }

  // COLLECTION RELATION METHODS
  Future<List<CollectionRelationModel>> getCollectionRelations({
    int? parentCollectionId,
    int? childCollectionId,
    List<int>? ids,
  }) async {
    try {
      String body;

      if (ids != null && ids.isNotEmpty) {
        final idsString = ids.join(',');
        body = '''
          where id = ($idsString);
          fields id, checksum, child_collection, parent_collection, type, created_at, updated_at;
          limit ${ids.length};
        ''';
      } else if (parentCollectionId != null) {
        body = '''
          where parent_collection = $parentCollectionId;
          fields id, checksum, child_collection, parent_collection, type, created_at, updated_at;
          limit 100;
        ''';
      } else if (childCollectionId != null) {
        body = '''
          where child_collection = $childCollectionId;
          fields id, checksum, child_collection, parent_collection, type, created_at, updated_at;
          limit 100;
        ''';
      } else {
        body = '''
          fields id, checksum, child_collection, parent_collection, type, created_at, updated_at;
          limit 100;
        ''';
      }

      final response = await _makeRequestRaw(IGDBEndpoints.collectionRelations, body);
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => CollectionRelationModel.fromJson(json)).toList();
    } catch (e) {
      print('💥 IGDB: Get collection relations error: $e');
      return [];
    }
  }

  // Get collection hierarchy (parent-child structure)
  Future<Map<String, dynamic>> getCollectionHierarchy(int collectionId) async {
    try {
      // Get the main collection
      final collections = await getCollections(ids: [collectionId]);
      if (collections.isEmpty) return {};

      final collection = collections.first;

      // Get parent collections
      final parentRelations = await getCollectionRelations(childCollectionId: collectionId);
      final parentIds = parentRelations
          .where((rel) => rel.parentCollectionId != null)
          .map((rel) => rel.parentCollectionId!)
          .toList();
      final parents = parentIds.isNotEmpty ? await getCollections(ids: parentIds) : <CollectionModel>[];

      // Get child collections
      final children = await getChildCollections(collectionId);

      return {
        'collection': collection,
        'parents': parents,
        'children': children,
        'parent_relations': parentRelations,
        'has_hierarchy': parents.isNotEmpty || children.isNotEmpty,
      };
    } catch (e) {
      print('💥 IGDB: Get collection hierarchy error: $e');
      return {};
    }
  }

  // Get complete collection data with all relations
  Future<List<Map<String, dynamic>>> getCompleteCollectionData({
    List<int>? collectionIds,
    String? search,
    int limit = 20,
  }) async {
    try {
      // 1. Get collections
      final collections = collectionIds != null
          ? await getCollections(ids: collectionIds)
          : search != null
          ? await searchCollections(search)
          : await getPopularCollections(limit: limit);

      if (collections.isEmpty) return [];

      // 2. Get all type IDs
      final typeIds = collections
          .where((col) => col.typeId != null)
          .map((col) => col.typeId!)
          .toSet()
          .toList();

      // 3. Fetch related data
      final types = typeIds.isNotEmpty
          ? await getCollectionTypes(ids: typeIds)
          : <CollectionTypeModel>[];

      // 4. For each collection, get memberships and games
      List<Map<String, dynamic>> completeData = [];

      for (final collection in collections.take(limit)) {
        // Get memberships for this collection
        final memberships = await getCollectionMemberships(collectionId: collection.id);

        // Get games for this collection (from the collection.gameIds or memberships)
        final gameIds = collection.gameIds.isNotEmpty
            ? collection.gameIds
            : memberships.where((m) => m.gameId != null).map((m) => m.gameId!).toList();

        final games = gameIds.isNotEmpty
            ? await getGamesByIds(gameIds.take(10).toList()) // Limit to 10 games per collection
            : <GameModel>[];

        final type = types.firstWhere(
              (t) => t.id == collection.typeId,
          orElse: () => const CollectionTypeModel(
              id: 0,
              checksum: '',
              name: 'Unknown'
          ),
        );

        completeData.add({
          'collection': collection,
          'type': type,
          'memberships': memberships,
          'games': games,
          'game_count': gameIds.length,
        });
      }

      // Sort by game count (most popular first)
      completeData.sort((a, b) =>
          (b['game_count'] as int).compareTo(a['game_count'] as int));

      return completeData;
    } catch (e) {
      print('💥 IGDB: Get complete collection data error: $e');
      return [];
    }
  }

  // Get famous game series (collections with many games)
  Future<List<Map<String, dynamic>>> getFamousGameSeries({int limit = 20}) async {
    try {
      final completeData = await getCompleteCollectionData(limit: limit * 2);

      // Filter for collections with at least 3 games
      final famousSeries = completeData
          .where((data) => (data['game_count'] as int) >= 3)
          .take(limit)
          .toList();

      return famousSeries;
    } catch (e) {
      print('💥 IGDB: Get famous game series error: $e');
      return [];
    }
  }

  // Helper method to get collection by name
  Future<CollectionModel?> getCollectionByName(String name) async {
    try {
      final collections = await searchCollections(name);
      return collections.isNotEmpty ? collections.first : null;
    } catch (e) {
      print('💥 IGDB: Get collection by name error: $e');
      return null;
    }
  }

  // Get collection statistics
  Future<Map<String, dynamic>> getCollectionStatistics() async {
    try {
      // Get sample of collections
      final collections = await getCollections(limit: 500);

      // Calculate statistics
      final totalCollections = collections.length;
      final collectionsWithGames = collections.where((c) => c.hasGames).length;
      final collectionsWithRelations = collections.where((c) => c.hasRelations).length;
      final averageGamesPerCollection = collectionsWithGames > 0
          ? collections.map((c) => c.gameCount).reduce((a, b) => a + b) / collectionsWithGames
          : 0.0;

      // Find biggest collections
      final biggestCollections = collections.toList()
        ..sort((a, b) => b.gameCount.compareTo(a.gameCount));

      return {
        'total_collections': totalCollections,
        'collections_with_games': collectionsWithGames,
        'collections_with_relations': collectionsWithRelations,
        'average_games_per_collection': averageGamesPerCollection.round(),
        'biggest_collections': biggestCollections.take(10).toList(),
      };
    } catch (e) {
      print('💥 IGDB: Get collection statistics error: $e');
      return {};
    }
  }

  // lib/data/datasources/remote/igdb_remote_datasource_impl.dart - Franchise Methods
// Diese Methoden gehören in die IGDBRemoteDataSourceImpl Klasse

  // FRANCHISE METHODS
  Future<List<FranchiseModel>> getFranchises({
    List<int>? ids,
    String? search,
    int limit = 100,
  }) async {
    try {
      String body;

      const fields = '''
        id, checksum, name, slug, url, games, created_at, updated_at
      ''';

      if (ids != null && ids.isNotEmpty) {
        final idsString = ids.join(',');
        body = '''
          where id = ($idsString);
          fields $fields;
          limit ${ids.length};
        ''';
      } else if (search != null) {
        body = '''
          search "$search";
          fields $fields;
          limit $limit;
        ''';
      } else {
        body = '''
          fields $fields;
          sort name asc;
          limit $limit;
        ''';
      }

      final response = await _makeRequestRaw(IGDBEndpoints.franchises, body);
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => FranchiseModel.fromJson(json)).toList();
    } catch (e) {
      print('💥 IGDB: Get franchises error: $e');
      return [];
    }
  }

  // Search franchises by name
  Future<List<FranchiseModel>> searchFranchises(String query) async {
    return await getFranchises(search: query, limit: 50);
  }

  // Get franchises for specific games
  Future<List<FranchiseModel>> getFranchisesForGames(List<int> gameIds) async {
    try {
      if (gameIds.isEmpty) return [];

      final idsString = gameIds.join(',');
      final body = '''
        where games = [$idsString];
        fields id, checksum, name, slug, url, games, created_at, updated_at;
        limit 200;
      ''';

      final response = await _makeRequestRaw(IGDBEndpoints.franchises, body);
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => FranchiseModel.fromJson(json)).toList();
    } catch (e) {
      print('💥 IGDB: Get franchises for games error: $e');
      return [];
    }
  }

  // Get popular franchises (those with the most games)
  Future<List<FranchiseModel>> getPopularFranchises({int limit = 20}) async {
    try {
      final franchises = await getFranchises(limit: limit * 2);

      // Sort by number of games (popularity indicator)
      franchises.sort((a, b) => b.gameCount.compareTo(a.gameCount));
      return franchises.take(limit).toList();
    } catch (e) {
      print('💥 IGDB: Get popular franchises error: $e');
      return [];
    }
  }

  // Get major franchises (5+ games)
  Future<List<FranchiseModel>> getMajorFranchises({int limit = 20}) async {
    try {
      final franchises = await getFranchises(limit: limit * 3);

      // Filter for major franchises and sort by game count
      final majorFranchises = franchises
          .where((franchise) => franchise.isMajorFranchise)
          .toList();

      majorFranchises.sort((a, b) => b.gameCount.compareTo(a.gameCount));
      return majorFranchises.take(limit).toList();
    } catch (e) {
      print('💥 IGDB: Get major franchises error: $e');
      return [];
    }
  }

  // Get trending franchises (hardcoded popular franchise names)
  Future<List<FranchiseModel>> getTrendingFranchises() async {
    try {
      // Popular franchise names to search for
      final trendingNames = [
        'Call of Duty',
        'Assassin\'s Creed',
        'Grand Theft Auto',
        'The Elder Scrolls',
        'Final Fantasy',
        'Super Mario',
        'The Legend of Zelda',
        'Pokémon',
        'Halo',
        'Battlefield',
        'FIFA',
        'Madden NFL',
        'Need for Speed',
        'Mortal Kombat',
        'Street Fighter',
        'Resident Evil',
        'Silent Hill',
        'Metal Gear',
        'God of War',
        'Uncharted',
      ];

      List<FranchiseModel> trendingFranchises = [];

      // Search for each trending franchise
      for (final name in trendingNames) {
        final franchises = await searchFranchises(name);
        if (franchises.isNotEmpty) {
          // Take the most relevant result (first one)
          final franchise = franchises.first;
          if (franchise.hasGames) {
            trendingFranchises.add(franchise);
          }
        }
      }

      // Remove duplicates and sort by game count
      final uniqueFranchises = <int, FranchiseModel>{};
      for (final franchise in trendingFranchises) {
        uniqueFranchises[franchise.id] = franchise;
      }

      final result = uniqueFranchises.values.toList();
      result.sort((a, b) => b.gameCount.compareTo(a.gameCount));
      return result.take(15).toList();
    } catch (e) {
      print('💥 IGDB: Get trending franchises error: $e');
      return [];
    }
  }

  // Get franchise with games data
  Future<List<Map<String, dynamic>>> getFranchisesWithGames({
    List<int>? franchiseIds,
    String? search,
    int limit = 20,
    int maxGamesPerFranchise = 10,
  }) async {
    try {
      // 1. Get franchises
      final franchises = franchiseIds != null
          ? await getFranchises(ids: franchiseIds)
          : search != null
          ? await searchFranchises(search)
          : await getPopularFranchises(limit: limit);

      if (franchises.isEmpty) return [];

      // 2. For each franchise, get its games
      List<Map<String, dynamic>> franchisesWithGames = [];

      for (final franchise in franchises.take(limit)) {
        if (franchise.hasGames) {
          // Get games for this franchise (limit to avoid too many requests)
          final gameIds = franchise.gameIds.take(maxGamesPerFranchise).toList();
          final games = await getGamesByIds(gameIds);

          franchisesWithGames.add({
            'franchise': franchise,
            'games': games,
            'total_games': franchise.gameCount,
            'is_major': franchise.isMajorFranchise,
          });
        }
      }

      // Sort by total game count (most popular first)
      franchisesWithGames.sort((a, b) =>
          (b['total_games'] as int).compareTo(a['total_games'] as int));

      return franchisesWithGames;
    } catch (e) {
      print('💥 IGDB: Get franchises with games error: $e');
      return [];
    }
  }

  // Get franchise statistics
  Future<Map<String, dynamic>> getFranchiseStatistics() async {
    try {
      // Get sample of franchises
      final franchises = await getFranchises(limit: 300);

      // Calculate statistics
      final totalFranchises = franchises.length;
      final franchisesWithGames = franchises.where((f) => f.hasGames).length;
      final majorFranchises = franchises.where((f) => f.isMajorFranchise).length;
      final averageGamesPerFranchise = franchisesWithGames > 0
          ? franchises.map((f) => f.gameCount).reduce((a, b) => a + b) / franchisesWithGames
          : 0.0;

      // Find biggest franchises
      final biggestFranchises = franchises.toList()
        ..sort((a, b) => b.gameCount.compareTo(a.gameCount));

      return {
        'total_franchises': totalFranchises,
        'franchises_with_games': franchisesWithGames,
        'major_franchises': majorFranchises,
        'average_games_per_franchise': averageGamesPerFranchise.round(),
        'biggest_franchises': biggestFranchises.take(10).toList(),
      };
    } catch (e) {
      print('💥 IGDB: Get franchise statistics error: $e');
      return {};
    }
  }

  // Get random franchises for discovery
  Future<List<FranchiseModel>> getRandomFranchises({int limit = 10}) async {
    try {
      final allFranchises = await getFranchises(limit: limit * 5);
      if (allFranchises.isEmpty) return [];

      // Filter for franchises with games and shuffle
      final franchisesWithGames = allFranchises.where((f) => f.hasGames).toList();
      franchisesWithGames.shuffle();
      return franchisesWithGames.take(limit).toList();
    } catch (e) {
      print('💥 IGDB: Get random franchises error: $e');
      return [];
    }
  }

  // Helper method to get franchise by name
  Future<FranchiseModel?> getFranchiseByName(String name) async {
    try {
      final franchises = await searchFranchises(name);
      return franchises.isNotEmpty ? franchises.first : null;
    } catch (e) {
      print('💥 IGDB: Get franchise by name error: $e');
      return null;
    }
  }

  // Get franchise game timeline (games sorted by release date)
  Future<Map<String, dynamic>> getFranchiseTimeline(int franchiseId) async {
    try {
      // Get franchise
      final franchises = await getFranchises(ids: [franchiseId]);
      if (franchises.isEmpty) return {};

      final franchise = franchises.first;
      if (!franchise.hasGames) return {'franchise': franchise, 'games': []};

      // Get all games in the franchise
      final games = await getGamesByIds(franchise.gameIds);

      // Sort games by release date
      final gamesWithReleaseDate = games.where((g) => g.releaseDate != null).toList();
      final gamesWithoutReleaseDate = games.where((g) => g.releaseDate == null).toList();

      gamesWithReleaseDate.sort((a, b) => a.releaseDate!.compareTo(b.releaseDate!));

      // Combine sorted games
      final sortedGames = [...gamesWithReleaseDate, ...gamesWithoutReleaseDate];

      return {
        'franchise': franchise,
        'games': sortedGames,
        'total_games': games.length,
        'earliest_game': gamesWithReleaseDate.isNotEmpty ? gamesWithReleaseDate.first : null,
        'latest_game': gamesWithReleaseDate.isNotEmpty ? gamesWithReleaseDate.last : null,
        'span_years': gamesWithReleaseDate.length >= 2
            ? gamesWithReleaseDate.last.releaseDate!.year - gamesWithReleaseDate.first.releaseDate!.year
            : 0,
      };
    } catch (e) {
      print('💥 IGDB: Get franchise timeline error: $e');
      return {};
    }
  }

  // Get similar franchises based on shared games or similar names
  Future<List<FranchiseModel>> getSimilarFranchises(
      int franchiseId, {
        int limit = 10,
      }) async {
    try {
      // Get the main franchise
      final mainFranchises = await getFranchises(ids: [franchiseId]);
      if (mainFranchises.isEmpty) return [];

      final mainFranchise = mainFranchises.first;

      // Search for franchises with similar names
      final searchTerms = mainFranchise.name.toLowerCase().split(' ');
      List<FranchiseModel> similarFranchises = [];

      for (final term in searchTerms) {
        if (term.length >= 3) { // Only search for meaningful terms
          final franchises = await searchFranchises(term);
          similarFranchises.addAll(franchises);
        }
      }

      // Remove the main franchise and duplicates
      final uniqueSimilar = <int, FranchiseModel>{};
      for (final franchise in similarFranchises) {
        if (franchise.id != franchiseId) {
          uniqueSimilar[franchise.id] = franchise;
        }
      }

      // Sort by game count and return top results
      final result = uniqueSimilar.values.toList();
      result.sort((a, b) => b.gameCount.compareTo(a.gameCount));
      return result.take(limit).toList();
    } catch (e) {
      print('💥 IGDB: Get similar franchises error: $e');
      return [];
    }
  }

}
