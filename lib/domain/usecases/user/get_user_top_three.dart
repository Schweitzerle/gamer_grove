// lib/domain/usecases/user/get_user_top_three.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import 'package:gamer_grove/domain/repositories/user_repository.dart';
import 'package:gamer_grove/domain/usecases/base_usecase.dart';

class GetUserTopThreeGames
    extends UseCase<List<Map<String, dynamic>>, GetUserTopThreeGamesParams> {

  GetUserTopThreeGames(this.repository);
  final UserRepository repository;

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> call(
      GetUserTopThreeGamesParams params,) async {
    if (params.userId.isEmpty) {
      return const Left(ValidationFailure(message: 'User ID cannot be empty'));
    }

    return repository.getUserTopThreeGames(
      userId: params.userId,
    );
  }
}

class GetUserTopThreeGamesParams extends Equatable {

  const GetUserTopThreeGamesParams({required this.userId});
  final String userId;

  @override
  List<Object> get props => [userId];
}
