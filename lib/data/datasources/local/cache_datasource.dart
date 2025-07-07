// lib/data/datasources/local/cache_datasource.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/errors/exceptions.dart';
import '../../../core/constants/storage_constants.dart';
import '../../models/collection/collection_model.dart';
import '../../models/game/game_model.dart';
import '../../models/user_model.dart';
import '../../models/character/character_model.dart';
import '../../models/company/company_model.dart';
import '../../models/website/website_model.dart';
import '../../models/game/game_video_model.dart';
import '../../models/franchise_model.dart';
import '../../models/genre_model.dart';
import '../../models/platform/platform_model.dart';
import '../../models/game/game_mode_model.dart';
import '../../models/theme_model.dart';

abstract class LocalDataSource {
  // ==========================================
  // USER CACHING
  // ==========================================
  Future<UserModel?> getCachedUser();
  Future<void> cacheUser(UserModel user);
  Future<void> clearUserCache();

  // User-specific data (separated for better performance)
  Future<List<int>?> getCachedUserWishlist(String userId);
  Future<void> cacheUserWishlist(String userId, List<int> gameIds);
  Future<void> addToUserWishlist(String userId, int gameId);
  Future<void> removeFromUserWishlist(String userId, int gameId);

  Future<Map<int, double>?> getCachedUserRatings(String userId);
  Future<void> cacheUserRatings(String userId, Map<int, double> ratings);
  Future<void> cacheUserGameRating(String userId, int gameId, double rating);
  Future<void> removeUserGameRating(String userId, int gameId);

  Future<List<int>?> getCachedUserTopThree(String userId);
  Future<void> cacheUserTopThree(String userId, List<int> gameIds);

  Future<List<int>?> getCachedUserRecommendations(String userId);
  Future<void> cacheUserRecommendations(String userId, List<int> gameIds);

  Future<List<String>?> getCachedUserFollowing(String userId);
  Future<void> cacheUserFollowing(String userId, List<String> userIds);

  Future<List<String>?> getCachedUserFollowers(String userId);
  Future<void> cacheUserFollowers(String userId, List<String> userIds);

  // ==========================================
  // GAME CACHING
  // ==========================================

  // Basic Game Caching
  Future<List<GameModel>?> getCachedSearchResults(String query);
  Future<void> cacheSearchResults(String query, List<GameModel> games);

  Future<GameModel?> getCachedGameDetails(int gameId);
  Future<void> cacheGameDetails(int gameId, GameModel game);

  Future<List<GameModel>> getCachedGames();
  Future<void> cacheGames(List<GameModel> games);

  // Complete Game Details Caching
  Future<GameModel?> getCachedCompleteGameDetails(int gameId);
  Future<void> cacheCompleteGameDetails(int gameId, GameModel game);

  // Popular & Upcoming Games
  Future<List<GameModel>?> getCachedPopularGames();
  Future<void> cachePopularGames(List<GameModel> games);

  Future<List<GameModel>?> getCachedUpcomingGames();
  Future<void> cacheUpcomingGames(List<GameModel> games);

  // Similar Games & Related Content
  Future<List<GameModel>?> getCachedSimilarGames(int gameId);
  Future<void> cacheSimilarGames(int gameId, List<GameModel> games);

  Future<List<GameModel>?> getCachedGameDLCs(int gameId);
  Future<void> cacheGameDLCs(int gameId, List<GameModel> dlcs);

  Future<List<GameModel>?> getCachedGameExpansions(int gameId);
  Future<void> cacheGameExpansions(int gameId, List<GameModel> expansions);

  // ==========================================
  // GAME COMPONENTS CACHING
  // ==========================================

  // Companies
  Future<List<CompanyModel>?> getCachedGameCompanies(int gameId);
  Future<void> cacheGameCompanies(int gameId, List<CompanyModel> companies);
  Future<CompanyModel?> getCachedCompany(int companyId);
  Future<void> cacheCompany(int companyId, CompanyModel company);

  // Websites
  Future<List<WebsiteModel>?> getCachedGameWebsites(int gameId);
  Future<void> cacheGameWebsites(int gameId, List<WebsiteModel> websites);

  // Videos
  Future<List<GameVideoModel>?> getCachedGameVideos(int gameId);
  Future<void> cacheGameVideos(int gameId, List<GameVideoModel> videos);

  // Characters
  Future<List<CharacterModel>?> getCachedGameCharacters(int gameId);
  Future<void> cacheGameCharacters(int gameId, List<CharacterModel> characters);
  Future<CharacterModel?> getCachedCharacter(int characterId);
  Future<void> cacheCharacter(int characterId, CharacterModel character);

  // ==========================================
  // COLLECTIONS & FRANCHISES
  // ==========================================
  Future<CollectionModel?> getCachedCollection(int collectionId);
  Future<void> cacheCollection(int collectionId, CollectionModel collection);

  Future<FranchiseModel?> getCachedFranchise(int franchiseId);
  Future<void> cacheFranchise(int franchiseId, FranchiseModel franchise);

  // ==========================================
  // METADATA CACHING
  // ==========================================
  Future<List<GenreModel>?> getCachedGenres();
  Future<void> cacheGenres(List<GenreModel> genres);

  Future<List<PlatformModel>?> getCachedPlatforms();
  Future<void> cachePlatforms(List<PlatformModel> platforms);

  Future<List<GameModeModel>?> getCachedGameModes();
  Future<void> cacheGameModes(List<GameModeModel> gameModes);

  Future<List<ThemeModel>?> getCachedThemes();
  Future<void> cacheThemes(List<ThemeModel> themes);

  // ==========================================
  // GENERAL CACHE MANAGEMENT
  // ==========================================
  Future<void> clearCache();
  Future<void> clearUserSpecificCache(String userId);
  Future<void> clearGameCache();
  Future<void> clearMetadataCache();
  Future<bool> isDataExpired(String key, {CacheType? cacheType});
  Future<void> clearExpiredCache();
  Future<int> getCacheSize();
  Future<Map<String, DateTime>> getCacheInfo();
  Future<void> clearCachedGameDetails(int gameId);
}

enum CacheType {
  userData,
  gameBasic,
  gameComplete,
  gameComponents,
  metadata,
  search,
  social
}

class LocalDataSourceImpl implements LocalDataSource {
  final SharedPreferences sharedPreferences;

  LocalDataSourceImpl({required this.sharedPreferences});

  // ==========================================
  // HELPER METHODS
  // ==========================================

  Duration _getCacheExpiry(CacheType cacheType) {
    switch (cacheType) {
      case CacheType.userData:
        return const Duration(minutes: 30); // User data changes frequently
      case CacheType.gameBasic:
        return const Duration(hours: 2); // Basic game info
      case CacheType.gameComplete:
        return const Duration(hours: 6); // Complete game details
      case CacheType.gameComponents:
        return const Duration(hours: 12); // Companies, videos, etc.
      case CacheType.metadata:
        return const Duration(days: 1); // Genres, platforms, etc.
      case CacheType.search:
        return const Duration(hours: 1); // Search results
      case CacheType.social:
        return const Duration(minutes: 15); // Following, followers
    }
  }

  CacheType _getCacheTypeFromKey(String key) {
    if (key.contains('user_wishlist') || key.contains('user_ratings') || key.contains('user_top_three')) {
      return CacheType.userData;
    } else if (key.contains('complete_game_details')) {
      return CacheType.gameComplete;
    } else if (key.contains('game_companies') || key.contains('game_videos') || key.contains('game_websites')) {
      return CacheType.gameComponents;
    } else if (key.contains('genres') || key.contains('platforms') || key.contains('themes')) {
      return CacheType.metadata;
    } else if (key.contains('search_results')) {
      return CacheType.search;
    } else if (key.contains('following') || key.contains('followers')) {
      return CacheType.social;
    } else {
      return CacheType.gameBasic;
    }
  }

  Future<void> _cacheWithTimestamp(String key, String jsonString, {CacheType? cacheType}) async {
    await sharedPreferences.setString(key, jsonString);
    await sharedPreferences.setInt(
      '${key}_timestamp',
      DateTime.now().millisecondsSinceEpoch,
    );
    if (cacheType != null) {
      await sharedPreferences.setString('${key}_cache_type', cacheType.name);
    }
  }

  Future<T?> _getCachedData<T>(
      String key,
      T Function(Map<String, dynamic>) fromJson, {
        CacheType? cacheType,
      }) async {
    try {
      if (await isDataExpired(key, cacheType: cacheType)) {
        await _removeKeyWithTimestamp(key);
        return null;
      }

      final jsonString = sharedPreferences.getString(key);
      if (jsonString != null) {
        final json = jsonDecode(jsonString) as Map<String, dynamic>;
        return fromJson(json);
      }
      return null;
    } catch (e) {
      await _removeKeyWithTimestamp(key);
      return null;
    }
  }

  Future<List<T>?> _getCachedList<T>(
      String key,
      T Function(Map<String, dynamic>) fromJson, {
        CacheType? cacheType,
      }) async {
    try {
      if (await isDataExpired(key, cacheType: cacheType)) {
        await _removeKeyWithTimestamp(key);
        return null;
      }

      final jsonString = sharedPreferences.getString(key);
      if (jsonString != null) {
        final List<dynamic> jsonList = jsonDecode(jsonString);
        return jsonList.map((json) => fromJson(json as Map<String, dynamic>)).toList();
      }
      return null;
    } catch (e) {
      await _removeKeyWithTimestamp(key);
      return null;
    }
  }

  Future<void> _cacheList<T>(
      String key,
      List<T> items,
      Map<String, dynamic> Function(T) toJson, {
        CacheType? cacheType,
      }) async {
    try {
      final jsonList = items.map((item) => toJson(item)).toList();
      final jsonString = jsonEncode(jsonList);
      await _cacheWithTimestamp(key, jsonString, cacheType: cacheType);
    } catch (e) {
      throw CacheException(message: 'Failed to cache list for key: $key');
    }
  }

  Future<void> _removeKeyWithTimestamp(String key) async {
    await sharedPreferences.remove(key);
    await sharedPreferences.remove('${key}_timestamp');
    await sharedPreferences.remove('${key}_cache_type');
  }

  // ==========================================
  // USER CACHING IMPLEMENTATION
  // ==========================================

  @override
  Future<UserModel?> getCachedUser() async {
    return await _getCachedData(
      StorageConstants.userKey,
          (json) => UserModel.fromJson(json),
      cacheType: CacheType.userData,
    );
  }

  @override
  Future<void> cacheUser(UserModel user) async {
    try {
      final jsonString = jsonEncode(user.toJson());
      await _cacheWithTimestamp(StorageConstants.userKey, jsonString, cacheType: CacheType.userData);
    } catch (e) {
      throw CacheException(message: 'Failed to cache user');
    }
  }

  @override
  Future<void> clearUserCache() async {
    try {
      await _removeKeyWithTimestamp(StorageConstants.userKey);
    } catch (e) {
      throw CacheException(message: 'Failed to clear user cache');
    }
  }

  @override
  Future<List<int>?> getCachedUserWishlist(String userId) async {
    try {
      final key = '${StorageConstants.userWishlistKey}_$userId';
      if (await isDataExpired(key, cacheType: CacheType.userData)) {
        await _removeKeyWithTimestamp(key);
        return null;
      }

      final jsonString = sharedPreferences.getString(key);
      if (jsonString != null) {
        final List<dynamic> jsonList = jsonDecode(jsonString);
        return jsonList.map((id) => id as int).toList();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> cacheUserWishlist(String userId, List<int> gameIds) async {
    try {
      final key = '${StorageConstants.userWishlistKey}_$userId';
      final jsonString = jsonEncode(gameIds);
      await _cacheWithTimestamp(key, jsonString, cacheType: CacheType.userData);
    } catch (e) {
      throw CacheException(message: 'Failed to cache user wishlist');
    }
  }

  @override
  Future<void> addToUserWishlist(String userId, int gameId) async {
    final currentWishlist = await getCachedUserWishlist(userId) ?? <int>[];
    if (!currentWishlist.contains(gameId)) {
      currentWishlist.add(gameId);
      await cacheUserWishlist(userId, currentWishlist);
    }
  }

  @override
  Future<void> removeFromUserWishlist(String userId, int gameId) async {
    final currentWishlist = await getCachedUserWishlist(userId) ?? <int>[];
    currentWishlist.remove(gameId);
    await cacheUserWishlist(userId, currentWishlist);
  }

  @override
  Future<Map<int, double>?> getCachedUserRatings(String userId) async {
    try {
      final key = '${StorageConstants.userRatingsKey}_$userId';
      if (await isDataExpired(key, cacheType: CacheType.userData)) {
        await _removeKeyWithTimestamp(key);
        return null;
      }

      final jsonString = sharedPreferences.getString(key);
      if (jsonString != null) {
        final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
        return jsonMap.map((key, value) => MapEntry(int.parse(key), value.toDouble()));
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> cacheUserRatings(String userId, Map<int, double> ratings) async {
    try {
      final key = '${StorageConstants.userRatingsKey}_$userId';
      final jsonMap = ratings.map((key, value) => MapEntry(key.toString(), value));
      final jsonString = jsonEncode(jsonMap);
      await _cacheWithTimestamp(key, jsonString, cacheType: CacheType.userData);
    } catch (e) {
      throw CacheException(message: 'Failed to cache user ratings');
    }
  }

  @override
  Future<void> cacheUserGameRating(String userId, int gameId, double rating) async {
    final currentRatings = await getCachedUserRatings(userId) ?? <int, double>{};
    currentRatings[gameId] = rating;
    await cacheUserRatings(userId, currentRatings);
  }

  @override
  Future<void> removeUserGameRating(String userId, int gameId) async {
    final currentRatings = await getCachedUserRatings(userId) ?? <int, double>{};
    currentRatings.remove(gameId);
    await cacheUserRatings(userId, currentRatings);
  }

  @override
  Future<List<int>?> getCachedUserTopThree(String userId) async {
    try {
      final key = '${StorageConstants.userTopThreeKey}_$userId';
      if (await isDataExpired(key, cacheType: CacheType.userData)) {
        await _removeKeyWithTimestamp(key);
        return null;
      }

      final jsonString = sharedPreferences.getString(key);
      if (jsonString != null) {
        final List<dynamic> jsonList = jsonDecode(jsonString);
        return jsonList.map((id) => id as int).toList();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> cacheUserTopThree(String userId, List<int> gameIds) async {
    try {
      final key = '${StorageConstants.userTopThreeKey}_$userId';
      final jsonString = jsonEncode(gameIds);
      await _cacheWithTimestamp(key, jsonString, cacheType: CacheType.userData);
    } catch (e) {
      throw CacheException(message: 'Failed to cache user top three');
    }
  }

  @override
  Future<List<int>?> getCachedUserRecommendations(String userId) async {
    try {
      final key = '${StorageConstants.userRecommendationsKey}_$userId';
      if (await isDataExpired(key, cacheType: CacheType.userData)) {
        await _removeKeyWithTimestamp(key);
        return null;
      }

      final jsonString = sharedPreferences.getString(key);
      if (jsonString != null) {
        final List<dynamic> jsonList = jsonDecode(jsonString);
        return jsonList.map((id) => id as int).toList();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> cacheUserRecommendations(String userId, List<int> gameIds) async {
    try {
      final key = '${StorageConstants.userRecommendationsKey}_$userId';
      final jsonString = jsonEncode(gameIds);
      await _cacheWithTimestamp(key, jsonString, cacheType: CacheType.userData);
    } catch (e) {
      throw CacheException(message: 'Failed to cache user recommendations');
    }
  }

  @override
  Future<List<String>?> getCachedUserFollowing(String userId) async {
    try {
      final key = '${StorageConstants.userFollowingKey}_$userId';
      if (await isDataExpired(key, cacheType: CacheType.social)) {
        await _removeKeyWithTimestamp(key);
        return null;
      }

      final jsonString = sharedPreferences.getString(key);
      if (jsonString != null) {
        final List<dynamic> jsonList = jsonDecode(jsonString);
        return jsonList.map((id) => id as String).toList();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> cacheUserFollowing(String userId, List<String> userIds) async {
    try {
      final key = '${StorageConstants.userFollowingKey}_$userId';
      final jsonString = jsonEncode(userIds);
      await _cacheWithTimestamp(key, jsonString, cacheType: CacheType.social);
    } catch (e) {
      throw CacheException(message: 'Failed to cache user following');
    }
  }

  @override
  Future<List<String>?> getCachedUserFollowers(String userId) async {
    try {
      final key = '${StorageConstants.userFollowersKey}_$userId';
      if (await isDataExpired(key, cacheType: CacheType.social)) {
        await _removeKeyWithTimestamp(key);
        return null;
      }

      final jsonString = sharedPreferences.getString(key);
      if (jsonString != null) {
        final List<dynamic> jsonList = jsonDecode(jsonString);
        return jsonList.map((id) => id as String).toList();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> cacheUserFollowers(String userId, List<String> userIds) async {
    try {
      final key = '${StorageConstants.userFollowersKey}_$userId';
      final jsonString = jsonEncode(userIds);
      await _cacheWithTimestamp(key, jsonString, cacheType: CacheType.social);
    } catch (e) {
      throw CacheException(message: 'Failed to cache user followers');
    }
  }

  // ==========================================
  // GAME CACHING IMPLEMENTATION
  // ==========================================

  @override
  Future<List<GameModel>?> getCachedSearchResults(String query) async {
    final key = '${StorageConstants.searchResultsKey}_${query.toLowerCase()}';
    return await _getCachedList(
      key,
          (json) => GameModel.fromJson(json),
      cacheType: CacheType.search,
    );
  }

  @override
  Future<void> cacheSearchResults(String query, List<GameModel> games) async {
    final key = '${StorageConstants.searchResultsKey}_${query.toLowerCase()}';
    await _cacheList(
      key,
      games,
          (game) => game.toJson(),
      cacheType: CacheType.search,
    );
  }

  @override
  Future<GameModel?> getCachedGameDetails(int gameId) async {
    final key = '${StorageConstants.gameDetailsKey}_$gameId';
    return await _getCachedData(
      key,
          (json) => GameModel.fromJson(json),
      cacheType: CacheType.gameBasic,
    );
  }

  @override
  Future<void> cacheGameDetails(int gameId, GameModel game) async {
    final key = '${StorageConstants.gameDetailsKey}_$gameId';
    try {
      final jsonString = jsonEncode(game.toJson());
      await _cacheWithTimestamp(key, jsonString, cacheType: CacheType.gameBasic);
    } catch (e) {
      throw CacheException(message: 'Failed to cache game details');
    }
  }

  @override
  Future<GameModel?> getCachedCompleteGameDetails(int gameId) async {
    final key = '${StorageConstants.completeGameDetailsKey}_$gameId';
    return await _getCachedData(
      key,
          (json) => GameModel.fromJson(json),
      cacheType: CacheType.gameComplete,
    );
  }

  @override
  Future<void> cacheCompleteGameDetails(int gameId, GameModel game) async {
    final key = '${StorageConstants.completeGameDetailsKey}_$gameId';
    try {
      final jsonString = jsonEncode(game.toJson());
      await _cacheWithTimestamp(key, jsonString, cacheType: CacheType.gameComplete);
    } catch (e) {
      throw CacheException(message: 'Failed to cache complete game details');
    }
  }

  @override
  Future<List<GameModel>> getCachedGames() async {
    return await _getCachedList(
      StorageConstants.popularGamesKey,
          (json) => GameModel.fromJson(json),
      cacheType: CacheType.gameBasic,
    ) ?? [];
  }

  @override
  Future<void> cacheGames(List<GameModel> games) async {
    await _cacheList(
      StorageConstants.popularGamesKey,
      games,
          (game) => game.toJson(),
      cacheType: CacheType.gameBasic,
    );
  }

  @override
  Future<List<GameModel>?> getCachedPopularGames() async {
    return await _getCachedList(
      StorageConstants.popularGamesKey,
          (json) => GameModel.fromJson(json),
      cacheType: CacheType.gameBasic,
    );
  }

  @override
  Future<void> cachePopularGames(List<GameModel> games) async {
    await _cacheList(
      StorageConstants.popularGamesKey,
      games,
          (game) => game.toJson(),
      cacheType: CacheType.gameBasic,
    );
  }

  @override
  Future<List<GameModel>?> getCachedUpcomingGames() async {
    return await _getCachedList(
      StorageConstants.upcomingGamesKey,
          (json) => GameModel.fromJson(json),
      cacheType: CacheType.gameBasic,
    );
  }

  @override
  Future<void> cacheUpcomingGames(List<GameModel> games) async {
    await _cacheList(
      StorageConstants.upcomingGamesKey,
      games,
          (game) => game.toJson(),
      cacheType: CacheType.gameBasic,
    );
  }

  @override
  Future<List<GameModel>?> getCachedSimilarGames(int gameId) async {
    final key = '${StorageConstants.similarGamesKey}_$gameId';
    return await _getCachedList(
      key,
          (json) => GameModel.fromJson(json),
      cacheType: CacheType.gameBasic,
    );
  }

  @override
  Future<void> cacheSimilarGames(int gameId, List<GameModel> games) async {
    final key = '${StorageConstants.similarGamesKey}_$gameId';
    await _cacheList(
      key,
      games,
          (game) => game.toJson(),
      cacheType: CacheType.gameBasic,
    );
  }

  @override
  Future<List<GameModel>?> getCachedGameDLCs(int gameId) async {
    final key = '${StorageConstants.gameDLCsKey}_$gameId';
    return await _getCachedList(
      key,
          (json) => GameModel.fromJson(json),
      cacheType: CacheType.gameBasic,
    );
  }

  @override
  Future<void> cacheGameDLCs(int gameId, List<GameModel> dlcs) async {
    final key = '${StorageConstants.gameDLCsKey}_$gameId';
    await _cacheList(
      key,
      dlcs,
          (game) => game.toJson(),
      cacheType: CacheType.gameBasic,
    );
  }

  @override
  Future<List<GameModel>?> getCachedGameExpansions(int gameId) async {
    final key = '${StorageConstants.gameExpansionsKey}_$gameId';
    return await _getCachedList(
      key,
          (json) => GameModel.fromJson(json),
      cacheType: CacheType.gameBasic,
    );
  }

  @override
  Future<void> cacheGameExpansions(int gameId, List<GameModel> expansions) async {
    final key = '${StorageConstants.gameExpansionsKey}_$gameId';
    await _cacheList(
      key,
      expansions,
          (game) => game.toJson(),
      cacheType: CacheType.gameBasic,
    );
  }

  // ==========================================
  // GAME COMPONENTS CACHING IMPLEMENTATION
  // ==========================================

  @override
  Future<List<CompanyModel>?> getCachedGameCompanies(int gameId) async {
    final key = '${StorageConstants.gameCompaniesKey}_$gameId';
    return await _getCachedList(
      key,
          (json) => CompanyModel.fromJson(json),
      cacheType: CacheType.gameComponents,
    );
  }

  @override
  Future<void> cacheGameCompanies(int gameId, List<CompanyModel> companies) async {
    final key = '${StorageConstants.gameCompaniesKey}_$gameId';
    await _cacheList(
      key,
      companies,
          (company) => company.toJson(),
      cacheType: CacheType.gameComponents,
    );
  }

  @override
  Future<CompanyModel?> getCachedCompany(int companyId) async {
    final key = '${StorageConstants.companyKey}_$companyId';
    return await _getCachedData(
      key,
          (json) => CompanyModel.fromJson(json),
      cacheType: CacheType.gameComponents,
    );
  }

  @override
  Future<void> cacheCompany(int companyId, CompanyModel company) async {
    final key = '${StorageConstants.companyKey}_$companyId';
    try {
      final jsonString = jsonEncode(company.toJson());
      await _cacheWithTimestamp(key, jsonString, cacheType: CacheType.gameComponents);
    } catch (e) {
      throw CacheException(message: 'Failed to cache company');
    }
  }

  @override
  Future<List<WebsiteModel>?> getCachedGameWebsites(int gameId) async {
    final key = '${StorageConstants.gameWebsitesKey}_$gameId';
    return await _getCachedList(
      key,
          (json) => WebsiteModel.fromJson(json),
      cacheType: CacheType.gameComponents,
    );
  }

  @override
  Future<void> cacheGameWebsites(int gameId, List<WebsiteModel> websites) async {
    final key = '${StorageConstants.gameWebsitesKey}_$gameId';
    await _cacheList(
      key,
      websites,
          (website) => website.toJson(),
      cacheType: CacheType.gameComponents,
    );
  }

  @override
  Future<List<GameVideoModel>?> getCachedGameVideos(int gameId) async {
    final key = '${StorageConstants.gameVideosKey}_$gameId';
    return await _getCachedList(
      key,
          (json) => GameVideoModel.fromJson(json),
      cacheType: CacheType.gameComponents,
    );
  }

  @override
  Future<void> cacheGameVideos(int gameId, List<GameVideoModel> videos) async {
    final key = '${StorageConstants.gameVideosKey}_$gameId';
    await _cacheList(
      key,
      videos,
          (video) => video.toJson(),
      cacheType: CacheType.gameComponents,
    );
  }

  @override
  Future<List<CharacterModel>?> getCachedGameCharacters(int gameId) async {
    final key = '${StorageConstants.gameCharactersKey}_$gameId';
    return await _getCachedList(
      key,
          (json) => CharacterModel.fromJson(json),
      cacheType: CacheType.gameComponents,
    );
  }

  @override
  Future<void> cacheGameCharacters(int gameId, List<CharacterModel> characters) async {
    final key = '${StorageConstants.gameCharactersKey}_$gameId';
    await _cacheList(
      key,
      characters,
          (character) => character.toJson(),
      cacheType: CacheType.gameComponents,
    );
  }

  @override
  Future<CharacterModel?> getCachedCharacter(int characterId) async {
    final key = '${StorageConstants.characterKey}_$characterId';
    return await _getCachedData(
      key,
          (json) => CharacterModel.fromJson(json),
      cacheType: CacheType.gameComponents,
    );
  }

  @override
  Future<void> cacheCharacter(int characterId, CharacterModel character) async {
    final key = '${StorageConstants.characterKey}_$characterId';
    try {
      final jsonString = jsonEncode(character.toJson());
      await _cacheWithTimestamp(key, jsonString, cacheType: CacheType.gameComponents);
    } catch (e) {
      throw CacheException(message: 'Failed to cache character');
    }
  }

  // ==========================================
  // COLLECTIONS & FRANCHISES IMPLEMENTATION
  // ==========================================

  @override
  Future<CollectionModel?> getCachedCollection(int collectionId) async {
    final key = '${StorageConstants.collectionKey}_$collectionId';
    return await _getCachedData(
      key,
          (json) => CollectionModel.fromJson(json),
      cacheType: CacheType.gameComponents,
    );
  }

  @override
  Future<void> cacheCollection(int collectionId, CollectionModel collection) async {
    final key = '${StorageConstants.collectionKey}_$collectionId';
    try {
      final jsonString = jsonEncode(collection.toJson());
      await _cacheWithTimestamp(key, jsonString, cacheType: CacheType.gameComponents);
    } catch (e) {
      throw CacheException(message: 'Failed to cache collection');
    }
  }

  @override
  Future<FranchiseModel?> getCachedFranchise(int franchiseId) async {
    final key = '${StorageConstants.franchiseKey}_$franchiseId';
    return await _getCachedData(
      key,
          (json) => FranchiseModel.fromJson(json),
      cacheType: CacheType.gameComponents,
    );
  }

  @override
  Future<void> cacheFranchise(int franchiseId, FranchiseModel franchise) async {
    final key = '${StorageConstants.franchiseKey}_$franchiseId';
    try {
      final jsonString = jsonEncode(franchise.toJson());
      await _cacheWithTimestamp(key, jsonString, cacheType: CacheType.gameComponents);
    } catch (e) {
      throw CacheException(message: 'Failed to cache franchise');
    }
  }

  // ==========================================
  // METADATA CACHING IMPLEMENTATION
  // ==========================================

  @override
  Future<List<GenreModel>?> getCachedGenres() async {
    return await _getCachedList(
      StorageConstants.genresKey,
          (json) => GenreModel.fromJson(json),
      cacheType: CacheType.metadata,
    );
  }

  @override
  Future<void> cacheGenres(List<GenreModel> genres) async {
    await _cacheList(
      StorageConstants.genresKey,
      genres,
          (genre) => genre.toJson(),
      cacheType: CacheType.metadata,
    );
  }

  @override
  Future<List<PlatformModel>?> getCachedPlatforms() async {
    return await _getCachedList(
      StorageConstants.platformsKey,
          (json) => PlatformModel.fromJson(json),
      cacheType: CacheType.metadata,
    );
  }

  @override
  Future<void> cachePlatforms(List<PlatformModel> platforms) async {
    await _cacheList(
      StorageConstants.platformsKey,
      platforms,
          (platform) => platform.toJson(),
      cacheType: CacheType.metadata,
    );
  }

  @override
  Future<List<GameModeModel>?> getCachedGameModes() async {
    return await _getCachedList(
      StorageConstants.gameModesKey,
          (json) => GameModeModel.fromJson(json),
      cacheType: CacheType.metadata,
    );
  }

  @override
  Future<void> cacheGameModes(List<GameModeModel> gameModes) async {
    await _cacheList(
      StorageConstants.gameModesKey,
      gameModes,
          (gameMode) => gameMode.toJson(),
      cacheType: CacheType.metadata,
    );
  }

  @override
  Future<List<ThemeModel>?> getCachedThemes() async {
    return await _getCachedList(
      StorageConstants.themesKey,
          (json) => ThemeModel.fromJson(json),
      cacheType: CacheType.metadata,
    );
  }

  @override
  Future<void> cacheThemes(List<ThemeModel> themes) async {
    await _cacheList(
      StorageConstants.themesKey,
      themes,
          (theme) => theme.toJson(),
      cacheType: CacheType.metadata,
    );
  }

  // ==========================================
  // GENERAL CACHE MANAGEMENT IMPLEMENTATION
  // ==========================================

  @override
  Future<void> clearCache() async {
    try {
      final keys = sharedPreferences.getKeys().where((key) =>
      key.startsWith(StorageConstants.userKey) ||
          key.startsWith(StorageConstants.searchResultsKey) ||
          key.startsWith(StorageConstants.gameDetailsKey) ||
          key.startsWith(StorageConstants.popularGamesKey) ||
          key.startsWith(StorageConstants.completeGameDetailsKey) ||
          key.startsWith(StorageConstants.gameCompaniesKey) ||
          key.startsWith(StorageConstants.gameWebsitesKey) ||
          key.startsWith(StorageConstants.gameVideosKey) ||
          key.startsWith(StorageConstants.characterKey) ||
          key.startsWith(StorageConstants.collectionKey) ||
          key.startsWith(StorageConstants.franchiseKey) ||
          key.startsWith(StorageConstants.genresKey) ||
          key.startsWith(StorageConstants.platformsKey) ||
          key.contains('_timestamp') ||
          key.contains('_cache_type'));

      for (final key in keys) {
        await sharedPreferences.remove(key);
      }
    } catch (e) {
      throw CacheException(message: 'Failed to clear cache');
    }
  }

  @override
  Future<void> clearUserSpecificCache(String userId) async {
    try {
      final keys = sharedPreferences.getKeys().where((key) =>
      key.contains(userId) ||
          key.startsWith('${StorageConstants.userWishlistKey}_$userId') ||
          key.startsWith('${StorageConstants.userRatingsKey}_$userId') ||
          key.startsWith('${StorageConstants.userTopThreeKey}_$userId'));

      for (final key in keys) {
        await _removeKeyWithTimestamp(key);
      }
    } catch (e) {
      throw CacheException(message: 'Failed to clear user-specific cache');
    }
  }

  @override
  Future<void> clearGameCache() async {
    try {
      final keys = sharedPreferences.getKeys().where((key) =>
      key.startsWith(StorageConstants.gameDetailsKey) ||
          key.startsWith(StorageConstants.searchResultsKey) ||
          key.startsWith(StorageConstants.popularGamesKey) ||
          key.startsWith(StorageConstants.completeGameDetailsKey) ||
          key.startsWith(StorageConstants.similarGamesKey) ||
          key.startsWith(StorageConstants.gameDLCsKey) ||
          key.startsWith(StorageConstants.gameExpansionsKey));

      for (final key in keys) {
        await _removeKeyWithTimestamp(key);
      }
    } catch (e) {
      throw CacheException(message: 'Failed to clear game cache');
    }
  }

  @override
  Future<void> clearMetadataCache() async {
    try {
      final keys = sharedPreferences.getKeys().where((key) =>
      key.startsWith(StorageConstants.genresKey) ||
          key.startsWith(StorageConstants.platformsKey) ||
          key.startsWith(StorageConstants.gameModesKey) ||
          key.startsWith(StorageConstants.themesKey));

      for (final key in keys) {
        await _removeKeyWithTimestamp(key);
      }
    } catch (e) {
      throw CacheException(message: 'Failed to clear metadata cache');
    }
  }

  @override
  Future<bool> isDataExpired(String key, {CacheType? cacheType}) async {
    try {
      final timestamp = sharedPreferences.getInt('${key}_timestamp');
      if (timestamp == null) return true;

      final cachedTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final now = DateTime.now();
      final difference = now.difference(cachedTime);

      // Use provided cache type or determine from key
      final type = cacheType ?? _getCacheTypeFromKey(key);
      final maxAge = _getCacheExpiry(type);

      return difference > maxAge;
    } catch (e) {
      return true; // If we can't determine, consider it expired
    }
  }

  @override
  Future<void> clearExpiredCache() async {
    try {
      final allKeys = sharedPreferences.getKeys();
      final cacheKeys = allKeys.where((key) => !key.contains('_timestamp') && !key.contains('_cache_type'));

      for (final key in cacheKeys) {
        if (await isDataExpired(key)) {
          await _removeKeyWithTimestamp(key);
        }
      }
    } catch (e) {
      throw CacheException(message: 'Failed to clear expired cache');
    }
  }

  @override
  Future<int> getCacheSize() async {
    try {
      int totalSize = 0;
      final keys = sharedPreferences.getKeys();

      for (final key in keys) {
        final value = sharedPreferences.get(key);
        if (value is String) {
          totalSize += value.length;
        }
      }

      return totalSize;
    } catch (e) {
      return 0;
    }
  }

  @override
  Future<Map<String, DateTime>> getCacheInfo() async {
    try {
      final Map<String, DateTime> cacheInfo = {};
      final keys = sharedPreferences.getKeys().where((key) => key.contains('_timestamp'));

      for (final key in keys) {
        final timestamp = sharedPreferences.getInt(key);
        if (timestamp != null) {
          final originalKey = key.replaceAll('_timestamp', '');
          cacheInfo[originalKey] = DateTime.fromMillisecondsSinceEpoch(timestamp);
        }
      }

      return cacheInfo;
    } catch (e) {
      return {};
    }
  }


  @override
  Future<void> clearCachedGameDetails(int gameId) async {
    try {
      final key = '${StorageConstants.gameDetailsKey}_$gameId';
      await _removeKeyWithTimestamp(key);

      final completeKey = '${StorageConstants.completeGameDetailsKey}_$gameId';
      await _removeKeyWithTimestamp(completeKey);
    } catch (e) {
      throw CacheException(message: 'Failed to clear cached game details');
    }
  }
}