// ============================================================
// GET RATED GAMES USE CASE
// ============================================================

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import 'package:gamer_grove/data/repositories/user_repository_impl.dart';
import 'package:gamer_grove/domain/usecases/usecase.dart';

/// Use case for getting user's rated games.
///
/// NOTE: This use case requires UserRepositoryImpl as it uses implementation-specific methods.
///
/// Example:
/// ```dart
/// final useCase = GetRatedGamesUseCase(userRepository);
/// final result = await useCase(GetRatedGamesParams(
///   userId: 'uuid',
///   limit: 50,
/// ));
///
/// result.fold(
///   (games) {
///     for (final game in games) {
///     }
///   },
/// );
/// ```
class GetRatedGamesUseCase
    implements UseCase<List<Map<String, dynamic>>, GetRatedGamesParams> {

  GetRatedGamesUseCase(this.repository);
  final UserRepositoryImpl repository;

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> call(
    GetRatedGamesParams params,
  ) async {
    return repository.getRatedGames(
      params.userId,
      limit: params.limit,
      offset: params.offset,
    );
  }
}

class GetRatedGamesParams extends Equatable {

  const GetRatedGamesParams({
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
