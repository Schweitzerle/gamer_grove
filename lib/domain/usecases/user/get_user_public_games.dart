// ==========================================

// lib/domain/usecases/user/get_user_public_games.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import 'package:gamer_grove/domain/repositories/user_repository.dart';
import 'package:gamer_grove/domain/usecases/base_usecase.dart';

class GetUserPublicRatedGames
    extends UseCase<List<Map<String, dynamic>>, GetUserPublicGamesParams> {

  GetUserPublicRatedGames(this.repository);
  final UserRepository repository;

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> call(
      GetUserPublicGamesParams params,) async {
    if (params.userId.isEmpty) {
      return const Left(ValidationFailure(message: 'User ID cannot be empty'));
    }

    return repository.getUserPublicRatedGames(
      userId: params.userId,
      currentUserId: params.currentUserId,
      limit: params.limit,
      offset: params.offset,
    );
  }
}

class GetUserPublicRecommendedGames
    extends UseCase<List<Map<String, dynamic>>, GetUserPublicGamesParams> {

  GetUserPublicRecommendedGames(this.repository);
  final UserRepository repository;

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> call(
      GetUserPublicGamesParams params,) async {
    if (params.userId.isEmpty) {
      return const Left(ValidationFailure(message: 'User ID cannot be empty'));
    }

    return repository.getUserPublicRecommendedGames(
      userId: params.userId,
      currentUserId: params.currentUserId,
      limit: params.limit,
      offset: params.offset,
    );
  }
}

class GetUserPublicGamesParams extends Equatable {

  const GetUserPublicGamesParams({
    required this.userId,
    this.currentUserId,
    this.limit = 20,
    this.offset = 0,
  });
  final String userId;
  final String? currentUserId;
  final int limit;
  final int offset;

  @override
  List<Object?> get props => [userId, currentUserId, limit, offset];
}
