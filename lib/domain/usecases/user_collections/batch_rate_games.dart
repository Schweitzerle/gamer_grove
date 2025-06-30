// ==========================================

// lib/domain/usecases/user_collections/batch_rate_games.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/errors/failures.dart';
import '../../repositories/game_repository.dart';
import '../base_usecase.dart';

class BatchRateGames extends UseCase<void, BatchRateGamesParams> {
  final GameRepository repository;

  BatchRateGames(this.repository);

  @override
  Future<Either<Failure, void>> call(BatchRateGamesParams params) async {
    if (params.userId.isEmpty) {
      return const Left(ValidationFailure(message: 'User ID cannot be empty'));
    }
    if (params.gameRatings.isEmpty) {
      return const Left(ValidationFailure(message: 'Game ratings cannot be empty'));
    }

    // Validate ratings are in valid range (0-10)
    for (final rating in params.gameRatings.values) {
      if (rating < 0 || rating > 10) {
        return const Left(ValidationFailure(message: 'Ratings must be between 0 and 10'));
      }
    }

    return await repository.batchRateGames(
      userId: params.userId,
      gameRatings: params.gameRatings,
    );
  }
}

class BatchRateGamesParams extends Equatable {
  final String userId;
  final Map<int, double> gameRatings; // gameId -> rating

  const BatchRateGamesParams({
    required this.userId,
    required this.gameRatings,
  });

  @override
  List<Object> get props => [userId, gameRatings];
}

