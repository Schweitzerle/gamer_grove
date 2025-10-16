// lib/data/datasources/remote/igdb/igdb_datasource_impl.dart

import 'package:dio/dio.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../models/game/game_model.dart';
import '../../../models/character/character_model.dart';
import '../../../models/platform/platform_model.dart';
import '../../../models/company/company_model.dart';
import '../../../models/event/event_model.dart';
import '../../../models/game/game_engine_model.dart';
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

      // Make the API request
      final response = await dio.post<dynamic>(
        '$baseUrl/$endpoint',
        data: queryString,
        options: Options(
          headers: {
            'Client-ID': _getClientId(),
            'Authorization': 'Bearer $_cachedAccessToken',
            'Content-Type': 'text/plain',
          },
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
      return data
          .map((json) {
            try {
              return parser(json as Map<String, dynamic>);
            } catch (e) {
              // Log the error but continue processing other items
              print('Warning: Failed to parse $endpoint item: $e');
              return null;
            }
          })
          .whereType<T>()
          .toList();
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

  /// Gets the IGDB client ID from environment or config.
  String _getClientId() {
    // TODO: Load from environment variables or secure storage
    return const String.fromEnvironment(
      'IGDB_CLIENT_ID',
      defaultValue: 'your_client_id_here',
    );
  }

  /// Gets the IGDB client secret from environment or config.
  String _getClientSecret() {
    // TODO: Load from environment variables or secure storage
    return const String.fromEnvironment(
      'IGDB_CLIENT_SECRET',
      defaultValue: 'your_client_secret_here',
    );
  }
}
