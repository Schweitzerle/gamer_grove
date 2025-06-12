// core/constants/storage_constants.dart
class StorageConstants {
  // Cache Keys
  static const String userKey = 'cached_user';
  static const String searchResultsKey = 'search_results';
  static const String gameDetailsKey = 'game_details';
  static const String popularGamesKey = 'popular_games';

  // Auth Keys
  static const String authTokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userSessionKey = 'user_session';

  // Settings Keys
  static const String themeKey = 'app_theme';
  static const String languageKey = 'app_language';
  static const String onboardingCompleteKey = 'onboarding_complete';

  // Cache Durations (in hours)
  static const int userCacheDuration = 24;
  static const int gamesCacheDuration = 1;
  static const int searchCacheDuration = 1;
}