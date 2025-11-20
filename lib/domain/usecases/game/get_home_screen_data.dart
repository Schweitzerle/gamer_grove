// lib/domain/usecases/game/get_home_screen_data.dart
// Composite Use Case for efficient home screen loading
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import 'package:gamer_grove/domain/entities/game/game.dart';
import 'package:gamer_grove/domain/usecases/base_usecase.dart';
import 'package:gamer_grove/domain/usecases/game/get_newest_games.dart';
import 'package:gamer_grove/domain/usecases/game/get_popular_games.dart';
import 'package:gamer_grove/domain/usecases/game/get_top_rated_games.dart';
import 'package:gamer_grove/domain/usecases/game/get_upcoming_games.dart';
import 'package:gamer_grove/domain/usecases/game/get_wishlist_recent_releases.dart';

class GetHomeScreenData
    extends UseCase<HomeScreenData, GetHomeScreenDataParams> {
  GetHomeScreenData({
    required this.getPopularGames,
    required this.getTopRatedGames,
    required this.getNewestGames,
    required this.getUpcomingGames,
    required this.getWishlistRecentReleases,
  });
  final GetPopularGames getPopularGames;
  final GetTopRatedGames getTopRatedGames;
  final GetNewestGames getNewestGames;
  final GetUpcomingGames getUpcomingGames;
  final GetWishlistRecentReleases getWishlistRecentReleases;

  @override
  Future<Either<Failure, HomeScreenData>> call(
      GetHomeScreenDataParams params) async {
    try {
      // Define the list of futures with an explicit type
      final futures = <Future<Either<Failure, List<Game>>>>[
        getPopularGames(GetPopularGamesParams(limit: params.limit)),
        getTopRatedGames(GetTopRatedGamesParams(limit: params.limit)),
        getNewestGames(GetNewestGamesParams(limit: params.limit)),
        getUpcomingGames(GetUpcomingGamesParams(limit: params.limit)),
      ];

      if (params.userId != null) {
        futures.add(
          getWishlistRecentReleases(
            GetWishlistRecentReleasesParams.defaultRange(
                userId: params.userId!),
          ),
        );
      } else {
        // Add an empty list for non-authenticated users
        futures.add(Future.value(const Right(<Game>[])));
      }

      // Execute all requests concurrently for better performance
      final results = await Future.wait(futures);

      // Check if any request failed
      for (final result in results) {
        if (result.isLeft()) {
          return result.fold(
              Left.new, (r) => throw Exception('Should not be Right'));
        }
      }

      // Extract successful results
      final popularGames = (results[0] as Right<Failure, List<Game>>).value;
      final topRatedGames = (results[1] as Right<Failure, List<Game>>).value;
      final newestGames = (results[2] as Right<Failure, List<Game>>).value;
      final upcomingGames = (results[3] as Right<Failure, List<Game>>).value;
      final wishlistReleases = (results[4] as Right<Failure, List<Game>>).value;

      return Right(
        HomeScreenData(
          popularGames: popularGames,
          topRatedGames: topRatedGames,
          newestGames: newestGames,
          upcomingGames: upcomingGames,
          wishlistRecentReleases: wishlistReleases,
        ),
      );
    } on Exception catch (e) {
      return Left(
          ServerFailure(message: 'Failed to load home screen data: $e'));
    }
  }
}

class GetHomeScreenDataParams extends Equatable {
  const GetHomeScreenDataParams({
    this.userId,
    this.limit = 10,
  });
  final String? userId; // nullable for non-authenticated users
  final int limit;

  @override
  List<Object?> get props => [userId, limit];
}

class HomeScreenData extends Equatable {
  const HomeScreenData({
    required this.popularGames,
    required this.topRatedGames,
    required this.newestGames,
    required this.upcomingGames,
    required this.wishlistRecentReleases,
  });
  final List<Game> popularGames;
  final List<Game> topRatedGames;
  final List<Game> newestGames;
  final List<Game> upcomingGames;
  final List<Game> wishlistRecentReleases;

  @override
  List<Object> get props => [
        popularGames,
        topRatedGames,
        newestGames,
        upcomingGames,
        wishlistRecentReleases,
      ];
}
