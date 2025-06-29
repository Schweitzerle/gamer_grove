// data/datasources/remote/igdb_remote_datasource.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../domain/entities/character/character.dart';
import '../../../../domain/entities/company/company_website.dart';
import '../../../../domain/entities/externalGame/external_game.dart';
import '../../../../domain/entities/game/game.dart';
import '../../../../domain/entities/platform/platform.dart';
import '../../../../domain/entities/popularity/popularity_primitive.dart';
import '../../../../domain/entities/search/search.dart';
import '../../../models/ageRating/age_rating_category_model.dart';
import '../../../models/ageRating/age_rating_model.dart';
import '../../../models/ageRating/age_rating_organization.dart';
import '../../../models/alternative_name_model.dart';
import '../../../models/character/character_gender_model.dart';
import '../../../models/character/character_model.dart';
import '../../../models/character/character_mug_shot_model.dart';
import '../../../models/character/character_species_model.dart';
import '../../../models/collection/collection_membership_model.dart';
import '../../../models/collection/collection_relation_model.dart';
import '../../../models/collection/collection_type_model.dart';
import '../../../models/collection_model.dart';
import '../../../models/company/company_model.dart';
import '../../../models/company/company_model_logo.dart';
import '../../../models/company/company_status_model.dart';
import '../../../models/company/company_website_model.dart';
import '../../../models/date/date_format_model.dart';
import '../../../models/event/event_logo_model.dart';
import '../../../models/event/event_model.dart';
import '../../../models/event/event_network_model.dart';
import '../../../models/event/network_type_model.dart';
import '../../../models/externalGame/external_game_model.dart';
import '../../../models/externalGame/external_game_source_model.dart';
import '../../../models/franchise_model.dart';
import '../../../models/game/game_engine_logo_model.dart';
import '../../../models/game/game_engine_model.dart';
import '../../../models/game/game_mode_model.dart';
import '../../../models/game/game_model.dart';
import '../../../models/game/game_release_format_model.dart';
import '../../../models/game/game_status_model.dart';
import '../../../models/game/game_time_to_beat_model.dart';
import '../../../models/game/game_type_model.dart';
import '../../../models/game/game_version_feature_model.dart';
import '../../../models/game/game_version_feature_value_model.dart';
import '../../../models/game/game_version_model.dart';
import '../../../models/game/game_video_model.dart';
import '../../../models/genre_model.dart';
import '../../../models/keyword_model.dart';
import '../../../models/language/language_support_type_model.dart';
import '../../../models/language/lanuage_model.dart';
import '../../../models/language_support_model.dart';
import '../../../models/multiplayer_mode_model.dart';
import '../../../models/platform/paltform_type_model.dart';
import '../../../models/platform/platform_family_model.dart';
import '../../../models/platform/platform_logo_model.dart';
import '../../../models/platform/platform_model.dart';
import '../../../models/platform/platform_version_company_model.dart';
import '../../../models/platform/platform_version_model.dart';
import '../../../models/platform/platform_version_release_date_model.dart';
import '../../../models/platform/platform_website_model.dart';
import '../../../models/player_perspective_model.dart';
import '../../../models/popularity/popularity_primitive_model.dart';
import '../../../models/popularity/popularity_type_model.dart';
import '../../../models/region_model.dart';
import '../../../models/release_date/release_date_model.dart';
import '../../../models/release_date/release_date_region_model.dart';
import '../../../models/release_date/release_date_status_model.dart';
import '../../../models/search/search_model.dart';
import '../../../models/theme_model.dart';
import '../../../models/website/website_model.dart';
import '../../../models/website/website_type_model.dart';

// lib/data/datasources/remote/igdb_remote_datasource.dart - Interface Update
// Diese Methoden gehören in das IGDBRemoteDataSource abstract interface

abstract class IGDBRemoteDataSource {
  // EXISTING METHODS...
  Future<List<GameModel>> searchGames(String query, int limit, int offset);
  Future<GameModel> getGameDetails(int gameId);
  Future<List<GameModel>> getPopularGames(int limit, int offset);
  Future<List<GameModel>> getUpcomingGames(int limit, int offset);
  Future<List<GameModel>> getGamesByIds(List<int> gameIds);

  // EXISTING API METHODS...
  Future<List<WebsiteModel>> getWebsites(List<int> gameIds);
  Future<List<GameVideoModel>> getGameVideos(List<int> gameIds);
  Future<List<GameEngineModel>> getGameEngines({List<int>? ids, String? search});
  Future<List<MultiplayerModeModel>> getMultiplayerModes(List<int> gameIds);
  Future<List<PlayerPerspectiveModel>> getPlayerPerspectives({List<int>? ids});
  Future<List<LanguageSupportModel>> getLanguageSupports(List<int> gameIds);
  // ALTERNATIVE NAMES METHODS
  Future<List<String>> getAlternativeNames(List<int> gameIds);
  Future<List<AlternativeNameModel>> getAlternativeNamesDetailed(List<int> gameIds);
  Future<List<GameModel>> searchGamesByAlternativeNames(String query);

  // PLATFORM METHODS
  Future<List<PlatformModel>> getPlatforms({
    List<int>? ids,
    String? search,
    PlatformCategoryEnum? category,
    bool includeFamilyInfo = false,
  });
  Future<List<PlatformModel>> getPlatformsByCategory(PlatformCategoryEnum category);
  Future<List<PlatformModel>> getPopularPlatforms();
  Future<List<PlatformFamilyModel>> getPlatformFamilies({List<int>? ids});
  Future<List<PlatformTypeModel>> getPlatformTypes({List<int>? ids});
  Future<List<PlatformLogoModel>> getPlatformLogos(List<int> logoIds);
  Future<List<Map<String, dynamic>>> getCompletePlatformData({
    List<int>? platformIds,
    PlatformCategoryEnum? category,
  });

  // GENRE METHODS
  Future<List<GenreModel>> getGenres({
    List<int>? ids,
    String? search,
    int limit = 100,
  });
  Future<List<GenreModel>> getPopularGenres();
  Future<List<GenreModel>> getTopGenres();
  Future<List<GenreModel>> searchGenres(String query);
  Future<List<GenreModel>> getAllGenres();
  Future<List<Map<String, dynamic>>> getGenresWithGameCount({
    List<int>? genreIds,
    int limit = 50,
  });
  Future<GenreModel?> getGenreByName(String name);

  // THEME METHODS
  Future<List<ThemeModel>> getThemes({
    List<int>? ids,
    String? search,
    int limit = 100,
  });
  Future<List<ThemeModel>> getPopularThemes();
  Future<List<ThemeModel>> searchThemes(String query);
  Future<List<ThemeModel>> getAllThemes();
  Future<ThemeModel?> getThemeByName(String name);

  // GAME MODE METHODS
  Future<List<GameModeModel>> getGameModes({
    List<int>? ids,
    String? search,
    int limit = 50,
  });
  Future<List<GameModeModel>> getPopularGameModes();
  Future<List<GameModeModel>> searchGameModes(String query);
  Future<List<GameModeModel>> getAllGameModes();
  Future<GameModeModel?> getGameModeByName(String name);

  // KEYWORD METHODS
  Future<List<KeywordModel>> getKeywords({
    List<int>? ids,
    String? search,
    int limit = 100,
  });
  Future<List<KeywordModel>> searchKeywords(String query);
  Future<List<KeywordModel>> getTrendingKeywords();
  Future<List<KeywordModel>> getKeywordsForGames(List<int> gameIds);
  Future<List<KeywordModel>> getSimilarKeywords(String keywordName);
  Future<List<KeywordModel>> getKeywordsByCategory(String category);
  Future<KeywordModel?> getKeywordByName(String name);
  Future<List<KeywordModel>> getRandomKeywords({int limit = 20});
  Future<List<GameModel>> searchGamesByKeywords(List<String> keywordNames);

  // CHARACTER METHODS
  Future<List<CharacterModel>> getCharacters({
    List<int>? ids,
    String? search,
    int limit = 50,
  });
  Future<List<CharacterModel>> searchCharacters(String query);
  Future<List<CharacterModel>> getCharactersForGames(List<int> gameIds);
  Future<List<CharacterModel>> getPopularCharacters({int limit = 20});
  Future<List<CharacterModel>> getCharactersByGender(CharacterGenderEnum gender);
  Future<List<CharacterModel>> getCharactersBySpecies(CharacterSpeciesEnum species);
  Future<List<CharacterGenderModel>> getCharacterGenders({List<int>? ids});
  Future<List<CharacterSpeciesModel>> getCharacterSpecies({List<int>? ids});
  Future<List<CharacterMugShotModel>> getCharacterMugShots(List<int> mugShotIds);
  Future<List<Map<String, dynamic>>> getCompleteCharacterData({
    List<int>? characterIds,
    String? search,
    int limit = 20,
  });
  Future<CharacterModel?> getCharacterByName(String name);
  Future<List<CharacterModel>> getRandomCharacters({int limit = 10});

  // EXTERNAL GAME METHODS
  Future<List<ExternalGameModel>> getExternalGames(List<int> gameIds);
  Future<List<ExternalGameModel>> getExternalGamesByStore(
      ExternalGameCategoryEnum store, {
        int limit = 100,
      });
  Future<Map<int, List<ExternalGameModel>>> getStoreLinksForGames(
      List<int> gameIds, {
        List<ExternalGameCategoryEnum>? preferredStores,
      });
  Future<List<ExternalGameModel>> getMainStoreLinks(List<int> gameIds);
  Future<List<ExternalGameModel>> getSteamLinks(List<int> gameIds);
  Future<Map<String, List<ExternalGameModel>>> getExternalGamesByMedia(List<int> gameIds);
  Future<List<ExternalGameSourceModel>> getExternalGameSources({List<int>? ids});
  Future<List<GameReleaseFormatModel>> getGameReleaseFormats({List<int>? ids});
  Future<List<Map<String, dynamic>>> getCompleteExternalGameData(List<int> gameIds);
  Future<ExternalGameModel?> getBestStoreLink(
      int gameId, {
        List<ExternalGameCategoryEnum>? preferredStores,
      });
  Future<List<ExternalGameModel>> searchExternalGamesByUid(String uid);
  Future<List<Map<String, dynamic>>> getPopularStores();

  // COLLECTION METHODS
  Future<List<CollectionModel>> getCollections({
    List<int>? ids,
    String? search,
    int limit = 100,
  });
  Future<List<CollectionModel>> searchCollections(String query);
  Future<List<CollectionModel>> getCollectionsForGames(List<int> gameIds);
  Future<List<CollectionModel>> getPopularCollections({int limit = 20});
  Future<List<CollectionModel>> getCollectionsByType(int typeId);
  Future<List<CollectionModel>> getParentCollections({int limit = 50});
  Future<List<CollectionModel>> getChildCollections(int parentCollectionId);
  Future<List<CollectionTypeModel>> getCollectionTypes({List<int>? ids});
  Future<List<CollectionMembershipModel>> getCollectionMemberships({
    int? collectionId,
    int? gameId,
    List<int>? ids,
  });
  Future<List<CollectionRelationModel>> getCollectionRelations({
    int? parentCollectionId,
    int? childCollectionId,
    List<int>? ids,
  });
  Future<Map<String, dynamic>> getCollectionHierarchy(int collectionId);
  Future<List<Map<String, dynamic>>> getCompleteCollectionData({
    List<int>? collectionIds,
    String? search,
    int limit = 20,
  });
  Future<List<Map<String, dynamic>>> getFamousGameSeries({int limit = 20});
  Future<CollectionModel?> getCollectionByName(String name);
  Future<Map<String, dynamic>> getCollectionStatistics();

  // FRANCHISE METHODS
  Future<List<FranchiseModel>> getFranchises({
    List<int>? ids,
    String? search,
    int limit = 100,
  });
  Future<List<FranchiseModel>> searchFranchises(String query);
  Future<List<FranchiseModel>> getFranchisesForGames(List<int> gameIds);
  Future<List<FranchiseModel>> getPopularFranchises({int limit = 20});
  Future<List<FranchiseModel>> getMajorFranchises({int limit = 20});
  Future<List<FranchiseModel>> getTrendingFranchises();
  Future<List<Map<String, dynamic>>> getFranchisesWithGames({
    List<int>? franchiseIds,
    String? search,
    int limit = 20,
    int maxGamesPerFranchise = 10,
  });
  Future<Map<String, dynamic>> getFranchiseStatistics();
  Future<List<FranchiseModel>> getRandomFranchises({int limit = 10});
  Future<FranchiseModel?> getFranchiseByName(String name);
  Future<Map<String, dynamic>> getFranchiseTimeline(int franchiseId);
  Future<List<FranchiseModel>> getSimilarFranchises(int franchiseId, {int limit = 10});
  Future<List<GameModel>> getSimilarGames(int gameId);
  Future<List<GameModel>> getGameDLCs(int gameId);
  Future<List<GameModel>> getGameExpansions(int gameId);
  Future<GameModel> getCompleteGameDetails(int gameId);

  // NEW AGE RATING METHODS
  Future<List<AgeRatingModel>> getAgeRatings(List<int> gameIds);
  Future<List<AgeRatingOrganizationModel>> getAgeRatingOrganizations({List<int>? ids});
  Future<List<AgeRatingCategoryModel>> getAgeRatingCategories({
    List<int>? ids,
    int? organizationId,
  });
  Future<List<Map<String, dynamic>>> getCompleteAgeRatings(List<int> gameIds);
  // ===== NEW DATASOURCE METHODS FOR COMPANY =====
// Diese Methoden gehören in die IGDBRemoteDataSource abstract class

  // COMPANY METHODS
  Future<List<CompanyModel>> getCompanies({
    List<int>? ids,
    String? search,
    int limit = 50,
  });

  Future<CompanyModel?> getCompanyById(int id);

  Future<List<CompanyModel>> searchCompanies(String query, {int limit = 20});

  Future<List<CompanyModel>> getPopularCompanies({int limit = 50});

  Future<List<CompanyModel>> getCompaniesByDevelopedGames(List<int> gameIds);

  Future<List<CompanyModel>> getCompaniesByPublishedGames(List<int> gameIds);

  // COMPANY LOGO METHODS
  Future<List<CompanyLogoModel>> getCompanyLogos({
    List<int>? ids,
    int limit = 50,
  });

  Future<CompanyLogoModel?> getCompanyLogoById(int id);

  // COMPANY STATUS METHODS
  Future<List<CompanyStatusModel>> getCompanyStatuses({
    List<int>? ids,
    int limit = 50,
  });

  Future<CompanyStatusModel?> getCompanyStatusById(int id);

  // COMPANY WEBSITE METHODS
  Future<List<CompanyWebsiteModel>> getCompanyWebsites({
    List<int>? ids,
    int limit = 50,
  });

  Future<CompanyWebsiteModel?> getCompanyWebsiteById(int id);

  Future<List<CompanyWebsiteModel>> getCompanyWebsitesByCategory(
      CompanyWebsiteCategory category, {
        int limit = 50,
      });

  // COMPREHENSIVE COMPANY DATA
  Future<Map<String, dynamic>> getCompleteCompanyData(int companyId);

  Future<List<CompanyModel>> getCompanyHierarchy(int companyId);

  // ===== GAME ENGINE LOGO DATASOURCE METHODS =====
// Diese Methoden in die IGDBRemoteDataSource abstract class hinzufügen:

  // GAME ENGINE LOGO METHODS
  Future<List<GameEngineLogoModel>> getGameEngineLogos({
    List<int>? ids,
    int limit = 50,
  });

  Future<GameEngineLogoModel?> getGameEngineLogoById(int id);

  // ===== NEW DATASOURCE METHODS FOR EVENTS =====
// Diese Methoden gehören in die IGDBRemoteDataSource abstract class

  // EVENT METHODS
  Future<List<EventModel>> getEvents({
    List<int>? ids,
    String? search,
    int limit = 50,
  });

  Future<EventModel?> getEventById(int id);

  Future<List<EventModel>> searchEvents(String query, {int limit = 20});

  Future<List<EventModel>> getUpcomingEvents({int limit = 50});

  Future<List<EventModel>> getLiveEvents({int limit = 50});

  Future<List<EventModel>> getPastEvents({int limit = 50});

  Future<List<EventModel>> getEventsByDateRange({
    DateTime? startDate,
    DateTime? endDate,
    int limit = 50,
  });

  Future<List<EventModel>> getEventsByGames(List<int> gameIds);

  // EVENT LOGO METHODS
  Future<List<EventLogoModel>> getEventLogos({
    List<int>? ids,
    int limit = 50,
  });

  Future<EventLogoModel?> getEventLogoById(int id);

  Future<EventLogoModel?> getEventLogoByEventId(int eventId);

  // EVENT NETWORK METHODS
  Future<List<EventNetworkModel>> getEventNetworks({
    List<int>? ids,
    int limit = 50,
  });

  Future<EventNetworkModel?> getEventNetworkById(int id);

  Future<List<EventNetworkModel>> getEventNetworksByEventId(int eventId);

  Future<List<EventNetworkModel>> getEventNetworksByNetworkType(int networkTypeId);

  // NETWORK TYPE METHODS
  Future<List<NetworkTypeModel>> getNetworkTypes({
    List<int>? ids,
    String? search,
    int limit = 50,
  });

  Future<NetworkTypeModel?> getNetworkTypeById(int id);

  Future<List<NetworkTypeModel>> searchNetworkTypes(String query, {int limit = 20});

  // COMPREHENSIVE EVENT DATA
  Future<Map<String, dynamic>> getCompleteEventData(int eventId);

  Future<List<EventModel>> getEventsWithGamesAndNetworks({
    bool includeLogos = true,
    int limit = 50,
  });

  // ===== NEW DATASOURCE METHODS FOR RELEASE DATES =====
// Diese Methoden gehören in die IGDBRemoteDataSource abstract class

  // RELEASE DATE METHODS
  Future<List<ReleaseDateModel>> getReleaseDates({
    List<int>? ids,
    int limit = 50,
  });

  Future<ReleaseDateModel?> getReleaseDateById(int id);

  Future<List<ReleaseDateModel>> getReleaseDatesByGame(int gameId);

  Future<List<ReleaseDateModel>> getReleaseDatesByPlatform(int platformId);

  Future<List<ReleaseDateModel>> getReleaseDatesByRegion(int regionId);

  Future<List<ReleaseDateModel>> getReleaseDatesByStatus(int statusId);

  Future<List<ReleaseDateModel>> getReleaseDatesByDateRange({
    DateTime? startDate,
    DateTime? endDate,
    int limit = 50,
  });

  Future<List<ReleaseDateModel>> getUpcomingReleaseDates({int limit = 50});

  Future<List<ReleaseDateModel>> getRecentReleaseDates({int limit = 50});

  Future<List<ReleaseDateModel>> getTodaysReleaseDates();

  Future<List<ReleaseDateModel>> getThisWeeksReleaseDates();

  Future<List<ReleaseDateModel>> getThisMonthsReleaseDates();

  Future<List<ReleaseDateModel>> getReleaseDatesForYear(int year, {int limit = 100});

  Future<List<ReleaseDateModel>> getReleaseDatesForQuarter(int year, int quarter, {int limit = 50});

  // RELEASE DATE REGION METHODS
  Future<List<ReleaseDateRegionModel>> getReleaseDateRegions({
    List<int>? ids,
    String? search,
    int limit = 50,
  });

  Future<ReleaseDateRegionModel?> getReleaseDateRegionById(int id);

  Future<List<ReleaseDateRegionModel>> searchReleaseDateRegions(String query, {int limit = 20});

  // RELEASE DATE STATUS METHODS
  Future<List<ReleaseDateStatusModel>> getReleaseDateStatuses({
    List<int>? ids,
    String? search,
    int limit = 50,
  });

  Future<ReleaseDateStatusModel?> getReleaseDateStatusById(int id);

  Future<List<ReleaseDateStatusModel>> searchReleaseDateStatuses(String query, {int limit = 20});

  // COMPREHENSIVE RELEASE DATE DATA
  Future<Map<String, dynamic>> getCompleteReleaseDateData(int releaseDateId);

  Future<List<ReleaseDateModel>> getReleaseDatesWithRegionsAndStatuses({
    int limit = 50,
  });

  // GAME-SPECIFIC RELEASE DATE METHODS
  Future<List<ReleaseDateModel>> getGameReleaseDatesWithDetails(int gameId);

  Future<ReleaseDateModel?> getEarliestReleaseDate(int gameId);

  Future<ReleaseDateModel?> getLatestReleaseDate(int gameId);

  Future<Map<String, List<ReleaseDateModel>>> getGameReleaseDatesByRegion(int gameId);

  // ===== NEW DATASOURCE METHODS FOR SEARCH & POPULARITY =====
// Diese Methoden gehören in die IGDBRemoteDataSource abstract class

  // SEARCH METHODS
  Future<List<SearchModel>> search({
    required String query,
    SearchResultType? resultType,
    int limit = 50,
  });

  Future<List<SearchModel>> searchGlobal(String query, {int limit = 50});

  Future<List<SearchModel>> searchGames(String query, {int limit = 20});

  Future<List<SearchModel>> searchCompanies(String query, {int limit = 20});

  Future<List<SearchModel>> searchPlatforms(String query, {int limit = 20});

  Future<List<SearchModel>> searchCharacters(String query, {int limit = 20});

  Future<List<SearchModel>> searchCollections(String query, {int limit = 20});

  Future<List<SearchModel>> searchThemes(String query, {int limit = 20});

  Future<List<SearchModel>> getSearchSuggestions(String partialQuery, {int limit = 10});

  Future<List<SearchModel>> getTrendingSearches({int limit = 20});

  Future<List<SearchModel>> getPopularSearches({int limit = 20});

  // POPULARITY PRIMITIVE METHODS
  Future<List<PopularityPrimitiveModel>> getPopularityPrimitives({
    List<int>? ids,
    int? gameId,
    int? popularityTypeId,
    PopularitySourceEnum? source,
    int limit = 50,
  });

  Future<PopularityPrimitiveModel?> getPopularityPrimitiveById(int id);

  Future<List<PopularityPrimitiveModel>> getGamePopularityMetrics(int gameId);

  Future<List<PopularityPrimitiveModel>> getPopularityByType(int popularityTypeId);

  Future<List<PopularityPrimitiveModel>> getPopularityBySource(PopularitySourceEnum source);

  Future<List<PopularityPrimitiveModel>> getTopPopularGames({
    int limit = 50,
    PopularitySourceEnum? source,
    int? popularityTypeId,
  });

  Future<List<PopularityPrimitiveModel>> getTrendingGames({
    int limit = 20,
    Duration? timeWindow,
  });

  Future<List<PopularityPrimitiveModel>> getRecentPopularityUpdates({
    int limit = 50,
    Duration? timeWindow,
  });

  // POPULARITY TYPE METHODS
  Future<List<PopularityTypeModel>> getPopularityTypes({
    List<int>? ids,
    String? search,
    PopularitySourceEnum? source,
    int limit = 50,
  });

  Future<PopularityTypeModel?> getPopularityTypeById(int id);

  Future<List<PopularityTypeModel>> searchPopularityTypes(String query, {int limit = 20});

  Future<List<PopularityTypeModel>> getPopularityTypesBySource(PopularitySourceEnum source);

  // COMPREHENSIVE SEARCH & POPULARITY DATA
  Future<Map<String, dynamic>> getCompleteSearchResults(String query, {int limit = 50});

  Future<Map<String, dynamic>> getGamePopularityAnalysis(int gameId);

  Future<Map<String, dynamic>> getPopularityTrends({
    int? gameId,
    Duration? timeWindow,
    PopularitySourceEnum? source,
  });

  // ADVANCED SEARCH METHODS
  Future<List<SearchModel>> searchWithFilters({
    required String query,
    SearchResultType? resultType,
    DateTime? publishedAfter,
    DateTime? publishedBefore,
    int limit = 50,
  });

  Future<List<SearchModel>> autocompleteSearch(String partialQuery, {int limit = 10});

  Future<List<String>> getSearchHistory();

  Future<void> saveSearchQuery(String query);

  // POPULARITY ANALYTICS
  Future<List<Map<String, dynamic>>> getPopularityLeaderboard({
    PopularitySourceEnum? source,
    int? popularityTypeId,
    int limit = 100,
  });

  Future<Map<String, dynamic>> getPopularityStatistics(int gameId);

  Future<List<PopularityPrimitiveModel>> getPopularityChanges({
    int? gameId,
    Duration? timeWindow,
    int limit = 50,
  });

  // SEARCH ANALYTICS
  Future<Map<String, dynamic>> getSearchAnalytics();

  Future<List<Map<String, dynamic>>> getSearchStatistics({
    DateTime? startDate,
    DateTime? endDate,
  });

  Future<List<DateFormatModel>> getDateFormats({List<int>? ids});
  Future<DateFormatModel?> getDateFormatById(int id);

  // Website Type Methods
  Future<List<WebsiteTypeModel>> getWebsiteTypes({List<int>? ids});
  Future<WebsiteTypeModel?> getWebsiteTypeById(int id);

  // Language Methods
  Future<List<LanguageModel>> getLanguages({List<int>? ids, String? search});
  Future<LanguageModel?> getLanguageById(int id);
  Future<List<LanguageModel>> getLanguagesByLocale(List<String> locales);

  // Language Support Type Methods
  Future<List<LanguageSupportTypeModel>> getLanguageSupportTypes({List<int>? ids});
  Future<LanguageSupportTypeModel?> getLanguageSupportTypeById(int id);

  // ===== REGION METHODS =====

  // Get all regions or filter by IDs
  Future<List<RegionModel>> getRegions({
  List<int>? ids,
  String? category, // 'locale' or 'continent'
  });

  // Get a specific region by ID
  Future<RegionModel?> getRegionById(int id);

  // Get regions by identifiers (e.g., ['US', 'GB', 'DE'])
  Future<List<RegionModel>> getRegionsByIdentifiers(List<String> identifiers);

  // Get all locale regions (countries)
  Future<List<RegionModel>> getLocaleRegions();

  // Get all continent regions
  Future<List<RegionModel>> getContinentRegions();

  // ===== PLATFORM VERSION METHODS =====

  // Get platform versions with optional filters
  Future<List<PlatformVersionModel>> getPlatformVersions({
  List<int>? ids,
  int? platformId,
  bool includeReleaseDates = false,
  });

  // Get a specific platform version by ID
  Future<PlatformVersionModel?> getPlatformVersionById(int id);

  // Get all versions for a specific platform
  Future<List<PlatformVersionModel>> getPlatformVersionsByPlatformId(int platformId);

  // Get platform versions with full details (including companies, release dates)
  Future<List<Map<String, dynamic>>> getPlatformVersionsWithDetails(List<int> versionIds);

  // ===== PLATFORM VERSION COMPANY METHODS =====

  // Get platform version companies
  Future<List<PlatformVersionCompanyModel>> getPlatformVersionCompanies({
  List<int>? ids,
  List<int>? versionIds,
  });

  // Get companies for specific platform versions
  Future<List<PlatformVersionCompanyModel>> getCompaniesByVersionIds(List<int> versionIds);

  // ===== PLATFORM VERSION RELEASE DATE METHODS =====

  // Get platform version release dates
  Future<List<PlatformVersionReleaseDateModel>> getPlatformVersionReleaseDates({
  List<int>? ids,
  List<int>? versionIds,
  int? regionId,
  });

  // Get release dates for specific platform versions
  Future<List<PlatformVersionReleaseDateModel>> getReleaseDatesByVersionIds(List<int> versionIds);

  // Get release dates for a specific region
  Future<List<PlatformVersionReleaseDateModel>> getReleaseDatesByRegion(int regionId);

  // ===== PLATFORM WEBSITE METHODS =====

  // Get platform websites
  Future<List<PlatformWebsiteModel>> getPlatformWebsites({
  List<int>? ids,
  List<int>? platformIds,
  });

  // Get websites for specific platforms
  Future<List<PlatformWebsiteModel>> getWebsitesByPlatformIds(List<int> platformIds);

  // Get platform websites by type
  Future<List<PlatformWebsiteModel>> getPlatformWebsitesByType(int typeId);

  // ===== HELPER METHODS =====

  // Get complete platform data with all related information
  Future<Map<String, dynamic>> getCompletePlatformDataWithVersions(int platformId);

  // Get platform version history with release dates
  Future<List<Map<String, dynamic>>> getPlatformVersionHistory(int platformId);

  // Search platforms by region
  Future<List<PlatformModel>> getPlatformsByRegion(int regionId);



  // ===== GAME STATUS METHODS =====

  Future<List<GameStatusModel>> getGameStatuses({List<int>? ids});
  Future<GameStatusModel?> getGameStatusById(int id);

  // ===== GAME TIME TO BEAT METHODS =====

  Future<List<GameTimeToBeatModel>> getGameTimesToBeat({
  List<int>? ids,
  List<int>? gameIds,
  });
  Future<GameTimeToBeatModel?> getGameTimeToBeatByGameId(int gameId);

  // ===== GAME TYPE METHODS =====

  Future<List<GameTypeModel>> getGameTypes({List<int>? ids});
  Future<GameTypeModel?> getGameTypeById(int id);

  // ===== GAME VERSION METHODS =====

  Future<List<GameVersionModel>> getGameVersions({
  List<int>? ids,
  int? mainGameId,
  });
  Future<GameVersionModel?> getGameVersionById(int id);
  Future<List<GameVersionModel>> getGameVersionsByMainGame(int gameId);

  // ===== GAME VERSION FEATURE METHODS =====

  Future<List<GameVersionFeatureModel>> getGameVersionFeatures({
  List<int>? ids,
  String? category,
  });
  Future<GameVersionFeatureModel?> getGameVersionFeatureById(int id);
  Future<List<GameVersionFeatureModel>> getGameVersionFeaturesByCategory(String category);

  // ===== GAME VERSION FEATURE VALUE METHODS =====

  Future<List<GameVersionFeatureValueModel>> getGameVersionFeatureValues({
  List<int>? ids,
  List<int>? gameIds,
  List<int>? featureIds,
  });
  Future<List<GameVersionFeatureValueModel>> getFeatureValuesByGame(int gameId);
  Future<List<GameVersionFeatureValueModel>> getFeatureValuesByFeature(int featureId);

  // ===== ENHANCED GAME METHODS =====

  // Get complete game details with all new fields
  Future<GameModel> getCompleteGameDetails(int gameId);

  // Get games with specific status
  Future<List<GameModel>> getGamesByStatus(int statusId, {int limit = 20, int offset = 0});

  // Get games by type/category
  Future<List<GameModel>> getGamesByType(int typeId, {int limit = 20, int offset = 0});

  // Get game with version features
  Future<Map<String, dynamic>> getGameWithVersionFeatures(int gameId);

  // Get games sorted by completion time
  Future<List<Map<String, dynamic>>> getGamesSortedByTimeToBeat({
  String sortBy = 'normally', // hastily, normally, completely
  int limit = 20,
  });

}

