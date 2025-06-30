// ==========================================

// lib/domain/usecases/user_collections/batch_manage_wishlist.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/errors/failures.dart';
import '../../repositories/game_repository.dart';
import '../base_usecase.dart';

class BatchAddToWishlist extends UseCase<void, BatchAddToWishlistParams> {
  final GameRepository repository;

  BatchAddToWishlist(this.repository);

  @override
  Future<Either<Failure, void>> call(BatchAddToWishlistParams params) async {
    if (params.userId.isEmpty) {
      return const Left(ValidationFailure(message: 'User ID cannot be empty'));
    }
    if (params.gameIds.isEmpty) {
      return const Left(ValidationFailure(message: 'Game IDs cannot be empty'));
    }

    return await repository.batchAddToWishlist(
      userId: params.userId,
      gameIds: params.gameIds,
    );
  }
}

class BatchAddToWishlistParams extends Equatable {
  final String userId;
  final List<int> gameIds;

  const BatchAddToWishlistParams({
    required this.userId,
    required this.gameIds,
  });

  @override
  List<Object> get props => [userId, gameIds];
}

