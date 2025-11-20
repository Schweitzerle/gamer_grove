import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import 'package:gamer_grove/domain/entities/game/game.dart';
import 'package:gamer_grove/domain/repositories/game_repository.dart';
import 'package:gamer_grove/domain/usecases/base_usecase.dart';

class GetUserRated extends UseCase<List<Game>, GetUserRatedParams> {

  GetUserRated(this.repository);
  final GameRepository repository;

  @override
  Future<Either<Failure, List<Game>>> call(GetUserRatedParams params) async {
    if (params.userId.isEmpty) {
      return const Left(ValidationFailure(message: 'User ID cannot be empty'));
    }

    return repository.getUserRated(
        params.userId, params.limit, params.offset,);
  }
}

class GetUserRatedParams extends Equatable {

  const GetUserRatedParams(
      {required this.userId, required this.limit, required this.offset,});
  final String userId;
  final int limit;
  final int offset;

  @override
  List<Object> get props => [userId];
}
