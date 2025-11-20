import 'package:gamer_grove/core/env/env.dart';

class ApiConstants {
  // IGDB API
  static const String igdbBaseUrl = 'https://api.igdb.com/v4';
  static final String igdbClientId = Env.igdbClientId;
  static final String igdbClientSecret = Env.igdbClientSecret;

  // Supabase
  static final String supabaseUrl = Env.supabaseUrl;
  static final String supabaseAnonKey = Env.supabaseAnonKey;

  // API Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 50;
}

class IGDBEndpoints {
  static const String ageRatings = 'age_ratings';
  static const String ageRatingCategories = 'age_rating_categories';
  static const String ageRatingContentDescriptions =
      'age_rating_content_descriptions';
  static const String ageRatingOrganizations = 'age_rating_organizations';
  static const String alternativeNames = 'alternative_names';
  static const String artworks = 'artworks';
  static const String artworkTypes = 'artwork_types';
  static const String characters = 'characters';
  static const String characterMugShots = 'character_mug_shots';
  static const String characterSpecies = 'character_species';
  static const String collections = 'collections';
  static const String collectionTypes = 'collection_types';
  static const String companies = 'companies';
  static const String companyLogos = 'company_logos';
  static const String covers = 'covers';
  static const String externalGames = 'external_games';
  static const String franchises = 'franchises';
  static const String games = 'games';
  static const String gameEngines = 'game_engines';
  static const String gameEngineLogos = 'game_engine_logos';
  static const String gameModes = 'game_modes';
  static const String gameVideos = 'game_videos';
  static const String genres = 'genres';
  static const String involvedCompanies = 'involved_companies';
  static const String keywords = 'keywords';
  static const String languages = 'languages';
  static const String languageSupports = 'language_supports';
  static const String languageSupportTypes = 'language_support_types';
  static const String multiplayerModes = 'multiplayer_modes';
  static const String platforms = 'platforms';
  static const String platformFamilies = 'platform_families';
  static const String platformLogos = 'platform_logos';
  static const String platformTypes = 'platform_types';
  static const String platformVersions = 'platform_versions';
  static const String playerPerspectives = 'player_perspectives';
  static const String regions = 'regions';
  static const String releaseDates = 'release_dates';
  static const String screenshots = 'screenshots';
  static const String themes = 'themes';
  static const String websites = 'websites';
  static const String websiteTypes = 'website_types';
}

class SupabaseTables {
  static const String profiles = 'profiles';
  static const String userGames = 'user_games';
  static const String gameRatings = 'game_ratings';
  static const String userFollows = 'user_follows';
  static const String userTopGames = 'user_top_games';
}
