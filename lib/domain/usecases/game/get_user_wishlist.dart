// domain/usecases/game/get_user_wishlist.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import 'package:gamer_grove/domain/entities/game/game.dart';
import 'package:gamer_grove/domain/repositories/game_repository.dart';
import 'package:gamer_grove/domain/usecases/base_usecase.dart';
class GetUserWishlist extends UseCase<List<Game>, GetUserWishlistParams> {

  GetUserWishlist(this.repository);
  final GameRepository repository;

  @override
  Future<Either<Failure, List<Game>>> call(GetUserWishlistParams params) async {
    if (params.userId.isEmpty) {
      return const Left(ValidationFailure(message: 'User ID cannot be empty'));
    }

    return repository.getUserWishlist(params.userId, params.limit, params.offset);
  }
}

class GetUserWishlistParams extends Equatable {

  const GetUserWishlistParams({required this.userId, required this.limit, required this.offset});
  final String userId;
  final int limit;
  final int offset;

  @override
  List<Object> get props => [userId];
}

