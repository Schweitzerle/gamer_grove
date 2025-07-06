// lib/data/datasources/remote/igdb/shared_prefs_token_manager.dart
// Production-ready Token Manager mit SharedPreferences

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';

class SharedPrefsTokenManager {
  static SharedPrefsTokenManager? _instance;
  static SharedPrefsTokenManager get instance => _instance ??= SharedPrefsTokenManager._();

  SharedPrefsTokenManager._();

  static const String _tokenKey = 'igdb_access_token';
  static const String _expiryKey = 'igdb_token_expiry';

  final http.Client _httpClient = http.Client();

  // Cache für ultra-schnellen Zugriff
  String? _cachedToken;
  DateTime? _cachedExpiry;
  bool _isRefreshing = false;

  Future<String> getValidToken() async {
    print('🏦 TOKEN MANAGER: Getting valid token...');

    // Prüfe Cache zuerst (ultra-schnell)
    if (_cachedToken != null &&
        _cachedExpiry != null &&
        DateTime.now().isBefore(_cachedExpiry!.subtract(Duration(hours: 1)))) {
      print('⚡ TOKEN MANAGER: Using cached token (${_cachedExpiry!.difference(DateTime.now()).inDays} days left)');
      return _cachedToken!;
    }

    // Verhindere gleichzeitige Refreshs
    if (_isRefreshing) {
      print('⏳ TOKEN MANAGER: Refresh in progress, waiting...');
      while (_isRefreshing) {
        await Future.delayed(Duration(milliseconds: 50));
      }
      return _cachedToken!;
    }

    try {
      _isRefreshing = true;

      // Lade von SharedPreferences
      await _loadFromPrefs();

      // Prüfe ob Token noch gültig ist
      if (_cachedToken != null &&
          _cachedExpiry != null &&
          DateTime.now().isBefore(_cachedExpiry!.subtract(Duration(hours: 1)))) {
        print('✅ TOKEN MANAGER: Using stored token (${_cachedExpiry!.difference(DateTime.now()).inDays} days left)');
        return _cachedToken!;
      }

      // Token abgelaufen oder nicht vorhanden -> neuen holen
      print('🔄 TOKEN MANAGER: Token expired or missing, refreshing...');
      await _refreshAndStoreToken();

      return _cachedToken!;

    } finally {
      _isRefreshing = false;
    }
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      _cachedToken = prefs.getString(_tokenKey);
      final expiryString = prefs.getString(_expiryKey);

      if (expiryString != null) {
        _cachedExpiry = DateTime.parse(expiryString);
      }

      if (_cachedToken != null && _cachedExpiry != null) {
        print('📂 TOKEN MANAGER: Loaded token from storage');
      }
    } catch (e) {
      print('⚠️ TOKEN MANAGER: Error loading from prefs: $e');
      _cachedToken = null;
      _cachedExpiry = null;
    }
  }

  Future<void> _refreshAndStoreToken() async {
    try {
      print('🔄 TOKEN MANAGER: Requesting new token from Twitch...');

      // Hole neuen Token von Twitch
      final request = http.Request('POST', Uri.parse('https://id.twitch.tv/oauth2/token'));
      request.headers['Content-Type'] = 'application/x-www-form-urlencoded';
      request.bodyFields = {
        'client_id': ApiConstants.igdbClientId,
        'client_secret': ApiConstants.igdbClientSecret,
        'grant_type': 'client_credentials',
      };

      final streamedResponse = await _httpClient.send(request);
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode != 200) {
        throw ServerException(
          message: 'Failed to refresh token: ${response.body}',
          statusCode: response.statusCode,
        );
      }

      final tokenData = json.decode(response.body);
      final accessToken = tokenData['access_token'];
      final expiresIn = tokenData['expires_in'] as int;

      // IGDB Tokens sind normalerweise 60 Tage gültig
      final expiryDate = DateTime.now().add(Duration(seconds: expiresIn));

      print('✅ TOKEN MANAGER: Got new token, expires at: $expiryDate');
      print('📅 TOKEN MANAGER: Token valid for ${expiryDate.difference(DateTime.now()).inDays} days');

      // Speichere in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, accessToken);
      await prefs.setString(_expiryKey, expiryDate.toIso8601String());

      // Update Cache
      _cachedToken = accessToken;
      _cachedExpiry = expiryDate;

      print('💾 TOKEN MANAGER: Token stored locally');

    } catch (e) {
      print('💥 TOKEN MANAGER: Token refresh failed: $e');
      throw ServerException(message: 'Token refresh failed: $e');
    }
  }

  // Für manuellen Token-Clear (bei Logout oder Reset)
  Future<void> clearToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_expiryKey);

      _cachedToken = null;
      _cachedExpiry = null;

      print('🗑️ TOKEN MANAGER: Token cleared');
    } catch (e) {
      print('⚠️ TOKEN MANAGER: Error clearing token: $e');
    }
  }

  // Für Debugging
  Future<Map<String, dynamic>> getTokenInfo() async {
    await _loadFromPrefs();

    return {
      'has_token': _cachedToken != null,
      'expires_at': _cachedExpiry?.toIso8601String(),
      'days_left': _cachedExpiry?.difference(DateTime.now()).inDays ?? 0,
      'is_valid': _cachedToken != null &&
          _cachedExpiry != null &&
          DateTime.now().isBefore(_cachedExpiry!),
    };
  }

  // Background refresh (optional, für sehr lange App-Nutzung)
  Future<void> refreshTokenIfNeeded() async {
    try {
      await _loadFromPrefs();

      if (_cachedExpiry != null &&
          DateTime.now().isAfter(_cachedExpiry!.subtract(Duration(days: 7)))) {
        print('🔄 TOKEN MANAGER: Background refresh triggered (expires in < 7 days)');
        await _refreshAndStoreToken();
      }
    } catch (e) {
      print('⚠️ TOKEN MANAGER: Background refresh failed: $e');
      // Fail silently bei Background-Refresh
    }
  }

  void dispose() {
    _httpClient.close();
  }
}