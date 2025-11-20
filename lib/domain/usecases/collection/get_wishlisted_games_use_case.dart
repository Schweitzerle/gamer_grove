// ============================================================
// GET WISHLISTED GAMES USE CASE
// ============================================================

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import 'package:gamer_grove/data/repositories/user_repository_impl.dart';
import 'package:gamer_grove/domain/usecases/usecase.dart';

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

  GetWishlistedGamesUseCase(this.repository);
  final UserRepositoryImpl repository;

  @override
  Future<Either<Failure, List<int>>> call(
    GetWishlistedGamesParams params,
  ) async {
    return repository.getWishlistedGames(
      params.userId,
      limit: params.limit,
      offset: params.offset,
    );
  }
}

class GetWishlistedGamesParams extends Equatable {

  const GetWishlistedGamesParams({
    required this.userId,
    this.limit,
    this.offset,
  });
  final String userId;
  final int? limit;
  final int? offset;

  @override
  List<Object?> get props => [userId, limit, offset];
}
