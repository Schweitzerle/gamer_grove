import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import 'package:gamer_grove/domain/repositories/game_repository.dart';
import 'package:gamer_grove/domain/usecases/base_usecase.dart';

class GetUserRatedGameIds extends UseCase<List<int>, GetUserRatedGameIdsParams> {

  GetUserRatedGameIds(this.repository);
  final GameRepository repository;

  @override
  Future<Either<Failure, List<int>>> call(GetUserRatedGameIdsParams params) async {
    return repository.getUserRatedGameIds(params.userId);
  }
}

class GetUserRatedGameIdsParams extends Equatable {

  const GetUserRatedGameIdsParams({required this.userId});
  final String userId;

  @override
  List<Object> get props => [userId];
}
