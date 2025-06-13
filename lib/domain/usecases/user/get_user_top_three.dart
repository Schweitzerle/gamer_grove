// lib/domain/usecases/user/get_user_top_three.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/errors/failures.dart';
import '../../repositories/user_repository.dart';
import '../base_usecase.dart';

class GetUserTopThreeGames implements UseCase<List<int>, GetUserTopThreeGamesParams> {
  final UserRepository repository;

  GetUserTopThreeGames(this.repository);

  @override
  Future<Either<Failure, List<int>>> call(GetUserTopThreeGamesParams params) async {
    return await repository.getUserTopThreeGames(params.userId);
  }
}

class GetUserTopThreeGamesParams extends Equatable {
  final String userId;

  const GetUserTopThreeGamesParams({required this.userId});

  @override
  List<Object> get props => [userId];
}