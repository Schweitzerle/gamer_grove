// ==========================================

// lib/domain/usecases/user_collections/batch_manage_wishlist.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import 'package:gamer_grove/domain/repositories/game_repository.dart';
import 'package:gamer_grove/domain/usecases/base_usecase.dart';

class BatchAddToWishlist extends UseCase<void, BatchAddToWishlistParams> {

  BatchAddToWishlist(this.repository);
  final GameRepository repository;

  @override
  Future<Either<Failure, void>> call(BatchAddToWishlistParams params) async {
    if (params.userId.isEmpty) {
      return const Left(ValidationFailure(message: 'User ID cannot be empty'));
    }
    if (params.gameIds.isEmpty) {
      return const Left(ValidationFailure(message: 'Game IDs cannot be empty'));
    }

    return repository.batchAddToWishlist(
      userId: params.userId,
      gameIds: params.gameIds,
    );
  }
}

class BatchAddToWishlistParams extends Equatable {

  const BatchAddToWishlistParams({
    required this.userId,
    required this.gameIds,
  });
  final String userId;
  final List<int> gameIds;

  @override
  List<Object> get props => [userId, gameIds];
}

