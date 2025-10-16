// lib/data/datasources/remote/igdb/igdb_datasource_impl.dart

import 'package:dio/dio.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../models/game/game_model.dart';
import 'igdb_datasource.dart';
import 'models/igdb_query.dart';

/// Implementation of [IgdbDataSource] using Dio HTTP client.
///
/// This implementation handles:
/// - Authentication with IGDB API (via Twitch OAuth)
/// - Query string construction
/// - HTTP requests and responses
/// - Error handling and mapping to exceptions
/// - Response parsing to GameModel
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
  // CORE IMPLEMENTATION
  // ============================================================

  @override
  Future<List<GameModel>> queryGames(IgdbGameQuery query) async {
    try {
      // Ensure we have a valid access token
      await _ensureValidToken();

      // Build the query string
      final queryString = query.buildQuery();

      // Make the API request
      final response = await dio.post(
        '$baseUrl/games',
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
          message: 'IGDB API returned status ${response.statusCode}',
        );
      }

      // Parse response data
      final List<dynamic> data = response.data ?? [];

      // Convert to GameModel instances
      return data
          .map((json) {
            try {
              return GameModel.fromJson(json as Map<String, dynamic>);
            } catch (e) {
              // Log the error but continue processing other games
              print('Warning: Failed to parse game: $e');
              return null;
            }
          })
          .whereType<GameModel>()
          .toList();
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ServerException(
        message: 'Unexpected error querying games: $e',
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
    // Check if we have a valid cached token
    if (_cachedAccessToken != null &&
        _tokenExpiryTime != null &&
        DateTime.now().isBefore(_tokenExpiryTime!)) {
      return; // Token is still valid
    }

    // Token expired or doesn't exist, fetch a new one
    await _fetchAccessToken();
  }

  /// Fetches a new access token from Twitch OAuth.
  ///
  /// IGDB uses Twitch authentication. You need:
  /// - Client ID (from Twitch Developer Console)
  /// - Client Secret (from Twitch Developer Console)
  Future<void> _fetchAccessToken() async {
    try {
      final clientId = _getClientId();
      final clientSecret = _getClientSecret();

      final response = await dio.post(
        'https://id.twitch.tv/oauth2/token',
        queryParameters: {
          'client_id': clientId,
          'client_secret': clientSecret,
          'grant_type': 'client_credentials',
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        _cachedAccessToken = data['access_token'] as String;

        // Token expires in X seconds (usually 5184000 = 60 days)
        final expiresIn = data['expires_in'] as int;
        _tokenExpiryTime = DateTime.now().add(Duration(seconds: expiresIn));
      } else {
        throw AuthException(
          message: 'Failed to fetch IGDB access token: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw AuthException(
        message: 'Failed to authenticate with IGDB: ${e.message}',
      );
    }
  }

  // ============================================================
  // ERROR HANDLING
  // ============================================================

  /// Maps Dio exceptions to our custom exception types.
  Exception _handleDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException(
          message: 'Connection timeout. Please check your internet connection.',
        );

      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;

        if (statusCode == 401) {
          return AuthException(
            message: 'Authentication failed. Invalid or expired token.',
          );
        } else if (statusCode == 429) {
          return ServerException(
            message: 'Rate limit exceeded. Please try again later.',
          );
        } else if (statusCode != null && statusCode >= 500) {
          return ServerException(
            message: 'IGDB server error. Please try again later.',
          );
        } else {
          return ServerException(
            message: 'Request failed with status $statusCode',
          );
        }

      case DioExceptionType.cancel:
        return ServerException(message: 'Request was cancelled');

      case DioExceptionType.unknown:
        if (e.error.toString().contains('SocketException')) {
          return NetworkException(
            message: 'No internet connection',
          );
        }
        return ServerException(
          message: 'An unexpected error occurred: ${e.message}',
        );

      default:
        return ServerException(
          message: 'Network error: ${e.message}',
        );
    }
  }

  // ============================================================
  // CONFIGURATION
  // ============================================================

  /// Get Client ID from environment or configuration.
  ///
  /// In production, use flutter_dotenv or similar to manage secrets.
  String _getClientId() {
    // TODO: Replace with your actual Client ID management
    const clientId = String.fromEnvironment(
      'IGDB_CLIENT_ID',
      defaultValue: 'YOUR_CLIENT_ID_HERE',
    );

    if (clientId == 'YOUR_CLIENT_ID_HERE') {
      throw ConfigurationException(
        'IGDB_CLIENT_ID not configured. Please set it in your environment.',
      );
    }

    return clientId;
  }

  /// Get Client Secret from environment or configuration.
  ///
  /// In production, use flutter_dotenv or similar to manage secrets.
  String _getClientSecret() {
    // TODO: Replace with your actual Client Secret management
    const clientSecret = String.fromEnvironment(
      'IGDB_CLIENT_SECRET',
      defaultValue: 'YOUR_CLIENT_SECRET_HERE',
    );

    if (clientSecret == 'YOUR_CLIENT_SECRET_HERE') {
      throw ConfigurationException(
        'IGDB_CLIENT_SECRET not configured. Please set it in your environment.',
      );
    }

    return clientSecret;
  }
}

// ============================================================
// CUSTOM EXCEPTIONS (if not already defined)
// ============================================================

/// Exception for configuration errors
class ConfigurationException implements Exception {
  final String message;

  ConfigurationException(this.message);

  @override
  String toString() => 'ConfigurationException: $message';
}

/// Exception for authentication errors
class AuthException implements Exception {
  final String message;

  AuthException({required this.message});

  @override
  String toString() => 'AuthException: $message';
}

/// Exception for network errors
class NetworkException implements Exception {
  final String message;

  NetworkException({required this.message});

  @override
  String toString() => 'NetworkException: $message';
}
