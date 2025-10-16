// ============================================================
// GET RATED GAMES USE CASE
// ============================================================

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import '../../../data/repositories/user_repository_impl.dart';
import '../usecase.dart';

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
///   (failure) => print('Error: ${failure.message}'),
///   (games) {
///     for (final game in games) {
///       print('Game ${game['game_id']}: ${game['rating']}');
///     }
///   },
/// );
/// ```
class GetRatedGamesUseCase
    implements UseCase<List<Map<String, dynamic>>, GetRatedGamesParams> {
  final UserRepositoryImpl repository;

  GetRatedGamesUseCase(this.repository);

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> call(
    GetRatedGamesParams params,
  ) async {
    return await repository.getRatedGames(
      params.userId,
      limit: params.limit,
      offset: params.offset,
    );
  }
}

class GetRatedGamesParams extends Equatable {
  final String userId;
  final int? limit;
  final int? offset;

  const GetRatedGamesParams({
    required this.userId,
    this.limit,
    this.offset,
  });

  @override
  List<Object?> get props => [userId, limit, offset];
}
