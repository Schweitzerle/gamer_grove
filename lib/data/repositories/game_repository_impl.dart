// data/repositories/game_repository_impl.dart
import '../../domain/entities/ageRating/age_rating.dart';
import '../../domain/entities/company/company.dart';
import '../../domain/entities/game/game_video.dart';
import '../../domain/entities/website/website.dart';
import '../../injection_container.dart';
import '../../../presentation/blocs/auth/auth_bloc.dart';
import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/game/game.dart';
import '../../domain/repositories/game_repository.dart';
import '../datasources/local/cache_datasource.dart';
import '../datasources/remote/idgb_remote_datasource.dart';
import '../datasources/remote/supabase_remote_datasource.dart';
import '../models/game/game_model.dart';

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


  @override
  Future<Either<Failure, Game>> getGameDetails(int gameId) async {
    // Check cache first
    final cachedGame = await localDataSource.getCachedGameDetails(gameId);
    if (cachedGame != null) {
      return Right(await _enrichGameWithUserData(cachedGame));
    }

    // Check network
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      // Get game details from IGDB
      final game = await igdbDataSource.getGameDetails(gameId);

      // Cache the game details
      await localDataSource.cacheGameDetails(gameId, game);

      // Enrich with user data
      return Right(await _enrichGameWithUserData(game));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<Game>>> searchGames(
      String query, int limit, int offset) async {
    // Check cache first
    final cachedResults = await localDataSource.getCachedSearchResults(query);
    if (cachedResults != null && cachedResults.isNotEmpty) {
      return Right(await _enrichGamesWithUserData(cachedResults)); // await hinzugefügt
    }

    // Check network
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(
        message: 'No internet connection. Please check your network.',
      ));
    }

    try {
      // Search games from IGDB
      final games = await igdbDataSource.searchGames(query, limit, offset);

      // Cache the results
      await localDataSource.cacheSearchResults(query, games);

      // Enrich with user data
      return Right(await _enrichGamesWithUserData(games)); // await hinzugefügt
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(
        message: 'An unexpected error occurred while searching games.',
      ));
    }
  }


  @override
  Future<Either<Failure, List<Game>>> getPopularGames(int limit, int offset) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final games = await igdbDataSource.getUpcomingGames(limit, offset);
      return Right(await _enrichGamesWithUserData(games));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<Game>>> getUpcomingGames(int limit, int offset) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final games = await igdbDataSource.getUpcomingGames(limit, offset);
      return Right(await _enrichGamesWithUserData(games));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<Game>>> getGamesByIds(List<int> gameIds) async {
    if (gameIds.isEmpty) {
      return const Right([]);
    }

    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final games = await igdbDataSource.getGamesByIds(gameIds);
      return Right(await _enrichGamesWithUserData(games));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> toggleWishlist(int gameId, String userId) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      await supabaseDataSource.toggleWishlist(gameId, userId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> toggleRecommended({
    required int gameId,
    required String userId,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      await supabaseDataSource.toggleRecommended(gameId, userId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> rateGame(int gameId, String userId, double rating) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      await supabaseDataSource.rateGame(gameId, userId, rating);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<Game>>> getUserWishlist(String userId, int limit, int offset) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final gameIds = await supabaseDataSource.getUserWishlistIds(userId);
      if (gameIds.isEmpty) {
        return const Right([]);
      }

      return getGamesByIds(gameIds);
    } catch (e) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<Game>>> getUserRecommendations(String userId, int limit, int offset) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final gameIds = await supabaseDataSource.getUserRecommendedIds(userId);
      if (gameIds.isEmpty) {
        return const Right([]);
      }

      return getGamesByIds(gameIds);
    } catch (e) {
      return const Left(ServerFailure());
    }
  }



  @override
  Future<Either<Failure, List<Game>>> getUserRatedGames(String userId) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final gameIds = await supabaseDataSource.getUserRatedIds(userId);
      if (gameIds.isEmpty) {
        return const Right([]);
      }

      return getGamesByIds(gameIds);
    } catch (e) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<Game>>> getUserTopThreeGames(String userId) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final gameIds = await supabaseDataSource.getTopThreeGames(userId);
      if (gameIds.isEmpty) {
        return const Right([]);
      }

      return getGamesByIds(gameIds);
    } catch (e) {
      return const Left(ServerFailure());
    }
  }

// Helper methods to enrich games with user data
  Future<List<Game>> _enrichGamesWithUserData(List<GameModel> games) async {
    // Get current user ID from AuthBloc
    String? currentUserId;
    try {
      final authBloc = sl<AuthBloc>();
      final authState = authBloc.state;
      if (authState is Authenticated) {
        currentUserId = authState.user.id;
      }
    } catch (e) {
      // If we can't get the auth bloc, proceed without user data
      print('Could not get current user for enriching games: $e');
    }

    if (currentUserId == null || games.isEmpty) {
      // No user logged in or no games to enrich
      return games;
    }

    try {
      // Get all user data for these games in batch
      final gameIds = games.map((g) => g.id).toList();

      // Get wishlisted games
      final wishlistedIds = await supabaseDataSource.getUserWishlistIds(currentUserId);
      final wishlistedSet = wishlistedIds.toSet();

      // Get recommended games
      final recommendedIds = await supabaseDataSource.getUserRecommendedIds(currentUserId);
      final recommendedSet = recommendedIds.toSet();

      // Get user ratings
      final ratings = await supabaseDataSource.getUserRatings(currentUserId);

      // Get top three data
      final topThreeData = await supabaseDataSource.getTopThreeGamesWithPosition(currentUserId);
      final topThreeMap = <int, int>{};
      for (var entry in topThreeData) {
        topThreeMap[entry['game_id'] as int] = entry['position'] as int;
      }

      // Enrich each game with user data
      return games.map((game) {
        return game.copyWith(
          isWishlisted: wishlistedSet.contains(game.id),
          isRecommended: recommendedSet.contains(game.id),
          userRating: ratings[game.id]!,
          isInTopThree: topThreeMap.containsKey(game.id),
          topThreePosition: topThreeMap[game.id],
        );
      }).toList();
    } catch (e) {
      print('Error enriching games with user data: $e');
      // If there's an error, return games without user data
      return games;
    }
  }

  Future<Game> _enrichGameWithUserData(GameModel game) async {
    // Get current user ID from AuthBloc
    String? currentUserId;
    try {
      final authBloc = sl<AuthBloc>();
      final authState = authBloc.state;
      if (authState is Authenticated) {
        currentUserId = authState.user.id;
      }
    } catch (e) {
      print('Could not get current user for enriching game: $e');
    }

    if (currentUserId == null) {
      return game;
    }

    try {
      final userGameData = await supabaseDataSource.getUserGameData(currentUserId, game.id);
      final topThreeData = await supabaseDataSource.getTopThreeGamesWithPosition(currentUserId);
      final topThreeMap = <int, int>{};
      for (var entry in topThreeData) {
        topThreeMap[entry['game_id'] as int] = entry['position'] as int;
      }

      return game.copyWith(
        isWishlisted: userGameData?['is_wishlisted'] ?? false,
        isRecommended: userGameData?['is_recommended'] ?? false,
        userRating: userGameData?['rating']?.toDouble(),
        isInTopThree: topThreeMap.containsKey(game.id),
        topThreePosition: topThreeMap[game.id],
      );
    } catch (e) {
      print('Error enriching game with user data: $e');
      return game;
    }
  }

  @override
  Future<Either<Failure, Game>> getCompleteGameDetails(int gameId, String? userId) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      print('🎮 GameRepository: Getting COMPLETE game details for ID: $gameId');

      // Get complete game data from IGDB
      final gameModel = await igdbDataSource.getCompleteGameDetails(gameId);

      // Get user-specific data if user is logged in
      Game game = gameModel;
      if (userId != null) {
        game = await _enrichGameWithUserData(gameModel);
      }

      // Cache the complete game data
      await localDataSource.cacheGameDetails(gameId, gameModel);

      print('✅ GameRepository: Complete game details loaded successfully');
      return Right(game);
    } on ServerException catch (e) {
      print('💥 GameRepository: Server error: ${e.message}');
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      print('💥 GameRepository: Unexpected error: $e');
      return Left(ServerFailure(message: 'Failed to load complete game details'));
    }
  }

  @override
  Future<Either<Failure, List<Company>>> getCompanies({List<int>? ids, String? search}) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final companies = await igdbDataSource.getCompanies(ids: ids, search: search);
      return Right(companies);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to load companies'));
    }
  }

  @override
  Future<Either<Failure, List<Website>>> getGameWebsites(List<int> gameIds) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final websites = await igdbDataSource.getWebsites(gameIds);
      return Right(websites);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to load game websites'));
    }
  }

  @override
  Future<Either<Failure, List<GameVideo>>> getGameVideos(List<int> gameIds) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final videos = await igdbDataSource.getGameVideos(gameIds);
      return Right(videos);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to load game videos'));
    }
  }

  @override
  Future<Either<Failure, List<AgeRating>>> getGameAgeRatings(List<int> gameIds) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final ageRatings = await igdbDataSource.getAgeRatings(gameIds);
      return Right(ageRatings);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to load age ratings'));
    }
  }

  @override
  Future<Either<Failure, List<Game>>> getSimilarGames(int gameId) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final similarGames = await igdbDataSource.getSimilarGames(gameId);
      return Right(similarGames);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to load similar games'));
    }
  }

  @override
  Future<Either<Failure, List<Game>>> getGameDLCs(int gameId) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final dlcs = await igdbDataSource.getGameDLCs(gameId);
      return Right(dlcs);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to load game DLCs'));
    }
  }

  @override
  Future<Either<Failure, List<Game>>> getGameExpansions(int gameId) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final expansions = await igdbDataSource.getGameExpansions(gameId);
      return Right(expansions);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to load game expansions'));
    }
  }

  @override
  Future<Either<Failure, Game>> getGameDetailsWithUserData(int gameId, String? userId) async {
    if (!await networkInfo.isConnected) {
      // Try to get from cache first
      try {
        final cachedGame = await localDataSource.getCachedGameDetails(gameId);
        if (cachedGame != null && userId != null) {
          final enrichedGame = await _enrichGameWithUserData(cachedGame);
          return Right(enrichedGame);
        }
      } catch (e) {
        print('⚠️ GameRepository: Cache read failed: $e');
      }
      return const Left(NetworkFailure());
    }

    try {
      // Get basic game details from IGDB
      final gameModel = await igdbDataSource.getGameDetails(gameId);

      // Enrich with user data if user is logged in
      Game game = gameModel;
      if (userId != null) {
        game = await _enrichGameWithUserData(gameModel);
      }

      // Cache the game
      await localDataSource.cacheGameDetails(gameId, gameModel);

      return Right(game);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to load game details'));
    }
  }


  @override
  Future<Either<Failure, List<Game>>> getUserRated(String userId, int limit, int offset) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final gameIds = await supabaseDataSource.getUserRatedIds(userId);
      if (gameIds.isEmpty) {
        return const Right([]);
      }

      return getGamesByIds(gameIds);
    } catch (e) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> toggleRecommend(int gameId, String userId) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      await supabaseDataSource.toggleRecommended(gameId, userId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return const Left(ServerFailure());
    }
  }
}