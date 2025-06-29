// lib/core/constants/storage_constants.dart
class StorageConstants {
  // ==========================================
  // USER CACHING KEYS
  // ==========================================
  static const String userKey = 'user_cache';

  // User-specific data (separated for better performance)
  static const String userWishlistKey = 'user_wishlist';
  static const String userRatingsKey = 'user_ratings';
  static const String userTopThreeKey = 'user_top_three';
  static const String userRecommendationsKey = 'user_recommendations';
  static const String userFollowingKey = 'user_following';
  static const String userFollowersKey = 'user_followers';

  // ==========================================
  // GAME CACHING KEYS
  // ==========================================

  // Basic Game Caching
  static const String searchResultsKey = 'search_results';
  static const String gameDetailsKey = 'game_details';
  static const String popularGamesKey = 'popular_games';
  static const String upcomingGamesKey = 'upcoming_games';

  // Complete Game Details
  static const String completeGameDetailsKey = 'complete_game_details';

  // Game Relations
  static const String similarGamesKey = 'similar_games';
  static const String gameDLCsKey = 'game_dlcs';
  static const String gameExpansionsKey = 'game_expansions';
  static const String gameStandaloneExpansionsKey = 'game_standalone_expansions';
  static const String gameBundlesKey = 'game_bundles';
  static const String gameExpandedGamesKey = 'game_expanded_games';
  static const String gameForksKey = 'game_forks';
  static const String gamePortsKey = 'game_ports';
  static const String gameRemakesKey = 'game_remakes';
  static const String gameRemastersKey = 'game_remasters';

  // ==========================================
  // GAME COMPONENTS CACHING KEYS
  // ==========================================

  // Companies
  static const String gameCompaniesKey = 'game_companies';
  static const String companyKey = 'company_cache';

  // Websites
  static const String gameWebsitesKey = 'game_websites';
  static const String websiteKey = 'website_cache';

  // Videos
  static const String gameVideosKey = 'game_videos';
  static const String videoKey = 'video_cache';

  // Characters
  static const String gameCharactersKey = 'game_characters';
  static const String characterKey = 'character_cache';

  // Age Ratings
  static const String gameAgeRatingsKey = 'game_age_ratings';
  static const String ageRatingKey = 'age_rating_cache';

  // External Games
  static const String gameExternalGamesKey = 'game_external_games';
  static const String externalGameKey = 'external_game_cache';

  // Game Engines
  static const String gameEnginesKey = 'game_engines';
  static const String gameEngineKey = 'game_engine_cache';

  // Multiplayer Modes
  static const String gameMultiplayerModesKey = 'game_multiplayer_modes';
  static const String multiplayerModeKey = 'multiplayer_mode_cache';

  // Language Support
  static const String gameLanguageSupportsKey = 'game_language_supports';
  static const String languageSupportKey = 'language_support_cache';

  // Game Localizations
  static const String gameLocalizationsKey = 'game_localizations';
  static const String gameLocalizationKey = 'game_localization_cache';

  // Release Dates
  static const String gameReleaseDatesKey = 'game_release_dates';
  static const String releaseDateKey = 'release_date_cache';

  // ==========================================
  // COLLECTIONS & FRANCHISES CACHING KEYS
  // ==========================================
  static const String collectionKey = 'collection_cache';
  static const String gameCollectionsKey = 'game_collections';
  static const String franchiseKey = 'franchise_cache';
  static const String gameFranchisesKey = 'game_franchises';
  static const String mainFranchiseKey = 'main_franchise_cache';

  // ==========================================
  // METADATA CACHING KEYS
  // ==========================================

  // Core Metadata
  static const String genresKey = 'genres_cache';
  static const String platformsKey = 'platforms_cache';
  static const String gameModesKey = 'game_modes_cache';
  static const String themesKey = 'themes_cache';
  static const String keywordsKey = 'keywords_cache';
  static const String playerPerspectivesKey = 'player_perspectives_cache';

  // Game-specific metadata
  static const String gameGenresKey = 'game_genres';
  static const String gamePlatformsKey = 'game_platforms';
  static const String gameModesForGameKey = 'game_modes_for_game';
  static const String gameThemesKey = 'game_themes';
  static const String gameKeywordsKey = 'game_keywords';
  static const String gamePlayerPerspectivesKey = 'game_player_perspectives';

  // ==========================================
  // SEARCH & FILTERING CACHING KEYS
  // ==========================================
  static const String searchFiltersKey = 'search_filters';
  static const String popularSearchesKey = 'popular_searches';
  static const String recentSearchesKey = 'recent_searches';
  static const String searchSuggestionsKey = 'search_suggestions';

  // Platform-specific searches
  static const String platformGamesKey = 'platform_games';
  static const String genreGamesKey = 'genre_games';
  static const String themeGamesKey = 'theme_games';

  // ==========================================
  // SOCIAL FEATURES CACHING KEYS
  // ==========================================

  // Reviews & Ratings
  static const String gameReviewsKey = 'game_reviews';
  static const String userReviewsKey = 'user_reviews';
  static const String reviewKey = 'review_cache';

  // Community Lists
  static const String popularReviewsKey = 'popular_reviews';
  static const String recentReviewsKey = 'recent_reviews';
  static const String topRatedGamesKey = 'top_rated_games';
  static const String trendingGamesKey = 'trending_games';

  // User Interactions
  static const String userInteractionsKey = 'user_interactions';
  static const String gameInteractionsKey = 'game_interactions';

  // ==========================================
  // ADVANCED GAME DATA CACHING KEYS
  // ==========================================

  // Screenshots & Media
  static const String gameScreenshotsKey = 'game_screenshots';
  static const String gameArtworksKey = 'game_artworks';
  static const String gameCoverKey = 'game_cover';

  // Alternative Names & Localization
  static const String gameAlternativeNamesKey = 'game_alternative_names';
  static const String alternativeNameKey = 'alternative_name_cache';

  // Game Status & Types
  static const String gameStatusKey = 'game_status_cache';
  static const String gameTypeKey = 'game_type_cache';

  // Game Versions
  static const String gameVersionsKey = 'game_versions';
  static const String gameVersionKey = 'game_version_cache';

  // ==========================================
  // SPECIAL COLLECTIONS CACHING KEYS
  // ==========================================

  // Curated Lists
  static const String curatedListsKey = 'curated_lists';
  static const String curatedListKey = 'curated_list_cache';
  static const String featuredGamesKey = 'featured_games';
  static const String editorPicksKey = 'editor_picks';

  // Time-based Collections
  static const String gamesByYearKey = 'games_by_year';
  static const String gamesByDecadeKey = 'games_by_decade';
  static const String recentReleasesKey = 'recent_releases';

  // Achievement & Progress
  static const String userAchievementsKey = 'user_achievements';
  static const String gameProgressKey = 'game_progress';
  static const String playTimeKey = 'play_time';

  // ==========================================
  // CACHE METADATA KEYS
  // ==========================================
  static const String cacheVersionKey = 'cache_version';
  static const String lastCacheCleanupKey = 'last_cache_cleanup';
  static const String cacheSizeKey = 'cache_size';
  static const String cacheStatsKey = 'cache_stats';

  // ==========================================
  // UTILITY METHODS
  // ==========================================

  /// Get cache key for user-specific data
  static String getUserSpecificKey(String baseKey, String userId) {
    return '${baseKey}_$userId';
  }

  /// Get cache key for game-specific data
  static String getGameSpecificKey(String baseKey, int gameId) {
    return '${baseKey}_$gameId';
  }

  /// Get cache key for platform-specific data
  static String getPlatformSpecificKey(String baseKey, int platformId) {
    return '${baseKey}_platform_$platformId';
  }

  /// Get cache key for genre-specific data
  static String getGenreSpecificKey(String baseKey, int genreId) {
    return '${baseKey}_genre_$genreId';
  }

  /// Get cache key for company-specific data
  static String getCompanySpecificKey(String baseKey, int companyId) {
    return '${baseKey}_company_$companyId';
  }

  /// Get cache key for collection-specific data
  static String getCollectionSpecificKey(String baseKey, int collectionId) {
    return '${baseKey}_collection_$collectionId';
  }

  /// Get cache key for franchise-specific data
  static String getFranchiseSpecificKey(String baseKey, int franchiseId) {
    return '${baseKey}_franchise_$franchiseId';
  }

  /// Get cache key for search queries
  static String getSearchKey(String baseKey, String query) {
    return '${baseKey}_${query.toLowerCase().replaceAll(' ', '_')}';
  }

  /// Check if key is user-specific
  static bool isUserSpecificKey(String key) {
    return key.contains('user_') ||
        key.contains('wishlist') ||
        key.contains('rating') ||
        key.contains('following') ||
        key.contains('top_three');
  }

  /// Check if key is game-specific
  static bool isGameSpecificKey(String key) {
    return key.contains('game_') ||
        key.contains('similar_') ||
        key.contains('dlc_') ||
        key.contains('expansion_');
  }

  /// Check if key is metadata
  static bool isMetadataKey(String key) {
    return key.contains('genres') ||
        key.contains('platforms') ||
        key.contains('themes') ||
        key.contains('modes');
  }

  /// Get all cache prefixes for cleanup operations
  static List<String> getAllCachePrefixes() {
    return [
      userKey,
      searchResultsKey,
      gameDetailsKey,
      popularGamesKey,
      completeGameDetailsKey,
      characterKey,
      companyKey,
      websiteKey,
      videoKey,
      collectionKey,
      franchiseKey,
      genresKey,
      platformsKey,
      gameModesKey,
      themesKey,
      keywordsKey,
      playerPerspectivesKey,
      userWishlistKey,
      userRatingsKey,
      userTopThreeKey,
      userRecommendationsKey,
      userFollowingKey,
      userFollowersKey,
    ];
  }

  /// Get all user-specific cache prefixes
  static List<String> getUserCachePrefixes() {
    return [
      userKey,
      userWishlistKey,
      userRatingsKey,
      userTopThreeKey,
      userRecommendationsKey,
      userFollowingKey,
      userFollowersKey,
      userInteractionsKey,
      userReviewsKey,
      userAchievementsKey,
    ];
  }

  /// Get all game-specific cache prefixes
  static List<String> getGameCachePrefixes() {
    return [
      gameDetailsKey,
      completeGameDetailsKey,
      searchResultsKey,
      popularGamesKey,
      upcomingGamesKey,
      similarGamesKey,
      gameDLCsKey,
      gameExpansionsKey,
      gameCompaniesKey,
      gameWebsitesKey,
      gameVideosKey,
      gameCharactersKey,
    ];
  }

  /// Get all metadata cache prefixes
  static List<String> getMetadataCachePrefixes() {
    return [
      genresKey,
      platformsKey,
      gameModesKey,
      themesKey,
      keywordsKey,
      playerPerspectivesKey,
      gameStatusKey,
      gameTypeKey,
    ];
  }
}