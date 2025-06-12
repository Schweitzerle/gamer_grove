// domain/repositories/game_repository.dart
import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/game.dart';

abstract class GameRepository {
  // IGDB Operations
  Future<Either<Failure, List<Game>>> searchGames({
    required String query,
    int limit = 20,
    int offset = 0,
  });

  Future<Either<Failure, Game>> getGameDetails(int gameId);

  Future<Either<Failure, List<Game>>> getPopularGames({
    int limit = 20,
    int offset = 0,
  });

  Future<Either<Failure, List<Game>>> getUpcomingGames({
    int limit = 20,
    int offset = 0,
  });

  Future<Either<Failure, List<Game>>> getGamesByIds(List<int> gameIds);

  // User-specific operations (Supabase)
  Future<Either<Failure, void>> toggleWishlist({
    required int gameId,
    required String userId,
  });

  Future<Either<Failure, void>> toggleRecommended({
    required int gameId,
    required String userId,
  });

  Future<Either<Failure, void>> rateGame({
    required int gameId,
    required String userId,
    required double rating,
  });

  Future<Either<Failure, List<Game>>> getUserWishlist(String userId);

  Future<Either<Failure, List<Game>>> getUserRecommendations(String userId);

  Future<Either<Failure, List<Game>>> getUserRatedGames(String userId);
}


