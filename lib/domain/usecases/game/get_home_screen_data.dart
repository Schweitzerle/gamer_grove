// lib/domain/usecases/game/get_home_screen_data.dart
// Composite Use Case for efficient home screen loading
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/errors/failures.dart';
import '../../entities/game/game.dart';
import '../base_usecase.dart';
import 'get_newest_games.dart';
import 'get_popular_games.dart';
import 'get_top_rated_games.dart';
import 'get_upcoming_games.dart';
import 'get_wishlist_recent_releases.dart';

class GetHomeScreenData extends UseCase<HomeScreenData, GetHomeScreenDataParams> {
  final GetPopularGames getPopularGames;
  final GetTopRatedGames getTopRatedGames;
  final GetNewestGames getNewestGames;
  final GetUpcomingGames getUpcomingGames;
  final GetWishlistRecentReleases getWishlistRecentReleases;

  GetHomeScreenData({
    required this.getPopularGames,
    required this.getTopRatedGames,
    required this.getNewestGames,
    required this.getUpcomingGames,
    required this.getWishlistRecentReleases,
  });

  @override
  Future<Either<Failure, HomeScreenData>> call(GetHomeScreenDataParams params) async {
    try {
      // Execute all requests concurrently for better performance
      final List<Either<Failure, dynamic>> results = await Future.wait([
        getPopularGames(GetPopularGamesParams(limit: params.limit)),
        getTopRatedGames(GetTopRatedGamesParams(limit: params.limit)),
        getNewestGames(GetNewestGamesParams(limit: params.limit)),
        getUpcomingGames(GetUpcomingGamesParams(limit: params.limit)),
        if (params.userId != null)
          getWishlistRecentReleases(GetWishlistRecentReleasesParams.defaultRange(userId: params.userId!))
        else
          Future.value(const Right(<Game>[])),
      ]);

      // Check if any request failed
      for (final result in results) {
        if (result.isLeft()) {
          return result.fold(
                (failure) => Left(failure),
                (data) => throw Exception('Unexpected success in fold'),
          );
        }
      }

      // Extract successful results
      final popularGames = results[0].fold((l) => <Game>[], (r) => r as List<Game>);
      final topRatedGames = results[1].fold((l) => <Game>[], (r) => r as List<Game>);
      final newestGames = results[2].fold((l) => <Game>[], (r) => r as List<Game>);
      final upcomingGames = results[3].fold((l) => <Game>[], (r) => r as List<Game>);
      final wishlistReleases = results[4].fold((l) => <Game>[], (r) => r as List<Game>);

      return Right(HomeScreenData(
        popularGames: popularGames,
        topRatedGames: topRatedGames,
        newestGames: newestGames,
        upcomingGames: upcomingGames,
        wishlistRecentReleases: wishlistReleases,
      ));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to load home screen data: $e'));
    }
  }
}

class GetHomeScreenDataParams extends Equatable {
  final String? userId; // nullable for non-authenticated users
  final int limit;

  const GetHomeScreenDataParams({
    this.userId,
    this.limit = 10,
  });

  @override
  List<Object?> get props => [userId, limit];
}

class HomeScreenData extends Equatable {
  final List<Game> popularGames;
  final List<Game> topRatedGames;
  final List<Game> newestGames;
  final List<Game> upcomingGames;
  final List<Game> wishlistRecentReleases;

  const HomeScreenData({
    required this.popularGames,
    required this.topRatedGames,
    required this.newestGames,
    required this.upcomingGames,
    required this.wishlistRecentReleases,
  });

  @override
  List<Object> get props => [
    popularGames,
    topRatedGames,
    newestGames,
    upcomingGames,
    wishlistRecentReleases,
  ];
}