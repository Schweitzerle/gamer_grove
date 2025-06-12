// data/repositories/game_repository_impl.dart
import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/game.dart';
import '../../domain/repositories/game_repository.dart';
import '../datasources/local/cache_datasource.dart';
import '../datasources/remote/idgb_remote_datasource.dart';
import '../datasources/remote/supabase_remote_datasource.dart';
import '../models/game_model.dart';

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
  Future<Either<Failure, List<Game>>> searchGames({
    required String query,
    int limit = 20,
    int offset = 0,
  }) async {
    // Check cache first
    final cachedResults = await localDataSource.getCachedSearchResults(query);
    if (cachedResults != null && cachedResults.isNotEmpty) {
      return Right(_enrichGamesWithUserData(cachedResults));
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
      return Right(_enrichGamesWithUserData(games));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(
        message: 'An unexpected error occurred while searching games.',
      ));
    }
  }

  @override
  Future<Either<Failure, Game>> getGameDetails(int gameId) async {
    // Check cache first
    final cachedGame = await localDataSource.getCachedGameDetails(gameId);
    if (cachedGame != null) {
      return Right(_enrichGameWithUserData(cachedGame));
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
      return Right(_enrichGameWithUserData(game));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<Game>>> getPopularGames({
    int limit = 20,
    int offset = 0,
  }) async {
    if (!await networkInfo.isConnected) {
      // Try to get from cache
      final cachedGames = await localDataSource.getCachedGames();
      if (cachedGames.isNotEmpty) {
        return Right(_enrichGamesWithUserData(cachedGames));
      }
      return const Left(NetworkFailure());
    }

    try {
      final games = await igdbDataSource.getPopularGames(limit, offset);

      // Cache popular games
      if (offset == 0) {
        await localDataSource.cacheGames(games);
      }

      return Right(_enrichGamesWithUserData(games));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<Game>>> getUpcomingGames({
    int limit = 20,
    int offset = 0,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final games = await igdbDataSource.getUpcomingGames(limit, offset);
      return Right(_enrichGamesWithUserData(games));
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
      return Right(_enrichGamesWithUserData(games));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> toggleWishlist({
    required int gameId,
    required String userId,
  }) async {
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
  Future<Either<Failure, void>> rateGame({
    required int gameId,
    required String userId,
    required double rating,
  }) async {
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
  Future<Either<Failure, List<Game>>> getUserWishlist(String userId) async {
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
  Future<Either<Failure, List<Game>>> getUserRecommendations(String userId) async {
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
      final ratings = await supabaseDataSource.getUserRatings(userId);
      if (ratings.isEmpty) {
        return const Right([]);
      }

      final gameIds = ratings.keys.toList();
      final gamesResult = await getGamesByIds(gameIds);

      return gamesResult.fold(
            (failure) => Left(failure),
            (games) {
          // Add user ratings to games
          final gamesWithRatings = games.map((game) {
            final userRating = ratings[game.id];
            return game.copyWith(userRating: userRating);
          }).toList();

          return Right(gamesWithRatings);
        },
      );
    } catch (e) {
      return const Left(ServerFailure());
    }
  }

  // Helper methods to enrich games with user data
  List<Game> _enrichGamesWithUserData(List<GameModel> games) {
    // TODO: Get current user ID and enrich games with user-specific data
    // For now, just return the games as is
    return games;
  }

  Game _enrichGameWithUserData(GameModel game) {
    // TODO: Get current user ID and enrich game with user-specific data
    // For now, just return the game as is
    return game;
  }
}