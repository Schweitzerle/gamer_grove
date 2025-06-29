import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../domain/entities/character/character.dart';
import '../../../../domain/entities/company/company_website.dart';
import '../../../../domain/entities/externalGame/external_game.dart';
import '../../../../domain/entities/game/game.dart';
import '../../../../domain/entities/platform/platform.dart';
import '../../../../domain/entities/popularity/popularity_primitive.dart';
import '../../../../domain/entities/search/search.dart';
import '../../../models/ageRating/age_rating_category_model.dart';
import '../../../models/ageRating/age_rating_model.dart';
import '../../../models/ageRating/age_rating_organization.dart';
import '../../../models/alternative_name_model.dart';
import '../../../models/character/character_gender_model.dart';
import '../../../models/character/character_model.dart';
import '../../../models/character/character_mug_shot_model.dart';
import '../../../models/character/character_species_model.dart';
import '../../../models/collection/collection_membership_model.dart';
import '../../../models/collection/collection_relation_model.dart';
import '../../../models/collection/collection_type_model.dart';
import '../../../models/collection_model.dart';
import '../../../models/company/company_model.dart';
import '../../../models/company/company_model_logo.dart';
import '../../../models/company/company_status_model.dart';
import '../../../models/company/company_website_model.dart';
import '../../../models/date/date_format_model.dart';
import '../../../models/event/event_logo_model.dart';
import '../../../models/event/event_model.dart';
import '../../../models/event/event_network_model.dart';
import '../../../models/event/network_type_model.dart';
import '../../../models/externalGame/external_game_model.dart';
import '../../../models/externalGame/external_game_source_model.dart';
import '../../../models/franchise_model.dart';
import '../../../models/game/game_engine_logo_model.dart';
import '../../../models/game/game_engine_model.dart';
import '../../../models/game/game_mode_model.dart';
import '../../../models/game/game_model.dart';
import '../../../models/game/game_release_format_model.dart';
import '../../../models/game/game_status_model.dart';
import '../../../models/game/game_time_to_beat_model.dart';
import '../../../models/game/game_type_model.dart';
import '../../../models/game/game_version_feature_model.dart';
import '../../../models/game/game_version_feature_value_model.dart';
import '../../../models/game/game_version_model.dart';
import '../../../models/game/game_video_model.dart';
import '../../../models/genre_model.dart';
import '../../../models/keyword_model.dart';
import '../../../models/language/language_support_type_model.dart';
import '../../../models/language/lanuage_model.dart';
import '../../../models/language_support_model.dart';
import '../../../models/multiplayer_mode_model.dart';
import '../../../models/platform/paltform_type_model.dart';
import '../../../models/platform/platform_family_model.dart';
import '../../../models/platform/platform_logo_model.dart';
import '../../../models/platform/platform_model.dart';
import '../../../models/platform/platform_version_company_model.dart';
import '../../../models/platform/platform_version_model.dart';
import '../../../models/platform/platform_version_release_date_model.dart';
import '../../../models/player_perspective_model.dart';
import '../../../models/popularity/popularity_primitive_model.dart';
import '../../../models/popularity/popularity_type_model.dart';
import '../../../models/region_model.dart';
import '../../../models/release_date/release_date_model.dart';
import '../../../models/release_date/release_date_region_model.dart';
import '../../../models/release_date/release_date_status_model.dart';
import '../../../models/search/search_model.dart';
import '../../../models/theme_model.dart';
import '../../../models/website/website_model.dart';
import '../../../models/website/website_type_model.dart';
import 'idgb_remote_datasource.dart';

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

  // ===== COMPANY DATASOURCE IMPLEMENTATION METHODS =====
// Diese Methoden gehören in die IGDBRemoteDataSourceImpl Klasse

  // ===== COMPANY METHODS =====
  @override
  Future<List<CompanyModel>> getCompanies({
    List<int>? ids,
    String? search,
    int limit = 50,
  }) async {
    try {
      String body;

      const fields = '''
        id, checksum, name, description, slug, url, country, created_at, updated_at,
        change_date, change_date_category, change_date_format, changed_company_id,
        parent, logo, status, start_date, start_date_category, start_date_format,
        developed, published, websites
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

      final response = await _makeRequestRaw(IGDBEndpoints.companies, body);
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => CompanyModel.fromJson(json)).toList();
    } catch (e) {
      print('💥 IGDB: Get companies error: $e');
      return [];
    }
  }

  @override
  Future<CompanyModel?> getCompanyById(int id) async {
    try {
      final companies = await getCompanies(ids: [id]);
      return companies.isNotEmpty ? companies.first : null;
    } catch (e) {
      print('💥 IGDB: Get company by ID error: $e');
      return null;
    }
  }

  @override
  Future<List<CompanyModel>> searchCompanies(String query, {int limit = 20}) async {
    return await getCompanies(search: query, limit: limit);
  }

  @override
  Future<List<CompanyModel>> getPopularCompanies({int limit = 50}) async {
    try {
      const body = '''
        fields id, checksum, name, description, slug, url, country, created_at, updated_at,
               change_date, change_date_category, change_date_format, changed_company_id,
               parent, logo, status, start_date, start_date_category, start_date_format,
               developed, published, websites;
        where developed != null & published != null;
        sort developed.count desc, published.count desc;
        limit $limit;
      ''';

      final response = await _makeRequestRaw(IGDBEndpoints.companies, body);
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => CompanyModel.fromJson(json)).toList();
    } catch (e) {
      print('💥 IGDB: Get popular companies error: $e');
      return [];
    }
  }

  @override
  Future<List<CompanyModel>> getCompaniesByDevelopedGames(List<int> gameIds) async {
    try {
      if (gameIds.isEmpty) return [];

      final gameIdsString = gameIds.join(',');
      const body = '''
        fields id, checksum, name, description, slug, url, country, created_at, updated_at,
               change_date, change_date_category, change_date_format, changed_company_id,
               parent, logo, status, start_date, start_date_category, start_date_format,
               developed, published, websites;
        where developed = [$gameIdsString];
        limit 50;
      ''';

      final response = await _makeRequestRaw(IGDBEndpoints.companies, body);
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => CompanyModel.fromJson(json)).toList();
    } catch (e) {
      print('💥 IGDB: Get companies by developed games error: $e');
      return [];
    }
  }

  @override
  Future<List<CompanyModel>> getCompaniesByPublishedGames(List<int> gameIds) async {
    try {
      if (gameIds.isEmpty) return [];

      final gameIdsString = gameIds.join(',');
      const body = '''
        fields id, checksum, name, description, slug, url, country, created_at, updated_at,
               change_date, change_date_category, change_date_format, changed_company_id,
               parent, logo, status, start_date, start_date_category, start_date_format,
               developed, published, websites;
        where published = [$gameIdsString];
        limit 50;
      ''';

      final response = await _makeRequestRaw(IGDBEndpoints.companies, body);
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => CompanyModel.fromJson(json)).toList();
    } catch (e) {
      print('💥 IGDB: Get companies by published games error: $e');
      return [];
    }
  }

  // ===== COMPANY LOGO METHODS =====
  @override
  Future<List<CompanyLogoModel>> getCompanyLogos({
    List<int>? ids,
    int limit = 50,
  }) async {
    try {
      String body;

      const fields = '''
        id, checksum, alpha_channel, animated, height, image_id, url, width
      ''';

      if (ids != null && ids.isNotEmpty) {
        final idsString = ids.join(',');
        body = '''
          where id = ($idsString);
          fields $fields;
          limit ${ids.length};
        ''';
      } else {
        body = '''
          fields $fields;
          limit $limit;
        ''';
      }

      final response = await _makeRequestRaw(IGDBEndpoints.companyLogos, body);
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => CompanyLogoModel.fromJson(json)).toList();
    } catch (e) {
      print('💥 IGDB: Get company logos error: $e');
      return [];
    }
  }

  @override
  Future<CompanyLogoModel?> getCompanyLogoById(int id) async {
    try {
      final logos = await getCompanyLogos(ids: [id]);
      return logos.isNotEmpty ? logos.first : null;
    } catch (e) {
      print('💥 IGDB: Get company logo by ID error: $e');
      return null;
    }
  }

  // ===== COMPANY STATUS METHODS =====
  @override
  Future<List<CompanyStatusModel>> getCompanyStatuses({
    List<int>? ids,
    int limit = 50,
  }) async {
    try {
      String body;

      const fields = '''
        id, checksum, name, created_at, updated_at
      ''';

      if (ids != null && ids.isNotEmpty) {
        final idsString = ids.join(',');
        body = '''
          where id = ($idsString);
          fields $fields;
          limit ${ids.length};
        ''';
      } else {
        body = '''
          fields $fields;
          sort name asc;
          limit $limit;
        ''';
      }

      final response = await _makeRequestRaw(IGDBEndpoints.companyStatuses, body);
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => CompanyStatusModel.fromJson(json)).toList();
    } catch (e) {
      print('💥 IGDB: Get company statuses error: $e');
      return [];
    }
  }

  @override
  Future<CompanyStatusModel?> getCompanyStatusById(int id) async {
    try {
      final statuses = await getCompanyStatuses(ids: [id]);
      return statuses.isNotEmpty ? statuses.first : null;
    } catch (e) {
      print('💥 IGDB: Get company status by ID error: $e');
      return null;
    }
  }

  // ===== COMPANY WEBSITE METHODS =====
  @override
  Future<List<CompanyWebsiteModel>> getCompanyWebsites({
    List<int>? ids,
    int limit = 50,
  }) async {
    try {
      String body;

      const fields = '''
        id, checksum, url, trusted, category, type
      ''';

      if (ids != null && ids.isNotEmpty) {
        final idsString = ids.join(',');
        body = '''
          where id = ($idsString);
          fields $fields;
          limit ${ids.length};
        ''';
      } else {
        body = '''
          fields $fields;
          limit $limit;
        ''';
      }

      final response = await _makeRequestRaw(IGDBEndpoints.companyWebsites, body);
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => CompanyWebsiteModel.fromJson(json)).toList();
    } catch (e) {
      print('💥 IGDB: Get company websites error: $e');
      return [];
    }
  }

  @override
  Future<CompanyWebsiteModel?> getCompanyWebsiteById(int id) async {
    try {
      final websites = await getCompanyWebsites(ids: [id]);
      return websites.isNotEmpty ? websites.first : null;
    } catch (e) {
      print('💥 IGDB: Get company website by ID error: $e');
      return null;
    }
  }

  @override
  Future<List<CompanyWebsiteModel>> getCompanyWebsitesByCategory(
      CompanyWebsiteCategory category, {
        int limit = 50,
      }) async {
    try {
      final body = '''
        fields id, checksum, url, trusted, category, type;
        where category = ${category.value};
        limit $limit;
      ''';

      final response = await _makeRequestRaw(IGDBEndpoints.companyWebsites, body);
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => CompanyWebsiteModel.fromJson(json)).toList();
    } catch (e) {
      print('💥 IGDB: Get company websites by category error: $e');
      return [];
    }
  }

  // ===== COMPREHENSIVE COMPANY DATA =====
  @override
  Future<Map<String, dynamic>> getCompleteCompanyData(int companyId) async {
    try {
      print('🏢 IGDB: Getting complete company data for ID: $companyId');

      // Get main company data
      final company = await getCompanyById(companyId);
      if (company == null) {
        throw ServerException(message: 'Company not found');
      }

      // Get related data in parallel
      final futures = await Future.wait([
        company.hasLogo && company.logoId != null
            ? getCompanyLogoById(company.logoId!)
            : Future.value(null),
        company.hasStatus && company.statusId != null
            ? getCompanyStatusById(company.statusId!)
            : Future.value(null),
        company.hasWebsites
            ? getCompanyWebsites(ids: company.websiteIds)
            : Future.value(<CompanyWebsiteModel>[]),
      ]);

      final logo = futures[0] as CompanyLogoModel?;
      final status = futures[1] as CompanyStatusModel?;
      final websites = futures[2] as List<CompanyWebsiteModel>;

      return {
        'company': company,
        'logo': logo,
        'status': status,
        'websites': websites,
      };
    } catch (e) {
      print('💥 IGDB: Get complete company data error: $e');
      throw ServerException(message: 'Failed to get complete company data: $e');
    }
  }

  @override
  Future<List<CompanyModel>> getCompanyHierarchy(int companyId) async {
    try {
      print('🏢 IGDB: Getting company hierarchy for ID: $companyId');

      final List<CompanyModel> hierarchy = [];
      final company = await getCompanyById(companyId);

      if (company == null) return hierarchy;

      hierarchy.add(company);

      // Get parent companies
      CompanyModel? currentCompany = company;
      while (currentCompany?.hasParent == true) {
        final parent = await getCompanyById(currentCompany!.parentId!);
        if (parent != null) {
          hierarchy.insert(0, parent); // Add parent at the beginning
          currentCompany = parent;
        } else {
          break;
        }
      }

      // Get child companies
      final childCompanies = await getCompanies();
      final children = childCompanies
          .where((c) => c.parentId == companyId)
          .toList();

      hierarchy.addAll(children);

      return hierarchy;
    } catch (e) {
      print('💥 IGDB: Get company hierarchy error: $e');
      return [];
    }
  }

  // ===== HELPER METHODS FOR COMPANY =====

  /// Get company by name (exact match)
  Future<CompanyModel?> getCompanyByName(String name) async {
    try {
      final companies = await searchCompanies(name, limit: 10);
      return companies
          .where((company) => company.name.toLowerCase() == name.toLowerCase())
          .firstOrNull;
    } catch (e) {
      print('💥 IGDB: Get company by name error: $e');
      return null;
    }
  }

  /// Get companies that are both developers and publishers
  Future<List<CompanyModel>> getDeveloperPublisherCompanies({int limit = 50}) async {
    try {
      const body = '''
        fields id, checksum, name, description, slug, url, country, created_at, updated_at,
               change_date, change_date_category, change_date_format, changed_company_id,
               parent, logo, status, start_date, start_date_category, start_date_format,
               developed, published, websites;
        where developed != null & published != null;
        sort name asc;
        limit $limit;
      ''';

      final response = await _makeRequestRaw(IGDBEndpoints.companies, body);
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => CompanyModel.fromJson(json)).toList();
    } catch (e) {
      print('💥 IGDB: Get developer-publisher companies error: $e');
      return [];
    }
  }

  /// Get companies founded in a specific year
  Future<List<CompanyModel>> getCompaniesByFoundingYear(int year, {int limit = 50}) async {
    try {
      final startOfYear = DateTime(year).millisecondsSinceEpoch ~/ 1000;
      final endOfYear = DateTime(year + 1).millisecondsSinceEpoch ~/ 1000;

      final body = '''
        fields id, checksum, name, description, slug, url, country, created_at, updated_at,
               change_date, change_date_category, change_date_format, changed_company_id,
               parent, logo, status, start_date, start_date_category, start_date_format,
               developed, published, websites;
        where start_date >= $startOfYear & start_date < $endOfYear;
        sort start_date asc;
        limit $limit;
      ''';

      final response = await _makeRequestRaw(IGDBEndpoints.companies, body);
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => CompanyModel.fromJson(json)).toList();
    } catch (e) {
      print('💥 IGDB: Get companies by founding year error: $e');
      return [];
    }
  }




// ===== GAME ENGINE LOGO DATASOURCE IMPLEMENTATION =====
// Diese Methoden in die IGDBRemoteDataSourceImpl Klasse hinzufügen:

  // ===== GAME ENGINE LOGO METHODS =====
  @override
  Future<List<GameEngineLogoModel>> getGameEngineLogos({
    List<int>? ids,
    int limit = 50,
  }) async {
    try {
      String body;

      const fields = '''
        id, checksum, alpha_channel, animated, height, image_id, url, width
      ''';

      if (ids != null && ids.isNotEmpty) {
        final idsString = ids.join(',');
        body = '''
          where id = ($idsString);
          fields $fields;
          limit ${ids.length};
        ''';
      } else {
        body = '''
          fields $fields;
          limit $limit;
        ''';
      }

      final response = await _makeRequestRaw(IGDBEndpoints.gameEngineLogos, body);
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => GameEngineLogoModel.fromJson(json)).toList();
    } catch (e) {
      print('💥 IGDB: Get game engine logos error: $e');
      return [];
    }
  }

  @override
  Future<GameEngineLogoModel?> getGameEngineLogoById(int id) async {
    try {
      final logos = await getGameEngineLogos(ids: [id]);
      return logos.isNotEmpty ? logos.first : null;
    } catch (e) {
      print('💥 IGDB: Get game engine logo by ID error: $e');
      return null;
    }
  }

  // ===== ENHANCED GAME ENGINE METHODS (Updated) =====
  // Diese Methode in der IGDBRemoteDataSourceImpl Klasse erweitern/aktualisieren:

  @override
  Future<List<GameEngineModel>> getGameEngines({
    List<int>? ids,
    String? search,
    int limit = 50,
  }) async {
    try {
      String body;

      const fields = '''
        id, checksum, name, description, logo, slug, url, companies, platforms, created_at, updated_at
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

      final response = await _makeRequestRaw(IGDBEndpoints.gameEngines, body);
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => GameEngineModel.fromJson(json)).toList();
    } catch (e) {
      print('💥 IGDB: Get game engines error: $e');
      return [];
    }
  }

  // ===== COMPREHENSIVE GAME ENGINE DATA =====
  Future<Map<String, dynamic>> getCompleteGameEngineData(int gameEngineId) async {
    try {
      print('🔧 IGDB: Getting complete game engine data for ID: $gameEngineId');

      // Get main game engine data
      final gameEngine = await getGameEngines(ids: [gameEngineId]);
      if (gameEngine.isEmpty) {
        throw ServerException(message: 'Game engine not found');
      }

      final engine = gameEngine.first;

      // Get logo if available
      GameEngineLogoModel? logo;
      if (engine.hasLogo && engine.logoId != null) {
        logo = await getGameEngineLogoById(engine.logoId!);
      }

      return {
        'game_engine': engine,
        'logo': logo,
      };
    } catch (e) {
      print('💥 IGDB: Get complete game engine data error: $e');
      throw ServerException(message: 'Failed to get complete game engine data: $e');
    }
  }

  // ===== HELPER METHODS FOR GAME ENGINE =====

  /// Get game engine by name (exact match)
  Future<GameEngineModel?> getGameEngineByName(String name) async {
    try {
      final engines = await getGameEngines(search: name, limit: 10);
      return engines
          .where((engine) => engine.name.toLowerCase() == name.toLowerCase())
          .firstOrNull;
    } catch (e) {
      print('💥 IGDB: Get game engine by name error: $e');
      return null;
    }
  }

  /// Get popular game engines (used by many companies)
  Future<List<GameEngineModel>> getPopularGameEngines({int limit = 50}) async {
    try {
      const body = '''
        fields id, checksum, name, description, logo, slug, url, companies, platforms, created_at, updated_at;
        where companies != null;
        sort companies.count desc;
        limit $limit;
      ''';

      final response = await _makeRequestRaw(IGDBEndpoints.gameEngines, body);
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => GameEngineModel.fromJson(json)).toList();
    } catch (e) {
      print('💥 IGDB: Get popular game engines error: $e');
      return [];
    }
  }

  /// Get game engines by company ID
  Future<List<GameEngineModel>> getGameEnginesByCompany(int companyId, {int limit = 50}) async {
    try {
      final body = '''
        fields id, checksum, name, description, logo, slug, url, companies, platforms, created_at, updated_at;
        where companies = [$companyId];
        sort name asc;
        limit $limit;
      ''';

      final response = await _makeRequestRaw(IGDBEndpoints.gameEngines, body);
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => GameEngineModel.fromJson(json)).toList();
    } catch (e) {
      print('💥 IGDB: Get game engines by company error: $e');
      return [];
    }
  }

  // ===== EVENT DATASOURCE IMPLEMENTATION METHODS =====
// Diese Methoden gehören in die IGDBRemoteDataSourceImpl Klasse

  // ===== EVENT METHODS =====
  @override
  Future<List<EventModel>> getEvents({
    List<int>? ids,
    String? search,
    int limit = 50,
  }) async {
    try {
      String body;

      const fields = '''
        id, checksum, name, description, slug, created_at, updated_at,
        start_time, end_time, time_zone, event_logo, live_stream_url,
        event_networks, games, videos
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
          sort start_time desc;
          limit $limit;
        ''';
      }

      final response = await _makeRequestRaw(IGDBEndpoints.events, body);
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => EventModel.fromJson(json)).toList();
    } catch (e) {
      print('💥 IGDB: Get events error: $e');
      return [];
    }
  }

  @override
  Future<EventModel?> getEventById(int id) async {
    try {
      final events = await getEvents(ids: [id]);
      return events.isNotEmpty ? events.first : null;
    } catch (e) {
      print('💥 IGDB: Get event by ID error: $e');
      return null;
    }
  }

  @override
  Future<List<EventModel>> searchEvents(String query, {int limit = 20}) async {
    return await getEvents(search: query, limit: limit);
  }

  @override
  Future<List<EventModel>> getUpcomingEvents({int limit = 50}) async {
    try {
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      const body = '''
        fields id, checksum, name, description, slug, created_at, updated_at,
               start_time, end_time, time_zone, event_logo, live_stream_url,
               event_networks, games, videos;
        where start_time > $now;
        sort start_time asc;
        limit $limit;
      ''';

      final response = await _makeRequestRaw(IGDBEndpoints.events, body);
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => EventModel.fromJson(json)).toList();
    } catch (e) {
      print('💥 IGDB: Get upcoming events error: $e');
      return [];
    }
  }

  @override
  Future<List<EventModel>> getLiveEvents({int limit = 50}) async {
    try {
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      const body = '''
        fields id, checksum, name, description, slug, created_at, updated_at,
               start_time, end_time, time_zone, event_logo, live_stream_url,
               event_networks, games, videos;
        where start_time <= $now & end_time >= $now;
        sort start_time asc;
        limit $limit;
      ''';

      final response = await _makeRequestRaw(IGDBEndpoints.events, body);
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => EventModel.fromJson(json)).toList();
    } catch (e) {
      print('💥 IGDB: Get live events error: $e');
      return [];
    }
  }

  @override
  Future<List<EventModel>> getPastEvents({int limit = 50}) async {
    try {
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      const body = '''
        fields id, checksum, name, description, slug, created_at, updated_at,
               start_time, end_time, time_zone, event_logo, live_stream_url,
               event_networks, games, videos;
        where end_time < $now;
        sort end_time desc;
        limit $limit;
      ''';

      final response = await _makeRequestRaw(IGDBEndpoints.events, body);
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => EventModel.fromJson(json)).toList();
    } catch (e) {
      print('💥 IGDB: Get past events error: $e');
      return [];
    }
  }

  @override
  Future<List<EventModel>> getEventsByDateRange({
    DateTime? startDate,
    DateTime? endDate,
    int limit = 50,
  }) async {
    try {
      String whereClause = '';

      if (startDate != null && endDate != null) {
        final startTimestamp = startDate.millisecondsSinceEpoch ~/ 1000;
        final endTimestamp = endDate.millisecondsSinceEpoch ~/ 1000;
        whereClause = 'where start_time >= $startTimestamp & start_time <= $endTimestamp;';
      } else if (startDate != null) {
        final startTimestamp = startDate.millisecondsSinceEpoch ~/ 1000;
        whereClause = 'where start_time >= $startTimestamp;';
      } else if (endDate != null) {
        final endTimestamp = endDate.millisecondsSinceEpoch ~/ 1000;
        whereClause = 'where start_time <= $endTimestamp;';
      }

      final body = '''
        fields id, checksum, name, description, slug, created_at, updated_at,
               start_time, end_time, time_zone, event_logo, live_stream_url,
               event_networks, games, videos;
        $whereClause
        sort start_time asc;
        limit $limit;
      ''';

      final response = await _makeRequestRaw(IGDBEndpoints.events, body);
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => EventModel.fromJson(json)).toList();
    } catch (e) {
      print('💥 IGDB: Get events by date range error: $e');
      return [];
    }
  }

  @override
  Future<List<EventModel>> getEventsByGames(List<int> gameIds) async {
    try {
      if (gameIds.isEmpty) return [];

      final gameIdsString = gameIds.join(',');
      const body = '''
        fields id, checksum, name, description, slug, created_at, updated_at,
               start_time, end_time, time_zone, event_logo, live_stream_url,
               event_networks, games, videos;
        where games = [$gameIdsString];
        sort start_time desc;
        limit 50;
      ''';

      final response = await _makeRequestRaw(IGDBEndpoints.events, body);
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => EventModel.fromJson(json)).toList();
    } catch (e) {
      print('💥 IGDB: Get events by games error: $e');
      return [];
    }
  }

  // ===== EVENT LOGO METHODS =====
  @override
  Future<List<EventLogoModel>> getEventLogos({
    List<int>? ids,
    int limit = 50,
  }) async {
    try {
      String body;

      const fields = '''
        id, checksum, alpha_channel, animated, event, height, image_id,
        url, width, created_at, updated_at
      ''';

      if (ids != null && ids.isNotEmpty) {
        final idsString = ids.join(',');
        body = '''
          where id = ($idsString);
          fields $fields;
          limit ${ids.length};
        ''';
      } else {
        body = '''
          fields $fields;
          limit $limit;
        ''';
      }

      final response = await _makeRequestRaw(IGDBEndpoints.eventLogos, body);
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => EventLogoModel.fromJson(json)).toList();
    } catch (e) {
      print('💥 IGDB: Get event logos error: $e');
      return [];
    }
  }

  @override
  Future<EventLogoModel?> getEventLogoById(int id) async {
    try {
      final logos = await getEventLogos(ids: [id]);
      return logos.isNotEmpty ? logos.first : null;
    } catch (e) {
      print('💥 IGDB: Get event logo by ID error: $e');
      return null;
    }
  }

  @override
  Future<EventLogoModel?> getEventLogoByEventId(int eventId) async {
    try {
      const body = '''
        fields id, checksum, alpha_channel, animated, event, height, image_id,
               url, width, created_at, updated_at;
        where event = $eventId;
        limit 1;
      ''';

      final response = await _makeRequestRaw(IGDBEndpoints.eventLogos, body);
      final List<dynamic> data = json.decode(response.body);
      return data.isNotEmpty ? EventLogoModel.fromJson(data.first) : null;
    } catch (e) {
      print('💥 IGDB: Get event logo by event ID error: $e');
      return null;
    }
  }

  // ===== EVENT NETWORK METHODS =====
  @override
  Future<List<EventNetworkModel>> getEventNetworks({
    List<int>? ids,
    int limit = 50,
  }) async {
    try {
      String body;

      const fields = '''
        id, checksum, url, event, network_type, created_at, updated_at
      ''';

      if (ids != null && ids.isNotEmpty) {
        final idsString = ids.join(',');
        body = '''
          where id = ($idsString);
          fields $fields;
          limit ${ids.length};
        ''';
      } else {
        body = '''
          fields $fields;
          limit $limit;
        ''';
      }

      final response = await _makeRequestRaw(IGDBEndpoints.eventNetworks, body);
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => EventNetworkModel.fromJson(json)).toList();
    } catch (e) {
      print('💥 IGDB: Get event networks error: $e');
      return [];
    }
  }

  @override
  Future<EventNetworkModel?> getEventNetworkById(int id) async {
    try {
      final networks = await getEventNetworks(ids: [id]);
      return networks.isNotEmpty ? networks.first : null;
    } catch (e) {
      print('💥 IGDB: Get event network by ID error: $e');
      return null;
    }
  }

  @override
  Future<List<EventNetworkModel>> getEventNetworksByEventId(int eventId) async {
    try {
      const body = '''
        fields id, checksum, url, event, network_type, created_at, updated_at;
        where event = $eventId;
        limit 50;
      ''';

      final response = await _makeRequestRaw(IGDBEndpoints.eventNetworks, body);
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => EventNetworkModel.fromJson(json)).toList();
    } catch (e) {
      print('💥 IGDB: Get event networks by event ID error: $e');
      return [];
    }
  }

  @override
  Future<List<EventNetworkModel>> getEventNetworksByNetworkType(int networkTypeId) async {
    try {
      const body = '''
        fields id, checksum, url, event, network_type, created_at, updated_at;
        where network_type = $networkTypeId;
        limit 50;
      ''';

      final response = await _makeRequestRaw(IGDBEndpoints.eventNetworks, body);
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => EventNetworkModel.fromJson(json)).toList();
    } catch (e) {
      print('💥 IGDB: Get event networks by network type error: $e');
      return [];
    }
  }

  // ===== NETWORK TYPE METHODS =====
  @override
  Future<List<NetworkTypeModel>> getNetworkTypes({
    List<int>? ids,
    String? search,
    int limit = 50,
  }) async {
    try {
      String body;

      const fields = '''
        id, checksum, name, event_networks, created_at, updated_at
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

      final response = await _makeRequestRaw(IGDBEndpoints.networkTypes, body);
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => NetworkTypeModel.fromJson(json)).toList();
    } catch (e) {
      print('💥 IGDB: Get network types error: $e');
      return [];
    }
  }

  @override
  Future<NetworkTypeModel?> getNetworkTypeById(int id) async {
    try {
      final networkTypes = await getNetworkTypes(ids: [id]);
      return networkTypes.isNotEmpty ? networkTypes.first : null;
    } catch (e) {
      print('💥 IGDB: Get network type by ID error: $e');
      return null;
    }
  }

  @override
  Future<List<NetworkTypeModel>> searchNetworkTypes(String query, {int limit = 20}) async {
    return await getNetworkTypes(search: query, limit: limit);
  }

  // ===== COMPREHENSIVE EVENT DATA =====
  @override
  Future<Map<String, dynamic>> getCompleteEventData(int eventId) async {
    try {
      print('🎪 IGDB: Getting complete event data for ID: $eventId');

      // Get main event data
      final event = await getEventById(eventId);
      if (event == null) {
        throw ServerException(message: 'Event not found');
      }

      // Get related data in parallel
      final futures = await Future.wait([
        event.hasLogo && event.eventLogoId != null
            ? getEventLogoById(event.eventLogoId!)
            : Future.value(null),
        event.hasNetworks
            ? getEventNetworksByEventId(eventId)
            : Future.value(<EventNetworkModel>[]),
        event.hasGames
            ? getGamesByIds(event.gameIds)
            : Future.value(<GameModel>[]),
        event.hasVideos
            ? getGameVideos(event.gameIds) // Assuming we have this method
            : Future.value(<GameVideoModel>[]),
      ]);

      final logo = futures[0] as EventLogoModel?;
      final networks = futures[1] as List<EventNetworkModel>;
      final games = futures[2] as List<GameModel>;
      final videos = futures[3] as List<GameVideoModel>;

      // Get network types for the networks
      final networkTypeIds = networks
          .where((network) => network.hasNetworkType)
          .map((network) => network.networkTypeId!)
          .toSet()
          .toList();

      List<NetworkTypeModel> networkTypes = [];
      if (networkTypeIds.isNotEmpty) {
        networkTypes = await getNetworkTypes(ids: networkTypeIds);
      }

      return {
        'event': event,
        'logo': logo,
        'networks': networks,
        'network_types': networkTypes,
        'games': games,
        'videos': videos,
      };
    } catch (e) {
      print('💥 IGDB: Get complete event data error: $e');
      throw ServerException(message: 'Failed to get complete event data: $e');
    }
  }

  @override
  Future<List<EventModel>> getEventsWithGamesAndNetworks({
    bool includeLogos = true,
    int limit = 50,
  }) async {
    try {
      print('🎪 IGDB: Getting events with games and networks');

      const body = '''
        fields id, checksum, name, description, slug, created_at, updated_at,
               start_time, end_time, time_zone, event_logo, live_stream_url,
               event_networks, games, videos;
        where games != null & event_networks != null;
        sort start_time desc;
        limit $limit;
      ''';

      final response = await _makeRequestRaw(IGDBEndpoints.events, body);
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => EventModel.fromJson(json)).toList();
    } catch (e) {
      print('💥 IGDB: Get events with games and networks error: $e');
      return [];
    }
  }

  // ===== HELPER METHODS FOR EVENTS =====

  /// Get events happening today
  Future<List<EventModel>> getTodaysEvents() async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      return await getEventsByDateRange(
        startDate: startOfDay,
        endDate: endOfDay,
        limit: 50,
      );
    } catch (e) {
      print('💥 IGDB: Get today\'s events error: $e');
      return [];
    }
  }

  /// Get events happening this week
  Future<List<EventModel>> getThisWeeksEvents() async {
    try {
      final now = DateTime.now();
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final endOfWeek = startOfWeek.add(const Duration(days: 7));

      return await getEventsByDateRange(
        startDate: startOfWeek,
        endDate: endOfWeek,
        limit: 100,
      );
    } catch (e) {
      print('💥 IGDB: Get this week\'s events error: $e');
      return [];
    }
  }

  /// Get event by name (exact match)
  Future<EventModel?> getEventByName(String name) async {
    try {
      final events = await searchEvents(name, limit: 10);
      return events
          .where((event) => event.name.toLowerCase() == name.toLowerCase())
          .firstOrNull;
    } catch (e) {
      print('💥 IGDB: Get event by name error: $e');
      return null;
    }
  }

  /// Get events with live streams
  Future<List<EventModel>> getEventsWithLiveStreams({int limit = 50}) async {
    try {
      const body = '''
        fields id, checksum, name, description, slug, created_at, updated_at,
               start_time, end_time, time_zone, event_logo, live_stream_url,
               event_networks, games, videos;
        where live_stream_url != null;
        sort start_time desc;
        limit $limit;
      ''';

      final response = await _makeRequestRaw(IGDBEndpoints.events, body);
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => EventModel.fromJson(json)).toList();
    } catch (e) {
      print('💥 IGDB: Get events with live streams error: $e');
      return [];
    }
  }

  // ===== RELEASE DATE DATASOURCE IMPLEMENTATION METHODS =====
// Diese Methoden gehören in die IGDBRemoteDataSourceImpl Klasse

  // ===== RELEASE DATE METHODS =====
  @override
  Future<List<ReleaseDateModel>> getReleaseDates({
    List<int>? ids,
    int limit = 50,
  }) async {
    try {
      String body;

      const fields = '''
        id, checksum, created_at, updated_at, date, human, m, y,
        game, platform, date_format, release_region, status, category, region
      ''';

      if (ids != null && ids.isNotEmpty) {
        final idsString = ids.join(',');
        body = '''
          where id = ($idsString);
          fields $fields;
          limit ${ids.length};
        ''';
      } else {
        body = '''
          fields $fields;
          sort date desc;
          limit $limit;
        ''';
      }

      final response = await _makeRequestRaw(IGDBEndpoints.releaseDates, body);
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => ReleaseDateModel.fromJson(json)).toList();
    } catch (e) {
      print('💥 IGDB: Get release dates error: $e');
      return [];
    }
  }

  @override
  Future<ReleaseDateModel?> getReleaseDateById(int id) async {
    try {
      final releaseDates = await getReleaseDates(ids: [id]);
      return releaseDates.isNotEmpty ? releaseDates.first : null;
    } catch (e) {
      print('💥 IGDB: Get release date by ID error: $e');
      return null;
    }
  }

  @override
  Future<List<ReleaseDateModel>> getReleaseDatesByGame(int gameId) async {
    try {
      const body = '''
        fields id, checksum, created_at, updated_at, date, human, m, y,
               game, platform, date_format, release_region, status, category, region;
        where game = $gameId;
        sort date asc;
        limit 50;
      ''';

      final response = await _makeRequestRaw(IGDBEndpoints.releaseDates, body);
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => ReleaseDateModel.fromJson(json)).toList();
    } catch (e) {
      print('💥 IGDB: Get release dates by game error: $e');
      return [];
    }
  }

  @override
  Future<List<ReleaseDateModel>> getReleaseDatesByPlatform(int platformId) async {
    try {
      const body = '''
        fields id, checksum, created_at, updated_at, date, human, m, y,
               game, platform, date_format, release_region, status, category, region;
        where platform = $platformId;
        sort date desc;
        limit 50;
      ''';

      final response = await _makeRequestRaw(IGDBEndpoints.releaseDates, body);
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => ReleaseDateModel.fromJson(json)).toList();
    } catch (e) {
      print('💥 IGDB: Get release dates by platform error: $e');
      return [];
    }
  }

  @override
  Future<List<ReleaseDateModel>> getReleaseDatesByRegion(int regionId) async {
    try {
      const body = '''
        fields id, checksum, created_at, updated_at, date, human, m, y,
               game, platform, date_format, release_region, status, category, region;
        where release_region = $regionId;
        sort date desc;
        limit 50;
      ''';

      final response = await _makeRequestRaw(IGDBEndpoints.releaseDates, body);
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => ReleaseDateModel.fromJson(json)).toList();
    } catch (e) {
      print('💥 IGDB: Get release dates by region error: $e');
      return [];
    }
  }

  @override
  Future<List<ReleaseDateModel>> getReleaseDatesByStatus(int statusId) async {
    try {
      const body = '''
        fields id, checksum, created_at, updated_at, date, human, m, y,
               game, platform, date_format, release_region, status, category, region;
        where status = $statusId;
        sort date desc;
        limit 50;
      ''';

      final response = await _makeRequestRaw(IGDBEndpoints.releaseDates, body);
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => ReleaseDateModel.fromJson(json)).toList();
    } catch (e) {
      print('💥 IGDB: Get release dates by status error: $e');
      return [];
    }
  }

  @override
  Future<List<ReleaseDateModel>> getReleaseDatesByDateRange({
    DateTime? startDate,
    DateTime? endDate,
    int limit = 50,
  }) async {
    try {
      String whereClause = '';

      if (startDate != null && endDate != null) {
        final startTimestamp = startDate.millisecondsSinceEpoch ~/ 1000;
        final endTimestamp = endDate.millisecondsSinceEpoch ~/ 1000;
        whereClause = 'where date >= $startTimestamp & date <= $endTimestamp;';
      } else if (startDate != null) {
        final startTimestamp = startDate.millisecondsSinceEpoch ~/ 1000;
        whereClause = 'where date >= $startTimestamp;';
      } else if (endDate != null) {
        final endTimestamp = endDate.millisecondsSinceEpoch ~/ 1000;
        whereClause = 'where date <= $endTimestamp;';
      }

      final body = '''
        fields id, checksum, created_at, updated_at, date, human, m, y,
               game, platform, date_format, release_region, status, category, region;
        $whereClause
        sort date asc;
        limit $limit;
      ''';

      final response = await _makeRequestRaw(IGDBEndpoints.releaseDates, body);
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => ReleaseDateModel.fromJson(json)).toList();
    } catch (e) {
      print('💥 IGDB: Get release dates by date range error: $e');
      return [];
    }
  }

  @override
  Future<List<ReleaseDateModel>> getUpcomingReleaseDates({int limit = 50}) async {
    try {
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      const body = '''
        fields id, checksum, created_at, updated_at, date, human, m, y,
               game, platform, date_format, release_region, status, category, region;
        where date > $now;
        sort date asc;
        limit $limit;
      ''';

      final response = await _makeRequestRaw(IGDBEndpoints.releaseDates, body);
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => ReleaseDateModel.fromJson(json)).toList();
    } catch (e) {
      print('💥 IGDB: Get upcoming release dates error: $e');
      return [];
    }
  }

  @override
  Future<List<ReleaseDateModel>> getRecentReleaseDates({int limit = 50}) async {
    try {
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      const body = '''
        fields id, checksum, created_at, updated_at, date, human, m, y,
               game, platform, date_format, release_region, status, category, region;
        where date <= $now;
        sort date desc;
        limit $limit;
      ''';

      final response = await _makeRequestRaw(IGDBEndpoints.releaseDates, body);
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => ReleaseDateModel.fromJson(json)).toList();
    } catch (e) {
      print('💥 IGDB: Get recent release dates error: $e');
      return [];
    }
  }

  @override
  Future<List<ReleaseDateModel>> getTodaysReleaseDates() async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      return await getReleaseDatesByDateRange(
        startDate: startOfDay,
        endDate: endOfDay,
        limit: 50,
      );
    } catch (e) {
      print('💥 IGDB: Get today\'s release dates error: $e');
      return [];
    }
  }

  @override
  Future<List<ReleaseDateModel>> getThisWeeksReleaseDates() async {
    try {
      final now = DateTime.now();
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final endOfWeek = startOfWeek.add(const Duration(days: 7));

      return await getReleaseDatesByDateRange(
        startDate: startOfWeek,
        endDate: endOfWeek,
        limit: 100,
      );
    } catch (e) {
      print('💥 IGDB: Get this week\'s release dates error: $e');
      return [];
    }
  }

  @override
  Future<List<ReleaseDateModel>> getThisMonthsReleaseDates() async {
    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 1);

      return await getReleaseDatesByDateRange(
        startDate: startOfMonth,
        endDate: endOfMonth,
        limit: 200,
      );
    } catch (e) {
      print('💥 IGDB: Get this month\'s release dates error: $e');
      return [];
    }
  }

  @override
  Future<List<ReleaseDateModel>> getReleaseDatesForYear(int year, {int limit = 100}) async {
    try {
      const body = '''
        fields id, checksum, created_at, updated_at, date, human, m, y,
               game, platform, date_format, release_region, status, category, region;
        where y = $year;
        sort date asc;
        limit $limit;
      ''';

      final response = await _makeRequestRaw(IGDBEndpoints.releaseDates, body);
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => ReleaseDateModel.fromJson(json)).toList();
    } catch (e) {
      print('💥 IGDB: Get release dates for year error: $e');
      return [];
    }
  }

  @override
  Future<List<ReleaseDateModel>> getReleaseDatesForQuarter(int year, int quarter, {int limit = 50}) async {
    try {
      int categoryValue;
      switch (quarter) {
        case 1: categoryValue = 3; break; // YYYYQ1
        case 2: categoryValue = 4; break; // YYYYQ2
        case 3: categoryValue = 5; break; // YYYYQ3
        case 4: categoryValue = 6; break; // YYYYQ4
        default: return [];
      }

      final body = '''
        fields id, checksum, created_at, updated_at, date, human, m, y,
               game, platform, date_format, release_region, status, category, region;
        where y = $year & category = $categoryValue;
        sort date asc;
        limit $limit;
      ''';

      final response = await _makeRequestRaw(IGDBEndpoints.releaseDates, body);
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => ReleaseDateModel.fromJson(json)).toList();
    } catch (e) {
      print('💥 IGDB: Get release dates for quarter error: $e');
      return [];
    }
  }

  // ===== RELEASE DATE REGION METHODS =====
  @override
  Future<List<ReleaseDateRegionModel>> getReleaseDateRegions({
    List<int>? ids,
    String? search,
    int limit = 50,
  }) async {
    try {
      String body;

      const fields = '''
        id, checksum, region, created_at, updated_at
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
          sort region asc;
          limit $limit;
        ''';
      }

      final response = await _makeRequestRaw(IGDBEndpoints.releaseDateRegions, body);
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => ReleaseDateRegionModel.fromJson(json)).toList();
    } catch (e) {
      print('💥 IGDB: Get release date regions error: $e');
      return [];
    }
  }

  @override
  Future<ReleaseDateRegionModel?> getReleaseDateRegionById(int id) async {
    try {
      final regions = await getReleaseDateRegions(ids: [id]);
      return regions.isNotEmpty ? regions.first : null;
    } catch (e) {
      print('💥 IGDB: Get release date region by ID error: $e');
      return null;
    }
  }

  @override
  Future<List<ReleaseDateRegionModel>> searchReleaseDateRegions(String query, {int limit = 20}) async {
    return await getReleaseDateRegions(search: query, limit: limit);
  }

  // ===== RELEASE DATE STATUS METHODS =====
  @override
  Future<List<ReleaseDateStatusModel>> getReleaseDateStatuses({
    List<int>? ids,
    String? search,
    int limit = 50,
  }) async {
    try {
      String body;

      const fields = '''
        id, checksum, name, description, created_at, updated_at
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

      final response = await _makeRequestRaw(IGDBEndpoints.releaseDateStatuses, body);
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => ReleaseDateStatusModel.fromJson(json)).toList();
    } catch (e) {
      print('💥 IGDB: Get release date statuses error: $e');
      return [];
    }
  }

  @override
  Future<ReleaseDateStatusModel?> getReleaseDateStatusById(int id) async {
    try {
      final statuses = await getReleaseDateStatuses(ids: [id]);
      return statuses.isNotEmpty ? statuses.first : null;
    } catch (e) {
      print('💥 IGDB: Get release date status by ID error: $e');
      return null;
    }
  }

  @override
  Future<List<ReleaseDateStatusModel>> searchReleaseDateStatuses(String query, {int limit = 20}) async {
    return await getReleaseDateStatuses(search: query, limit: limit);
  }

  // ===== COMPREHENSIVE RELEASE DATE DATA =====
  @override
  Future<Map<String, dynamic>> getCompleteReleaseDateData(int releaseDateId) async {
    try {
      print('📅 IGDB: Getting complete release date data for ID: $releaseDateId');

      // Get main release date data
      final releaseDate = await getReleaseDateById(releaseDateId);
      if (releaseDate == null) {
        throw ServerException(message: 'Release date not found');
      }

      // Get related data in parallel
      final futures = await Future.wait([
        releaseDate.hasRegion && releaseDate.releaseRegionId != null
            ? getReleaseDateRegionById(releaseDate.releaseRegionId!)
            : Future.value(null),
        releaseDate.hasStatus && releaseDate.statusId != null
            ? getReleaseDateStatusById(releaseDate.statusId!)
            : Future.value(null),
        releaseDate.isAssociatedWithGame && releaseDate.gameId != null
            ? getGameDetails(releaseDate.gameId!)
            : Future.value(null),
        releaseDate.isAssociatedWithPlatform && releaseDate.platformId != null
            ? getPlatforms(ids: [releaseDate.platformId!])
            : Future.value(<PlatformModel>[]),
      ]);

      final region = futures[0] as ReleaseDateRegionModel?;
      final status = futures[1] as ReleaseDateStatusModel?;
      final game = futures[2] as GameModel?;
      final platforms = futures[3] as List<PlatformModel>;

      return {
        'release_date': releaseDate,
        'region': region,
        'status': status,
        'game': game,
        'platform': platforms.isNotEmpty ? platforms.first : null,
      };
    } catch (e) {
      print('💥 IGDB: Get complete release date data error: $e');
      throw ServerException(message: 'Failed to get complete release date data: $e');
    }
  }

  @override
  Future<List<ReleaseDateModel>> getReleaseDatesWithRegionsAndStatuses({
    int limit = 50,
  }) async {
    try {
      print('📅 IGDB: Getting release dates with regions and statuses');

      const body = '''
        fields id, checksum, created_at, updated_at, date, human, m, y,
               game, platform, date_format, release_region, status, category, region;
        where release_region != null & status != null;
        sort date desc;
        limit $limit;
      ''';

      final response = await _makeRequestRaw(IGDBEndpoints.releaseDates, body);
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => ReleaseDateModel.fromJson(json)).toList();
    } catch (e) {
      print('💥 IGDB: Get release dates with regions and statuses error: $e');
      return [];
    }
  }

  // ===== GAME-SPECIFIC RELEASE DATE METHODS =====
  @override
  Future<List<ReleaseDateModel>> getGameReleaseDatesWithDetails(int gameId) async {
    try {
      print('📅 IGDB: Getting release dates with details for game ID: $gameId');

      const body = '''
        fields id, checksum, created_at, updated_at, date, human, m, y,
               game, platform, date_format, release_region, status, category, region;
        where game = $gameId;
        sort date asc;
        limit 50;
      ''';

      final response = await _makeRequestRaw(IGDBEndpoints.releaseDates, body);
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => ReleaseDateModel.fromJson(json)).toList();
    } catch (e) {
      print('💥 IGDB: Get game release dates with details error: $e');
      return [];
    }
  }

  @override
  Future<ReleaseDateModel?> getEarliestReleaseDate(int gameId) async {
    try {
      const body = '''
        fields id, checksum, created_at, updated_at, date, human, m, y,
               game, platform, date_format, release_region, status, category, region;
        where game = $gameId & date != null;
        sort date asc;
        limit 1;
      ''';

      final response = await _makeRequestRaw(IGDBEndpoints.releaseDates, body);
      final List<dynamic> data = json.decode(response.body);
      return data.isNotEmpty ? ReleaseDateModel.fromJson(data.first) : null;
    } catch (e) {
      print('💥 IGDB: Get earliest release date error: $e');
      return null;
    }
  }

  @override
  Future<ReleaseDateModel?> getLatestReleaseDate(int gameId) async {
    try {
      const body = '''
        fields id, checksum, created_at, updated_at, date, human, m, y,
               game, platform, date_format, release_region, status, category, region;
        where game = $gameId & date != null;
        sort date desc;
        limit 1;
      ''';

      final response = await _makeRequestRaw(IGDBEndpoints.releaseDates, body);
      final List<dynamic> data = json.decode(response.body);
      return data.isNotEmpty ? ReleaseDateModel.fromJson(data.first) : null;
    } catch (e) {
      print('💥 IGDB: Get latest release date error: $e');
      return null;
    }
  }

  @override
  Future<Map<String, List<ReleaseDateModel>>> getGameReleaseDatesByRegion(int gameId) async {
    try {
      final releaseDates = await getGameReleaseDatesWithDetails(gameId);
      final Map<String, List<ReleaseDateModel>> regionMap = {};

      for (final releaseDate in releaseDates) {
        final regionName = releaseDate.regionDisplayName;
        if (!regionMap.containsKey(regionName)) {
          regionMap[regionName] = [];
        }
        regionMap[regionName]!.add(releaseDate);
      }

      return regionMap;
    } catch (e) {
      print('💥 IGDB: Get game release dates by region error: $e');
      return {};
    }
  }

  // ===== HELPER METHODS FOR RELEASE DATES =====

  /// Get release dates for games releasing this year
  Future<List<ReleaseDateModel>> getThisYearsReleaseDates() async {
    return await getReleaseDatesForYear(DateTime.now().year);
  }

  /// Get release dates for games releasing next year
  Future<List<ReleaseDateModel>> getNextYearsReleaseDates() async {
    return await getReleaseDatesForYear(DateTime.now().year + 1);
  }

  /// Get TBD release dates
  Future<List<ReleaseDateModel>> getTbdReleaseDates({int limit = 50}) async {
    try {
      const body = '''
        fields id, checksum, created_at, updated_at, date, human, m, y,
               game, platform, date_format, release_region, status, category, region;
        where category = 7;
        sort created_at desc;
        limit $limit;
      ''';

      final response = await _makeRequestRaw(IGDBEndpoints.releaseDates, body);
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => ReleaseDateModel.fromJson(json)).toList();
    } catch (e) {
      print('💥 IGDB: Get TBD release dates error: $e');
      return [];
    }
  }

  /// Get games releasing in a specific month of a year
  Future<List<ReleaseDateModel>> getReleaseDatesForMonth(int year, int month, {int limit = 50}) async {
    try {
      final body = '''
        fields id, checksum, created_at, updated_at, date, human, m, y,
               game, platform, date_format, release_region, status, category, region;
        where y = $year & m = $month;
        sort date asc;
        limit $limit;
      ''';

      final response = await _makeRequestRaw(IGDBEndpoints.releaseDates, body);
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => ReleaseDateModel.fromJson(json)).toList();
    } catch (e) {
      print('💥 IGDB: Get release dates for month error: $e');
      return [];
    }
  }

  /// Get release dates by region enum (deprecated but useful)
  Future<List<ReleaseDateModel>> getReleaseDatesByRegionEnum(ReleaseDateRegionEnum region, {int limit = 50}) async {
    try {
      final body = '''
        fields id, checksum, created_at, updated_at, date, human, m, y,
               game, platform, date_format, release_region, status, category, region;
        where region = ${region.value};
        sort date desc;
        limit $limit;
      ''';

      final response = await _makeRequestRaw(IGDBEndpoints.releaseDates, body);
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => ReleaseDateModel.fromJson(json)).toList();
    } catch (e) {
      print('💥 IGDB: Get release dates by region enum error: $e');
      return [];
    }
  }

  // ===== SEARCH & POPULARITY DATASOURCE IMPLEMENTATION METHODS =====
// Diese Methoden gehören in die IGDBRemoteDataSourceImpl Klasse

  // ===== SEARCH METHODS =====
  @override
  Future<List<SearchModel>> search({
    required String query,
    SearchResultType? resultType,
    int limit = 50,
  }) async {
    try {
      print('🔍 IGDB: Searching for "$query"');

      final body = '''
        search "$query";
        fields id, checksum, name, alternative_name, description, published_at,
               character, collection, company, game, platform, theme, test_dummy;
        limit $limit;
      ''';

      final response = await _makeRequestRaw(IGDBEndpoints.search, body);
      final List<dynamic> data = json.decode(response.body);
      final results = data.map((json) => SearchModel.fromJson(json)).toList();

      // Filter by result type if specified
      if (resultType != null) {
        return results.where((result) => result.resultType == resultType).toList();
      }

      return results;
    } catch (e) {
      print('💥 IGDB: Search error: $e');
      return [];
    }
  }

  @override
  Future<List<SearchModel>> searchGlobal(String query, {int limit = 50}) async {
    return await search(query: query, limit: limit);
  }

  @override
  Future<List<SearchModel>> searchGames(String query, {int limit = 20}) async {
    return await search(query: query, resultType: SearchResultType.game, limit: limit);
  }

  @override
  Future<List<SearchModel>> searchCompanies(String query, {int limit = 20}) async {
    return await search(query: query, resultType: SearchResultType.company, limit: limit);
  }

  @override
  Future<List<SearchModel>> searchPlatforms(String query, {int limit = 20}) async {
    return await search(query: query, resultType: SearchResultType.platform, limit: limit);
  }

  @override
  Future<List<SearchModel>> searchCharacters(String query, {int limit = 20}) async {
    return await search(query: query, resultType: SearchResultType.character, limit: limit);
  }

  @override
  Future<List<SearchModel>> searchCollections(String query, {int limit = 20}) async {
    return await search(query: query, resultType: SearchResultType.collection, limit: limit);
  }

  @override
  Future<List<SearchModel>> searchThemes(String query, {int limit = 20}) async {
    return await search(query: query, resultType: SearchResultType.theme, limit: limit);
  }

  @override
  Future<List<SearchModel>> getSearchSuggestions(String partialQuery, {int limit = 10}) async {
    try {
      // Use autocomplete-style search with shorter query
      if (partialQuery.length < 2) return [];

      final results = await search(query: partialQuery, limit: limit * 2);

      // Filter and sort suggestions by relevance
      final suggestions = results
          .where((result) => result.name.toLowerCase().contains(partialQuery.toLowerCase()))
          .take(limit)
          .toList();

      // Sort by name length (shorter names first for better suggestions)
      suggestions.sort((a, b) => a.name.length.compareTo(b.name.length));

      return suggestions;
    } catch (e) {
      print('💥 IGDB: Get search suggestions error: $e');
      return [];
    }
  }

  @override
  Future<List<SearchModel>> getTrendingSearches({int limit = 20}) async {
    try {
      // Search for popular gaming terms that are likely trending
      final trendingTerms = [
        'cyberpunk', 'elden ring', 'god of war', 'witcher', 'zelda',
        'pokemon', 'call of duty', 'fortnite', 'minecraft', 'gta',
        'souls', 'rpg', 'indie', 'battle royale', 'multiplayer'
      ];

      final List<SearchModel> trendingResults = [];

      for (final term in trendingTerms.take(5)) {
        final results = await search(query: term, limit: 4);
        trendingResults.addAll(results);
        if (trendingResults.length >= limit) break;
      }

      return trendingResults.take(limit).toList();
    } catch (e) {
      print('💥 IGDB: Get trending searches error: $e');
      return [];
    }
  }

  @override
  Future<List<SearchModel>> getPopularSearches({int limit = 20}) async {
    try {
      // Search for universally popular games/franchises
      final popularTerms = [
        'grand theft auto', 'call of duty', 'pokemon', 'mario',
        'zelda', 'final fantasy', 'elder scrolls', 'fallout',
        'assassins creed', 'resident evil', 'street fighter', 'tekken'
      ];

      final List<SearchModel> popularResults = [];

      for (final term in popularTerms.take(6)) {
        final results = await search(query: term, limit: 3);
        popularResults.addAll(results);
        if (popularResults.length >= limit) break;
      }

      return popularResults.take(limit).toList();
    } catch (e) {
      print('💥 IGDB: Get popular searches error: $e');
      return [];
    }
  }

  // ===== POPULARITY PRIMITIVE METHODS =====
  @override
  Future<List<PopularityPrimitiveModel>> getPopularityPrimitives({
    List<int>? ids,
    int? gameId,
    int? popularityTypeId,
    PopularitySourceEnum? source,
    int limit = 50,
  }) async {
    try {
      String body;

      const fields = '''
        id, checksum, created_at, updated_at, calculated_at, game_id,
        value, popularity_type, external_popularity_source, popularity_source
      ''';

      if (ids != null && ids.isNotEmpty) {
        final idsString = ids.join(',');
        body = '''
          where id = ($idsString);
          fields $fields;
          limit ${ids.length};
        ''';
      } else {
        List<String> conditions = [];

        if (gameId != null) {
          conditions.add('game_id = $gameId');
        }

        if (popularityTypeId != null) {
          conditions.add('popularity_type = $popularityTypeId');
        }

        if (source != null) {
          conditions.add('popularity_source = ${source.value}');
        }

        final whereClause = conditions.isNotEmpty
            ? 'where ${conditions.join(' & ')};'
            : '';

        body = '''
          fields $fields;
          $whereClause
          sort value desc;
          limit $limit;
        ''';
      }

      final response = await _makeRequestRaw(IGDBEndpoints.popularityPrimitives, body);
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => PopularityPrimitiveModel.fromJson(json)).toList();
    } catch (e) {
      print('💥 IGDB: Get popularity primitives error: $e');
      return [];
    }
  }

  @override
  Future<PopularityPrimitiveModel?> getPopularityPrimitiveById(int id) async {
    try {
      final primitives = await getPopularityPrimitives(ids: [id]);
      return primitives.isNotEmpty ? primitives.first : null;
    } catch (e) {
      print('💥 IGDB: Get popularity primitive by ID error: $e');
      return null;
    }
  }

  @override
  Future<List<PopularityPrimitiveModel>> getGamePopularityMetrics(int gameId) async {
    return await getPopularityPrimitives(gameId: gameId, limit: 50);
  }

  @override
  Future<List<PopularityPrimitiveModel>> getPopularityByType(int popularityTypeId) async {
    return await getPopularityPrimitives(popularityTypeId: popularityTypeId, limit: 100);
  }

  @override
  Future<List<PopularityPrimitiveModel>> getPopularityBySource(PopularitySourceEnum source) async {
    return await getPopularityPrimitives(source: source, limit: 100);
  }

  @override
  Future<List<PopularityPrimitiveModel>> getTopPopularGames({
    int limit = 50,
    PopularitySourceEnum? source,
    int? popularityTypeId,
  }) async {
    try {
      final primitives = await getPopularityPrimitives(
        source: source,
        popularityTypeId: popularityTypeId,
        limit: limit,
      );

      // Sort by popularity value (descending)
      primitives.sort((a, b) => b.value.compareTo(a.value));

      return primitives;
    } catch (e) {
      print('💥 IGDB: Get top popular games error: $e');
      return [];
    }
  }

  @override
  Future<List<PopularityPrimitiveModel>> getTrendingGames({
    int limit = 20,
    Duration? timeWindow,
  }) async {
    try {
      final window = timeWindow ?? const Duration(days: 7);
      final cutoffDate = DateTime.now().subtract(window);
      final cutoffTimestamp = cutoffDate.millisecondsSinceEpoch ~/ 1000;

      const body = '''
        fields id, checksum, created_at, updated_at, calculated_at, game_id,
               value, popularity_type, external_popularity_source, popularity_source;
        where calculated_at > $cutoffTimestamp;
        sort value desc;
        limit $limit;
      ''';

      final response = await _makeRequestRaw(IGDBEndpoints.popularityPrimitives, body);
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => PopularityPrimitiveModel.fromJson(json)).toList();
    } catch (e) {
      print('💥 IGDB: Get trending games error: $e');
      return [];
    }
  }

  @override
  Future<List<PopularityPrimitiveModel>> getRecentPopularityUpdates({
    int limit = 50,
    Duration? timeWindow,
  }) async {
    try {
      final window = timeWindow ?? const Duration(days: 1);
      final cutoffDate = DateTime.now().subtract(window);
      final cutoffTimestamp = cutoffDate.millisecondsSinceEpoch ~/ 1000;

      const body = '''
        fields id, checksum, created_at, updated_at, calculated_at, game_id,
               value, popularity_type, external_popularity_source, popularity_source;
        where updated_at > $cutoffTimestamp;
        sort updated_at desc;
        limit $limit;
      ''';

      final response = await _makeRequestRaw(IGDBEndpoints.popularityPrimitives, body);
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => PopularityPrimitiveModel.fromJson(json)).toList();
    } catch (e) {
      print('💥 IGDB: Get recent popularity updates error: $e');
      return [];
    }
  }

  // ===== POPULARITY TYPE METHODS =====
  @override
  Future<List<PopularityTypeModel>> getPopularityTypes({
    List<int>? ids,
    String? search,
    PopularitySourceEnum? source,
    int limit = 50,
  }) async {
    try {
      String body;

      const fields = '''
        id, checksum, name, created_at, updated_at,
        external_popularity_source, popularity_source
      ''';

      if (ids != null && ids.isNotEmpty) {
        final idsString = ids.join(',');
        body = '''
          where id = ($idsString);
          fields $fields;
          limit ${ids.length};
        ''';
      } else if (search != null) {
        String whereClause = 'search "$search";';
        if (source != null) {
          whereClause += ' where popularity_source = ${source.value};';
        }
        body = '''
          $whereClause
          fields $fields;
          limit $limit;
        ''';
      } else {
        String whereClause = '';
        if (source != null) {
          whereClause = 'where popularity_source = ${source.value};';
        }
        body = '''
          fields $fields;
          $whereClause
          sort name asc;
          limit $limit;
        ''';
      }

      final response = await _makeRequestRaw(IGDBEndpoints.popularityTypes, body);
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => PopularityTypeModel.fromJson(json)).toList();
    } catch (e) {
      print('💥 IGDB: Get popularity types error: $e');
      return [];
    }
  }

  @override
  Future<PopularityTypeModel?> getPopularityTypeById(int id) async {
    try {
      final types = await getPopularityTypes(ids: [id]);
      return types.isNotEmpty ? types.first : null;
    } catch (e) {
      print('💥 IGDB: Get popularity type by ID error: $e');
      return null;
    }
  }

  @override
  Future<List<PopularityTypeModel>> searchPopularityTypes(String query, {int limit = 20}) async {
    return await getPopularityTypes(search: query, limit: limit);
  }

  @override
  Future<List<PopularityTypeModel>> getPopularityTypesBySource(PopularitySourceEnum source) async {
    return await getPopularityTypes(source: source, limit: 50);
  }

  // ===== COMPREHENSIVE SEARCH & POPULARITY DATA =====
  @override
  Future<Map<String, dynamic>> getCompleteSearchResults(String query, {int limit = 50}) async {
    try {
      print('🔍 IGDB: Getting complete search results for "$query"');

      // Get search results
      final searchResults = await search(query: query, limit: limit);

      // Group results by type
      final gameResults = searchResults.where((r) => r.isGameResult).toList();
      final companyResults = searchResults.where((r) => r.isCompanyResult).toList();
      final platformResults = searchResults.where((r) => r.isPlatformResult).toList();
      final characterResults = searchResults.where((r) => r.isCharacterResult).toList();
      final collectionResults = searchResults.where((r) => r.isCollectionResult).toList();
      final themeResults = searchResults.where((r) => r.isThemeResult).toList();

      return {
        'query': query,
        'total_results': searchResults.length,
        'all_results': searchResults,
        'games': gameResults,
        'companies': companyResults,
        'platforms': platformResults,
        'characters': characterResults,
        'collections': collectionResults,
        'themes': themeResults,
        'result_counts': {
          'games': gameResults.length,
          'companies': companyResults.length,
          'platforms': platformResults.length,
          'characters': characterResults.length,
          'collections': collectionResults.length,
          'themes': themeResults.length,
        },
      };
    } catch (e) {
      print('💥 IGDB: Get complete search results error: $e');
      return {
        'query': query,
        'total_results': 0,
        'error': e.toString(),
      };
    }
  }

  @override
  Future<Map<String, dynamic>> getGamePopularityAnalysis(int gameId) async {
    try {
      print('📊 IGDB: Getting popularity analysis for game ID: $gameId');

      // Get all popularity metrics for the game
      final popularityMetrics = await getGamePopularityMetrics(gameId);

      if (popularityMetrics.isEmpty) {
        return {
          'game_id': gameId,
          'has_popularity_data': false,
          'message': 'No popularity data available for this game',
        };
      }

      // Calculate statistics
      final values = popularityMetrics.map((p) => p.value).toList();
      final averagePopularity = values.reduce((a, b) => a + b) / values.length;
      final maxPopularity = values.reduce((a, b) => a > b ? a : b);
      final minPopularity = values.reduce((a, b) => a < b ? a : b);

      // Group by source
      final steamMetrics = popularityMetrics.where((p) => p.isFromSteam).toList();
      final igdbMetrics = popularityMetrics.where((p) => p.isFromIgdb).toList();

      // Find latest update
      final sortedByDate = popularityMetrics
          .where((p) => p.calculatedAt != null)
          .toList()
        ..sort((a, b) => b.calculatedAt!.compareTo(a.calculatedAt!));

      return {
        'game_id': gameId,
        'has_popularity_data': true,
        'total_metrics': popularityMetrics.length,
        'statistics': {
          'average_popularity': averagePopularity,
          'max_popularity': maxPopularity,
          'min_popularity': minPopularity,
          'popularity_range': maxPopularity - minPopularity,
        },
        'by_source': {
          'steam': {
            'count': steamMetrics.length,
            'metrics': steamMetrics,
          },
          'igdb': {
            'count': igdbMetrics.length,
            'metrics': igdbMetrics,
          },
        },
        'latest_update': sortedByDate.isNotEmpty ? sortedByDate.first : null,
        'all_metrics': popularityMetrics,
      };
    } catch (e) {
      print('💥 IGDB: Get game popularity analysis error: $e');
      return {
        'game_id': gameId,
        'has_popularity_data': false,
        'error': e.toString(),
      };
    }
  }

  @override
  Future<Map<String, dynamic>> getPopularityTrends({
    int? gameId,
    Duration? timeWindow,
    PopularitySourceEnum? source,
  }) async {
    try {
      print('📈 IGDB: Getting popularity trends');

      final window = timeWindow ?? const Duration(days: 30);
      final recentUpdates = await getRecentPopularityUpdates(
        limit: 100,
        timeWindow: window,
      );

      // Filter by game and source if specified
      var filteredUpdates = recentUpdates;
      if (gameId != null) {
        filteredUpdates = filteredUpdates.where((p) => p.gameId == gameId).toList();
      }
      if (source != null) {
        filteredUpdates = filteredUpdates.where((p) => p.popularitySourceEnum == source).toList();
      }

      // Group by date for trend analysis
      final Map<String, List<PopularityPrimitiveModel>> dailyData = {};
      for (final update in filteredUpdates) {
        if (update.calculatedAt != null) {
          final dateKey = '${update.calculatedAt!.year}-${update.calculatedAt!.month.toString().padLeft(2, '0')}-${update.calculatedAt!.day.toString().padLeft(2, '0')}';
          dailyData[dateKey] = (dailyData[dateKey] ?? [])..add(update);
        }
      }

      // Calculate daily averages
      final dailyAverages = dailyData.map((date, updates) {
        final averageValue = updates.map((u) => u.value).reduce((a, b) => a + b) / updates.length;
        return MapEntry(date, averageValue);
      });

      return {
        'time_window_days': window.inDays,
        'total_updates': filteredUpdates.length,
        'game_id': gameId,
        'source': source?.displayName,
        'daily_data': dailyData,
        'daily_averages': dailyAverages,
        'trend_direction': _calculateTrendDirection(dailyAverages),
        'all_updates': filteredUpdates,
      };
    } catch (e) {
      print('💥 IGDB: Get popularity trends error: $e');
      return {
        'error': e.toString(),
      };
    }
  }

  // ===== ADVANCED SEARCH METHODS =====
  @override
  Future<List<SearchModel>> searchWithFilters({
    required String query,
    SearchResultType? resultType,
    DateTime? publishedAfter,
    DateTime? publishedBefore,
    int limit = 50,
  }) async {
    try {
      final results = await search(query: query, resultType: resultType, limit: limit);

      // Apply date filters
      var filteredResults = results;

      if (publishedAfter != null) {
        filteredResults = filteredResults.where((result) {
          return result.publishedAt != null && result.publishedAt!.isAfter(publishedAfter);
        }).toList();
      }

      if (publishedBefore != null) {
        filteredResults = filteredResults.where((result) {
          return result.publishedAt != null && result.publishedAt!.isBefore(publishedBefore);
        }).toList();
      }

      return filteredResults;
    } catch (e) {
      print('💥 IGDB: Search with filters error: $e');
      return [];
    }
  }

  @override
  Future<List<SearchModel>> autocompleteSearch(String partialQuery, {int limit = 10}) async {
    return await getSearchSuggestions(partialQuery, limit: limit);
  }

  @override
  Future<List<String>> getSearchHistory() async {
    try {
      // This would typically be stored locally or in a database
      // For now, return empty list as it requires local storage implementation
      return [];
    } catch (e) {
      print('💥 IGDB: Get search history error: $e');
      return [];
    }
  }

  @override
  Future<void> saveSearchQuery(String query) async {
    try {
      // This would typically save to local storage or database
      // For now, just log the query
      print('💾 IGDB: Saving search query: $query');
    } catch (e) {
      print('💥 IGDB: Save search query error: $e');
    }
  }

  // ===== POPULARITY ANALYTICS =====
  @override
  Future<List<Map<String, dynamic>>> getPopularityLeaderboard({
    PopularitySourceEnum? source,
    int? popularityTypeId,
    int limit = 100,
  }) async {
    try {
      final primitives = await getTopPopularGames(
        limit: limit,
        source: source,
        popularityTypeId: popularityTypeId,
      );

      return primitives.asMap().entries.map((entry) {
        final index = entry.key;
        final primitive = entry.value;

        return {
          'rank': index + 1,
          'game_id': primitive.gameId,
          'popularity_value': primitive.value,
          'popularity_level': primitive.popularityLevel,
          'source': primitive.sourceDisplayName,
          'calculated_at': primitive.calculatedAt?.toIso8601String(),
          'is_fresh': primitive.isFresh,
          'is_stale': primitive.isStale,
        };
      }).toList();
    } catch (e) {
      print('💥 IGDB: Get popularity leaderboard error: $e');
      return [];
    }
  }

  @override
  Future<Map<String, dynamic>> getPopularityStatistics(int gameId) async {
    return await getGamePopularityAnalysis(gameId);
  }

  @override
  Future<List<PopularityPrimitiveModel>> getPopularityChanges({
    int? gameId,
    Duration? timeWindow,
    int limit = 50,
  }) async {
    return await getRecentPopularityUpdates(
      limit: limit,
      timeWindow: timeWindow,
    );
  }

  // ===== SEARCH ANALYTICS =====
  @override
  Future<Map<String, dynamic>> getSearchAnalytics() async {
    try {
      // Get trending and popular searches for analytics
      final trending = await getTrendingSearches(limit: 10);
      final popular = await getPopularSearches(limit: 10);

      return {
        'trending_searches': trending,
        'popular_searches': popular,
        'total_trending': trending.length,
        'total_popular': popular.length,
        'analysis_timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      print('💥 IGDB: Get search analytics error: $e');
      return {
        'error': e.toString(),
      };
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getSearchStatistics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      // This would typically analyze search logs stored in a database
      // For now, return empty list as it requires search logging implementation
      return [];
    } catch (e) {
      print('💥 IGDB: Get search statistics error: $e');
      return [];
    }
  }

  // ===== HELPER METHODS =====

  String _calculateTrendDirection(Map<String, double> dailyAverages) {
    if (dailyAverages.length < 2) return 'insufficient_data';

    final values = dailyAverages.values.toList();
    final firstValue = values.first;
    final lastValue = values.last;

    if (lastValue > firstValue) return 'increasing';
    if (lastValue < firstValue) return 'decreasing';
    return 'stable';
  }

  @override
  Future<List<DateFormatModel>> getDateFormats({List<int>? ids}) async {
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
          limit 20;
        ''';
      }

      final response = await _makeRequestRaw(IGDBEndpoints.dateFormats, body);
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => DateFormatModel.fromJson(json)).toList();
    } catch (e) {
      print('💥 IGDB: Get date formats error: $e');
      return [];
    }
  }

  @override
  Future<DateFormatModel?> getDateFormatById(int id) async {
    final formats = await getDateFormats(ids: [id]);
    return formats.isNotEmpty ? formats.first : null;
  }

  // ===== WEBSITE TYPE METHODS =====

  @override
  Future<List<WebsiteTypeModel>> getWebsiteTypes({List<int>? ids}) async {
    try {
      String body;
      if (ids != null && ids.isNotEmpty) {
        final idsString = ids.join(',');
        body = '''
          where id = ($idsString);
          fields id, checksum, type, created_at, updated_at;
          limit ${ids.length};
        ''';
      } else {
        body = '''
          fields id, checksum, type, created_at, updated_at;
          sort type asc;
          limit 50;
        ''';
      }

      final response = await _makeRequestRaw(IGDBEndpoints.websiteTypes, body);
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => WebsiteTypeModel.fromJson(json)).toList();
    } catch (e) {
      print('💥 IGDB: Get website types error: $e');
      return [];
    }
  }

  @override
  Future<WebsiteTypeModel?> getWebsiteTypeById(int id) async {
    final types = await getWebsiteTypes(ids: [id]);
    return types.isNotEmpty ? types.first : null;
  }

  // ===== LANGUAGE METHODS =====

  @override
  Future<List<LanguageModel>> getLanguages({
    List<int>? ids,
    String? search,
  }) async {
    try {
      String body;

      if (ids != null && ids.isNotEmpty) {
        final idsString = ids.join(',');
        body = '''
          where id = ($idsString);
          fields id, checksum, locale, name, native_name, created_at, updated_at;
          limit ${ids.length};
        ''';
      } else if (search != null && search.isNotEmpty) {
        body = '''
          search "$search";
          fields id, checksum, locale, name, native_name, created_at, updated_at;
          limit 50;
        ''';
      } else {
        body = '''
          fields id, checksum, locale, name, native_name, created_at, updated_at;
          sort name asc;
          limit 200;
        ''';
      }

      final response = await _makeRequestRaw(IGDBEndpoints.languages, body);
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => LanguageModel.fromJson(json)).toList();
    } catch (e) {
      print('💥 IGDB: Get languages error: $e');
      return [];
    }
  }

  @override
  Future<LanguageModel?> getLanguageById(int id) async {
    final languages = await getLanguages(ids: [id]);
    return languages.isNotEmpty ? languages.first : null;
  }

  @override
  Future<List<LanguageModel>> getLanguagesByLocale(List<String> locales) async {
    try {
      final localesString = locales.map((l) => '"$l"').join(',');
      final body = '''
        where locale = ($localesString);
        fields id, checksum, locale, name, native_name, created_at, updated_at;
        limit ${locales.length};
      ''';

      final response = await _makeRequestRaw(IGDBEndpoints.languages, body);
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => LanguageModel.fromJson(json)).toList();
    } catch (e) {
      print('💥 IGDB: Get languages by locale error: $e');
      return [];
    }
  }

  // ===== LANGUAGE SUPPORT TYPE METHODS =====

  @override
  Future<List<LanguageSupportTypeModel>> getLanguageSupportTypes({
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
          limit 20;
        ''';
      }

      final response = await _makeRequestRaw(IGDBEndpoints.languageSupportTypes, body);
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => LanguageSupportTypeModel.fromJson(json)).toList();
    } catch (e) {
      print('💥 IGDB: Get language support types error: $e');
      return [];
    }
  }

  @override
  Future<LanguageSupportTypeModel?> getLanguageSupportTypeById(int id) async {
    final types = await getLanguageSupportTypes(ids: [id]);
    return types.isNotEmpty ? types.first : null;
  }

  // Helper method to get language supports with full details
  Future<List<LanguageSupportModel>> getLanguageSupportsWithDetails(
      List<int> gameIds,
      ) async {
    try {
      if (gameIds.isEmpty) return [];

      final idsString = gameIds.join(',');
      final body = '''
        where game = ($idsString);
        fields id, checksum, game, 
               language.id, language.locale, language.name, language.native_name,
               language_support_type.id, language_support_type.name,
               created_at, updated_at;
        limit 500;
      ''';

      final response = await _makeRequestRaw(IGDBEndpoints.languageSupports, body);
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => LanguageSupportModel.fromJson(json)).toList();
    } catch (e) {
      print('💥 IGDB: Get language supports with details error: $e');
      return [];
    }
  }

  // Add these implementations to IGDBRemoteDataSourceImpl class:
// File: lib/data/datasources/remote/igdb_remote_datasource_impl.dart



  @override
  Future<List<RegionModel>> getRegions({
    List<int>? ids,
    String? category,
  }) async {
    try {
      String body;

      if (ids != null && ids.isNotEmpty) {
        final idsString = ids.join(',');
        body = '''
          where id = ($idsString);
          fields id, checksum, category, identifier, name, created_at, updated_at;
          limit ${ids.length};
        ''';
      } else if (category != null) {
        body = '''
          where category = "$category";
          fields id, checksum, category, identifier, name, created_at, updated_at;
          sort name asc;
          limit 100;
        ''';
      } else {
        body = '''
          fields id, checksum, category, identifier, name, created_at, updated_at;
          sort name asc;
          limit 200;
        ''';
      }

      final response = await _makeRequestRaw(IGDBEndpoints.regions, body);
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => RegionModel.fromJson(json)).toList();
    } catch (e) {
      print('💥 IGDB: Get regions error: $e');
      return [];
    }
  }

  @override
  Future<RegionModel?> getRegionById(int id) async {
    final regions = await getRegions(ids: [id]);
    return regions.isNotEmpty ? regions.first : null;
  }

  @override
  Future<List<RegionModel>> getRegionsByIdentifiers(List<String> identifiers) async {
    try {
      final identifiersString = identifiers.map((i) => '"$i"').join(',');
      final body = '''
        where identifier = ($identifiersString);
        fields id, checksum, category, identifier, name, created_at, updated_at;
        limit ${identifiers.length};
      ''';

      final response = await _makeRequestRaw(IGDBEndpoints.regions, body);
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => RegionModel.fromJson(json)).toList();
    } catch (e) {
      print('💥 IGDB: Get regions by identifiers error: $e');
      return [];
    }
  }

  @override
  Future<List<RegionModel>> getLocaleRegions() async {
    return getRegions(category: 'locale');
  }

  @override
  Future<List<RegionModel>> getContinentRegions() async {
    return getRegions(category: 'continent');
  }

  // ===== PLATFORM VERSION IMPLEMENTATIONS =====

  @override
  Future<List<PlatformVersionModel>> getPlatformVersions({
    List<int>? ids,
    int? platformId,
    bool includeReleaseDates = false,
  }) async {
    try {
      String fields = '''
        id, checksum, connectivity, cpu, graphics, main_manufacturer,
        media, memory, name, os, output, platform_logo, resolutions,
        slug, sound, storage, summary, url, companies
      ''';

      if (includeReleaseDates) {
        fields += ', platform_version_release_dates';
      }

      String body;

      if (ids != null && ids.isNotEmpty) {
        final idsString = ids.join(',');
        body = '''
          where id = ($idsString);
          fields $fields;
          limit ${ids.length};
        ''';
      } else if (platformId != null) {
        // Note: Platform versions are linked through platform.versions field
        // This query would need to be adjusted based on actual API structure
        body = '''
          fields $fields;
          limit 100;
        ''';
      } else {
        body = '''
          fields $fields;
          sort name asc;
          limit 200;
        ''';
      }

      final response = await _makeRequestRaw(IGDBEndpoints.platformVersions, body);
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => PlatformVersionModel.fromJson(json)).toList();
    } catch (e) {
      print('💥 IGDB: Get platform versions error: $e');
      return [];
    }
  }

  @override
  Future<PlatformVersionModel?> getPlatformVersionById(int id) async {
    final versions = await getPlatformVersions(ids: [id]);
    return versions.isNotEmpty ? versions.first : null;
  }

  @override
  Future<List<PlatformVersionModel>> getPlatformVersionsByPlatformId(int platformId) async {
    // First get the platform to get its version IDs
    final platforms = await getPlatforms(ids: [platformId]);
    if (platforms.isEmpty) return [];

    final versionIds = platforms.first.versionIds;
    if (versionIds.isEmpty) return [];

    return getPlatformVersions(ids: versionIds);
  }

  @override
  Future<List<Map<String, dynamic>>> getPlatformVersionsWithDetails(List<int> versionIds) async {
    try {
      if (versionIds.isEmpty) return [];

      // 1. Get platform versions
      final versions = await getPlatformVersions(ids: versionIds, includeReleaseDates: true);

      // 2. Get all company IDs
      final companyIds = <int>{};
      for (final version in versions) {
        companyIds.addAll(version.companyIds);
        if (version.mainManufacturerId != null) {
          companyIds.add(version.mainManufacturerId!);
        }
      }

      // 3. Get companies
      final companies = companyIds.isNotEmpty
          ? await getCompaniesByVersionIds(versionIds.toList())
          : <PlatformVersionCompanyModel>[];

      // 4. Get release dates
      final releaseDates = await getReleaseDatesByVersionIds(versionIds);

      // 5. Combine data
      return versions.map((version) {
        return {
          'version': version,
          'companies': companies.where((c) =>
          version.companyIds.contains(c.companyId) ||
              c.companyId == version.mainManufacturerId
          ).toList(),
          'releaseDates': releaseDates.where((rd) =>
          rd.platformVersionId == version.id
          ).toList(),
        };
      }).toList();
    } catch (e) {
      print('💥 IGDB: Get platform versions with details error: $e');
      return [];
    }
  }

  // ===== PLATFORM VERSION COMPANY IMPLEMENTATIONS =====

  @override
  Future<List<PlatformVersionCompanyModel>> getPlatformVersionCompanies({
    List<int>? ids,
    List<int>? versionIds,
  }) async {
    try {
      String body;

      if (ids != null && ids.isNotEmpty) {
        final idsString = ids.join(',');
        body = '''
          where id = ($idsString);
          fields id, checksum, comment, company, developer, manufacturer;
          limit ${ids.length};
        ''';
      } else if (versionIds != null && versionIds.isNotEmpty) {
        // This would need adjustment based on actual API structure
        body = '''
          fields id, checksum, comment, company, developer, manufacturer;
          limit 500;
        ''';
      } else {
        body = '''
          fields id, checksum, comment, company, developer, manufacturer;
          limit 100;
        ''';
      }

      final response = await _makeRequestRaw(IGDBEndpoints.platformVersionCompanies, body);
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => PlatformVersionCompanyModel.fromJson(json)).toList();
    } catch (e) {
      print('💥 IGDB: Get platform version companies error: $e');
      return [];
    }
  }

  @override
  Future<List<PlatformVersionCompanyModel>> getCompaniesByVersionIds(List<int> versionIds) async {
    return getPlatformVersionCompanies(versionIds: versionIds);
  }

  // ===== PLATFORM VERSION RELEASE DATE IMPLEMENTATIONS =====

  @override
  Future<List<PlatformVersionReleaseDateModel>> getPlatformVersionReleaseDates({
    List<int>? ids,
    List<int>? versionIds,
    int? regionId,
  }) async {
    try {
      String body;
      String whereConditions = [];

      if (ids != null && ids.isNotEmpty) {
        whereConditions.add('id = (${ids.join(',')})');
      }

      if (versionIds != null && versionIds.isNotEmpty) {
        whereConditions.add('platform_version = (${versionIds.join(',')})');
      }

      if (regionId != null) {
        whereConditions.add('release_region = $regionId');
      }

      if (whereConditions.isNotEmpty) {
        body = '''
          where ${whereConditions.join(' & ')};
          fields id, checksum, date, date_format, human, m, y,
                 platform_version, release_region, created_at, updated_at;
          limit 500;
        ''';
      } else {
        body = '''
          fields id, checksum, date, date_format, human, m, y,
                 platform_version, release_region, created_at, updated_at;
          sort date asc;
          limit 100;
        ''';
      }

      final response = await _makeRequestRaw(IGDBEndpoints.platformVersionReleaseDates, body);
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => PlatformVersionReleaseDateModel.fromJson(json)).toList();
    } catch (e) {
      print('💥 IGDB: Get platform version release dates error: $e');
      return [];
    }
  }

  @override
  Future<List<PlatformVersionReleaseDateModel>> getReleaseDatesByVersionIds(List<int> versionIds) async {
    return getPlatformVersionReleaseDates(versionIds: versionIds);
  }

  @override
  Future<List<PlatformVersionReleaseDateModel>> getReleaseDatesByRegion(int regionId) async {
    return getPlatformVersionReleaseDates(regionId: regionId);
  }

  // ===== PLATFORM WEBSITE IMPLEMENTATIONS =====

  @override
  Future<List<PlatformWebsiteModel>> getPlatformWebsites({
    List<int>? ids,
    List<int>? platformIds,
  }) async {
    try {
      String body;

      if (ids != null && ids.isNotEmpty) {
        final idsString = ids.join(',');
        body = '''
          where id = ($idsString);
          fields id, checksum, url, trusted, type, category;
          limit ${ids.length};
        ''';
      } else if (platformIds != null && platformIds.isNotEmpty) {
        // Platform websites are linked through platform.websites field
        // This query would need adjustment
        body = '''
          fields id, checksum, url, trusted, type, category;
          limit 200;
        ''';
      } else {
        body = '''
          fields id, checksum, url, trusted, type, category;
          limit 100;
        ''';
      }

      final response = await _makeRequestRaw(IGDBEndpoints.platformWebsites, body);
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => PlatformWebsiteModel.fromJson(json)).toList();
    } catch (e) {
      print('💥 IGDB: Get platform websites error: $e');
      return [];
    }
  }

  @override
  Future<List<PlatformWebsiteModel>> getWebsitesByPlatformIds(List<int> platformIds) async {
    // First get platforms to get their website IDs
    final platforms = await getPlatforms(ids: platformIds);
    final websiteIds = <int>{};

    for (final platform in platforms) {
      websiteIds.addAll(platform.websiteIds);
    }

    if (websiteIds.isEmpty) return [];

    return getPlatformWebsites(ids: websiteIds.toList());
  }

  @override
  Future<List<PlatformWebsiteModel>> getPlatformWebsitesByType(int typeId) async {
    try {
      final body = '''
        where type = $typeId;
        fields id, checksum, url, trusted, type, category;
        limit 200;
      ''';

      final response = await _makeRequestRaw(IGDBEndpoints.platformWebsites, body);
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => PlatformWebsiteModel.fromJson(json)).toList();
    } catch (e) {
      print('💥 IGDB: Get platform websites by type error: $e');
      return [];
    }
  }

  // ===== HELPER IMPLEMENTATIONS =====

  @override
  Future<Map<String, dynamic>> getCompletePlatformDataWithVersions(int platformId) async {
    try {
      // 1. Get platform
      final platforms = await getPlatforms(ids: [platformId]);
      if (platforms.isEmpty) return {};

      final platform = platforms.first;

      // 2. Get versions with details
      final versionsWithDetails = await getPlatformVersionsWithDetails(platform.versionIds);

      // 3. Get platform websites
      final websites = await getWebsitesByPlatformIds([platformId]);

      // 4. Get platform logo if exists
      PlatformLogoModel? logo;
      if (platform.platformLogoId != null) {
        final logos = await getPlatformLogos([platform.platformLogoId!]);
        logo = logos.isNotEmpty ? logos.first : null;
      }

      return {
        'platform': platform,
        'logo': logo,
        'versions': versionsWithDetails,
        'websites': websites,
      };
    } catch (e) {
      print('💥 IGDB: Get complete platform data error: $e');
      return {};
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getPlatformVersionHistory(int platformId) async {
    try {
      // 1. Get platform versions
      final versions = await getPlatformVersionsByPlatformId(platformId);

      // 2. Get all release dates
      final versionIds = versions.map((v) => v.id).toList();
      final releaseDates = await getReleaseDatesByVersionIds(versionIds);

      // 3. Sort by release date
      final history = <Map<String, dynamic>>[];

      for (final version in versions) {
        final versionDates = releaseDates
            .where((rd) => rd.platformVersionId == version.id)
            .toList()
          ..sort((a, b) => (a.date ?? DateTime(2100))
              .compareTo(b.date ?? DateTime(2100)));

        history.add({
          'version': version,
          'releaseDates': versionDates,
          'firstReleaseDate': versionDates.isNotEmpty ? versionDates.first.date : null,
        });
      }

      // Sort by first release date
      history.sort((a, b) {
        final dateA = a['firstReleaseDate'] as DateTime?;
        final dateB = b['firstReleaseDate'] as DateTime?;
        if (dateA == null && dateB == null) return 0;
        if (dateA == null) return 1;
        if (dateB == null) return -1;
        return dateA.compareTo(dateB);
      });

      return history;
    } catch (e) {
      print('💥 IGDB: Get platform version history error: $e');
      return [];
    }
  }

  @override
  Future<List<PlatformModel>> getPlatformsByRegion(int regionId) async {
    try {
      // First get release dates for the region
      final releaseDates = await getPlatformVersionReleaseDates(regionId: regionId);

      // Get unique platform version IDs
      final versionIds = releaseDates
          .map((rd) => rd.platformVersionId)
          .where((id) => id != null)
          .toSet()
          .cast<int>()
          .toList();

      if (versionIds.isEmpty) return [];

      // Get platform versions
      final versions = await getPlatformVersions(ids: versionIds);

      // Get platforms that have these versions
      // This would need to query platforms by their version IDs
      // Implementation depends on actual API structure

      return [];
    } catch (e) {
      print('💥 IGDB: Get platforms by region error: $e');
      return [];
    }
  }



  // ===== GAME STATUS IMPLEMENTATIONS =====

  @override
  Future<List<GameStatusModel>> getGameStatuses({List<int>? ids}) async {
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
          sort id asc;
          limit 20;
        ''';
      }

      final response = await _makeRequestRaw(IGDBEndpoints.gameStatuses, body);
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => GameStatusModel.fromJson(json)).toList();
    } catch (e) {
      print('💥 IGDB: Get game statuses error: $e');
      return [];
    }
  }

  @override
  Future<GameStatusModel?> getGameStatusById(int id) async {
    final statuses = await getGameStatuses(ids: [id]);
    return statuses.isNotEmpty ? statuses.first : null;
  }

  // ===== GAME TIME TO BEAT IMPLEMENTATIONS =====

  @override
  Future<List<GameTimeToBeatModel>> getGameTimesToBeat({
    List<int>? ids,
    List<int>? gameIds,
  }) async {
    try {
      String body;
      String whereConditions = [];

      if (ids != null && ids.isNotEmpty) {
        whereConditions.add('id = (${ids.join(',')})');
      }

      if (gameIds != null && gameIds.isNotEmpty) {
        whereConditions.add('game = (${gameIds.join(',')})');
      }

      if (whereConditions.isNotEmpty) {
        body = '''
          where ${whereConditions.join(' & ')};
          fields id, checksum, game, hastily, normally, completely, 
                 created_at, updated_at;
          limit ${ids?.length ?? gameIds?.length ?? 100};
        ''';
      } else {
        body = '''
          fields id, checksum, game, hastily, normally, completely, 
                 created_at, updated_at;
          limit 100;
        ''';
      }

      final response = await _makeRequestRaw(IGDBEndpoints.gameTimesToBeat, body);
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => GameTimeToBeatModel.fromJson(json)).toList();
    } catch (e) {
      print('💥 IGDB: Get game times to beat error: $e');
      return [];
    }
  }

  @override
  Future<GameTimeToBeatModel?> getGameTimeToBeatByGameId(int gameId) async {
    final times = await getGameTimesToBeat(gameIds: [gameId]);
    return times.isNotEmpty ? times.first : null;
  }

  // ===== GAME TYPE IMPLEMENTATIONS =====

  @override
  Future<List<GameTypeModel>> getGameTypes({List<int>? ids}) async {
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
          sort id asc;
          limit 20;
        ''';
      }

      final response = await _makeRequestRaw(IGDBEndpoints.gameTypes, body);
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => GameTypeModel.fromJson(json)).toList();
    } catch (e) {
      print('💥 IGDB: Get game types error: $e');
      return [];
    }
  }

  @override
  Future<GameTypeModel?> getGameTypeById(int id) async {
    final types = await getGameTypes(ids: [id]);
    return types.isNotEmpty ? types.first : null;
  }

  // ===== GAME VERSION IMPLEMENTATIONS =====

  @override
  Future<List<GameVersionModel>> getGameVersions({
    List<int>? ids,
    int? mainGameId,
  }) async {
    try {
      String body;

      if (ids != null && ids.isNotEmpty) {
        final idsString = ids.join(',');
        body = '''
          where id = ($idsString);
          fields id, checksum, game, features, games, url, 
                 created_at, updated_at;
          limit ${ids.length};
        ''';
      } else if (mainGameId != null) {
        body = '''
          where game = $mainGameId;
          fields id, checksum, game, features, games, url, 
                 created_at, updated_at;
          limit 100;
        ''';
      } else {
        body = '''
          fields id, checksum, game, features, games, url, 
                 created_at, updated_at;
          limit 100;
        ''';
      }

      final response = await _makeRequestRaw(IGDBEndpoints.gameVersions, body);
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => GameVersionModel.fromJson(json)).toList();
    } catch (e) {
      print('💥 IGDB: Get game versions error: $e');
      return [];
    }
  }

  @override
  Future<GameVersionModel?> getGameVersionById(int id) async {
    final versions = await getGameVersions(ids: [id]);
    return versions.isNotEmpty ? versions.first : null;
  }

  @override
  Future<List<GameVersionModel>> getGameVersionsByMainGame(int gameId) async {
    return getGameVersions(mainGameId: gameId);
  }

  // ===== GAME VERSION FEATURE IMPLEMENTATIONS =====

  @override
  Future<List<GameVersionFeatureModel>> getGameVersionFeatures({
    List<int>? ids,
    String? category,
  }) async {
    try {
      String body;

      if (ids != null && ids.isNotEmpty) {
        final idsString = ids.join(',');
        body = '''
          where id = ($idsString);
          fields id, checksum, title, description, category, position, values;
          limit ${ids.length};
        ''';
      } else if (category != null) {
        body = '''
          where category = "$category";
          fields id, checksum, title, description, category, position, values;
          sort position asc;
          limit 100;
        ''';
      } else {
        body = '''
          fields id, checksum, title, description, category, position, values;
          sort position asc;
          limit 200;
        ''';
      }

      final response = await _makeRequestRaw(IGDBEndpoints.gameVersionFeatures, body);
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => GameVersionFeatureModel.fromJson(json)).toList();
    } catch (e) {
      print('💥 IGDB: Get game version features error: $e');
      return [];
    }
  }

  @override
  Future<GameVersionFeatureModel?> getGameVersionFeatureById(int id) async {
    final features = await getGameVersionFeatures(ids: [id]);
    return features.isNotEmpty ? features.first : null;
  }

  @override
  Future<List<GameVersionFeatureModel>> getGameVersionFeaturesByCategory(String category) async {
    return getGameVersionFeatures(category: category);
  }

  // ===== GAME VERSION FEATURE VALUE IMPLEMENTATIONS =====

  @override
  Future<List<GameVersionFeatureValueModel>> getGameVersionFeatureValues({
    List<int>? ids,
    List<int>? gameIds,
    List<int>? featureIds,
  }) async {
    try {
      String body;
      List<String> whereConditions = [];

      if (ids != null && ids.isNotEmpty) {
        whereConditions.add('id = (${ids.join(',')})');
      }

      if (gameIds != null && gameIds.isNotEmpty) {
        whereConditions.add('game = (${gameIds.join(',')})');
      }

      if (featureIds != null && featureIds.isNotEmpty) {
        whereConditions.add('game_feature = (${featureIds.join(',')})');
      }

      if (whereConditions.isNotEmpty) {
        body = '''
          where ${whereConditions.join(' & ')};
          fields id, checksum, game, game_feature, included_feature, note;
          limit 500;
        ''';
      } else {
        body = '''
          fields id, checksum, game, game_feature, included_feature, note;
          limit 100;
        ''';
      }

      final response = await _makeRequestRaw(IGDBEndpoints.gameVersionFeatureValues, body);
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => GameVersionFeatureValueModel.fromJson(json)).toList();
    } catch (e) {
      print('💥 IGDB: Get game version feature values error: $e');
      return [];
    }
  }

  @override
  Future<List<GameVersionFeatureValueModel>> getFeatureValuesByGame(int gameId) async {
    return getGameVersionFeatureValues(gameIds: [gameId]);
  }

  @override
  Future<List<GameVersionFeatureValueModel>> getFeatureValuesByFeature(int featureId) async {
    return getGameVersionFeatureValues(featureIds: [featureId]);
  }

  // ===== ENHANCED GAME IMPLEMENTATIONS =====

  @override
  Future<GameModel> getCompleteGameDetails(int gameId) async {
    try {
      final body = '''
        where id = $gameId;
        fields *,
          game_type.*,
          game_status.*,
          time_to_beat.*,
          version_parent.*,
          version_title,
          game_localizations.*,
          involved_companies.company.*,
          involved_companies.developer,
          involved_companies.publisher,
          involved_companies.porting,
          involved_companies.supporting,
          game_engines.*,
          game_modes.*,
          genres.*,
          keywords.*,
          multiplayer_modes.*,
          player_perspectives.*,
          platforms.*,
          release_dates.*,
          screenshots.*,
          themes.*,
          videos.*,
          websites.*,
          language_supports.*,
          age_ratings.*,
          artworks.*,
          bundles.*,
          collection.*,
          cover.*,
          dlcs.*,
          expanded_games.*,
          expansions.*,
          follows,
          franchise.*,
          franchises.*,
          hypes,
          parent_game.*,
          ports.*,
          remakes.*,
          remasters.*,
          similar_games.*,
          standalone_expansions.*,
          tags;
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
  Future<List<GameModel>> getGamesByStatus(int statusId, {int limit = 20, int offset = 0}) async {
    try {
      final body = '''
        where game_status = $statusId;
        fields ${_gameDetailFields};
        limit $limit;
        offset $offset;
      ''';

      return await _makeRequest(IGDBEndpoints.games, body);
    } catch (e) {
      print('💥 IGDB: Get games by status error: $e');
      return [];
    }
  }

  @override
  Future<List<GameModel>> getGamesByType(int typeId, {int limit = 20, int offset = 0}) async {
    try {
      final body = '''
        where game_type = $typeId;
        fields ${_gameDetailFields};
        limit $limit;
        offset $offset;
      ''';

      return await _makeRequest(IGDBEndpoints.games, body);
    } catch (e) {
      print('💥 IGDB: Get games by type error: $e');
      return [];
    }
  }

  @override
  Future<Map<String, dynamic>> getGameWithVersionFeatures(int gameId) async {
    try {
      // 1. Get game details
      final game = await getGameDetails(gameId);

      // 2. Get game versions
      final versions = await getGameVersionsByMainGame(gameId);

      // 3. Get all feature IDs
      final featureIds = <int>{};
      for (final version in versions) {
        featureIds.addAll(version.featureIds);
      }

      // 4. Get features
      final features = featureIds.isNotEmpty
          ? await getGameVersionFeatures(ids: featureIds.toList())
          : <GameVersionFeatureModel>[];

      // 5. Get feature values for this game
      final featureValues = await getFeatureValuesByGame(gameId);

      return {
        'game': game,
        'versions': versions,
        'features': features,
        'featureValues': featureValues,
      };
    } catch (e) {
      print('💥 IGDB: Get game with version features error: $e');
      return {};
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getGamesSortedByTimeToBeat({
    String sortBy = 'normally',
    int limit = 20,
  }) async {
    try {
      // Note: IGDB API doesn't support direct sorting by time_to_beat fields
      // So we need to fetch games with time_to_beat data and sort locally

      final body = '''
        where time_to_beat != null;
        fields id, name, cover.url, time_to_beat.*;
        limit 100;
      ''';

      final response = await _makeRequestRaw(IGDBEndpoints.games, body);
      final List<dynamic> data = json.decode(response.body);

      // Parse and sort
      final gamesWithTime = <Map<String, dynamic>>[];

      for (final gameData in data) {
        if (gameData['time_to_beat'] != null) {
          final game = GameModel.fromJson(gameData);
          final timeToBeat = GameTimeToBeatModel.fromJson(gameData['time_to_beat']);

          // Only include if the requested sort field has a value
          int? sortValue;
          switch (sortBy) {
            case 'hastily':
              sortValue = timeToBeat.hastily;
              break;
            case 'completely':
              sortValue = timeToBeat.completely;
              break;
            default:
              sortValue = timeToBeat.normally;
          }

          if (sortValue != null) {
            gamesWithTime.add({
              'game': game,
              'timeToBeat': timeToBeat,
              'sortValue': sortValue,
            });
          }
        }
      }

      // Sort by the requested field
      gamesWithTime.sort((a, b) => a['sortValue'].compareTo(b['sortValue']));

      // Return limited results
      return gamesWithTime.take(limit).toList();
    } catch (e) {
      print('💥 IGDB: Get games sorted by time to beat error: $e');
      return [];
    }
  }




}
