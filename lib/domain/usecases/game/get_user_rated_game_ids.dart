import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import 'package:gamer_grove/domain/repositories/game_repository.dart';
import 'package:gamer_grove/domain/usecases/base_usecase.dart';

class GetUserRatedGameIds extends UseCase<List<int>, GetUserRatedGameIdsParams> {
  final GameRepository repository;

  GetUserRatedGameIds(this.repository);

  @override
  Future<Either<Failure, List<int>>> call(GetUserRatedGameIdsParams params) async {
    return await repository.getUserRatedGameIds(params.userId);
  }
}

class GetUserRatedGameIdsParams extends Equatable {
  final String userId;

  const GetUserRatedGameIdsParams({required this.userId});

  @override
  List<Object> get props => [userId];
}
