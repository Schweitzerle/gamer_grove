// domain/usecases/game/get_user_wishlist.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import 'package:gamer_grove/domain/entities/game/game.dart';
import 'package:gamer_grove/domain/repositories/game_repository.dart';
import 'package:gamer_grove/domain/usecases/base_usecase.dart';
class GetUserTopThree extends UseCase<List<Game>, GetUserTopThreeParams> {

  GetUserTopThree(this.repository);
  final GameRepository repository;

  @override
  Future<Either<Failure, List<Game>>> call(GetUserTopThreeParams params) async {
    if (params.userId.isEmpty) {
      return const Left(ValidationFailure(message: 'User ID cannot be empty'));
    }

    return repository.getUserTopThreeGames(params.userId);
  }
}

class GetUserTopThreeParams extends Equatable {

  const GetUserTopThreeParams({required this.userId});
  final String userId;

  @override
  List<Object> get props => [userId];
}

