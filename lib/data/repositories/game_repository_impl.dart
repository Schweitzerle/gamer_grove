// data/repositories/game_repository_impl.dart
import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/game/game.dart';
import '../../domain/entities/ageRating/age_rating.dart';
import '../../domain/entities/company/company.dart';
import '../../domain/entities/game/game_video.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/website/website.dart';
import '../../domain/repositories/game_repository.dart';
import '../datasources/local/cache_datasource.dart';
import '../datasources/remote/igdb/idgb_remote_datasource.dart';
import '../datasources/remote/supabase_remote_datasource.dart';
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
  Future<Either<Failure, List<GameVideo>>> getGameVideos(List<int> gameIds) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      print('🎥 GameRepository: Getting videos for ${gameIds.length} games');

      final videos = await igdbDataSource.getGameVideos(gameIds);

      print('✅ GameRepository: Loaded ${videos.length} videos');
      return Right(videos);

    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to load game videos'));
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

      print('🏆 GameRepository: Getting top 3 games for user: $userId');

      // Get top 3 game data from Supabase
      final topThreeData = await supabaseDataSource.getUserTopThreeGames(userId);

      if (topThreeData.isEmpty) {
        return const Right([]);
      }

      // Extract game IDs
      final gameIds = topThreeData.map<int>((data) => data['game_id'] as int).toList();

      // Get enhanced game data
      final games = await igdbDataSource.getGamesByIds(gameIds);
      final enrichedGames = await _enrichGamesWithUserData(games);

      // Sort by position
      enrichedGames.sort((a, b) {
        final posA = a.topThreePosition ?? 999;
        final posB = b.topThreePosition ?? 999;
        return posA.compareTo(posB);
      });

      print('✅ GameRepository: Loaded ${enrichedGames.length} top 3 games');
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
  // ENHANCED HELPER METHODS
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
      final topThreeData = await supabaseDataSource.getUserTopThreeGames(currentUser.id);
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
      final topThreeData = await supabaseDataSource.getUserTopThreeGames(currentUser.id);
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

      print(
          '❤️ GameRepository: Getting wishlist recent releases for user: $userId');
      print('📅 GameRepository: Date range: ${fromDate.toString()} to ${toDate
          .toString()}');

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

      print('✅ GameRepository: Found ${enrichedGames
          .length} wishlist games with recent/upcoming releases');
      return Right(enrichedGames);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(
          ServerFailure(message: 'Failed to load wishlist recent releases'));
    }
  }
}