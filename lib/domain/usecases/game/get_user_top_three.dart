// domain/usecases/game/get_user_wishlist.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/errors/failures.dart';
import '../../entities/game/game.dart';
import '../../repositories/game_repository.dart';
import '../base_usecase.dart';
class GetUserTopThree extends UseCase<List<Game>, GetUserTopThreeParams> {
  final GameRepository repository;

  GetUserTopThree(this.repository);

  @override
  Future<Either<Failure, List<Game>>> call(GetUserTopThreeParams params) async {
    if (params.userId.isEmpty) {
      return const Left(ValidationFailure(message: 'User ID cannot be empty'));
    }

    return await repository.getUserTopThreeGames(params.userId);
  }
}

class GetUserTopThreeParams extends Equatable {
  final String userId;

  const GetUserTopThreeParams({required this.userId});

  @override
  List<Object> get props => [userId];
}

