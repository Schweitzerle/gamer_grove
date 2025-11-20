// ============================================================
// TOGGLE WISHLIST USE CASE
// ============================================================

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:gamer_grove/core/errors/failures.dart';
import '../../../data/repositories/user_repository_impl.dart';
import '../usecase.dart';

/// Use case for toggling a game in wishlist.
///
/// NOTE: This use case requires UserRepositoryImpl as it uses implementation-specific methods.
///
/// Example:
/// ```dart
/// final useCase = ToggleWishlistUseCase(userRepository);
/// final result = await useCase(ToggleWishlistParams(
///   userId: 'uuid',
///   gameId: 1942,
/// ));
///
/// result.fold(
/// );
/// ```
class ToggleWishlistUseCase implements UseCase<void, ToggleWishlistParams> {
  final UserRepositoryImpl repository;

  ToggleWishlistUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(ToggleWishlistParams params) async {
    return await repository.toggleWishlist(params.userId, params.gameId);
  }
}

class ToggleWishlistParams extends Equatable {
  final String userId;
  final int gameId;

  const ToggleWishlistParams({
    required this.userId,
    required this.gameId,
  });

  @override
  List<Object> get props => [userId, gameId];
}
