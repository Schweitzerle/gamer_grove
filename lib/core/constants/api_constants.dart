class ApiConstants {
  // IGDB API
  static const String igdbBaseUrl = 'https://api.igdb.com/v4';
  static const String igdbClientId = 'lbesf37nfwly4czho4wp8vqbzhexu8';
  static const String igdbClientSecret = 's6xa3psvwt8sroq2ox8k5r7972a1ka';

  // Supabase
  static const String supabaseUrl = 'https://jmvhqefqjuljrbxlhanf.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImptdmhxZWZxanVsanJieGxoYW5mIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDk2NzIxNjYsImV4cCI6MjA2NTI0ODE2Nn0.Y552iva57JPH4sPKW7lGr5Mdof0KBq5TXgCceP6fSco';

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