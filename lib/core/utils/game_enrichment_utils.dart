// 🔧 GAME ENRICHMENT UTILS - SHARED USER DATA ENRICHMENT
// Diese Klasse kann von GameBloc, EventBloc, CharacterBloc und anderen verwendet werden

// ==========================================
// 1. ERSTELLE NEUE DATEI: lib/core/utils/game_enrichment_utils.dart
// ==========================================

import 'dart:async';
import '../../data/datasources/remote/supabase/supabase_remote_datasource.dart';
import '../../domain/entities/game/game.dart';
import '../../injection_container.dart';

class GameEnrichmentUtils {

  // ==========================================
  // HAUPT-ENRICHMENT METHODE
  // ==========================================

  /// Enriches games with user data (wishlist, ratings, top three, etc.)
  ///
  /// [games] - List of games to enrich
  /// [userId] - User ID for fetching user data
  /// [enrichLimit] - Maximum number of games to fully enrich (for performance)
  /// [enableTopThree] - Whether to fetch and apply top three data
  /// [enableParallelRequests] - Whether to use parallel requests for better performance
  static Future<List<Game>> enrichGamesWithUserData(
      List<Game> games,
      String userId, {
        int? enrichLimit,
        bool enableTopThree = true,
        bool enableParallelRequests = true,
        bool enableLogging = true,
      }) async {
    if (games.isEmpty) {
      if (enableLogging) print('🔄 GameEnrichment: No games to enrich');
      return games;
    }

    final limit = enrichLimit ?? 10; // Default: Erste 10 Games vollständig enrichen
    if (enableLogging) {
      print('🔄 GameEnrichment: Enriching ${games.length} games (limit: $limit) for user: $userId');
    }

    try {
      final supabaseDataSource = sl<SupabaseRemoteDataSource>();

      // Schritt 1: Games die enriched werden sollen
      final gamesToEnrich = games.take(limit).toList();

      // Schritt 2: User Game Data holen (parallel oder sequenziell)
      final userGameDataList = enableParallelRequests
          ? await _getUserGameDataParallel(supabaseDataSource, userId, gamesToEnrich, enableLogging)
          : await _getUserGameDataSequential(supabaseDataSource, userId, gamesToEnrich, enableLogging);

      // Schritt 3: Top Three Data holen (optional)
      Map<int, int> topThreeMap = {};
      if (enableTopThree) {
        topThreeMap = await _getTopThreeData(supabaseDataSource, userId, enableLogging);
      }

      // Schritt 4: Enriched Games erstellen
      final enrichedGames = <Game>[];

      // Vollständig enriched games (erste X)
      for (int i = 0; i < gamesToEnrich.length; i++) {
        final game = gamesToEnrich[i];
        final userGameData = userGameDataList[i];

        final enrichedGame = _createEnrichedGame(
          game,
          userGameData,
          topThreeMap,
          enableLogging,
        );

        enrichedGames.add(enrichedGame);
      }

      // Remaining games (nur mit Top Three Data)
      if (games.length > limit) {
        final remainingGames = games.skip(limit);
        for (final game in remainingGames) {
          final partiallyEnrichedGame = _createPartiallyEnrichedGame(
            game,
            topThreeMap,
          );
          enrichedGames.add(partiallyEnrichedGame);
        }
      }

      if (enableLogging) {
        final enrichedCount = enrichedGames.where((g) => g.isWishlisted != null).length;
        print('✅ GameEnrichment: Successfully enriched $enrichedCount/${enrichedGames.length} games');
      }

      return enrichedGames;

    } catch (e) {
      if (enableLogging) {
        print('❌ GameEnrichment: Error enriching games: $e');
      }

      // Fallback: Games mit default values zurückgeben
      return _createFallbackGames(games, enableTopThree ? await _getTopThreeData(sl<SupabaseRemoteDataSource>(), userId, false) : {});
    }
  }

  // ==========================================
  // SPEZIALISIERTE ENRICHMENT METHODEN
  // ==========================================

  /// Enriches games specifically for Character context
  static Future<List<Game>> enrichCharacterGames(
      List<Game> games,
      String userId, {
        int limit = 8, // Characters haben oft weniger Games
      }) async {
    return await enrichGamesWithUserData(
      games,
      userId,
      enrichLimit: limit,
      enableTopThree: true,
      enableParallelRequests: true,
      enableLogging: true,
    );
  }

  /// Enriches games specifically for Event context
  static Future<List<Game>> enrichEventGames(
      List<Game> games,
      String userId, {
        int limit = 10, // Events können viele Games haben
      }) async {
    return await enrichGamesWithUserData(
      games,
      userId,
      enrichLimit: limit,
      enableTopThree: true,
      enableParallelRequests: true,
      enableLogging: true,
    );
  }

  /// Enriches games for main Game Detail context (vollständig)
  static Future<List<Game>> enrichGameDetailGames(
      List<Game> games,
      String userId, {
        int limit = 15, // Game Details brauchen mehr enriched data
      }) async {
    return await enrichGamesWithUserData(
      games,
      userId,
      enrichLimit: limit,
      enableTopThree: true,
      enableParallelRequests: true,
      enableLogging: true,
    );
  }

  // ==========================================
  // PRIVATE HELPER METHODEN
  // ==========================================

  /// Holt User Game Data parallel (schneller)
  static Future<List<Map<String, dynamic>?>> _getUserGameDataParallel(
      SupabaseRemoteDataSource dataSource,
      String userId,
      List<Game> games,
      bool enableLogging,
      ) async {
    if (enableLogging) {
      print('🔄 GameEnrichment: Fetching user data for ${games.length} games (parallel)');
    }

    final futures = games
        .map((game) => dataSource.getUserGameData(userId, game.id))
        .toList();

    return await Future.wait(futures);
  }

  /// Holt User Game Data sequenziell (langsamer aber stabiler)
  static Future<List<Map<String, dynamic>?>> _getUserGameDataSequential(
      SupabaseRemoteDataSource dataSource,
      String userId,
      List<Game> games,
      bool enableLogging,
      ) async {
    if (enableLogging) {
      print('🔄 GameEnrichment: Fetching user data for ${games.length} games (sequential)');
    }

    final userGameDataList = <Map<String, dynamic>?>[];

    for (final game in games) {
      try {
        final userData = await dataSource.getUserGameData(userId, game.id);
        userGameDataList.add(userData);
      } catch (e) {
        if (enableLogging) {
          print('⚠️ GameEnrichment: Failed to get data for game ${game.id}: $e');
        }
        userGameDataList.add(null);
      }
    }

    return userGameDataList;
  }

  /// Holt Top Three Data
  static Future<Map<int, int>> _getTopThreeData(
      SupabaseRemoteDataSource dataSource,
      String userId,
      bool enableLogging,
      ) async {
    try {
      if (enableLogging) {
        print('🔄 GameEnrichment: Fetching top three data');
      }

      final topThreeData = await dataSource.getUserTopThreeGames(userId: userId);
      final topThreeMap = <int, int>{};

      for (var entry in topThreeData) {
        final gameId = entry['game_id'] as int;
        final position = entry['position'] as int;
        topThreeMap[gameId] = position;
      }

      if (enableLogging) {
        print('✅ GameEnrichment: Found ${topThreeMap.length} top three games');
      }

      return topThreeMap;
    } catch (e) {
      if (enableLogging) {
        print('⚠️ GameEnrichment: Failed to get top three data: $e');
      }
      return {};
    }
  }

  /// Erstellt vollständig enriched Game
  static Game _createEnrichedGame(
      Game game,
      Map<String, dynamic>? userGameData,
      Map<int, int> topThreeMap,
      bool enableLogging,
      ) {
    final isWishlisted = userGameData?['is_wishlisted'] ?? false;
    final isRecommended = userGameData?['is_recommended'] ?? false;
    final userRating = userGameData?['rating']?.toDouble();
    final isInTopThree = topThreeMap.containsKey(game.id);
    final topThreePosition = topThreeMap[game.id];

    if (enableLogging && userGameData != null) {
      print('🎮 GameEnrichment: ${game.name} - W:$isWishlisted R:$isRecommended Rating:$userRating TopThree:$isInTopThree');
    }

    return game.copyWith(
      isWishlisted: isWishlisted,
      isRecommended: isRecommended,
      userRating: userRating,
      isInTopThree: isInTopThree,
      topThreePosition: topThreePosition,
    );
  }

  /// Erstellt teilweise enriched Game (nur Top Three)
  static Game _createPartiallyEnrichedGame(
      Game game,
      Map<int, int> topThreeMap,
      ) {
    return game.copyWith(
      isWishlisted: false, // Default values für non-enriched
      isRecommended: false,
      userRating: null,
      isInTopThree: topThreeMap.containsKey(game.id),
      topThreePosition: topThreeMap[game.id],
    );
  }

  /// Erstellt Fallback Games bei Fehlern
  static List<Game> _createFallbackGames(
      List<Game> games,
      Map<int, int> topThreeMap,
      ) {
    return games.map((game) => game.copyWith(
      isWishlisted: false,
      isRecommended: false,
      userRating: null,
      isInTopThree: topThreeMap.containsKey(game.id),
      topThreePosition: topThreeMap[game.id],
    )).toList();
  }

  // ==========================================
  // UTILITY METHODEN
  // ==========================================

  /// Prüft ob ein Game User Data hat
  static bool hasUserData(Game game) {
    return game.isWishlisted != null ||
        game.isRecommended != null ||
        game.userRating != null ||
        game.isInTopThree != null;
  }

  /// Zählt enriched Games
  static int countEnrichedGames(List<Game> games) {
    return games.where((game) => hasUserData(game)).length;
  }

  /// Debug Info für enriched Games
  static void printEnrichmentStats(List<Game> games, {String context = ''}) {
    final enrichedCount = countEnrichedGames(games);
    final wishlistedCount = games.where((g) => g.isWishlisted == true).length;
    final recommendedCount = games.where((g) => g.isRecommended == true).length;
    final ratedCount = games.where((g) => g.userRating != null).length;
    final topThreeCount = games.where((g) => g.isInTopThree == true).length;

    print('📊 GameEnrichment Stats${context.isNotEmpty ? ' ($context)' : ''}:');
    print('   Total: ${games.length}, Enriched: $enrichedCount');
    print('   Wishlisted: $wishlistedCount, Recommended: $recommendedCount');
    print('   Rated: $ratedCount, Top Three: $topThreeCount');
  }
}

