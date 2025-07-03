// data/repositories/game_repository_impl.dart
import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/artwork.dart';
import '../../domain/entities/character/character.dart';
import '../../domain/entities/character/character_gender.dart';
import '../../domain/entities/character/character_species.dart';
import '../../domain/entities/event/event.dart';
import '../../domain/entities/game/game.dart';
import '../../domain/entities/ageRating/age_rating.dart';
import '../../domain/entities/company/company.dart';
import '../../domain/entities/game/game_media_collection.dart';
import '../../domain/entities/game/game_sort_options.dart';
import '../../domain/entities/game/game_video.dart';
import '../../domain/entities/genre.dart';
import '../../domain/entities/platform/platform.dart';
import '../../domain/entities/recommendations/discovery_challenge.dart';
import '../../domain/entities/recommendations/game_mood.dart';
import '../../domain/entities/recommendations/genre_trend.dart';
import '../../domain/entities/recommendations/platform_trend.dart';
import '../../domain/entities/recommendations/recommendation_signal.dart';
import '../../domain/entities/recommendations/seasons.dart';
import '../../domain/entities/screenshot.dart';
import '../../domain/entities/search/search_filters.dart';
import '../../domain/entities/user/user.dart';
import '../../domain/entities/user/user_collection_filters.dart';
import '../../domain/entities/user/user_collection_sort_options.dart';
import '../../domain/entities/user/user_collection_summary.dart';
import '../../domain/entities/website/website.dart';
import '../../domain/repositories/game_repository.dart';
import '../datasources/local/cache_datasource.dart';
import '../datasources/remote/igdb/idgb_remote_datasource.dart';
import '../datasources/remote/supabase/supabase_remote_datasource.dart';
import '../../../presentation/blocs/auth/auth_bloc.dart';
import 'package:get_it/get_it.dart';

class GameRepositoryImpl implements GameRepository {
  final IGDBRemoteDataSource igdbDataSource;
  final SupabaseRemoteDataSource supabaseDataSource;
  final LocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  GameRepositoryImpl({
    required this.igdbDataSource,
    required this.supabaseDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  // ==========================================
  // BASIC GAME METHODS - Enhanced with new structures
  // ==========================================

  @override
  Future<Either<Failure, Game>> getGameDetails(int gameId) async {
    try {
      // Check cache first with enhanced data
      final cachedGame = await localDataSource.getCachedGameDetails(gameId);
      if (cachedGame != null) {
        print('🎮 GameRepository: Found cached game details for ID: $gameId');
        return Right(await _enrichGameWithUserData(cachedGame));
      }

      // Check network connectivity
      if (!await networkInfo.isConnected) {
        print('❌ GameRepository: No network connection');
        return const Left(NetworkFailure(
            message: 'No internet connection. Please check your network.'
        ));
      }

      print('🌐 GameRepository: Fetching enhanced game details for ID: $gameId');

      // Use new comprehensive method from IGDB data source
      final gameModel = await igdbDataSource.getCompleteGameDetails(gameId);

      // Cache the enhanced game data
      await localDataSource.cacheGameDetails(gameId, gameModel);

      // Enrich with user-specific data
      final enrichedGame = await _enrichGameWithUserData(gameModel);

      print('✅ GameRepository: Enhanced game details loaded successfully');
      return Right(enrichedGame);

    } on ServerException catch (e) {
      print('💥 GameRepository: Server error: ${e.message}');
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      print('💥 GameRepository: Unexpected error: $e');
      return const Left(ServerFailure(message: 'Failed to load game details'));
    }
  }

  @override
  Future<Either<Failure, Game>> getCompleteGameDetails(int gameId, String? userId) async {
    try {
      if (!await networkInfo.isConnected) {
        // Try cache for offline access
        try {
          final cachedGame = await localDataSource.getCachedGameDetails(gameId);
          if (cachedGame != null && userId != null) {
            return Right(await _enrichGameWithUserData(cachedGame));
          }
        } catch (e) {
          print('⚠️ GameRepository: Cache read failed: $e');
        }
        return const Left(NetworkFailure());
      }

      print('🎮 GameRepository: Getting COMPLETE game details for ID: $gameId');

      // Get comprehensive game data using new IGDB methods
      final gameModel = await igdbDataSource.getCompleteGameDetails(gameId);

      // Enrich with user data if user is logged in
      Game game = gameModel;
      if (userId != null) {
        game = await _enrichGameWithUserData(gameModel);
      }

      // Cache the complete enhanced data
      await localDataSource.cacheGameDetails(gameId, gameModel);

      print('✅ GameRepository: Complete enhanced game details loaded successfully');
      return Right(game);

    } on ServerException catch (e) {
      print('💥 GameRepository: Server error: ${e.message}');
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      print('💥 GameRepository: Unexpected error: $e');
      return const Left(ServerFailure(message: 'Failed to load complete game details'));
    }
  }

  @override
  Future<Either<Failure, Game>> getGameDetailsWithUserData(int gameId, String? userId) async {
    return getCompleteGameDetails(gameId, userId);
  }

  @override
  Future<Either<Failure, List<Game>>> searchGames(String query, int limit, int offset) async {
    try {
      // Check cache for search results
      final cachedResults = await localDataSource.getCachedSearchResults(query);
      if (cachedResults != null && cachedResults.isNotEmpty) {
        print('🔍 GameRepository: Found cached search results for: $query');
        return Right(await _enrichGamesWithUserData(cachedResults));
      }

      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure(
            message: 'No internet connection. Please check your network.'
        ));
      }

      print('🔍 GameRepository: Searching for: "$query" (limit: $limit, offset: $offset)');

      // Use enhanced search that includes more data
      final searchResults = await igdbDataSource.searchGames(query, limit, offset);

      // Cache search results
      await localDataSource.cacheSearchResults(query, searchResults);

      // Enrich with user data
      final enrichedResults = await _enrichGamesWithUserData(searchResults);

      print('✅ GameRepository: Search completed - found ${enrichedResults.length} results');
      return Right(enrichedResults);

    } on ServerException catch (e) {
      print('💥 GameRepository: Search error: ${e.message}');
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      print('💥 GameRepository: Unexpected search error: $e');
      return const Left(ServerFailure(message: 'Failed to search games'));
    }
  }

  @override
  Future<Either<Failure, List<Game>>> getGamesByIds(List<int> gameIds) async {
    try {
      if (gameIds.isEmpty) {
        return const Right([]);
      }

      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      print('🎮 GameRepository: Getting ${gameIds.length} games by IDs');

      // Use batch method for better performance with enhanced data
      final games = await igdbDataSource.getGamesByIds(gameIds);

      // Enrich all games with user data
      final enrichedGames = await _enrichGamesWithUserData(games);

      print('✅ GameRepository: Loaded ${enrichedGames.length} games by IDs');
      return Right(enrichedGames);

    } on ServerException catch (e) {
      print('💥 GameRepository: Error getting games by IDs: ${e.message}');
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      print('💥 GameRepository: Unexpected error getting games by IDs: $e');
      return Left(ServerFailure(message: 'Failed to load games'));
    }
  }

  // ==========================================
  // POPULAR & UPCOMING GAMES - Enhanced
  // ==========================================

  @override
  Future<Either<Failure, List<Game>>> getPopularGames(int limit, int offset) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      print('🔥 GameRepository: Getting popular games (limit: $limit, offset: $offset)');

      // Use enhanced popular games method
      final popularGames = await igdbDataSource.getPopularGames(limit, offset);

      // Enrich with user data
      final enrichedGames = await _enrichGamesWithUserData(popularGames);

      print('✅ GameRepository: Loaded ${enrichedGames.length} popular games');
      return Right(enrichedGames);

    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to load popular games'));
    }
  }

  @override
  Future<Either<Failure, List<Game>>> getUpcomingGames(int limit, int offset) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      print('📅 GameRepository: Getting upcoming games (limit: $limit, offset: $offset)');

      // Use enhanced upcoming games method
      final upcomingGames = await igdbDataSource.getUpcomingGames(limit, offset);

      // Enrich with user data
      final enrichedGames = await _enrichGamesWithUserData(upcomingGames);

      print('✅ GameRepository: Loaded ${enrichedGames.length} upcoming games');
      return Right(enrichedGames);

    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to load upcoming games'));
    }
  }

  // ==========================================
  // ENHANCED COMPANY & CONTENT METHODS
  // ==========================================

  @override
  Future<Either<Failure, List<Company>>> getCompanies({List<int>? ids, String? search}) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      print('🏢 GameRepository: Getting companies (ids: $ids, search: $search)');

      // Use enhanced company method with complete data
      final companies = await igdbDataSource.getCompanies(ids: ids, search: search);

      print('✅ GameRepository: Loaded ${companies.length} companies');
      return Right(companies);

    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to load companies'));
    }
  }

  @override
  Future<Either<Failure, List<Website>>> getGameWebsites(List<int> gameIds) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      print('🌐 GameRepository: Getting websites for ${gameIds.length} games');

      final websites = await igdbDataSource.getWebsites(gameIds);

      print('✅ GameRepository: Loaded ${websites.length} websites');
      return Right(websites);

    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to load game websites'));
    }
  }

  @override
  Future<Either<Failure, List<AgeRating>>> getGameAgeRatings(List<int> gameIds) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      print('🔞 GameRepository: Getting age ratings for ${gameIds.length} games');

      final ageRatings = await igdbDataSource.getAgeRatings(gameIds);

      print('✅ GameRepository: Loaded ${ageRatings.length} age ratings');
      return Right(ageRatings);

    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to load age ratings'));
    }
  }

  // ==========================================
  // RELATED GAMES - Enhanced Methods
  // ==========================================

  @override
  Future<Either<Failure, List<Game>>> getSimilarGames(int gameId) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      print('🔄 GameRepository: Getting similar games for game ID: $gameId');

      final similarGames = await igdbDataSource.getSimilarGames(gameId);
      final enrichedGames = await _enrichGamesWithUserData(similarGames);

      print('✅ GameRepository: Loaded ${enrichedGames.length} similar games');
      return Right(enrichedGames);

    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to load similar games'));
    }
  }

  @override
  Future<Either<Failure, List<Game>>> getGameDLCs(int gameId) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      print('📦 GameRepository: Getting DLCs for game ID: $gameId');

      final dlcs = await igdbDataSource.getGameDLCs(gameId);
      final enrichedDLCs = await _enrichGamesWithUserData(dlcs);

      print('✅ GameRepository: Loaded ${enrichedDLCs.length} DLCs');
      return Right(enrichedDLCs);

    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to load game DLCs'));
    }
  }

  @override
  Future<Either<Failure, List<Game>>> getGameExpansions(int gameId) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      print('🚀 GameRepository: Getting expansions for game ID: $gameId');

      final expansions = await igdbDataSource.getGameExpansions(gameId);
      final enrichedExpansions = await _enrichGamesWithUserData(expansions);

      print('✅ GameRepository: Loaded ${enrichedExpansions.length} expansions');
      return Right(enrichedExpansions);

    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to load game expansions'));
    }
  }

  // ==========================================
  // USER-SPECIFIC METHODS - Enhanced
  // ==========================================

  @override
  Future<Either<Failure, List<Game>>> getUserWishlist(String userId, int limit, int offset) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      print('❤️ GameRepository: Getting wishlist for user: $userId');

      // Get wishlist game IDs from Supabase
      final gameIds = await supabaseDataSource.getUserWishlistIds(userId);

      if (gameIds.isEmpty) {
        return const Right([]);
      }

      // Apply pagination to IDs
      final paginatedIds = gameIds.skip(offset).take(limit).toList();

      // Get enhanced game data
      final games = await igdbDataSource.getGamesByIds(paginatedIds);
      final enrichedGames = await _enrichGamesWithUserData(games);

      print('✅ GameRepository: Loaded ${enrichedGames.length} wishlist games');
      return Right(enrichedGames);

    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to load wishlist'));
    }
  }

  @override
  Future<Either<Failure, List<Game>>> getUserRecommendations(String userId, int limit, int offset) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      print('⭐ GameRepository: Getting recommendations for user: $userId');

      // Get recommended game IDs from Supabase
      final gameIds = await supabaseDataSource.getUserRecommendedIds(userId);

      if (gameIds.isEmpty) {
        return const Right([]);
      }

      // Apply pagination to IDs
      final paginatedIds = gameIds.skip(offset).take(limit).toList();

      // Get enhanced game data
      final games = await igdbDataSource.getGamesByIds(paginatedIds);
      final enrichedGames = await _enrichGamesWithUserData(games);

      print('✅ GameRepository: Loaded ${enrichedGames.length} recommended games');
      return Right(enrichedGames);

    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to load recommendations'));
    }
  }

  @override
  Future<Either<Failure, List<Game>>> getUserRated(String userId, int limit, int offset) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      print('⭐ GameRepository: Getting rated games for user: $userId');

      // Get rated game IDs from Supabase
      final gameIds = await supabaseDataSource.getUserRatedIds(userId);

      if (gameIds.isEmpty) {
        return const Right([]);
      }

      // Apply pagination to IDs
      final paginatedIds = gameIds.skip(offset).take(limit).toList();

      // Get enhanced game data
      final games = await igdbDataSource.getGamesByIds(paginatedIds);
      final enrichedGames = await _enrichGamesWithUserData(games);

      print('✅ GameRepository: Loaded ${enrichedGames.length} rated games');
      return Right(enrichedGames);

    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to load rated games'));
    }
  }

  @override
  Future<Either<Failure, List<Game>>> getUserTopThreeGames(String userId) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      // Get raw data from Supabase
      final topThreeData = await supabaseDataSource.getUserTopThreeGames(userId: userId);

      if (topThreeData.isEmpty) {
        return const Right([]);
      }

      // Extract game IDs
      final gameIds = topThreeData.map<int>((data) => data['game_id'] as int).toList();

      // Get game details from IGDB
      final games = await igdbDataSource.getGamesByIds(gameIds);

      // Create position map for sorting
      final positionMap = <int, int>{};
      for (final data in topThreeData) {
        positionMap[data['game_id'] as int] = data['position'] as int;
      }

      // Enrich with user data
      final enrichedGames = await _enrichGamesWithUserData(games);

      // Sort by position
      enrichedGames.sort((a, b) {
        final posA = positionMap[a.id] ?? 999;
        final posB = positionMap[b.id] ?? 999;
        return posA.compareTo(posB);
      });

      return Right(enrichedGames);

    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to load top 3 games'));
    }
  }

  // ==========================================
  // USER ACTIONS - Enhanced
  // ==========================================

  @override
  Future<Either<Failure, void>> rateGame(int gameId, String userId, double rating) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      print('⭐ GameRepository: Rating game $gameId with $rating stars');

      await supabaseDataSource.rateGame(gameId, userId, rating);

      // Invalidate cache for this game to refresh data
      await localDataSource.clearCachedGameDetails(gameId);

      print('✅ GameRepository: Game rated successfully');
      return const Right(null);

    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to rate game'));
    }
  }

  @override
  Future<Either<Failure, void>> toggleWishlist(int gameId, String userId) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      print('❤️ GameRepository: Toggling wishlist for game: $gameId');

      await supabaseDataSource.toggleWishlist(gameId, userId);

      // Invalidate cache for this game to refresh data
      await localDataSource.clearCachedGameDetails(gameId);

      print('✅ GameRepository: Wishlist toggled successfully');
      return const Right(null);

    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to toggle wishlist'));
    }
  }

  @override
  Future<Either<Failure, void>> toggleRecommend(int gameId, String userId) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      print('⭐ GameRepository: Toggling recommendation for game: $gameId');

      await supabaseDataSource.toggleRecommended(gameId, userId);

      // Invalidate cache for this game to refresh data
      await localDataSource.clearCachedGameDetails(gameId);

      print('✅ GameRepository: Recommendation toggled successfully');
      return const Right(null);

    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to toggle recommendation'));
    }
  }

  // ==========================================
  // PHASE 1 - HOME SCREEN METHODS IMPLEMENTATION
  // ==========================================

  @override
  Future<Either<Failure, List<Game>>> getTopRatedGames(int limit, int offset) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      print('⭐ GameRepository: Getting top rated games (limit: $limit, offset: $offset)');

      // Get games sorted by total_rating, excluding those without ratings
      final topRatedGames = await igdbDataSource.getGamesSortedByRating(
          limit: limit,
          offset: offset
      );

      // Enrich with user data
      final enrichedGames = await _enrichGamesWithUserData(topRatedGames);

      print('✅ GameRepository: Loaded ${enrichedGames.length} top rated games');
      return Right(enrichedGames);

    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to load top rated games'));
    }
  }

  @override
  Future<Either<Failure, List<Game>>> getNewestGames(int limit, int offset) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      print('🆕 GameRepository: Getting newest games (limit: $limit, offset: $offset)');

      // Get games sorted by release date (most recent first)
      final newestGames = await igdbDataSource.getGamesSortedByReleaseDate(
          limit: limit,
          offset: offset
      );

      // Enrich with user data
      final enrichedGames = await _enrichGamesWithUserData(newestGames);

      print('✅ GameRepository: Loaded ${enrichedGames.length} newest games');
      return Right(enrichedGames);

    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to load newest games'));
    }
  }

  @override
  Future<Either<Failure, List<Game>>> getWishlistRecentReleases(
      String userId,
      {DateTime? fromDate, DateTime? toDate}
      ) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      // Default date range: 1 month ago to 2 weeks from now
      final now = DateTime.now();
      fromDate ??= now.subtract(const Duration(days: 30));
      toDate ??= now.add(const Duration(days: 14));

      print('❤️ GameRepository: Getting wishlist recent releases for user: $userId');
      print('📅 GameRepository: Date range: ${fromDate.toString()} to ${toDate.toString()}');

      // Get user's wishlist game IDs
      final wishlistIds = await supabaseDataSource.getUserWishlistIds(userId);

      if (wishlistIds.isEmpty) {
        return const Right([]);
      }

      // Get wishlist games with release dates in the specified range
      final recentReleases = await igdbDataSource.getGamesByReleaseDateRange(
          gameIds: wishlistIds,
          fromDate: fromDate,
          toDate: toDate
      );

      // Enrich with user data
      final enrichedGames = await _enrichGamesWithUserData(recentReleases);

      print('✅ GameRepository: Found ${enrichedGames.length} wishlist games with recent/upcoming releases');
      return Right(enrichedGames);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to load wishlist recent releases'));
    }
  }

  // ==========================================
  // PHASE 2 - ENHANCED SEARCH & FILTERING
  // ==========================================

  @override
  Future<Either<Failure, List<Game>>> searchGamesWithFilters({
    required String query,
    required SearchFilters filters,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure(
            message: 'No internet connection. Please check your network.'
        ));
      }

      print('🔍 GameRepository: Enhanced search for: "$query" with filters');
      print('📊 GameRepository: Genres: ${filters.genreIds}, Platforms: ${filters.platformIds}');

      final searchResults = await igdbDataSource.searchGamesWithFilters(
        query: query,
        filters: filters,
        limit: limit,
        offset: offset,
      );

      // Enrich with user data
      final enrichedResults = await _enrichGamesWithUserData(searchResults);

      print('✅ GameRepository: Enhanced search completed - found ${enrichedResults.length} results');
      return Right(enrichedResults);

    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to search games with filters'));
    }
  }

  @override
  Future<Either<Failure, List<Game>>> getGamesByGenre({
    required List<int> genreIds,
    int limit = 20,
    int offset = 0,
    GameSortBy sortBy = GameSortBy.popularity,
    SortOrder sortOrder = SortOrder.descending,
  }) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      if (genreIds.isEmpty) {
        return const Right([]);
      }

      print('🎨 GameRepository: Getting games by genres: $genreIds');

      final games = await igdbDataSource.getGamesByGenres(
        genreIds: genreIds,
        limit: limit,
        offset: offset,
        sortBy: sortBy.igdbField,
        sortOrder: sortOrder.value,
      );

      final enrichedGames = await _enrichGamesWithUserData(games);

      print('✅ GameRepository: Found ${enrichedGames.length} games for genres');
      return Right(enrichedGames);

    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get games by genre'));
    }
  }

  @override
  Future<Either<Failure, List<Game>>> getGamesByPlatform({
    required List<int> platformIds,
    int limit = 20,
    int offset = 0,
    GameSortBy sortBy = GameSortBy.popularity,
    SortOrder sortOrder = SortOrder.descending,
  }) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      if (platformIds.isEmpty) {
        return const Right([]);
      }

      print('🎮 GameRepository: Getting games by platforms: $platformIds');

      final games = await igdbDataSource.getGamesByPlatforms(
        platformIds: platformIds,
        limit: limit,
        offset: offset,
        sortBy: sortBy.igdbField,
        sortOrder: sortOrder.value,
      );

      final enrichedGames = await _enrichGamesWithUserData(games);

      print('✅ GameRepository: Found ${enrichedGames.length} games for platforms');
      return Right(enrichedGames);

    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get games by platform'));
    }
  }

  @override
  Future<Either<Failure, List<Game>>> getGamesByReleaseYear({
    required int fromYear,
    required int toYear,
    int limit = 20,
    int offset = 0,
    GameSortBy sortBy = GameSortBy.releaseDate,
    SortOrder sortOrder = SortOrder.descending,
  }) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      print('📅 GameRepository: Getting games from $fromYear to $toYear');

      final games = await igdbDataSource.getGamesByYearRange(
        fromYear: fromYear,
        toYear: toYear,
        limit: limit,
        offset: offset,
        sortBy: sortBy.igdbField,
        sortOrder: sortOrder.value,
      );

      final enrichedGames = await _enrichGamesWithUserData(games);

      print('✅ GameRepository: Found ${enrichedGames.length} games for year range');
      return Right(enrichedGames);

    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get games by release year'));
    }
  }

  @override
  Future<Either<Failure, List<Game>>> getGamesByRatingRange({
    required double minRating,
    required double maxRating,
    int limit = 20,
    int offset = 0,
    GameSortBy sortBy = GameSortBy.rating,
    SortOrder sortOrder = SortOrder.descending,
  }) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      print('⭐ GameRepository: Getting games with rating $minRating-$maxRating');

      final games = await igdbDataSource.getGamesByRatingRange(
        minRating: minRating,
        maxRating: maxRating,
        limit: limit,
        offset: offset,
        sortBy: sortBy.igdbField,
        sortOrder: sortOrder.value,
      );

      final enrichedGames = await _enrichGamesWithUserData(games);

      print('✅ GameRepository: Found ${enrichedGames.length} games for rating range');
      return Right(enrichedGames);

    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get games by rating range'));
    }
  }

  @override
  Future<Either<Failure, List<Genre>>> getAllGenres() async {
    try {
      // Check cache first
      final cachedGenres = await localDataSource.getCachedGenres();
      if (cachedGenres != null && cachedGenres.isNotEmpty) {
        print('🎨 GameRepository: Found cached genres');
        return Right(cachedGenres);
      }

      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      print('🎨 GameRepository: Fetching all genres');

      final genres = await igdbDataSource.getAllGenres();

      // Cache genres for future use
      await localDataSource.cacheGenres(genres);

      print('✅ GameRepository: Loaded ${genres.length} genres');
      return Right(genres);

    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get genres'));
    }
  }

  @override
  Future<Either<Failure, List<Platform>>> getAllPlatforms() async {
    try {
      // Check cache first
      final cachedPlatforms = await localDataSource.getCachedPlatforms();
      if (cachedPlatforms != null && cachedPlatforms.isNotEmpty) {
        print('🎮 GameRepository: Found cached platforms');
        return Right(cachedPlatforms);
      }

      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      print('🎮 GameRepository: Fetching all platforms');

      final platforms = await igdbDataSource.getAllPlatforms();

      // Cache platforms for future use
      await localDataSource.cachePlatforms(platforms);

      print('✅ GameRepository: Loaded ${platforms.length} platforms');
      return Right(platforms);

    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get platforms'));
    }
  }

  @override
  Future<Either<Failure, List<Game>>> getFilteredGames({
    required SearchFilters filters,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      print('🔍 GameRepository: Getting filtered games');
      print('📊 GameRepository: Active filters: ${filters.hasFilters ? 'Yes' : 'No'}');

      final games = await igdbDataSource.getFilteredGames(
        filters: filters,
        limit: limit,
        offset: offset,
      );

      final enrichedGames = await _enrichGamesWithUserData(games);

      print('✅ GameRepository: Found ${enrichedGames.length} filtered games');
      return Right(enrichedGames);

    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get filtered games'));
    }
  }

  @override
  Future<Either<Failure, List<Game>>> advancedGameSearch({
    String? textQuery,
    required SearchFilters filters,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      print('🔍 GameRepository: Advanced search - Query: "${textQuery ?? 'None'}"');

      final games = await igdbDataSource.searchGamesWithFilters(
        query: textQuery ?? '',
        filters: filters,
        limit: limit,
        offset: offset,
      );

      final enrichedGames = await _enrichGamesWithUserData(games);

      print('✅ GameRepository: Advanced search found ${enrichedGames.length} games');
      return Right(enrichedGames);

    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to perform advanced search'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getSearchSuggestions(String partialQuery) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      if (partialQuery.length < 2) {
        return const Right([]);
      }

      print('💡 GameRepository: Getting search suggestions for: "$partialQuery"');

      final suggestions = await igdbDataSource.getSearchSuggestions(partialQuery);

      print('✅ GameRepository: Found ${suggestions.length} search suggestions');
      return Right(suggestions);

    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get search suggestions'));
    }
  }

  @override
  Future<Either<Failure, List<Game>>> getRecentSearches(String userId, {int limit = 10}) async {
    try {
      print('📝 GameRepository: Getting recent searches for user: $userId');

      // Get recent search queries from Supabase
      final recentQueries = await supabaseDataSource.getRecentSearchQueries(userId, limit: limit);

      if (recentQueries.isEmpty) {
        return const Right([]);
      }

      // For now, return games from the most recent search
      // In a full implementation, you might store actual game IDs
      final mostRecentQuery = recentQueries.first;
      final searchResult = await searchGames(mostRecentQuery, limit, 0);

      return searchResult;

    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get recent searches'));
    }
  }

  @override
  Future<Either<Failure, void>> saveSearchQuery(String userId, String query) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      print('💾 GameRepository: Saving search query for user: $userId');

      await supabaseDataSource.saveSearchQuery(userId, query);

      print('✅ GameRepository: Search query saved successfully');
      return const Right(null);

    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to save search query'));
    }
  }

  // ==========================================
  // PHASE 3 - ENHANCED USER COLLECTIONS IMPLEMENTATION
  // ==========================================

  @override
  Future<Either<Failure, List<Game>>> getUserWishlistWithFilters({
    required String userId,
    required UserCollectionFilters filters,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      print('❤️ GameRepository: Getting filtered wishlist for user: $userId');
      print('📊 GameRepository: Filters active: ${filters.hasFilters}');

      // Get wishlist data from Supabase with basic filters
      final wishlistData = await supabaseDataSource.getUserWishlistWithFilters(
        userId: userId,
        filters: filters,
        limit: limit * 2, // Get more to handle post-filtering
        offset: offset,
      );

      if (wishlistData.isEmpty) {
        return const Right([]);
      }

      // Extract game IDs
      final gameIds = wishlistData.map((item) => item['game_id'] as int).toList();

      // Get full game data from IGDB
      final games = await igdbDataSource.getGamesByIds(gameIds);

      // Apply complex filters that require IGDB data
      var filteredGames = _applyComplexFilters(games, filters);

      // Apply sorting that requires IGDB data
      filteredGames = _applySorting(filteredGames, filters.sortBy, filters.sortOrder);

      // Apply final pagination after filtering
      final paginatedGames = filteredGames.skip(offset).take(limit).toList();

      // Enrich with user data
      final enrichedGames = await _enrichGamesWithUserData(paginatedGames);

      print('✅ GameRepository: Loaded ${enrichedGames.length} filtered wishlist games');
      return Right(enrichedGames);

    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get filtered wishlist'));
    }
  }

  @override
  Future<Either<Failure, List<Game>>> getUserRatedGamesWithFilters({
    required String userId,
    required UserCollectionFilters filters,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      print('⭐ GameRepository: Getting filtered rated games for user: $userId');

      // Get rated games data from Supabase
      final ratedData = await supabaseDataSource.getUserRatedGamesWithFilters(
        userId: userId,
        filters: filters,
        limit: limit * 2,
        offset: offset,
      );

      if (ratedData.isEmpty) {
        return const Right([]);
      }

      // Extract game IDs and user ratings
      final gameIds = ratedData.map((item) => item['game_id'] as int).toList();
      final userRatings = <int, double>{};
      for (final item in ratedData) {
        userRatings[item['game_id'] as int] = (item['rating'] as num).toDouble();
      }

      // Get full game data from IGDB
      final games = await igdbDataSource.getGamesByIds(gameIds);

      // Apply complex filters
      var filteredGames = _applyComplexFilters(games, filters);

      // Apply user rating filters
      if (filters.hasUserRatingFilter) {
        filteredGames = filteredGames.where((game) {
          final userRating = userRatings[game.id];
          if (userRating == null) return false;

          if (filters.minUserRating != null && userRating < filters.minUserRating!) {
            return false;
          }
          if (filters.maxUserRating != null && userRating > filters.maxUserRating!) {
            return false;
          }
          return true;
        }).toList();
      }

      // Apply sorting
      filteredGames = _applySorting(filteredGames, filters.sortBy, filters.sortOrder, userRatings);

      // Apply pagination
      final paginatedGames = filteredGames.skip(offset).take(limit).toList();

      // Enrich with user data
      final enrichedGames = await _enrichGamesWithUserData(paginatedGames);

      print('✅ GameRepository: Loaded ${enrichedGames.length} filtered rated games');
      return Right(enrichedGames);

    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get filtered rated games'));
    }
  }

  @override
  Future<Either<Failure, List<Game>>> getUserRecommendedGamesWithFilters({
    required String userId,
    required UserCollectionFilters filters,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      print('👍 GameRepository: Getting filtered recommended games for user: $userId');

      // Get recommended games data from Supabase
      final recommendedData = await supabaseDataSource.getUserRecommendedGamesWithFilters(
        userId: userId,
        filters: filters,
        limit: limit * 2,
        offset: offset,
      );

      if (recommendedData.isEmpty) {
        return const Right([]);
      }

      // Extract game IDs
      final gameIds = recommendedData.map((item) => item['game_id'] as int).toList();

      // Get full game data from IGDB
      final games = await igdbDataSource.getGamesByIds(gameIds);

      // Apply complex filters and sorting
      var filteredGames = _applyComplexFilters(games, filters);
      filteredGames = _applySorting(filteredGames, filters.sortBy, filters.sortOrder);

      // Apply pagination
      final paginatedGames = filteredGames.skip(offset).take(limit).toList();

      // Enrich with user data
      final enrichedGames = await _enrichGamesWithUserData(paginatedGames);

      print('✅ GameRepository: Loaded ${enrichedGames.length} filtered recommended games');
      return Right(enrichedGames);

    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get filtered recommended games'));
    }
  }

  @override
  Future<Either<Failure, UserCollectionSummary>> getUserCollectionSummary({
    required String userId,
    required UserCollectionType collectionType,
  }) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      print('📊 GameRepository: Getting collection summary for ${collectionType.displayName}');

      // Get statistics from Supabase
      final stats = await supabaseDataSource.getUserCollectionStatistics(
        userId: userId,
        collectionType: collectionType,
      );

      // Build collection summary
      final summary = UserCollectionSummary(
        type: collectionType,
        totalCount: stats['total_count'] ?? 0,
        averageRating: (stats['average_rating'] as num?)?.toDouble(),
        averageGameRating: (stats['average_game_rating'] as num?)?.toDouble(),
        genreBreakdown: Map<String, int>.from(stats['genre_breakdown'] ?? {}),
        platformBreakdown: Map<String, int>.from(stats['platform_breakdown'] ?? {}),
        yearBreakdown: Map<int, int>.from(stats['year_breakdown'] ?? {}),
        recentlyAddedCount: stats['recently_added_count'] ?? 0,
        lastUpdated: DateTime.tryParse(stats['last_updated'] ?? ''),
      );

      print('✅ GameRepository: Collection summary loaded');
      return Right(summary);

    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get collection summary'));
    }
  }

  @override
  Future<Either<Failure, Map<UserCollectionType, List<Game>>>> getAllUserCollections({
    required String userId,
    int limitPerCollection = 10,
  }) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      print('🏠 GameRepository: Getting all user collections overview');

      // Execute all collection requests concurrently - FIX: Use direct repository methods
      final results = await Future.wait([
        getUserWishlist(userId, limitPerCollection, 0),
        getUserRated(userId, limitPerCollection, 0),
        getUserRecommendations(userId, limitPerCollection, 0),
        getUserTopThreeGames(userId),
      ]);

      // Check if any request failed
      for (final result in results) {
        if (result.isLeft()) {
          return result.fold(
                (failure) => Left(failure),
                (data) => throw Exception('Unexpected success'),
          );
        }
      }

      // Extract successful results
      final wishlist = results[0].fold((l) => <Game>[], (r) => r as List<Game>);
      final rated = results[1].fold((l) => <Game>[], (r) => r as List<Game>);
      final recommended = results[2].fold((l) => <Game>[], (r) => r as List<Game>);
      final topThree = results[3].fold((l) => <Game>[], (r) => r as List<Game>);

      final collections = {
        UserCollectionType.wishlist: wishlist,
        UserCollectionType.rated: rated,
        UserCollectionType.recommended: recommended,
        UserCollectionType.topThree: topThree,
      };

      print('✅ GameRepository: All user collections loaded');
      return Right(collections);

    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get all user collections'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getUserGamingStatistics(String userId) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      print('📈 GameRepository: Getting gaming statistics for user: $userId');

      final stats = await supabaseDataSource.getUserGamingStatistics(userId);

      print('✅ GameRepository: Gaming statistics loaded');
      return Right(stats);

    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get gaming statistics'));
    }
  }

  // ==========================================
  // BATCH OPERATIONS
  // ==========================================

  @override
  Future<Either<Failure, void>> batchAddToWishlist({
    required String userId,
    required List<int> gameIds,
  }) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      print('❤️ GameRepository: Batch adding ${gameIds.length} games to wishlist');

      await supabaseDataSource.batchAddToWishlist(userId, gameIds);

      // Clear relevant caches
      for (final gameId in gameIds) {
        await localDataSource.clearCachedGameDetails(gameId);
      }

      print('✅ GameRepository: Batch wishlist operation completed');
      return const Right(null);

    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to batch add to wishlist'));
    }
  }

  @override
  Future<Either<Failure, void>> batchRateGames({
    required String userId,
    required Map<int, double> gameRatings,
  }) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      print('⭐ GameRepository: Batch rating ${gameRatings.length} games');

      await supabaseDataSource.batchRateGames(userId, gameRatings);

      // Clear relevant caches
      for (final gameId in gameRatings.keys) {
        await localDataSource.clearCachedGameDetails(gameId);
      }

      print('✅ GameRepository: Batch rating operation completed');
      return const Right(null);

    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to batch rate games'));
    }
  }

  // ==========================================
  // PHASE 4 - GAME DETAIL ENHANCEMENTS IMPLEMENTATION
  // ==========================================

  @override
  Future<Either<Failure, List<Character>>> getGameCharacters(int gameId) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      print('🎭 GameRepository: Getting characters for game: $gameId');

      final characters = await igdbDataSource.getCharactersForGames([gameId]);

      print('✅ GameRepository: Found ${characters.length} characters');
      return Right(characters);

    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get game characters'));
    }
  }

  @override
  Future<Either<Failure, List<Event>>> getGameEvents(int gameId) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      print('🎪 GameRepository: Getting events for game: $gameId');

      final events = await igdbDataSource.getEventsByGames([gameId]);

      print('✅ GameRepository: Found ${events.length} events');
      return Right(events);

    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get game events'));
    }
  }

  @override
  Future<Either<Failure, List<GameVideo>>> getGameVideos(int gameId) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      print('🎥 GameRepository: Getting videos for game: $gameId');

      final videos = await igdbDataSource.getGameVideos([gameId]);

      print('✅ GameRepository: Found ${videos.length} videos');
      return Right(videos);

    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get game videos'));
    }
  }

  @override
  Future<Either<Failure, List<Screenshot>>> getGameScreenshots(int gameId) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      print('📸 GameRepository: Getting screenshots for game: $gameId');

      final screenshots = await igdbDataSource.getScreenshots(gameIds: [gameId]);

      print('✅ GameRepository: Found ${screenshots.length} screenshots');
      return Right(screenshots);

    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get game screenshots'));
    }
  }

  @override
  Future<Either<Failure, List<Artwork>>> getGameArtwork(int gameId) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      print('🎨 GameRepository: Getting artwork for game: $gameId');

      final artworks = await igdbDataSource.getArtworks(gameIds: [gameId]);

      print('✅ GameRepository: Found ${artworks.length} artworks');
      return Right(artworks);

    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get game artwork'));
    }
  }

  @override
  Future<Either<Failure, GameMediaCollection>> getGameMediaCollection(int gameId) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      print('📱 GameRepository: Getting complete media collection for game: $gameId');

      // Execute all media requests concurrently for better performance
      final results = await Future.wait([
        igdbDataSource.getGameVideos([gameId]),
        igdbDataSource.getScreenshots(gameIds: [gameId]),
        igdbDataSource.getArtworks(gameIds: [gameId]),
      ]);

      final videos = results[0] as List<GameVideo>;
      final screenshots = results[1] as List<Screenshot>;
      final artworks = results[2] as List<Artwork>;

      final mediaCollection = GameMediaCollection(
        gameId: gameId,
        videos: videos,
        screenshots: screenshots,
        artworks: artworks,
      );

      print('✅ GameRepository: Media collection loaded - ${mediaCollection.totalMediaCount} total items');
      return Right(mediaCollection);

    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get game media collection'));
    }
  }

  @override
  Future<Either<Failure, Game>> getEnhancedGameDetails({
    required int gameId,
    String? userId,
    bool includeCharacters = true,
    bool includeEvents = true,
    bool includeMedia = true,
  }) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      print('🎮 GameRepository: Getting enhanced game details for: $gameId');
      print('🔍 GameRepository: Include - Characters: $includeCharacters, Events: $includeEvents, Media: $includeMedia');

      // Start with complete game details
      final gameResult = await getCompleteGameDetails(gameId, userId);
      if (gameResult.isLeft()) {
        return gameResult;
      }

      final game = gameResult.fold((l) => throw Exception('Unexpected failure'), (r) => r);

      // Collect additional requests based on flags
      final futures = <Future>[];

      if (includeCharacters) {
        futures.add(igdbDataSource.getCharactersForGames([gameId]));
      }

      if (includeEvents) {
        futures.add(igdbDataSource.getEventsByGames([gameId]));
      }

      if (includeMedia) {
        futures.addAll([
          igdbDataSource.getGameVideos([gameId]),
          igdbDataSource.getScreenshots(gameIds: [gameId]),
          igdbDataSource.getArtworks(gameIds: [gameId]),
        ]);
      }

      // Execute all additional requests concurrently
      final results = futures.isNotEmpty ? await Future.wait(futures) : [];

      // Parse results based on what was requested
      int resultIndex = 0;
      List<Character> characters = [];
      List<Event> events = [];
      List<GameVideo> videos = [];
      List<Screenshot> screenshots = [];
      List<Artwork> artworks = [];

      if (includeCharacters) {
        characters = results[resultIndex++] as List<Character>;
      }

      if (includeEvents) {
        events = results[resultIndex++] as List<Event>;
      }

      if (includeMedia) {
        videos = results[resultIndex++] as List<GameVideo>;
        screenshots = results[resultIndex++] as List<Screenshot>;
        artworks = results[resultIndex++] as List<Artwork>;
      }

      // Create enhanced game with additional data
      final enhancedGame = game.copyWith(
        characters: characters,
        events: events,
        videos: videos,
        screenshots: screenshots,
        artworks: artworks,
      );

      print('✅ GameRepository: Enhanced game details loaded');
      print('📊 GameRepository: ${characters.length} characters, ${events.length} events, ${videos.length + screenshots.length + artworks.length} media items');

      return Right(enhancedGame);

    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get enhanced game details'));
    }
  }

  // ==========================================
  // CHARACTER DISCOVERY & SEARCH
  // ==========================================

  @override
  Future<Either<Failure, List<Character>>> searchCharacters(String query) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      print('🔍 GameRepository: Searching characters for: "$query"');

      final characters = await igdbDataSource.searchCharacters(query);

      print('✅ GameRepository: Found ${characters.length} characters');
      return Right(characters);

    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to search characters'));
    }
  }

  @override
  Future<Either<Failure, List<Character>>> getPopularCharacters({int limit = 20}) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      print('⭐ GameRepository: Getting popular characters (limit: $limit)');

      final characters = await igdbDataSource.getPopularCharacters(limit: limit);

      print('✅ GameRepository: Found ${characters.length} popular characters');
      return Right(characters);

    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get popular characters'));
    }
  }

  @override
  Future<Either<Failure, List<Character>>> getCharactersByGender(CharacterGenderEnum gender) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      print('👤 GameRepository: Getting ${gender.displayName} characters');

      // Convert enum to IGDB enum - FIX: Use proper conversion
      final igdbGender = CharacterGenderEnum.fromValue(gender.value);
      final characters = await igdbDataSource.getCharactersByGender(igdbGender);

      print('✅ GameRepository: Found ${characters.length} ${gender.displayName} characters');
      return Right(characters);

    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get characters by gender'));
    }
  }

  @override
  Future<Either<Failure, List<Character>>> getCharactersBySpecies(CharacterSpeciesEnum species) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      print('🧬 GameRepository: Getting ${species.displayName} characters');

      // Convert enum to IGDB enum - FIX: Use proper conversion
      final igdbSpecies = CharacterSpeciesEnum.fromValue(species.value);
      final characters = await igdbDataSource.getCharactersBySpecies(igdbSpecies);

      print('✅ GameRepository: Found ${characters.length} ${species.displayName} characters');
      return Right(characters);

    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get characters by species'));
    }
  }

  @override
  Future<Either<Failure, Character>> getCharacterDetails(int characterId) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      print('🎭 GameRepository: Getting character details for: $characterId');

      final characters = await igdbDataSource.getCharacters(ids: [characterId]);

      if (characters.isEmpty) {
        return const Left(NotFoundFailure(message: 'Character not found'));
      }

      print('✅ GameRepository: Character details loaded');
      return Right(characters.first);

    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get character details'));
    }
  }

  @override
  Future<Either<Failure, List<Game>>> getGamesByCharacter(int characterId) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      print('🎮 GameRepository: Getting games for character: $characterId');

      // First get character to extract game IDs
      final character = await getCharacterDetails(characterId);
      if (character.isLeft()) {
        return character.fold((failure) => Left(failure), (char) => throw Exception('Unexpected success'));
      }

      final characterData = character.fold((l) => throw Exception('Unexpected failure'), (r) => r);
      final gameIds = characterData.gameIds;

      if (gameIds.isEmpty) {
        return const Right([]);
      }

      // Get full game data
      final games = await igdbDataSource.getGamesByIds(gameIds);
      final enrichedGames = await _enrichGamesWithUserData(games);

      print('✅ GameRepository: Found ${enrichedGames.length} games for character');
      return Right(enrichedGames);

    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get games by character'));
    }
  }

  // ==========================================
  // EVENT DISCOVERY
  // ==========================================

  @override
  Future<Either<Failure, List<Event>>> searchEvents(String query) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      print('🔍 GameRepository: Searching events for: "$query"');

      final events = await igdbDataSource.searchEvents(query);

      print('✅ GameRepository: Found ${events.length} events');
      return Right(events);

    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to search events'));
    }
  }

  @override
  Future<Either<Failure, Event>> getEventDetails(int eventId) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      print('🎪 GameRepository: Getting event details for: $eventId');

      final event = await igdbDataSource.getEventById(eventId);

      if (event == null) {
        return const Left(NotFoundFailure(message: 'Event not found'));
      }

      print('✅ GameRepository: Event details loaded');
      return Right(event);

    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get event details'));
    }
  }

  @override
  Future<Either<Failure, List<Game>>> getEventGames(int eventId) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      print('🎮 GameRepository: Getting games for event: $eventId');

      // First get event to extract game IDs
      final event = await getEventDetails(eventId);
      if (event.isLeft()) {
        return event.fold((failure) => Left(failure), (evt) => throw Exception('Unexpected success'));
      }

      final eventData = event.fold((l) => throw Exception('Unexpected failure'), (r) => r);
      final gameIds = eventData.gameIds;

      if (gameIds.isEmpty) {
        return const Right([]);
      }

      // Get full game data
      final games = await igdbDataSource.getGamesByIds(gameIds);
      final enrichedGames = await _enrichGamesWithUserData(games);

      print('✅ GameRepository: Found ${enrichedGames.length} games for event');
      return Right(enrichedGames);

    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get event games'));
    }
  }

  // ==========================================
  // MEDIA MANAGEMENT
  // ==========================================

  @override
  Future<Either<Failure, GameVideo>> getVideoDetails(int videoId) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      print('🎥 GameRepository: Getting video details for: $videoId');

      final videos = await igdbDataSource.getGameVideos([videoId]);

      if (videos.isEmpty) {
        return const Left(NotFoundFailure(message: 'Video not found'));
      }

      print('✅ GameRepository: Video details loaded');
      return Right(videos.first);

    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get video details'));
    }
  }

  @override
  Future<Either<Failure, Screenshot>> getScreenshotDetails(int screenshotId) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      print('📸 GameRepository: Getting screenshot details for: $screenshotId');

      final screenshots = await igdbDataSource.getScreenshots(ids: [screenshotId]);

      if (screenshots.isEmpty) {
        return const Left(NotFoundFailure(message: 'Screenshot not found'));
      }

      print('✅ GameRepository: Screenshot details loaded');
      return Right(screenshots.first);

    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get screenshot details'));
    }
  }

  @override
  Future<Either<Failure, Artwork>> getArtworkDetails(int artworkId) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      print('🎨 GameRepository: Getting artwork details for: $artworkId');

      final artworks = await igdbDataSource.getArtworks(ids: [artworkId]);

      if (artworks.isEmpty) {
        return const Left(NotFoundFailure(message: 'Artwork not found'));
      }

      print('✅ GameRepository: Artwork details loaded');
      return Right(artworks.first);

    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get artwork details'));
    }
  }

  @override
  Future<Either<Failure, Map<int, GameMediaCollection>>> getBatchGameMedia(List<int> gameIds) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      if (gameIds.isEmpty) {
        return const Right({});
      }

      print('📱 GameRepository: Getting batch media for ${gameIds.length} games');

      // Get media for all games concurrently
      final results = await Future.wait([
        igdbDataSource.getGameVideos(gameIds),
        igdbDataSource.getScreenshots(gameIds: gameIds),
        igdbDataSource.getArtworks(gameIds: gameIds),
      ]);

      final allVideos = results[0] as List<GameVideo>;
      final allScreenshots = results[1] as List<Screenshot>;
      final allArtworks = results[2] as List<Artwork>;

      // Group media by game ID
      final mediaCollections = <int, GameMediaCollection>{};

      for (final gameId in gameIds) {
        final gameVideos = allVideos.where((v) => v.id == gameId).toList();
        final gameScreenshots = allScreenshots.where((s) => s.gameId == gameId).toList();
        final gameArtworks = allArtworks.where((a) => a.gameId == gameId).toList();

        mediaCollections[gameId] = GameMediaCollection(
          gameId: gameId,
          videos: gameVideos,
          screenshots: gameScreenshots,
          artworks: gameArtworks,
        );
      }

      print('✅ GameRepository: Batch media loaded for ${mediaCollections.length} games');
      return Right(mediaCollections);

    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get batch game media'));
    }
  }

  // ==========================================
  // HELPER METHODS - Enhanced
  // ==========================================

  Future<Game> _enrichGameWithUserData(Game game) async {
    try {
      final authBloc = GetIt.instance<AuthBloc>();

      // Check if user is authenticated
      User? currentUser;
      final authState = authBloc.state;
      if (authState is Authenticated) {
        currentUser = authState.user;
      }

      if (currentUser == null) {
        return game;
      }

      print('🔄 GameRepository: Enriching game ${game.id} with user data for ${currentUser.id}');

      // Get user-specific game data
      final userGameData = await supabaseDataSource.getUserGameData(currentUser.id, game.id);

      // Get top three games for position check
      final topThreeData = await supabaseDataSource.getUserTopThreeGames(userId: currentUser.id);
      final topThreeMap = <int, int>{};
      for (var data in topThreeData) {
        final gameId = data['game_id'] as int;
        final position = data['position'] as int;
        topThreeMap[gameId] = position;
      }

      // Return enhanced game with user data
      return game.copyWith(
        isWishlisted: userGameData?['is_wishlisted'] ?? false,
        isRecommended: userGameData?['is_recommended'] ?? false,
        userRating: userGameData?['rating']?.toDouble(),
        isInTopThree: topThreeMap.containsKey(game.id),
        topThreePosition: topThreeMap[game.id],
      );

    } catch (e) {
      print('⚠️ GameRepository: Error enriching game with user data: $e');
      return game;
    }
  }

  Future<List<Game>> _enrichGamesWithUserData(List<Game> games) async {
    try {
      if (games.isEmpty) return games;

      final authBloc = GetIt.instance<AuthBloc>();

      // Check if user is authenticated
      User? currentUser;
      final authState = authBloc.state;
      if (authState is Authenticated) {
        currentUser = authState.user;
      }

      if (currentUser == null) {
        return games;
      }

      print('🔄 GameRepository: Enriching ${games.length} games with user data');

      // Get user data for all games in batch
      final gameIds = games.map((game) => game.id).toList();
      final batchUserData = await supabaseDataSource.getBatchUserGameData(gameIds, currentUser.id);

      // Get top three games
      final topThreeData = await supabaseDataSource.getUserTopThreeGames(userId: currentUser.id);
      final topThreeMap = <int, int>{};
      for (var data in topThreeData) {
        final gameId = data['game_id'] as int;
        final position = data['position'] as int;
        topThreeMap[gameId] = position;
      }

      // Enrich each game with its user data
      final enrichedGames = games.map((game) {
        final userData = batchUserData[game.id];
        return game.copyWith(
          isWishlisted: userData?['is_wishlisted'] ?? false,
          isRecommended: userData?['is_recommended'] ?? false,
          userRating: userData?['rating']?.toDouble(),
          isInTopThree: topThreeMap.containsKey(game.id),
          topThreePosition: topThreeMap[game.id],
        );
      }).toList();

      print('✅ GameRepository: Successfully enriched ${enrichedGames.length} games with user data');
      return enrichedGames;

    } catch (e) {
      print('⚠️ GameRepository: Error enriching games with user data: $e');
      return games;
    }
  }

  /// Apply complex filters that require IGDB game data
  List<Game> _applyComplexFilters(List<Game> games, UserCollectionFilters filters) {
    var filteredGames = games;

    // Genre filter
    if (filters.hasGenreFilter) {
      filteredGames = filteredGames.where((game) {
        return game.genres.any((genre) => filters.genreIds.contains(genre.id));
      }).toList();
    }

    // Platform filter
    if (filters.hasPlatformFilter) {
      filteredGames = filteredGames.where((game) {
        return game.platforms.any((platform) => filters.platformIds.contains(platform.id));
      }).toList();
    }

    // Game rating filter
    if (filters.hasGameRatingFilter) {
      filteredGames = filteredGames.where((game) {
        final rating = game.totalRating;
        if (rating == null) return false;

        if (filters.minRating != null && rating < filters.minRating!) {
          return false;
        }
        if (filters.maxRating != null && rating > filters.maxRating!) {
          return false;
        }
        return true;
      }).toList();
    }

    // Release date filter
    if (filters.hasReleaseDateFilter) {
      filteredGames = filteredGames.where((game) {
        final releaseDate = game.firstReleaseDate;
        if (releaseDate == null) return false;

        if (filters.releaseDateFrom != null && releaseDate.isBefore(filters.releaseDateFrom!)) {
          return false;
        }
        if (filters.releaseDateTo != null && releaseDate.isAfter(filters.releaseDateTo!)) {
          return false;
        }
        return true;
      }).toList();
    }

    return filteredGames;
  }

  /// Apply sorting to games list
  List<Game> _applySorting(
      List<Game> games,
      UserCollectionSortBy sortBy,
      SortOrder sortOrder,
      [Map<int, double>? userRatings]
      ) {
    final sortedGames = [...games];

    switch (sortBy) {
      case UserCollectionSortBy.name:
      case UserCollectionSortBy.alphabetical:
        sortedGames.sort((a, b) => a.name.compareTo(b.name));
        break;
      case UserCollectionSortBy.rating:
        if (userRatings != null) {
          sortedGames.sort((a, b) {
            final ratingA = userRatings[a.id] ?? 0.0;
            final ratingB = userRatings[b.id] ?? 0.0;
            return ratingA.compareTo(ratingB);
          });
        }
        break;
      case UserCollectionSortBy.gameRating:
        sortedGames.sort((a, b) {
          final ratingA = a.totalRating ?? 0.0;
          final ratingB = b.totalRating ?? 0.0;
          return ratingA.compareTo(ratingB);
        });
        break;
      case UserCollectionSortBy.releaseDate:
        sortedGames.sort((a, b) {
          final dateA = a.firstReleaseDate ?? DateTime(1970);
          final dateB = b.firstReleaseDate ?? DateTime(1970);
          return dateA.compareTo(dateB);
        });
        break;
      case UserCollectionSortBy.popularity:
        sortedGames.sort((a, b) {
          final popularityA = a.hypes ?? 0;
          final popularityB = b.hypes ?? 0;
          return popularityA.compareTo(popularityB);
        });
        break;
      default:
      // Default sorting by name
        sortedGames.sort((a, b) => a.name.compareTo(b.name));
        break;
    }

    // Apply sort order
    if (sortOrder == SortOrder.descending) {
      return sortedGames.reversed.toList();
    }

    return sortedGames;
  }



  // ==========================================
// VOLLSTÄNDIGE IMPLEMENTIERUNG ALLER FEHLENDEN METHODEN
// ==========================================

  // ==========================================
  // BATCH OPERATIONS
  // ==========================================

  @override
  Future<Either<Failure, void>> batchRemoveFromWishlist({
    required String userId,
    required List<int> gameIds,
  }) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      print('💔 GameRepository: Batch removing ${gameIds.length} games from wishlist');

      await supabaseDataSource.batchRemoveFromWishlist(userId, gameIds);

      // Clear relevant caches
      for (final gameId in gameIds) {
        await localDataSource.clearCachedGameDetails(gameId);
      }

      print('✅ GameRepository: Batch wishlist removal completed');
      return const Right(null);

    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to batch remove from wishlist'));
    }
  }

  @override
  Future<Either<Failure, void>> moveGamesBetweenCollections({
    required String userId,
    required List<int> gameIds,
    required UserCollectionType fromCollection,
    required UserCollectionType toCollection,
  }) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      print('🔄 GameRepository: Moving ${gameIds.length} games from ${fromCollection.displayName} to ${toCollection.displayName}');

      await supabaseDataSource.moveGamesBetweenCollections(
        userId: userId,
        gameIds: gameIds,
        fromCollection: fromCollection,
        toCollection: toCollection,
      );

      // Clear relevant caches
      for (final gameId in gameIds) {
        await localDataSource.clearCachedGameDetails(gameId);
      }

      print('✅ GameRepository: Games moved successfully');
      return const Right(null);

    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to move games between collections'));
    }
  }

  // ==========================================
  // USER COLLECTIONS EXTENDED
  // ==========================================

  @override
  Future<Either<Failure, Map<UserCollectionType, UserCollectionSummary>>> getAllUserCollectionSummaries(String userId) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      print('📊 GameRepository: Getting all collection summaries for user: $userId');

      // Execute all summary requests concurrently
      final results = await Future.wait([
        getUserCollectionSummary(userId: userId, collectionType: UserCollectionType.wishlist),
        getUserCollectionSummary(userId: userId, collectionType: UserCollectionType.rated),
        getUserCollectionSummary(userId: userId, collectionType: UserCollectionType.recommended),
        getUserCollectionSummary(userId: userId, collectionType: UserCollectionType.topThree),
      ]);

      // Check if any request failed
      for (final result in results) {
        if (result.isLeft()) {
          return result.fold(
                (failure) => Left(failure),
                (data) => throw Exception('Unexpected success'),
          );
        }
      }

      // Extract successful results
      final summaries = {
        UserCollectionType.wishlist: results[0].fold((l) => throw Exception('Unexpected failure'), (r) => r),
        UserCollectionType.rated: results[1].fold((l) => throw Exception('Unexpected failure'), (r) => r),
        UserCollectionType.recommended: results[2].fold((l) => throw Exception('Unexpected failure'), (r) => r),
        UserCollectionType.topThree: results[3].fold((l) => throw Exception('Unexpected failure'), (r) => r),
      };

      print('✅ GameRepository: All collection summaries loaded');
      return Right(summaries);

    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get all collection summaries'));
    }
  }

  @override
  Future<Either<Failure, List<Game>>> searchUserCollections({
    required String userId,
    required String query,
    required List<UserCollectionType> collectionTypes,
    UserCollectionFilters? filters,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      print('🔍 GameRepository: Searching user collections for: "$query"');

      // Get all game IDs from specified collections
      final allGameIds = <int>[];

      for (final collectionType in collectionTypes) {
        List<int> gameIds = [];

        switch (collectionType) {
          case UserCollectionType.wishlist:
            gameIds = await supabaseDataSource.getUserWishlistIds(userId);
            break;
          case UserCollectionType.rated:
            gameIds = await supabaseDataSource.getUserRatedIds(userId);
            break;
          case UserCollectionType.recommended:
            gameIds = await supabaseDataSource.getUserRecommendedIds(userId);
            break;
          case UserCollectionType.topThree:
            final topThreeData = await supabaseDataSource.getUserTopThreeGames(userId: userId);
            gameIds = topThreeData.map<int>((data) => data['game_id'] as int).toList();
            break;
        }

        allGameIds.addAll(gameIds);
      }

      if (allGameIds.isEmpty) {
        return const Right([]);
      }

      // Remove duplicates
      final uniqueGameIds = allGameIds.toSet().toList();

      // Get game data
      final games = await igdbDataSource.getGamesByIds(uniqueGameIds);

      // Filter by search query
      var filteredGames = games.where((game) {
        return game.name.toLowerCase().contains(query.toLowerCase()) ||
            game.summary?.toLowerCase().contains(query.toLowerCase()) == true;
      }).toList();

      // Apply additional filters if provided
      if (filters != null) {
        filteredGames = _applyComplexFilters(filteredGames, filters);
        filteredGames = _applySorting(filteredGames, filters.sortBy, filters.sortOrder);
      }

      // Apply pagination
      final paginatedGames = filteredGames.skip(offset).take(limit).toList();

      // Enrich with user data
      final enrichedGames = await _enrichGamesWithUserData(paginatedGames);

      print('✅ GameRepository: Found ${enrichedGames.length} games in user collections');
      return Right(enrichedGames);

    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to search user collections'));
    }
  }

  @override
  Future<Either<Failure, List<Game>>> getRecentlyAddedToCollections({
    required String userId,
    int days = 7,
    int limit = 20,
  }) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      print('📅 GameRepository: Getting recently added games (last $days days)');

      final cutoffDate = DateTime.now().subtract(Duration(days: days));
      final recentlyAddedData = await supabaseDataSource.getRecentlyAddedToCollections(
        userId: userId,
        sinceDate: cutoffDate,
        limit: limit,
      );

      if (recentlyAddedData.isEmpty) {
        return const Right([]);
      }

      // Extract game IDs
      final gameIds = recentlyAddedData.map<int>((data) => data['game_id'] as int).toList();

      // Get game data
      final games = await igdbDataSource.getGamesByIds(gameIds);

      // Sort by added date (most recent first)
      games.sort((a, b) {
        final addedDateA = recentlyAddedData.firstWhere((data) => data['game_id'] == a.id)['added_at'];
        final addedDateB = recentlyAddedData.firstWhere((data) => data['game_id'] == b.id)['added_at'];
        return DateTime.parse(addedDateB).compareTo(DateTime.parse(addedDateA));
      });

      // Enrich with user data
      final enrichedGames = await _enrichGamesWithUserData(games);

      print('✅ GameRepository: Found ${enrichedGames.length} recently added games');
      return Right(enrichedGames);

    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get recently added games'));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getUserTopGenres({
    required String userId,
    int limit = 10,
  }) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      print('🎨 GameRepository: Getting top genres for user: $userId');

      final topGenres = await supabaseDataSource.getUserTopGenres(userId, limit: limit);

      print('✅ GameRepository: Found ${topGenres.length} top genres');
      return Right(topGenres);

    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get user top genres'));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getUserActivityTimeline({
    required String userId,
    DateTime? fromDate,
    DateTime? toDate,
    int limit = 50,
  }) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      fromDate ??= DateTime.now().subtract(const Duration(days: 30));
      toDate ??= DateTime.now();

      print('📈 GameRepository: Getting activity timeline for user: $userId');

      final timeline = await supabaseDataSource.getUserActivityTimeline(
        userId: userId,
        fromDate: fromDate,
        toDate: toDate,
        limit: limit,
      );

      print('✅ GameRepository: Retrieved ${timeline.length} activity entries');
      return Right(timeline);

    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get user activity timeline'));
    }
  }

  // ==========================================
  // USER ANALYTICS & PREFERENCES
  // ==========================================

  @override
  Future<Either<Failure, Map<String, double>>> getUserGenrePreferences(String userId) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      print('🎯 GameRepository: Analyzing genre preferences for user: $userId');

      final preferences = await supabaseDataSource.getUserGenrePreferences(userId);

      print('✅ GameRepository: Genre preferences analyzed');
      return Right(preferences);

    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get genre preferences'));
    }
  }

  @override
  Future<Either<Failure, Map<String, int>>> getUserPlatformStatistics(String userId) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      print('🎮 GameRepository: Getting platform statistics for user: $userId');

      final statistics = await supabaseDataSource.getUserPlatformStatistics(userId);

      print('✅ GameRepository: Platform statistics retrieved');
      return Right(statistics);

    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get platform statistics'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getUserRatingAnalytics(String userId) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      print('⭐ GameRepository: Analyzing rating patterns for user: $userId');

      final analytics = await supabaseDataSource.getUserRatingAnalytics(userId);

      print('✅ GameRepository: Rating analytics completed');
      return Right(analytics);

    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get rating analytics'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getUserGamingPatterns(String userId) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      print('📊 GameRepository: Analyzing gaming patterns for user: $userId');

      final patterns = await supabaseDataSource.getUserGamingPatternAnalysis(userId);

      print('✅ GameRepository: Gaming patterns analyzed');
      return Right(patterns);

    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get gaming patterns'));
    }
  }

  // ==========================================
  // RECOMMENDATION ALGORITHMS
  // ==========================================

  @override
  Future<Either<Failure, List<Game>>> getPersonalizedRecommendations({
    required String userId,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      print('🎯 GameRepository: Getting personalized recommendations for user: $userId');

      // Get user's gaming profile and preferences
      final userProfile = await supabaseDataSource.getUserGamingProfile(userId);

      // Get user's rated games to understand preferences
      final ratedGameIds = await supabaseDataSource.getUserRatedIds(userId);
      final wishlistIds = await supabaseDataSource.getUserWishlistIds(userId);

      // Generate recommendations using multiple signals
      final recommendations = await _generateSmartRecommendations(
        userId: userId,
        userProfile: userProfile,
        ratedGameIds: ratedGameIds,
        wishlistIds: wishlistIds,
        limit: limit * 2, // Get more to filter and rank
      );

      // Apply pagination
      final paginatedRecommendations = recommendations.skip(offset).take(limit).toList();

      // Enrich with user data
      final enrichedRecommendations = await _enrichGamesWithUserData(paginatedRecommendations);

      print('✅ GameRepository: Generated ${enrichedRecommendations.length} personalized recommendations');
      return Right(enrichedRecommendations);

    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get personalized recommendations'));
    }
  }

  @override
  Future<Either<Failure, List<Game>>> getAIRecommendations({
    required String userId,
    int limit = 20,
    List<RecommendationSignal> signals = const [
      RecommendationSignal.ratings,
      RecommendationSignal.wishlist,
      RecommendationSignal.genres,
      RecommendationSignal.platforms,
      RecommendationSignal.playtime,
    ],
  }) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      print('🤖 GameRepository: Getting AI recommendations for user: $userId');
      print('📊 GameRepository: Using signals: ${signals.map((s) => s.displayName).join(', ')}');

      // Collect data for each signal
      final signalData = <RecommendationSignal, dynamic>{};

      for (final signal in signals) {
        switch (signal) {
          case RecommendationSignal.ratings:
            signalData[signal] = await supabaseDataSource.getUserRatingPatterns(userId);
            break;
          case RecommendationSignal.wishlist:
            signalData[signal] = await supabaseDataSource.getUserWishlistPatterns(userId);
            break;
          case RecommendationSignal.genres:
            signalData[signal] = await supabaseDataSource.getUserGenrePreferences(userId);
            break;
          case RecommendationSignal.platforms:
            signalData[signal] = await supabaseDataSource.getUserPlatformStatistics(userId);
            break;
          case RecommendationSignal.friends:
            signalData[signal] = await supabaseDataSource.getFriendsActivity(userId);
            break;
          case RecommendationSignal.community:
            signalData[signal] = await supabaseDataSource.getCommunityTrends();
            break;
          default:
            continue;
        }
      }

      // Generate AI-powered recommendations
      final recommendations = await _generateAIRecommendations(
        userId: userId,
        signalData: signalData,
        limit: limit,
      );

      // Enrich with user data
      final enrichedRecommendations = await _enrichGamesWithUserData(recommendations);

      print('✅ GameRepository: Generated ${enrichedRecommendations.length} AI recommendations');
      return Right(enrichedRecommendations);

    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get AI recommendations'));
    }
  }

  @override
  Future<Either<Failure, List<Game>>> getRecommendationsBasedOnRated({
    required String userId,
    int limit = 20,
  }) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      print('⭐ GameRepository: Getting recommendations based on rated games');

      // Get user's highly rated games (8+ rating)
      final ratedData = await supabaseDataSource.getUserHighlyRatedGames(userId, minRating: 8.0);

      if (ratedData.isEmpty) {
        return const Right([]);
      }

      final highlyRatedIds = ratedData.map<int>((data) => data['game_id'] as int).toList();
      final recommendations = <Game>[];

      // Get similar games for each highly rated game
      for (final gameId in highlyRatedIds.take(5)) { // Limit to top 5 to avoid too many API calls
        final similarGames = await igdbDataSource.getSimilarGames(gameId);
        recommendations.addAll(similarGames);
      }

      // Remove duplicates and already rated games
      final uniqueRecommendations = recommendations
          .where((game) => !highlyRatedIds.contains(game.id))
          .toSet()
          .toList();

      // Sort by relevance (simple scoring based on frequency)
      final gameFrequency = <int, int>{};
      for (final game in recommendations) {
        gameFrequency[game.id] = (gameFrequency[game.id] ?? 0) + 1;
      }

      uniqueRecommendations.sort((a, b) {
        final freqA = gameFrequency[a.id] ?? 0;
        final freqB = gameFrequency[b.id] ?? 0;
        return freqB.compareTo(freqA);
      });

      // Take top recommendations
      final finalRecommendations = uniqueRecommendations.take(limit).toList();

      // Enrich with user data
      final enrichedRecommendations = await _enrichGamesWithUserData(finalRecommendations);

      print('✅ GameRepository: Generated ${enrichedRecommendations.length} recommendations based on rated games');
      return Right(enrichedRecommendations);

    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get recommendations based on rated games'));
    }
  }

  @override
  Future<Either<Failure, List<Game>>> getRecommendationsBasedOnWishlist({
    required String userId,
    int limit = 20,
  }) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      print('❤️ GameRepository: Getting recommendations based on wishlist');

      // Get user's wishlist
      final wishlistIds = await supabaseDataSource.getUserWishlistIds(userId);

      if (wishlistIds.isEmpty) {
        return const Right([]);
      }

      // Get wishlist games data to analyze genres and themes
      final wishlistGames = await igdbDataSource.getGamesByIds(wishlistIds);

      // Extract preferred genres from wishlist
      final genreFrequency = <int, int>{};
      for (final game in wishlistGames) {
        for (final genre in game.genres) {
          genreFrequency[genre.id] = (genreFrequency[genre.id] ?? 0) + 1;
        }
      }

      // Get top genres
      final topGenres = genreFrequency.entries
          .where((entry) => entry.value > 1) // Genre must appear in multiple wishlist games
          .map((entry) => entry.key)
          .take(3)
          .toList();

      if (topGenres.isEmpty) {
        return const Right([]);
      }

      // Get games from preferred genres
      final recommendations = await igdbDataSource.getGamesByGenres(
        genreIds: topGenres,
        limit: limit * 2,
        offset: 0,
        sortBy: 'total_rating',
        sortOrder: 'desc',
      );

      // Filter out games already in wishlist or rated
      final ratedIds = await supabaseDataSource.getUserRatedIds(userId);
      final excludedIds = {...wishlistIds, ...ratedIds};

      final filteredRecommendations = recommendations
          .where((game) => !excludedIds.contains(game.id))
          .take(limit)
          .toList();

      // Enrich with user data
      final enrichedRecommendations = await _enrichGamesWithUserData(filteredRecommendations);

      print('✅ GameRepository: Generated ${enrichedRecommendations.length} recommendations based on wishlist');
      return Right(enrichedRecommendations);

    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get recommendations based on wishlist'));
    }
  }

  @override
  Future<Either<Failure, List<Game>>> getSimilarToTopRated({
    required String userId,
    int limit = 20,
  }) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      print('🌟 GameRepository: Getting games similar to top rated');

      // Get user's top rated games (9+ rating)
      final topRatedData = await supabaseDataSource.getUserHighlyRatedGames(userId, minRating: 9.0);

      if (topRatedData.isEmpty) {
        return const Right([]);
      }

      final topRatedIds = topRatedData.map<int>((data) => data['game_id'] as int).toList();
      final similarGames = <Game>[];

      // Get similar games for top rated games
      for (final gameId in topRatedIds.take(3)) { // Top 3 highest rated
        final similar = await igdbDataSource.getSimilarGames(gameId);
        similarGames.addAll(similar);
      }

      // Remove duplicates and already rated games
      final ratedIds = await supabaseDataSource.getUserRatedIds(userId);
      final uniqueSimilar = similarGames
          .where((game) => !ratedIds.contains(game.id))
          .toSet()
          .take(limit)
          .toList();

      // Enrich with user data
      final enrichedGames = await _enrichGamesWithUserData(uniqueSimilar);

      print('✅ GameRepository: Found ${enrichedGames.length} games similar to top rated');
      return Right(enrichedGames);

    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get games similar to top rated'));
    }
  }

  @override
  Future<Either<Failure, List<Game>>> getGamesMightHaveMissed({
    required String userId,
    DateTime? sinceDate,
    int limit = 20,
  }) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      sinceDate ??= DateTime.now().subtract(const Duration(days: 365));

      print('⏰ GameRepository: Finding games user might have missed since ${sinceDate.toString()}');

      // Get user's genre preferences
      final genrePreferences = await supabaseDataSource.getUserGenrePreferences(userId);
      final preferredGenres = genrePreferences.entries
          .where((entry) => entry.value > 0.5) // Strong preference
          .map((entry) => int.tryParse(entry.key) ?? 0)
          .where((id) => id > 0)
          .toList();

      if (preferredGenres.isEmpty) {
        return const Right([]);
      }

      // Get highly rated games in preferred genres released since the date
      final missedGames = await igdbDataSource.getGamesByGenresAndDateRange(
        genreIds: preferredGenres,
        fromDate: sinceDate,
        toDate: DateTime.now(),
        minRating: 80.0,
        limit: limit * 2,
      );

      // Filter out games user already has
      final userGameIds = await supabaseDataSource.getAllUserGameIds(userId);
      final filteredGames = missedGames
          .where((game) => !userGameIds.contains(game.id))
          .take(limit)
          .toList();

      // Enrich with user data
      final enrichedGames = await _enrichGamesWithUserData(filteredGames);

      print('✅ GameRepository: Found ${enrichedGames.length} games user might have missed');
      return Right(enrichedGames);

    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get games user might have missed'));
    }
  }

  @override
  Future<Either<Failure, List<Game>>> getGamesToPlayNext({
    required String userId,
    int limit = 10,
  }) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      print('▶️ GameRepository: Getting games to play next for user: $userId');

      // Get user's current gaming context
      final userContext = await supabaseDataSource.getUserGamingContext(userId);

      // Generate contextual recommendations
      final nextGames = await _generateNextPlayRecommendations(
        userId: userId,
        userContext: userContext,
        limit: limit,
      );

      // Enrich with user data
      final enrichedGames = await _enrichGamesWithUserData(nextGames);

      print('✅ GameRepository: Generated ${enrichedGames.length} games to play next');
      return Right(enrichedGames);

    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get games to play next'));
    }
  }

  @override
  Future<Either<Failure, List<Game>>> getCollectionCompletionGames({
    required String userId,
    int limit = 20,
  }) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      print('📚 GameRepository: Finding collection completion games');

      // Get user's game collections and identify incomplete series/franchises
      final userGameIds = await supabaseDataSource.getAllUserGameIds(userId);
      final userGames = await igdbDataSource.getGamesByIds(userGameIds);

      // Analyze collections and franchises
      final franchiseIds = <int>[];
      final collectionIds = <int>[];

      for (final game in userGames) {
        // Franchise-IDs extrahieren
        if (game.franchises.isNotEmpty) {
          for (final franchise in game.franchises!) {
            franchiseIds.add(franchise.id);
          }
        }

        // Collection-IDs extrahieren
        if (game.collections.isNotEmpty) {
          for (final collection in game.collections!) {
            collectionIds.add(collection.id);
          }
        }
      }

      // Get missing games from these franchises/collections
      final missingGames = <Game>[];

      // Get franchise completion games
      for (final franchiseId in franchiseIds.toSet()) {
        final franchiseGames = await igdbDataSource.getGamesByFranchise(franchiseId);
        final missing = franchiseGames.where((game) => !userGameIds.contains(game.id));
        missingGames.addAll(missing);
      }

      // Get collection completion games
      for (final collectionId in collectionIds.toSet()) {
        final collectionGames = await igdbDataSource.getGamesByCollection(collectionId);
        final missing = collectionGames.where((game) => !userGameIds.contains(game.id));
        missingGames.addAll(missing);
      }

      // Remove duplicates and sort by rating
      final uniqueGames = missingGames.toSet().toList();
      uniqueGames.sort((a, b) => (b.totalRating ?? 0).compareTo(a.totalRating ?? 0));

      final completionGames = uniqueGames.take(limit).toList();

      // Enrich with user data
      final enrichedGames = await _enrichGamesWithUserData(completionGames);

      print('✅ GameRepository: Found ${enrichedGames.length} collection completion games');
      return Right(enrichedGames);

    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get collection completion games'));
    }
  }

  // ==========================================
  // TRENDING & DISCOVERY
  // ==========================================

  @override
  Future<Either<Failure, List<Game>>> getTrendingGames({
    int limit = 20,
    int offset = 0,
    Duration? timeWindow,
  }) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      final window = timeWindow ?? const Duration(days: 7);
      print('🔥 GameRepository: Getting trending games (${window.inDays} days window)');

      // Get games that are trending based on multiple signals
      final trendingGames = await igdbDataSource.getTrendingGames(
        timeWindow: window,
        limit: limit,
      );

      // Enrich with user data
      final enrichedGames = await _enrichGamesWithUserData(trendingGames);

      print('✅ GameRepository: Found ${enrichedGames.length} trending games');
      return Right(enrichedGames);

    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get trending games'));
    }
  }

  @override
  Future<Either<Failure, List<Game>>> getTrendingGamesByGenre({
    required int genreId,
    int limit = 20,
    Duration? timeWindow,
  }) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      final window = timeWindow ?? const Duration(days: 7);
      print('🎨 GameRepository: Getting trending games for genre: $genreId');

      final trendingGames = await igdbDataSource.getTrendingGamesByGenre(
        genreId: genreId,
        timeWindow: window,
        limit: limit,
      );

      // Enrich with user data
      final enrichedGames = await _enrichGamesWithUserData(trendingGames);

      print('✅ GameRepository: Found ${enrichedGames.length} trending games for genre');
      return Right(enrichedGames);

    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get trending games by genre'));
    }
  }

  @override
  Future<Either<Failure, List<Game>>> getTrendingGamesByPlatform({
    required int platformId,
    int limit = 20,
    Duration? timeWindow,
  }) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      final window = timeWindow ?? const Duration(days: 7);
      print('🎮 GameRepository: Getting trending games for platform: $platformId');

      final trendingGames = await igdbDataSource.getTrendingGamesByPlatform(
        platformId: platformId,
        timeWindow: window,
        limit: limit,
      );

      // Enrich with user data
      final enrichedGames = await _enrichGamesWithUserData(trendingGames);

      print('✅ GameRepository: Found ${enrichedGames.length} trending games for platform');
      return Right(enrichedGames);

    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get trending games by platform'));
    }
  }

  @override
  Future<Either<Failure, List<Game>>> getRisingGames({
    int limit = 20,
    Duration? timeWindow,
  }) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      final window = timeWindow ?? const Duration(days: 30);
      print('📈 GameRepository: Getting rising games');

      final risingGames = await igdbDataSource.getRisingGames(
        timeWindow: window,
        limit: limit,
      );

      // Enrich with user data
      final enrichedGames = await _enrichGamesWithUserData(risingGames);

      print('✅ GameRepository: Found ${enrichedGames.length} rising games');
      return Right(enrichedGames);

    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get rising games'));
    }
  }

  @override
  Future<Either<Failure, List<Game>>> getHiddenGems({
    int limit = 20,
    double minRating = 80.0,
    int maxHypes = 100,
  }) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      print('💎 GameRepository: Finding hidden gems (rating≥$minRating, hypes≤$maxHypes)');

      // Get games with high ratings but low visibility
      final hiddenGems = await igdbDataSource.getHiddenGems(
        minRating: minRating,
        maxHypes: maxHypes,
        limit: limit,
      );

      // Enrich with user data
      final enrichedGems = await _enrichGamesWithUserData(hiddenGems);

      print('✅ GameRepository: Found ${enrichedGems.length} hidden gems');
      return Right(enrichedGems);

    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get hidden gems'));
    }
  }

  @override
  Future<Either<Failure, List<Game>>> getGamesByMood({
    required GameMood mood,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      print('😊 GameRepository: Getting ${mood.displayName} games');

      // Map mood to search criteria
      final searchCriteria = _getMoodSearchCriteria(mood);

      // Get games matching mood criteria
      final games = await igdbDataSource.getGamesByMoodCriteria(
        criteria: searchCriteria,
        limit: limit,
        offset: offset,
      );

      // Enrich with user data
      final enrichedGames = await _enrichGamesWithUserData(games);

      print('✅ GameRepository: Found ${enrichedGames.length} ${mood.displayName} games');
      return Right(enrichedGames);

    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get games by mood'));
    }
  }

  @override
  Future<Either<Failure, List<Game>>> getSeasonalRecommendations({
    required Season season,
    int limit = 20,
  }) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      print('🍂 GameRepository: Getting ${season.displayName} recommendations');

      // Map season to game characteristics
      final seasonalCriteria = _getSeasonalCriteria(season);

      // Get games matching seasonal themes
      final seasonalGames = await igdbDataSource.getGamesBySeasonalCriteria(
        criteria: seasonalCriteria,
        limit: limit,
      );

      // Enrich with user data
      final enrichedGames = await _enrichGamesWithUserData(seasonalGames);

      print('✅ GameRepository: Found ${enrichedGames.length} ${season.displayName} recommendations');
      return Right(enrichedGames);

    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get seasonal recommendations'));
    }
  }

  // ==========================================
  // SOCIAL & COMMUNITY FEATURES
  // ==========================================

  @override
  Future<Either<Failure, List<Game>>> getFriendsActivity({
    required String userId,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      print('👥 GameRepository: Getting friends activity for user: $userId');

      // Get friend IDs
      final friendIds = await supabaseDataSource.getUserFriends(userId);

      if (friendIds.isEmpty) {
        return const Right([]);
      }

      // Get recent activity from friends
      final friendsActivity = await supabaseDataSource.getFriendsRecentActivity(
        friendIds: friendIds,
        limit: limit * 2,
        offset: offset,
      );

      if (friendsActivity.isEmpty) {
        return const Right([]);
      }

      // Extract unique game IDs from activity
      final gameIds = friendsActivity
          .map<int>((activity) => activity['game_id'] as int)
          .toSet()
          .take(limit)
          .toList();

      // Get game data
      final games = await igdbDataSource.getGamesByIds(gameIds);

      // Sort by activity recency
      games.sort((a, b) {
        final activityA = friendsActivity.firstWhere((act) => act['game_id'] == a.id);
        final activityB = friendsActivity.firstWhere((act) => act['game_id'] == b.id);
        return DateTime.parse(activityB['created_at']).compareTo(DateTime.parse(activityA['created_at']));
      });

      // Enrich with user data
      final enrichedGames = await _enrichGamesWithUserData(games);

      print('✅ GameRepository: Found ${enrichedGames.length} games from friends activity');
      return Right(enrichedGames);

    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get friends activity'));
    }
  }

  @override
  Future<Either<Failure, List<Game>>> getFriendsRecommendations({
    required String userId,
    int limit = 20,
  }) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      print('👍 GameRepository: Getting friends recommendations for user: $userId');

      // Get friend IDs
      final friendIds = await supabaseDataSource.getUserFriends(userId);

      if (friendIds.isEmpty) {
        return const Right([]);
      }

      // Get games recommended by friends
      final friendsRecommendations = await supabaseDataSource.getFriendsRecommendedGames(
        friendIds: friendIds,
        excludeUserId: userId, // Don't include games user already has
        limit: limit,
      );

      if (friendsRecommendations.isEmpty) {
        return const Right([]);
      }

      // Extract game IDs
      final gameIds = friendsRecommendations.map<int>((rec) => rec['game_id'] as int).toList();

      // Get game data
      final games = await igdbDataSource.getGamesByIds(gameIds);

      // Sort by number of friend recommendations (popularity among friends)
      final gamePopularity = <int, int>{};
      for (final rec in friendsRecommendations) {
        final gameId = rec['game_id'] as int;
        gamePopularity[gameId] = (gamePopularity[gameId] ?? 0) + 1;
      }

      games.sort((a, b) => (gamePopularity[b.id] ?? 0).compareTo(gamePopularity[a.id] ?? 0));

      // Enrich with user data
      final enrichedGames = await _enrichGamesWithUserData(games);

      print('✅ GameRepository: Found ${enrichedGames.length} games recommended by friends');
      return Right(enrichedGames);

    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get friends recommendations'));
    }
  }

  @override
  Future<Either<Failure, List<Game>>> getCommunityFavoritesByGenre({
    required String userId,
    int limit = 20,
  }) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      print('🌟 GameRepository: Getting community favorites by user preferred genres');

      // Get user's preferred genres
      final genrePreferences = await supabaseDataSource.getUserGenrePreferences(userId);
      final preferredGenres = genrePreferences.entries
          .where((entry) => entry.value > 0.3) // Moderate preference
          .map((entry) => int.tryParse(entry.key) ?? 0)
          .where((id) => id > 0)
          .take(3)
          .toList();

      if (preferredGenres.isEmpty) {
        return const Right([]);
      }

      // Get community favorites in these genres
      final communityFavorites = await supabaseDataSource.getCommunityFavoritesByGenres(
        genreIds: preferredGenres,
        limit: limit,
      );

      if (communityFavorites.isEmpty) {
        return const Right([]);
      }

      // Extract game IDs
      final gameIds = communityFavorites.map<int>((fav) => fav['game_id'] as int).toList();

      // Get game data
      final games = await igdbDataSource.getGamesByIds(gameIds);

      // Sort by community rating/popularity
      games.sort((a, b) {
        final ratingA = communityFavorites.firstWhere((fav) => fav['game_id'] == a.id)['avg_rating'] as double;
        final ratingB = communityFavorites.firstWhere((fav) => fav['game_id'] == b.id)['avg_rating'] as double;
        return ratingB.compareTo(ratingA);
      });

      // Enrich with user data
      final enrichedGames = await _enrichGamesWithUserData(games);

      print('✅ GameRepository: Found ${enrichedGames.length} community favorites');
      return Right(enrichedGames);

    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get community favorites by genre'));
    }
  }

  @override
  Future<Either<Failure, List<Game>>> getSimilarUsersGames({
    required String userId,
    int limit = 20,
  }) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      print('🎯 GameRepository: Getting games from similar users');

      // Find similar users based on gaming preferences
      final similarUsers = await supabaseDataSource.findSimilarUsers(userId, limit: 10);

      if (similarUsers.isEmpty) {
        return const Right([]);
      }

      // Get highly rated games from similar users
      final similarUsersGames = <int, double>{};

      for (final similarUser in similarUsers) {
        final userHighRated = await supabaseDataSource.getUserHighlyRatedGames(
          similarUser['user_id'],
          minRating: 8.0,
        );

        for (final gameData in userHighRated) {
          final gameId = gameData['game_id'] as int;
          final rating = gameData['rating'] as double;
          final similarity = similarUser['similarity_score'] as double;

          // Weight rating by user similarity
          final weightedRating = rating * similarity;
          similarUsersGames[gameId] = (similarUsersGames[gameId] ?? 0) + weightedRating;
        }
      }

      // Exclude games user already has
      final userGameIds = await supabaseDataSource.getAllUserGameIds(userId);
      final filteredGameIds = similarUsersGames.keys
          .where((gameId) => !userGameIds.contains(gameId))
          .toList();

      // Sort by weighted rating
      filteredGameIds.sort((a, b) => similarUsersGames[b]!.compareTo(similarUsersGames[a]!));

      // Take top games
      final topGameIds = filteredGameIds.take(limit).toList();

      // Get game data
      final games = await igdbDataSource.getGamesByIds(topGameIds);

      // Enrich with user data
      final enrichedGames = await _enrichGamesWithUserData(games);

      print('✅ GameRepository: Found ${enrichedGames.length} games from similar users');
      return Right(enrichedGames);

    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get similar users games'));
    }
  }

  // ==========================================
  // ANALYTICS & TRENDS
  // ==========================================

  @override
  Future<Either<Failure, List<GenreTrend>>> getGenreTrends({
    Duration? timeWindow,
    int limit = 20,
  }) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      final window = timeWindow ?? const Duration(days: 30);
      print('📈 GameRepository: Getting genre trends (${window.inDays} days window)');

      // Get genre trends from analytics
      final trends = await supabaseDataSource.getGenreTrendAnalytics(
        timeWindow: window,
        limit: limit,
      );

      // Convert to GenreTrend entities
      final genreTrends = trends.map((trendData) => GenreTrend(
        genreId: trendData['genre_id'] ?? 0,
        genreName: trendData['genre_name'] ?? 'Unknown',
        trendScore: (trendData['trend_score'] as num?)?.toDouble() ?? 0.0,
        growthRate: (trendData['growth_rate'] as num?)?.toDouble() ?? 0.0,
        gameCount: trendData['game_count'] ?? 0,
        averageRating: (trendData['average_rating'] as num?)?.toDouble() ?? 0.0,
        calculatedAt: DateTime.tryParse(trendData['calculated_at'] ?? ''),
      )).toList();

      print('✅ GameRepository: Analyzed ${genreTrends.length} genre trends');
      return Right(genreTrends);

    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get genre trends'));
    }
  }

  @override
  Future<Either<Failure, List<PlatformTrend>>> getPlatformTrends({
    Duration? timeWindow,
    int limit = 20,
  }) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      final window = timeWindow ?? const Duration(days: 30);
      print('🎮 GameRepository: Getting platform trends (${window.inDays} days window)');

      final trends = await supabaseDataSource.getPlatformTrendAnalytics(
        timeWindow: window,
        limit: limit,
      );

      // Convert to PlatformTrend entities
      final platformTrends = trends.map((trendData) => PlatformTrend(
        platformId: trendData['platform_id'] ?? 0,
        platformName: trendData['platform_name'] ?? 'Unknown',
        trendScore: (trendData['trend_score'] as num?)?.toDouble() ?? 0.0,
        gameCount: trendData['game_count'] ?? 0,
        averageRating: (trendData['average_rating'] as num?)?.toDouble() ?? 0.0,
        calculatedAt: DateTime.tryParse(trendData['calculated_at'] ?? ''),
        adoptionRate: (trendData['adoption_rate'] as num?)?.toDouble() ?? 0.0,
      )).toList();

      print('✅ GameRepository: Analyzed ${platformTrends.length} platform trends');
      return Right(platformTrends);

    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get platform trends'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getIndustryTrends({
    Duration? timeWindow,
  }) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      final window = timeWindow ?? const Duration(days: 90);
      print('🏭 GameRepository: Getting industry trends');

      final trends = await supabaseDataSource.getIndustryTrendAnalytics(timeWindow: window);

      print('✅ GameRepository: Industry trends analyzed');
      return Right(trends);

    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get industry trends'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getPersonalizedInsights(String userId) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      print('🔍 GameRepository: Getting personalized insights for user: $userId');

      final insights = await supabaseDataSource.getPersonalizedInsights(userId);

      print('✅ GameRepository: Personalized insights generated');
      return Right(insights);

    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get personalized insights'));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getGenreEvolutionTrends() async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      print('📊 GameRepository: Getting genre evolution trends');

      final evolutionTrends = await supabaseDataSource.getGenreEvolutionTrends();

      print('✅ GameRepository: Genre evolution trends analyzed');
      return Right(evolutionTrends);

    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get genre evolution trends'));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getPlatformAdoptionTrends() async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      print('📱 GameRepository: Getting platform adoption trends');

      final adoptionTrends = await supabaseDataSource.getPlatformAdoptionTrends();

      print('✅ GameRepository: Platform adoption trends analyzed');
      return Right(adoptionTrends);

    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get platform adoption trends'));
    }
  }

  // ==========================================
  // GAMIFICATION & DISCOVERY CHALLENGES
  // ==========================================

  @override
  Future<Either<Failure, List<DiscoveryChallenge>>> getDiscoveryChallenges(String userId) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      print('🎯 GameRepository: Getting discovery challenges for user: $userId');

      // Generate personalized discovery challenges
      final challenges = await _generateDiscoveryChallenges(userId);

      print('✅ GameRepository: Generated ${challenges.length} discovery challenges');
      return Right(challenges);

    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get discovery challenges'));
    }
  }

  @override
  Future<Either<Failure, List<Game>>> getAchievementRecommendations({
    required String userId,
    int limit = 20,
  }) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      print('🏆 GameRepository: Getting achievement recommendations');

      // Get user's gaming profile to identify achievement opportunities
      final userProfile = await supabaseDataSource.getUserGamingProfile(userId);
      final preferences = await supabaseDataSource.getUserGenrePreferences(userId);

      // Get games with interesting achievements in user's preferred genres
      final preferredGenres = preferences.entries
          .where((entry) => entry.value > 0.4)
          .map((entry) => int.tryParse(entry.key) ?? 0)
          .where((id) => id > 0)
          .take(5)
          .toList();

      if (preferredGenres.isEmpty) {
        return const Right([]);
      }

      // Get games known for good achievement systems
      final achievementGames = await igdbDataSource.getGamesWithAchievements(
        genreIds: preferredGenres,
        minRating: 75.0,
        limit: limit,
      );

      // Filter out games user already has
      final userGameIds = await supabaseDataSource.getAllUserGameIds(userId);
      final filteredGames = achievementGames
          .where((game) => !userGameIds.contains(game.id))
          .toList();

      // Enrich with user data
      final enrichedGames = await _enrichGamesWithUserData(filteredGames);

      print('✅ GameRepository: Found ${enrichedGames.length} achievement-focused games');
      return Right(enrichedGames);

    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get achievement recommendations'));
    }
  }

  @override
  Future<Either<Failure, List<Game>>> getDiversityRecommendations({
    required String userId,
    int limit = 20,
  }) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      print('🌈 GameRepository: Getting diversity recommendations');

      // Analyze user's current game diversity
      final userGameIds = await supabaseDataSource.getAllUserGameIds(userId);
      final userGames = await igdbDataSource.getGamesByIds(userGameIds);

      // Analyze current genre distribution
      final currentGenres = <int>[];
      final currentPlatforms = <int>[];

      for (final game in userGames) {
        currentGenres.addAll(game.genres.map((g) => g.id));
        currentPlatforms.addAll(game.platforms.map((p) => p.id));
      }

      final genreFrequency = <int, int>{};
      final platformFrequency = <int, int>{};

      for (final genreId in currentGenres) {
        genreFrequency[genreId] = (genreFrequency[genreId] ?? 0) + 1;
      }

      for (final platformId in currentPlatforms) {
        platformFrequency[platformId] = (platformFrequency[platformId] ?? 0) + 1;
      }

      // Find underrepresented genres/platforms
      final allGenres = await igdbDataSource.getAllGenres();
      final allPlatforms = await igdbDataSource.getAllPlatforms();

      final underrepresentedGenres = allGenres
          .where((genre) => (genreFrequency[genre.id] ?? 0) < 2)
          .map((genre) => genre.id)
          .take(3)
          .toList();

      if (underrepresentedGenres.isEmpty) {
        return const Right([]);
      }

      // Get diverse games from underrepresented genres
      final diverseGames = await igdbDataSource.getGamesByGenres(
        genreIds: underrepresentedGenres,
        limit: limit * 2,
        offset: 0,
        sortBy: 'total_rating',
        sortOrder: 'desc',
      );

      // Filter out games user already has
      final filteredGames = diverseGames
          .where((game) => !userGameIds.contains(game.id))
          .take(limit)
          .toList();

      // Enrich with user data
      final enrichedGames = await _enrichGamesWithUserData(filteredGames);

      print('✅ GameRepository: Found ${enrichedGames.length} diversity recommendations');
      return Right(enrichedGames);

    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get diversity recommendations'));
    }
  }

  // ==========================================
  // HELPER METHODS FOR ADVANCED FEATURES
  // ==========================================

  /// Generate smart recommendations using multiple signals
  Future<List<Game>> _generateSmartRecommendations({
    required String userId,
    required Map<String, dynamic> userProfile,
    required List<int> ratedGameIds,
    required List<int> wishlistIds,
    int limit = 40,
  }) async {
    final recommendations = <Game>[];

    // 1. Genre-based recommendations (40%)
    final genreRecommendations = await _getGenreBasedRecommendations(
      userProfile: userProfile,
      limit: (limit * 0.4).round(),
    );
    recommendations.addAll(genreRecommendations);

    // 2. Similar games recommendations (30%)
    final similarRecommendations = await _getSimilarGameRecommendations(
      ratedGameIds: ratedGameIds,
      limit: (limit * 0.3).round(),
    );
    recommendations.addAll(similarRecommendations);

    // 3. Platform-based recommendations (20%)
    final platformRecommendations = await _getPlatformBasedRecommendations(
      userProfile: userProfile,
      limit: (limit * 0.2).round(),
    );
    recommendations.addAll(platformRecommendations);

    // 4. Trending games (10%)
    final trendingRecommendations = await igdbDataSource.getTrendingGames(
      timeWindow: const Duration(days: 7),
      limit: (limit * 0.1).round(),
    );
    recommendations.addAll(trendingRecommendations);

    // Remove duplicates and games user already has
    final uniqueRecommendations = recommendations.where((game) {
      return !ratedGameIds.contains(game.id) && !wishlistIds.contains(game.id);
    }).toSet().toList();

    // Sort by recommendation score (could implement scoring algorithm)
    uniqueRecommendations.shuffle(); // Simple randomization for now

    return uniqueRecommendations.take(limit).toList();
  }

  /// Generate AI-powered recommendations using signal data
  Future<List<Game>> _generateAIRecommendations({
    required String userId,
    required Map<RecommendationSignal, dynamic> signalData,
    int limit = 20,
  }) async {
    // This would be where you integrate with AI/ML services
    // For now, implementing rule-based recommendations

    final recommendations = <Game>[];

    // Weight each signal and combine recommendations
    for (final entry in signalData.entries) {
      final signal = entry.key;
      final data = entry.value;

      switch (signal) {
        case RecommendationSignal.genres:
          final genreGames = await _getGamesFromGenrePreferences(data, limit ~/ signalData.length);
          recommendations.addAll(genreGames);
          break;
        case RecommendationSignal.ratings:
          final ratingGames = await _getGamesFromRatingPatterns(data, limit ~/ signalData.length);
          recommendations.addAll(ratingGames);
          break;
        default:
          continue;
      }
    }

    return recommendations.take(limit).toList();
  }

  /// Get search criteria for different moods
  Map<String, dynamic> _getMoodSearchCriteria(GameMood mood) {
    switch (mood) {
      case GameMood.actionPacked:
        return {
          'genres': [4, 5], // Action, Adventure
          'keywords': ['fast-paced', 'action', 'combat'],
          'themes': [1], // Action theme
        };
      case GameMood.relaxing:
        return {
          'genres': [13, 15], // Simulation, Strategy
          'keywords': ['relaxing', 'peaceful', 'meditative'],
          'themes': [17], // Non-violence
        };
      case GameMood.storyRich:
        return {
          'genres': [12, 14], // RPG, Adventure
          'keywords': ['story', 'narrative', 'cinematic'],
          'themes': [38], // Open World
        };
      default:
        return {};
    }
  }

  /// Get seasonal criteria for game recommendations
  Map<String, dynamic> _getSeasonalCriteria(Season season) {
    switch (season) {
      case Season.spring:
        return {
          'themes': [17, 38], // Non-violence, Open World
          'keywords': ['adventure', 'exploration', 'nature'],
        };
      case Season.summer:
        return {
          'genres': [4, 5, 10], // Action, Adventure, Racing
          'keywords': ['adventure', 'outdoor', 'sports'],
        };
      case Season.autumn:
        return {
          'genres': [12, 31], // RPG, Adventure
          'keywords': ['story', 'atmospheric', 'cozy'],
        };
      case Season.winter:
        return {
          'genres': [13, 15, 12], // Simulation, Strategy, RPG
          'keywords': ['long-session', 'immersive', 'story'],
        };
    }
  }

  /// Generate discovery challenges based on user's gaming profile
  Future<List<DiscoveryChallenge>> _generateDiscoveryChallenges(String userId) async {
    final challenges = <DiscoveryChallenge>[];

    // Get user's gaming profile to identify gaps
    final userProfile = await supabaseDataSource.getUserGamingProfile(userId);
    final userGenres = userProfile['favorite_genres'] as List<int>? ?? [];
    final userPlatforms = userProfile['used_platforms'] as List<int>? ?? [];

    // Genre exploration challenge
    final allGenres = await igdbDataSource.getAllGenres();
    final unexploredGenres = allGenres.where((genre) => !userGenres.contains(genre.id)).toList();

    if (unexploredGenres.isNotEmpty) {
      final randomGenre = (unexploredGenres..shuffle()).first;
      challenges.add(DiscoveryChallenge(
        id: 'explore_${randomGenre.slug}',
        title: 'Explore ${randomGenre.name}',
        description: 'Try 3 highly-rated ${randomGenre.name} games',
        type: DiscoveryChallengeType.exploreGenre,
        requirements: {'genre_id': randomGenre.id, 'game_count': 3, 'min_rating': 75.0},
        recommendedGameIds: [], // Would be populated with actual recommendations
        rewardPoints: 100,
        expiresAt: DateTime.now().add(const Duration(days: 30)),
      ));
    }

    return challenges;
  }

  /// Helper methods for different recommendation strategies
  Future<List<Game>> _getGenreBasedRecommendations({
    required Map<String, dynamic> userProfile,
    int limit = 10,
  }) async {
    final favoriteGenres = userProfile['favorite_genres'] as List<int>? ?? [];
    if (favoriteGenres.isEmpty) return [];

    return await igdbDataSource.getGamesByGenres(
      genreIds: favoriteGenres,
      limit: limit,
      offset: 0,
      sortBy: 'total_rating',
      sortOrder: 'desc',
    );
  }

  Future<List<Game>> _getSimilarGameRecommendations({
    required List<int> ratedGameIds,
    int limit = 10,
  }) async {
    final similarGames = <Game>[];

    for (final gameId in ratedGameIds.take(5)) { // Limit to top 5 rated games
      final similar = await igdbDataSource.getSimilarGames(gameId);
      similarGames.addAll(similar);
    }

    return similarGames.take(limit).toList();
  }

  Future<List<Game>> _getPlatformBasedRecommendations({
    required Map<String, dynamic> userProfile,
    int limit = 10,
  }) async {
    final preferredPlatforms = userProfile['preferred_platforms'] as List<int>? ?? [];
    if (preferredPlatforms.isEmpty) return [];

    return await igdbDataSource.getGamesByPlatforms(
      platformIds: preferredPlatforms,
      limit: limit,
      offset: 0,
      sortBy: 'total_rating',
      sortOrder: 'desc',
    );
  }

  Future<List<Game>> _generateNextPlayRecommendations({
    required String userId,
    required Map<String, dynamic> userContext,
    int limit = 10,
  }) async {
    // Analyze user's gaming context and suggest appropriate next games
    final lastPlayedGenres = userContext['recent_genres'] as List<int>? ?? [];
    final currentMood = userContext['suggested_mood'] as String? ?? 'balanced';

    // Generate contextual recommendations based on recent activity
    return await _getContextualRecommendations(
      genres: lastPlayedGenres,
      mood: currentMood,
      limit: limit,
    );
  }

  Future<List<Game>> _getContextualRecommendations({
    required List<int> genres,
    required String mood,
    int limit = 10,
  }) async {
    // Implementation would analyze context and return appropriate games
    // For now, return games from provided genres
    if (genres.isEmpty) return [];

    return await igdbDataSource.getGamesByGenres(
      genreIds: genres,
      limit: limit,
      offset: 0,
      sortBy: 'total_rating',
      sortOrder: 'desc',
    );
  }

  Future<List<Game>> _getGamesFromGenrePreferences(dynamic data, int limit) async {
    // Extract genre preferences and get games
    if (data is Map<String, double>) {
      final topGenres = data.entries
          .where((entry) => entry.value > 0.5)
          .map((entry) => int.tryParse(entry.key) ?? 0)
          .where((id) => id > 0)
          .take(3)
          .toList();

      if (topGenres.isNotEmpty) {
        return await igdbDataSource.getGamesByGenres(
          genreIds: topGenres,
          limit: limit,
          offset: 0,
          sortBy: 'total_rating',
          sortOrder: 'desc',
        );
      }
    }
    return [];
  }

  Future<List<Game>> _getGamesFromRatingPatterns(dynamic data, int limit) async {
    // Analyze rating patterns and suggest similar games
    // This would be implemented based on the actual rating pattern data structure
    return [];
  }

}