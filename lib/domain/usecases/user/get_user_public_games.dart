// ==========================================

// lib/domain/usecases/user/get_user_public_games.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/errors/failures.dart';
import '../../entities/game/game.dart';
import '../../repositories/user_repository.dart';
import '../base_usecase.dart';

class GetUserPublicRatedGames extends UseCase<List<Map<String, dynamic>>, GetUserPublicGamesParams> {
  final UserRepository repository;

  GetUserPublicRatedGames(this.repository);

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> call(GetUserPublicGamesParams params) async {
    if (params.userId.isEmpty) {
      return const Left(ValidationFailure(message: 'User ID cannot be empty'));
    }

    return await repository.getUserPublicRatedGames(
      userId: params.userId,
      currentUserId: params.currentUserId,
      limit: params.limit,
      offset: params.offset,
    );
  }
}

class GetUserPublicRecommendedGames extends UseCase<List<Map<String, dynamic>>, GetUserPublicGamesParams> {
  final UserRepository repository;

  GetUserPublicRecommendedGames(this.repository);

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> call(GetUserPublicGamesParams params) async {
    if (params.userId.isEmpty) {
      return const Left(ValidationFailure(message: 'User ID cannot be empty'));
    }

    return await repository.getUserPublicRecommendedGames(
      userId: params.userId,
      currentUserId: params.currentUserId,
      limit: params.limit,
      offset: params.offset,
    );
  }
}

class GetUserPublicGamesParams extends Equatable {
  final String userId;
  final String? currentUserId;
  final int limit;
  final int offset;

  const GetUserPublicGamesParams({
    required this.userId,
    this.currentUserId,
    this.limit = 20,
    this.offset = 0,
  });

  @override
  List<Object?> get props => [userId, currentUserId, limit, offset];
}

