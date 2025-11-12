// lib/data/datasources/remote/igdb/igdb_datasource.dart

import 'package:gamer_grove/data/models/ageRating/age_rating_category_model.dart';
import 'package:gamer_grove/data/models/game/game_mode_model.dart';
import 'package:gamer_grove/data/models/game/game_model.dart';
import 'package:gamer_grove/data/models/character/character_model.dart';
import 'package:gamer_grove/data/models/game/game_status_model.dart';
import 'package:gamer_grove/data/models/game/game_type_model.dart';
import 'package:gamer_grove/data/models/language/lanuage_model.dart';
import 'package:gamer_grove/data/models/platform/platform_model.dart';
import 'package:gamer_grove/data/models/company/company_model.dart';
import 'package:gamer_grove/data/models/event/event_model.dart';
import 'package:gamer_grove/data/models/game/game_engine_model.dart';
import 'package:gamer_grove/data/models/genre_model.dart';
import 'package:gamer_grove/data/models/franchise_model.dart';
import 'package:gamer_grove/data/models/collection/collection_model.dart';
import 'package:gamer_grove/data/models/keyword_model.dart';
import 'package:gamer_grove/data/models/multiplayer_mode_model.dart';
import 'package:gamer_grove/data/models/player_perspective_model.dart';
import 'package:gamer_grove/data/models/theme_model.dart';

import 'models/igdb_query.dart';

/// Abstract interface for IGDB data source operations.
///
/// This interface defines a unified way to query all entities from the IGDB API
/// using the flexible query system instead of multiple specialized methods.
///
/// Each entity type has its own query method that accepts a typed query object:
/// - Games: queryGames(IgdbGameQuery)
/// - Characters: queryCharacters(IgdbCharacterQuery)
/// - Platforms: queryPlatforms(IgdbPlatformQuery)
/// - Companies: queryCompanies(IgdbCompanyQuery)
/// - Events: queryEvents(IgdbEventQuery)
/// - Game Engines: queryGameEngines(IgdbGameEngineQuery)
///
/// All query methods follow the same pattern:
/// 1. Accept a typed query object with filters, fields, sorting, etc.
/// 2. Return a list of typed model instances
/// 3. Throw exceptions on errors (ServerException, NetworkException)
///
/// Example usage:
/// ```dart
/// // Query games
/// final gameQuery = GameQueryPresets.popular(limit: 20);
/// final games = await dataSource.queryGames(gameQuery);
///
/// // Query characters
/// final charQuery = CharacterQueryPresets.fromGame(gameId: 1942);
/// final characters = await dataSource.queryCharacters(charQuery);
/// ```
abstract class IgdbDataSource {
  // ============================================================
  // GAME QUERIES
  // ============================================================

  /// Queries games from IGDB using the unified query system.
  ///
  /// This is the primary method for fetching games. Use [GameQueryPresets]
  /// for common query patterns or build custom queries with [IgdbGameQuery].
  ///
  /// **Parameters:**
  /// - [query]: Complete query specification including filters, fields, sorting, etc.
  ///
  /// **Returns:**
  /// List of [GameModel] instances matching the query criteria.
  ///
  /// **Throws:**
  /// - [ServerException] if the API request fails
  /// - [NetworkException] if there's no network connection
  ///
  /// **Example:**
  /// ```dart
  /// final query = GameQueryPresets.byPlatform(
  ///   platformId: 6,
  ///   limit: 20,
  /// );
  /// final games = await dataSource.queryGames(query);
  /// ```
  Future<List<GameModel>> queryGames(IgdbGameQuery query);

  // ============================================================
  // CHARACTER QUERIES
  // ============================================================

  /// Queries characters from IGDB using the unified query system.
  ///
  /// Use [CharacterQueryPresets] for common query patterns or build
  /// custom queries with [IgdbCharacterQuery].
  ///
  /// **Parameters:**
  /// - [query]: Complete query specification including filters, fields, sorting, etc.
  ///
  /// **Returns:**
  /// List of [CharacterModel] instances matching the query criteria.
  ///
  /// **Throws:**
  /// - [ServerException] if the API request fails
  /// - [NetworkException] if there's no network connection
  ///
  /// **Example:**
  /// ```dart
  /// final query = CharacterQueryPresets.fromGame(
  ///   gameId: 1942,
  ///   limit: 50,
  /// );
  /// final characters = await dataSource.queryCharacters(query);
  /// ```
  Future<List<CharacterModel>> queryCharacters(IgdbCharacterQuery query);

  // ============================================================
  // PLATFORM QUERIES
  // ============================================================

  /// Queries platforms from IGDB using the unified query system.
  ///
  /// Use [PlatformQueryPresets] for common query patterns or build
  /// custom queries with [IgdbPlatformQuery].
  ///
  /// **Parameters:**
  /// - [query]: Complete query specification including filters, fields, sorting, etc.
  ///
  /// **Returns:**
  /// List of [PlatformModel] instances matching the query criteria.
  ///
  /// **Throws:**
  /// - [ServerException] if the API request fails
  /// - [NetworkException] if there's no network connection
  ///
  /// **Example:**
  /// ```dart
  /// final query = PlatformQueryPresets.currentGeneration(
  ///   limit: 20,
  /// );
  /// final platforms = await dataSource.queryPlatforms(query);
  /// ```
  Future<List<PlatformModel>> queryPlatforms(IgdbPlatformQuery query);

  // ============================================================
  // COMPANY QUERIES
  // ============================================================

  /// Queries companies from IGDB using the unified query system.
  ///
  /// Use [CompanyQueryPresets] for common query patterns or build
  /// custom queries with [IgdbCompanyQuery].
  ///
  /// **Parameters:**
  /// - [query]: Complete query specification including filters, fields, sorting, etc.
  ///
  /// **Returns:**
  /// List of [CompanyModel] instances matching the query criteria.
  ///
  /// **Throws:**
  /// - [ServerException] if the API request fails
  /// - [NetworkException] if there's no network connection
  ///
  /// **Example:**
  /// ```dart
  /// final query = CompanyQueryPresets.developers(
  ///   limit: 50,
  /// );
  /// final companies = await dataSource.queryCompanies(query);
  /// ```
  Future<List<CompanyModel>> queryCompanies(IgdbCompanyQuery query);

  // ============================================================
  // EVENT QUERIES
  // ============================================================

  /// Queries events from IGDB using the unified query system.
  ///
  /// Use [EventQueryPresets] for common query patterns or build
  /// custom queries with [IgdbEventQuery].
  ///
  /// **Parameters:**
  /// - [query]: Complete query specification including filters, fields, sorting, etc.
  ///
  /// **Returns:**
  /// List of [EventModel] instances matching the query criteria.
  ///
  /// **Throws:**
  /// - [ServerException] if the API request fails
  /// - [NetworkException] if there's no network connection
  ///
  /// **Example:**
  /// ```dart
  /// final query = EventQueryPresets.upcoming(
  ///   limit: 20,
  ///   daysAhead: 30,
  /// );
  /// final events = await dataSource.queryEvents(query);
  /// ```
  Future<List<EventModel>> queryEvents(IgdbEventQuery query);

  // ============================================================
  // GAME ENGINE QUERIES
  // ============================================================

  /// Queries game engines from IGDB using the unified query system.
  ///
  /// Use [GameEngineQueryPresets] for common query patterns or build
  /// custom queries with [IgdbGameEngineQuery].
  ///
  /// **Parameters:**
  /// - [query]: Complete query specification including filters, fields, sorting, etc.
  ///
  /// **Returns:**
  /// List of [GameEngineModel] instances matching the query criteria.
  ///
  /// **Throws:**
  /// - [ServerException] if the API request fails
  /// - [NetworkException] if there's no network connection
  ///
  /// **Example:**
  /// ```dart
  /// final query = GameEngineQueryPresets.popular(
  ///   limit: 20,
  /// );
  /// final engines = await dataSource.queryGameEngines(query);
  /// ```
  Future<List<GameEngineModel>> queryGameEngines(IgdbGameEngineQuery query);

  // ============================================================
  // GENRE QUERIES
  // ============================================================

  /// Queries genres from IGDB using the unified query system.
  ///
  /// Use this method to fetch all available genres or build
  /// custom queries with [IgdbGenreQuery].
  ///
  /// **Parameters:**
  /// - [query]: Complete query specification including filters, fields, sorting, etc.
  ///
  /// **Returns:**
  /// List of [GenreModel] instances matching the query criteria.
  ///
  /// **Throws:**
  /// - [ServerException] if the API request fails
  /// - [NetworkException] if there's no network connection
  ///
  /// **Example:**
  /// ```dart
  /// final query = IgdbGenreQuery(
  ///   fields: ['id', 'name', 'slug'],
  ///   limit: 50,
  ///   sort: 'name asc',
  /// );
  /// final genres = await dataSource.queryGenres(query);
  /// ```
  Future<List<GenreModel>> queryGenres(IgdbGenreQuery query);

  // ============================================================
  // FRANCHISE QUERIES
  // ============================================================

  /// Queries franchises from IGDB
  Future<List<FranchiseModel>> queryFranchises(IgdbFranchiseQuery query);

  // ============================================================
  // COLLECTION QUERIES
  // ============================================================

  /// Queries collections from IGDB
  Future<List<CollectionModel>> queryCollections(IgdbCollectionQuery query);

  // ============================================================
  // KEYWORD QUERIES
  // ============================================================

  /// Queries keywords from IGDB
  Future<List<KeywordModel>> queryKeywords(IgdbKeywordQuery query);

  // ============================================================
  // AGE RATING QUERIES
  // ============================================================

  /// Queries age ratings from IGDB
  Future<List<AgeRatingCategoryModel>> queryAgeRatings(
      IgdbAgeRatingQuery query);

  // ============================================================
  // MULTIPLAYER MODE QUERIES
  // ============================================================

  /// Queries multiplayer modes from IGDB
  Future<List<MultiplayerModeModel>> queryMultiplayerModes(
      IgdbMultiplayerModeQuery query);

  // ============================================================
  // LANGUAGE SUPPORT QUERIES
  // ============================================================

  /// Queries languages from IGDB
  Future<List<LanguageModel>> queryLanguages(IgdbLanguageQuery query);

  // ============================================================
  // Theme QUERIES
  // ============================================================

  /// Queries themes from IGDB
  Future<List<IGDBThemeModel>> queryThemes(IgdbThemeQuery query);

  // ============================================================
  // Player perspective QUERIES
  // ============================================================

  /// Queries player perspectives from IGDB
  Future<List<PlayerPerspectiveModel>> queryPlayerPerspectives(
      IgdbPlayerPerspectiveQuery query);

  // ============================================================
  // Game modes QUERIES
  // ============================================================

  /// Queries game modes from IGDB
  Future<List<GameModeModel>> queryGameModes(IgdbGameModeQuery query);

  // ============================================================
  // Game statuses QUERIES
  // ============================================================

  /// Queries game statuses from IGDB
  Future<List<GameStatusModel>> queryGameStatuses(IgdbGameStatusQuery query);

  // ============================================================
  // Game types QUERIES
  // ============================================================

  /// Queries game types from IGDB
  Future<List<GameTypeModel>> queryGameTypes(IgdbGameTypeQuery query);
}
