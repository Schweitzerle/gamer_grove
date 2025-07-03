// lib/domain/usecases/user/get_user_top_three.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/errors/failures.dart';
import '../../entities/game/game.dart';
import '../../repositories/user_repository.dart';
import '../base_usecase.dart';

class GetUserTopThreeGames extends UseCase<List<Map<String, dynamic>>, GetUserTopThreeGamesParams> {
  final UserRepository repository;

  GetUserTopThreeGames(this.repository);

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> call(GetUserTopThreeGamesParams params) async {
    if (params.userId.isEmpty) {
      return const Left(ValidationFailure(message: 'User ID cannot be empty'));
    }

    return await repository.getUserTopThreeGames(
      userId: params.userId,
    );
  }
}

class GetUserTopThreeGamesParams extends Equatable {
  final String userId;

  const GetUserTopThreeGamesParams({required this.userId});

  @override
  List<Object> get props => [userId];
}