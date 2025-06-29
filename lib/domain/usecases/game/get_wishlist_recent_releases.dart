// lib/domain/usecases/game/get_wishlist_recent_releases.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/errors/failures.dart';
import '../../entities/game/game.dart';
import '../../repositories/game_repository.dart';
import '../base_usecase.dart';

class GetWishlistRecentReleases extends UseCase<List<Game>, GetWishlistRecentReleasesParams> {
  final GameRepository repository;

  GetWishlistRecentReleases(this.repository);

  @override
  Future<Either<Failure, List<Game>>> call(GetWishlistRecentReleasesParams params) async {
    return await repository.getWishlistRecentReleases(
      params.userId,
      fromDate: params.fromDate,
      toDate: params.toDate,
    );
  }
}

class GetWishlistRecentReleasesParams extends Equatable {
  final String userId;
  final DateTime? fromDate;
  final DateTime? toDate;

  const GetWishlistRecentReleasesParams({
    required this.userId,
    this.fromDate, // defaults to 1 month ago
    this.toDate,   // defaults to 2 weeks from now
  });

  // Helper constructor for default date range (1 month ago to 2 weeks from now)
  GetWishlistRecentReleasesParams.defaultRange({
    required this.userId,
  }) : fromDate = DateTime.now().subtract(const Duration(days: 30)),
        toDate = DateTime.now().add(const Duration(days: 14));

  @override
  List<Object?> get props => [userId, fromDate, toDate];
}


