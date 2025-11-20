// ==========================================

// lib/domain/usecases/grove_page/get_grove_page_data.dart
// Composite Use Case for efficient Grove page loading
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import 'package:gamer_grove/domain/entities/game/game.dart';
import 'package:gamer_grove/domain/entities/user/user_collection_sort_options.dart';
import 'package:gamer_grove/domain/entities/user/user_collection_summary.dart';
import 'package:gamer_grove/domain/usecases/base_usecase.dart';
import 'package:gamer_grove/domain/usecases/user_collections/get_all_user_collections.dart';
import 'package:gamer_grove/domain/usecases/user_collections/get_user_collection_summary.dart';
import 'package:gamer_grove/domain/usecases/user_collections/get_user_gaming_statistics.dart';

class GetGrovePageData extends UseCase<GrovePageData, GetGrovePageDataParams> {

  GetGrovePageData({
    required this.getAllUserCollections,
    required this.getUserCollectionSummary,
    required this.getUserGamingStatistics,
  });
  final GetAllUserCollections getAllUserCollections;
  final GetUserCollectionSummary getUserCollectionSummary;
  final GetUserGamingStatistics getUserGamingStatistics;

  @override
  Future<Either<Failure, GrovePageData>> call(GetGrovePageDataParams params) async {
    try {
      // Execute all requests concurrently for better performance
      final results = await Future.wait([
        getAllUserCollections(GetAllUserCollectionsParams(
          userId: params.userId,
          limitPerCollection: params.limitPerCollection,
        ),),
        getUserCollectionSummary(GetUserCollectionSummaryParams(
          userId: params.userId,
          collectionType: UserCollectionType.wishlist,
        ),),
        getUserCollectionSummary(GetUserCollectionSummaryParams(
          userId: params.userId,
          collectionType: UserCollectionType.rated,
        ),),
        getUserCollectionSummary(GetUserCollectionSummaryParams(
          userId: params.userId,
          collectionType: UserCollectionType.recommended,
        ),),
        getUserGamingStatistics(GetUserGamingStatisticsParams(userId: params.userId)),
      ]);

      // Check if any request failed
      for (final result in results) {
        if (result.isLeft()) {
          return result.fold(
                Left.new,
                (data) => throw Exception('Unexpected success in fold'),
          );
        }
      }

      // Extract successful results
      final collections = results[0].fold((l) => <UserCollectionType, List<Game>>{}, (r) => r as Map<UserCollectionType, List<Game>>);
      final wishlistSummary = results[1].fold((l) => null, (r) => r as UserCollectionSummary?);
      final ratedSummary = results[2].fold((l) => null, (r) => r as UserCollectionSummary?);
      final recommendedSummary = results[3].fold((l) => null, (r) => r as UserCollectionSummary?);
      final gamingStats = results[4].fold((l) => <String, dynamic>{}, (r) => r as Map<String, dynamic>);

      final summaries = <UserCollectionType, UserCollectionSummary>{};
      if (wishlistSummary != null) summaries[UserCollectionType.wishlist] = wishlistSummary;
      if (ratedSummary != null) summaries[UserCollectionType.rated] = ratedSummary;
      if (recommendedSummary != null) summaries[UserCollectionType.recommended] = recommendedSummary;

      return Right(GrovePageData(
        collections: collections,
        summaries: summaries,
        gamingStatistics: gamingStats,
      ),);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to load Grove page data: $e'));
    }
  }
}

class GetGrovePageDataParams extends Equatable {

  const GetGrovePageDataParams({
    required this.userId,
    this.limitPerCollection = 6, // Show 6 games per collection on overview
  });
  final String userId;
  final int limitPerCollection;

  @override
  List<Object> get props => [userId, limitPerCollection];
}

class GrovePageData extends Equatable {

  const GrovePageData({
    required this.collections,
    required this.summaries,
    required this.gamingStatistics,
  });
  final Map<UserCollectionType, List<Game>> collections;
  final Map<UserCollectionType, UserCollectionSummary> summaries;
  final Map<String, dynamic> gamingStatistics;

  // Helper getters
  List<Game> get wishlistGames => collections[UserCollectionType.wishlist] ?? [];
  List<Game> get ratedGames => collections[UserCollectionType.rated] ?? [];
  List<Game> get recommendedGames => collections[UserCollectionType.recommended] ?? [];
  List<Game> get topThreeGames => collections[UserCollectionType.topThree] ?? [];

  UserCollectionSummary? get wishlistSummary => summaries[UserCollectionType.wishlist];
  UserCollectionSummary? get ratedSummary => summaries[UserCollectionType.rated];
  UserCollectionSummary? get recommendedSummary => summaries[UserCollectionType.recommended];

  int get totalGamesInCollections => summaries.values.fold(0, (sum, summary) => sum + summary.totalCount);
  double? get overallAverageRating => ratedSummary?.averageRating;

  @override
  List<Object> get props => [collections, summaries, gamingStatistics];
}