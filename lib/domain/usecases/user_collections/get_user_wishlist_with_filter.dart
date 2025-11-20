// ==========================================
// PHASE 3 USE CASES FOR GROVE PAGE (USER COLLECTIONS)
// ==========================================

// lib/domain/usecases/user_collections/get_user_wishlist_with_filters.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import 'package:gamer_grove/domain/entities/game/game.dart';
import 'package:gamer_grove/domain/entities/user/user_collection_filters.dart';
import 'package:gamer_grove/domain/repositories/game_repository.dart';
import 'package:gamer_grove/domain/usecases/base_usecase.dart';

class GetUserWishlistWithFilters extends UseCase<List<Game>, GetUserWishlistWithFiltersParams> {

  GetUserWishlistWithFilters(this.repository);
  final GameRepository repository;

  @override
  Future<Either<Failure, List<Game>>> call(GetUserWishlistWithFiltersParams params) async {
    if (params.userId.isEmpty) {
      return const Left(ValidationFailure(message: 'User ID cannot be empty'));
    }

    return repository.getUserWishlistWithFilters(
      userId: params.userId,
      filters: params.filters,
      limit: params.limit,
      offset: params.offset,
    );
  }
}

class GetUserWishlistWithFiltersParams extends Equatable {

  const GetUserWishlistWithFiltersParams({
    required this.userId,
    required this.filters,
    this.limit = 20,
    this.offset = 0,
  });
  final String userId;
  final UserCollectionFilters filters;
  final int limit;
  final int offset;

  @override
  List<Object> get props => [userId, filters, limit, offset];
}

