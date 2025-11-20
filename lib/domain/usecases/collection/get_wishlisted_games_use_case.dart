// ============================================================
// GET WISHLISTED GAMES USE CASE
// ============================================================

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import '../../../data/repositories/user_repository_impl.dart';
import '../usecase.dart';

/// Use case for getting user's wishlisted games.
///
/// NOTE: This use case requires UserRepositoryImpl as it uses implementation-specific methods.
///
/// Example:
/// ```dart
/// final useCase = GetWishlistedGamesUseCase(userRepository);
/// final result = await useCase(GetWishlistedGamesParams(
///   userId: 'uuid',
///   limit: 50,
/// ));
///
/// result.fold(
/// );
/// ```
class GetWishlistedGamesUseCase
    implements UseCase<List<int>, GetWishlistedGamesParams> {
  final UserRepositoryImpl repository;

  GetWishlistedGamesUseCase(this.repository);

  @override
  Future<Either<Failure, List<int>>> call(
    GetWishlistedGamesParams params,
  ) async {
    return await repository.getWishlistedGames(
      params.userId,
      limit: params.limit,
      offset: params.offset,
    );
  }
}

class GetWishlistedGamesParams extends Equatable {
  final String userId;
  final int? limit;
  final int? offset;

  const GetWishlistedGamesParams({
    required this.userId,
    this.limit,
    this.offset,
  });

  @override
  List<Object?> get props => [userId, limit, offset];
}
