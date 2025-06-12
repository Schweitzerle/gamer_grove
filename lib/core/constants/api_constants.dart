class ApiConstants {
  // IGDB API
  static const String igdbBaseUrl = 'https://api.igdb.com/v4';
  static const String igdbClientId = 'YOUR_CLIENT_ID'; // Später aus env laden
  static const String igdbClientSecret = 'YOUR_CLIENT_SECRET';

  // Supabase
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';

  // API Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 50;
}

class IGDBEndpoints {
  static const String games = '/games';
  static const String genres = '/genres';
  static const String platforms = '/platforms';
  static const String companies = '/companies';
  static const String gameModes = '/game_modes';
  static const String themes = '/themes';
  static const String multiquery = '/multiquery';
}

class SupabaseTables {
  static const String users = 'users';
  static const String userGames = 'user_games';
  static const String userRatings = 'user_ratings';
  static const String userFollows = 'user_follows';
  static const String gameRecommendations = 'game_recommendations';
}