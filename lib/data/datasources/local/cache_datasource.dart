// data/datasources/local/cache_datasource.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/errors/exceptions.dart';
import '../../../core/constants/storage_constants.dart';
import '../../models/game/game_model.dart';
import '../../models/user_model.dart';

abstract class LocalDataSource {
  // User Caching
  Future<UserModel?> getCachedUser();
  Future<void> cacheUser(UserModel user);
  Future<void> clearUserCache();

  // Game Caching
  Future<List<GameModel>?> getCachedSearchResults(String query);
  Future<void> cacheSearchResults(String query, List<GameModel> games);
  Future<GameModel?> getCachedGameDetails(int gameId);
  Future<void> cacheGameDetails(int gameId, GameModel game);
  Future<List<GameModel>> getCachedGames();
  Future<void> cacheGames(List<GameModel> games);

  // General Cache Management
  Future<void> clearCache();
  Future<bool> isDataExpired(String key);
}

class LocalDataSourceImpl implements LocalDataSource {
  final SharedPreferences sharedPreferences;

  LocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<UserModel?> getCachedUser() async {
    try {
      final jsonString = sharedPreferences.getString(StorageConstants.userKey);
      if (jsonString != null) {
        final json = jsonDecode(jsonString);
        return UserModel.fromJson(json);
      }
      return null;
    } catch (e) {
      throw CacheException(message: 'Failed to get cached user');
    }
  }

  @override
  Future<void> cacheUser(UserModel user) async {
    try {
      final jsonString = jsonEncode(user.toJson());
      await sharedPreferences.setString(StorageConstants.userKey, jsonString);

      // Store cache timestamp
      await sharedPreferences.setInt(
        '${StorageConstants.userKey}_timestamp',
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (e) {
      throw CacheException(message: 'Failed to cache user');
    }
  }

  @override
  Future<void> clearUserCache() async {
    try {
      await sharedPreferences.remove(StorageConstants.userKey);
      await sharedPreferences.remove('${StorageConstants.userKey}_timestamp');
    } catch (e) {
      throw CacheException(message: 'Failed to clear user cache');
    }
  }

  @override
  Future<List<GameModel>?> getCachedSearchResults(String query) async {
    try {
      final key = '${StorageConstants.searchResultsKey}_${query.toLowerCase()}';

      // Check if data is expired
      if (await isDataExpired(key)) {
        await sharedPreferences.remove(key);
        await sharedPreferences.remove('${key}_timestamp');
        return null;
      }

      final jsonString = sharedPreferences.getString(key);
      if (jsonString != null) {
        final List<dynamic> jsonList = jsonDecode(jsonString);
        return jsonList.map((json) => GameModel.fromJson(json)).toList();
      }
      return null;
    } catch (e) {
      throw CacheException(message: 'Failed to get cached search results');
    }
  }

  @override
  Future<void> cacheSearchResults(String query, List<GameModel> games) async {
    try {
      final key = '${StorageConstants.searchResultsKey}_${query.toLowerCase()}';
      final jsonList = games.map((game) => game.toJson()).toList();
      final jsonString = jsonEncode(jsonList);

      await sharedPreferences.setString(key, jsonString);
      await sharedPreferences.setInt(
        '${key}_timestamp',
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (e) {
      throw CacheException(message: 'Failed to cache search results');
    }
  }

  @override
  Future<GameModel?> getCachedGameDetails(int gameId) async {
    try {
      final key = '${StorageConstants.gameDetailsKey}_$gameId';

      // Check if data is expired
      if (await isDataExpired(key)) {
        await sharedPreferences.remove(key);
        await sharedPreferences.remove('${key}_timestamp');
        return null;
      }

      final jsonString = sharedPreferences.getString(key);
      if (jsonString != null) {
        final json = jsonDecode(jsonString);
        return GameModel.fromJson(json);
      }
      return null;
    } catch (e) {
      throw CacheException(message: 'Failed to get cached game details');
    }
  }

  @override
  Future<void> cacheGameDetails(int gameId, GameModel game) async {
    try {
      final key = '${StorageConstants.gameDetailsKey}_$gameId';
      final jsonString = jsonEncode(game.toJson());

      await sharedPreferences.setString(key, jsonString);
      await sharedPreferences.setInt(
        '${key}_timestamp',
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (e) {
      throw CacheException(message: 'Failed to cache game details');
    }
  }

  @override
  Future<List<GameModel>> getCachedGames() async {
    try {
      // Check if data is expired
      if (await isDataExpired(StorageConstants.popularGamesKey)) {
        await sharedPreferences.remove(StorageConstants.popularGamesKey);
        await sharedPreferences.remove('${StorageConstants.popularGamesKey}_timestamp');
        return [];
      }

      final jsonString = sharedPreferences.getString(StorageConstants.popularGamesKey);
      if (jsonString != null) {
        final List<dynamic> jsonList = jsonDecode(jsonString);
        return jsonList.map((json) => GameModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw CacheException(message: 'Failed to get cached games');
    }
  }

  @override
  Future<void> cacheGames(List<GameModel> games) async {
    try {
      final jsonList = games.map((game) => game.toJson()).toList();
      final jsonString = jsonEncode(jsonList);

      await sharedPreferences.setString(StorageConstants.popularGamesKey, jsonString);
      await sharedPreferences.setInt(
        '${StorageConstants.popularGamesKey}_timestamp',
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (e) {
      throw CacheException(message: 'Failed to cache games');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      // Get all keys that start with our cache prefixes
      final keys = sharedPreferences.getKeys().where((key) =>
      key.startsWith(StorageConstants.userKey) ||
          key.startsWith(StorageConstants.searchResultsKey) ||
          key.startsWith(StorageConstants.gameDetailsKey) ||
          key.startsWith(StorageConstants.popularGamesKey));

      for (final key in keys) {
        await sharedPreferences.remove(key);
      }
    } catch (e) {
      throw CacheException(message: 'Failed to clear cache');
    }
  }

  @override
  Future<bool> isDataExpired(String key) async {
    try {
      final timestamp = sharedPreferences.getInt('${key}_timestamp');
      if (timestamp == null) return true;

      final cachedTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final now = DateTime.now();
      final difference = now.difference(cachedTime);

      // Data expires after 1 hour for search results and game details
      // User data expires after 24 hours
      final maxAge = key.contains(StorageConstants.userKey)
          ? const Duration(hours: 24)
          : const Duration(hours: 1);

      return difference > maxAge;
    } catch (e) {
      return true; // If we can't determine, consider it expired
    }
  }
}