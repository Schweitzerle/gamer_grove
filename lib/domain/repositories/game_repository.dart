// lib/domain/repositories/game_repository.dart
import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/game/game.dart';
import '../entities/company/company.dart';
import '../entities/game/game_video.dart';
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
  Future<Either<Failure, List<Game>>> searchGames(
      String query,
      int limit,
      int offset
      );

  /// Get basic game details by ID
  Future<Either<Failure, Game>> getGameDetails(int gameId);

  /// Get complete game details with all related data
  Future<Either<Failure, Game>> getCompleteGameDetails(
      int gameId,
      String? userId
      );

  /// Get game details enriched with user-specific data
  Future<Either<Failure, Game>> getGameDetailsWithUserData(
      int gameId,
      String? userId
      );

  /// Get multiple games by their IDs (batch operation)
  Future<Either<Failure, List<Game>>> getGamesByIds(List<int> gameIds);

  // ==========================================
  // POPULAR & UPCOMING GAMES
  // ==========================================

  /// Get popular games with pagination
  Future<Either<Failure, List<Game>>> getPopularGames(int limit, int offset);

  /// Get upcoming games with pagination
  Future<Either<Failure, List<Game>>> getUpcomingGames(int limit, int offset);

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

  /// Get videos (trailers, gameplay, etc.) for games
  Future<Either<Failure, List<GameVideo>>> getGameVideos(List<int> gameIds);

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
  Future<Either<Failure, List<Game>>> getUserWishlist(
      String userId,
      int limit,
      int offset
      );

  /// Get user's recommended games with pagination
  Future<Either<Failure, List<Game>>> getUserRecommendations(
      String userId,
      int limit,
      int offset
      );

  /// Get user's rated games with pagination
  Future<Either<Failure, List<Game>>> getUserRated(
      String userId,
      int limit,
      int offset
      );

  /// Get user's top three favorite games
  Future<Either<Failure, List<Game>>> getUserTopThreeGames(String userId);

  // ==========================================
  // USER ACTIONS
  // ==========================================

  /// Rate a game (0-10 scale)
  Future<Either<Failure, void>> rateGame(
      int gameId,
      String userId,
      double rating
      );

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
  Future<Either<Failure, List<Game>>> getWishlistRecentReleases(
  String userId,
  {DateTime? fromDate, DateTime? toDate}
  );
}