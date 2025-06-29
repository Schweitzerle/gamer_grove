// ==================================================
// ERWEITERTE GAME REPOSITORY INTERFACE
// ==================================================

// lib/domain/repositories/game_repository.dart (UPDATED)
import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/game/game.dart';
import '../entities/company/company.dart';
import '../entities/game/game_video.dart';
import '../entities/website/website.dart';
import '../entities/ageRating/age_rating.dart';

abstract class GameRepository {
  // EXISTING METHODS
  Future<Either<Failure, List<Game>>> searchGames(String query, int limit, int offset);
  Future<Either<Failure, Game>> getGameDetails(int gameId);
  Future<Either<Failure, List<Game>>> getPopularGames(int limit, int offset);
  Future<Either<Failure, List<Game>>> getUpcomingGames(int limit, int offset);
  Future<Either<Failure, List<Game>>> getGamesByIds(List<int> gameIds);
  Future<Either<Failure, List<Game>>> getUserWishlist(String userId, int limit, int offset);
  Future<Either<Failure, List<Game>>> getUserRecommendations(String userId, int limit, int offset);
  Future<Either<Failure, List<Game>>> getUserRated(String userId, int limit, int offset);
  Future<Either<Failure, List<Game>>> getUserTopThreeGames(String userId);
  Future<Either<Failure, void>> rateGame(int gameId, String userId, double rating);
  Future<Either<Failure, void>> toggleWishlist(int gameId, String userId);
  Future<Either<Failure, void>> toggleRecommend(int gameId, String userId);

  // NEW METHODS FOR EXTENDED API
  Future<Either<Failure, Game>> getCompleteGameDetails(int gameId, String? userId);
  Future<Either<Failure, List<Company>>> getCompanies({List<int>? ids, String? search});
  Future<Either<Failure, List<Website>>> getGameWebsites(List<int> gameIds);
  Future<Either<Failure, List<GameVideo>>> getGameVideos(List<int> gameIds);
  Future<Either<Failure, List<AgeRating>>> getGameAgeRatings(List<int> gameIds);
  Future<Either<Failure, List<Game>>> getSimilarGames(int gameId);
  Future<Either<Failure, List<Game>>> getGameDLCs(int gameId);
  Future<Either<Failure, List<Game>>> getGameExpansions(int gameId);
  Future<Either<Failure, Game>> getGameDetailsWithUserData(int gameId, String? userId);
}