// domain/usecases/game/get_user_recommendations.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/errors/failures.dart';
import '../../entities/game.dart';
import '../../repositories/game_repository.dart';
import '../base_usecase.dart';

class GetUserRecommendations extends UseCase<List<Game>, GetUserRecommendationsParams> {
  final GameRepository repository;

  GetUserRecommendations(this.repository);

  @override
  Future<Either<Failure, List<Game>>> call(GetUserRecommendationsParams params) async {
    if (params.userId.isEmpty) {
      return const Left(ValidationFailure(message: 'User ID cannot be empty'));
    }

    return await repository.getUserRecommendations(params.userId, params.limit, params.offset);
  }
}

class GetUserRecommendationsParams extends Equatable {
  final String userId;
  final int limit;
  final int offset;

  const GetUserRecommendationsParams({required this.userId, required this.limit, required this.offset, });

  @override
  List<Object> get props => [userId];
}