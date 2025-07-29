// lib/domain/repositories/game_repository.dart
import 'package:dartz/dartz.dart';
import 'package:gamer_grove/domain/entities/character/character.dart';
import 'package:gamer_grove/domain/entities/game/game_engine.dart';
import '../../core/errors/failures.dart';
import '../entities/artwork.dart';
import '../entities/character/character_gender.dart';
import '../entities/character/character_species.dart';
import '../entities/event/event.dart';
import '../entities/game/game.dart';
import '../entities/company/company.dart';
import '../entities/game/game_media_collection.dart';
import '../entities/game/game_sort_options.dart';
import '../entities/game/game_video.dart';
import '../entities/genre.dart';
import '../entities/platform/platform.dart';
import '../entities/recommendations/discovery_challenge.dart';
import '../entities/recommendations/game_mood.dart';
import '../entities/recommendations/genre_trend.dart';
import '../entities/recommendations/platform_trend.dart';
import '../entities/recommendations/recommendation_signal.dart';
import '../entities/recommendations/seasons.dart';
import '../entities/screenshot.dart';
import '../entities/search/search_filters.dart';
import '../entities/user/user_collection_filters.dart';
import '../entities/user/user_collection_sort_options.dart';
import '../entities/user/user_collection_summary.dart';
import '../entities/website/website.dart';
import '../entities/ageRating/age_rating.dart';

/// Game Repository Interface
///
/// This interface defines all game-related operations that are currently
/// implemented in the GameRepositoryImpl.
abstract class GameRepository {

  // ==========================================
  // BASIC GAME METHODS
  // ==========================================

  /// Search for games by query with pagination
  Future<Either<Failure, List<Game>>> searchGames(String query,
      int limit,
      int offset);

  /// Get basic game details by ID
  Future<Either<Failure, Game>> getGameDetails(int gameId);

  /// Get complete game details with all related data
  Future<Either<Failure, Game>> getCompleteGameDetails(int gameId,
      String? userId);

  /// Get game details enriched with user-specific data
  Future<Either<Failure, Game>> getGameDetailsWithUserData(int gameId,
      String? userId);

  /// Get multiple games by their IDs (batch operation)
  Future<Either<Failure, List<Game>>> getGamesByIds(List<int> gameIds);

  // ==========================================
  // POPULAR & UPCOMING GAMES
  // ==========================================

  /// Get popular games with pagination
  Future<Either<Failure, List<Game>>> getPopularGames(int limit, int offset);

  /// Get upcoming games with pagination
  Future<Either<Failure, List<Game>>> getUpcomingGames(int limit, int offset);

  Future<Either<Failure, List<Game>>> getLatestGames(int limit, int offset);

  // ==========================================
  // ENHANCED COMPANY & CONTENT METHODS
  // ==========================================

  /// Get companies (developers, publishers, etc.)
  Future<Either<Failure, List<Company>>> getCompanies({
    List<int>? ids,
    String? search
  });

  /// Get websites associated with games
  Future<Either<Failure, List<Website>>> getGameWebsites(List<int> gameIds);

  /// Get age ratings for games
  Future<Either<Failure, List<AgeRating>>> getGameAgeRatings(List<int> gameIds);

  // ==========================================
  // RELATED GAMES
  // ==========================================

  /// Get games similar to a specific game
  Future<Either<Failure, List<Game>>> getSimilarGames(int gameId);

  /// Get DLCs for a specific game
  Future<Either<Failure, List<Game>>> getGameDLCs(int gameId);

  /// Get expansions for a specific game
  Future<Either<Failure, List<Game>>> getGameExpansions(int gameId);

  // ==========================================
  // USER-SPECIFIC METHODS
  // ==========================================

  /// Get user's wishlist games with pagination
  Future<Either<Failure, List<Game>>> getUserWishlist(String userId,
      int limit,
      int offset);

  /// Get user's recommended games with pagination
  Future<Either<Failure, List<Game>>> getUserRecommendations(String userId,
      int limit,
      int offset);

  /// Get user's rated games with pagination
  Future<Either<Failure, List<Game>>> getUserRated(String userId,
      int limit,
      int offset);

  /// Get user's top three favorite games
  Future<Either<Failure, List<Game>>> getUserTopThreeGames(String userId);

  // ==========================================
  // USER ACTIONS
  // ==========================================

  /// Rate a game (0-10 scale)
  Future<Either<Failure, void>> rateGame(int gameId,
      String userId,
      double rating);

  /// Toggle game in user's wishlist
  Future<Either<Failure, void>> toggleWishlist(int gameId, String userId);

  /// Toggle game recommendation status
  Future<Either<Failure, void>> toggleRecommend(int gameId, String userId);

  // ==========================================
  // PHASE 1 - HOME SCREEN METHODS
  // ==========================================

  /// Get top rated games with pagination
  Future<Either<Failure, List<Game>>> getTopRatedGames(int limit, int offset);

  /// Get newest/recently released games with pagination
  Future<Either<Failure, List<Game>>> getNewestGames(int limit, int offset);

  /// Get wishlist items that were recently released (last month)
  /// or are releasing soon (next 2 weeks)
  Future<Either<Failure, List<Game>>> getWishlistRecentReleases(String userId,
      {DateTime? fromDate, DateTime? toDate});

  // ==========================================
  // PHASE 2 - ENHANCED SEARCH & FILTERING
  // ==========================================

  /// Enhanced search with comprehensive filtering options
  Future<Either<Failure, List<Game>>> searchGamesWithFilters({
    required String query,
    required SearchFilters filters,
    int limit = 20,
    int offset = 0,
  });

  /// Get games by specific genres
  Future<Either<Failure, List<Game>>> getGamesByGenre({
    required List<int> genreIds,
    int limit = 20,
    int offset = 0,
    GameSortBy sortBy = GameSortBy.popularity,
    SortOrder sortOrder = SortOrder.descending,
  });

  /// Get games by specific platforms
  Future<Either<Failure, List<Game>>> getGamesByPlatform({
    required List<int> platformIds,
    int limit = 20,
    int offset = 0,
    GameSortBy sortBy = GameSortBy.popularity,
    SortOrder sortOrder = SortOrder.descending,
  });

  /// Get games by release year range
  Future<Either<Failure, List<Game>>> getGamesByReleaseYear({
    required int fromYear,
    required int toYear,
    int limit = 20,
    int offset = 0,
    GameSortBy sortBy = GameSortBy.releaseDate,
    SortOrder sortOrder = SortOrder.descending,
  });

  /// Get games by rating range
  Future<Either<Failure, List<Game>>> getGamesByRatingRange({
    required double minRating,
    required double maxRating,
    int limit = 20,
    int offset = 0,
    GameSortBy sortBy = GameSortBy.rating,
    SortOrder sortOrder = SortOrder.descending,
  });

  /// Get all available genres for filtering
  Future<Either<Failure, List<Genre>>> getAllGenres();

  /// Get all available platforms for filtering
  Future<Either<Failure, List<Platform>>> getAllPlatforms();

  /// Get filtered games with complex multi-criteria search
  Future<Either<Failure, List<Game>>> getFilteredGames({
    required SearchFilters filters,
    int limit = 20,
    int offset = 0,
  });

  /// Advanced search combining text search with filters
  Future<Either<Failure, List<Game>>> advancedGameSearch({
    String? textQuery,
    required SearchFilters filters,
    int limit = 20,
    int offset = 0,
  });

  // ==========================================
  // UTILITY METHODS FOR SEARCH ENHANCEMENT
  // ==========================================

  /// Get search suggestions based on partial query
  Future<Either<Failure, List<String>>> getSearchSuggestions(
      String partialQuery);

  /// Get recently searched games for user
  Future<Either<Failure, List<Game>>> getRecentSearches(String userId,
      {int limit = 10});

  /// Save search query for user (for recent searches)
  Future<Either<Failure, void>> saveSearchQuery(String userId, String query);

  // ==========================================
  // PHASE 3 - ENHANCED USER COLLECTIONS WITH SORTING & FILTERING
  // ==========================================

  /// Get user's wishlist with advanced sorting and filtering
  Future<Either<Failure, List<Game>>> getUserWishlistWithFilters({
    required String userId,
    required UserCollectionFilters filters,
    int limit = 20,
    int offset = 0,
  });

  /// Get user's rated games with advanced sorting and filtering
  Future<Either<Failure, List<Game>>> getUserRatedGamesWithFilters({
    required String userId,
    required UserCollectionFilters filters,
    int limit = 20,
    int offset = 0,
  });

  /// Get user's recommended games with advanced sorting and filtering
  Future<Either<Failure, List<Game>>> getUserRecommendedGamesWithFilters({
    required String userId,
    required UserCollectionFilters filters,
    int limit = 20,
    int offset = 0,
  });

  /// Get summary statistics for a user collection
  Future<Either<Failure, UserCollectionSummary>> getUserCollectionSummary({
    required String userId,
    required UserCollectionType collectionType,
  });

  /// Get user's gaming statistics across all collections
  Future<Either<Failure, Map<String, dynamic>>> getUserGamingStatistics(
      String userId);

  /// Get user's genre preferences based on their collections
  Future<Either<Failure, Map<String, double>>> getUserGenrePreferences(
      String userId);

  /// Get user's platform usage statistics
  Future<Either<Failure, Map<String, int>>> getUserPlatformStatistics(
      String userId);

  /// Get user's rating patterns and analytics
  Future<Either<Failure, Map<String, dynamic>>> getUserRatingAnalytics(
      String userId);

  // ==========================================
  // ENHANCED COLLECTION MANAGEMENT
  // ==========================================

  /// Get all user collections data in one call (for Grove page overview)
  Future<Either<Failure,
      Map<UserCollectionType, List<Game>>>> getAllUserCollections({
    required String userId,
    int limitPerCollection = 10,
  });

  /// Get user collection summaries for all collection types
  Future<Either<Failure,
      Map<UserCollectionType,
          UserCollectionSummary>>> getAllUserCollectionSummaries(String userId);

  /// Search within user's collections
  Future<Either<Failure, List<Game>>> searchUserCollections({
    required String userId,
    required String query,
    required List<UserCollectionType> collectionTypes,
    UserCollectionFilters? filters,
    int limit = 20,
    int offset = 0,
  });

  /// Get recently added games across all user collections
  Future<Either<Failure, List<Game>>> getRecentlyAddedToCollections({
    required String userId,
    int days = 7,
    int limit = 20,
  });

  /// Get user's most played/favorite genres with game counts
  Future<Either<Failure, List<Map<String, dynamic>>>> getUserTopGenres({
    required String userId,
    int limit = 10,
  });

  /// Get user's gaming activity timeline
  Future<Either<Failure, List<Map<String, dynamic>>>> getUserActivityTimeline({
    required String userId,
    DateTime? fromDate,
    DateTime? toDate,
    int limit = 50,
  });

  // ==========================================
  // QUICK ACTIONS & BATCH OPERATIONS
  // ==========================================

  /// Batch add games to wishlist
  Future<Either<Failure, void>> batchAddToWishlist({
    required String userId,
    required List<int> gameIds,
  });

  /// Batch remove games from wishlist
  Future<Either<Failure, void>> batchRemoveFromWishlist({
    required String userId,
    required List<int> gameIds,
  });

  /// Batch rate multiple games
  Future<Either<Failure, void>> batchRateGames({
    required String userId,
    required Map<int, double> gameRatings, // gameId -> rating
  });

  /// Move games between collections (e.g., wishlist -> rated)
  Future<Either<Failure, void>> moveGamesBetweenCollections({
    required String userId,
    required List<int> gameIds,
    required UserCollectionType fromCollection,
    required UserCollectionType toCollection,
  });

  // ==========================================
  // PHASE 4 - GAME DETAIL ENHANCEMENTS
  // ==========================================

  /// Get characters associated with a game
  Future<Either<Failure, List<Character>>> getGameCharacters(int gameId);

  /// Get events featuring a specific game
  Future<Either<Failure, List<Event>>> getGameEvents(int gameId);

  /// Get videos (trailers, gameplay, etc.) for a game
  Future<Either<Failure, List<GameVideo>>> getGameVideos(int gameId);

  /// Get screenshots for a game
  Future<Either<Failure, List<Screenshot>>> getGameScreenshots(int gameId);

  /// Get artwork for a game
  Future<Either<Failure, List<Artwork>>> getGameArtwork(int gameId);

  /// Get complete game media (videos, screenshots, artwork) in one call
  Future<Either<Failure, GameMediaCollection>> getGameMediaCollection(
      int gameId);

  /// Get game details with all extended content (characters, events, media)
  Future<Either<Failure, Game>> getEnhancedGameDetails({
    required int gameId,
    String? userId,
    bool includeCharacters = true,
    bool includeEvents = true,
    bool includeMedia = true,
  });

  // ==========================================
  // CHARACTER DISCOVERY & SEARCH
  // ==========================================

  /// Search characters across all games
  Future<Either<Failure, List<Character>>> searchCharacters(String query);

  /// Get popular characters
  Future<Either<Failure, List<Character>>> getPopularCharacters(
      {int limit = 20});

  /// Get characters by gender
  Future<Either<Failure, List<Character>>> getCharactersByGender(
      CharacterGenderEnum gender);

  /// Get characters by species
  Future<Either<Failure, List<Character>>> getCharactersBySpecies(
      CharacterSpeciesEnum species);

  /// Get character details by ID
  Future<Either<Failure, Character>> getCharacterDetails(int characterId);

  /// Get games featuring a specific character
  Future<Either<Failure, List<Game>>> getGamesByCharacter(int characterId);

  // ==========================================
  // EVENT DISCOVERY
  // ==========================================

  /// Search events
  Future<Either<Failure, List<Event>>> searchEvents(String query);

  /// Get event details by ID
  Future<Either<Failure, Event>> getEventDetails(int eventId);

  /// Get all games featured in an event
  Future<Either<Failure, List<Game>>> getEventGames(int eventId);

  /// Get platform details by ID
  Future<Either<Failure, Platform>> getPlatformDetails(int platformId);

  Future<Either<Failure, GameEngine>> getGameEngineDetails(int gameEngineId);

  /// Get games by specific gameEngine
  Future<Either<Failure, List<Game>>> getGamesByGameEngine({
    required List<int> gameEngineIds,
    int limit = 20,
    int offset = 0,
    GameSortBy sortBy = GameSortBy.popularity,
    SortOrder sortOrder = SortOrder.descending,
  });


}

