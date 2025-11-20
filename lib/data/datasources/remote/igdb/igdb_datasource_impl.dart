// lib/data/datasources/remote/igdb/igdb_datasource_impl.dart

import 'package:dio/dio.dart';
import 'package:gamer_grove/data/models/ageRating/age_rating_category_model.dart';
import 'package:gamer_grove/data/models/game/game_mode_model.dart';
import 'package:gamer_grove/data/models/game/game_status_model.dart';
import 'package:gamer_grove/data/models/game/game_type_model.dart';
import 'package:gamer_grove/data/models/language/lanuage_model.dart';
import 'package:gamer_grove/data/models/player_perspective_model.dart';
import 'package:gamer_grove/data/models/theme_model.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../models/game/game_model.dart';
import '../../../models/character/character_model.dart';
import '../../../models/platform/platform_model.dart';
import '../../../models/company/company_model.dart';
import '../../../models/event/event_model.dart';
import '../../../models/game/game_engine_model.dart';
import '../../../models/genre_model.dart';
import '../../../models/franchise_model.dart';
import '../../../models/collection/collection_model.dart';
import '../../../models/keyword_model.dart';
import '../../../models/multiplayer_mode_model.dart';
import 'igdb_datasource.dart';
import 'models/igdb_query.dart';

/// Implementation of [IgdbDataSource] using Dio HTTP client.
///
/// This implementation handles:
/// - Authentication with IGDB API (via Twitch OAuth)
/// - Query string construction
/// - HTTP requests and responses
/// - Error handling and mapping to exceptions
/// - Response parsing to Model instances
///
/// All query methods follow the same pattern:
/// 1. Ensure valid auth token
/// 2. Build query string from IgdbQuery
/// 3. Make POST request to appropriate endpoint
/// 4. Parse JSON response to typed models
/// 5. Handle errors appropriately
class IgdbDataSourceImpl implements IgdbDataSource {
  final Dio dio;
  final String baseUrl;

  // Cache for auth tokens (in a real app, use a proper token manager)
  String? _cachedAccessToken;
  DateTime? _tokenExpiryTime;

  IgdbDataSourceImpl({
    required this.dio,
    this.baseUrl = 'https://api.igdb.com/v4',
  });

  // ============================================================
  // GAME QUERIES IMPLEMENTATION
  // ============================================================

  @override
  Future<List<GameModel>> queryGames(IgdbGameQuery query) async {
    return await _executeQuery<GameModel>(
      endpoint: 'games',
      query: query,
      parser: (json) => GameModel.fromJson(json),
    );
  }

  // ============================================================
  // CHARACTER QUERIES IMPLEMENTATION
  // ============================================================

  @override
  Future<List<CharacterModel>> queryCharacters(IgdbCharacterQuery query) async {
    // Debug log: show the constructed IGDB query for characters
    try {
      query.buildQuery();
    } catch (e) {
      // If buildQuery throws for any reason, still proceed but log the error
    }

    return await _executeQuery<CharacterModel>(
      endpoint: 'characters',
      query: query,
      parser: (json) => CharacterModel.fromJson(json),
    );
  }

  // ============================================================
  // PLATFORM QUERIES IMPLEMENTATION
  // ============================================================

  @override
  Future<List<PlatformModel>> queryPlatforms(IgdbPlatformQuery query) async {
    return await _executeQuery<PlatformModel>(
      endpoint: 'platforms',
      query: query,
      parser: (json) => PlatformModel.fromJson(json),
    );
  }

  // ============================================================
  // COMPANY QUERIES IMPLEMENTATION
  // ============================================================

  @override
  Future<List<CompanyModel>> queryCompanies(IgdbCompanyQuery query) async {
    return await _executeQuery<CompanyModel>(
      endpoint: 'companies',
      query: query,
      parser: (json) => CompanyModel.fromJson(json),
    );
  }

  // ============================================================
  // EVENT QUERIES IMPLEMENTATION
  // ============================================================

  @override
  Future<List<EventModel>> queryEvents(IgdbEventQuery query) async {
    return await _executeQuery<EventModel>(
      endpoint: 'events',
      query: query,
      parser: (json) => EventModel.fromJson(json),
    );
  }

  // ============================================================
  // GAME ENGINE QUERIES IMPLEMENTATION
  // ============================================================

  @override
  Future<List<GameEngineModel>> queryGameEngines(
      IgdbGameEngineQuery query) async {
    return await _executeQuery<GameEngineModel>(
      endpoint: 'game_engines',
      query: query,
      parser: (json) => GameEngineModel.fromJson(json),
    );
  }

  // ============================================================
  // GENRE QUERIES IMPLEMENTATION
  // ============================================================

  @override
  Future<List<GenreModel>> queryGenres(IgdbGenreQuery query) async {
    return await _executeQuery<GenreModel>(
      endpoint: 'genres',
      query: query,
      parser: (json) => GenreModel.fromJson(json),
    );
  }

  @override
  Future<List<FranchiseModel>> queryFranchises(IgdbFranchiseQuery query) async {
    return await _executeQuery<FranchiseModel>(
      endpoint: 'franchises',
      query: query,
      parser: (json) => FranchiseModel.fromJson(json),
    );
  }

  @override
  Future<List<CollectionModel>> queryCollections(
      IgdbCollectionQuery query) async {
    return await _executeQuery<CollectionModel>(
      endpoint: 'collections',
      query: query,
      parser: (json) => CollectionModel.fromJson(json),
    );
  }

  @override
  Future<List<KeywordModel>> queryKeywords(IgdbKeywordQuery query) async {
    return await _executeQuery<KeywordModel>(
      endpoint: 'keywords',
      query: query,
      parser: (json) => KeywordModel.fromJson(json),
    );
  }

  @override
  Future<List<AgeRatingCategoryModel>> queryAgeRatings(
      IgdbAgeRatingQuery query) async {
    return _executeQuery<AgeRatingCategoryModel>(
      endpoint: 'age_rating_categories',
      query: query,
      parser: (json) => AgeRatingCategoryModel.fromJson(json),
    );
  }

  @override
  Future<List<MultiplayerModeModel>> queryMultiplayerModes(
      IgdbMultiplayerModeQuery query) async {
    return await _executeQuery<MultiplayerModeModel>(
      endpoint: 'multiplayer_modes',
      query: query,
      parser: (json) => MultiplayerModeModel.fromJson(json),
    );
  }

  @override
  Future<List<LanguageModel>> queryLanguages(IgdbLanguageQuery query) async {
    return await _executeQuery<LanguageModel>(
      endpoint: 'languages',
      query: query,
      parser: (json) => LanguageModel.fromJson(json),
    );
  }

  @override
  Future<List<GameModeModel>> queryGameModes(IgdbGameModeQuery query) async {
    return await _executeQuery<GameModeModel>(
      endpoint: 'game_modes',
      query: query,
      parser: (json) => GameModeModel.fromJson(json),
    );
  }

  @override
  Future<List<GameStatusModel>> queryGameStatuses(
      IgdbGameStatusQuery query) async {
    return await _executeQuery<GameStatusModel>(
      endpoint: 'game_statuses',
      query: query,
      parser: (json) => GameStatusModel.fromJson(json),
    );
  }

  @override
  Future<List<GameTypeModel>> queryGameTypes(IgdbGameTypeQuery query) async {
    return await _executeQuery<GameTypeModel>(
      endpoint: 'game_types',
      query: query,
      parser: (json) => GameTypeModel.fromJson(json),
    );
  }

  @override
  Future<List<PlayerPerspectiveModel>> queryPlayerPerspectives(
      IgdbPlayerPerspectiveQuery query) async {
    return await _executeQuery<PlayerPerspectiveModel>(
      endpoint: 'player_perspectives',
      query: query,
      parser: (json) => PlayerPerspectiveModel.fromJson(json),
    );
  }

  @override
  Future<List<IGDBThemeModel>> queryThemes(IgdbThemeQuery query) async {
    return await _executeQuery<IGDBThemeModel>(
      endpoint: 'themes',
      query: query,
      parser: (json) => IGDBThemeModel.fromJson(json),
    );
  }

  // ============================================================
  // SHARED QUERY EXECUTION METHOD
  // ============================================================

  /// Generic method to execute any IGDB query.
  ///
  /// This method handles all common logic:
  /// - Authentication
  /// - Request building
  /// - Error handling
  /// - Response parsing
  ///
  /// Type parameter [T] is the model type being queried.
  Future<List<T>> _executeQuery<T>({
    required String endpoint,
    required IgdbQuery<T> query,
    required T Function(Map<String, dynamic>) parser,
  }) async {
    try {

      // Ensure we have a valid access token
      await _ensureValidToken();

      // Build the query string
      final queryString = query.buildQuery();

      // Prepare request details
      final clientId = _getClientId();
      final fullUrl = '$baseUrl/$endpoint';
      final headers = {
        'Client-ID': clientId,
        'Authorization': 'Bearer $_cachedAccessToken',
        'Content-Type': 'text/plain',
      };

      // LOG COMPLETE REQUEST DETAILS
      headers.forEach((key, value) {
      });

      // Make the API request
      final response = await dio.post<dynamic>(
        fullUrl,
        data: queryString,
        options: Options(
          headers: headers,
        ),
      );


      // Check response status
      if (response.statusCode != 200) {
        throw ServerException(
          'IGDB API returned status ${response.statusCode}',
          message: 'IGDB API returned status ${response.statusCode}',
        );
      }

      // Parse response data
      final List<dynamic> data = response.data ?? [];

      // Convert to Model instances
      final results = data
          .map((json) {
            try {
              return parser(json as Map<String, dynamic>);
            } catch (e) {
              // Log the error but continue processing other items
              return null;
            }
          })
          .whereType<T>()
          .toList();

      return results;
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ServerException(
        'Unexpected error querying $endpoint: $e',
        message: 'Unexpected error querying $endpoint: $e',
      );
    }
  }

  // ============================================================
  // AUTHENTICATION
  // ============================================================

  /// Ensures we have a valid access token for IGDB API.
  ///
  /// Tokens are cached and only refreshed when expired.
  Future<void> _ensureValidToken() async {
    // Check if we have a cached token that's still valid
    if (_cachedAccessToken != null &&
        _tokenExpiryTime != null &&
        DateTime.now().isBefore(_tokenExpiryTime!)) {
      return; // Token is still valid
    }

    // Need to get a new token
    await _refreshAccessToken();
  }

  /// Fetches a new access token from Twitch OAuth.
  Future<void> _refreshAccessToken() async {
    try {

      final response = await dio.post<dynamic>(
        'https://id.twitch.tv/oauth2/token',
        queryParameters: {
          'client_id': _getClientId(),
          'client_secret': _getClientSecret(),
          'grant_type': 'client_credentials',
        },
      );


      if (response.statusCode == 200) {
        final data = response.data;
        _cachedAccessToken = data['access_token'];
        final expiresIn = data['expires_in'] as int;
        _tokenExpiryTime = DateTime.now().add(Duration(seconds: expiresIn));
      } else {
        throw ServerException(
          'Failed to get access token: ${response.statusCode}',
          message: 'Failed to get access token: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  // ============================================================
  // ERROR HANDLING
  // ============================================================

  /// Converts Dio exceptions to domain exceptions.
  Exception _handleDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException(
          message: 'Request timeout. Please check your connection.',
        );

      case DioExceptionType.connectionError:
        return NetworkException(
          message: 'No internet connection.',
        );

      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == 401) {
          return AuthException(message: 'Authentication failed.');
        } else if (statusCode == 429) {
          return ServerException(
            'Rate limit exceeded.',
            message: 'Rate limit exceeded.',
          );
        } else {
          return ServerException(
            'Server error: $statusCode',
            message: 'Server error: $statusCode',
          );
        }

      case DioExceptionType.cancel:
        return ServerException(
          'Request cancelled.',
          message: 'Request cancelled.',
        );

      default:
        return ServerException(
          'Unexpected error: ${e.message}',
          message: 'Unexpected error: ${e.message}',
        );
    }
  }

  // ============================================================
  // CONFIGURATION
  // ============================================================

  /// Gets the IGDB client ID from API constants.
  String _getClientId() {
    return ApiConstants.igdbClientId;
  }

  /// Gets the IGDB client secret from API constants.
  String _getClientSecret() {
    return ApiConstants.igdbClientSecret;
  }
}
