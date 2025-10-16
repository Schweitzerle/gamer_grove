// lib/domain/usecases/collection/

/// Collection use cases for game collection operations.
library;

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import '../../../data/repositories/user_repository_impl.dart';
import '../usecase.dart';

// ============================================================
// GET USER GAME DATA USE CASE (PERFORMANCE-CRITICAL!)
// ============================================================

/// Use case for getting enriched game data for multiple games.
///
/// This is the PERFORMANCE-CRITICAL use case that uses the
/// PostgreSQL function for 40x faster enrichment!
///
/// NOTE: This use case requires UserRepositoryImpl as it uses implementation-specific methods.
///
/// Example:
/// ```dart
/// final useCase = GetUserGameDataUseCase(userRepository);
/// final result = await useCase(GetUserGameDataParams(
///   userId: 'uuid',
///   gameIds: [1942, 1905, 113],
/// ));
///
/// result.fold(
///   (failure) => print('Error: ${failure.message}'),
///   (data) {
///     final game1942Data = data[1942];
///     print('Is wishlisted: ${game1942Data['is_wishlisted']}');
///     print('Rating: ${game1942Data['rating']}');
///   },
/// );
/// ```
class GetUserGameDataUseCase
    implements UseCase<Map<int, Map<String, dynamic>>, GetUserGameDataParams> {
  final UserRepositoryImpl repository;

  GetUserGameDataUseCase(this.repository);

  @override
  Future<Either<Failure, Map<int, Map<String, dynamic>>>> call(
    GetUserGameDataParams params,
  ) async {
    if (params.gameIds.isEmpty) {
      return const Right({});
    }

    return await repository.getUserGameData(params.userId, params.gameIds);
  }
}

class GetUserGameDataParams extends Equatable {
  final String userId;
  final List<int> gameIds;

  const GetUserGameDataParams({
    required this.userId,
    required this.gameIds,
  });

  @override
  List<Object> get props => [userId, gameIds];
}
