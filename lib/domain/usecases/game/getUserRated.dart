// domain/usecases/game/get_user_wishlist.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/errors/failures.dart';
import '../../entities/game.dart';
import '../../repositories/game_repository.dart';
import '../base_usecase.dart';
class GetUserRated extends UseCase<List<Game>, GetUserRatedParams> {
  final GameRepository repository;

  GetUserRated(this.repository);

  @override
  Future<Either<Failure, List<Game>>> call(GetUserRatedParams params) async {
    if (params.userId.isEmpty) {
      return const Left(ValidationFailure(message: 'User ID cannot be empty'));
    }

    return await repository.getUserRatedGames(params.userId);
  }
}

class GetUserRatedParams extends Equatable {
  final String userId;

  const GetUserRatedParams({required this.userId});

  @override
  List<Object> get props => [userId];
}

