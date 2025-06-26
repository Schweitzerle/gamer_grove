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
  static const String games = 'games';
  static const String companies = 'companies';
  static const String involvedCompanies = 'involved_companies';
  static const String websites = 'websites';
  static const String videos = 'game_videos';
  static const String ageRatings = 'age_ratings';
  static const String gameEngines = 'game_engines';
  static const String keywords = 'keywords';
  static const String multiplayerModes = 'multiplayer_modes';
  static const String playerPerspectives = 'player_perspectives';
  static const String franchises = 'franchises';
  static const String collections = 'collections';
  static const String externalGames = 'external_games';
  static const String languageSupports = 'language_supports';
  static const String alternativeNames = 'alternative_names';
  static const String characters = 'characters';
  static const String events = 'events';
  static const String platforms = 'platforms';
  static const String genres = 'genres';
  static const String themes = 'themes';
  static const String gameModes = 'game_modes';
  static const String covers = 'covers';
  static const String screenshots = 'screenshots';
  static const String artworks = 'artworks';
  static const String releaseDates = 'release_dates';
}

class SupabaseTables {
  static const String profiles = 'profiles';
  static const String userGames = 'user_games';
  static const String gameRatings = 'game_ratings';
  static const String userFollows = 'user_follows';
  static const String userTopGames = 'user_top_games';
}