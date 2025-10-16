// lib/data/datasources/remote/igdb/igdb_datasource.dart

import 'package:gamer_grove/data/models/game/game_model.dart';
import 'models/igdb_query.dart';

/// Abstract interface for IGDB data source operations.
///
/// This interface defines a unified way to query games from the IGDB API
/// using the flexible query system instead of multiple specialized methods.
abstract class IgdbDataSource {
  // ============================================================
  // CORE QUERY METHOD - The One Method to Rule Them All
  // ============================================================

  /// Queries games from IGDB using the unified query system.
  ///
  /// This is the primary method for fetching games. All other convenience
  /// methods should internally use this method.
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
}
