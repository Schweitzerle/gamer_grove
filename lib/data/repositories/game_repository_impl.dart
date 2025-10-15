// data/repositories/game_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:gamer_grove/domain/entities/game/game_engine.dart';
import 'package:gamer_grove/domain/entities/game/game_engine_logo.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/artwork.dart';
import '../../domain/entities/character/character.dart';
import '../../domain/entities/character/character_gender.dart';
import '../../domain/entities/character/character_species.dart';
import '../../domain/entities/company/company_logo.dart';
import '../../domain/entities/event/event.dart';
import '../../domain/entities/game/game.dart';
import '../../domain/entities/ageRating/age_rating.dart';
import '../../domain/entities/company/company.dart';
import '../../domain/entities/game/game_media_collection.dart';
import '../../domain/entities/game/game_sort_options.dart';
import '../../domain/entities/game/game_video.dart';
import '../../domain/entities/genre.dart';
import '../../domain/entities/platform/platform.dart';
import '../../domain/entities/platform/platform_logo.dart';
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

import '../models/character/character_model.dart';
import '../models/company/company_model_logo.dart';
import '../models/game/game_engine_logo_model.dart';
import '../models/game/game_model.dart';
import '../models/platform/platform_logo_model.dart';
import '../models/platform/platform_model.dart';

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
            message: 'No internet connection. Please check your network.'));
      }

      print(
          '🌐 GameRepository: Fetching enhanced game details for ID: $gameId');

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
  Future<Either<Failure, Game>> getCompleteGameDetails(
      int gameId, String? userId) async {
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

      print(
          '✅ GameRepository: Complete enhanced game details loaded successfully');
      return Right(game);
    } on ServerException catch (e) {
      print('💥 GameRepository: Server error: ${e.message}');
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      print('💥 GameRepository: Unexpected error: $e');
      return const Left(
          ServerFailure(message: 'Failed to load complete game details'));
    }
  }

  @override
  Future<Either<Failure, Game>> getGameDetailsWithUserData(
      int gameId, String? userId) async {
    return getCompleteGameDetails(gameId, userId);
  }

  @override
  Future<Either<Failure, List<Game>>> searchGames(
      String query, int limit, int offset) async {
    try {
      // Check cache for search results
      final cachedResults = await localDataSource.getCachedSearchResults(query);
      if (cachedResults != null && cachedResults.isNotEmpty) {
        print('🔍 GameRepository: Found cached search results for: $query');
        return Right(await _enrichGamesWithUserData(cachedResults));
      }

      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure(
            message: 'No internet connection. Please check your network.'));
      }

      print(
          '🔍 GameRepository: Searching for: "$query" (limit: $limit, offset: $offset)');

      // Use enhanced search that includes more data
      final searchResults =
          await igdbDataSource.searchGames(query, limit, offset);

      // Cache search results
      await localDataSource.cacheSearchResults(query, searchResults);

      // Enrich with user data
      final enrichedResults = await _enrichGamesWithUserData(searchResults);

      print(
          '✅ GameRepository: Search completed - found ${enrichedResults.length} results');
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
      return const Left(ServerFailure(message: 'Failed to load games'));
    }
  }

  // ==========================================
  // POPULAR & UPCOMING GAMES - Enhanced
  // ==========================================

  @override
  Future<Either<Failure, List<Game>>> getPopularGames(
      int limit, int offset) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      print(
          '🔥 GameRepository: Getting popular games (limit: $limit, offset: $offset)');

      // Use enhanced popular games method
      final popularGames = await igdbDataSource.getPopularGames(limit, offset);

      // Enrich with user data
      final enrichedGames = await _enrichGamesWithUserData(popularGames);

      print('✅ GameRepository: Loaded ${enrichedGames.length} popular games');
      return Right(enrichedGames);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return const Left(ServerFailure(message: 'Failed to load popular games'));
    }
  }

  @override
  Future<Either<Failure, List<Game>>> getUpcomingGames(
      int limit, int offset) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      print(
          '📅 GameRepository: Getting upcoming games (limit: $limit, offset: $offset)');

      // Use enhanced upcoming games method
      final upcomingGames =
          await igdbDataSource.getUpcomingGames(limit, offset);

      // Enrich with user data
      final enrichedGames = await _enrichGamesWithUserData(upcomingGames);

      print('✅ GameRepository: Loaded ${enrichedGames.length} upcoming games');
      return Right(enrichedGames);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return const Left(
          ServerFailure(message: 'Failed to load upcoming games'));
    }
  }

  @override
  Future<Either<Failure, List<Game>>> getLatestGames(
      int limit, int offset) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      print(
          '📅 GameRepository: Getting latest games (limit: $limit, offset: $offset)');

      // Use enhanced latest games method
      final latestGames = await igdbDataSource.getLatestGames(limit, offset);

      // Enrich with user data
      final enrichedGames = await _enrichGamesWithUserData(latestGames);

      print('✅ GameRepository: Loaded ${enrichedGames.length} latest games');
      return Right(enrichedGames);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return const Left(ServerFailure(message: 'Failed to load latest games'));
    }
  }

  // ==========================================
  // ENHANCED COMPANY & CONTENT METHODS
  // ==========================================

  @override
  Future<Either<Failure, List<Company>>> getCompanies(
      {List<int>? ids, String? search}) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      print(
          '🏢 GameRepository: Getting companies (ids: $ids, search: $search)');

      // Use enhanced company method with complete data
      final companies =
          await igdbDataSource.getCompanies(ids: ids, search: search);

      print('✅ GameRepository: Loaded ${companies.length} companies');
      return Right(companies);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return const Left(ServerFailure(message: 'Failed to load companies'));
    }
  }

  @override
  Future<Either<Failure, List<Website>>> getGameWebsites(
      List<int> gameIds) async {
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
      return const Left(ServerFailure(message: 'Failed to load game websites'));
    }
  }

  @override
  Future<Either<Failure, List<AgeRating>>> getGameAgeRatings(
      List<int> gameIds) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      print(
          '🔞 GameRepository: Getting age ratings for ${gameIds.length} games');

      final ageRatings = await igdbDataSource.getAgeRatings(gameIds);

      print('✅ GameRepository: Loaded ${ageRatings.length} age ratings');
      return Right(ageRatings);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return const Left(ServerFailure(message: 'Failed to load age ratings'));
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
      return const Left(ServerFailure(message: 'Failed to load similar games'));
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
      return const Left(ServerFailure(message: 'Failed to load game DLCs'));
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
      return const Left(
          ServerFailure(message: 'Failed to load game expansions'));
    }
  }

  // ==========================================
  // USER-SPECIFIC METHODS - Enhanced
  // ==========================================

  @override
  Future<Either<Failure, List<Game>>> getUserWishlist(
      String userId, int limit, int offset) async {
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
      //final paginatedIds = gameIds.skip(offset).take(limit).toList();

      // Get enhanced game data
      final games = await igdbDataSource.getGamesByIds(gameIds);
      final enrichedGames = await _enrichGamesWithUserData(games);

      print('✅ GameRepository: Loaded ${enrichedGames.length} wishlist games');
      return Right(enrichedGames);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return const Left(ServerFailure(message: 'Failed to load wishlist'));
    }
  }

  @override
  Future<Either<Failure, List<Game>>> getUserRecommendations(
      String userId, int limit, int offset) async {
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
      //final paginatedIds = gameIds.skip(offset).take(limit).toList();

      // Get enhanced game data
      final games = await igdbDataSource.getGamesByIds(gameIds);
      final enrichedGames = await _enrichGamesWithUserData(games);

      print(
          '✅ GameRepository: Loaded ${enrichedGames.length} recommended games');
      return Right(enrichedGames);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return const Left(
          ServerFailure(message: 'Failed to load recommendations'));
    }
  }

  @override
  Future<Either<Failure, List<Game>>> getUserRated(
      String userId, int limit, int offset) async {
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
      //final paginatedIds = gameIds.skip(offset).take(limit).toList();

      // Get enhanced game data
      final games = await igdbDataSource.getGamesByIds(gameIds);
      final enrichedGames = await _enrichGamesWithUserData(games);

      print('✅ GameRepository: Loaded ${enrichedGames.length} rated games');
      return Right(enrichedGames);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return const Left(ServerFailure(message: 'Failed to load rated games'));
    }
  }

  @override
  Future<Either<Failure, List<Game>>> getUserTopThreeGames(
      String userId) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      // Get raw data from Supabase
      final topThreeData =
          await supabaseDataSource.getUserTopThreeGames(userId: userId);

      if (topThreeData.isEmpty) {
        return const Right([]);
      }

      // Extract game IDs
      final gameIds =
          topThreeData.map<int>((data) => data['game_id'] as int).toList();

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
      return const Left(ServerFailure(message: 'Failed to load top 3 games'));
    }
  }

  // ==========================================
  // USER ACTIONS - Enhanced
  // ==========================================

  @override
  Future<Either<Failure, void>> rateGame(
      int gameId, String userId, double rating) async {
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
      return const Left(ServerFailure(message: 'Failed to rate game'));
    }
  }

  @override
  Future<Either<Failure, void>> toggleWishlist(
      int gameId, String userId) async {
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
      return const Left(ServerFailure(message: 'Failed to toggle wishlist'));
    }
  }

  @override
  Future<Either<Failure, void>> toggleRecommend(
      int gameId, String userId) async {
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
      return const Left(
          ServerFailure(message: 'Failed to toggle recommendation'));
    }
  }

  // ==========================================
  // PHASE 1 - HOME SCREEN METHODS IMPLEMENTATION
  // ==========================================

  @override
  Future<Either<Failure, List<Game>>> getTopRatedGames(
      int limit, int offset) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      print(
          '⭐ GameRepository: Getting top rated games (limit: $limit, offset: $offset)');

      // Get games sorted by total_rating, excluding those without ratings
      final topRatedGames =
          await igdbDataSource.getTopRatedGames(limit: limit, offset: offset);

      print('TopRatedGames: ${topRatedGames.length}');
      // Enrich with user data
      final enrichedGames = await _enrichGamesWithUserData(topRatedGames);

      print('✅ GameRepository: Loaded ${enrichedGames.length} top rated games');
      return Right(enrichedGames);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return const Left(
          ServerFailure(message: 'Failed to load top rated games'));
    }
  }

  @override
  Future<Either<Failure, List<Game>>> getNewestGames(
      int limit, int offset) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      print(
          '🆕 GameRepository: Getting newest games (limit: $limit, offset: $offset)');

      // Get games sorted by release date (most recent first)
      final newestGames = await igdbDataSource.getGamesSortedByReleaseDate(
          limit: limit, offset: offset);

      // Enrich with user data
      final enrichedGames = await _enrichGamesWithUserData(newestGames);

      print('✅ GameRepository: Loaded ${enrichedGames.length} newest games');
      return Right(enrichedGames);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return const Left(ServerFailure(message: 'Failed to load newest games'));
    }
  }

  @override
  Future<Either<Failure, List<Game>>> getWishlistRecentReleases(String userId,
      {DateTime? fromDate, DateTime? toDate}) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      // Default date range: 1 month ago to 2 weeks from now
      final now = DateTime.now();
      fromDate ??= now.subtract(const Duration(days: 30));
      toDate ??= now.add(const Duration(days: 14));

      print(
          '❤️ GameRepository: Getting wishlist recent releases for user: $userId');
      print(
          '📅 GameRepository: Date range: ${fromDate.toString()} to ${toDate.toString()}');

      // Get user's wishlist game IDs
      final wishlistIds = await supabaseDataSource.getUserWishlistIds(userId);

      if (wishlistIds.isEmpty) {
        return const Right([]);
      }

      // Get wishlist games with release dates in the specified range
      final recentReleases = await igdbDataSource.getGamesByReleaseDateRange(
          gameIds: wishlistIds, fromDate: fromDate, toDate: toDate);

      // Enrich with user data
      final enrichedGames = await _enrichGamesWithUserData(recentReleases);

      print(
          '✅ GameRepository: Found ${enrichedGames.length} wishlist games with recent/upcoming releases');
      return Right(enrichedGames);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return const Left(
          ServerFailure(message: 'Failed to load wishlist recent releases'));
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
            message: 'No internet connection. Please check your network.'));
      }

      print('🔍 GameRepository: Enhanced search for: "$query" with filters');
      print(
          '📊 GameRepository: Genres: ${filters.genreIds}, Platforms: ${filters.platformIds}');

      final searchResults = await igdbDataSource.searchGamesWithFilters(
        query: query,
        filters: filters,
        limit: limit,
        offset: offset,
      );

      // Enrich with user data
      final enrichedResults = await _enrichGamesWithUserData(searchResults);

      print(
          '✅ GameRepository: Enhanced search completed - found ${enrichedResults.length} results');
      return Right(enrichedResults);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return const Left(
          ServerFailure(message: 'Failed to search games with filters'));
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
      return const Left(ServerFailure(message: 'Failed to get games by genre'));
    }
  }

  @override
  Future<Either<Failure, List<Game>>> getGamesByPlatform({
    required List<int> platformIds,
    int limit = 20,
    int offset = 0,
    GameSortBy sortBy = GameSortBy.ratingCount,
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

      print(
          '✅ GameRepository: Found ${enrichedGames.length} games for platforms');
      return Right(enrichedGames);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return const Left(
          ServerFailure(message: 'Failed to get games by platform'));
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

      print(
          '✅ GameRepository: Found ${enrichedGames.length} games for year range');
      return Right(enrichedGames);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return const Left(
          ServerFailure(message: 'Failed to get games by release year'));
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

      print(
          '⭐ GameRepository: Getting games with rating $minRating-$maxRating');

      final games = await igdbDataSource.getGamesByRatingRange(
        minRating: minRating,
        maxRating: maxRating,
        limit: limit,
        offset: offset,
        sortBy: sortBy.igdbField,
        sortOrder: sortOrder.value,
      );

      final enrichedGames = await _enrichGamesWithUserData(games);

      print(
          '✅ GameRepository: Found ${enrichedGames.length} games for rating range');
      return Right(enrichedGames);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return const Left(
          ServerFailure(message: 'Failed to get games by rating range'));
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
      return const Left(ServerFailure(message: 'Failed to get genres'));
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
      return const Left(ServerFailure(message: 'Failed to get platforms'));
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
      print(
          '📊 GameRepository: Active filters: ${filters.hasFilters ? 'Yes' : 'No'}');

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
      return const Left(ServerFailure(message: 'Failed to get filtered games'));
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

      print(
          '🔍 GameRepository: Advanced search - Query: "${textQuery ?? 'None'}"');

      final games = await igdbDataSource.searchGamesWithFilters(
        query: textQuery ?? '',
        filters: filters,
        limit: limit,
        offset: offset,
      );

      final enrichedGames = await _enrichGamesWithUserData(games);

      print(
          '✅ GameRepository: Advanced search found ${enrichedGames.length} games');
      return Right(enrichedGames);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return const Left(
          ServerFailure(message: 'Failed to perform advanced search'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getSearchSuggestions(
      String partialQuery) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      if (partialQuery.length < 2) {
        return const Right([]);
      }

      print(
          '💡 GameRepository: Getting search suggestions for: "$partialQuery"');

      final suggestions =
          await igdbDataSource.getSearchSuggestions(partialQuery);

      print('✅ GameRepository: Found ${suggestions.length} search suggestions');
      return Right(suggestions);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return const Left(
          ServerFailure(message: 'Failed to get search suggestions'));
    }
  }

  @override
  Future<Either<Failure, List<Game>>> getRecentSearches(String userId,
      {int limit = 10}) async {
    try {
      print('📝 GameRepository: Getting recent searches for user: $userId');

      // Get recent search queries from Supabase
      final recentQueries =
          await supabaseDataSource.getRecentSearchQueries(userId, limit: limit);

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
      return const Left(
          ServerFailure(message: 'Failed to get recent searches'));
    }
  }

  @override
  Future<Either<Failure, void>> saveSearchQuery(
      String userId, String query) async {
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
      return const Left(ServerFailure(message: 'Failed to save search query'));
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
      final gameIds =
          wishlistData.map((item) => item['game_id'] as int).toList();

      // Get full game data from IGDB
      final games = await igdbDataSource.getGamesByIds(gameIds);

      // Apply complex filters that require IGDB data
      var filteredGames = _applyComplexFilters(games, filters);

      // Apply sorting that requires IGDB data
      filteredGames =
          _applySorting(filteredGames, filters.sortBy, filters.sortOrder);

      // Apply final pagination after filtering
      final paginatedGames = filteredGames.skip(offset).take(limit).toList();

      // Enrich with user data
      final enrichedGames = await _enrichGamesWithUserData(paginatedGames);

      print(
          '✅ GameRepository: Loaded ${enrichedGames.length} filtered wishlist games');
      return Right(enrichedGames);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return const Left(
          ServerFailure(message: 'Failed to get filtered wishlist'));
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
        userRatings[item['game_id'] as int] =
            (item['rating'] as num).toDouble();
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

          if (filters.minUserRating != null &&
              userRating < filters.minUserRating!) {
            return false;
          }
          if (filters.maxUserRating != null &&
              userRating > filters.maxUserRating!) {
            return false;
          }
          return true;
        }).toList();
      }

      // Apply sorting
      filteredGames = _applySorting(
          filteredGames, filters.sortBy, filters.sortOrder, userRatings);

      // Apply pagination
      final paginatedGames = filteredGames.skip(offset).take(limit).toList();

      // Enrich with user data
      final enrichedGames = await _enrichGamesWithUserData(paginatedGames);

      print(
          '✅ GameRepository: Loaded ${enrichedGames.length} filtered rated games');
      return Right(enrichedGames);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return const Left(
          ServerFailure(message: 'Failed to get filtered rated games'));
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

      print(
          '👍 GameRepository: Getting filtered recommended games for user: $userId');

      // Get recommended games data from Supabase
      final recommendedData =
          await supabaseDataSource.getUserRecommendedGamesWithFilters(
        userId: userId,
        filters: filters,
        limit: limit * 2,
        offset: offset,
      );

      if (recommendedData.isEmpty) {
        return const Right([]);
      }

      // Extract game IDs
      final gameIds =
          recommendedData.map((item) => item['game_id'] as int).toList();

      // Get full game data from IGDB
      final games = await igdbDataSource.getGamesByIds(gameIds);

      // Apply complex filters and sorting
      var filteredGames = _applyComplexFilters(games, filters);
      filteredGames =
          _applySorting(filteredGames, filters.sortBy, filters.sortOrder);

      // Apply pagination
      final paginatedGames = filteredGames.skip(offset).take(limit).toList();

      // Enrich with user data
      final enrichedGames = await _enrichGamesWithUserData(paginatedGames);

      print(
          '✅ GameRepository: Loaded ${enrichedGames.length} filtered recommended games');
      return Right(enrichedGames);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return const Left(
          ServerFailure(message: 'Failed to get filtered recommended games'));
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

      print(
          '📊 GameRepository: Getting collection summary for ${collectionType.displayName}');

      // Get statistics from Supabase
      final stats = await supabaseDataSource.getUserCollectionStatistics(
        userId: userId,
      );

      // Build collection summary
      final summary = UserCollectionSummary(
        type: collectionType,
        totalCount: stats['total_count'] ?? 0,
        averageRating: (stats['average_rating'] as num?)?.toDouble(),
        averageGameRating: (stats['average_game_rating'] as num?)?.toDouble(),
        genreBreakdown: Map<String, int>.from(stats['genre_breakdown'] ?? {}),
        platformBreakdown:
            Map<String, int>.from(stats['platform_breakdown'] ?? {}),
        yearBreakdown: Map<int, int>.from(stats['year_breakdown'] ?? {}),
        recentlyAddedCount: stats['recently_added_count'] ?? 0,
        lastUpdated: DateTime.tryParse(stats['last_updated'] ?? ''),
      );

      print('✅ GameRepository: Collection summary loaded');
      return Right(summary);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return const Left(
          ServerFailure(message: 'Failed to get collection summary'));
    }
  }

  @override
  Future<Either<Failure, Map<UserCollectionType, List<Game>>>>
      getAllUserCollections({
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
      final wishlist = results[0].fold((l) => <Game>[], (r) => r);
      final rated = results[1].fold((l) => <Game>[], (r) => r);
      final recommended = results[2].fold((l) => <Game>[], (r) => r);
      final topThree = results[3].fold((l) => <Game>[], (r) => r);

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
      return const Left(
          ServerFailure(message: 'Failed to get all user collections'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getUserGamingStatistics(
      String userId) async {
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
      return const Left(
          ServerFailure(message: 'Failed to get gaming statistics'));
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

      print(
          '❤️ GameRepository: Batch adding ${gameIds.length} games to wishlist');

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
      return const Left(
          ServerFailure(message: 'Failed to batch add to wishlist'));
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
      return const Left(ServerFailure(message: 'Failed to batch rate games'));
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

      // 🔧 HAUPTFIX: Verwende die richtige Methode!
      // ❌ FALSCH: final characterData = await igdbDataSource.getCompleteCharacterData(gameId);
      // ✅ RICHTIG:
      final characters = await igdbDataSource.getCharactersForGames([gameId]);

      print('📡 GameRepository: IGDB returned ${characters.length} characters');

      if (characters.isEmpty) {
        print('ℹ️ GameRepository: No characters found for game: $gameId');
        return const Right([]);
      }

      // Konvertiere zu Entities (ohne Enrichment erstmal)
      final characterEntities = <Character>[];
      for (final character in characters) {
        try {
          characterEntities.add(character as Character);
        } catch (e) {
          print('⚠️ GameRepository: Failed to convert character: $e');
          continue;
        }
      }

      print(
          '✅ GameRepository: Successfully converted ${characterEntities.length} characters');
      return Right(characterEntities);
    } on ServerException catch (e) {
      print('❌ GameRepository: ServerException: ${e.message}');
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      print('❌ GameRepository: Generic error: $e');
      return Left(ServerFailure(message: 'Failed to get game characters: $e'));
    }
  }

// ==========================================
// 🆕 ENHANCED CHARACTER DETAIL METHOD
// ==========================================

  @override
  Future<Either<Failure, Character>> getCharacterDetails(
      int characterId) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      print('🎭 GameRepository: Getting character details: $characterId');

      // Das ist korrekt - für EINEN Character
      final characterData =
          await igdbDataSource.getCompleteCharacterData(characterId);

      if (characterData.isEmpty) {
        return const Left(NotFoundFailure(message: 'Character not found'));
      }

      final character = _parseCompleteCharacterData(characterData);
      if (character == null) {
        return const Left(ServerFailure(message: 'Failed to parse character'));
      }

      print('✅ GameRepository: Character loaded: ${character.name}');
      return Right(character);
    } catch (e) {
      return Left(ServerFailure(message: 'Character details failed: $e'));
    }
  }

  Future<void> debugCharacterMethods(int gameId) async {
    print('\n=== 🔍 CHARACTER DEBUG ===');

    try {
      // Test Multiple Characters
      final charactersList =
          await igdbDataSource.getCharactersForGames([gameId]);
      print('✅ getCharactersForGames: ${charactersList.length} characters');
      print('📝 Type: ${charactersList.runtimeType}');

      // Test Single Character
      if (charactersList.isNotEmpty) {
        final characterData = await igdbDataSource
            .getCompleteCharacterData(charactersList.first.id);
        print(
            '✅ getCompleteCharacterData: ${characterData.keys.length} fields');
        print('📝 Type: ${characterData.runtimeType}');
      }
    } catch (e) {
      print('❌ Debug failed: $e');
    }
  }

// ==========================================
// 🆕 ENHANCED BATCH CHARACTER ENRICHMENT
// ==========================================

// Keep existing _parseCompleteCharacterData method unchanged...
  Character? _parseCompleteCharacterData(Map<String, dynamic> data) {
    try {
      // Extract mugshot image ID from nested data
      String? mugShotImageId;
      final mugShotData = data['mug_shot'];
      if (mugShotData is Map<String, dynamic>) {
        mugShotImageId = mugShotData['image_id']?.toString();
      }

      // Create character with image data (games will be added later)
      return CharacterModel(
        id: data['id'] ?? 0,
        checksum: data['checksum'] ?? '',
        name: data['name'] ?? '',
        akas: _parseStringList(data['akas']),
        characterGenderId: data['character_gender'],
        characterSpeciesId: data['character_species'],
        countryName: data['country_name'],
        description: data['description'],
        gameIds: _parseIdList(data['games']),
        mugShotId:
            data['mug_shot'] is Map ? data['mug_shot']['id'] : data['mug_shot'],
        slug: data['slug'],
        url: data['url'],
        createdAt: _parseDateTime(data['created_at']),
        updatedAt: _parseDateTime(data['updated_at']),
        genderEnum: _parseGenderEnum(data['gender']),
        speciesEnum: _parseSpeciesEnum(data['species']),
        mugShotImageId: mugShotImageId, // 🆕 This is the key!
        // games: null, // Will be populated by _enrichCharactersWithGames
      );
    } catch (e) {
      print('❌ GameRepository: Error parsing character data: $e');
      return null;
    }
  }

// Keep existing helper methods unchanged...
  List<String> _parseStringList(dynamic data) {
    if (data is List) {
      return data.whereType<String>().map((item) => item.toString()).toList();
    }
    return [];
  }

  List<int> _parseIdList(dynamic data) {
    if (data is List) {
      return data
          .where((item) => item is int || (item is Map && item['id'] is int))
          .map((item) => item is int ? item : item['id'] as int)
          .toList();
    }
    return [];
  }

  DateTime? _parseDateTime(dynamic date) {
    if (date is String) {
      return DateTime.tryParse(date);
    } else if (date is int) {
      return DateTime.fromMillisecondsSinceEpoch(date * 1000);
    }
    return null;
  }

  CharacterGenderEnum? _parseGenderEnum(dynamic gender) {
    if (gender is int) {
      return CharacterGenderEnum.fromValue(gender);
    }
    return null;
  }

  CharacterSpeciesEnum? _parseSpeciesEnum(dynamic species) {
    if (species is int) {
      return CharacterSpeciesEnum.fromValue(species);
    }
    return null;
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
      return const Left(ServerFailure(message: 'Failed to get game videos'));
    }
  }

  @override
  Future<Either<Failure, List<Screenshot>>> getGameScreenshots(
      int gameId) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      print('📸 GameRepository: Getting screenshots for game: $gameId');

      final screenshots =
          await igdbDataSource.getScreenshots(gameIds: [gameId]);

      print('✅ GameRepository: Found ${screenshots.length} screenshots');
      return Right(screenshots);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return const Left(
          ServerFailure(message: 'Failed to get game screenshots'));
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
      return const Left(ServerFailure(message: 'Failed to get game artwork'));
    }
  }

  @override
  Future<Either<Failure, GameMediaCollection>> getGameMediaCollection(
      int gameId) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      print(
          '📱 GameRepository: Getting complete media collection for game: $gameId');

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

      print(
          '✅ GameRepository: Media collection loaded - ${mediaCollection.totalMediaCount} total items');
      return Right(mediaCollection);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return const Left(
          ServerFailure(message: 'Failed to get game media collection'));
    }
  }

  // ==========================================
  // CHARACTER DISCOVERY & SEARCH
  // ==========================================

  @override
  Future<Either<Failure, List<Character>>> searchCharacters(
      String query) async {
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
      return const Left(ServerFailure(message: 'Failed to search characters'));
    }
  }

  @override
  Future<Either<Failure, List<Character>>> getPopularCharacters(
      {int limit = 20}) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      print('⭐ GameRepository: Getting popular characters (limit: $limit)');

      final characters =
          await igdbDataSource.getPopularCharacters(limit: limit);

      print('✅ GameRepository: Found ${characters.length} popular characters');
      return Right(characters);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return const Left(
          ServerFailure(message: 'Failed to get popular characters'));
    }
  }

  @override
  Future<Either<Failure, List<Character>>> getCharactersByGender(
      CharacterGenderEnum gender) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      print('👤 GameRepository: Getting ${gender.displayName} characters');

      // Convert enum to IGDB enum - FIX: Use proper conversion
      final igdbGender = CharacterGenderEnum.fromValue(gender.value);
      final characters = await igdbDataSource.getCharactersByGender(igdbGender);

      print(
          '✅ GameRepository: Found ${characters.length} ${gender.displayName} characters');
      return Right(characters);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return const Left(
          ServerFailure(message: 'Failed to get characters by gender'));
    }
  }

  @override
  Future<Either<Failure, List<Character>>> getCharactersBySpecies(
      CharacterSpeciesEnum species) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      print('🧬 GameRepository: Getting ${species.displayName} characters');

      // Convert enum to IGDB enum - FIX: Use proper conversion
      final igdbSpecies = CharacterSpeciesEnum.fromValue(species.value);
      final characters =
          await igdbDataSource.getCharactersBySpecies(igdbSpecies);

      print(
          '✅ GameRepository: Found ${characters.length} ${species.displayName} characters');
      return Right(characters);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return const Left(
          ServerFailure(message: 'Failed to get characters by species'));
    }
  }

  @override
  Future<Either<Failure, List<Game>>> getGamesByCharacter(
      int characterId) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      print('🎮 GameRepository: Getting games for character: $characterId');

      // First get character to extract game IDs
      final character = await getCharacterDetails(characterId);
      if (character.isLeft()) {
        return character.fold((failure) => Left(failure),
            (char) => throw Exception('Unexpected success'));
      }

      final characterData = character.fold(
          (l) => throw Exception('Unexpected failure'), (r) => r);
      final gameIds = characterData.gameIds;

      if (gameIds.isEmpty) {
        return const Right([]);
      }

      // Get full game data
      final games = await igdbDataSource.getGamesByIds(gameIds);
      final enrichedGames = await _enrichGamesWithUserData(games);

      print(
          '✅ GameRepository: Found ${enrichedGames.length} games for character');
      return Right(enrichedGames);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return const Left(
          ServerFailure(message: 'Failed to get games by character'));
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
      return const Left(ServerFailure(message: 'Failed to search events'));
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
      return const Left(ServerFailure(message: 'Failed to get event details'));
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
        return event.fold((failure) => Left(failure),
            (evt) => throw Exception('Unexpected success'));
      }

      final eventData =
          event.fold((l) => throw Exception('Unexpected failure'), (r) => r);
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
      return const Left(ServerFailure(message: 'Failed to get event games'));
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

      print(
          '🔄 GameRepository: Enriching game ${game.id} with user data for ${currentUser.id}');

      // Get user-specific game data
      final userGameData =
          await supabaseDataSource.getUserGameData(currentUser.id, game.id);

      // Get top three games for position check
      final topThreeData =
          await supabaseDataSource.getUserTopThreeGames(userId: currentUser.id);
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

      print(
          '🔄 GameRepository: Enriching ${games.length} games with user data');

      // Get user data for all games in batch
      final gameIds = games.map((game) => game.id).toList();
      final batchUserData = await supabaseDataSource.getBatchUserGameData(
          gameIds, currentUser.id);

      // Get top three games
      final topThreeData =
          await supabaseDataSource.getUserTopThreeGames(userId: currentUser.id);
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

      print(
          '✅ GameRepository: Successfully enriched ${enrichedGames.length} games with user data');
      return enrichedGames;
    } catch (e) {
      print('⚠️ GameRepository: Error enriching games with user data: $e');
      return games;
    }
  }

  /// Apply complex filters that require IGDB game data
  List<GameModel> _applyComplexFilters(
      List<GameModel> games, UserCollectionFilters filters) {
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
        return game.platforms
            .any((platform) => filters.platformIds.contains(platform.id));
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

        if (filters.releaseDateFrom != null &&
            releaseDate.isBefore(filters.releaseDateFrom!)) {
          return false;
        }
        if (filters.releaseDateTo != null &&
            releaseDate.isAfter(filters.releaseDateTo!)) {
          return false;
        }
        return true;
      }).toList();
    }

    return filteredGames;
  }

  /// Apply sorting to games list
  List<GameModel> _applySorting(
      List<GameModel> games, UserCollectionSortBy sortBy, SortOrder sortOrder,
      [Map<int, double>? userRatings]) {
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

      print(
          '💔 GameRepository: Batch removing ${gameIds.length} games from wishlist');

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
      return const Left(
          ServerFailure(message: 'Failed to batch remove from wishlist'));
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

      print(
          '🔄 GameRepository: Moving ${gameIds.length} games from ${fromCollection.displayName} to ${toCollection.displayName}');

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
      return const Left(
          ServerFailure(message: 'Failed to move games between collections'));
    }
  }

  // ==========================================
  // USER COLLECTIONS EXTENDED
  // ==========================================

  @override
  Future<Either<Failure, Map<UserCollectionType, UserCollectionSummary>>>
      getAllUserCollectionSummaries(String userId) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      print(
          '📊 GameRepository: Getting all collection summaries for user: $userId');

      // Execute all summary requests concurrently
      final results = await Future.wait([
        getUserCollectionSummary(
            userId: userId, collectionType: UserCollectionType.wishlist),
        getUserCollectionSummary(
            userId: userId, collectionType: UserCollectionType.rated),
        getUserCollectionSummary(
            userId: userId, collectionType: UserCollectionType.recommended),
        getUserCollectionSummary(
            userId: userId, collectionType: UserCollectionType.topThree),
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
        UserCollectionType.wishlist: results[0]
            .fold((l) => throw Exception('Unexpected failure'), (r) => r),
        UserCollectionType.rated: results[1]
            .fold((l) => throw Exception('Unexpected failure'), (r) => r),
        UserCollectionType.recommended: results[2]
            .fold((l) => throw Exception('Unexpected failure'), (r) => r),
        UserCollectionType.topThree: results[3]
            .fold((l) => throw Exception('Unexpected failure'), (r) => r),
      };

      print('✅ GameRepository: All collection summaries loaded');
      return Right(summaries);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return const Left(
          ServerFailure(message: 'Failed to get all collection summaries'));
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
            final topThreeData =
                await supabaseDataSource.getUserTopThreeGames(userId: userId);
            gameIds = topThreeData
                .map<int>((data) => data['game_id'] as int)
                .toList();
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
        filteredGames =
            _applySorting(filteredGames, filters.sortBy, filters.sortOrder);
      }

      // Apply pagination
      final paginatedGames = filteredGames.skip(offset).take(limit).toList();

      // Enrich with user data
      final enrichedGames = await _enrichGamesWithUserData(paginatedGames);

      print(
          '✅ GameRepository: Found ${enrichedGames.length} games in user collections');
      return Right(enrichedGames);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return const Left(
          ServerFailure(message: 'Failed to search user collections'));
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

      print(
          '📅 GameRepository: Getting recently added games (last $days days)');

      final cutoffDate = DateTime.now().subtract(Duration(days: days));
      final recentlyAddedData =
          await supabaseDataSource.getRecentlyAddedToCollections(
        userId: userId,
        sinceDate: cutoffDate,
        limit: limit,
      );

      if (recentlyAddedData.isEmpty) {
        return const Right([]);
      }

      // Extract game IDs
      final gameIds =
          recentlyAddedData.map<int>((data) => data['game_id'] as int).toList();

      // Get game data
      final games = await igdbDataSource.getGamesByIds(gameIds);

      // Sort by added date (most recent first)
      games.sort((a, b) {
        final addedDateA = recentlyAddedData
            .firstWhere((data) => data['game_id'] == a.id)['added_at'];
        final addedDateB = recentlyAddedData
            .firstWhere((data) => data['game_id'] == b.id)['added_at'];
        return DateTime.parse(addedDateB).compareTo(DateTime.parse(addedDateA));
      });

      // Enrich with user data
      final enrichedGames = await _enrichGamesWithUserData(games);

      print(
          '✅ GameRepository: Found ${enrichedGames.length} recently added games');
      return Right(enrichedGames);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return const Left(
          ServerFailure(message: 'Failed to get recently added games'));
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

      final topGenres =
          await supabaseDataSource.getUserTopGenres(userId, limit: limit);

      print('✅ GameRepository: Found ${topGenres.length} top genres');
      return Right(topGenres);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return const Left(
          ServerFailure(message: 'Failed to get user top genres'));
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
      return const Left(
          ServerFailure(message: 'Failed to get user activity timeline'));
    }
  }

  // ==========================================
  // USER ANALYTICS & PREFERENCES
  // ==========================================

  @override
  Future<Either<Failure, Map<String, double>>> getUserGenrePreferences(
      String userId) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      print('🎯 GameRepository: Analyzing genre preferences for user: $userId');

      final preferences =
          await supabaseDataSource.getUserGenrePreferences(userId);

      print('✅ GameRepository: Genre preferences analyzed');
      return Right(preferences);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return const Left(
          ServerFailure(message: 'Failed to get genre preferences'));
    }
  }

  @override
  Future<Either<Failure, Map<String, int>>> getUserPlatformStatistics(
      String userId) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      print('🎮 GameRepository: Getting platform statistics for user: $userId');

      final statistics =
          await supabaseDataSource.getUserPlatformStatistics(userId);

      print('✅ GameRepository: Platform statistics retrieved');
      return Right(statistics);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return const Left(
          ServerFailure(message: 'Failed to get platform statistics'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getUserRatingAnalytics(
      String userId) async {
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
      return const Left(
          ServerFailure(message: 'Failed to get rating analytics'));
    }
  }

  @override
  Future<Either<Failure, List<Event>>> getGameEvents(int gameId) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      print('🎪 GameRepository: Getting events for game: $gameId');

      // Use enhanced method for complete event data
      final events =
          await igdbDataSource.getEventsByGamesWithCompleteData([gameId]);

      print(
          '✅ GameRepository: Found ${events.length} events with complete data');
      print(
          '📊 GameRepository: Events have logos: ${events.where((e) => e.hasLogoObject).length}');
      print(
          '📊 GameRepository: Events have networks: ${events.where((e) => e.hasNetworkObjects).length}');
      print(
          '📊 GameRepository: Events have games: ${events.where((e) => e.hasGameObjects).length}');

      return Right(events);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return const Left(ServerFailure(message: 'Failed to get game events'));
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

      // Get basic game details first
      final gameResult = await getGameDetails(gameId);
      if (gameResult.isLeft()) {
        return gameResult;
      }

      final game = gameResult.fold(
          (l) => throw Exception('Unexpected failure'), (r) => r);

      // Prepare futures for concurrent loading
      List<Future> futures = [];

      if (includeCharacters) {
        futures.add(igdbDataSource.getCharactersForGames([gameId]));
      }

      if (includeEvents) {
        // Use enhanced method for complete event data
        futures.add(igdbDataSource.getEventsByGamesWithCompleteData([gameId]));
      }

      if (includeMedia) {
        futures.add(igdbDataSource.getGameVideos([gameId]));
        futures.add(igdbDataSource.getScreenshots(gameIds: [gameId]));
        futures.add(igdbDataSource.getArtworks(gameIds: [gameId]));
      }

      // Execute all requests concurrently
      final results = futures.isNotEmpty ? await Future.wait(futures) : [];

      // Parse results
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
      print(
          '📊 GameRepository: ${characters.length} characters, ${events.length} events, ${videos.length + screenshots.length + artworks.length} media items');

      // Print event details for debugging
      if (events.isNotEmpty) {
        print('📊 GameRepository: Event details:');
        for (final event in events) {
          print(
              '  - ${event.name}: ${event.games.length} games, ${event.eventNetworks.length} networks');
        }
      }

      return Right(enhancedGame);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return const Left(
          ServerFailure(message: 'Failed to get enhanced game details'));
    }
  }

  Future<Either<Failure, List<Game>>> getCompleteFranchiseGames(
      int franchiseId) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      print(
          '🏢 GameRepository: Getting complete franchise games for ID: $franchiseId');

      // Lade ALLE Franchise-Spiele ohne Limit
      final franchiseGames = await igdbDataSource.getGamesByFranchise(
        franchiseId: franchiseId,
        limit: 100000, // Kein Limit = alle Spiele
      );

      final enrichedGames = await _enrichGamesWithUserData(franchiseGames);

      print('✅ GameRepository: Loaded ${enrichedGames.length} franchise games');
      return Right(enrichedGames);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return const Left(
          ServerFailure(message: 'Failed to load franchise games'));
    }
  }

  Future<Either<Failure, List<Game>>> getCompleteCollectionGames(
      int collectionId) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      print(
          '📚 GameRepository: Getting complete collection games for ID: $collectionId');

      // Lade ALLE Collection-Spiele ohne Limit
      final collectionGames = await igdbDataSource.getGamesByCollection(
        collectionId: collectionId,
        limit: 100000, // Kein Limit = alle Spiele
      );

      final enrichedGames = await _enrichGamesWithUserData(collectionGames);

      print(
          '✅ GameRepository: Loaded ${enrichedGames.length} collection games');
      return Right(enrichedGames);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return const Left(
          ServerFailure(message: 'Failed to load collection games'));
    }
  }

  // In game_repository_impl.dart implementieren:
  @override
  Future<Either<Failure, Platform>> getPlatformDetails(int platformId) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      print('🎮 GameRepository: Getting platform details: $platformId');

      final platformData =
          await igdbDataSource.getCompletePlatformDataWithVersions(platformId);

      if (platformData.isEmpty) {
        return const Left(NotFoundFailure(message: 'Platform not found'));
      }

      final platform = _parseCompletePlatformData(platformData);
      if (platform == null) {
        return const Left(ServerFailure(message: 'Failed to parse platform'));
      }

      print('✅ GameRepository: Platform loaded: ${platform.name}');
      return Right(platform);
    } catch (e) {
      return Left(ServerFailure(message: 'Platform details failed: $e'));
    }
  }

  Platform? _parseCompletePlatformData(Map<String, dynamic> data) {
    try {
      // Extract platform logo image ID from nested data
      final logoData = data['platform_logo'];
      if (logoData is Map<String, dynamic>) {}

      // Parse platform logo
      PlatformLogo? logo;
      if (logoData is Map<String, dynamic>) {
        logo = PlatformLogo(
          id: logoData['id'] ?? 0,
          url: logoData['url'],
          imageId: logoData['image_id']?.toString() ?? '',
          width: logoData['width'],
          height: logoData['height'],
          alphaChannel: logoData['alpha_channel'],
          animated: logoData['animated'] ?? false,
          checksum: logoData['checksum'] ?? '',
        );
      }

      // Parse category enum
      PlatformCategoryEnum? categoryEnum;
      if (data['category'] is int) {
        final categoryValue = data['category'] as int;
        switch (categoryValue) {
          case 1:
            categoryEnum = PlatformCategoryEnum.console;
            break;
          case 2:
            categoryEnum = PlatformCategoryEnum.arcade;
            break;
          case 3:
            categoryEnum = PlatformCategoryEnum.platform;
            break;
          case 4:
            categoryEnum = PlatformCategoryEnum.operatingSystem;
            break;
          case 5:
            categoryEnum = PlatformCategoryEnum.portableConsole;
            break;
          case 6:
            categoryEnum = PlatformCategoryEnum.computer;
            break;
        }
      }

      // Create platform with parsed data
      return PlatformModel(
        id: data['id'] ?? 0,
        checksum: data['checksum'] ?? '',
        name: data['name'] ?? '',
        abbreviation: data['abbreviation'],
        alternativeName: data['alternative_name'],
        generation: data['generation'],
        platformFamilyId: data['platform_family'] is Map
            ? data['platform_family']['id']
            : data['platform_family'],
        platformLogoId: logoData is Map ? logoData['id'] : logoData,
        logo: logo,
        platformTypeId: data['platform_type'],
        slug: data['slug'] ?? '',
        summary: data['summary'],
        url: data['url'],
        versionIds: _parseIdList(data['versions']),
        websiteIds: _parseIdList(data['websites']),
        createdAt: _parseDateTime(data['created_at']),
        updatedAt: _parseDateTime(data['updated_at']),
        categoryEnum: categoryEnum,
        category: data['category'],
      );
    } catch (e) {
      print('❌ GameRepository: Error parsing platform data: $e');
      return null;
    }
  }

  @override
  Future<Either<Failure, GameEngine>> getGameEngineDetails(
      int gameEngineId) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      print('🎮 GameRepository: Getting gameEngine details: $gameEngineId');

      final gameEngineData =
          await igdbDataSource.getCompleteGameEngineData(gameEngineId);

      if (gameEngineData.isEmpty) {
        return const Left(NotFoundFailure(message: 'GameEngine not found'));
      }

      final gameEngine = _parseCompleteGameEngineData(gameEngineData);
      if (gameEngine == null) {
        return const Left(ServerFailure(message: 'Failed to parse gameEngine'));
      }

      print('✅ GameRepository: GameEngine loaded: ${gameEngine.name}');
      return Right(gameEngine);
    } catch (e) {
      return Left(ServerFailure(message: 'GameEngine details failed: $e'));
    }
  }

  @override
  Future<Either<Failure, Company>> getCompanyDetails(
      int companyId, String? userId) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      print('🏢 GameRepository: Getting complete company details: $companyId');

      // 1. Hol das Company Model mit allen related data
      final companyModel =
          await igdbDataSource.getCompleteCompanyDetails(companyId);

      // 2. Enrich developed games with user data
      List<Game> enrichedDevelopedGames = companyModel.developedGames ?? [];
      if (userId != null && enrichedDevelopedGames.isNotEmpty) {
        enrichedDevelopedGames =
            await _enrichGamesWithUserData(enrichedDevelopedGames);
        print(
            '✅ Enriched ${enrichedDevelopedGames.length} developed games with user data');
      }

      // 3. Enrich published games with user data
      List<Game> enrichedPublishedGames = companyModel.publishedGames ?? [];
      if (userId != null && enrichedPublishedGames.isNotEmpty) {
        enrichedPublishedGames =
            await _enrichGamesWithUserData(enrichedPublishedGames);
        print(
            '✅ Enriched ${enrichedPublishedGames.length} published games with user data');
      }

      print('✅ GameRepository: Company loaded: ${companyModel.name}');
      return Right(companyModel);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Company details failed: $e'));
    }
  }

  GameEngine? _parseCompleteGameEngineData(Map<String, dynamic> data) {
    try {
      print('🔧 Parsing complete GameEngine data: ${data['name']}');

      // ✅ PARSE GAME ENGINE LOGO OBJECT
      GameEngineLogo? logo;
      final logoData = data['logo'];
      if (logoData is Map<String, dynamic>) {
        try {
          logo = GameEngineLogoModel.fromJson(logoData);
          print('🔧 Engine Logo created: ${logo.logoMedUrl}');
        } catch (e) {
          print('❌ Error creating engine logo: $e');
        }
      }

      // ✅ PARSE COMPANIES
      List<Company> companies = [];
      if (data['companies'] is List) {
        for (var companyData in data['companies']) {
          if (companyData is Map<String, dynamic>) {
            try {
              // Enhanced company parsing with logo support
              CompanyLogo? companyLogo;
              if (companyData['logo'] is Map<String, dynamic>) {
                companyLogo = CompanyLogoModel.fromJson(companyData['logo']);
              }

              final company = Company(
                id: companyData['id'] ?? 0,
                checksum: companyData['checksum'] ?? '',
                name: companyData['name'] ?? '',
                slug: companyData['slug'],
                description: companyData['description'],
                url: companyData['url'],
                logo: companyLogo,
                logoId: companyData['logo'] is Map
                    ? companyData['logo']['id']
                    : companyData['logo'],
                country: companyData['country'],
                createdAt: _parseDateTime(companyData['created_at']),
                updatedAt: _parseDateTime(companyData['updated_at']),
              );
              companies.add(company);
            } catch (e) {
              print('❌ Error parsing company: $e');
            }
          }
        }
      }

      // ✅ PARSE PLATFORMS
      List<Platform> platforms = [];
      if (data['platforms'] is List) {
        for (var platformData in data['platforms']) {
          if (platformData is Map<String, dynamic>) {
            try {
              // Enhanced platform parsing with logo support
              PlatformLogo? platformLogo;
              if (platformData['platform_logo'] is Map<String, dynamic>) {
                platformLogo =
                    PlatformLogoModel.fromJson(platformData['platform_logo']);
              }

              final platform = Platform(
                id: platformData['id'] ?? 0,
                checksum: platformData['checksum'] ?? '',
                name: platformData['name'] ?? '',
                slug: platformData['slug'] ?? '',
                abbreviation: platformData['abbreviation'],
                alternativeName: platformData['alternative_name'],
                generation: platformData['generation'],
                logo: platformLogo,
                platformLogoId: platformData['platform_logo'] is Map
                    ? platformData['platform_logo']['id']
                    : platformData['platform_logo'],
                summary: platformData['summary'],
                url: platformData['url'],
                createdAt: _parseDateTime(platformData['created_at']),
                updatedAt: _parseDateTime(platformData['updated_at']),
              );
              platforms.add(platform);
            } catch (e) {
              print('❌ Error parsing platform: $e');
            }
          }
        }
      }

      // ✅ Create enhanced GameEngine with all objects
      final gameEngine = GameEngine(
        id: data['id'] ?? 0,
        checksum: data['checksum'] ?? '',
        name: data['name'] ?? '',
        description: data['description'],
        logoId: logoData is Map ? logoData['id'] : logoData,
        logo: logo, // ✅ Logo-Objekt
        slug: data['slug'],
        url: data['url'],
        companyIds: _parseIdList(data['companies']),
        platformIds: _parseIdList(data['platforms']),
        companies: companies, // ✅ Vollständige Company-Objekte
        platforms: platforms, // ✅ Vollständige Platform-Objekte
        createdAt: _parseDateTime(data['created_at']),
        updatedAt: _parseDateTime(data['updated_at']),
      );

      print(
          '✅ GameEngine parsed: ${gameEngine.name} with ${companies.length} companies and ${platforms.length} platforms');
      return gameEngine;
    } catch (e) {
      print('❌ GameRepository: Error parsing complete gameEngine data: $e');
      return null;
    }
  }

  @override
  Future<Either<Failure, List<Game>>> getGamesByGameEngine({
    required List<int> gameEngineIds,
    int limit = 20,
    int offset = 0,
    GameSortBy sortBy = GameSortBy.ratingCount,
    SortOrder sortOrder = SortOrder.descending,
  }) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      if (gameEngineIds.isEmpty) {
        return const Right([]);
      }

      print('🎮 GameRepository: Getting games by gameEngines: $gameEngineIds');

      final games = await igdbDataSource.getGamesByGameEngines(
        gameEngineIds: gameEngineIds,
        limit: limit,
        offset: offset,
        sortBy: sortBy.igdbField,
        sortOrder: sortOrder.value,
      );

      final enrichedGames = await _enrichGamesWithUserData(games);

      print(
          '✅ GameRepository: Found ${enrichedGames.length} games for gameEngines');
      return Right(enrichedGames);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return const Left(
          ServerFailure(message: 'Failed to get games by gameEngine'));
    }
  }

  @override
  Future<Either<Failure, List<Game>>> getGamesByCompany({
    required List<int> companyIds,
    int limit = 20,
    int offset = 0,
    GameSortBy sortBy = GameSortBy.ratingCount,
    SortOrder sortOrder = SortOrder.descending,
  }) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      if (companyIds.isEmpty) {
        return const Right([]);
      }

      print('🎮 GameRepository: Getting games by companies: $companyIds');

      final games = await igdbDataSource.getGamesByCompanies(
        companyIds: companyIds,
        limit: limit,
        offset: offset,
        sortBy: sortBy.igdbField,
        sortOrder: sortOrder.value,
      );

      final enrichedGames = await _enrichGamesWithUserData(games);

      print(
          '✅ GameRepository: Found ${enrichedGames.length} games for companies');
      return Right(enrichedGames);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return const Left(
          ServerFailure(message: 'Failed to get games by company'));
    }
  }
}
