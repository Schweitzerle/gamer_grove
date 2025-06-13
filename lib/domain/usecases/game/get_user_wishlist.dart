// domain/usecases/game/get_user_wishlist.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/errors/failures.dart';
import '../../entities/game.dart';
import '../../repositories/game_repository.dart';
import '../base_usecase.dart';
class GetUserWishlist extends UseCase<List<Game>, GetUserWishlistParams> {
  final GameRepository repository;

  GetUserWishlist(this.repository);

  @override
  Future<Either<Failure, List<Game>>> call(GetUserWishlistParams params) async {
    if (params.userId.isEmpty) {
      return const Left(ValidationFailure(message: 'User ID cannot be empty'));
    }

    return await repository.getUserWishlist(params.userId);
  }
}

class GetUserWishlistParams extends Equatable {
  final String userId;

  const GetUserWishlistParams({required this.userId});

  @override
  List<Object> get props => [userId];
}

