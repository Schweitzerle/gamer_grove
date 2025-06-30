// lib/data/datasources/remote/igdb_remote_datasource.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';

// Domain Entities
import '../../../../domain/entities/character/character.dart';
import '../../../../domain/entities/company/company_website.dart';
import '../../../../domain/entities/externalGame/external_game.dart';
import '../../../../domain/entities/game/game.dart';
import '../../../../domain/entities/platform/platform.dart';
import '../../../../domain/entities/popularity/popularity_primitive.dart';
import '../../../../domain/entities/search/search.dart';

// Models - Age Rating
import '../../../../domain/entities/search/search_filters.dart';
import '../../../models/ageRating/age_rating_category_model.dart';
import '../../../models/ageRating/age_rating_model.dart';
import '../../../models/ageRating/age_rating_organization.dart';

// Models - Alternative Names
import '../../../models/alternative_name_model.dart';

// Models - Artwork & Visual
import '../../../models/artwork_model.dart';
import '../../../models/cover_model.dart';
import '../../../models/screenshot_model.dart';

// Models - Character
import '../../../models/character/character_gender_model.dart';
import '../../../models/character/character_model.dart';
import '../../../models/character/character_mug_shot_model.dart';
import '../../../models/character/character_species_model.dart';

// Models - Collection
import '../../../models/collection/collection_membership_model.dart';
import '../../../models/collection/collection_relation_model.dart';
import '../../../models/collection/collection_type_model.dart';
import '../../../models/collection_model.dart';

// Models - Company
import '../../../models/company/company_model.dart';
import '../../../models/company/company_model_logo.dart';
import '../../../models/company/company_status_model.dart';
import '../../../models/company/company_website_model.dart';

// Models - Date & Time
import '../../../models/date/date_format_model.dart';

// Models - Event
import '../../../models/event/event_logo_model.dart';
import '../../../models/event/event_model.dart';
import '../../../models/event/event_network_model.dart';
import '../../../models/event/network_type_model.dart';

// Models - External Game
import '../../../models/externalGame/external_game_model.dart';
import '../../../models/externalGame/external_game_source_model.dart';

// Models - Franchise
import '../../../models/franchise_model.dart';

// Models - Game
import '../../../models/game/game_engine_logo_model.dart';
import '../../../models/game/game_engine_model.dart';
import '../../../models/game/game_localization_model.dart';
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

// Models - Basic Types
import '../../../models/genre_model.dart';
import '../../../models/keyword_model.dart';
import '../../../models/theme_model.dart';

// Models - Language
import '../../../models/language/language_support_type_model.dart';
import '../../../models/language/lanuage_model.dart';
import '../../../models/language_support_model.dart';

// Models - Multiplayer & Perspectives
import '../../../models/multiplayer_mode_model.dart';
import '../../../models/player_perspective_model.dart';

// Models - Platform
import '../../../models/platform/paltform_type_model.dart';
import '../../../models/platform/platform_family_model.dart';
import '../../../models/platform/platform_logo_model.dart';
import '../../../models/platform/platform_model.dart';
import '../../../models/platform/platform_version_company_model.dart';
import '../../../models/platform/platform_version_model.dart';
import '../../../models/platform/platform_version_release_date_model.dart';
import '../../../models/platform/platform_website_model.dart';

// Models - Popularity & Search
import '../../../models/popularity/popularity_primitive_model.dart';
import '../../../models/popularity/popularity_type_model.dart';
import '../../../models/search/search_model.dart';

// Models - Region & Release
import '../../../models/region_model.dart';
import '../../../models/release_date/release_date_model.dart';
import '../../../models/release_date/release_date_region_model.dart';
import '../../../models/release_date/release_date_status_model.dart';

// Models - Website
import '../../../models/website/website_model.dart';
import '../../../models/website/website_type_model.dart';

// Models - Involved Company
import '../../../models/involved_company_model.dart';

/// Abstract interface for IGDB API remote data source
///
/// This interface defines all methods for interacting with the IGDB API.
/// It's organized by logical groups for better maintainability.
abstract class IGDBRemoteDataSource {

  // ==========================================
  // CORE GAME METHODS
  // ==========================================

  /// Search for games with pagination
  Future<List<GameModel>> searchGames(String query, int limit, int offset);

  /// Get detailed information for a specific game
  Future<GameModel> getGameDetails(int gameId);

  /// Get complete game details with all related data
  Future<GameModel> getCompleteGameDetails(int gameId);

  /// Get popular games with pagination
  Future<List<GameModel>> getPopularGames(int limit, int offset);

  /// Get upcoming games with pagination
  Future<List<GameModel>> getUpcomingGames(int limit, int offset);

  /// Get games by their IDs
  Future<List<GameModel>> getGamesByIds(List<int> gameIds);

  /// Get games by status
  Future<List<GameModel>> getGamesByStatus(int statusId, {int limit = 20, int offset = 0});

  /// Get games by type/category
  Future<List<GameModel>> getGamesByType(int typeId, {int limit = 20, int offset = 0});

  /// Get similar games for a given game
  Future<List<GameModel>> getSimilarGames(int gameId);

  /// Get DLCs for a game
  Future<List<GameModel>> getGameDLCs(int gameId);

  /// Get expansions for a game
  Future<List<GameModel>> getGameExpansions(int gameId);

  /// Get games sorted by completion time
  Future<List<Map<String, dynamic>>> getGamesSortedByTimeToBeat({
    String sortBy = 'normally', // hastily, normally, completely
    int limit = 20,
  });

  /// Get game with version features
  Future<Map<String, dynamic>> getGameWithVersionFeatures(int gameId);

  // ==========================================
  // VISUAL CONTENT METHODS (Artwork, Covers, Screenshots)
  // ==========================================

  /// Get artworks for games
  Future<List<ArtworkModel>> getArtworks({
    List<int>? ids,
    List<int>? gameIds,
    int limit = 50,
  });

  /// Get artwork by ID
  Future<ArtworkModel?> getArtworkById(int id);

  /// Get artworks for specific games
  Future<List<ArtworkModel>> getArtworksByGameIds(List<int> gameIds);

  /// Get covers for games
  Future<List<CoverModel>> getCovers({
    List<int>? ids,
    List<int>? gameIds,
    int limit = 50,
  });

  /// Get cover by ID
  Future<CoverModel?> getCoverById(int id);

  /// Get cover for a specific game
  Future<CoverModel?> getCoverByGameId(int gameId);

  /// Get screenshots for games
  Future<List<ScreenshotModel>> getScreenshots({
    List<int>? ids,
    List<int>? gameIds,
    int limit = 50,
  });

  /// Get screenshot by ID
  Future<ScreenshotModel?> getScreenshotById(int id);

  /// Get screenshots for specific games
  Future<List<ScreenshotModel>> getScreenshotsByGameIds(List<int> gameIds);

  // ==========================================
  // GAME METADATA METHODS
  // ==========================================

  /// Get game videos
  Future<List<GameVideoModel>> getGameVideos(List<int> gameIds);

  /// Get game engines
  Future<List<GameEngineModel>> getGameEngines({List<int>? ids, String? search});

  /// Get game engine logos
  Future<List<GameEngineLogoModel>> getGameEngineLogos({
    List<int>? ids,
    int limit = 50,
  });

  /// Get game engine logo by ID
  Future<GameEngineLogoModel?> getGameEngineLogoById(int id);

  /// Get multiplayer modes
  Future<List<MultiplayerModeModel>> getMultiplayerModes(List<int> gameIds);

  /// Get player perspectives
  Future<List<PlayerPerspectiveModel>> getPlayerPerspectives({List<int>? ids});

  /// Get language supports
  Future<List<LanguageSupportModel>> getLanguageSupports(List<int> gameIds);

  /// Get game localizations
  Future<List<GameLocalizationModel>> getGameLocalizations({
    List<int>? ids,
    List<int>? gameIds,
    int limit = 50,
  });

  /// Get game localization by ID
  Future<GameLocalizationModel?> getGameLocalizationById(int id);

  /// Get game localizations for specific games
  Future<List<GameLocalizationModel>> getGameLocalizationsByGameIds(List<int> gameIds);

  // ==========================================
  // GAME STATUS & TYPE METHODS
  // ==========================================

  /// Get game statuses
  Future<List<GameStatusModel>> getGameStatuses({List<int>? ids});

  /// Get game status by ID
  Future<GameStatusModel?> getGameStatusById(int id);

  /// Get game types
  Future<List<GameTypeModel>> getGameTypes({List<int>? ids});

  /// Get game type by ID
  Future<GameTypeModel?> getGameTypeById(int id);

  /// Get game time to beat data
  Future<List<GameTimeToBeatModel>> getGameTimesToBeat({
    List<int>? ids,
    List<int>? gameIds,
  });

  /// Get game time to beat by game ID
  Future<GameTimeToBeatModel?> getGameTimeToBeatByGameId(int gameId);

  // ==========================================
  // GAME VERSION METHODS
  // ==========================================

  /// Get game versions
  Future<List<GameVersionModel>> getGameVersions({
    List<int>? ids,
    int? mainGameId,
  });

  /// Get game version by ID
  Future<GameVersionModel?> getGameVersionById(int id);

  /// Get game versions by main game
  Future<List<GameVersionModel>> getGameVersionsByMainGame(int gameId);

  /// Get game version features
  Future<List<GameVersionFeatureModel>> getGameVersionFeatures({
    List<int>? ids,
    String? category,
  });

  /// Get game version feature by ID
  Future<GameVersionFeatureModel?> getGameVersionFeatureById(int id);

  /// Get game version features by category
  Future<List<GameVersionFeatureModel>> getGameVersionFeaturesByCategory(String category);

  /// Get game version feature values
  Future<List<GameVersionFeatureValueModel>> getGameVersionFeatureValues({
    List<int>? ids,
    List<int>? gameIds,
    List<int>? featureIds,
  });

  /// Get feature values by game
  Future<List<GameVersionFeatureValueModel>> getFeatureValuesByGame(int gameId);

  /// Get feature values by feature
  Future<List<GameVersionFeatureValueModel>> getFeatureValuesByFeature(int featureId);

  // ==========================================
  // ALTERNATIVE NAMES METHODS
  // ==========================================

  /// Get alternative names as strings
  Future<List<String>> getAlternativeNames(List<int> gameIds);

  /// Get detailed alternative names
  Future<List<AlternativeNameModel>> getAlternativeNamesDetailed(List<int> gameIds);

  /// Search games by alternative names
  Future<List<GameModel>> searchGamesByAlternativeNames(String query);

  // ==========================================
  // PLATFORM METHODS
  // ==========================================

  /// Get platforms with optional filters
  Future<List<PlatformModel>> getPlatforms({
    List<int>? ids,
    String? search,
    PlatformCategoryEnum? category,
    bool includeFamilyInfo = false,
  });

  /// Get platforms by category
  Future<List<PlatformModel>> getPlatformsByCategory(PlatformCategoryEnum category);

  /// Get popular platforms
  Future<List<PlatformModel>> getPopularPlatforms();

  /// Get platforms by region
  Future<List<PlatformModel>> getPlatformsByRegion(int regionId);

  /// Get platform families
  Future<List<PlatformFamilyModel>> getPlatformFamilies({List<int>? ids});

  /// Get platform types
  Future<List<PlatformTypeModel>> getPlatformTypes({List<int>? ids});

  /// Get platform logos
  Future<List<PlatformLogoModel>> getPlatformLogos(List<int> logoIds);

  /// Get complete platform data
  Future<List<Map<String, dynamic>>> getCompletePlatformData({
    List<int>? platformIds,
    PlatformCategoryEnum? category,
  });

  /// Get complete platform data with versions
  Future<Map<String, dynamic>> getCompletePlatformDataWithVersions(int platformId);

  // ==========================================
  // PLATFORM VERSION METHODS
  // ==========================================

  /// Get platform versions
  Future<List<PlatformVersionModel>> getPlatformVersions({
    List<int>? ids,
    int? platformId,
    bool includeReleaseDates = false,
  });

  /// Get platform version by ID
  Future<PlatformVersionModel?> getPlatformVersionById(int id);

  /// Get platform versions by platform ID
  Future<List<PlatformVersionModel>> getPlatformVersionsByPlatformId(int platformId);

  /// Get platform versions with details
  Future<List<Map<String, dynamic>>> getPlatformVersionsWithDetails(List<int> versionIds);

  /// Get platform version history
  Future<List<Map<String, dynamic>>> getPlatformVersionHistory(int platformId);

  /// Get platform version companies
  Future<List<PlatformVersionCompanyModel>> getPlatformVersionCompanies({
    List<int>? ids,
    List<int>? versionIds,
  });

  /// Get companies by version IDs
  Future<List<PlatformVersionCompanyModel>> getCompaniesByVersionIds(List<int> versionIds);

  /// Get platform version release dates
  Future<List<PlatformVersionReleaseDateModel>> getPlatformVersionReleaseDates({
    List<int>? ids,
    List<int>? versionIds,
    int? regionId,
  });

  /// Get release dates by version IDs
  Future<List<PlatformVersionReleaseDateModel>> getReleaseDatesByVersionIds(List<int> versionIds);

  /// Get platform websites
  Future<List<PlatformWebsiteModel>> getPlatformWebsites({
    List<int>? ids,
    List<int>? platformIds,
  });

  /// Get websites by platform IDs
  Future<List<PlatformWebsiteModel>> getWebsitesByPlatformIds(List<int> platformIds);

  /// Get platform websites by type
  Future<List<PlatformWebsiteModel>> getPlatformWebsitesByType(int typeId);

  // ==========================================
  // GENRE METHODS
  // ==========================================

  /// Get genres with optional filters
  Future<List<GenreModel>> getGenres({
    List<int>? ids,
    String? search,
    int limit = 100,
  });

  /// Get popular genres
  Future<List<GenreModel>> getPopularGenres();

  /// Get top genres
  Future<List<GenreModel>> getTopGenres();

  /// Search genres
  Future<List<GenreModel>> searchGenres(String query);


  /// Get genres with game count
  Future<List<Map<String, dynamic>>> getGenresWithGameCount({
    List<int>? genreIds,
    int limit = 50,
  });

  /// Get genre by name
  Future<GenreModel?> getGenreByName(String name);

  // ==========================================
  // THEME METHODS
  // ==========================================

  /// Get themes with optional filters
  Future<List<ThemeModel>> getThemes({
    List<int>? ids,
    String? search,
    int limit = 100,
  });

  /// Get popular themes
  Future<List<ThemeModel>> getPopularThemes();

  /// Search themes
  Future<List<ThemeModel>> searchThemes(String query);

  /// Get all themes
  Future<List<ThemeModel>> getAllThemes();

  /// Get theme by name
  Future<ThemeModel?> getThemeByName(String name);

  // ==========================================
  // GAME MODE METHODS
  // ==========================================

  /// Get game modes with optional filters
  Future<List<GameModeModel>> getGameModes({
    List<int>? ids,
    String? search,
    int limit = 50,
  });

  /// Get popular game modes
  Future<List<GameModeModel>> getPopularGameModes();

  /// Search game modes
  Future<List<GameModeModel>> searchGameModes(String query);

  /// Get all game modes
  Future<List<GameModeModel>> getAllGameModes();

  /// Get game mode by name
  Future<GameModeModel?> getGameModeByName(String name);

  // ==========================================
  // KEYWORD METHODS
  // ==========================================

  /// Get keywords with optional filters
  Future<List<KeywordModel>> getKeywords({
    List<int>? ids,
    String? search,
    int limit = 100,
  });

  /// Search keywords
  Future<List<KeywordModel>> searchKeywords(String query);

  /// Get trending keywords
  Future<List<KeywordModel>> getTrendingKeywords();

  /// Get keywords for games
  Future<List<KeywordModel>> getKeywordsForGames(List<int> gameIds);

  /// Get similar keywords
  Future<List<KeywordModel>> getSimilarKeywords(String keywordName);

  /// Get keywords by category
  Future<List<KeywordModel>> getKeywordsByCategory(String category);

  /// Get keyword by name
  Future<KeywordModel?> getKeywordByName(String name);

  /// Get random keywords
  Future<List<KeywordModel>> getRandomKeywords({int limit = 20});

  /// Search games by keywords
  Future<List<GameModel>> searchGamesByKeywords(List<String> keywordNames);

  // ==========================================
  // CHARACTER METHODS
  // ==========================================

  /// Get characters with optional filters
  Future<List<CharacterModel>> getCharacters({
    List<int>? ids,
    String? search,
    int limit = 50,
  });

  /// Search characters
  Future<List<CharacterModel>> searchCharacters(String query);

  /// Get characters for games
  Future<List<CharacterModel>> getCharactersForGames(List<int> gameIds);

  /// Get popular characters
  Future<List<CharacterModel>> getPopularCharacters({int limit = 20});

  /// Get characters by gender
  Future<List<CharacterModel>> getCharactersByGender(CharacterGenderEnum gender);

  /// Get characters by species
  Future<List<CharacterModel>> getCharactersBySpecies(CharacterSpeciesEnum species);

  /// Get character by name
  Future<CharacterModel?> getCharacterByName(String name);

  /// Get random characters
  Future<List<CharacterModel>> getRandomCharacters({int limit = 10});

  /// Get character genders
  Future<List<CharacterGenderModel>> getCharacterGenders({List<int>? ids});

  /// Get character species
  Future<List<CharacterSpeciesModel>> getCharacterSpecies({List<int>? ids});

  /// Get character mug shots
  Future<List<CharacterMugShotModel>> getCharacterMugShots(List<int> mugShotIds);

  /// Get complete character data
  Future<List<Map<String, dynamic>>> getCompleteCharacterData({
    List<int>? characterIds,
    String? search,
    int limit = 20,
  });

  // ==========================================
  // COMPANY METHODS
  // ==========================================

  /// Get companies with optional filters
  Future<List<CompanyModel>> getCompanies({
    List<int>? ids,
    String? search,
    int limit = 50,
  });

  /// Get company by ID
  Future<CompanyModel?> getCompanyById(int id);

  /// Search companies
  Future<List<CompanyModel>> searchCompanies(String query, {int limit = 20});

  /// Get popular companies
  Future<List<CompanyModel>> getPopularCompanies({int limit = 50});

  /// Get companies by developed games
  Future<List<CompanyModel>> getCompaniesByDevelopedGames(List<int> gameIds);

  /// Get companies by published games
  Future<List<CompanyModel>> getCompaniesByPublishedGames(List<int> gameIds);

  /// Get complete company data
  Future<Map<String, dynamic>> getCompleteCompanyData(int companyId);

  /// Get company hierarchy
  Future<List<CompanyModel>> getCompanyHierarchy(int companyId);

  /// Get company logos
  Future<List<CompanyLogoModel>> getCompanyLogos({
    List<int>? ids,
    int limit = 50,
  });

  /// Get company logo by ID
  Future<CompanyLogoModel?> getCompanyLogoById(int id);

  /// Get company statuses
  Future<List<CompanyStatusModel>> getCompanyStatuses({
    List<int>? ids,
    int limit = 50,
  });

  /// Get company status by ID
  Future<CompanyStatusModel?> getCompanyStatusById(int id);

  /// Get company websites
  Future<List<CompanyWebsiteModel>> getCompanyWebsites({
    List<int>? ids,
    int limit = 50,
  });

  /// Get company website by ID
  Future<CompanyWebsiteModel?> getCompanyWebsiteById(int id);

  /// Get company websites by category
  Future<List<CompanyWebsiteModel>> getCompanyWebsitesByCategory(
      CompanyWebsiteCategory category, {
        int limit = 50,
      });

  // ==========================================
  // EXTERNAL GAME METHODS
  // ==========================================

  /// Get external games for games
  Future<List<ExternalGameModel>> getExternalGames(List<int> gameIds);

  /// Get external games by store
  Future<List<ExternalGameModel>> getExternalGamesByStore(
      ExternalGameCategoryEnum store, {
        int limit = 100,
      });

  /// Get store links for games
  Future<Map<int, List<ExternalGameModel>>> getStoreLinksForGames(
      List<int> gameIds, {
        List<ExternalGameCategoryEnum>? preferredStores,
      });

  /// Get main store links
  Future<List<ExternalGameModel>> getMainStoreLinks(List<int> gameIds);

  /// Get Steam links
  Future<List<ExternalGameModel>> getSteamLinks(List<int> gameIds);

  /// Get external games by media
  Future<Map<String, List<ExternalGameModel>>> getExternalGamesByMedia(List<int> gameIds);

  /// Get best store link
  Future<ExternalGameModel?> getBestStoreLink(
      int gameId, {
        List<ExternalGameCategoryEnum>? preferredStores,
      });

  /// Search external games by UID
  Future<List<ExternalGameModel>> searchExternalGamesByUid(String uid);

  /// Get popular stores
  Future<List<Map<String, dynamic>>> getPopularStores();

  /// Get external game sources
  Future<List<ExternalGameSourceModel>> getExternalGameSources({List<int>? ids});

  /// Get game release formats
  Future<List<GameReleaseFormatModel>> getGameReleaseFormats({List<int>? ids});

  /// Get complete external game data
  Future<List<Map<String, dynamic>>> getCompleteExternalGameData(List<int> gameIds);

  // ==========================================
  // COLLECTION METHODS
  // ==========================================

  /// Get collections with optional filters
  Future<List<CollectionModel>> getCollections({
    List<int>? ids,
    String? search,
    int limit = 100,
  });

  /// Search collections
  Future<List<CollectionModel>> searchCollections(String query);

  /// Get collections for games
  Future<List<CollectionModel>> getCollectionsForGames(List<int> gameIds);

  /// Get popular collections
  Future<List<CollectionModel>> getPopularCollections({int limit = 20});

  /// Get collections by type
  Future<List<CollectionModel>> getCollectionsByType(int typeId);

  /// Get parent collections
  Future<List<CollectionModel>> getParentCollections({int limit = 50});

  /// Get child collections
  Future<List<CollectionModel>> getChildCollections(int parentCollectionId);

  /// Get collection by name
  Future<CollectionModel?> getCollectionByName(String name);

  /// Get collection types
  Future<List<CollectionTypeModel>> getCollectionTypes({List<int>? ids});

  /// Get collection memberships
  Future<List<CollectionMembershipModel>> getCollectionMemberships({
    int? collectionId,
    int? gameId,
    List<int>? ids,
  });

  /// Get collection relations
  Future<List<CollectionRelationModel>> getCollectionRelations({
    int? parentCollectionId,
    int? childCollectionId,
    List<int>? ids,
  });

  /// Get collection hierarchy
  Future<Map<String, dynamic>> getCollectionHierarchy(int collectionId);

  /// Get complete collection data
  Future<List<Map<String, dynamic>>> getCompleteCollectionData({
    List<int>? collectionIds,
    String? search,
    int limit = 20,
  });

  /// Get famous game series
  Future<List<Map<String, dynamic>>> getFamousGameSeries({int limit = 20});

  /// Get collection statistics
  Future<Map<String, dynamic>> getCollectionStatistics();

  // ==========================================
  // FRANCHISE METHODS
  // ==========================================

  /// Get franchises with optional filters
  Future<List<FranchiseModel>> getFranchises({
    List<int>? ids,
    String? search,
    int limit = 100,
  });

  /// Search franchises
  Future<List<FranchiseModel>> searchFranchises(String query);

  /// Get franchises for games
  Future<List<FranchiseModel>> getFranchisesForGames(List<int> gameIds);

  /// Get popular franchises
  Future<List<FranchiseModel>> getPopularFranchises({int limit = 20});

  /// Get major franchises
  Future<List<FranchiseModel>> getMajorFranchises({int limit = 20});

  /// Get trending franchises
  Future<List<FranchiseModel>> getTrendingFranchises();

  /// Get franchise by name
  Future<FranchiseModel?> getFranchiseByName(String name);

  /// Get random franchises
  Future<List<FranchiseModel>> getRandomFranchises({int limit = 10});

  /// Get similar franchises
  Future<List<FranchiseModel>> getSimilarFranchises(int franchiseId, {int limit = 10});

  /// Get franchises with games
  Future<List<Map<String, dynamic>>> getFranchisesWithGames({
    List<int>? franchiseIds,
    String? search,
    int limit = 20,
    int maxGamesPerFranchise = 10,
  });

  /// Get franchise statistics
  Future<Map<String, dynamic>> getFranchiseStatistics();

  /// Get franchise timeline
  Future<Map<String, dynamic>> getFranchiseTimeline(int franchiseId);

  // ==========================================
  // AGE RATING METHODS
  // ==========================================

  /// Get age ratings for games
  Future<List<AgeRatingModel>> getAgeRatings(List<int> gameIds);

  /// Get age rating organizations
  Future<List<AgeRatingOrganizationModel>> getAgeRatingOrganizations({List<int>? ids});

  /// Get age rating categories
  Future<List<AgeRatingCategoryModel>> getAgeRatingCategories({
    List<int>? ids,
    int? organizationId,
  });

  /// Get complete age ratings
  Future<List<Map<String, dynamic>>> getCompleteAgeRatings(List<int> gameIds);

  // ==========================================
  // EVENT METHODS
  // ==========================================

  /// Get events with optional filters
  Future<List<EventModel>> getEvents({
    List<int>? ids,
    String? search,
    int limit = 50,
  });

  /// Get event by ID
  Future<EventModel?> getEventById(int id);

  /// Search events
  Future<List<EventModel>> searchEvents(String query, {int limit = 20});

  /// Get upcoming events
  Future<List<EventModel>> getUpcomingEvents({int limit = 50});

  /// Get live events
  Future<List<EventModel>> getLiveEvents({int limit = 50});

  /// Get past events
  Future<List<EventModel>> getPastEvents({int limit = 50});

  /// Get events by date range
  Future<List<EventModel>> getEventsByDateRange({
    DateTime? startDate,
    DateTime? endDate,
    int limit = 50,
  });

  /// Get events by games
  Future<List<EventModel>> getEventsByGames(List<int> gameIds);

  /// Get event logos
  Future<List<EventLogoModel>> getEventLogos({
    List<int>? ids,
    int limit = 50,
  });

  /// Get event logo by ID
  Future<EventLogoModel?> getEventLogoById(int id);

  /// Get event logo by event ID
  Future<EventLogoModel?> getEventLogoByEventId(int eventId);

  /// Get event networks
  Future<List<EventNetworkModel>> getEventNetworks({
    List<int>? ids,
    int limit = 50,
  });

  /// Get event network by ID
  Future<EventNetworkModel?> getEventNetworkById(int id);

  /// Get event networks by event ID
  Future<List<EventNetworkModel>> getEventNetworksByEventId(int eventId);

  /// Get event networks by network type
  Future<List<EventNetworkModel>> getEventNetworksByNetworkType(int networkTypeId);

  /// Get network types
  Future<List<NetworkTypeModel>> getNetworkTypes({
    List<int>? ids,
    String? search,
    int limit = 50,
  });

  /// Get network type by ID
  Future<NetworkTypeModel?> getNetworkTypeById(int id);

  /// Search network types
  Future<List<NetworkTypeModel>> searchNetworkTypes(String query, {int limit = 20});

  /// Get complete event data
  Future<Map<String, dynamic>> getCompleteEventData(int eventId);

  /// Get events with games and networks
  Future<List<EventModel>> getEventsWithGamesAndNetworks({
    bool includeLogos = true,
    int limit = 50,
  });

  // ==========================================
  // RELEASE DATE METHODS
  // ==========================================

  /// Get release dates
  Future<List<ReleaseDateModel>> getReleaseDates({
    List<int>? ids,
    int limit = 50,
  });

  /// Get release date by ID
  Future<ReleaseDateModel?> getReleaseDateById(int id);

  /// Get release dates by game
  Future<List<ReleaseDateModel>> getReleaseDatesByGame(int gameId);

  /// Get release dates by platform
  Future<List<ReleaseDateModel>> getReleaseDatesByPlatform(int platformId);

  /// Get release dates by region
  Future<List<ReleaseDateModel>> getReleaseDatesByRegion(int regionId);

  /// Get release dates by status
  Future<List<ReleaseDateModel>> getReleaseDatesByStatus(int statusId);

  /// Get release dates by date range
  Future<List<ReleaseDateModel>> getReleaseDatesByDateRange({
    DateTime? startDate,
    DateTime? endDate,
    int limit = 50,
  });

  /// Get upcoming release dates
  Future<List<ReleaseDateModel>> getUpcomingReleaseDates({int limit = 50});

  /// Get recent release dates
  Future<List<ReleaseDateModel>> getRecentReleaseDates({int limit = 50});

  /// Get today's release dates
  Future<List<ReleaseDateModel>> getTodaysReleaseDates();

  /// Get this week's release dates
  Future<List<ReleaseDateModel>> getThisWeeksReleaseDates();

  /// Get this month's release dates
  Future<List<ReleaseDateModel>> getThisMonthsReleaseDates();

  /// Get release dates for year
  Future<List<ReleaseDateModel>> getReleaseDatesForYear(int year, {int limit = 100});

  /// Get release dates for quarter
  Future<List<ReleaseDateModel>> getReleaseDatesForQuarter(int year, int quarter, {int limit = 50});

  /// Get release date regions
  Future<List<ReleaseDateRegionModel>> getReleaseDateRegions({
    List<int>? ids,
    String? search,
    int limit = 50,
  });

  /// Get release date region by ID
  Future<ReleaseDateRegionModel?> getReleaseDateRegionById(int id);

  /// Search release date regions
  Future<List<ReleaseDateRegionModel>> searchReleaseDateRegions(String query, {int limit = 20});

  /// Get release date statuses
  Future<List<ReleaseDateStatusModel>> getReleaseDateStatuses({
    List<int>? ids,
    String? search,
    int limit = 50,
  });

  /// Get release date status by ID
  Future<ReleaseDateStatusModel?> getReleaseDateStatusById(int id);

  /// Search release date statuses
  Future<List<ReleaseDateStatusModel>> searchReleaseDateStatuses(String query, {int limit = 20});

  /// Get complete release date data
  Future<Map<String, dynamic>> getCompleteReleaseDateData(int releaseDateId);

  /// Get release dates with regions and statuses
  Future<List<ReleaseDateModel>> getReleaseDatesWithRegionsAndStatuses({
    int limit = 50,
  });

  /// Get game release dates with details
  Future<List<ReleaseDateModel>> getGameReleaseDatesWithDetails(int gameId);

  /// Get earliest release date
  Future<ReleaseDateModel?> getEarliestReleaseDate(int gameId);

  /// Get latest release date
  Future<ReleaseDateModel?> getLatestReleaseDate(int gameId);

  /// Get game release dates by region
  Future<Map<String, List<ReleaseDateModel>>> getGameReleaseDatesByRegion(int gameId);

  // ==========================================
  // SEARCH & POPULARITY METHODS
  // ==========================================

  /// Global search across all entity types
  Future<List<SearchModel>> search({
    required String query,
    SearchResultType? resultType,
    int limit = 50,
  });

  /// Global search
  Future<List<SearchModel>> searchGlobal(String query, {int limit = 50});

  /// Search with filters
  Future<List<SearchModel>> searchWithFilters({
    required String query,
    SearchResultType? resultType,
    DateTime? publishedAfter,
    DateTime? publishedBefore,
    int limit = 50,
  });

  /// Get trending searches
  Future<List<SearchModel>> getTrendingSearches({int limit = 20});

  /// Get popular searches
  Future<List<SearchModel>> getPopularSearches({int limit = 20});

  /// Autocomplete search
  Future<List<SearchModel>> autocompleteSearch(String partialQuery, {int limit = 10});

  /// Get search history
  Future<List<String>> getSearchHistory();

  /// Save search query
  Future<void> saveSearchQuery(String query);

  /// Get search analytics
  Future<Map<String, dynamic>> getSearchAnalytics();

  /// Get search statistics
  Future<List<Map<String, dynamic>>> getSearchStatistics({
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Get complete search results
  Future<Map<String, dynamic>> getCompleteSearchResults(String query, {int limit = 50});

  // ==========================================
  // POPULARITY METHODS
  // ==========================================

  /// Get popularity primitives
  Future<List<PopularityPrimitiveModel>> getPopularityPrimitives({
    List<int>? ids,
    int? gameId,
    int? popularityTypeId,
    PopularitySourceEnum? source,
    int limit = 50,
  });

  /// Get popularity primitive by ID
  Future<PopularityPrimitiveModel?> getPopularityPrimitiveById(int id);

  /// Get game popularity metrics
  Future<List<PopularityPrimitiveModel>> getGamePopularityMetrics(int gameId);

  /// Get popularity by type
  Future<List<PopularityPrimitiveModel>> getPopularityByType(int popularityTypeId);

  /// Get popularity by source
  Future<List<PopularityPrimitiveModel>> getPopularityBySource(PopularitySourceEnum source);

  /// Get top popular games
  Future<List<PopularityPrimitiveModel>> getTopPopularGames({
    int limit = 50,
    PopularitySourceEnum? source,
    int? popularityTypeId,
  });

  /// Get trending games
  Future<List<PopularityPrimitiveModel>> getTrendingGames({
    int limit = 20,
    Duration? timeWindow,
  });

  /// Get recent popularity updates
  Future<List<PopularityPrimitiveModel>> getRecentPopularityUpdates({
    int limit = 50,
    Duration? timeWindow,
  });

  /// Get popularity types
  Future<List<PopularityTypeModel>> getPopularityTypes({
    List<int>? ids,
    String? search,
    PopularitySourceEnum? source,
    int limit = 50,
  });

  /// Get popularity type by ID
  Future<PopularityTypeModel?> getPopularityTypeById(int id);

  /// Search popularity types
  Future<List<PopularityTypeModel>> searchPopularityTypes(String query, {int limit = 20});

  /// Get popularity types by source
  Future<List<PopularityTypeModel>> getPopularityTypesBySource(PopularitySourceEnum source);

  /// Get game popularity analysis
  Future<Map<String, dynamic>> getGamePopularityAnalysis(int gameId);

  /// Get popularity trends
  Future<Map<String, dynamic>> getPopularityTrends({
    int? gameId,
    Duration? timeWindow,
    PopularitySourceEnum? source,
  });

  /// Get popularity leaderboard
  Future<List<Map<String, dynamic>>> getPopularityLeaderboard({
    PopularitySourceEnum? source,
    int? popularityTypeId,
    int limit = 100,
  });

  /// Get popularity statistics
  Future<Map<String, dynamic>> getPopularityStatistics(int gameId);

  /// Get popularity changes
  Future<List<PopularityPrimitiveModel>> getPopularityChanges({
    int? gameId,
    Duration? timeWindow,
    int limit = 50,
  });

  // ==========================================
  // WEBSITE METHODS
  // ==========================================

  /// Get websites for games
  Future<List<WebsiteModel>> getWebsites(List<int> gameIds);

  /// Get website types
  Future<List<WebsiteTypeModel>> getWebsiteTypes({List<int>? ids});

  /// Get website type by ID
  Future<WebsiteTypeModel?> getWebsiteTypeById(int id);

  // ==========================================
  // LANGUAGE METHODS
  // ==========================================

  /// Get languages
  Future<List<LanguageModel>> getLanguages({List<int>? ids, String? search});

  /// Get language by ID
  Future<LanguageModel?> getLanguageById(int id);

  /// Get languages by locale
  Future<List<LanguageModel>> getLanguagesByLocale(List<String> locales);

  /// Get language support types
  Future<List<LanguageSupportTypeModel>> getLanguageSupportTypes({List<int>? ids});

  /// Get language support type by ID
  Future<LanguageSupportTypeModel?> getLanguageSupportTypeById(int id);

  // ==========================================
  // REGION METHODS
  // ==========================================

  /// Get regions
  Future<List<RegionModel>> getRegions({
    List<int>? ids,
    String? category, // 'locale' or 'continent'
  });

  /// Get region by ID
  Future<RegionModel?> getRegionById(int id);

  /// Get regions by identifiers
  Future<List<RegionModel>> getRegionsByIdentifiers(List<String> identifiers);

  /// Get locale regions
  Future<List<RegionModel>> getLocaleRegions();

  /// Get continent regions
  Future<List<RegionModel>> getContinentRegions();

  // ==========================================
  // DATE FORMAT METHODS
  // ==========================================

  /// Get date formats
  Future<List<DateFormatModel>> getDateFormats({List<int>? ids});

  /// Get date format by ID
  Future<DateFormatModel?> getDateFormatById(int id);

  // ==========================================
  // INVOLVED COMPANY METHODS
  // ==========================================

  /// Get involved companies
  Future<List<InvolvedCompanyModel>> getInvolvedCompanies({
    List<int>? ids,
    List<int>? gameIds,
    List<int>? companyIds,
    bool? developer,
    bool? publisher,
    bool? porting,
    bool? supporting,
    int limit = 50,
  });

  /// Get involved company by ID
  Future<InvolvedCompanyModel?> getInvolvedCompanyById(int id);

  /// Get involved companies by game
  Future<List<InvolvedCompanyModel>> getInvolvedCompaniesByGame(int gameId);

  /// Get involved companies by company
  Future<List<InvolvedCompanyModel>> getInvolvedCompaniesByCompany(int companyId);

  /// Get developers for games
  Future<List<InvolvedCompanyModel>> getDevelopersForGames(List<int> gameIds);

  /// Get publishers for games
  Future<List<InvolvedCompanyModel>> getPublishersForGames(List<int> gameIds);

  /// Get porting companies for games
  Future<List<InvolvedCompanyModel>> getPortingCompaniesForGames(List<int> gameIds);

  /// Get supporting companies for games
  Future<List<InvolvedCompanyModel>> getSupportingCompaniesForGames(List<int> gameIds);

  // ==========================================
  // PHASE 1 - HOME SCREEN DATA METHODS
  // ==========================================

  /// Get games sorted by rating (highest first)
  Future<List<GameModel>> getGamesSortedByRating({
  int limit = 20,
  int offset = 0,
  double minRating = 70.0, // Minimum rating to include
  });

  /// Get games sorted by release date (newest first)
  Future<List<GameModel>> getGamesSortedByReleaseDate({
  int limit = 20,
  int offset = 0,
  int maxDaysOld = 365, // Only games released in last X days
  });

  /// Get specific games by IDs with release dates in a range
  Future<List<GameModel>> getGamesByReleaseDateRange({
  required List<int> gameIds,
  required DateTime fromDate,
  required DateTime toDate,
  });

  // ==========================================
  // PHASE 2 - ENHANCED SEARCH & FILTERING METHODS
  // ==========================================

  /// Enhanced search with comprehensive filtering
  Future<List<GameModel>> searchGamesWithFilters({
    required String query,
    required SearchFilters filters,
    int limit = 20,
    int offset = 0,
  });

  /// Get games by genres with sorting options
  Future<List<GameModel>> getGamesByGenres({
    required List<int> genreIds,
    int limit = 20,
    int offset = 0,
    String sortBy = 'total_rating',
    String sortOrder = 'desc',
  });

  /// Get games by platforms with sorting options
  Future<List<GameModel>> getGamesByPlatforms({
    required List<int> platformIds,
    int limit = 20,
    int offset = 0,
    String sortBy = 'total_rating',
    String sortOrder = 'desc',
  });

  /// Get games by release year range
  Future<List<GameModel>> getGamesByYearRange({
    required int fromYear,
    required int toYear,
    int limit = 20,
    int offset = 0,
    String sortBy = 'first_release_date',
    String sortOrder = 'desc',
  });

  /// Get games by rating range
  Future<List<GameModel>> getGamesByRatingRange({
    required double minRating,
    required double maxRating,
    int limit = 20,
    int offset = 0,
    String sortBy = 'total_rating',
    String sortOrder = 'desc',
  });

  /// Get all genres
  Future<List<GenreModel>> getAllGenres();

  /// Get all platforms
  Future<List<PlatformModel>> getAllPlatforms();

  /// Advanced search with multiple filters
  Future<List<GameModel>> getFilteredGames({
    required SearchFilters filters,
    int limit = 20,
    int offset = 0,
  });

  /// Get search suggestions
  Future<List<String>> getSearchSuggestions(String partialQuery);
}

