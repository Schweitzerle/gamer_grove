// lib/data/datasources/remote/igdb/igdb_datasource_impl.dart

import 'package:dio/dio.dart';
import 'package:gamer_grove/core/env/env.dart';
import 'package:gamer_grove/core/errors/exceptions.dart';
import 'package:gamer_grove/data/datasources/remote/igdb/igdb_datasource.dart';
import 'package:gamer_grove/data/datasources/remote/igdb/models/igdb_query.dart';
import 'package:gamer_grove/data/models/ageRating/age_rating_category_model.dart';
import 'package:gamer_grove/data/models/character/character_model.dart';
import 'package:gamer_grove/data/models/collection/collection_model.dart';
import 'package:gamer_grove/data/models/company/company_model.dart';
import 'package:gamer_grove/data/models/event/event_model.dart';
import 'package:gamer_grove/data/models/franchise_model.dart';
import 'package:gamer_grove/data/models/game/game_engine_model.dart';
import 'package:gamer_grove/data/models/game/game_mode_model.dart';
import 'package:gamer_grove/data/models/game/game_model.dart';
import 'package:gamer_grove/data/models/game/game_status_model.dart';
import 'package:gamer_grove/data/models/game/game_type_model.dart';
import 'package:gamer_grove/data/models/genre_model.dart';
import 'package:gamer_grove/data/models/keyword_model.dart';
import 'package:gamer_grove/data/models/language/lanuage_model.dart';
import 'package:gamer_grove/data/models/multiplayer_mode_model.dart';
import 'package:gamer_grove/data/models/platform/platform_model.dart';
import 'package:gamer_grove/data/models/player_perspective_model.dart';
import 'package:gamer_grove/data/models/theme_model.dart';

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
/// Talks to IGDB through our own proxy rather than to IGDB directly.
///
/// Calling IGDB from the app meant carrying IGDB_CLIENT_SECRET on every device
/// in order to mint Twitch tokens. `envied` masks that constant with XOR, which
/// raises the effort of pulling it out and nothing more — the mask ships beside
/// the masked bytes. The only honest statement about a secret in a client is
/// that it is not one.
///
/// The credentials now live in the `igdb` edge function, which mints and caches
/// the token and forwards the query. What travels from here is the query the
/// app wanted to run.
class IgdbDataSourceImpl implements IgdbDataSource {
  IgdbDataSourceImpl({
    required this.dio,
    required this.accessToken,
    String? proxyUrl,
  }) : proxyUrl = proxyUrl ?? '${Env.supabaseUrl}/functions/v1/igdb';

  final Dio dio;

  /// The signed-in user's access token, read afresh for every request.
  ///
  /// A function rather than a value because the token is refreshed while the
  /// app runs; a copy taken at construction would go stale within the hour.
  ///
  /// Injected rather than read from Supabase here so this class keeps knowing
  /// nothing about where a session comes from — and so a test can hand it one.
  final String? Function() accessToken;

  /// Where the proxy lives. Derived from the Supabase project rather than
  /// configured separately, because it is always the same project.
  final String proxyUrl;

  // ============================================================
  // GAME QUERIES IMPLEMENTATION
  // ============================================================

  @override
  Future<List<GameModel>> queryGames(IgdbGameQuery query) async {
    return _executeQuery<GameModel>(
      endpoint: 'games',
      query: query,
      parser: GameModel.fromJson,
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

    return _executeQuery<CharacterModel>(
      endpoint: 'characters',
      query: query,
      parser: CharacterModel.fromJson,
    );
  }

  // ============================================================
  // PLATFORM QUERIES IMPLEMENTATION
  // ============================================================

  @override
  Future<List<PlatformModel>> queryPlatforms(IgdbPlatformQuery query) async {
    return _executeQuery<PlatformModel>(
      endpoint: 'platforms',
      query: query,
      parser: PlatformModel.fromJson,
    );
  }

  // ============================================================
  // COMPANY QUERIES IMPLEMENTATION
  // ============================================================

  @override
  Future<List<CompanyModel>> queryCompanies(IgdbCompanyQuery query) async {
    return _executeQuery<CompanyModel>(
      endpoint: 'companies',
      query: query,
      parser: CompanyModel.fromJson,
    );
  }

  // ============================================================
  // EVENT QUERIES IMPLEMENTATION
  // ============================================================

  @override
  Future<List<EventModel>> queryEvents(IgdbEventQuery query) async {
    return _executeQuery<EventModel>(
      endpoint: 'events',
      query: query,
      parser: EventModel.fromJson,
    );
  }

  // ============================================================
  // GAME ENGINE QUERIES IMPLEMENTATION
  // ============================================================

  @override
  Future<List<GameEngineModel>> queryGameEngines(
    IgdbGameEngineQuery query,
  ) async {
    return _executeQuery<GameEngineModel>(
      endpoint: 'game_engines',
      query: query,
      parser: GameEngineModel.fromJson,
    );
  }

  // ============================================================
  // GENRE QUERIES IMPLEMENTATION
  // ============================================================

  @override
  Future<List<GenreModel>> queryGenres(IgdbGenreQuery query) async {
    return _executeQuery<GenreModel>(
      endpoint: 'genres',
      query: query,
      parser: GenreModel.fromJson,
    );
  }

  @override
  Future<List<FranchiseModel>> queryFranchises(IgdbFranchiseQuery query) async {
    return _executeQuery<FranchiseModel>(
      endpoint: 'franchises',
      query: query,
      parser: FranchiseModel.fromJson,
    );
  }

  @override
  Future<List<CollectionModel>> queryCollections(
    IgdbCollectionQuery query,
  ) async {
    return _executeQuery<CollectionModel>(
      endpoint: 'collections',
      query: query,
      parser: CollectionModel.fromJson,
    );
  }

  @override
  Future<List<KeywordModel>> queryKeywords(IgdbKeywordQuery query) async {
    return _executeQuery<KeywordModel>(
      endpoint: 'keywords',
      query: query,
      parser: KeywordModel.fromJson,
    );
  }

  @override
  Future<List<AgeRatingCategoryModel>> queryAgeRatings(
    IgdbAgeRatingQuery query,
  ) async {
    return _executeQuery<AgeRatingCategoryModel>(
      endpoint: 'age_rating_categories',
      query: query,
      parser: AgeRatingCategoryModel.fromJson,
    );
  }

  @override
  Future<List<MultiplayerModeModel>> queryMultiplayerModes(
    IgdbMultiplayerModeQuery query,
  ) async {
    return _executeQuery<MultiplayerModeModel>(
      endpoint: 'multiplayer_modes',
      query: query,
      parser: MultiplayerModeModel.fromJson,
    );
  }

  @override
  Future<List<LanguageModel>> queryLanguages(IgdbLanguageQuery query) async {
    return _executeQuery<LanguageModel>(
      endpoint: 'languages',
      query: query,
      parser: LanguageModel.fromJson,
    );
  }

  @override
  Future<List<GameModeModel>> queryGameModes(IgdbGameModeQuery query) async {
    return _executeQuery<GameModeModel>(
      endpoint: 'game_modes',
      query: query,
      parser: GameModeModel.fromJson,
    );
  }

  @override
  Future<List<GameStatusModel>> queryGameStatuses(
    IgdbGameStatusQuery query,
  ) async {
    return _executeQuery<GameStatusModel>(
      endpoint: 'game_statuses',
      query: query,
      parser: GameStatusModel.fromJson,
    );
  }

  @override
  Future<List<GameTypeModel>> queryGameTypes(IgdbGameTypeQuery query) async {
    return _executeQuery<GameTypeModel>(
      endpoint: 'game_types',
      query: query,
      parser: GameTypeModel.fromJson,
    );
  }

  @override
  Future<List<PlayerPerspectiveModel>> queryPlayerPerspectives(
    IgdbPlayerPerspectiveQuery query,
  ) async {
    return _executeQuery<PlayerPerspectiveModel>(
      endpoint: 'player_perspectives',
      query: query,
      parser: PlayerPerspectiveModel.fromJson,
    );
  }

  @override
  Future<List<IGDBThemeModel>> queryThemes(IgdbThemeQuery query) async {
    return _executeQuery<IGDBThemeModel>(
      endpoint: 'themes',
      query: query,
      parser: IGDBThemeModel.fromJson,
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
      // The session token, not the anon key. Until #161 this sent the anon
      // key, which is readable out of the APK and sits in the public git
      // history — the proxy could not tell one caller from another and had no
      // ceiling, so it was a free IGDB API on our Twitch credentials.
      //
      // `apikey` stays the anon key: that header is what the Supabase gateway
      // routes on, and it is public by design.
      final token = accessToken();
      if (token == null || token.isEmpty) {
        throw AuthException(
          message: 'Please sign in to browse games.',
        );
      }

      final response = await dio.post<dynamic>(
        proxyUrl,
        data: {'endpoint': endpoint, 'query': query.buildQuery()},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'apikey': Env.supabaseAnonKey,
            'Content-Type': 'application/json',
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
        message: 'Unexpected error querying $endpoint: $e',
      );
    }
  }

  /// Maps transport failures onto the app's own exception types.
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
          // The proxy now answers 401 for "no session", not only for a bad
          // key, so the message has to make sense to a reader who is simply
          // signed out.
          return AuthException(message: 'Please sign in to browse games.');
        } else if (statusCode == 429) {
          return ServerException(
            message: 'Too many requests — try again in a minute.',
          );
        } else {
          return ServerException(
            message: 'Server error: $statusCode',
          );
        }

      case DioExceptionType.cancel:
        return ServerException(
          message: 'Request cancelled.',
        );

      default:
        return ServerException(
          message: 'Unexpected error: ${e.message}',
        );
    }
  }
}
